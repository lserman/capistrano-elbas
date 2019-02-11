module Elbas
  module AWS
    class AMI < Base
      include Taggable

      attr_reader :id, :snapshots

      def initialize(id, snapshots = [])
        @id = id
        @aws_counterpart = ::Aws::EC2::Image.new id

        @snapshots = snapshots.map do |snapshot|
          Elbas::AWS::Snapshot.new snapshot&.ebs&.snapshot_id
        end
      end

      def deploy_id
        tags['ELBAS-Deploy-id']
      end

      def deploy_group
        tags['ELBAS-Deploy-group']
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
              name: 'tag:ELBAS-Deploy-group',
              values: [deploy_group],
            }]
          }).images
        end

        def deploy_id_from_aws_tags(tags)
          tags.detect { |tag| tag.key == 'ELBAS-Deploy-id' }&.value
        end
    end
  end
end