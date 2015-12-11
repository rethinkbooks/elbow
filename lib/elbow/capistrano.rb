require 'aws-sdk'
require 'net/dns'
require 'capistrano/dsl'

def elastic_load_balancer(name, *args)

    include Capistrano::DSL

    aws_region= fetch(:aws_region, 'us-east-1')
    AWS.config(:access_key_id => fetch(:aws_access_key_id),
        :secret_access_key => fetch(:aws_secret_access_key),
        :ec2_endpoint => "ec2.#{aws_region}.amazonaws.com",
        :elb_endpoint => "elasticloadbalancing.#{aws_region}.amazonaws.com")

    load_balancer = AWS::ELB.new.load_balancers[name]
    raise "EC2 Load Balancer not found for #{name} in region #{aws_region}" if load_balancer.nil?

    load_balancer.instances.each do |instance|
        hostname = instance.dns_name || instance.private_ip_address
        server(hostname, *args)
    end
end
