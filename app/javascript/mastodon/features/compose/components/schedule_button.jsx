import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { defineMessages, injectIntl } from 'react-intl';

import { ReactComponent as CalendarIcon } from '@/material-icons/400-24px/calendar_add_on.svg?react';

import { IconButton } from '../../../components/icon_button';

const messages = defineMessages({
  add_schedule: { id: 'schedule_button.add_schedule', defaultMessage: 'Add schedule' },
  remove_schedule: { id: 'schedule_button.remove_schedule', defaultMessage: 'Remove schedule' },
});

const iconStyle = {
  height: null,
  lineHeight: '27px',
};

class ScheduleButton extends PureComponent {

  static propTypes = {
    disabled: PropTypes.bool,
    unavailable: PropTypes.bool,
    active: PropTypes.bool,
    onClick: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleClick = () => {
    this.props.onClick();
  };

  render () {
    const { intl, active, unavailable, disabled } = this.props;

    if (unavailable) {
      return null;
    }

    return (
      <div className='compose-form__schedule-button'>
        <IconButton
          icon='calendar'
          iconComponent={CalendarIcon}
          title={intl.formatMessage(active ? messages.remove_schedule : messages.add_schedule)}
          disabled={disabled}
          onClick={this.handleClick}
          className={`compose-form__schedule-button-icon ${active ? 'active' : ''}`}
          size={18}
          inverted
          style={iconStyle}
        />
      </div>
    );
  }

}

export default injectIntl(ScheduleButton);
