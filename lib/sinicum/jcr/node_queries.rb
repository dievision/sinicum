require 'multi_json'

module Sinicum
  module Jcr
    module NodeQueries
      PATH_DELIMITER = '/'
      UUID_PREFIX = "_uuid"
      BINARY_PREFIX = "_binary"
      extend ActiveSupport::Concern

      module ClassMethods
        include Sinicum::Logger
        include ApiClient
        include QuerySanitizer

        def find_by_path(workspace, path)
          Sinicum::Cache::ThreadLocalCache.fetch(["node-path", workspace, path].join("-")) do
            url = construct_url(workspace, nil, path)
            return_first_item(url)
          end
        end

        def find_by_uuid(workspace, uuid)
          if uuid.is_a?(Array)
            query(workspace, :'JCR-SQL2', construct_query_for_uuids(uuid))
          else
            Sinicum::Cache::ThreadLocalCache.fetch(["node-uuid", workspace, uuid].join("-")) do
              url = construct_url(workspace, UUID_PREFIX, uuid)
              return_first_item(url)
            end
          end
        end

        def query(workspace, language, query, parameters = nil, options = {})
          url = "/#{workspace}/_query"
          sanitized = sanitize_query(language, query, parameters)
          api_hash = { "query" => sanitized, "language" => language.to_s }
          api_hash["limit"] = options[:limit] if options[:limit]
          api_hash["offset"] = options[:offset] if options[:offset]
          response = api_get(url, api_hash)
          from_rest_response(response)
        end

        def stream_attribute(workspace, path, property_name, output)
          connection = ApiQueries.http_client.get_async(
            ApiQueries.jcr_configuration.base_url + construct_url(workspace, BINARY_PREFIX, path),
            "property" => property_name)
          response = connection.pop
          while result = response.content.read(256)
            output.write(result)
          end
        end

        private

        def return_first_item(url)
          response = api_get(url)
          nodes = from_rest_response(response)
          result = nodes
          result = nodes.first if nodes && nodes.is_a?(Array)
          result
        end

        def from_rest_response(result)
          if result.status == 200
            instances = create_instances(result.body)
            return instances
          elsif result.status == 404
            return
          elsif result.status == 500
            message = "Error fetching content"
            begin
              if result.headers["Content-Type"] =~ /application\/json/
                message << ": #{MultiJson.load(result.body)["message"]}"
              end
            rescue
              # nothing
            end
            fail message
          end
          the_status = result ? result.status : "undefined"
          fail "Error fetching JCR content object. Server status: #{the_status}"
        end

        def create_instances(body)
          instances = []
          json = MultiJson.load(body)
          if json.is_a?(Array)
            json.each do |node|
              instance = NodeInitializer.initialize_node_from_json(node)
              instances << instance if instance
            end
          else
            instance = NodeInitializer.initialize_node_from_json(json)
            instances << instance if instance
          end
          instances
        end

        def construct_url(workspace, action, path)
          fail "JCR access is not configured" unless ApiQueries.jcr_configuration
          action = PATH_DELIMITER + action if action && action[0] && action[0] != PATH_DELIMITER
          path = PATH_DELIMITER + path if path && path[0] && path[0] != PATH_DELIMITER
          "/#{workspace}#{action}#{path}"
        end

        def construct_query_for_uuids(uuids)
          query_string = "SELECT * FROM [nt:base] WHERE " #[jcr:uuid] = '4374582d-6e38-492f-8d02-ec104cef731b' OR [jcr:uuid] = '382a97fa-b587-41c8-b61e-fb554dc4a7c9'"
          uuids.each do |uuid|
            next unless Sinicum::Util.is_a_uuid? uuid
            query_string << "[jcr:uuid] = '#{uuid}' OR "
          end
          query_string[0, -5]
        end
      end
    end
  end
end
