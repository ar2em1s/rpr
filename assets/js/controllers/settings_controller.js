import ApplicationController from './application_controller'

export default class extends ApplicationController {
  static targets = ['from', 'to', 'normalize']

  connect () {
    const defaultSettings = this.defaultSettings
    if (defaultSettings.filter.from) this.fromTarget.value = defaultSettings.filter.from
    if (defaultSettings.filter.to) this.toTarget.value = defaultSettings.filter.to
    this.normalizeTarget.checked = defaultSettings.normalize
  }

  save () {
    const settings = {}
    if (this.fromTarget.value) settings.from = this.fromTarget.value
    if (this.toTarget.value) settings.to = this.toTarget.value
    settings.normalize = this.normalizeTarget.checked
    const params = new URLSearchParams(settings)

    window.history.replaceState(null, '', `/rpr/?${params}${window.location.hash}`)
    this.dispatch('changed', { detail: settings, bubbles: true })
  }
}
