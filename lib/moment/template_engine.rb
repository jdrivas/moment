module Moment
  class TemplateEngine

    @@engine = Moment::NoTemplate

    @@available_engines = [:simple_php,:no_template,:none]

    # Pick a template engine based on the symbol.
    # true on success, false if not found.
    def self.set_engine(template_sym)
      found = false
      case template_sym
      when :simple_php
        @@engine = Moment::SimplePhp
        found = true
      when :none
        @@engine = Moment::NoTemplate
        found = true
      when :no_template
        @@engine = Moment::NoTemplate
        found =true
      else
        found = false
      end

      return found
    end

    # Get the currently selected tempate engine.
    def self.get_engine
      return @@engine
    end

    def self.get_available_engines
      return @@available_engines
    end
  end
end
