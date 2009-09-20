ask_app_name = File.basename(root);
default_ask_site_name = ask_app_name.camelize
ask_site_name = ask("What is this site's name? (Return for '#{default_ask_site_name}')")
ask_site_name = default_ask_site_name if ask_site_name.blank?
default_ask_author = ENV['USER'] || ENV['USERNAME'];
ask_author = ask("What is the site author's name? (Return for '#{default_ask_author}')")
ask_author = default_ask_author if ask_author.blank?
yes_testing = yes?("Do you want to use testing libraries (RSpec, Webrat, & Cucumber)? (Return for 'no')")
yes_symlink_plugins = yes?("Do you want to use symlinks to existing local copies of the plugins repos? (Return or 'no' to make new local repo copies)")
if yes_symlink_plugins
  default_ask_symlink_dir = "~/Library/RubyOnRails/plugins"
  ask_symlink_dir = yes?("In which directory are the current plugins? (Return for '#{default_ask_symlink_dir}/')")
  ask_symlink_dir = default_ask_symlink_dir if ask_symlink_dir.blank?
end
ask_exception_notified = ask("List the space-separated emails which should be notified of site exceptions? (Return for none)")
yes_exception_notification = !ask_exception_notified.blank?
yes_marketplace = yes?("Do you want to include Marketplace plugin (Products, Vendors, Manufacturers, etc)? (Return for 'no')")
yes_geokit = yes?("Do you want to include Geokit geocoding functionality? (Return for 'no')")
yes_portlet = yes?("Do you want this site to act as a Portlet, which can be placed inside other webpages? (Return for 'no')")

file "README", <<-CODE
#{ask_site_name}
==============

TODO

Copyright (c) #{Date.today.year} #{ask_author}, released under the MIT license
CODE

file "config/environment.rb", <<-CODE
# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

