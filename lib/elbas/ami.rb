module Elbas
  class AMI < AWSResource
    include Taggable

    def self.create(&block)
      ami = new
      ami.cleanup do
        ami.save
        ami.tag 'Deployed-with' => 'ELBAS'
        ami.tag 'ELBAS-Deploy-group' => ami.autoscale_group_name
        yield ami
      end
    end

    def save
      info "Creating EC2 AMI from EC2 Instance: #{base_ec2_instance.id}"
      @aws_counterpart = ec2.images.create \
        name: name,
        instance_id: base_ec2_instance.id,
        no_reboot: fetch(:aws_no_reboot_on_create_ami, true)
    end

    def destroy(images = [])
      images.each do |i|
        info "Deleting old AMI: #{i.id}"
        snapshots = snapshots_attached_to i
        i.delete if i.exists?
        delete_snapshots snapshots
      end
    end

    private
      def name
        timestamp "#{environment}-AMI"
      end

      def trash
        ec2.images.with_owner('self').to_a.select do |ami|
          deployed_with_elbas? ami
        end
      end

      def snapshots_attached_to(image)
        image.block_device_mappings.map do |_, values|
          ec2.snapshots[values[:snapshot_id]]
        end
      end

      def delete_snapshots(snapshots)
        snapshots.each do |snapshot|
          info "Deleting snapshot: #{snapshot.id}"
          snapshot.delete if snapshot.exists?
        end
      end
  end
end
