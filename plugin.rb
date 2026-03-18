# name: discourse-topic-views
# about: Renders topic title + cooked content only, triggered via ?tcv=1 query param
# version: 1.0.0
# authors: @denvergeeks
# url: https://github.com/denvergeeks/discourse-topic-views

enabled_site_setting :topic_views_enabled

# SCSS adds body.tcv-mode which hides all chrome; JS initializer sets it when ?tcv=1 present
register_asset "stylesheets/topic-views.scss", :desktop

# No custom Rails routes needed — we piggyback on existing /t/:slug/:id Discourse routing.
# The ?tcv=1 query param is detected client-side by the initializer.