require File.join(File.dirname(__FILE__), '../vendor/plugins/engines/boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( \#{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  #config.gem "rspec", :lib => false, :version => '>=1.2.2'

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  config.plugins = [ #{yes_geokit ? ":'geokit-rails', " : ''}:trainyard, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  config.i18n.load_path += Dir[File.join(RAILS_ROOT, 'config', 'locales', '*', '*.{rb,yml}')]
end
CODE

gem 'mysql'
gem "RedCloth", :version => '>= 4.0.1'
gem "authlogic", :version => '>=2.0.0', :source => 'http://gems.github.com'
gem "thoughtbot-paperclip", :lib => 'paperclip', :version => '>=2.2.8', :source => 'http://gems.github.com'
gem "mislav-will_paginate", :lib => 'will_paginate', :version => '>=2.3.7', :source => 'http://gems.github.com'
if yes_testing
  gem "rspec", :lib => false, :version => '>=1.2.2'
  gem "rspec-rails", :lib => false, :version => '>=1.2.2'
  gem "webrat", :lib => false, :version => '>=0.4.3', :source => 'http://gems.github.com'
  gem "cucumber", :lib => false, :version => '>=0.2.2', :source => 'http://gems.github.com'
end
if yes_geokit
  gem "andre-geokit", :lib => 'geokit', :source => 'http://gems.github.com'
end

if yes_symlink_plugins
  inside "vendor/plugins" do
    %w(active_enumeration acts_as_list acts_as_tree indexer searchable_record trainyard engines easy-fckeditor http_accept_language make_resourceful).each do |plugin_name|
      run "ln -s #{File.join(ask_symlink_dir, plugin_name)} #{plugin_name}"
    end
    run "ln -s #{File.join(ask_symlink_dir, 'exception_notification')} exception_notification" if yes_exception_notification
    run "ln -s #{File.join(ask_symlink_dir, 'marketplace')} marketplace" if yes_marketplace
    if yes_geokit
      run "ln -s #{File.join(ask_symlink_dir, 'geographer')} geographer"
      run "ln -s #{File.join(ask_symlink_dir, 'geokit-rails')} geokit-rails"
    end
  end
else
  plugin "active_enumeration", :git => "git://github.com/glennpow/active_enumeration.git"
  plugin "acts_as_list", :git => "git://github.com/rails/acts_as_list.git"
  plugin "acts_as_tree", :git => "git://github.com/rails/acts_as_tree.git"
  plugin "indexer", :git => "git://github.com/glennpow/indexer.git"
  plugin "searchable_record", :git => "git://github.com/glennpow/searchable_record.git"
  plugin "trainyard", :git => "git://github.com/glennpow/trainyard.git"
  plugin "engines", :git => "git://github.com/lazyatom/engines.git"
  plugin "easy-fckeditor", :git => "git://github.com/gramos/easy-fckeditor.git"
  plugin "http_accept_language", :git => "git://github.com/iain/http_accept_language.git"
  plugin "make_resourceful", :git => "git://github.com/hcatlin/make_resourceful.git"
  plugin "exception_notification", :git => "git://github.com/rails/exception_notification.git" if yes_exception_notification
  plugin "marketplace", :git => "git://github.com/glennpow/marketplace.git" if yes_marketplace
  if yes_geokit
    plugin "geographer", :git => "git://github.com/glennpow/geographer.git"
    plugin "geokit-rails", :git => "git://github.com/andre/geokit-rails.git"
  end
end

rake "gems:install"

if yes_testing
  generate :rspec
end

file "config/database.yml", <<-CODE
development:
  adapter: mysql
  encoding: utf8
  database: #{ask_app_name}_development
  username: root
  password:
  socket: /tmp/mysql.sock

test:
  adapter: mysql
  encoding: utf8
  database: #{ask_app_name}_test
  username: root
  password:
  socket: /tmp/mysql.sock

production:
  adapter: mysql
  encoding: utf8
  database: #{ask_app_name}
  username: root
  password: 
  socket: /tmp/mysql.sock
CODE
run "cp config/database.yml config/example_database.yml"

initializer "configuration.rb", <<-CODE
Configuration.load_path << "\#{RAILS_ROOT}/config/application.yml"
CODE

if yes_exception_notification
  initializer "exception_notification.rb", <<-CODE
ExceptionNotifier.exception_recipients = %w(#{ask_exception_notified})
CODE
end

if yes_marketplace
  initializer "marketplace.rb", <<-CODE
User.class_eval do
  acts_as_marketer
end
CODE
end

initializer "mail.rb", <<-CODE
# Email settings
#ActionMailer::Base.default_url_options[:host] = site_email_host
ActionMailer::Base.delivery_method = ENV['RAILS_ENV'] == 'production' ? :sendmail : :test # :smtp
ActionMailer::Base.smtp_settings = {
  :address => 'localhost',
#  :domain => site_email_host,
  :port => 25
}
CODE

file "db/migrate/#{Time.now.strftime('%Y%m%d%H%M%S')}_rev_engines.rb", <<-CODE
class RevEngines < ActiveRecord::Migration
  def self.up
    Engines.plugins["trainyard"].migrate(4)
    #{yes_marketplace ? "Engines.plugins[\"marketplace\"].migrate(1)" : ""}
  end

  def self.down
    Engines.plugins["trainyard"].migrate(0)
    #{yes_marketplace ? "Engines.plugins[\"marketplace\"].migrate(0)" : ""}
  end
end
CODE

file "app/controllers/application_controller.rb", <<-CODE
class ApplicationController < ActionController::Base
  #{yes_exception_notification ? "include ExceptionNotifiable" : ""}

  helper :all

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery :only => [ :create, :update, :destroy ] #, :secret => 'CHANGE ME TO SOMETHING SECURE'
end
CODE

file "app/controllers/site_controller.rb", <<-CODE
class SiteController < ApplicationController
  def root
    respond_to do |format|
      format.html { render :layout => 'layouts/clean' } # root.html.erb
    end
  end
  
  def home
    if logged_in?
      if has_administrator_role?
        self.action_name = 'home/administrator'
        render :action => self.action_name
      else
        self.action_name = 'home/user'
        render :action => self.action_name
      end
    else
      self.action_name = 'home/guest'
      render :action => self.action_name
    end
  end
  
  def terms
  end
  
  def contact
  end
  
  def help
  end
  
  def welcome
  end
end
CODE

file "app/helpers/site_helper.rb", <<-CODE
module SiteHelper
  def site_page_title
    "\#{site_name}\#{page_title.blank? ? '' : " - \#{page_title}"}"
  end
  
  def render_page_title
    "<p class='page-title'>\#{page_title}</p>" unless page_title.blank?
  end
  
  def render_page_actions(options = {})
    valid_page_actions = actions_for(page_actions)
    render_bar_list(valid_page_actions, :class => merge_classes(options[:class], 'page-actions')) unless valid_page_actions.empty?
  end
  
  def title_menu
    content_tag :div, :class => 'title-menu' do
      actions = []
      actions << "<span class='beta'>BETA</span>" if Configuration.beta_site
      if topic = Topic.find_by_name(Configuration.feedback_topic_name)
        actions << link_to_unless_current(icon_label(:feedback, t(:feedback, :scope => [ :site_content ])), topic)
      end
      render_bar_list(actions)
    end
  end
  
  def user_organization_name
    h(current_user.name) + (current_organization.nil? ? "" : " (\#{current_organization.name})")
  end
  
  def user_menu
    content_tag :div, :class => 'user-menu' do
      actions = []
      if logged_in?
        actions << link_to_unless_current(t(:welcome_user, :scope => [ :site_content ], :user => h(current_user.name)), user_path(current_user))
        unless Configuration.demo_site && @current_user.login == Configuration.demo_user
          actions << link_to_unless_current(t(:edit_object, :object => t(:account, :scope => [ :authentication ])), edit_user_path(current_user))
        end
        actions << link_to_unless_current(t(:logout, :scope => [ :authentication ]), logout_path)
      else
        should_return_to = controller_name != 'users' && controller_name != 'user_sessions' && controller_name != 'site'
        actions << link_to_unless_current(t(:login, :scope => [ :authentication ]), login_path(:return_to => should_return_to))
        actions << link_to_unless_current(t(:join, :scope => [ :authentication ]), new_user_path)
      end
      render_bar_list(actions)
    end
  end
  
  def site_menu
    content_tag :div, :class => 'site-menu' do
      actions = []
      actions << link_to_unless_current(t(:home), logged_in? ? home_path : root_path)
      render_bar_list(actions)
    end
  end
  
  def info_menu
    content_tag :div, :class => 'info-menu' do
      render_bar_list([
        link_to_unless_current(t(:terms_and_conditions, :scope => [ :site_content ]), terms_path),
        link_to_unless_current(t(:contact_us, :scope => [ :site_content ]), contact_path),
        link_to_unless_current(t(:help), help_path)
      ])
    end
  end
  
  def links_menu
    url = url_escape(request.url)
    title = url_escape(site_page_title)
    content_tag :div, :class => 'links-menu' do
      "<script type=\\"text/javascript\\">var addthis_pub=\\"glennpow\\";</script>
      <a href=\\"http://www.addthis.com/bookmark.php?v=20\\" onmouseover=\\"return addthis_open(this, '', '[URL]', '[TITLE]')\\" onmouseout=\\"addthis_close()\\" onclick=\\"return addthis_sendto()\\"><img src=\\"http://s7.addthis.com/static/btn/sm-share-en.gif\\" width=\\"83\\" height=\\"16\\" alt=\\"Bookmark and Share\\" style=\\"border:0\\"/></a><script type=\\"text/javascript\\" src=\\"http://s7.addthis.com/js/200/addthis_widget.js\\"></script>"
    end
  end
  
  def render_panel(options = {}, &block)
    locals = {
      :content => capture(&block),
      :panel_class => options[:panel_class],
      :actions => actions_for(options[:actions])
    }
    content = render(:partial => 'site/panel', :locals => locals)
    block_called_from_erb?(block) ? concat(content) : content
  end
  
  def footer
    render :partial => 'site/footer'
  end
end
CODE

file "app/views/layouts/_application.css.erb", <<-CODE
body {
}

body, p, ol, ul, td {
  font-family: arial, helvetica, sans-serif;
  font-size:   13px;
  line-height: 18px;
  margin: 0;
}

p {
  padding: 0px;
  margin: 4px 0px;
}

pre {
  padding: 10px;
  font-size: 11px;
}

img {
  border: none;
}

table {
  border-spacing: 0px;
}

table.columns {
  table-layout: fixed;
}

td {
  padding: 0px;
}

ul {
  padding: 0px;
}

hr {
  border: none;
  background: transparent url('/images/theme/separator_long.jpg') no-repeat top center;
  min-height: 1px;
  min-width: 1px;
}

.flash {
  padding: 5px 15px;
  margin: 0;
}

.wrapper {
  margin: 10px auto;
  max-width: 900px;
}

.main-table {
  width: 100%;
}

.main-td-content {
}

.main-td-advertisements {
  width: 200px;
  border-left: 1px inset <%= theme[:secondary].background_color %>;
  text-align: center;
  background: <%= theme[:secondary].background_color %>;
}

.header-content {
  margin: 20px 0px;
  padding: 10px 40px;
}

table.header-table {
  width: 100%;
}

.header-left-td {
}

.header-banner {
}

.header-login {
  float: right;
  text-align: left;
  padding: 10px;
  width: 250px;
  background-color: #fff;
  opacity: 0.8;
  border: 1px dotted <%= theme[:secondary].background_color %>;
}

.header-title {
  margin-left: 5px;
}

.header-title p {
  line-height: 11px;
  font-weight: bold;
}

.navigation {
  border-bottom: 2px outset <%= theme[:secondary].background_color %>;
}

.page-title {
  border-bottom: 2px solid <%= theme[:secondary].background_color %>;
  font-size: x-large;
  padding: 6px 10px;
  text-align: left;
  margin: 8px 0px 8px 0px;
}

.page-title .actions {
  color: #666;
}

.page-title .actions a {
  color: #669;
}

.page-title .actions a:hover {
  color: #336;
}

.heading {
  background: none;
  border-top: 3px solid <%= theme[:secondary].background_color %>;
  border-bottom: 1px solid <%= theme[:secondary].background_color %>;
  margin: 20px 0 12px 0;
  padding: 6px 0 4px 0;
}

.heading span.label {
  font-size: large;
  padding: 2px 10px 2px 10px;
}

.footer-content {
  padding: 10px 40px;
}

.show-field {
  text-align: left;
  padding-left: 30px;
}

.show-field .label {
  width: 150px;
}

.show-field .value .actions {
  font-weight: normal;
}

.show-field-values {
  border: 1px dotted <%= theme[:secondary].background_color %>;
  display: table;
  width: auto;
  margin: 0 0 5px 40px;
  padding: 10px;
}

.show-text-area {
  padding: 10px 30px;
}

table.show-table {
  width: 100%;
}

table.show-table td {
  vertical-align: top;
}

.form-submit {
  margin: 10px 0px;
}

.form-submit input {
  background: transparent url('/images/theme/button.png') no-repeat;
  color: #000;
  width: 140px;
  height: 50px;
  font-family: serif;
  font-weight: bold;
  font-size: larger;
  border: none;
  cursor: pointer;
}

.application-box-list {
  margin-bottom: 1em;
  margin-left: 140px;
}

.application-box-list ul {
  width: 50em;
}

.application-box-list li {
  float: left;
  width: 25em;
}

.application-box-list br {
  clear: left;
}

.user-menu, .info-menu {
  text-align: right;
  padding-right: 10px;
}

.title-menu, .site-menu {
  text-align: left;
  padding-left: 10px;
}

.title-menu {
  font-weight: bold;
}

.main {
  border: 1px solid;
  margin-top: 1px;
  margin-bottom: 1px;
}

.content {
  padding: 10px;
  min-height: 480px;
}

.footer-navigation {
  height: 20px;
}

.footer-locale {
  display: inline;
}

.footer-locale select {
  font-size: xx-small;
  margin-left: 10px;
}

.powered-by {
  text-align: right;
  margin-top: 2px;
  margin-right: 10px;
}

.powered-by span, .powered-by p {
  color: #c1c4c3;
  font-size: x-small;
}

.intro-content {
  padding: 10px 60px 10px 60px;
}

.intro-article {
  padding-top: 10px;
  margin-right: 40px;
}

.theme-preview-overlay {
  background: transparent url('/images/theme/preview.png') repeat;
	<%= alpha_css(0.5) %>
}

.page-content.article {
  background: <%= theme[:secondary].background_color %>;
  border: 1px solid <%= theme[:primary].background_color %>;
  color: <%= theme[:secondary].font_color %>;
}

.page-content.article a {
  color: <%= theme[:secondary].link_color %>;
}

.page-content.article a:hover {
  color: <%= theme[:secondary].link_hover_color %>;
}

.indexer .paginate {
  border: none;
  padding: 5px 10px;
}

.panel {
  background: <%= theme[:secondary].background %>;
  border-bottom: 2px outset <%= theme[:secondary].background_color %>;
  color: <%= theme[:secondary].font_color %>;
  padding: 15px;
  margin: 15px 0px;
}

.panel a {
  color: <%= theme[:secondary].link_color %>;
}

.panel a:hover {
  color: <%= theme[:secondary].link_hover_color %>;
}

.panel .label {
  padding: 6px;
  font-size: larger;
  font-weight: bold;
}

.panel ul.actions {
  background: <%= theme[:secondary].background %>;
  border-top: 2px inset <%= theme[:secondary].background_color %>;
  border-bottom: 2px outset <%= theme[:secondary].background_color %>;
  border-left: 1px solid <%= theme[:primary].background_color %>;
  border-right: 1px solid <%= theme[:primary].background_color %>;
  color: <%= theme[:secondary].font_color %>;
  list-style: disc inside;
  padding: 15px;
}

.panel ul.actions a {
  color: <%= theme[:secondary].link_color %>;
  text-decoration: none;
}

.panel ul.actions a:hover {
  color: <%= theme[:secondary].link_hover_color %>;
}

.panel-table {
  border-spacing: 10px;
}

.links-menu {
  text-align: center;
  font-size: smaller;
}

.current-organization {
  border: 2px dotted <%= theme[:primary].background_color %>;
}
CODE

file "app/views/layouts/application.html.erb", <<-CODE
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
  <meta http-equiv="content-type" content="text/html;charset=UTF-8" />
  
  <title><%= site_page_title %></title>
  
  <%= javascript_include_tag :defaults %>
  <%= trainyard_header %>
  <%= stylesheet_link_tag_theme 'layouts/application' %>
  <%= yield(:head) %>
</head>
<body>

<div class="wrapper">
  <div class="header">
    <table class="full-width">
      <tr>
        <td>
          <%= title_menu %>
        </td>
        <td>
          <%= user_menu %>
        </td>
      </tr>
    </table>
  </div>
  
  <div class="main">
    <div class="navigation bar">
      <table class="full-width">
        <tr>
          <td>
            <%= site_menu %>
          </td>
          <td>
            <%= info_menu %>
          </td>
        </tr>
      </table>
    </div>

    <div class="messages">
      <%= render_flash %>
    </div>

    <table class="main-table">
      <tr>
        <td class="main-td-content">
          <div class="content">
            <% for_page_content(:route => params[:route_page_content].nil? ? true : params[:route_page_content]) do |article| %>
              <%= render_article(article, :class => 'page-content') %>
            <% end %>

            <%= render_breadcrumbs %>

            <%= render_page_title %>
      
            <%= render_page_actions %>
      
            <%= yield %>
          </div>
        </div>
      </td>
    </tr>
  </table>
  
  <div class="footer">
    <table class="full-width columns">
      <tr>
        <td>
          <div class="footer-locale">
            <%= session_locale_select %>
          </div>
        </td>
        <td>
          <%= links_menu %>
        </td>
        <td>
          <%= footer %>
        </td>
      </tr>
    </table>
  </div>
</div>

</body>
</html>
CODE

file "app/views/layouts/clean.html.erb", <<-CODE
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
  <meta http-equiv="content-type" content="text/html;charset=UTF-8" />
  
  <title><%= "\#{site_page_title}" %></title>
  
  <%= javascript_include_tag :defaults %>
  <%= trainyard_header %>
  <%= stylesheet_link_tag_theme 'layouts/application' %>
  <%= yield(:head) %>
</head>
<body>
  <%= yield %>
</body>
</html>
CODE

file "app/views/site/_footer.html.erb", <<-CODE
<div class="powered-by">
  Powered by <strong><a href="http://github.com/glennpow/bullet_train/tree/master">BulletTrain</a></strong>
  <p>© 2009 <a href="http://github.com/glennpow">Glenn Powell</a> All rights reserved.</p>
</div>
CODE

file "app/views/layouts/_panel.html.erb", <<-CODE
<div class="panel <%= panel_class %>">
  <table class="panel-table full-width columns">
    <tr>
      <td>
        <%= content %>
      </td>
      <% if actions && actions.any? %>
        <td>
          <ul class="actions">
            <% actions.each do |action| %>
              <li>
                <%= action %>
              </li>
            <% end %>
          </ul>
        </td>
        <% end %>
    </tr>
  </table>
</div>
CODE

file "app/views/site/root.html.erb", <<-CODE
<% title nil %>

<div class="wrapper">
  <div class="main">
	  <% if logged_in? %>
			<p><%= link_to_unless_current("Welcome \#{h(current_user.name)}", user_path(current_user)) %></p>
			<p><%= link_to_unless_current(t(:home), home_path) %></p>
	  <% else %>
			<p>Already Registered?</p>
			<p><%= link_to(t(:login, :scope => [ :authentication ]), login_path) %></p>
		<% end %>
  </div>
  
  <div class="footer">
    <div>
      <table class="full-width">
        <tr>
          <td>
            <div class="footer-locale">
              <%= session_locale_select %>
            </div>
          </td>
          <td>
            <%= footer %>
          </td>
        </tr>
      </table>
    </div>
  </div>
</div>
CODE

file "app/views/site/home/terms.html.erb", <<-CODE
<% title t(:terms_and_conditions) %>
CODE

file "app/views/site/home/contact.html.erb", <<-CODE
<% title t(:contact_us, :scope => [ :site_content ]) %>
CODE

file "app/views/site/home/help.html.erb", <<-CODE
<% title t(:help) %>
CODE

file "app/views/site/welcome.html.erb", <<-CODE
<% title t(:welcome, :scope => [ :site_content ]) %>
CODE

if yes_marketplace
  file "app/views/site/home/administrator.html.erb", <<-CODE
<% title t(:home) %>

<% render_panel(:actions => [
    link_to(t(:messages_info, :scope => [ :content ], :count => current_user.messages.length, :unread => current_user.messages.unread.length), messages_path),
    link_to(t(:administer_object, :scope => [ :authentication ], :object => tp(:user, :scope => [ :authentication ])), users_path),
    link_to(t(:administer_object, :scope => [ :authentication ], :object => tp(:group, :scope => [ :authentication ])), groups_path),
    link_to(t(:administer_object, :scope => [ :authentication ], :object => tp(:vendor, :scope => [ :marketplace ])), vendors_path),
    link_to(t(:administer_object, :scope => [ :authentication ], :object => tp(:manufacturer, :scope => [ :marketplace ])), manufacturers_path),
    link_to(t(:administer_object, :scope => [ :authentication ], :object => tp(:make, :scope => [ :marketplace ])), makes_path),
    link_to(t(:administer_object, :scope => [ :authentication ], :object => tp(:model, :scope => [ :marketplace ])), models_path),
    link_to(t(:administer_object, :scope => [ :authentication ], :object => tp(:product, :scope => [ :marketplace ])), products_path),
    link_to(t(:administer_object, :scope => [ :authentication ], :object => tp(:feature_type, :scope => [ :marketplace ])), feature_types_path),
    link_to(t(:administer_object, :scope => [ :authentication ], :object => tp(:feature, :scope => [ :marketplace ])), features_path),
    link_to(t(:administer_object, :scope => [ :authentication ], :object => tp(:wiki, :scope => [ :content ])), wikis_path),
    link_to(t(:administer_object, :scope => [ :authentication ], :object => tp(:page, :scope => [ :site_content ])), pages_path),
    link_to(t(:administer_object, :scope => [ :authentication ], :object => tp(:theme, :scope => [ :themes ])), themes_path),
  ]) do %>
  <%=tt :welcome_home_user, :scope => [ :site_content ], :user => h(current_user.name) %>
<% end %>
CODE

  file "app/views/site/home/user.html.erb", <<-CODE
<% title t(:home) %>

<% render_panel(:actions => [
    link_to(t(:messages_info, :scope => [ :content ], :count => current_user.messages.length, :unread => current_user.messages.unread.length), messages_path),
    link_to(t(:watched_object, :scope => [ :content ], :object => tp(:product, :scope => [ :marketplace ])), user_watchings_path(current_user, :resource_type => 'Product')),
    link_to(tp(:quote_request, :scope => [ :marketplace ]), user_quote_requests_path(current_user))
  ]) do %>
  <%=tt :welcome_home_user, :scope => [ :site_content ], :user => h(current_user.name) %>
<% end %>
CODE
else
  file "app/views/site/home/administrator.html.erb", <<-CODE
<% title t(:home) %>

<% render_panel(:actions => [
    link_to(t(:messages_info, :scope => [ :content ], :count => current_user.messages.length, :unread => current_user.messages.unread.length), messages_path),
    link_to(t(:administer_object, :scope => [ :authentication ], :object => tp(:user, :scope => [ :authentication ])), users_path),
    link_to(t(:administer_object, :scope => [ :authentication ], :object => tp(:group, :scope => [ :authentication ])), groups_path),
    link_to(t(:administer_object, :scope => [ :authentication ], :object => tp(:wiki, :scope => [ :content ])), wikis_path),
    link_to(t(:administer_object, :scope => [ :authentication ], :object => tp(:page, :scope => [ :site_content ])), pages_path),
    link_to(t(:administer_object, :scope => [ :authentication ], :object => tp(:theme, :scope => [ :themes ])), themes_path),
  ]) do %>
  <%=tt :welcome_home_user, :scope => [ :site_content ], :user => h(current_user.name) %>
<% end %>
CODE

  file "app/views/site/home/user.html.erb", <<-CODE
<% title t(:home) %>

<% render_panel(:actions => [
    link_to(t(:messages_info, :scope => [ :content ], :count => current_user.messages.length, :unread => current_user.messages.unread.length), messages_path),
  ]) do %>
  <%=tt :welcome_home_user, :scope => [ :site_content ], :user => h(current_user.name) %>
<% end %>
CODE
end

file "app/views/site/home/guest.html.erb", <<-CODE
<% title t(:home) %>
CODE

file "config/environments/production.rb", <<-CODE
# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

# See everything in the log (default is :info)
# config.log_level = :debug

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# Enable threaded mode
# config.threadsafe!
CODE

file "config/application.yml", <<-CODE
common: &common
  default_path: /home
  signup_success_path: /welcome
  default_locale: en-US
  beta_site: true
  feedback_topic_name: Give Us Feedback!
  
development:
  <<: *common
  sites:
    - :domain: '#{ask_app_name}.com'
      :name: '#{ask_site_name}'
      :email: mail@#{ask_app_name}.com
      :email_host: #{ask_app_name}.com
    - :domain: 'localhost'
      :name: '#{ask_site_name} (localhost)'
      :email: mail@#{ask_app_name}.com
      :email_host: localhost:3000
  email_activation: false

test:
  <<: *common
  sites:
    - :domain: '#{ask_app_name}.com'
      :name: '#{ask_site_name}'
      :email: mail@#{ask_app_name}.com
      :email_host: #{ask_app_name}.com
    - :domain: 'localhost'
      :name: '#{ask_site_name} (localhost)'
      :email: mail@#{ask_app_name}.com
      :email_host: localhost:3000
  email_activation: false

production:
  <<: *common
  sites:
    - :domain: '#{ask_app_name}.com'
      :name: '#{ask_site_name}'
      :email: mail@#{ask_app_name}.com
      :email_host: #{ask_app_name}.com
  email_activation: true
CODE

run "rm config/locales/en.yml"

file "config/locales/en/site_content.yml", <<-CODE
en:
  site_content:
    already_registered: Already registered?
    contact_us: Contact Us
    feedback: Give Us Feedback!
    powered_by: Powered by
    register_now: Register Now
    terms_and_conditions: Terms and conditions
    welcome_user: welcome {{user}}
    welcome_home_user: welcome *{{user}}*
  website:
    page: Site Page
CODE

file "config/locales/en/rails.yml", <<-CODE
en:
  number:
    # Used in number_with_delimiter()
    # These are also the defaults for 'currency', 'percentage', 'precision', and 'human'
    format:
      # Sets the separator between the units, for more precision (e.g. 1.0 / 2.0 == 0.5)
      separator: "."
      # Delimets thousands (e.g. 1,000,000 is a million) (always in groups of three)
      delimiter: ","
      # Number of decimals, behind the separator (the number 1 with a precision of 2 gives: 1.00)
      precision: 3
      
    # Used in number_to_currency()
    currency:
      format:
        # Where is the currency sign? %u is the currency unit, %n the number (default: $5.00)
        format: "%u%n"
        unit: "$"
        # These three are to override number.format and are optional
        separator: "."
        delimiter: ","
        precision: 2
        
    # Used in number_to_percentage()
    percentage:
      format:
        # These three are to override number.format and are optional
        # separator: 
        delimiter: ""
        # precision: 
        
    # Used in number_to_precision()
    precision:
      format:
        # These three are to override number.format and are optional
        # separator:
        delimiter: ""
        # precision:
        
    # Used in number_to_human_size()
    human:
      format:
        # These three are to override number.format and are optional
        # separator: 
        delimiter: ""
        precision: 1

  # Used in distance_of_time_in_words(), distance_of_time_in_words_to_now(), time_ago_in_words()
  datetime:
    distance_in_words:
      half_a_minute: "half a minute"
      less_than_x_seconds:
        one:   "less than 1 second"
        other: "less than {{count}} seconds"
      x_seconds:
        one:   "1 second"
        other: "{{count}} seconds"
      less_than_x_minutes:
        one:   "less than a minute"
        other: "less than {{count}} minutes"
      x_minutes:
        one:   "1 minute"
        other: "{{count}} minutes"
      about_x_hours:
        one:   "about 1 hour"
        other: "about {{count}} hours"
      x_days:
        one:   "1 day"
        other: "{{count}} days"
      about_x_months:
        one:   "about 1 month"
        other: "about {{count}} months"
      x_months:
        one:   "1 month"
        other: "{{count}} months"
      about_x_years:
        one:   "about 1 year"
        other: "about {{count}} years"
      over_x_years:
        one:   "over 1 year"
        other: "over {{count}} years"

  activerecord:
    errors:
      template:
        header:
          one:    "1 error prohibited this {{model}} from being saved"
          other:  "{{count}} errors prohibited this {{model}} from being saved"
        # The variable :count is also available
        body: "There were problems with the following fields:"

  activerecord:
    errors:
      # The values :model, :attribute and :value are always available for interpolation
      # The value :count is available when applicable. Can be used for pluralization.
      messages:
        inclusion: "is not included in the list"
        exclusion: "is reserved"
        invalid: "is invalid"
        confirmation: "doesn't match confirmation"
        accepted: "must be accepted"
        empty: "can't be empty"
        blank: "can't be blank"
        too_long: "is too long (maximum is {{count}} characters)"
        too_short: "is too short (minimum is {{count}} characters)"
        wrong_length: "is the wrong length (should be {{count}} characters)"
        taken: "has already been taken"
        not_a_number: "is not a number"
        greater_than: "must be greater than {{count}}"
        greater_than_or_equal_to: "must be greater than or equal to {{count}}"
        equal_to: "must be equal to {{count}}"
        less_than: "must be less than {{count}}"
        less_than_or_equal_to: "must be less than or equal to {{count}}"
        odd: "must be odd"
        even: "must be even"
        # Append your own errors here or at the model/attributes scope.

      models:
        # Overrides default messages
      
      attributes:
        # Overrides model and default messages.

  date:
    formats:
      # Use the strftime parameters for formats.
      # When no format has been given, it uses default.
      # You can provide other formats here if you like!
      default: "%Y-%m-%d"
      short: "%b %d"
      long: "%B %d, %Y"
      
    day_names: [Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday]
    abbr_day_names: [Sun, Mon, Tue, Wed, Thu, Fri, Sat]
      
    # Don't forget the nil at the beginning; there's no such thing as a 0th month
    month_names: [~, January, February, March, April, May, June, July, August, September, October, November, December]
    abbr_month_names: [~, Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec]
    # Used in date_select and datime_select.
    order: [ :year, :month, :day ]

  time:
    formats:
      default: "%a, %d %b %Y %H:%M:%S %z"
      short: "%d %b %H:%M"
      long: "%B %d, %Y %H:%M"
    am: "am"
    pm: "pm"
      
  # Used in array.to_sentence.
  support:
    array:
      sentence_connector: "and"
CODE

file "config/routes.rb", <<-CODE
ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'site', :action => 'root'
  map.home '/home', :controller => 'site', :action => 'home'
  map.terms '/terms', :controller => 'site', :action => 'terms'
  map.contact '/contact', :controller => 'site', :action => 'contact'
  map.help '/help', :controller => 'site', :action => 'help'
  map.welcome '/welcome', :controller => 'site', :action => 'welcome'

  map.connect ':controller/:action'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
CODE

run "rm public/index.html"

run "cp vendor/plugins/trainyard/test/fixtures/* test/fixtures/"

git :init

file ".gitignore", <<-CODE
.DS_Store
log/*.log
tmp/**/*
config/database.yml
public/javascripts/fckeditor
public/plugin_assets
public/system
CODE
run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"

git :add => "."
git :commit => "-m 'Initial commit'"

