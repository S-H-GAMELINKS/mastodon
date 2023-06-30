import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { defineMessages, injectIntl } from 'react-intl';

import { IconButton } from '../../../components/icon_button';

const messages = defineMessages({
  add_delete_schedule: { id: 'delete_schedule_button.add_delete_schedule', defaultMessage: 'Add delete schedule' },
  remove_delete_schedule: { id: 'delete_schedule_button.remove_delete_schedule', defaultMessage: 'Remove delete schedule' },
});

const iconStyle = {
  height: null,
  lineHeight: '27px',
};

class DeleteScheduleButton extends PureComponent {

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
      <div className='compose-form__delete-schedule-button'>
        <IconButton
          icon='trash'
          title={intl.formatMessage(active ? messages.remove_delete_schedule : messages.add_delete_schedule)}
          disabled={disabled}
          onClick={this.handleClick}
          className={`compose-form__delete-schedule-button-icon ${active ? 'active' : ''}`}
          size={18}
          inverted
          style={iconStyle}
        />
      </div>
    );
  }

}

export default injectIntl(DeleteScheduleButton);
