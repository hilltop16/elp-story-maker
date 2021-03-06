class StoriesController < ApplicationController

  def index
    @stories = policy_scope(Story).order('LOWER(title) ASC')
  end

  def show
    @story = Story.find(params[:id])
    authorize @story
    @pages = @story.pages.order('pages.id ASC')
    # ALL complete Link.joins('INNER JOIN pages ON links.dst_page_id=pages.id').where("story_id = ?", params[:id])
    # all links
    @links = Link.joins('INNER JOIN pages ON links.src_page_id=pages.id').where("story_id = ?", params[:id]).order('links.id')

    @json =  {pages: @pages, links: @links, story_id: @story.id, root_page_id: @story.root_page_id}.to_json
    respond_to do |format|
        format.html
        format.json { render json: @json}
    end
  end

  def destroy
    @story = Story.find(params[:id])
    authorize @story
    # if @story.destroy
    #   render json: {status: "success"}
    # else
    #   render json: {status: "failed"}
    # end
    @story.destroy
    redirect_to stories_path
  end

  def update
    # publish or update story info
    @story = Story.find(params[:id])
    authorize @story
    json = {}
    if @story.root_page_id
      if @story.update(story_params)
        json[:status] = "success"
        json[:story] = @story
      else
        json[:status] = "error"
        json[:message] = "cannot update"
      end
    else
      if @story.update(story_no_published_params)
        json[:status] = "success"
        json[:story] = @story
      else
        json[:status] = "error"
        json[:message] = "cannot update"
      end
    end

    render json: json
  end

  def create
    if params.key? :story
      whitelisted_params = story_params
    else
      whitelisted_params = {title:"Default Story Title",category:"young"}
    end
    @story = Story.new(whitelisted_params)
    authorize @story
    if @story.save
      #render json: params
      redirect_to story_path(@story)
    else
      redirect_to stories_path
    end

    #render json: @story
  end

  # this is not actually needed,user can construct request with root_page_id
  # def root_page
  #   @root_page = Story.find(params[:id]).root_page
  #   render json: @root_page
  # end

  private

  def story_params
    params.require(:story).permit(:title,:root_page_id,:category,:published,:image)
  end

  def story_no_published_params
    params.require(:story).permit(:title,:root_page_id,:category,:image)
  end

end
