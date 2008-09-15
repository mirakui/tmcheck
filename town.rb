require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'gena/mail'


for i in 1..22
  str = open "http://townmarket.jp/CSP/CSP01/CSP0100420/#{i}/"
  doc = Hpricot str

  category = (doc / 'strong').first.inner_text
  category = category.split('の広告チラシ').first

  (doc / 'td a').each do |a|
    store = a.inner_text
    break if store=='スーパー'
    puts category+','+store if a['href']=~/CSP/ && store.length>0
  end
end


