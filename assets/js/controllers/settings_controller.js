import ApplicationController from './application_controller'

export default class extends ApplicationController {
  static targets = ['from', 'to', 'relative']

  connect () {
    const defaultSettings = this.defaultSettings
    if (defaultSettings.filter.from) this.fromTarget.value = defaultSettings.filter.from
    if (defaultSettings.filter.to) this.toTarget.value = defaultSettings.filter.to
    this.relativeTarget.checked = defaultSettings.relative
  }

  save () {
    const settings = {}
    if (this.fromTarget.value) settings.from = this.fromTarget.value
    if (this.toTarget.value) settings.to = this.toTarget.value
    settings.relative = this.relativeTarget.checked
    const params = new URLSearchParams(settings)

    window.history.replaceState(null, '', `/rpr/?${params}${window.location.hash}`)
    this.dispatch('changed', { detail: settings, bubbles: true })
  }
}
