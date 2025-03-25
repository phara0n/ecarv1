# This file contains seed data for vehicle brands and models popular in Tunisia
# Usage: Load this file in your seeds.rb with `load 'db/seeds/vehicle_brands.rb'`

# Create vehicle brands and models
puts "Creating vehicle brands and models for Tunisian market..."

# European Brands

# Volkswagen
volkswagen = Brand.find_or_create_by!(name: "Volkswagen")
[
  { name: "Golf", years: (2005..2023).to_a },
  { name: "Polo", years: (2005..2023).to_a },
  { name: "Passat", years: (2005..2023).to_a },
  { name: "Tiguan", years: (2008..2023).to_a },
  { name: "Caddy", years: (2005..2023).to_a },
  { name: "Touareg", years: (2005..2023).to_a }
].each do |model|
  vehicle_model = volkswagen.models.find_or_create_by!(name: model[:name])
  model[:years].each do |year|
    vehicle_model.year_models.find_or_create_by!(year: year)
  end
end

# Renault
renault = Brand.find_or_create_by!(name: "Renault")
[
  { name: "Clio", years: (2005..2023).to_a },
  { name: "Symbol", years: (2008..2023).to_a },
  { name: "Mégane", years: (2005..2023).to_a },
  { name: "Duster", years: (2010..2023).to_a },
  { name: "Fluence", years: (2010..2020).to_a },
  { name: "Kadjar", years: (2015..2023).to_a },
  { name: "Captur", years: (2013..2023).to_a }
].each do |model|
  vehicle_model = renault.models.find_or_create_by!(name: model[:name])
  model[:years].each do |year|
    vehicle_model.year_models.find_or_create_by!(year: year)
  end
end

# Peugeot
peugeot = Brand.find_or_create_by!(name: "Peugeot")
[
  { name: "208", years: (2012..2023).to_a },
  { name: "301", years: (2012..2023).to_a },
  { name: "3008", years: (2009..2023).to_a },
  { name: "508", years: (2011..2023).to_a },
  { name: "2008", years: (2013..2023).to_a },
  { name: "5008", years: (2009..2023).to_a },
  { name: "Partner", years: (2005..2023).to_a }
].each do |model|
  vehicle_model = peugeot.models.find_or_create_by!(name: model[:name])
  model[:years].each do |year|
    vehicle_model.year_models.find_or_create_by!(year: year)
  end
end

# Citroën
citroen = Brand.find_or_create_by!(name: "Citroën")
[
  { name: "C3", years: (2005..2023).to_a },
  { name: "C4", years: (2005..2023).to_a },
  { name: "C-Elysée", years: (2012..2023).to_a },
  { name: "Berlingo", years: (2005..2023).to_a },
  { name: "C3 Aircross", years: (2017..2023).to_a },
  { name: "C5 Aircross", years: (2018..2023).to_a }
].each do |model|
  vehicle_model = citroen.models.find_or_create_by!(name: model[:name])
  model[:years].each do |year|
    vehicle_model.year_models.find_or_create_by!(year: year)
  end
end

# SEAT
seat = Brand.find_or_create_by!(name: "SEAT")
[
  { name: "Ibiza", years: (2005..2023).to_a },
  { name: "Leon", years: (2005..2023).to_a },
  { name: "Ateca", years: (2016..2023).to_a },
  { name: "Arona", years: (2017..2023).to_a }
].each do |model|
  vehicle_model = seat.models.find_or_create_by!(name: model[:name])
  model[:years].each do |year|
    vehicle_model.year_models.find_or_create_by!(year: year)
  end
end

# Fiat
fiat = Brand.find_or_create_by!(name: "Fiat")
[
  { name: "Tipo", years: (2015..2023).to_a },
  { name: "500", years: (2007..2023).to_a },
  { name: "Panda", years: (2005..2023).to_a },
  { name: "Doblo", years: (2005..2023).to_a }
].each do |model|
  vehicle_model = fiat.models.find_or_create_by!(name: model[:name])
  model[:years].each do |year|
    vehicle_model.year_models.find_or_create_by!(year: year)
  end
