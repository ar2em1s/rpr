import ApplicationController from './application_controller'
import { useIntersection } from 'stimulus-use'

const SERIE_NAME_REGEXP = /(\d.\d)(?!.*YJIT)/i
const PRECISION = 4

const CHART_TYPES = {
  execution_time: 'execution_time',
  memory_usage: 'memory_usage'
}
const CHART_TYPE_VALUE_FORMATTERS = {
  [CHART_TYPES.execution_time]: (value) => Math.round(value),
  [CHART_TYPES.memory_usage]: (value) => Math.round(value / 1024 ** 2)
}
const PLOT_SETTINGS = {
  relative: {
    tooltip: { valuePrefix: 'x', valueSuffix: undefined },
    yAxis: {
      labels: { format: 'x{text}', formatter: undefined },
      plotLines: [{ color: 'red', width: 2, value: 1 }]
    }
  },

  [CHART_TYPES.execution_time]: {
    tooltip: { valuePrefix: undefined, valueSuffix: 'ms' },
    yAxis: {
      labels: {
        format: undefined,
        formatter: function () { return this.value < 1000 ? `${this.value}ms` : `${this.value / 1000}s` }
      },
      plotLines: []
    }
  },

  [CHART_TYPES.memory_usage]: {
    tooltip: { valuePrefix: undefined, valueSuffix: 'mb' },
    yAxis: {
      labels: {
        format: undefined,
        formatter: function () { return this.value < 1000 ? `${this.value}mb` : `${this.value / 1000}gb` }
      },
      plotLines: []
    }
  }
}

export default class extends ApplicationController {
  static targets = ['chart']
  static values = {
    title: String,
    type: String,
    anomalies: Array,
    data: Object
  }

  connect () {
    this.settings = this.defaultSettings
    this.updated = false
    useIntersection(this, { rootMargin: '100% 0px 100% 0px' })
  }

  appear () {
    if (this.updated) return
    if (!this.chart) this._buildChart()

    this._updateChart()
    this.updated = true
  }

  applySettings ({ detail: { relative = false, from = null, to = null } }) {
    this.settings = { relative, filter: { from, to } }
    if (!this.chart || this.noneVisible()) {
      this.updated = false
      return
    }

    this._updateChart()
    this.updated = true
  }

  _filterData (chartData) {
    return Object.entries(chartData).map(
      ([name, data]) => {
        const from = this.settings.filter.from
        const to = this.settings.filter.to

        let lowerIndex = from === null ? undefined : data.findIndex(([dateString, _]) => dateString >= from)
        if (lowerIndex === -1) lowerIndex = data.length

        let upperIndex = to === null ? undefined : data.findLastIndex(([dateString, _]) => dateString <= to)
        if (upperIndex === -1) upperIndex = 0

        const filteredData = data.slice(lowerIndex, upperIndex)
        if (filteredData.length === 0) return null

        return { name, data: filteredData }
      }
    ).filter((data) => data)
  }

  _normalizeData (data) {
    const oldestSerie = data.map((serie) => SERIE_NAME_REGEXP.exec(serie.name)?.input).filter((version) => version)
      .reduce((oldest, version) => (oldest && oldest < version ? oldest : version), null)
    const base = data.find((serie) => serie.name === oldestSerie).data[0][1]

    return data.map((serie) => ({
      name: serie.name,
      data: serie.data.map(([dateString, value]) => [dateString, +((value / base).toPrecision(PRECISION))])
    }))
  }

  _formatData (data) {
    const formatter = CHART_TYPE_VALUE_FORMATTERS[this.typeValue]
    return data.map((serie) => (
      {
        name: serie.name,
        data: serie.data.map(([dateString, value]) => [dateString, formatter(value)])
      }
    )
    )
  }

  _chartData () {
    let data = this._filterData(this.dataValue)
    if (data.length === 0) return []

    data = this.settings.relative ? this._normalizeData(data) : this._formatData(data)

    return data
  }

  _yAxisSettings () {
    return PLOT_SETTINGS[this.settings.relative ? 'relative' : this.typeValue]
  }

  _updateChart () {
    this.chart.update(
      {
        ...this._yAxisSettings(),
        series: this._chartData()
      },
      true,
      true,
      true
    )
  }

  _buildChart () {
    this.chart = window.Highcharts.chart(this.element, {
      title: { text: this.titleValue, align: 'left' },
      noData: { text: 'No data to display' },
      legend: { layout: 'horizontal', align: 'center', verticalAlign: 'bottom' },

      yAxis: {
        title: { text: 'Difference between versions' }
      },

      xAxis: {
        accessibility: { rangeDescription: 'Time' },
        type: 'datetime',
        plotLines: this.anomaliesValue.map((date) => (
          {
            color: 'rgba(250, 212, 0, 0.4)',
            width: 10,
            value: date,
            label: {
              useHTML: true,
              text: `
                  <span

                  >
                    <img
                      src="/rpr/assets/img/icons/warning.svg"
                      width="20"
                      class="cursor-pointer"
                      data-controller="tooltip-target"
                      data-tooltip-target-tooltip-outlet=".tooltip"
                    />
                  </span>
                `,
              rotation: 0,
              verticalAlign: 'top',
              align: 'center',
              x: 0,
              y: -8
            }
          }
        )
        )
      },

      series: []
    })
  }
}
