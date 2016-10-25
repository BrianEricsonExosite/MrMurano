
command :status do |c|
  c.syntax = %{mr status [options]}
  c.description = %{Get the status of files}
  c.option '--all', 'Check everything'
  c.option '-s','--[no-]files', %{Static Files}
  c.option '-a','--[no-]endpoints', %{Endpoints}
  c.option '-m','--[no-]modules', %{Modules}
  c.option '-e','--[no-]eventhandlers', %{Event Handlers}
  c.option '--[no-]roles', %{Roles}
  c.option '--[no-]users', %{Users}
  c.option '-p','--[no-]spec', %{Product Specification}

  c.option '--[no-]asdown', %{Report as if syncdown instead of syncup}
  c.option '--[no-]diff', %{For modified items, show a diff}
  c.option '--[no-]grouped', %{Group all adds, deletes, and mods together}
  c.option '--[no-]showall', %{List unchanged as well}

  c.action do |args,options|
    options.default :delete=>true, :create=>true, :update=>true, :diff=>false,
      :grouped => true

    def fmtr(item)
      if item.has_key? :local_path then
        item[:local_path].relative_path_from(Pathname.pwd()).to_s
      else
        item[:synckey]
      end
    end
    def pretty(ret, options)
      say "Adding:" if options.grouped
      ret[:toadd].each{|item| say " + #{item[:pp_type]}  #{fmtr(item)}"}
      say "Deleteing:" if options.grouped
      ret[:todel].each{|item| say " - #{item[:pp_type]}  #{fmtr(item)}"}
      say "Changing:" if options.grouped
      ret[:tomod].each{|item|
        say " M #{item[:pp_type]}  #{fmtr(item)}"
        say item[:diff] if options.diff
      }
      if options.showall then
        say "Unchanged:" if options.grouped
        ret[:unchg].each{|item| say "   #{item[:pp_type]}  #{fmtr(item)}"}
      end
    end

    @grouped = {:toadd=>[],:todel=>[],:tomod=>[], :unchg=>[]}
    def gmerge(ret, type, options)
      if options.grouped then
        [:toadd, :todel, :tomod, :unchg].each do |kind|
          ret[kind].each{|item| item[:pp_type] = type; @grouped[kind] << item}
        end
      else
        pretty(ret, options)
      end
    end

    MrMurano::SyncRoot.each_filtered(options) do |name, type, klass|
      sol = klass.new
      ret = sol.status(options)
      gmerge(ret, type, options)
    end

    pretty(@grouped, options) if options.grouped
  end
end

alias_command :diff, :status, '--diff', '--no-grouped'

#  vim: set ai et sw=2 ts=2 :
