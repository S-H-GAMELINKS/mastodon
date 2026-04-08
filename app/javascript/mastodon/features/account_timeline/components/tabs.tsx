import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import type { NavLinkProps } from 'react-router-dom';
import { NavLink } from 'react-router-dom';

import type { List as ImmutableList } from 'immutable';

import { useAccount } from '@/mastodon/hooks/useAccount';
import { useAccountId } from '@/mastodon/hooks/useAccountId';

import { areCollectionsEnabled } from '../../collections/utils';
import { isRedesignEnabled } from '../common';

import classes from './styles.module.scss';

interface FeaturedTagRecord {
  get(key: 'name'): string | null | undefined;
}

export const AccountTabs: FC<{
  acct?: string;
  featuredTags?: ImmutableList<FeaturedTagRecord> | FeaturedTagRecord[];
}> = ({ acct, featuredTags }) => {
  if (isRedesignEnabled()) {
    return <RedesignTabs />;
  }

  if (!acct) {
    return null;
  }

  return (
    <div className='account__section-headline'>
      <NavLink exact to={`/@${acct}/featured`}>
        <FormattedMessage id='account.featured' defaultMessage='Featured' />
      </NavLink>
      <NavLink exact to={`/@${acct}`}>
        <FormattedMessage id='account.posts' defaultMessage='Posts' />
      </NavLink>
      <NavLink exact to={`/@${acct}/with_replies`}>
        <FormattedMessage
          id='account.posts_with_replies'
          defaultMessage='Posts and replies'
        />
      </NavLink>
      <NavLink exact to={`/@${acct}/media`}>
        <FormattedMessage id='account.media' defaultMessage='Media' />
      </NavLink>
      <NavLink exact to={`/@${acct}/tagged/CreatodonFolio`}>
        <FormattedMessage id='account.portfolio' defaultMessage='Portfolio' />
      </NavLink>
      {featuredTags &&
        Array.from(featuredTags).map((featuredTag) => {
          const tagName = featuredTag.get('name');
          if (!tagName) return null;
          return (
            <NavLink
              key={tagName}
              className='feature_tag_timeline'
              exact
              to={`/@${acct}/tagged/${tagName}`}
            >
              {tagName}
            </NavLink>
          );
        })}
    </div>
  );
};

const isActive: Required<NavLinkProps>['isActive'] = (match, location) =>
  match?.url === location.pathname ||
  (!!match?.url && location.pathname.startsWith(`${match.url}/tagged/`));

const RedesignTabs: FC = () => {
  const accountId = useAccountId();
  const account = useAccount(accountId);

  if (!account) {
    return <hr className={classes.noTabs} />;
  }

  const { acct, show_featured, show_media } = account;
  if (!show_featured && !show_media) {
    return <hr className={classes.noTabs} />;
  }

  return (
    <div className={classes.tabs}>
      <NavLink isActive={isActive} to={`/@${acct}`}>
        <FormattedMessage id='account.activity' defaultMessage='Activity' />
      </NavLink>
      {show_media && (
        <NavLink exact to={`/@${acct}/media`}>
          <FormattedMessage id='account.media' defaultMessage='Media' />
        </NavLink>
      )}
      {show_featured && (
        <NavLink exact to={`/@${acct}/featured`}>
          {areCollectionsEnabled() ? (
            <FormattedMessage
              id='account.featured.collections'
              defaultMessage='Collections'
            />
          ) : (
            <FormattedMessage id='account.featured' defaultMessage='Featured' />
          )}
        </NavLink>
      )}
    </div>
  );
};
