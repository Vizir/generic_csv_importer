A csv importer gem.


## Usage

```ruby
model_name = "Person"
csv_file = CSV.read("/home/user/person.csv", {:col_sep => ",", :headers => true} )

g = GenericCsvImporter.new
g.import(csv_file, model_name)
```


## CSV example

Person belongs to Class

```
Person.name,Person.age,Class.number
John,9,10
Mary,8,15
```



## Contributing

1. Fork it ( https://github.com/Vizir/generic_csv_importer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
