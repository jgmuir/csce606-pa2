class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # removed these lines, they stopped working when adding ratings
    #@sort = params[:sort]
    #@movies = Movie.all.order(@sort)
    
    @ratings = Movie.ratings

    if !params.has_key?(:ratings) && !session.key?(:ratings)
      @ratings_to_show = []
      
    elsif !params.has_key?(:ratings) && session.key?(:ratings)
      @ratings_to_show = session[:ratings]
      @ratings_to_show_hash = Hash[@ratings_to_show.collect {|key| [key, '1']}]
      params[:ratings] = @ratings_to_show_hash
    else
      @ratings_to_show = params[:ratings].keys
      @ratings_to_show_hash = Hash[@ratings_to_show.collect {|key| [key, '1']}]
      session[:ratings] = @ratings_to_show
    end

    @movies = Movie.with_ratings(@ratings_to_show)
    
    # commented out lines because hilite not seemingly functioning, will check on later
    #@title_header = ''
    #@release_date_header = ''
    if params.has_key?(:sort)
      session[:sort] = params[:sort]
      @movies = @movies.order(params[:sort])
      #@title_header = 'hilite bg-warning' if params[:sort]=='title'
      #@release_date_header = 'hilite bg-warning' if params[:sort]=='release_date'
    elsif !params.has_key?(:sort) && session.key?(:sort)
      session[:sort] = params[:sort]
      @movies = @movies.order(params[:sort])
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
