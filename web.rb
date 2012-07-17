require 'json'
require 'open-uri'
require 'sinatra'

set :haml, :format => :html5

get '/' do
  haml :index
end

get '/watched/:user' do |user|
  @user = user
  begin
    json = open("https://api.github.com/users/#{@user}/watched?per_page=1000").read
    @repos = JSON.parse(json).map { |r| OpenStruct.new(r) }
    haml :watched
  rescue => e
    haml :usernotfound
  end
end

__END__

@@ layout
!!!
%html
  %head
    %meta(charset='UTF-8')
    %title Git Brother Is Watching You
    %link(rel='stylesheet' href='/css/bootstrap.min.css')
    %link(rel='stylesheet' href='/css/font-awesome.css')
  %body
    %div.navbar.navbar-fixed-top
      %div.navbar-inner
        %div.container
          %h3
            %a.brand(href='/')
              %i.icon-github-sign
              Git Brother Is Watching You
          %form.form-search.navbar-search.pull-right
            %input.input-medium.search-query#user(type='text' placeholder='GitHub User Name')
            %button.btn(type='button' href='#' onclick="location.href='/watched/' + document.getElementById('user').value") Search

    %div(style='margin-top: 60px;')
      = yield

@@ index
%div.span12(style='margin: 0 auto; float: none;')
  %div.hero-unit.span10
    %div.hero-content
      %h1
        %i.icon-github(style='font-size: 50px;')
        GBIWY
        %p GitHub watched repositories


@@ watched
%div.container
  %table.table.table-striped
    %thead
      %tr
        %th avatar
        %th name
        %th owner
        %th language
        %th description
        %th watchers
        %th forks
        %th updated
    %tbody
      - @repos.each do |repo|
        %tr
          %td.avatar
            %img(width=30 height=30 style='border: 1px solid #ccc; padding: 1px;' src="#{repo.owner['avatar_url']}")
          %td.name
            %a(href='#{repo.html_url}')= repo.name
          %td.owner
            %a(href="https://github.com/#{repo.owner['login']}")= repo.owner['login']
          %td.language= repo.language
          %td.description= repo.description
          %td.watchrs= repo.watchers
          %td.forks= repo.forks
          %td.updated_at= repo.updated_at

@@ usernotfound
%div.span12(style='margin: 0 auto; float: none;')
  %h2 User not found: #{@user}
