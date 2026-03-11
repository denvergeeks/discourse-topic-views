import Route from "@ember/routing/route";
import { ajax } from "discourse/lib/ajax";

export default class TopicContentViewRoute extends Route {
  model(params) {
    return ajax(`/t/${params.id}/tc.json`);
  }
}
