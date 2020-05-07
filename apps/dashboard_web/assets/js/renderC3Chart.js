import c3 from "c3"

export default {
  mounted() {
    this.chart = c3.generate({
      bindto: "#chart",
      color: {
        pattern: [
          "#4299e1", // blue-500
          "#48bb78", // green-500
          "#ed8936", // orange-500
          "#ed64a6", // pink-500
          "#ecc94b", // yellow-500
          "#9f7aea", // purple-500
          "#f56565", // red-500
          "#667eea", // indigo-500
          "#a0aec0", // gray-500
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
  },

  updated() {
    this.chart.load({
      columns: JSON.parse(this.el.dataset.chartColumns),
    })
  },
}
