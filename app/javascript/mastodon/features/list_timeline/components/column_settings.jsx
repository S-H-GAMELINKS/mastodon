import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { FormattedMessage } from 'react-intl';

import ImmutablePropTypes from 'react-immutable-proptypes';

import SettingToggle from '../../notifications/components/setting_toggle';

class ColumnSettings extends PureComponent {

  static propTypes = {
    settings: ImmutablePropTypes.map.isRequired,
    onChange: PropTypes.func.isRequired,
  };

  render () {
    const { settings, onChange } = this.props;

    return (
      <div className='column-settings'>
        <section>
          <div className='column-settings__row'>
            <SettingToggle settings={settings} settingPath={['other', 'onlyMedia']} onChange={onChange} label={<FormattedMessage id='community.column_settings.media_only' defaultMessage='Media only' />} />
          </div>
        </section>
      </div>
    );
  }

}

export default ColumnSettings;