require 'MrMurano/Solution'

module MrMurano
  # …/serviceconfig
  class ServiceConfig < SolutionBase
    def initialize
      super
      @uriparts << 'serviceconfig'
    end

    def list
      get()[:items]
    end
    def fetch(id)
      get('/' + id.to_s)
    end

    def scid_for_name(name)
      name = name.to_s unless name.kind_of? String
      scr = list().select{|i| i[:service] == name}.first
      scr[:id]
    end

    def scid
      return @scid unless @scid.nil?
      @scid = scid_for_name(@serviceName)
    end

    def info(id=scid)
      get("/#{id}/info")
    end

    def logs(id=scid)
      get("/#{id}/logs")
    end

    def call(op, post=nil, id=scid)
      call = "/#{id.to_s}/call/#{op.to_s}"
      if post.nil? then
        get(call)
      else
        post(call, post)
      end
    end

  end

  class SC_Device < ServiceConfig
    def initialize
      super
      @serviceName = 'device'
    end

    def assignTriggers(products)
      details = fetch(scid)
      products = [products] unless products.kind_of? Array
      details[:triggers] = {:pid=>products, :vendor=>products}

      put('/'+scid, details)
    end

    def showTriggers
      details = fetch(scid)

      return [] if details[:triggers].nil?
      details[:triggers][:pid]
    end

  end
end

#  vim: set ai et sw=2 ts=2 :
