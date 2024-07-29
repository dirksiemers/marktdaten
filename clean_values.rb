require 'csv'

# Eingabedatei und Ausgabedatei
input_csv = "marktbericht_values.csv"
output_csv = "marktbericht_preise_kw.csv"

# Funktion zum Formatieren der Werte
def format_value(value)
  # Entferne alle Leerzeichen
  cleaned_value = value.to_s.gsub(/\s+/, '')
  # Suche nach der ersten Zahl mit optionalen Nachkommastellen
  match = cleaned_value.match(/(\d+(\,\d+)?)/) # Suche nach Zahlen mit optionalem Komma und Nachkommastellen
  match ? match[0] : ""
end

# Lesen der Eingabedatei und Erstellen der Ausgabedatei
CSV.open(output_csv, "wb") do |csv_out|
  # Die erste Zeile wird als Header verwendet
  header = nil
  CSV.foreach(input_csv, headers: true) do |row|
    if header.nil?
      # Schreibe den neuen Header in die Ausgabedatei
      header = ["Kalenderwoche", "Jahr", "weiß XL", "weiß L", "weiß M", "weiß S"]
      csv_out << header
    end

    # Extrahiere die Kalenderwoche und das Jahr aus der Spalte "Marktbericht KW"
    marktbericht_kw = row["Marktbericht KW"]
    
    # Entferne den Header 'Marktbericht KW'
    marktbericht_kw = marktbericht_kw.gsub(/^Marktbericht KW\s*/, '')
    
    week, year = marktbericht_kw.split('/').map(&:strip)

    # Formatieren der Werte
    wei_xl = format_value(row["weiß XL"])
    wei_l = format_value(row["weiß L"])
    wei_m = format_value(row["weiß M"])
    wei_s = format_value(row["weiß S"])

    # Schreiben der Daten in die neue CSV-Datei
    csv_out << [week, year, wei_xl, wei_l, wei_m, wei_s]
  end
end

puts "Datenaufbereitung abgeschlossen. Ergebnisse sind in '#{output_csv}' gespeichert."
