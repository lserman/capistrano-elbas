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
        timestamp "ELBAS-#{environment}-LC"
      end

      def instance_size
        fetch(:aws_autoscale_instance_size, 'm1.small')
      end

      def detailed_instance_monitoring
        fetch(:aws_autoscale_detailed_instance_monitoring, false)
      end

      def aws_key_pair
        fetch(:aws_autoscale_key_pair, nil)
      end


      def create_options
        _options = {
          security_groups: base_ec2_instance.security_groups.to_a,
          detailed_instance_monitoring: detailed_instance_monitoring,
          associate_public_ip_address: true
        }

        if user_data = fetch(:aws_launch_configuration_user_data, nil)
          _options.merge user_data: user_data
        end

        unless aws_key_pair.nil?
          _options.merge key_pair: aws_key_pair
        end
        debug "autoscaling key_pair #{aws_key_pair}"
        debug "autoscaling launch_configurations_options #{_options}"
        _options
      end

      def deployed_with_elbas?(lc)
        lc.name =~ /ELBAS-#{environment}/
      end

      def trash
        autoscaling.launch_configurations.to_a.select do |lc|
          deployed_with_elbas? lc
        end
      end

  end
end
