header + csv_line poderia ser uma row

poderia importar xls tambem


**Usage**

model_name = "Person"
csv_file = CSV.read("/project/script/csv/general_index/Person.csv", {:col_sep => ",", :headers => true} )

g = GenericCsvImporter.new
g.import(csv_file, model_name)



**CSV example**

Person belongs to Class

Person.name,Person.age,Class.number
John,9,10
Mary,8,15




**Contributing**

Fork it ( https://github.com/Vizir/generic_csv_importer/fork )
Create your feature branch (git checkout -b my-new-feature)
Commit your changes (git commit -am 'Add some feature')
Push to the branch (git push origin my-new-feature)
Create a new Pull Request