# name: discourse-topic-content-view
# about: Renders topic title + cooked content inside Discourse SPA (all theme/plugin CSS+JS active)
# version: 1.0.0
# authors: @denvergeeks
# url: https://github.com/denvergeeks/discourse-topic-content-view

enabled_site_setting :topic_content_view_enabled

register_asset "stylesheets/topic-content-view.scss", :desktop

after_initialize do
  # JSON API — called by the Ember route's model() hook via ajax("/tc/:id.json")
  class ::TopicContentViewController < ::ApplicationController
    requires_plugin 'discourse-topic-content-view'
    skip_before_action :verify_authenticity_token

    def show
      topic_id = params[:id]
      begin
        topic_view = TopicView.new(topic_id, current_user)
      rescue Discourse::NotFound, Discourse::InvalidAccess
        return render json: { error: 'not_found' }, status: 404
      end

      topic = topic_view.topic
      return render json: { error: 'not_found' }, status: 404 unless topic

      begin
        guardian.ensure_can_see!(topic)
      rescue Discourse::InvalidAccess
        return render json: { error: 'not_found' }, status: 404
      end

      post = topic.ordered_posts.first
      return render json: { error: 'not_found' }, status: 404 unless post

      render json: {
        id:            topic.id,
        title:         topic.title,
        slug:          topic.slug,
        category_id:   topic.category_id,
        category_name: topic.category&.name,
        tags:          topic.tags.map(&:name),
        cooked:        post.cooked
      }
    end
  end

  Discourse::Application.routes.prepend do
    # JSON API — Ember ajax calls /tc/:id.json
    get '/tc/:id' => 'topic_content_view#show',
        constraints: { id: /\d+/ },
        format: 'json'

    # SPA shell — route all browser /tc/* requests to list#index
    # which renders the standard Discourse SPA HTML (Ember then handles the URL)
    get '/tc/*path' => 'list#index'
  end
end
