module Elbas
  # Create launch configuration
  class LaunchConfiguration < AWSResource
    def self.create(ami, &_block)
      lc = new
      lc.cleanup do
        lc.save(ami)
        yield lc
      end
    end

    def save(ami)
      info "Creating an EC2 Launch Configuration for AMI: #{ami.aws_counterpart.id}"
      ec2_instance = ec2_resource.instance(base_ec2_instance.id)
      with_retry do
        @aws_counterpart = autoscaling_resource.create_launch_configuration(
          launch_configuration_name: name,
          image_id: ami.aws_counterpart.id,
          instance_type: instance_size,
          security_groups: ec2_instance.security_groups.map(&:group_id),
          associate_public_ip_address:
            fetch(:aws_launch_configuration_associate_public_ip, true),
          instance_monitoring: {
            enabled: fetch(:aws_launch_configuration_detailed_instance_monitoring, true)
          },
          user_data: fetch(:aws_launch_configuration_user_data, nil)
        )
      end
    end

    def attach_to_autoscale_group!
      info "Attaching Launch Configuration #{aws_counterpart.name} to AutoScaling Group #{autoscaling_group.name}"
      autoscaling_group.update(
        launch_configuration_name: aws_counterpart.name
      )
    end

    def destroy(launch_configurations = [])
      launch_configurations.each do |lc|
        info "Deleting old Launch Configuration: #{lc.name}"
        lc.delete
      end
    end

    private

    def name
      timestamp "ELBAS-#{environment}-#{autoscaling_group_name}-LC"
    end

    def instance_size
      fetch(:aws_autoscale_instance_size, 'm1.small')
    end

    def deployed_with_elbas?(lc)
      lc.name.include? "ELBAS-#{environment}-#{autoscaling_group_name}-LC"
    end

    def trash
      autoscaling_resource.launch_configurations.to_a.select do |lc|
        deployed_with_elbas? lc
      end
    end
  end
end
