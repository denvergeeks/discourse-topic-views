// Register Ember routes for the topic content view.
// Uses /tc/ prefix to avoid collision with Discourse's built-in /t/:slug/:id topic routes.
export default {
  name: "topic-content-routes",
  before: "build-resolver",

  initialize(container, app) {
    app.Router.map(function () {
      this.route("topic-content-show", {
        path: "/tc/:slug/:id",
      });
      this.route("topic-content-show", {
        path: "/tc/:id",
      });
    });
  },
};
