module Elbas
  class AMI < AWSResource
    include Taggable

    def self.create(&block)
      ami = new
      ami.cleanup do
        ami.save
        ami.tag 'Deployed-with' => 'ELBAS'
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
        i.delete
      end
    end

    private

      def name
        timestamp "ELBAS-#{environment}-#{$server_role}-AMI"
      end

      def trash
        ec2.images.with_owner('self').to_a.select do |ami|
          deployed_with_elbas? ami
        end
      end

  end
end
