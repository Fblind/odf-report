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
      #TODO: ask for nil

      @image_size.each_pair do |image_name, size|
          
            content.xpath("//draw:frame[@draw:name='#{image_name}']/@svg:width").each{ |width|
              if !(size.width == 0)
                width.content = "#{size.width}cm"
              end
            }
            
            content.xpath("//draw:frame[@draw:name='#{image_name}']/@svg:height").each{ |height|
              if !(size.height == 0)
                height.content = "#{size.height}cm"  
              end
            }

      end
    end
    
    def find_and_replace_coord(content)
      #TODO: ask for nil

      @image_coords.each_pair do |image_name, coord|

            content.xpath("//draw:frame[@draw:name='#{image_name}']/@svg:x").each{ |x|
              if !(coord.x == 0)
                x.content = "#{coord.x}cm"
              end
            }
            
            content.xpath("//draw:frame[@draw:name='#{image_name}']/@svg:y").each{ |y|
              if !(coord.y == 0)
                y.content = "#{coord.y}cm"
              end
            }

      end
    end

    def delete_extra_images(content)
      #TODO: ask for nil
      #TODO: how I can delete xml openoffice

      @images_to_delete.each{ |image_name|

        content.xpath("//draw:frame[@draw:name='#{image_name}']/draw:image/@xlink:href").each{ |image|
          puts image
          puts image.content
          image.content = ' '
        }

      }
      
    end



  end

end
