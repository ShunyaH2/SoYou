class Admin::DashboardController < Admin::ApplicationController
  def top
    @users_count    = User.count
    @posts_count    = Post.count
    @profiles_count = Profile.count
  end
end