import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  get defaultSettings () {
    const urlParams = new URLSearchParams(window.location.search)

    return {
      relative: ['true', null].includes(urlParams.get('relative')),
      filter: {
        from: urlParams.get('from') || null,
        to: urlParams.get('to') || null
      }
    }
  }
}
