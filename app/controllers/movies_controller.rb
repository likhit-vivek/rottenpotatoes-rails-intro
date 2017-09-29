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
    $redirectPage = false
    if params[:order]
      $orderParams = params[:order]
      $redirectPage = false
    elsif session[:order]
      $orderParams = session[:order]
      $redirectPage = true
    else
      $redirectPage = false
    end
    # $orderParams = params[:order] ? params[:order] : session[:order]
    if params[:ratings]
      $ratingParams = params[:ratings]
      $redirectPage = false
      if params[:commit] == "Refresh"
        $redirectPage = true
      end
    elsif session[:ratings]
      $ratingParams = session[:ratings]
      $redirectPage = true
    else
      $redirectPage = false
    end
    if $redirectPage
      flash.keep
      redirect_to movies_path :order => $orderParams, :ratings => $ratingParams
    end
    $ratings = []
    # $ratingParams = params[:ratings] ? params[:ratings] : session[:ratings]

    $url = "/movies?utf8=true"
    $query = "SELECT * FROM movies"

    if $ratingParams
      session[:ratings] = $ratingParams
      $ratings = $ratingParams.keys
      $query += " WHERE rating IN (" + $ratings.map{|i| "'"+i+"'" }.join(",") + ")"
      $ratings.each{|x| $url += "&ratings[" + x + "]=1"}
      $url += "&commit=Refresh"
    end

    if $orderParams == "title"
      $query += " ORDER BY title"
      $sortByTitle = true
      $sortByDate = false
      session[:order] = $orderParams
      $url += '&order=title'
    elsif $orderParams == "date"
      $query += " ORDER BY release_date"
      $sortByTitle = false
      $sortByDate = true
      session[:order] = $orderParams
      $url += '&order=date'
    else
      $sortByTitle = false
      $sortByDate = false
    end

    $titleUrl = "/movies?order=title"
    $dateUrl = "/movies?order=date"

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
