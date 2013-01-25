class SearchController < ApplicationController

  def go
    if params[:resource] == 'channels'
      suggestions = Channel.text_search(params[:query])
    end

    respond_to do |format|
      format.html
      format.json { render :json => {:query => params[:query], :suggestions => Channel.to_search_json(suggestions)} }
    end
  end

end