end

# Premium European Brands

# BMW
bmw = Brand.find_or_create_by!(name: "BMW")
[
  { name: "3 Series", years: (2005..2023).to_a },
  { name: "5 Series", years: (2005..2023).to_a },
  { name: "X3", years: (2005..2023).to_a },
  { name: "X5", years: (2005..2023).to_a },
  { name: "X1", years: (2009..2023).to_a }
].each do |model|
  vehicle_model = bmw.models.find_or_create_by!(name: model[:name])
  model[:years].each do |year|
    vehicle_model.year_models.find_or_create_by!(year: year)
  end
end

# Mercedes-Benz
mercedes = Brand.find_or_create_by!(name: "Mercedes-Benz")
[
  { name: "C-Class", years: (2005..2023).to_a },
  { name: "E-Class", years: (2005..2023).to_a },
  { name: "GLC", years: (2015..2023).to_a },
  { name: "GLE", years: (2015..2023).to_a },
  { name: "A-Class", years: (2005..2023).to_a }
].each do |model|
  vehicle_model = mercedes.models.find_or_create_by!(name: model[:name])
  model[:years].each do |year|
    vehicle_model.year_models.find_or_create_by!(year: year)
  end
end

# Audi
audi = Brand.find_or_create_by!(name: "Audi")
[
  { name: "A3", years: (2005..2023).to_a },
  { name: "A4", years: (2005..2023).to_a },
  { name: "A6", years: (2005..2023).to_a },
  { name: "Q3", years: (2011..2023).to_a },
  { name: "Q5", years: (2008..2023).to_a }
].each do |model|
  vehicle_model = audi.models.find_or_create_by!(name: model[:name])
  model[:years].each do |year|
    vehicle_model.year_models.find_or_create_by!(year: year)
  end
end

# Asian Brands

# Hyundai
hyundai = Brand.find_or_create_by!(name: "Hyundai")
[
  { name: "i10", years: (2008..2023).to_a },
  { name: "i20", years: (2008..2023).to_a },
  { name: "Accent", years: (2005..2023).to_a },
  { name: "Tucson", years: (2005..2023).to_a },
  { name: "Santa Fe", years: (2005..2023).to_a },
  { name: "Elantra", years: (2005..2023).to_a }
].each do |model|
  vehicle_model = hyundai.models.find_or_create_by!(name: model[:name])
  model[:years].each do |year|
    vehicle_model.year_models.find_or_create_by!(year: year)
  end
end

# Kia
kia = Brand.find_or_create_by!(name: "Kia")
[
  { name: "Picanto", years: (2005..2023).to_a },
  { name: "Rio", years: (2005..2023).to_a },
  { name: "Sportage", years: (2005..2023).to_a },
  { name: "Cerato", years: (2005..2023).to_a },
  { name: "Sorento", years: (2005..2023).to_a }
].each do |model|
  vehicle_model = kia.models.find_or_create_by!(name: model[:name])
  model[:years].each do |year|
    vehicle_model.year_models.find_or_create_by!(year: year)
  end
end

# Toyota
toyota = Brand.find_or_create_by!(name: "Toyota")
[
  { name: "Yaris", years: (2005..2023).to_a },
  { name: "Corolla", years: (2005..2023).to_a },
  { name: "RAV4", years: (2005..2023).to_a },
  { name: "Land Cruiser", years: (2005..2023).to_a },
  { name: "Hilux", years: (2005..2023).to_a },
  { name: "Fortuner", years: (2005..2023).to_a }
].each do |model|
  vehicle_model = toyota.models.find_or_create_by!(name: model[:name])
  model[:years].each do |year|
    vehicle_model.year_models.find_or_create_by!(year: year)
  end
end

