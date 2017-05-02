module Elbas
  # Extend AWS Resource class to include AMI methods
  class AMI < AWSResource
    include Taggable

    def self.create(&_block)
      ami = new
      ami.cleanup do
        ami.save
        ami.tag 'Deployed-with' => 'ELBAS'
        ami.tag 'ELBAS-Deploy-group' => ami.autoscaling_group_name
        yield ami
      end
    end

    def save
      info "Creating EC2 AMI from EC2 Instance: #{base_ec2_instance.id}"
      ec2_instance = ec2_resource.instance(base_ec2_instance.id)
      @aws_counterpart = ec2_instance.create_image(
        name: name,
        no_reboot: fetch(:aws_no_reboot_on_create_ami, true)
      )
    end

    def destroy(images = [])
      images.each do |i|
        info "Deleting old AMI: #{i.id}"
        snapshots = snapshots_attached_to i
        i.deregister
        delete_snapshots snapshots
      end
    end

    private

    def name
      timestamp "latest-#{environment}-AMI"
    end

    def trash
      ec2_resource.images(owners: ['self']).to_a.select do |ami|
        deployed_with_elbas? ami
      end
    end

    def snapshots_attached_to(image)
      ids = image.block_device_mappings.map(&:ebs).compact.map(&:snapshot_id)
      ec2_resource.snapshots(snapshot_ids: ids)
    end

    def delete_snapshots(snapshots)
      snapshots.each do |snapshot|
        info "Deleting snapshot: #{snapshot.id}"
        snapshot.delete unless snapshot.nil?
      end
    end
  end
end
