module Elbas
  class AMI < AWS
    include Capistrano::DSL

    def self.create(&block)
      ami = new
      ami.cleanup do
        ami.save
        yield ami
      end
    end

    def save
      info "Creating EC2 AMI from #{base_ec2_instance.id}"
      @aws_counterpart = ec2.images.create \
        name: timestamp(name_prefix),
        instance_id: base_ec2_instance.id,
        no_reboot: true
    end

    def destroy(images = [])
      images.each do |i|
        info "Deleting old image: #{i.id}"
        i.delete
      end
    end

    private

      def name_prefix
        "elbas-ami-#{environment}"
      end

      def garbage
        ec2.images.with_owner('self').to_a.select do |i|
          i.name =~ /#{name_prefix}/i
        end
      end

  end
end