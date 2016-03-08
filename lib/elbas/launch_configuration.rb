module Elbas
  class LaunchConfiguration < AWSResource

    def self.create(ami, &block)
      lc = new
      lc.cleanup do
        lc.save(ami)
        yield lc
      end
    end

    def save(ami)
      info "Creating an EC2 Launch Configuration for AMI: #{ami.aws_counterpart.id}"
      with_retry do
        @aws_counterpart = autoscaling.launch_configurations.create(name, ami.aws_counterpart.id, instance_size, create_options)
      end
    end

    def attach_to_autoscale_group!
      info "Attaching Launch Configuration to AutoScale Group"
      autoscale_group.update(launch_configuration: aws_counterpart)
    end

    def destroy(launch_configurations = [])
      launch_configurations.each do |lc|
        info "Deleting old launch configuration: #{lc.name}"
        lc.delete
      end
    end

    private

      def name
        timestamp "ELBAS-#{environment}-#{autoscale_group_name}-LC"
      end

      def instance_size
        fetch(:aws_autoscale_instance_size, 'm1.small')
      end

      def create_options
        _options = {
          security_groups: base_ec2_instance.security_groups.to_a,
          detailed_instance_monitoring: fetch(:aws_launch_configuration_detailed_instance_monitoring, true),
          associate_public_ip_address: fetch(:aws_launch_configuration_associate_public_ip, true),
        }

        if user_data = fetch(:aws_launch_configuration_user_data, nil)
          _options.merge user_data: user_data
        end

        _options
      end

      def deployed_with_elbas?(lc)
        lc.name =~ /ELBAS-#{environment}-#{autoscale_group_name}/
      end

      def trash
        autoscaling.launch_configurations.to_a.select do |lc|
          deployed_with_elbas? lc
        end
      end

  end
end
