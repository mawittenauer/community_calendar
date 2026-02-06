// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import { mountCommunityCalendar } from "./community_calendar";

document.addEventListener("DOMContentLoaded", () => {
  mountCommunityCalendar("community-calendar-root");
});
