import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ActionBar from './action_bar';
import Avatar from '../../../components/avatar';
import { Link } from 'react-router-dom';
import IconButton from '../../../components/icon_button';
import { FormattedMessage } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';

export default class NavigationBar extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    onLogout: PropTypes.func.isRequired,
    onClose: PropTypes.func,
  };

  render () {
    const displayNameHtml = { __html: this.props.account.get('display_name_html') };

    return (
      <div className='navigation-bar'>
        <Link to={`/@${this.props.account.get('acct')}`}>
          <span style={{ display: 'none' }}>{this.props.account.get('acct')}</span>
          <Avatar account={this.props.account} size={46} />
        </Link>

        <div className='navigation-bar__profile'>
          <strong dangerouslySetInnerHTML={displayNameHtml} />
          <Link to={`/@${this.props.account.get('acct')}`}>
            <span className='navigation-bar__profile-account'>@{this.props.account.get('acct')}</span>
          </Link>
        </div>

        <div className='navigation-bar__actions'>
          <IconButton className='close' title='' icon='close' onClick={this.props.onClose} />
          <ActionBar account={this.props.account} onLogout={this.props.onLogout} />
        </div>
      </div>
    );
  }

}
