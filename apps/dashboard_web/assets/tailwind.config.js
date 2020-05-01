module.exports = {
  purge: [],
  theme: {
    extend: {
      colors: {
        alabaster: "#fafafa",
        app: {
          calendar: "#cc4832",
          "check-ins": "#876096",
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
