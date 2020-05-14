module.exports = {
  purge: [
    "../**/*.html.eex",
    "../**/*.html.leex",
    "../**/views/**/*.ex",
    "../**/lives/**/*.ex",
    "./js/**/*.js",
  ],
  theme: {
    extend: {
      colors: {
        product: {
          calendar: "#cc4832",
          checkins: "#876096",
          giving: "#f2b327",
          groups: "#fb7642",
          people: "#5282e5",
          registrations: "#46948d",
          services: "#659630"
        }
      }
    }
  },
  variants: {
    backgroundColor: ["responsive", "hover", "focus", "odd", "even"]
  },
  plugins: []
};
