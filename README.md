Sinicum
=======

[![Build Status](https://travis-ci.org/dievision/sinicum.svg?branch=master)](https://travis-ci.org/dievision/sinicum) [![Code Climate](https://codeclimate.com/github/dievision/sinicum.png)](https://codeclimate.com/github/dievision/sinicum)

Use content created in Magnolia CMS in your Ruby/Rails application. Sinicum works as a Ruby Client for the REST API provided by [Sinicum Server](http://github.com/dievision/sinicum-server). Basically it is an "Object-Document-Mapper" mapping the JSON-responses to Ruby objects. It is fully integrated into Rails and lets Controller handle the requests to Magnolia CMS.

Sinicum has been used internally at [Dievision](http://www.dievision.de) for quite some time and has only recently been open sourced. We think it’s a great way to build Rails Applications in concert with a really advanced Content Management System. If you are interested in the concept but have trouble getting started, [please let us know](mailto: sinicum@dievision.de). We are happy to help and interested in your pain points.

We plan to expand the documentation and add more examples until mid-May 2014.

So dive in and get started!

# Installation

Add this line to your application's Gemfile:

    gem 'sinicum'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sinicum


# Installation for Rails

### Requirements
Please make sure to have [Maven 3.x](http://maven.apache.org) and PostgreSQL installed
on your system. If you are using OS X and Homebrew, run

    $ brew install maven
    $ brew install postgresql
    
By default, we will prepare Magnolia CMS with a postgres database. Please create the database you have entered in the installation step following.

Please note that all template files installed in the installation step are using haml. You can install this Gem by adding

    gem 'haml-rails'

to your Gemfile.

In order to use the Sinicum Imaging functionality, you will need to install [Imagemagick](http://www.imagemagick.org/) on your machine. If you are using OS X and Homebrew you can do this with

    $ brew install imagemagick

##### Please note: Sinicum works with Rails >= 3.2, but we recommend Rails 4. 

### Installation
In order to set up Sinicum in a Rails project, you need to add `sinicum-runner` to your Gemfile:

    gem 'sinicum-runner'

Then set up the necessary files by running

    $ rails generate sinicum:install

You will be asked a few questions. After this all necessary files for a
Magnolia Maven Project will be generated and your Rails project will
be configured. The generator will ask you, if you would like to have some sample templates installed. We highly recommend you to answer with `yes`.

At this point, please remember to create your database, you specifed before. (as a quick reminder: `createdb` and `createuser` for psql).

Then start up Magnolia CMS with

    $ bundle exec sinicum-runner

and Rails with

    $ rails server

You can visit the Magnolia installation at http://localhost:8080. Rails is accessible as usual at http://localhost:3000.

#### Important Note:

The first thing you should do after logging into Magnolia CMS with the credentials `superuser`:`superuser` is to go to `Security` and edit the `superuser` in the `System Users` tab. You need to add the role sinicum-server manually, to be able to access Sinicum Server from rails.

# Getting Started

## Basic Magnolia CMS knowledge is highly recommended

If you want to use Sinicum with all its features you will need to learn some basics of Magnolia CMS.
It is always a good idea to have a look at the [Magnolia CMS Documentation](http://documentation.magnolia-cms.com/display/DOCS/Magnolia+5+Documentation).

To just use it as a CMS with Rails we provide you with all information you'll need.

## Templating

Magnolia CMS provides three types of templates:

- `Page` is the highest level template. It renders a page. Pages are the building blocks of a site hierarchy. They create a tree hierarchy of parent pages and child pages that you can see in Magnolia AdminCentral and visualize to site visitors in a sitemap and in navigation. Each part of a URI is also a page. For example, example.com/products/bicycles would have at least three pages: home page, products section page, and a bicycles page.

- `Area` is the next level down. Pages consist of areas which can consist of further areas or components. Areas have two purposes: they structure the page and control what components editors can place inside the area. This makes area the most powerful template. It ensures consistency across the site. Areas also provide repeatability. An area template typically loops through the components inside it, rendering the components one by one. Most areas are rendered with containing div elements in the generated HTML so you can control their layout on the page with CSS.

- `Component` is the smallest block of content that editors can edit, delete and move as a single unit. Think of a component as content that belongs together. At its simplest, a component may be a heading and some text that belong together. However, it can contain almost anything: text and a related image, list of links, teased content from another page and so on.

(Taken from [Magnolia CMS Documentation](http://documentation.magnolia-cms.com/display/DOCS/My+first+template))

## Nodes

As Magnolia CMS uses the [Apache Jackrabbit](https://jackrabbit.apache.org/) implementation of the [Java Content Repository](https://en.wikipedia.org/wiki/Content_repository_API_for_Java) standard as its internal data format. JCR-Nodes are exposed in Sincium as instances of the class `Sinicum::Jcr::Node`.

### Sinicum::Jcr::Node
This class follows common Ruby/ActiveRecord semantics.

#### Finders and queries

Finders are included with the `NodeQueries` module.

##### find_by_path(workspace, path)
    Sinicum::Jcr::Node.find_by_path(:website, '/en/page/subpage')
    
##### find_by_uuid(workspace, uuid)
    Sinicum::Jcr::Node.find_by_uuid(:website, 'dd793410-89d7-41f3-8cc2-7654c9e8e72b')
    
##### query(workspace, language, query, parameters = nil, options = {})
    Sinicum::Jcr::Node.query(:website, :xpath, '//en/page/subpage')
Valid options are:
- limit
- offset

Valid languages are:
- xpath
- jcr-sql2
- sql

You can get a quick overview at the [JCR-Query cheat sheet](http://wiki.magnolia-cms.com/display/WIKI/JCR+Query+Cheat+Sheet)

#### Properties

Once a node is retrieved you can access various parameters defined by Magnolia CMS:

- jcr_path
- jcr_name
- jcr_primary_type
- jcr_workspace

You can use [] to access all custom defined parameters (defined by you in the Magnolia CMS Template definition). So it would be possible to retrieve a press_date with

    node = Sinicum::Jcr::Node.find_by_path(:website, '/en/page/press/article01')
    node[:press_date]

Since JCR Nodes are stored in a tree structure, you can also access the children and the parent.

    node.children
    node.parent
    
#### Mapping JCR objects to Ruby classes

All JCR nodes in Magnolia are mapped to `Sinicum::Jcr::Node` objects with the help of `TypeTranslators`. This is somewhat of an analogy to ActiveRecord::Base. But depending on various factors, Sinicum tries to find a better matching subclass of Node. The rules are quite flexible and can be modified (the default rules can be found in the `Sinicum::Jcr::TypeTranslators` module) and are probably best explained in an example.

Templates are configured in Magnolia CMS and then mapped to Rails.
This is done . (A good example is the [ComponentTranslator](https://github.com/dievision/sinicum/blob/master/lib/sinicum/jcr/type_translators/component_translator.rb). It checks the template of a component and tries to initialise a matching class.

##### Example:
 
A component `article` has the template 'my_project:components/article' (generated in the example templates).
It is now accessed in a content area and a the ComponentTranslator tries to constantize the templatename. The resulting class would be `MyProject::Components::Article`.

    module MyProject
      module Components
        class Article < Sinicum::Jcr::Node
            
        end
      end
    end

## Controllers

Sinicum provides convenience functionality to let Rails Controller handle requests to Magnolia CMS and to map Magnolia CMS template definitions to Rails layout files. This is done by including the `Sinicum::ControllerBase`
    
    class ContentController < ApplicationController
      include Sinicum::ControllerBase
    end
    
Best practice would be to use the generated `ContentController` as the base Controller for all Controllers, that should have access to Magnolia CMS data.
ControllerBase adds a few filters to the controller and overrides the render method so that by default the content from the Magnolia CMS page matching the path of the Rails request is fetched and pushed upon a node stack.

##### Example:
Let's say we have a basic blog with posts and we want to handle the different posts in Magnolia CMS. They should be located under the path `/blog/posts` and have the mgnl:template `myProject:pages/blog_entry`
We need two things first.
    
    class BlogController < ContentController
      
      def posts
        @posts = Sinicum::Jcr::Node.query(:website, :sql, 'select * from mgnl:page where jcr:path like '/blog/posts/%'
        render
      end
    end
and a matching route
    
    get '/blog/posts', to: 'blog#posts'

The call to render will now try to find a matching view in `views/blog` (e.g. `posts.html.haml`) and use the layout in `views/layouts/my_project/blog_entry.html.haml`.

### Redirect Template

Sometimes you want to redirect from a specific page in Magnolia CMS to another page. Normally you would need to set up a route and a redirect action. Since this can lead to errors (e.g. when the page name is changed in magnolia, or the page is moved), Sinicum handles redirects on a template base with the `redirect` template. It is already generated for you with `rails g sinicum:install`.

If you select the `redirect` template in Magnolia CMS for a page, you can set its `redirect_link` in the page preferences. It will be saved as a `uuid-string` so you can change the location of the target page or rename it and the redirect will still work.

## Imaging

Sinicum makes image handling very easy. You can define several styles for your images you want to render by adding them to `config/imaging.yml` (a default one will be generated during ` rails g sinicum:install`).

    renderer:
      default:
        render_type: resize_crop
        format: jpeg
        x: 307
        y: 202
        hires_factor: 2

The render_type can be

- resize_crop - Resizes an image to an exact given size and crops anything else
- resize_max - Resizes an image to a predefined maximum size
- default - Simple converter that simply serves a copy of the original file

A new feature (available since v0.9.0) introduces the configuration of the Imaging Module via apps. You have to define a few values in the `imaging.yml` (default values for DAM are already generated) and you can basically use Imaging for the asset handling of all you content apps.

    apps:
      videos:
        imaging_prefix: "/videofiles"
        magnolia_prefix: "/videos"
        workspace: "videos"
        node_type: "mgnl:video"
      dam:
        imaging_prefix: "/damfiles"
        magnolia_prefix: "/dam"
        workspace: "dam"
        node_type: "mgnl:asset"

In this example, we have configured two apps that will be able to serve assets via the Imaging Module.

- imaging_prefix - Is the prefix that the imaging path will have
- magnolia_prefix - Is the prefix that the original path from magnolia has
- workspace - The workspace of the content app
- node_type - The node_type that has been configured for nodes from the content app

This is all you need to know for a quick start. More details will be added soon.

## Helpers

To make it as easy as possible for you to navigate your way around the Magnolia CMS content wrapped in `Sinicum::Jcr::Node`, Sinicum provides you with some neat helper methods. They are split up in two helper modules: `MgnlHelper` and `MgnlImageHelper`. Both are included in `MgnlHelper5` which is automatically included in your ´ApplicationHelper`.

### MgnlHelper

#### mgnl_content_data

You can always access the current node pushed by the Controller by calling `mgnl_content_data`.

#### mgnl_value(key)

This method will access a property of the node that sits on top of the node stack.

    mgnl_value :title

#### mgnl_push(key_or_object, options = {})

This method is best explained by an example:

    mgnl_value :title
    mgnl_push :contact_link, workspace: 'contacts' do
      "#{mgnl_value :firstName} #{mgnl_value :lastName}"

In the first line of the example, we print out the property title of the node that was pushed on top of the stack by the controller. Then we have a property called `contact_link` which is a uuid-string. We want to access `firstName` and `lastName` of this linked node with the mgnl_value helper method.
In order to do this, we need to push the linked node onto the node stack. This done by this function. At the end of the block the node will be removed and the previous node is on top of the node stack again.

#### mgnl_path(key_or_object, options = {})

This method returns the path for an object. If the object is a Sinicum::Jcr::Node it will return its path. If the object is a uuid-string, it will be resolved to the matching node and then its path will be returned.

    link_to 'Redirect', mgnl_path(:redirect_link)

You can pass :workspace as an option, which will tell Sinicum where to look for your node (`website` is the default workspace).
    
#### mgnl_link(key_or_object, options = {}, &block)

`mgnl_link` does basically the same as `mgnl_path` except that it renders a `link_to` for you and that you can pass a normal string as `key_or_object`.

    mgnl_link :link, class: "big-link" do
      'Click me'

#### mgnl_exists?(key_or_object, options = {})

`mgnl_exists?` is a good method to check for the existence of a Magnolia CMS object. It returns true or false.

#### mgnl_meta(options = {})

Displays the `<title>` tag and the `<meta>` tags for a page. The attributes must follow the default naming conventions.
* title
* meta_title
* meta_description
* meta_keywords
* meta_noindex
* meta_search_weight
* meta_search_boost

Returns a String with all necessary `<meta>` tags and the `<title>` tag.

#### mgnl_navigation(base_node_or_path, type, options = {}, &block)

`mgnl_navigation` iterates over an array with `NavigationElement` instances. You can pass a base node and then select the type of navigation you want (currently only `:children` or`:parents` are supported though). For the options, you can pass on a hash with `{ depth: 2 }`. If you pass on a block, you will get a `NavigationElement` and the corresponding `NavigationStatus`.

Let's show you with an example:

    mgnl_navigation( '/blog', :children, depth: 1).each do |e,s|
      link_to e.title, e.path

`NavigationStatus` provides meta-information about the status of a `NavigationElement` in the iteration.

 - `first?`
 - `last?`
 - `size`
 - `count`

### MgnlImageHelper

#### mgnl_asset_path(key_or_object = nil, options = {})

Basically a call to `mgnl_path` with the default workspace `:dam`.

#### mgnl_img(key_or_object, options = {})

`mgnl_img` queries the Magnolia CMS DAM for the given link or uuid and returns it wrapped in ready-to-use `<img>` tag. It takes several options:

 - `:renderer` - this is the renderer from the imaging.yml file
 - `:width`
 - `:height`
 - `:src`
 - `:alt`

An example would be:

    mgnl_img :image, renderer: "big_image"

## Questions or problems?

If you have any issues with Sinicum which you cannot solve by reading the readme, please add an issue on GitHub or write us an email at [sinicum@dievision.de](mailto:sinicum@dievision.de).
We will be happy to get you started!

## Contributing

Contributions are more than welcome! Feel free to fork Sinicum and submit a new feature-branch as pull request. If you encounter any bugs or non expected behaviour, please open a GitHub issue or write an email.
