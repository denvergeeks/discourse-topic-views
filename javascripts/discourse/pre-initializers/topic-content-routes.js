import DiscourseURL from "discourse/lib/url";

// Wire the Ember router to recognise /t/:slug/:id/content and /t/:id/content
// The matching route class lives in routes/topic-content-show.js
// The template lives in templates/topic-content-show.hbs
export default {
  name: "topic-content-routes",
  before: "build-resolver",

  initialize(container, app) {
    app.Router.map(function () {
      this.route("topic-content-show", {
        path: "/t/:slug/:id/content",
      });
      this.route("topic-content-show", {
        path: "/t/:id/content",
      });
    });
  },
};
