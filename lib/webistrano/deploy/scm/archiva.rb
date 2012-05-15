require 'capistrano/recipes/deploy/scm/base' 
require 'rexml/document'

module Capistrano 
  module Deploy
    module SCM
      class Archiva < Base
	      # Sets the default command name for this SCM on your *local* machine.
        # Users may override this by setting the :scm_command variable.
        default_command "wget"

	      def checkout(revision, destination)
          wget = command

          execute = []
	        execute << "mkdir -p #{destination}"
	        execute << "cd #{destination}"
          execute << "#{wget} #{verbose} -r -np -nd -A #{file_type} #{configuration[:repository]}/#{revision}/ "
          
          execute.join(" && ")
        end

      	def head
      	  configuration[:version] || 'release'
      	end

      	def query_revision(revision)
      	  return revision if revision =~ /^[0-9\.]+$/
      	  command = "curl #{repository}/maven-metadata.xml -sS"
      	  raise ArgumentError, "Unknown version: '#{revision}'. Must be version number or 'release'." unless revision == "release"
      	  result = yield(command)
      	  doc = REXML::Document.new(result)
      	  rev = REXML::XPath.first(doc, "//#{revision}")
      	  raise "Unable to resolve revision for '#{revision}' on repository '#{repository}'." unless rev.text =~ /^[0-9\.]+$/
      	  return rev.text
      	end

      	def export(revision, destination)
      	  checkout(revision, destination)
      	end

	      private
        def verbose
          variable(:scm_verbose) ? nil : "-q"
        end
		
    	  def file_type
    	    files = configuration[:file_type] || 'war'
    	    files = files.to_a
    	    logger.info "Checking out #{files.join(', ')} files."
     	    files = files.map { |file| file = "*.#{file}" }
    	    files.join(',')  
    	  end
      end
    end
  end
end
