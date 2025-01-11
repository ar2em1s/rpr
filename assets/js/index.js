import Highcharts from 'highcharts';
import 'highcharts/modules/accessibility';
import { options as themeOptions } from 'highcharts/themes/high-contrast-dark';

import { Application } from '@hotwired/stimulus';

import ChartController from './controllers/chart_controller';

window.Highcharts = Highcharts;
window.Stimulus = Application.start();

Highcharts.theme = {
  ...themeOptions,
  colors: [
    '#8087E8', '#A3EDBA', '#F19E53', '#6699A1', '#E1D369', '#87B4E7', '#DA6D85', '#BBBAC5',
    '#2B908F', '#90EE7E', '#F45B5B', '#7798BF', '#AAEEEE', '#FF0066', '#55BF3B', '#DF5353',
  ],
  chart: {
    backgroundColor: 'transparent',
  },
};

Highcharts.setOptions(Highcharts.theme);

Stimulus.register('chart', ChartController);
