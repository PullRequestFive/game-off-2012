Scavenger.controllers  do
  layout :main

  get :index do
    if session[:username]
      user = User.get session[:username]
      redirect url_for(:level, :id => user.next_level)
    else
      render :index
    end
  end

  get :level, :with => :id do
    level = Level.get params[:id]
    render level.template
  end

  get :leaderboard do
    # TODO(icco): Query DB to get logged in users progress and top 25 users.
    render :leaderboard
  end

  get :login do
    if Padrino.env == :development
      redirect "/auth/developer"
    else
      redirect "/auth/github"
    end
  end

  get :logout do
    session.clear

    redirect "/"
  end

  # For development testing
  post "/auth/developer/callback" do
    auth = request.env["omniauth.auth"]
    auth = auth.info
    logger.push(" Developer: #{auth.inspect}", :devel)

    # TODO: Validate.
    user = User.create(
      :name => auth["name"],
      :email => auth["email"]
    )

    session[:username] = user.name

    redirect "/"
  end

  # Github callback
  get "/auth/github/callback" do
    auth = request.env["omniauth.auth"]
    auth = auth.info
    logger.push(" Github: #{auth.inspect}", :devel)

    # TODO: Validate.
    user = User.create(
      :name => auth["nickname"],
      :email => auth["email"]
    )

    session[:username] = user.name

    redirect "/"
  end

  get "/auth/failure" do
    flash[:notice] = params[:message]
    redirect "/"
  end
end
