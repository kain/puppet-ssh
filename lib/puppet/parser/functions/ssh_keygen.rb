# Takes a Hash of config arguments:
#   Required parameters:
#     :name   (the name of the key - e.g 'my_ssh_key')
#   Optional parameters:
#     :type   (the key type - default: 'rsa')
#     :dir    (the subdir of /var/lib/puppet/modules_data to store the key in - default: 'ssh')
#     :size   (the key size - default 2048)
#TODO :side   (host - for host key; user - for user key)
#     :part   (public - for regular public part of key; signed - for certificate signed by CA; private key if any other specified)
#
require 'fileutils'
module Puppet::Parser::Functions
  newfunction(:ssh_keygen, :type => :rvalue) do |args|
    unless args.first.class == Hash then
      raise Puppet::ParseError, "ssh_keygen(): config argument must be a Hash"
    end

    config = args.first

    config = {
      'type'   => 'rsa',
      'dir'    => 'ssh',
      'size'   => 2048,
      'side'   => 'host',
      'part'   => 'private',
    }.merge(config)

    config['size'] = 1024 if config['type'] == 'dsa' and config['size'] > 1024

    fullpath = "/var/lib/puppet/modules_data/#{config['dir']}"
    fullname = "ssh_host_#{config['type']}_#{config['name']}"

    # Make sure to write out a directory to init if necessary
    begin
      if !File.directory? fullpath
        FileUtils.mkdir_p fullpath
      end
    rescue => e
      raise Puppet::ParseError, "ssh_keygen(): Unable to setup ssh keystore directory (#{e}) #{%x[whoami]}"
    end

    # Do my keys exist? Well, keygen if they don't!
    begin
      unless File.exists?("#{fullpath}/#{fullname}") then
        %x[/usr/bin/ssh-keygen -t #{config['type']} -b #{config['size']} -P '' -f #{fullpath}/#{fullname}]
      end
    rescue => e
      raise Puppet::ParseError, "ssh_keygen(): Unable to generate ssh key (#{e})"
    end

    # Sign public part of the ssh key by CA key
    begin
      unless File.exists?("#{fullpath}/#{fullname}-cert.pub") then
        %x[/usr/bin/ssh-keygen -s /etc/ssh/signing/server_ca -I host_sshserver -h -n #{config['name']} -V +156w #{fullpath}/#{fullname}.pub]
      end
    rescue => e
      raise Puppet::ParseError, "ssh_keygen(): Unable to sign ssh key (#{e})"
    end

    # Return ssh key content based on request
    begin
      case config['part']
      when 'public'
        request = 'public key'
        pub_key = File.open("#{fullpath}/#{fullname}.pub").read
        foo = pub_key.scan(/^.* (.*) .*$/)[0][0]
        return foo
      when 'signed'
        request = 'certificate'
        return File.open("#{fullpath}/#{fullname}-cert.pub").read
      else
        request = 'private key'
        return File.open("#{fullpath}/#{fullname}").read
      end
    rescue => e
      raise Puppet::ParseError, "ssh_keygen(): Unable to read ssh #{request.to_s} (#{e})"
    end
  end
end
