import c3 from "c3"

export default {
  mounted() {
    this.chart = c3.generate({
      bindto: "#chart",
      color: {
        pattern: [
          "#a0aec0", // gray-500
          "#4299e1", // blue-500
        ]
      },
      data: {
        columns: JSON.parse(this.el.dataset.chartColumns),
      },
      point: {
        r: 2
      },
      grid: {
        x: {
          show: true
        },
        y: {
          show: true
        },
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
