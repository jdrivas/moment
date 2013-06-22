module Moment
  class SimplePhp
    def self.build(site_directory)
      template = File.expand_path("template.php", site_directory)
      bindings_directory = File.expand_path("bindings", site_directory)
      output_directory = site_directory
      Dir.foreach(bindings_directory) do |f|
        next unless f.end_with?(".php")
        binding = File.basename(f, ".php")
        html_output = File.expand_path(binding + ".html", output_directory)
        puts "Building: #{html_output}\n\tfrom #{template}\n\tand binding #{f}"
        if !system "php -f #{template} #{binding} > #{html_output}"
          puts "\nIn file: #{html_output}"
          File.open(html_output).readlines.each {|l| puts l}
        end
      end
    end
  end
end
