#!/usr/bin/env ruby
#Sam Gleske 
#Mon Feb 16 23:40:35 EST 2015
#Fedora release 16 (Verne)
#Linux 3.6.11-4.fc16.x86_64 x86_64
#using a locally compiled ruby
#Must configure gitlab-mirrors first
require 'json'
require 'yaml'
require 'pp'

#GitHub info
config = YAML.load_file('config.yml')
user = config['user']
mirror_org = config['mirror_org']
api_token = config['api_token']
#no trailing slash
config['api_url'] ||= 'https://api.github.com'
api_url = config['api_url']
github_ignore_projects = config['github_ignore_projects'] || []

gitlab_mirrors = config['gitlab_mirrors']
mirrors = config['mirrors']

if mirror_org != nil and mirror_org.length == 0 then
  mirror_org = nil
end

#get repos and wikis
parsed = ['']
page = 1
listing = `cd "#{mirrors}";ls -1 -d *`.split()
while parsed.length > 0 do
  if mirror_org then
    url = "#{api_url}/orgs/#{mirror_org}/repos?page=#{page}"
  else
    url = "#{api_url}/users/#{user}/repos?page=#{page}"
  end
  res = `curl -s -H 'Accept: application/vnd.github.v3+json' -H 'Authorization: token #{api_token}' #{url}`
  parsed = JSON.parse(res)
  parsed.each do |repo|
    if github_ignore_projects.include? repo['name'] then
      next
    end
    if not listing.include?(repo['name']) then
      puts "clone " + repo['name']
      `cd "#{gitlab_mirrors}";./add_mirror.sh --git --project-name #{repo['name']} --mirror #{repo['ssh_url']}`
    end
    wiki_name = repo['name'] + '.wiki'
    wiki_url = repo['ssh_url'][0..-5] + '.wiki.git'
    if repo['has_wiki'] and (not listing.include?(wiki_name))
      puts "clone " + wiki_url
      `cd "#{gitlab_mirrors}";./add_mirror.sh --git --project-name #{wiki_name} --mirror #{wiki_url}`
    end
  end
  if page > 100
    break
  end
  page += 1
end

#get gists
if not mirror_org then
  parsed = ['']
  page = 1
  listing = `cd "#{mirrors}";ls -1 -d *`.split()
  while parsed.length > 0 do
    res = `curl -s -H 'Accept: application/vnd.github.v3+json' -H 'Authorization: token #{api_token}' #{api_url}/users/#{user}/gists?page=#{page}`
    parsed = JSON.parse(res)
    parsed.each do |gist|
      gist_name = 'gist' + gist['id']
      if not listing.include?(gist_name)
        puts "clone " + gist_name
        `cd "#{gitlab_mirrors}";./add_mirror.sh --git --project-name #{gist_name} --mirror #{gist['git_pull_url']}`
      end
    end
    if page > 100
      break
    end
    page += 1
  end
end


#the old way but because ruby ssl didn't have TLS on this ancient machine.  I resorted to curl in a subshell.
#require 'net/http'
#url = URI.parse("https://api.github.com/users/#{user}/repos")
#req = Net::HTTP::Get.new(url.to_s)
#req.add_field('Accept', 'application/vnd.github.v3+json')
#req.add_field('Authorization', "token #{api_token}")
#http = Net::HTTP.new(url.host, url.port)
#http.use_ssl = true
#res = http.request(req)
##or
#res = Net::HTTP.start(url.host, url.port) {|http|
#  http.request(req)
#}
#pp JSON.parse(res.body)
