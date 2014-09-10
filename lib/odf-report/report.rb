module ODFReport

class Report
  include Images

  def initialize(template_name, &block)

    @file = ODFReport::File.new(template_name)

    @texts = []
    @fields = []
    @tables = []
    @images = {}
    @image_names_replacements = {}
    @sections = []
    @image_size = {}
    @images_to_delete
    @texts_to_delete

    yield(self)

  end

  def add_field(field_tag, value='')
    opts = {:name => field_tag, :value => value}
    field = Field.new(opts)
    @fields << field
  end

  def add_text(field_tag, value='')
    opts = {:name => field_tag, :value => value}
    text = Text.new(opts)
    @texts << text
  end

  def add_table(table_name, collection, opts={})
    opts.merge!(:name => table_name, :collection => collection)
    tab = Table.new(opts)
    @tables << tab

    yield(tab)
  end

  def add_section(section_name, collection, opts={})
    opts.merge!(:name => section_name, :collection => collection)
    sec = Section.new(opts)
    @sections << sec

    yield(sec)
  end

  def add_image(name, path)
    @images[name] = path
  end
  
  def change_image_size(name, width, height)
    @size = Size.new(width, height)
    @image_size[name] = @size
  end

  def add_extra_images_to_delete(images_to_delete)
    @images_to_delete = images_to_delete
  end

  def add_extra_texts_to_delete(texts_to_delete)
    @texts_to_delete = texts_to_delete
  end


  def generate(dest = nil)

    @file.update_content do |file|

      file.update_files('content.xml', 'styles.xml') do |txt|

        parse_document(txt) do |doc|

          @sections.each { |s| s.replace!(doc) }
          @tables.each   { |t| t.replace!(doc) }

          @texts.each    { |t| t.replace!(doc) }
          @fields.each   { |f| f.replace!(doc) }

          if !@image_size.empty?
            find_and_replace_size(doc)
          end
          find_image_name_matches(doc)
          delete_extra_images(doc)
          Text.delete_extra_text(doc, @texts_to_delete)
          avoid_duplicate_image_names(doc)

        end

      end

      replace_images(file)

    end

    if dest
      ::File.open(dest, "wb") {|f| f.write(@file.data) }
    else
      @file.data
    end

  end

private

  def parse_document(txt)
    doc = Nokogiri::XML(txt)
    yield doc
    txt.replace(doc.to_xml(:save_with => Nokogiri::XML::Node::SaveOptions::AS_XML))
  end

end

end
