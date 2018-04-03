CSV.generate({col_sep: ';', row_sep: "\r\n"}) { |csv|
  csv << export_column_titles(@columns)
  render partial: 'show', formats: [:csv], locals: {route: @route, csv: csv}
}
