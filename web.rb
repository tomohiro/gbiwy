require 'json'
require 'open-uri'
require 'ostruct'

require 'sinatra'


ENV['https_proxy'] = ENV['http_proxy'] if ENV['http_proxy']

class Repository < OpenStruct
  def initialize(repo)
    super
    @owner  = repo['owner']['login']
    @avatar = repo['owner']['avatar_url']
  end
end


get '/' do
  haml :index
end

get '/watched/:user' do |user|
  begin
    json = open("https://api.github.com/users/#{user}/watched?per_page=1000").read
    @repos = JSON.parse(json).map { |repo| Repository.new(repo) }
    haml :watched
  rescue
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
  %body
    = yield

@@ index
%form
  %input#user(type='text' name='user')
  %input(type='button' onclick="location.href='/watched/' + document.getElementById('user').value" value='show')

@@ watched
%table
  %tr
    %th avatar
    %th name
    %th owner
    %th language
    %th description
    %th watchers
    %th forks
    %th updated
  - @repos.each do |repo|
    %tr
      %td.avatar
        %img(src='#{repo.avatar}')
      %td.name
        %a(href='#{repo.html_url}')= repo.name
      %td.owner
        %a(href='https://github.com/#{repo.owner}')= repo.owner
      %td.language= repo.language
      %td.description= repo.description
      %td.watchrs= repo.watchers
      %td.forks= repo.forks
      %td.updated_at= repo.updated_at

%a(href='/') back

@@ usernotfound
%h2 User not found
%a(href='/') back