require 'csv'
require 'erb'
require 'date'

# Funktion zur Berechnung des Datums des ersten Tages einer Kalenderwoche
def date_of_week(year, week_number)
    # Berechne den ersten Tag der Woche (Montag)
    d = Date.commercial(year.to_i, week_number.to_i, 1) # 1 für Montag
    d
  end

# Eingabedatei
input_csv = "marktbericht_preise_kw.csv"

# Arrays zum Speichern der Daten
dates = []
values_wei_m = []
values_wei_s = []

# Lesen der CSV-Datei
CSV.foreach(input_csv, headers: true) do |row|
  # Berechne das Datum des ersten Tages der Kalenderwoche
  date = date_of_week(row["Jahr"], row["Kalenderwoche"])
  dates << date.strftime('%Y-%m-%d') # Formatierung für die Darstellung im Diagramm

  # Entferne alle Leerzeichen und konvertiere in Float, falls es leer ist, wird 0 gesetzt
  values_wei_m << (row["weiß M"].to_s.strip.empty? ? 0.0 : row["weiß M"].gsub(',', '.').to_f)
  values_wei_s << (row["weiß S"].to_s.strip.empty? ? 0.0 : row["weiß S"].gsub(',', '.').to_f)
end

# Werte umkehren
dates.reverse!
values_wei_m.reverse!
values_wei_s.reverse!

# Erstelle HTML-Datei mit eingebettetem Chartkick-Diagramm
html_content = <<-HTML
<!DOCTYPE html>
<html>
<head>
  <title>Weiße Ware Liniendiagramm</title>
  <script src="https://www.gstatic.com/charts/loader.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/chartkick@3.0.0/dist/chartkick.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
  <h1>Preise für weiße Ware über Kalenderwochen</h1>
  <div id="chart-1" style="height: 600px;"></div>
  <script>
    data = [
        { name: "Weiß M", data: { #{dates.each_with_index.map { |date, i| "'#{date.to_s}': #{values_wei_m[i]}" }.join(", ")}}},
        { name: "Weiß S", data: { #{dates.each_with_index.map { |date, i| "'#{date.to_s}': #{values_wei_s[i]}" }.join(", ")}}}
    ]
    new Chartkick.LineChart("chart-1", data, {discrete: true, download: true, pointSize: 0} );
  </script>
</body>
</html>
HTML

# Schreibe den Inhalt in eine HTML-Datei
File.open('wei_m_liniendiagramm.html', 'w') do |file|
  file.write(html_content)
end

puts "Liniendiagramm erstellt und als 'wei_m_liniendiagramm.html' gespeichert."
