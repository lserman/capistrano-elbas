module Elbas
  module AWS
    class AMI < Base
      include Taggable

      DEPLOY_ID_TAG = 'ELBAS-Deploy-id'.freeze
      DEPLOY_GROUP_TAG = 'ELBAS-Deploy-group'.freeze

      attr_reader :id, :snapshots

      def initialize(id, snapshots = [])
        @id = id
        @aws_counterpart = ::Aws::EC2::Image.new id, client: aws_client

        @snapshots = snapshots.map do |snapshot|
          Elbas::AWS::Snapshot.new snapshot&.ebs&.snapshot_id
        end
      end

      def deploy_id
        tags[DEPLOY_ID_TAG]
      end

      def deploy_group
        tags[DEPLOY_GROUP_TAG]
      end

      def ancestors
        aws_amis_in_deploy_group.select { |aws_ami|
          deploy_id_from_aws_tags(aws_ami.tags) != deploy_id
        }.map { |aws_ami|
          self.class.new aws_ami.image_id, aws_ami.block_device_mappings
        }
      end

      def delete
        aws_client.deregister_image image_id: id
        snapshots.each(&:delete)
      end

      def self.create(instance, no_reboot: true)
        ami = instance.aws_counterpart.create_image({
          name: "ELBAS-ami-#{Time.now.to_i}",
          instance_id: instance.id,
          no_reboot: no_reboot
        })

        new ami.id
      end

      private
        def aws_namespace
          ::Aws::EC2
        end

        def aws_amis_in_deploy_group
          aws_client.describe_images({
            owners: ['self'],
            filters: [{
              name: "tag:#{DEPLOY_GROUP_TAG}",
              values: [deploy_group],
            }]
          }).images
        end

        def deploy_id_from_aws_tags(tags)
          tags.detect { |tag| tag.key == DEPLOY_ID_TAG }&.value
        end
    end
  end
end