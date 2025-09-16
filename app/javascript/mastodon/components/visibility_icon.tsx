import { defineMessages, useIntl } from 'react-intl';

import AlternateEmailIcon from '@/material-icons/400-24px/alternate_email.svg?react';
import LockIcon from '@/material-icons/400-24px/lock.svg?react';
import MeowIcon from '@/material-icons/400-24px/pets.svg?react';
import PublicIcon from '@/material-icons/400-24px/public.svg?react';
import QuietTimeIcon from '@/material-icons/400-24px/quiet_time.svg?react';
import PortfolioIcon from '@/material-icons/400-24px/work_history.svg?react';
import type { StatusVisibility } from 'mastodon/models/status';

import { Icon } from './icon';

const messages = defineMessages({
  public_short: { id: 'privacy.public.short', defaultMessage: 'Public' },
  portfolio_short: {
    id: 'privacy.portfolio.short',
    defaultMessage: 'ポートフォリオとして公開されます',
  },
  unlisted_short: {
    id: 'privacy.unlisted.short',
    defaultMessage: 'Quiet public',
  },
  private_short: {
    id: 'privacy.private.short',
    defaultMessage: 'Followers',
  },
  nyan_short: {
    id: 'privacy.nyan.short',
    defaultMessage: 'Replace content to にゃーん',
  },
  direct_short: {
    id: 'privacy.direct.short',
    defaultMessage: 'Specific people',
  },
});

export const VisibilityIcon: React.FC<{ visibility: StatusVisibility }> = ({
  visibility,
}) => {
  const intl = useIntl();

  const visibilityIconInfo = {
    public: {
      icon: 'globe',
      iconComponent: PublicIcon,
      text: intl.formatMessage(messages.public_short),
    },
    portfolio: {
      icon: 'work_history',
      iconComponent: PortfolioIcon,
      text: intl.formatMessage(messages.portfolio_short),
    },
    unlisted: {
      icon: 'unlock',
      iconComponent: QuietTimeIcon,
      text: intl.formatMessage(messages.unlisted_short),
    },
    private: {
      icon: 'lock',
      iconComponent: LockIcon,
      text: intl.formatMessage(messages.private_short),
    },
    nyan: {
      icon: 'pets',
      iconComponent: MeowIcon,
      text: intl.formatMessage(messages.nyan_short),
    },
    direct: {
      icon: 'at',
      iconComponent: AlternateEmailIcon,
      text: intl.formatMessage(messages.direct_short),
    },
  };

  const visibilityIcon = visibilityIconInfo[visibility];

  return (
    <Icon
      id={visibilityIcon.icon}
      icon={visibilityIcon.iconComponent}
      aria-label={visibilityIcon.text}
    />
  );
};
