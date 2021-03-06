module Gitlab
  # Wrapper class of paginated response.
  class PaginatedResponse
    attr_accessor :client

    def initialize(array)
      @array = array
    end

    def ==(other)
      @array == other
    end

    def inspect
      @array.inspect
    end

    def method_missing(name, *args, &block)
      if @array.respond_to?(name)
        @array.send(name, *args, &block)
      else
        super
      end
    end

    def respond_to?(method, include_all=false)
      super || @array.respond_to?(method, include_all)
    end

    def parse_headers!(headers)
      @links = PageLinks.new headers
    end

    def each_page
      current = self
      yield current
      while current.has_next_page?
        current = current.next_page
        yield current
      end
    end

    def auto_paginate
      response = block_given? ? nil : []
      each_page do |page|
        if block_given?
          page.each do |item|
            yield item
          end
        else
          response += page
        end
      end
      response
    end

    def has_last_page?
      !(@links.nil? || @links.last.nil?)
    end

    def last_page
      return nil if @client.nil? || !has_last_page?
      path = @links.last.sub(/#{@client.endpoint}/, '')
      @client.get(path)
    end

    def has_first_page?
      !(@links.nil? || @links.first.nil?)
    end

    def first_page
      return nil if @client.nil? || !has_first_page?
      path = @links.first.sub(/#{@client.endpoint}/, '')
      @client.get(path)
    end

    def has_next_page?
      !(@links.nil? || @links.next.nil?)
    end

    def next_page
      return nil if @client.nil? || !has_next_page?
      path = @links.next.sub(/#{@client.endpoint}/, '')
      @client.get(path)
    end

    def has_prev_page?
      !(@links.nil? || @links.prev.nil?)
    end

    def prev_page
      return nil if @client.nil? || !has_prev_page?
      path = @links.prev.sub(/#{@client.endpoint}/, '')
      @client.get(path)
    end
  end
end