# Nissan
nissan = Brand.find_or_create_by!(name: "Nissan")
[
  { name: "Sunny", years: (2005..2023).to_a },
  { name: "Qashqai", years: (2007..2023).to_a },
  { name: "X-Trail", years: (2005..2023).to_a },
  { name: "Patrol", years: (2005..2023).to_a },
  { name: "Navara", years: (2005..2023).to_a }
].each do |model|
  vehicle_model = nissan.models.find_or_create_by!(name: model[:name])
  model[:years].each do |year|
    vehicle_model.year_models.find_or_create_by!(year: year)
  end
end

# Mitsubishi
mitsubishi = Brand.find_or_create_by!(name: "Mitsubishi")
[
  { name: "Lancer", years: (2005..2017).to_a },
  { name: "Pajero", years: (2005..2023).to_a },
  { name: "L200", years: (2005..2023).to_a },
  { name: "ASX", years: (2010..2023).to_a },
  { name: "Outlander", years: (2005..2023).to_a }
].each do |model|
  vehicle_model = mitsubishi.models.find_or_create_by!(name: model[:name])
  model[:years].each do |year|
    vehicle_model.year_models.find_or_create_by!(year: year)
  end
end

# Honda
honda = Brand.find_or_create_by!(name: "Honda")
[
  { name: "Civic", years: (2005..2023).to_a },
  { name: "Accord", years: (2005..2023).to_a },
  { name: "CR-V", years: (2005..2023).to_a },
  { name: "HR-V", years: (2015..2023).to_a }
].each do |model|
  vehicle_model = honda.models.find_or_create_by!(name: model[:name])
  model[:years].each do |year|
    vehicle_model.year_models.find_or_create_by!(year: year)
  end
end

# American Brands

# Chevrolet
chevrolet = Brand.find_or_create_by!(name: "Chevrolet")
[
  { name: "Aveo", years: (2005..2023).to_a },
  { name: "Cruze", years: (2009..2023).to_a },
  { name: "Spark", years: (2005..2023).to_a },
  { name: "Captiva", years: (2006..2023).to_a }
].each do |model|
  vehicle_model = chevrolet.models.find_or_create_by!(name: model[:name])
  model[:years].each do |year|
    vehicle_model.year_models.find_or_create_by!(year: year)
  end
end

# Ford
ford = Brand.find_or_create_by!(name: "Ford")
[
  { name: "Fiesta", years: (2005..2023).to_a },
  { name: "Focus", years: (2005..2023).to_a },
  { name: "Ranger", years: (2005..2023).to_a },
  { name: "Ecosport", years: (2013..2023).to_a },
  { name: "Kuga", years: (2008..2023).to_a }
].each do |model|
  vehicle_model = ford.models.find_or_create_by!(name: model[:name])
  model[:years].each do |year|
    vehicle_model.year_models.find_or_create_by!(year: year)
  end
end

# Commercial Vehicles (common for taxis and commercial use in Tunisia)

# Create a special category for Taxi vehicles
taxi_models = [
  { brand: "Hyundai", model: "Accent", years: (2005..2023).to_a, taxi: true },
  { brand: "Kia", model: "Rio", years: (2005..2023).to_a, taxi: true },
  { brand: "Renault", model: "Symbol", years: (2008..2023).to_a, taxi: true },
  { brand: "Peugeot", model: "301", years: (2012..2023).to_a, taxi: true },
  { brand: "Citroën", model: "C-Elysée", years: (2012..2023).to_a, taxi: true }
]

taxi_models.each do |vehicle|
  brand = Brand.find_by(name: vehicle[:brand])
  next unless brand

  model = brand.models.find_by(name: vehicle[:model])
  next unless model

  # Flag this model as commonly used for taxis
  model.update(common_taxi: true) if model.respond_to?(:common_taxi)
  
  # Create special taxi configurations if needed
  vehicle[:years].each do |year|
    year_model = model.year_models.find_by(year: year)
    next unless year_model
    
    # Add taxi-specific attributes if applicable
    year_model.update(taxi_model_available: true) if year_model.respond_to?(:taxi_model_available)
  end
end

puts "Finished creating #{Brand.count} brands and #{Model.count if defined?(Model)} models for the Tunisian market." 