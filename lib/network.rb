require_relative 'config'

require 'httparty'
require 'pry'
require 'json'

module GitlabCi
  class Network
    include HTTParty

    # check for available build from coordinator
    # and pick a pending one
    # {
    #   commands: ['ls -la'],
    #   path: '/home/git/testproject',
    #   ref: '3ee2b0fda79b326692135f5fb69da8c2eb557709',
    #   id: rand(1900)
    # }
    def get_build
      print 'Checking for builds...'

      opts = {
        body: default_options.to_json,
        headers: {"Content-Type" => "application/json"},
      }

      response = self.class.post(url + '/api/v1/builds/register.json', opts)

      if response.code == 201
        {
          id: response['id'],
          commands: response['commands'].lines,
          path: response['path'],
          ref: response['sha'],
        }
      else
        nil
      end
    rescue
      puts 'failed'
      nil
    end

    def update_build(id, state, trace)

      options = default_options.merge(
        state: state,
        trace: trace,
      )

      self.class.put("#{url}/builds/#{id}.json", body: options)
    end

    private

    def url
      config.url
    end

    def token
      config.token
    end

    def config
      @config ||= Config.new
    end

    def default_options
      {
        token: token
      }
    end
  end
end