class StaticPagesController < ApplicationController
  def home
    render('devise/sessions/new')
  end
end
