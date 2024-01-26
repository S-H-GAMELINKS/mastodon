import PropTypes from 'prop-types';

import { defineMessages, injectIntl } from 'react-intl';

import ImmutablePureComponent from 'react-immutable-pure-component';

const messages = defineMessages({
  minutes: { id: 'intervals.full.minutes', defaultMessage: '{number, plural, one {# minute} other {# minutes}}' },
  hours: { id: 'intervals.full.hours', defaultMessage: '{number, plural, one {# hour} other {# hours}}' },
  days: { id: 'intervals.full.days', defaultMessage: '{number, plural, one {# day} other {# days}}' },
});

class ShceduleForm extends ImmutablePureComponent {

  static propTypes = {
    schedule: PropTypes.number,
    unavailable: PropTypes.bool,
    onChangeSchedule: PropTypes.func.isRequired,
  };

  handleSelectDuration = e => {
    this.props.onChangeSchedule(e.target.value);
  };

  render () {
    const { intl, schedule } = this.props;

    if (!schedule) {
      return null;
    }

    return (
      <div className='compose-form__poll-wrapper'>
        <div className='compose-form__poll__footer'>
          <select className='compose-form__poll__select__value' value={schedule} onChange={this.handleSelectDuration}>
            <option value={300}>{intl.formatMessage(messages.minutes, { number: 5 })}</option>
            <option value={1800}>{intl.formatMessage(messages.minutes, { number: 30 })}</option>
            <option value={3600}>{intl.formatMessage(messages.hours, { number: 1 })}</option>
            <option value={21600}>{intl.formatMessage(messages.hours, { number: 6 })}</option>
            <option value={43200}>{intl.formatMessage(messages.hours, { number: 12 })}</option>
            <option value={86400}>{intl.formatMessage(messages.days, { number: 1 })}</option>
            <option value={259200}>{intl.formatMessage(messages.days, { number: 3 })}</option>
            <option value={604800}>{intl.formatMessage(messages.days, { number: 7 })}</option>
          </select>
        </div>
      </div>
    );
  }

}

export default injectIntl(ShceduleForm);
