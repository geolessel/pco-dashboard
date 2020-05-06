import c3 from "c3"

export default {
  mounted() {
    this.chart = c3.generate({
      bindto: "#chart",
      data: {
        columns: JSON.parse(this.el.dataset.chartColumns),
      },
    })

    window.chart = this.chart
  },

  updated() {
    this.chart.load({
      columns: JSON.parse(this.el.dataset.chartColumns),
    })
  },
}
