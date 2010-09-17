Extending Hyde
==============

Creating extensions
-------------------

In your Hyde project's extensions folder (`extensions` by default), create a file called
`<name>/<name>.rb`, where `<name>` is the name of your extension. This file will automatically loaded.

Example:

    # extensions/hyde-blog/hyde-blog.rb
    module Hyde
      # Set up autoload hooks for the other classes
      prefix = File.dirname(__FILE__)
      autoload :Blog,   "#{prefix}/lib/blog.rb"
    end

Creating extensions as gems
---------------------------

You may also create your extensions as gems. It is recommended to name them as `hyde-(name)`,
for instance, `hyde-blog`.

To load gem extensions in your Hyde project, add them to the `gems` section of your project's 
config file (typically `hyde.conf`). Example:

    # hyde.conf
    gems:
     - hyde-blog
     - hyde-clean

Adding helpers
--------------

Make a module under `Hyde::Helpers`. Any functions here will be available to your files.

Example:

In this example, we'll create a simple helper function.

    # extensions/hyde-blog/hyde-blog.rb
    module Hyde
      module Helpers
        module BlogHelpers
          def form_tag(meth, action, &b)
            [ "<form method='#{meth}' action='#{action}'>",
              b.call,
              "</form>"
            ].join("\n")
          end
        end
      end
    end

In your project's site files, you can then now use this helper.

    # site/my_page.html.haml
    %h1 My form
    = form_tag 'post', '/note/new' do
      %p
        %label Your name:
        %input{ :type => 'text', :name => 'name' }
      %p
        %label Your email:
        %input{ :type => 'text', :name => 'email' }

Adding commands
---------------

Create a subclass of the class {Hyde::CLICommand} and place it under the {Hyde::CLICommands} module.
The name of the class will be the command it will be accessible as.

This example below defines a new `clean` command, which will be accessible by typing `hyde clean`.
It will also show under `hyde --help` since it provides a `desc`.

    # extensions/hyde-clean/hyde-clean.rb
    module Hyde
      module CLICommands
        class Clean < CLICommand
          desc "Cleans up your project's dirt"

          def self.run(*a)
            if a.size > 0
              log "Unknown arguments: #{a.join(' ')}"
              log "Type `hyde --help clean` for more information."
              exit
            end

            log "Cleaning..."
            # Do stuff here
            log "All clean!"
          end
        end
      end
    end

This may now be used in the command line.

    $ hyde clean all
    Unknown arguments: all
    Type `hyde --help clean` for more information.

    $ hyde clean
    Cleaning...
    All done!

    $ hyde --help
    Usage: hyde <command> arguments

    Commands:
       ....
       clean            Cleans up your project's dirt

Adding parsers
--------------

TODO.
