=begin
MastodonCthulhu.setup do |status|	
  fortune = MastodonCthulhu::Random.new('[ 　\n]?#(クトゥルフ神話)[ 　\n]?', %w(いあ!いあ!くとぅるぅ! いあ!いあ!はすたぁ! いあ!いあ!つとぅぁぐぁ! ふんぐるいむぐるうなふ! うがふなぐる! ふたぐん! ふんぐるい！むぐるうなふ！くとぅぐあ！ふぉまるはうと！んがあ・ぐあ！なふるたぐん！いあ！くとぅぐあ！ いあ！いあ！はすたあ！はすたあ!くふあやく!ぶるぐとむ!ぶぐとらぐるん!ぶるぐとむ!あい！あい！はすたあ！))
  status = fortune.convert(status) if fortune.match(status)	
  status

  fortune = MastodonCthulhu::Random.new('[ 　\n]?#(スーモ)[ 　\n]?', %w(あ❗️スーモ❗️🌚ダン💥ダン💥ダン💥シャーン🎶スモ🌝スモ🌚スモ🌝スモ🌚スモ🌝スモ🌚ス〜〜〜モ⤴スモ🌚スモ🌝スモ🌚スモ🌝スモ🌚スモ🌝ス～～～モ⤵🌞))
  status = fortune.convert(status) if fortune.match(status)	
  status

  fortune = MastodonCthulhu::Random.new('[ 　\n]?#(水曜どうでしょう)[ 　\n]?', %w(ここをキャンプ地とする 腹を割って話そう ギアいじったっけ、ロー入っちゃって、もうウィリーさ おい、パイ食わねぇか?))
  status = fortune.convert(status) if fortune.match(status)	
  status

  fortune = MastodonCthulhu::Random.new('[ 　\n]?#(社会性フィルター)[ 　\n]?', %w(こゃーん！))
  status = status.replace("こゃーん！ :neko_oinari: \n #社会性フィルター") if fortune.match(status)	
  status
  
  fortune = MastodonCthulhu::Random.new('[ 　\n]?#(cpp)[ 　\n]?', %w(こゃーん！))
  if fortune.match(status) then
    status.gsub!(/#cpp/, '')
    s = status.match /--std=c++\S+/
    status.gsub!(/--std=c++\S+/, "")

    File.open("./config/initializers/cplusplus.cpp", "w+") do |file|
      file.write status
    end
    
    if system("g++ ./config/initializers/cplusplus.cpp #{s}") then 
      s = Open3.capture3("./a.out")
      
      if s[0].length == 0 then
        status = status.replace(" #{s[1]} \n #cpp")
      elsif s[0].length <= 500 then
        status = status.replace("#{s[0]} \n #cpp")
      else
        status = status.replace("文字数がオーバーしています \n #cpp")
      end
    else
      status = status.replace("コンパイルできませんでした！ \n #cpp")
    end
        
        system("rm ./config/initializers/cplusplus.cpp")
        system("rm ./a.out")
  end
      
  fortune = MastodonCthulhu::Random.new('[ 　\n]?#(ruby)[ 　\n]?', %w(こゃーん！))
  if fortune.match(status) then
    status.gsub!(/#ruby/, '')
    File.open("./config/initializers/ruby.rb", "w+") do |file|
      file.write status
    end
    
    s = Open3.capture3("ruby ./config/initializers/ruby.rb")
    puts s
    if s[0].length == 0 then
      status = status.replace(" #{s[1]} \n #ruby")
    elsif s[0].length <= 500 then
      status = status.replace("#{s[0]} \n #ruby")
    else
      status = status.replace("文字数がオーバーしています \n #ruby")
    end
      
      system("rm ./config/initializers/ruby.rb")
  end
  
  fortune = MastodonCthulhu::Random.new('[ 　\n]?#(javascript)[ 　\n]?', %w(こゃーん！))
  if fortune.match(status) then
    status.gsub!(/#javascript/, '')
    File.open("./config/initializers/javascript.js", "w+") do |file|
      file.write status
    end
    
    s = Open3.capture3("node ./config/initializers/javascript.js")
    puts s
    if s[0].length == 0 then
      status = status.replace(" #{s[1]} \n #javascript")
    elsif s[0].length <= 500 then
      status = status.replace("#{s[0]} \n #javascript")
    else
      status = status.replace("文字数がオーバーしています \n #javascript")
    end
      
      system("rm ./config/initializers/javascript.js")
  end
      
  fortune = MastodonCthulhu::Random.new('[ 　\n]?#(python)[ 　\n]?', %w(こゃーん！))
  if fortune.match(status) then
    status.gsub!(/#python/, '')
    File.open("./config/initializers/python.py", "w+") do |file|
      file.write status
    end
    
    s = Open3.capture3("python ./config/initializers/python.py")
    puts s
    if s[0].length == 0 then
      status = status.replace(" #{s[1]} \n #python")
    elsif s[0].length <= 500 then
      status = status.replace("#{s[0]} \n #python")
    else
      status = status.replace("文字数がオーバーしています \n #python")
    end
      
      system("rm ./config/initializers/python.py")
  end
      
  cthulhu = Cthulhu.find(rand(Cthulhu.count) + 1).story
  fortune = MastodonCthulhu::Random.new('[ 　\n]?#(Cthulhu)[ 　\n]?', %W(#{cthulhu}))
  status = fortune.convert(status) if fortune.match(status)	
  status
end
=end