import { Controller } from '@hotwired/stimulus';
import { useIntersection } from 'stimulus-use';

export default class extends Controller {
  static targets = ['chart']
  static values = {
    title: String,
    dates: Array,
    data: Object,
  }

  async connect() {
    const [_, unobserve] = useIntersection(this, { rootMargin: "100% 0px 100% 0px" });
    this.unobserve = unobserve;
  }

  appear(entry, observer) {
   this._buildChart();
   this.unobserve();
  }


  _buildChart() {
    window.Highcharts.chart(this.element, {
      title: {
        text: this.titleValue,
        align: 'left'
      },

      yAxis: {
        title: {
          text: 'Difference between versions'
        },
        labels: {
          format: 'x{text}',
        },
        plotLines: [{
          color: 'red',
          width: 2,
          value: 1,
      }],
      },

      xAxis: {
        accessibility: {
          rangeDescription: 'Time',
        },
        type: 'datetime',
      },

      legend: {
        layout: 'horizontal',
        align: 'center',
        verticalAlign: 'bottom',
      },

      tooltip: {
        valuePrefix: 'x',
      },

      series: Object.entries(this.dataValue).map(([name, data]) => ({ name, data })),
    });
  }
}
