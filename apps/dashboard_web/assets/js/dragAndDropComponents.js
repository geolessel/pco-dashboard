import { Sortable, Plugins } from "@shopify/draggable"

export default {
  mounted() {
    const sortable = new Sortable(document.querySelectorAll('#sortable-container'), {
      draggable: 'div.sortable',
      mirror: { constrainDimensions: true },
      swapAnimation: {
        duration: 200,
        easingFunction: "ease-in-out",
        horizontal: true
      },
      plugins: [Plugins.SwapAnimation]
    })

    // sortable.on('drag:start', () => console.log('drag:start'))
    // sortable.on('drag:move', () => console.log('drag:move'))
    // sortable.on('drag:stop', () => console.log('drag:stop'))
    sortable.on('sortable:stop', e => {
      const dcId = e.data.dragEvent.data.source.dataset.dcId
      console.log(e.newIndex)
      this.pushEvent("reorder-component", { dc_id: dcId, new_sequence: e.newIndex })
    })
  }
}
