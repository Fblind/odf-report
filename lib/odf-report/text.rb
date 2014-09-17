module ODFReport

  class Text < Field

    attr_accessor :parser

    def replace!(doc, data_item = nil)

      return unless node = find_text_node(doc)

      text_value = get_value(data_item)

      @parser = Parser::Default.new(text_value, node)

      @parser.paragraphs.each do |p|
        node.before(p)
      end

      node.remove

    end

    def self.delete_extra_text(doc, texts_to_delete)
      puts "Los texts del xml= #{texts_to_delete}"
      texts_to_delete.each{ |text|
        puts "#{doc.xpath(".//text:p[text()='[#{text.to_s.upcase}]']")}"
        puts "#{doc.xpath(".//text:p/text:span[text()='#{text.to_s.upcase}]']")}"
        doc.xpath(".//text:p[text()='[#{text.to_s.upcase}]']").remove
      }
      
    end

    private

    def find_text_node(doc)
      texts = doc.xpath(".//text:p[text()='#{to_placeholder}']")
      if texts.empty?
        texts = doc.xpath(".//text:p/text:span[text()='#{to_placeholder}']")
        if texts.empty?
          texts = nil
        else
          texts = texts.first.parent
        end
      else
        texts = texts.first
      end

      texts
    end

  end

end
