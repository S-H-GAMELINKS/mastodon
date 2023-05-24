import PropTypes from 'prop-types';

import { FormattedMessage } from 'react-intl';

import { connect } from 'react-redux';

import { me } from 'mastodon/initial_state';
import { HASHTAG_PATTERN_REGEX } from 'mastodon/utils/hashtags';

import Warning from '../components/warning';

const mapStateToProps = state => ({
  needsLockWarning: state.getIn(['compose', 'privacy']) === 'private' && !state.getIn(['accounts', me, 'locked']),
  hashtagWarning: state.getIn(['compose', 'privacy']) !== 'public' && HASHTAG_PATTERN_REGEX.test(state.getIn(['compose', 'text'])),
  nyanWarning: state.getIn(['compose', 'privacy']) === 'nyan',
  portfolioWarning: state.getIn(['compose', 'privacy']) === 'portfolio',
  directMessageWarning: state.getIn(['compose', 'privacy']) === 'direct',
});

const WarningWrapper = ({ needsLockWarning, hashtagWarning, nyanWarning, portfolioWarning, directMessageWarning }) => {
  if (portfolioWarning) {
    return <Warning message={<FormattedMessage id='compose_form.portfolio_warning' defaultMessage='公開範囲が「ポートフォリオ」になっています。ここで入力した内容はすべてアカウントの「ポートフォリオ」欄に表示されます' />} />;
  }

  if (nyanWarning) {
    return <Warning message={<FormattedMessage id='compose_form.nyan_warning' defaultMessage='公開範囲が「にゃーん」になっています。ここで入力した内容はすべて「にゃーん」に置き換えられます' />} />;
  }

  if (needsLockWarning) {
    return <Warning message={<FormattedMessage id='compose_form.lock_disclaimer' defaultMessage='Your account is not {locked}. Anyone can follow you to view your follower-only posts.' values={{ locked: <a href='/settings/profile'><FormattedMessage id='compose_form.lock_disclaimer.lock' defaultMessage='locked' /></a> }} />} />;
  }

  if (hashtagWarning) {
    return <Warning message={<FormattedMessage id='compose_form.hashtag_warning' defaultMessage="This post won't be listed under any hashtag as it is unlisted. Only public posts can be searched by hashtag." />} />;
  }

  if (directMessageWarning) {
    const message = (
      <span>
        <FormattedMessage id='compose_form.encryption_warning' defaultMessage='Posts on Mastodon are not end-to-end encrypted. Do not share any dangerous information over Mastodon.' /> <a href='/terms' target='_blank'><FormattedMessage id='compose_form.direct_message_warning_learn_more' defaultMessage='Learn more' /></a>
      </span>
    );

    return <Warning message={message} />;
  }

  return null;
};

WarningWrapper.propTypes = {
  needsLockWarning: PropTypes.bool,
  hashtagWarning: PropTypes.bool,
  nyanWarning: PropTypes.bool,
  portfolioWarning: PropTypes.bool,
  directMessageWarning: PropTypes.bool,
};

export default connect(mapStateToProps)(WarningWrapper);
