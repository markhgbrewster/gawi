class IndexController < ApplicationController
  include GetCategories

  def index
    get_categories
  end

  def show
    get_categories
    @crime = @crime_categories.select{ |c| c[1] == params[:crime] }.first[0]
    @admin_ward = AdminWard.find_by(url: params[:admin_ward])
    
    # NEIGHBOURHOOD
    @neighbourhood_response = HTTParty.get("https://data.police.uk/api/greater-manchester/#{@admin_ward.neighbourhood_code}")
    @neighbourhood = JSON.parse(@neighbourhood_response.body)
    @neighbourhood_mash = Hashie::Mash.new @neighbourhood

    @lat = @neighbourhood_mash.centre.latitude rescue "53.472225"
    @long = @neighbourhood_mash.centre.longitude rescue "-2.2936317"
    
    # WIKI INTRO
    # @wiki_response = HTTParty.get("http://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro=&explaintext=&titles=#{@neighbourhood['name']}")
    # @wiki_info = JSON.parse(@wiki_response.body)
    
    @wiki_response = nil
    @wiki_info = nil
    
    @crew = Crew.all.sample(4)
    @local_bacon = JSON.parse(HTTParty.get("https://data.police.uk/api/greater-manchester/#{@admin_ward.neighbourhood_code}/people").body)
    @comments = Comment.where(crime: params[:crime], admin_ward_id: @admin_ward.id)
  end
  
  def create
    if params[:comment].present? &&  params[:comment][:blurb].present?
      admin_ward_id = AdminWard.find_by(url: params[:admin_ward]).id
      Comment.create(
       blurb: params[:comment][:blurb],
       hood: params[:neighbourhood],
       admin_ward_id: admin_ward_id,
       crime: params[:crime]
      )
      flash[:notice] = "Comment added"
    else
      flash[:notice] = "You are a dickhead.You did not put any text in the Comment field. You should think twice before reproducing!"
    end
    redirect_to info_path(admin_ward: params[:admin_ward], crime: params[:crime], neighbourhood: params[:neighbourhood], anchor: "gazeeb0")
  end

end