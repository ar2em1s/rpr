import ApplicationController from './application_controller'
import { useHover } from 'stimulus-use'

export default class extends ApplicationController {
  static outlets = ['tooltip']

  connect () {
    useHover(this, { element: this.element })
  }

  mouseEnter () {
    this._toggleTooltip({ visible: true })
  }

  mouseLeave () {
    this._toggleTooltip({ visible: false })
  }

  _toggleTooltip ({ visible }) {
    const { top, left } = this.element.getBoundingClientRect()
    this.tooltipOutlet.toggleVisibility(
      {
        details: {
          visible,
          y: Math.round(top + window.scrollY),
          x: Math.round(left + window.scrollX)
        }
      }
    )
  }
}
