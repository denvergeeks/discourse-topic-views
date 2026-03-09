# name: discourse-topic-content-view
# about: Renders a topic's first-post cooked content via a JSON API + Ember route
# version: 1.0.0
# authors: @denvergeeks
# url: https://github.com/denvergeeks/discourse-topic-content-view

enabled_site_setting :topic_content_view_enabled

register_asset "stylesheets/topic-content-view.scss", :desktop

after_initialize do
  # JSON API only — called by the Ember route model() hook as /t/:id/content.json
  # HTML requests to /t/:slug/:id/content fall through to Discourse's catch-all,
  # which serves the Ember SPA shell; Ember then boots and handles routing.
  class ::TopicContentViewController < ::ApplicationController
    requires_plugin 'discourse-topic-content-view'
    skip_before_action :verify_authenticity_token

    def show
      topic_id = params[:id] || params[:slug]
      topic_view = TopicView.new(topic_id, current_user)
      topic = topic_view.topic

      raise Discourse::NotFound unless topic
      guardian.ensure_can_see!(topic)

      post = topic.ordered_posts.first
      raise Discourse::NotFound unless post

      render json: {
        id: topic.id,
        title: topic.title,
        slug: topic.slug,
        category_id: topic.category_id,
        category_name: topic.category&.name,
        tags: topic.tags.map(&:name),
        cooked: post.cooked,
        created_at: post.created_at,
        updated_at: post.updated_at
      }
    rescue Discourse::InvalidAccess
      raise Discourse::NotFound
    end
  end

  Discourse::Application.routes.prepend do
    # Only register JSON format routes — these are called by the Ember route's ajax()
    # Browser direct GETs (no .json) fall through to Discourse's catch-all and boot Ember
    get '/t/:slug/:id/content' => 'topic_content_view#show',
        constraints: { id: /\d+/, slug: /[^\/]+/, format: /json/ }
    get '/t/:id/content' => 'topic_content_view#show',
        constraints: { id: /[^.\/]+/, format: /json/ }
  end
end
