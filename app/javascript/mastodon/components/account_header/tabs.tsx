import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import type { NavLinkProps } from 'react-router-dom';

import type { List as ImmutableList } from 'immutable';

import { useAccount } from '@/mastodon/hooks/useAccount';
import { useAccountId } from '@/mastodon/hooks/useAccountId';

import { TabLink, TabList } from '../tab_list';

import classes from './styles.module.scss';

interface FeaturedTagRecord {
  get(key: 'name'): string | null | undefined;
}

const isActive: Required<NavLinkProps>['isActive'] = (match, location) =>
  match?.url === location.pathname ||
  (!!match?.url && location.pathname.startsWith(`${match.url}/tagged/`));

export const AccountTabs: FC<{
  acct?: string;
  featuredTags?: ImmutableList<FeaturedTagRecord> | FeaturedTagRecord[];
}> = ({ acct, featuredTags }) => {
  const accountId = useAccountId();
  const account = useAccount(accountId);
  const featuredTagItems = featuredTags ? Array.from(featuredTags) : [];

  if (!account) {
    return <hr className={classes.noTabs} />;
  }

  const accountAcct = acct ?? account.acct;
  const { show_featured, show_media } = account;

  if (!accountAcct) {
    return null;
  }

  if (!show_featured && !show_media && featuredTagItems.length === 0) {
    return <hr className={classes.noTabs} />;
  }

  return (
    <TabList>
      <TabLink isActive={isActive} to={`/@${accountAcct}`}>
        <FormattedMessage id='account.activity' defaultMessage='Activity' />
      </TabLink>
      {show_media && (
        <TabLink exact to={`/@${accountAcct}/media`}>
          <FormattedMessage id='account.media' defaultMessage='Media' />
        </TabLink>
      )}
      {show_featured && (
        <TabLink exact to={`/@${accountAcct}/featured`}>
          <FormattedMessage id='account.featured' defaultMessage='Featured' />
        </TabLink>
      )}
      <TabLink exact to={`/@${accountAcct}/tagged/CreatodonFolio`}>
        <FormattedMessage id='account.portfolio' defaultMessage='Portfolio' />
      </TabLink>
      {featuredTagItems.map((featuredTag) => {
        const tagName = featuredTag.get('name');
        if (!tagName) return null;

        return (
          <TabLink
            key={tagName}
            className='feature_tag_timeline'
            exact
            to={`/@${accountAcct}/tagged/${tagName}`}
          >
            {tagName}
          </TabLink>
        );
      })}
    </TabList>
  );
};
