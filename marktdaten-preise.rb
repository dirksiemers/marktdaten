require 'selenium-webdriver'
require 'nokogiri'
require 'csv'

# Datei mit den URLs
input_csv = "marktbericht_urls.csv"
output_csv = "marktbericht_values.csv"

# Erstellen eines Selenium-WebDriver für Safari
driver = Selenium::WebDriver.for :safari

# Funktion zum Extrahieren von Informationen von einer URL
def extract_info(driver, url, xpaths)
  driver.navigate.to(url)

  # WebDriverWait verwenden
  wait = Selenium::WebDriver::Wait.new(timeout: 10) # Warte bis zu 10 Sekunden
  wait.until { driver.find_element(:xpath, '//*[@id="contentcenter"]') } # Warte auf ein bestimmtes Element

  html = driver.page_source
  doc = Nokogiri::HTML(html)
  
  # Extrahierte Werte als Hash zurückgeben
  values = xpaths.map { |key, xpath| [key, doc.xpath(xpath).map(&:text).join(" ")] }.to_h
  return values
end

# CSV-Datei mit URLs einlesen
urls = CSV.read(input_csv, headers: true).map { |row| row['URL'] }

# Definieren der XPath-Ausdrücke für die gewünschten Informationen
xpaths = {
  "Marktbericht KW" => '//*[@id="contentcenter"]/table/tbody/tr[1]/td[1]/h1',
  "Haltungsform" => '/html/body/table/tbody/tr[3]/td[3]/div[2]/table/tbody/tr[2]/td[1]/div/p[3]/b/span[1]',
  "Label" => '/html/body/table/tbody/tr[3]/td[3]/div[2]/table/tbody/tr[2]/td[1]/div/p[3]/b/span[2]',
  "weiß XL" => '//*[@id="contentcenter"]/table/tbody/tr[2]/td[1]/div/table[2]/tbody/tr[2]/td[2]',
  "weiß L" => '//*[@id="contentcenter"]/table/tbody/tr[2]/td[1]/div/table[2]/tbody/tr[3]/td[2]',
  "weiß M" => '//*[@id="contentcenter"]/table/tbody/tr[2]/td[1]/div/table[2]/tbody/tr[4]/td[2]',
  "weiß S" => '//*[@id="contentcenter"]/table/tbody/tr[2]/td[1]/div/table[2]/tbody/tr[5]/td[2]'
}

# CSV-Datei zum Speichern der extrahierten Informationen öffnen oder erstellen
CSV.open(output_csv, "wb") do |csv|
  # Header der CSV-Datei
  csv << ["URL"] + xpaths.keys

  # Über die URLs iterieren und Informationen extrahieren
  urls.each do |url|
    puts "Extrahiere Daten von: #{url}"
    values = extract_info(driver, url, xpaths)
    csv << [url] + xpaths.keys.map { |key| values[key] }
  end
end

# Schließen des Browsers
driver.quit

puts "Extraktion abgeschlossen. Ergebnisse sind in '#{output_csv}' gespeichert."
