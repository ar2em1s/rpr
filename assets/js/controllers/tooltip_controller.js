import ApplicationController from './application_controller'

export default class extends ApplicationController {
  static classes = ['hidden']
  static values = {
    moveBottom: Number
  }

  toggleVisibility ({ details: { visible, x, y } }) {
    this.element.classList.toggle(this.hiddenClass, !visible)
    if (visible) {
      const { width } = this.element.getBoundingClientRect()
      this.element.style.left = `${Math.round(x - (width / 2))}px`
      this.element.style.top = `${y + this.moveBottomValue}px`
    }
  }
}
