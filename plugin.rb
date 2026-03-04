# name: discourse-published-pages-cooked
# about: Renders published pages as cooked content instead of static HTML
# version: 0.1.0
# authors: @denvergeeks
# url: https://github.com/denvergeeks/discourse-published-pages-cooked

enabled_site_setting :published_pages_cooked_enabled

after_initialize do
  require_dependency 'published_page'
  
  PublishedPage.class_eval do
    def contents_excerpt
      PrettyText.cook(contents)
    end
  end
  
  # Override the published page controller to use cooked content
  require_dependency 'published_pages_controller'
  
  PublishedPagesController.class_eval do
    def show
      @published_page = PublishedPage.find_by(slug: params[:slug].downcase)
      raise Discourse::NotFound unless @published_page
      
      # Cook the content instead of using static HTML
      @published_page_contents = PrettyText.cook(@published_page.contents)
      
      render :show, layout: 'publish'
    end
  end
end
