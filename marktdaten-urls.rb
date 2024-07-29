require 'net/http'
require 'nokogiri'
require 'uri'
require 'csv'

# Basis-URL mit Platzhaltern für den nextstep-Parameter
base_url = "https://www.deu-eier.de/liste-wichtig.html?nextstep=%{step}"

# Set zur Speicherung der gefundenen URLs (verhindert Duplikate)
all_urls = Set.new

# Funktion zum Extrahieren von Marktbericht-URLs von einer Seite
def extract_market_report_urls(url)
  uri = URI(url)
  response = Net::HTTP.get(uri)
  if response
    doc = Nokogiri::HTML(response)
    # XPath-Abfrage, um alle Links zu finden, die mit /service/marktbericht/ beginnen
    links = doc.xpath('//a[contains(@href, "/service/marktbericht/")]/@href')
    # Vollständige URLs erstellen
    full_links = links.map { |link| "https://www.deu-eier.de" + link.value }
    return full_links
  else
    puts "Fehler beim Abrufen der Webseite: #{response.code}"
    return []
  end
end

# Iterieren über die Seiten mit dem nextstep-Parameter in 10er-Schritten
(0..280).step(10) do |step|
  url = base_url % { step: step }
  puts "Extrahiere Daten von: #{url}"
  market_report_urls = extract_market_report_urls(url)
  all_urls.merge(market_report_urls)
end

# Schreiben der URLs in eine CSV-Datei
CSV.open("marktbericht_urls.csv", "wb") do |csv|
  csv << ["URL"]  # Header der CSV-Datei
  all_urls.each do |market_url|
    csv << [market_url]
  end
end

puts "Gesamtanzahl der gefundenen URLs: #{all_urls.length}"
