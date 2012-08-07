require 'RMagick'
require 'httparty'

class Nagios
  include HTTParty
  
  #debug_output $stderr #debugger to check httparty output
    
  CONFIG = YAML::load( File.open( Rails.root.join('config/config.yml') ) )['config']
  basic_auth CONFIG["nag_un"], CONFIG["nag_pw"]
  
  
  headers "Content-Type" => "application/json"
end

namespace :dashboard do
  desc "task to create image of nagios"
  task :update_nagios do
    
    x = 20
    y = 20

    #set-up nagios feed
    responser = Nagios.get('http://ec2-50-17-42-47.compute-1.amazonaws.com/nagios/cgi-bin/status-json.cgi')
    ar = []

    responser["services"].each do |service|
      ar << service["service_status"]
    end

    size = 30
    startpad = 10
    
    square = [0,size+23,size,0+23]
    square.collect!{|i| i + startpad}
    
    #these 2 are the start location of the square
    xoff=5
    yoff=5
    
    columns = 8 
    
    #this is the square inc padding
    offset = size + xoff

    canvas = Magick::Image.new(((size + xoff) * (columns+1)) + xoff + (startpad*2), 420) {self.background_color = '#424953'}
    gc = Magick::Draw.new
    gc.fill('#AE432E')

    ar.each do |a|  

        gc.rectangle(square[0]+xoff,square[1]+yoff,square[2]+xoff,square[3]+yoff) #upper left lower right
        
        if a == "WARNING" 
          gc.fill('#B5712E')
        elsif a == "CRITICAL"
          gc.fill('#AE432E')  
        else
          gc.fill('#7FA416')
        end

        gc.draw(canvas)

        if xoff-5 == columns*offset
          xoff = 5
          yoff+=offset
        else      
          xoff+=offset
        end

    end

    canvas.format = 'png'
    canvas.write(Rails.root.join('public', 'nagios.png'))
    #canvas.to_blob


      
  end
end