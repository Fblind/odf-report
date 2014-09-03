module ODFReport

  module Images

    IMAGE_DIR_NAME = "Pictures"

    def find_image_name_matches(content)

      puts @image_size
      puts @images
      @images.each_pair do |image_name, path|
        if node = content.xpath("//draw:frame[@draw:name='#{image_name}']/draw:image").first
          placeholder_path = node.attribute('href').value

          puts placeholder_path

          @image_names_replacements[path] = ::File.join(IMAGE_DIR_NAME, ::File.basename(placeholder_path))
        end
      end

      @image_size.each_pair do |image_name, size|
         if node = content.xpath("//draw:frame[@draw:name='#{image_name}']").first

          width = content.xpath("//draw:frame[@draw:name='#{image_name}']/@svg:width").first
          puts "Antes de cambiar el width #{width.content}"
          width.content = "#{size.x}cm"
          puts "despues de cambiar el width #{width.content}"
          height = content.xpath("//draw:frame[@draw:name='#{image_name}']/@svg:height").first
          puts "Antes de cambiar el height #{height.content}"
          height.content = "#{size.y}cm"
          puts "Antes de cambiar el width #{height.content}"



           #placeholder_width = node['svg:width']
           #node.attribute('svg:width').value
           #placeholder_height = node['svg:height']
           #node.attribute('svg:height').value
           #@image_size_replacements["#{size.x}cm"] = placeholder_width
           #@image_size_replacements["#{size.y}cm"] = placeholder_height
         end
      end

    end

    def replace_images(file)
      puts "ENTRO AL REPLACE"

      return if @images.empty?

      @image_names_replacements.each_pair do |path, template_image|

        file.output_stream.put_next_entry(template_image)
        file.output_stream.write ::File.read(path)

      end

      #@image_size_replacements.each_pair do |size, placeholder|
      #  puts size
      #  puts placeholder
      #  file.output_stream.put_next_entry(placeholder)
      #  file.output_stream.write size
      #end


    end # replace_images

    # newer versions of LibreOffice can't open files with duplicates image names
    def avoid_duplicate_image_names(content)

      nodes = content.xpath("//draw:frame[@draw:name]")

      nodes.each_with_index do |node, i|
        node.attribute('name').value = "pic_#{i}"
      end

    end

  end

end
