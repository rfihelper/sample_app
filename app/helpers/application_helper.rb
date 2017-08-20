module ApplicationHelper

  def full_title(page_title = '')
    #Returns the full title on a per-page basis
    base_title = "Ruby on Rails Tutorial Sample App"

    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end   # full_title
  
end
