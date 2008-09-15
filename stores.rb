require 'rubygems'
require 'hpricot'
require 'open-uri'

class Stores
  attr_reader :stores
  attr_reader :date

  def initialize(file=nil)
    if file
      self.load file
    end
  end

# 店舗一覧を取得
  def get
    @stores = [];
    conf = Pit.get('tmcheck')
    
    for i in 1..22
      str = open(conf['url']+'/'+i.to_s)
      doc = Hpricot str

      category = (doc / 'strong').first.inner_text
      category = category.split('の広告チラシ').first

      (doc / 'td a').each do |a|
        store = a.inner_text
        break if store=='スーパー'
        @stores.push(category+','+store) if a['href']=~/CSP/ && store.length>0
      end
    end
    @date = Time.now
    @stores
  end

  def load(fname)
    fname ||= :latest
    files = Dir.glob('csv/*.csv')
    case fname
    when :latest
      raise "There's no CSV" if files.length < 1
      self.load(files.last)
    when :pre_latest
      raise "There's no two CSVs" if files.length < 2
      files.pop
      self.load(files.last)
    else
      raise "file name error: #{file}" unless fname
      @date = File.split(fname).last.my_unformat
      @stores = open(fname, 'r').readlines
    end
  end

  def save
    fname = "csv/#{@date.my_format}.csv";
    open(fname, 'w') do |f|
      f.puts @stores.join("\n")
    end
    fname
  end

  def diff(other)
    arr1 = @stores
    arr2 = other.stores
    buff1 = {}
    buff2 = {}
    added = []
    removed = []

    arr1.each do |line|
      line.chomp!
      buff1[line] = true
    end

    arr2.each do |line|
      line.chomp!
      if buff1[line]!=true
        removed.push line
      end
      buff2[line] = true
    end

    arr1.each do |line|
      line.chomp!
      if buff2[line]!=true
        added.push line
      end
    end

    {:added => added, :removed => removed }
  end

end


class Time
  def my_format
    strftime '%y%m%d%H%M%S'
  end

  def simple_format
    strftime '%Y.%m.%d (%a) %H:%M'
  end
end

class String
  def my_unformat
    a = scan /\d\d/
    Time::local *a
  end
end


