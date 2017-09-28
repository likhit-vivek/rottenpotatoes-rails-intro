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
    $orderParams = params[:order] ? params[:order] : session[:order]
    $ratings = []
    $ratingParams = params[:ratings] ? params[:ratings] : session[:ratings]

    $query = "SELECT * FROM movies"

    if $ratingParams
      session[:ratings] = $ratingParams
      $ratings = $ratingParams.keys
      $query += " WHERE rating IN (" + $ratings.map{|i| "'"+i+"'" }.join(",") + ")"
    end

    if $orderParams == "title"
      $query += " ORDER BY title"
      $sortByTitle = true
      $sortByDate = false
      session[:order] = $orderParams
    elsif $orderParams == "date"
      $query += " ORDER BY release_date"
      $sortByTitle = false
      $sortByDate = true
      session[:order] = $orderParams
    else
      $sortByTitle = false
      $sortByDate = false
    end

    $titleUrl = "/movies?order=title"
    $dateUrl = "/movies?order=date"

    # if $titleParams
    #   $query += " ORDER BY title"
    #   session[:title] = "title"
    #   session[:date] = ""
    # elsif $dateParams
    #   $query += " ORDER BY release_date"
    #   session[:title] = ""
    #   session[:date] = "date"
    # end

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
