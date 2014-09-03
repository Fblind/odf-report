module ODFReport
	class Size  
	  def initialize(width,height)  
	    @width, @height = width, height 
	  end  
	    
	  attr_reader :width, :height

	end   
end