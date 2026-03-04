# name: discourse-topic-content-view
# about: Display topic cooked content at /topic-content/:id
# version: 0.2.0
# authors: @denvergeeks
# url: https://github.com/denvergeeks/discourse-topic-content-view

enabled_site_setting :topic_content_view_enabled

after_initialize do
  class ::TopicContentViewController < ::ApplicationController
    requires_plugin 'discourse-topic-content-view'
    skip_before_action :check_xhr, :preload_json, :verify_authenticity_token
    layout false

    def show
      topic = find_topic(params[:id])
      raise Discourse::NotFound unless topic
      guardian.ensure_can_see!(topic)

      post = topic.first_post
      raise Discourse::NotFound unless post

      title      = ERB::Util.html_escape(topic.title)
      site_title = ERB::Util.html_escape(SiteSetting.title)
      cooked     = post.cooked
      sheets     = build_stylesheets

      render html: build_html(title, site_title, cooked, sheets).html_safe
    end

    private

    def find_topic(id_or_slug)
      if id_or_slug =~ /\A\d+\z/
        Topic.find_by(id: id_or_slug.to_i)
      else
        Topic.find_by(slug: id_or_slug)
      end
    end

    def build_stylesheets
      tags = []
      tid = theme_id
      [:desktop, :mobile, :publish].each do |target|
        begin
          Stylesheet::Manager.new(theme_id: tid).stylesheet_details(target, 'all').each do |s|
            tags << "<link href=\"#{s[:new_href]}\" media=\"all\" rel=\"stylesheet\">"
          end
        rescue
        end
      end
      tags.join("\n  ")
    end

    def build_html(title, site_title, cooked, sheets)
      <<~HTML
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8">
          <title>#{title} - #{site_title}</title>
          <meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0">
          #{sheets}
          <style>
            body {
              max-width: 900px;
              margin: 0 auto;
              padding: 2em 2em 4em;
              font-family: var(--font-family);
              background: var(--secondary);
              color: var(--primary);
            }
            .topic-content-title {
              font-size: 1.7em;
              font-weight: bold;
              margin-bottom: 1em;
              padding-bottom: 0.5em;
              border-bottom: 1px solid var(--primary-low);
            }
            .cooked img { max-width: 100%; height: auto; }
            .cooked pre {
              background: var(--primary-very-low);
              padding: 1em;
              border-radius: 4px;
              overflow-x: auto;
            }
            .cooked code {
              background: var(--primary-very-low);
              padding: 0.15em 0.4em;
              border-radius: 3px;
            }
            .cooked blockquote {
              border-left: 4px solid var(--primary-low-mid);
              padding-left: 1em;
              margin-left: 0;
            }
          </style>
        </head>
        <body class="topic-content-view">
          <div class="topic-content-container">
            <h1 class="topic-content-title">#{title}</h1>
            <div class="topic-content-body cooked">
              #{cooked}
            </div>
          </div>
        </body>
        </html>
      HTML
    end
  end

  Discourse::Application.routes.append do
    get '/topic-content/:id' => 'topic_content_view#show', constraints: { id: /[^\/]+/ }
  end
end
