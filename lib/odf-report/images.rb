module ODFReport

  module Images

    IMAGE_DIR_NAME = "Pictures"

    def find_image_name_matches(content)

      @images.each_pair do |image_name, path|
        if node = content.xpath("//draw:frame[@draw:name='#{image_name}']/draw:image").first
          placeholder_path = node.attribute('href').value
          @image_names_replacements[path] = ::File.join(IMAGE_DIR_NAME, ::File.basename(placeholder_path))
        end
      end

    end

    def replace_images(file)

      return if @images.empty?

      @image_names_replacements.each_pair do |path, template_image|

        file.output_stream.put_next_entry(template_image)
        file.output_stream.write ::File.read(path)

      end

    end # replace_images

    # newer versions of LibreOffice can't open files with duplicates image names
    def avoid_duplicate_image_names(content)

      nodes = content.xpath("//draw:frame[@draw:name]")

      nodes.each_with_index do |node, i|
        node.attribute('name').value = "pic_#{i}"
      end

    end

    def find_and_replace_size(content)

      @image_size.each_pair do |image_name, size|
          
        content.xpath("//draw:frame[@draw:name='#{image_name}']").each{ |node|
            width = content.xpath("//draw:frame[@draw:name='#{image_name}']/@svg:width").first          
            width.content = "#{size.x}cm"

            height = content.xpath("//draw:frame[@draw:name='#{image_name}']/@svg:height").first
            height.content = "#{size.y}cm"    
          }

          #width = content.xpath("//draw:frame[@draw:name='#{image_name}']/@svg:width").first
          #puts "Antes de cambiar el width #{width.content}"
          #width.content = "#{size.x}cm"
          #puts "despues de cambiar el width #{width.content}"
          #height = content.xpath("//draw:frame[@draw:name='#{image_name}']/@svg:height").first
          #puts "Antes de cambiar el height #{height.content}"
          #height.content = "#{size.y}cm"
          #puts "Antes de cambiar el width #{height.content}"

      end

    end




  end

end
