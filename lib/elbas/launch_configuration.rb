module Elbas
  class LaunchConfiguration < AWS

    def self.create(ami, &block)
      lc = new
      lc.cleanup do
        lc.save(ami)
        yield lc
      end
    end

    def save(ami)
      info "Creating an EC2 Launch Configuration for AMI: #{ami.id}"
      @aws_counterpart = autoscaling.launch_configurations.create(timestamp(name_prefix), ami.id, instance_size, create_options)
    end

    def attach_to_asgroup!
      info "Attaching Launch Configuration to AutoScale Group"
      asgroup.update(launch_configuration: aws_counterpart)
    end

    def destroy(launch_configurations = [])
      launch_configurations.each do |lc|
        info "Deleting old launch configuration: #{lc.name}"
        lc.delete
      end
    end

    private

      def name_prefix
        "elbas-lc-#{environment}"
      end

      def create_options
        _options = {
          security_groups: base_ec2_instance.security_groups.to_a,
          detailed_instance_monitoring: true,
          associate_public_ip_address: true,
        }

        if asgroup_already_had_launch_configuration_attached?
          _options.merge user_data: old_launch_configuration.user_data
        end

        _options
      end

      def asgroup_already_had_launch_configuration_attached?
        !!old_launch_configuration
      end

      def old_launch_configuration
        @_old_launch_configuration ||= asgroup.launch_configurations.first
      end

      def instance_size
        fetch(:aws_autoscale_instance_size, 'm1.small')
      end

      def garbage
        autoscaling.launch_configurations.to_a.select do |lc|
          lc.name =~ /#{name_prefix}/i
        end
      end

  end
end