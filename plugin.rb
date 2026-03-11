# name: discourse-topic-content-view
# about: Renders topic title + cooked content only, triggered via ?tc=1 query param
# version: 1.0.0
# authors: @denvergeeks
# url: https://github.com/denvergeeks/discourse-topic-content-view

enabled_site_setting :topic_content_view_enabled

# SCSS adds body.tc-mode which hides all chrome; JS initializer sets it when ?tc=1 present
register_asset "stylesheets/topic-content-view.scss", :desktop

# No custom Rails routes needed — we piggyback on existing /t/:slug/:id Discourse routing.
# The ?tc=1 query param is detected client-side by the initializer.
