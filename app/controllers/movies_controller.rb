class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    $titleParams = params[:title]
    $dateParams = params[:date]
    $ratingParams = params[:ratings]
    $ratings = ['G', 'R', 'PG-13', 'PG']
    $query = "SELECT * FROM movies"
    if $ratingParams
      $ratings = $ratingParams.keys
      $query += " WHERE rating IN (" + $ratings.map{|i| "'"+i+"'" }.join(",") + ")"
    else
      $ratings = []
    end
    $titleUrl = "/movies?title=title"
    $dateUrl = "/movies?date=release_date"
    if $titleParams
      $query += " ORDER BY title"
    elsif $dateParams
      $query += " ORDER BY release_date"
    end
    @movies = Movie.find_by_sql $query
    @all_ratings = Movie.select(:rating).distinct
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

end
