# encoding: utf-8
module Sinicum
  module Content
    # Public: Handles the content and provides access to it during a request
    class Aggregator
      include Sinicum::Logger
      class << self
        # Public: Set the "original content" of a request, i.e. the content object
        # that represents the "base" of the request, before any other object is
        # subsequently pushed. Usually the content object of the node corresponding
        # to the URI called.
        #
        # Usually, this method should only be called once during a request.
        #
        # When this method is called, all other stacks (`content_data`,
        # `content_node`) are being reset.
        #
        # node - The Node with the original content object.
        #
        # Returns nothing.
        def original_content=(node)
          clean
          Thread.current[:__cms_original_content] = node
        end

        # Retrieves the `original_content` object.
        #
        # Returns a Node with the original content object.
        def original_content
          Thread.current[:__cms_original_content]
        end

        # Retrieves the current "active page", comparable to the Magnolia property
        # "actpage".
        #
        # Returns the Node with the current "active page" or the `original_content`
        # if no active page has explicitly been set.
        def active_page
          stack(:__cms_active_page).first || original_content
        end

        # Sets a new "active page", makes it the new `cms_content_data` and executes
        # the given block in this context. Resets all changes afterwards.
        #
        # node - The node with the active active page.
        def push_active_page(node, &block)
          stack(:__cms_active_page).push(node)
          begin
            push(node) do
              yield
            end
          ensure
            pop(:__cms_active_page)
          end
        end

        # Retrieves the `content_data` object currently on top of the stack.
        #
        # Returns the current Node.
        def content_data
          if stack && stack.length > 0
            stack.last
          else
            original_content
          end
        end

        # Push a new `content_data` object on top of the stack and pop it after
        # returning from the block
        #
        # node - The Node to push on top of the stack
        def push(node, &block)
          stack.push(node)
          begin
            yield
          ensure
            pop
          end
        end

        # Push a new `Content` object on top of the stack and update Magnolia's
        # `current_content`.
        #
        # node - The object to push, must wrap a Magnolia `Content` object.
        def push_current_content(node, &block)
          stack.push(node)
          begin
            yield
          ensure
            pop
          end
        end

        def push_node_iterator(node, key)
          stack(:__content_iterator_stack).push(node)
          stack(:__content_iterator_stack_key).push(key)
          begin
            yield
          ensure
            pop(:__content_iterator_stack)
            pop(:__content_iterator_stack_key)
          end
        end

        def node_iterator_key
          stack(:__content_iterator_stack_key).last
        end

        def node_iterator
          stack(:__content_iterator_stack).last
        end

        # Convenience method for pushing the _contents_ of a `ContentNode` with the _name_
        # `content_node_name`, based on the current `content_data` object, on top of the stack
        # and popping it afterwards. If no node with the name exists, an empty `Hash` is pushed.
        #
        # Primarily intended to be used with the `cms_content_node` helper
        #
        # @param [String] content_node_name the name of the `content_node` as it is stored in the
        # current `content_data` object
        def push_content_node(content_node_name, &block)
          node_data = nil
          if content_data && content_data.key?(content_node_name)
            node_data = content_data[content_node_name]
          else
            node_data = {}
          end
          stack(:__content_node_stack).push(content_node_name)
          stack.push(node_data)
          begin
            yield
          ensure
            pop
            pop(:__content_node_stack)
          end
        end

        # Retrieves the current `content_node` or `nil` if none is set
        #
        # @return [Content, nil] _Usually_ a `Content`-like object, `nil` if no `content_node`
        # has been set
        def content_node
          if stack(:__content_node_stack) && stack(:__content_node_stack).length > 0
            stack(:__content_node_stack).last
          else
            nil
          end
        end

        # Resets all stacks. Should always be called at the end of a request
        def clean
          Thread.current[:__cms_original_content] = nil
          Thread.current[:__cms_active_page] = nil
          Thread.current[:__cms_stack] = nil
          Thread.current[:__content_node_stack] = nil
          Thread.current[:__content_iterator_stack] = nil
          Thread.current[:__content_iterator_stack_key] = nil
        end

        private

        def pop(stack_name = :__cms_stack)
          stack(stack_name).pop
        end

        def stack(stack_name = :__cms_stack)
          Thread.current[stack_name] ||= []
          Thread.current[stack_name]
        end
      end
    end
  end
end
