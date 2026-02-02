Category.find_or_create_by!(name: "School Events") { |c| c.sort_order = 1 }
Category.find_or_create_by!(name: "Charity Events") { |c| c.sort_order = 2 }
Category.find_or_create_by!(name: "Local Government Events") { |c| c.sort_order = 3 }
Category.find_or_create_by!(name: "Library Events") { |c| c.sort_order = 4 }
Category.find_or_create_by!(name: "Parks & Rec") { |c| c.sort_order = 5 }

%w[Free Family-friendly Indoors Outdoors Fundraiser Volunteer Meeting Sports].each do |t|
  Tag.find_or_create_by!(name: t)
end
