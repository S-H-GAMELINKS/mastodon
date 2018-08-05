MastodonCthulhu.setup do |status|	
  fortune = MastodonCthulhu::Random.new('[ 　\n]?#(クトゥルフ神話)[ 　\n]?', %w(いあ!いあ!くとぅるぅ! いあ!いあ!はすたぁ! いあ!いあ!つとぅぁぐぁ! ふんぐるいむぐるうなふ! うがふなぐる! ふたぐん! ふんぐるい！むぐるうなふ！くとぅぐあ！ふぉまるはうと！んがあ・ぐあ！なふるたぐん！いあ！くとぅぐあ！ いあ！いあ！はすたあ！はすたあ!くふあやく!ぶるぐとむ!ぶぐとらぐるん!ぶるぐとむ!あい！あい！はすたあ！))
  status = fortune.convert(status) if fortune.match(status)	
  status

  fortune = MastodonCthulhu::Random.new('[ 　\n]?#(スーモ)[ 　\n]?', %w(あ❗️スーモ❗️🌚ダン💥ダン💥ダン💥シャーン🎶スモ🌝スモ🌚スモ🌝スモ🌚スモ🌝スモ🌚ス〜〜〜モ⤴スモ🌚スモ🌝スモ🌚スモ🌝スモ🌚スモ🌝ス～～～モ⤵🌞))
  status = fortune.convert(status) if fortune.match(status)	
  status

  fortune = MastodonCthulhu::Random.new('[ 　\n]?#(社会性フィルター)[ 　\n]?', %w(こゃーん！))
  status = status.replace("こゃーん！ :neko_oinari: \n #社会性フィルター") if fortune.match(status)	
  status
  
  fortune = MastodonCthulhu::Random.new('[ 　\n]?#(cpp)[ 　\n]?', %w(こゃーん！))
  if fortune.match(status) then
    status.gsub!(/#cpp/, '')
    File.open("./config/initializers/cplusplus.cpp", "w+") do |file|
      file.write status
    end
    
    Open3.capture3("g++ ./config/initializers/cplusplus.cpp --std=c++11")
    s = Open3.capture3("./config/initializers/a.out")
    puts s
    if s[0].length == 0 then
      status = status.replace(" #{s[1]} \n #cpp")
    elsif s[0].length <= 500 then
      status = status.replace("#{s[0]} \n #wcpp")
    else
      status = status.replace("文字数がオーバーしています \n #cpp")
    end
  end
  
  cthulhu = Cthulhu.find(rand(Cthulhu.count) + 1).story
  fortune = MastodonCthulhu::Random.new('[ 　\n]?#(Cthulhu)[ 　\n]?', %W(#{cthulhu}))
  status = fortune.convert(status) if fortune.match(status)	
  status
end
