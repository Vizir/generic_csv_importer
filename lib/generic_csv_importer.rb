class GenericCsvImporter
  def import(csv_file, model_name)
    if is_composite_csv?(csv_file, model_name)
      composite_import(csv_file, model_name)
    else
      simple_import(csv_file, model_name)
    end
  end

  def is_composite_csv?(csv_file, model_name)
    csv_file.headers.each_with_index do |header_column, index|
      return true if header_column[/^#{model_name}\.\w*\([\w\s=>]*\)/]
    end
    false
  end

  def simple_import(csv_file, model_name)
    header = csv_file.headers
    csv_file.each do |csv_line|
       puts csv_line
       params = build_simple_params(header, csv_line, model_name)
       clazz = model_name.constantize
       obj = clazz.new(params)
       solve_associations(obj, header, csv_line)
       obj.save
    end
  end

  def composite_import(csv_file, model_name)
    ActiveRecord::Base.transaction do
      composite_column_indexes = generate_composite_column_indexes(csv_file.headers, model_name)
      header = csv_file.headers
      csv_file.each do |csv_line|
        puts csv_line
        composite_column_indexes.each do |composite_column_index|
          params = build_composite_params(header, csv_line, model_name, composite_column_index)
          clazz = model_name.constantize
          obj = clazz.new(params)
          solve_associations(obj, header, csv_line)
          obj.save
        end
      end
    end  
  end

  def generate_composite_column_indexes(header, model_name)
    composite_column_indexes = []
    header.each_with_index do |header_column, index|
      if header_column[/^#{model_name}\.\w*\([\w\s=>]*\)/]
        composite_column_indexes << index
      end
    end
    composite_column_indexes 
  end

##### BUILD PARAMS ##### 
  def build_simple_params(header, csv_line, model_name)
    params = {}
    header.each_with_index do |header_column, index|
      if header_column[/^#{model_name}\.[\w]*$/]
        include_simple_param(params, header_column, csv_line[index])
      end  
    end
    params
  end

  def build_composite_params(header, csv_line, model_name, composite_column_index)
    params = {}
    params = build_simple_params(header, csv_line, model_name)
    include_composite_param(params, header[composite_column_index], csv_line[composite_column_index])
    params
  end

  def include_simple_param(params, header_column, value)
    param_name = header_column.split('.')[1]
    params[param_name] = value
  end

  def include_composite_param(params, header_column, value)
    model = header_column[/[\w]*/]

    first_param_name = header_column[/[\w]*\.[\w]*/].split('.')[1]
    first_value = value

    second_part = header_column[/\([\w\s=>]*\)/].gsub(' ', '').slice(1..-2).split('=>')
    second_param_name = second_part[0]
    second_value = second_part[1]

    include_simple_param(params, "#{model}.#{first_param_name}", first_value)
    include_simple_param(params, "#{model}.#{second_param_name}", second_value)
  end

##### SOLVE ASSOCITATIONS ##### 
  def solve_associations(obj, header, csv_line)
    associations = get_association(obj)
    associations.each do |association|
      clazz = association.constantize
      params = build_simple_params(header, csv_line, association)
      result = clazz.where(params)
      if result.size == 0
        c = clazz.new(params)
        solve_associations(c, header, csv_line)
        c.save
        obj.update_attribute("#{clazz.model_name.singular}_id", c.id)
      elsif result.size == 1
        obj.update_attribute("#{clazz.model_name.singular}_id", result[0].id)
      elsif result.size > 1
        puts "ambiguous association"
        raise
      end
    end
  end

  def get_association(obj)
    associations = []
    obj.class.reflect_on_all_associations(:belongs_to).each_with_index do |association, index|
      associations[index] =  association.class_name
    end
    associations
  end
end