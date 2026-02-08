/* eslint-disable */
// @ts-nocheck
import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import type { NavLinkProps } from 'react-router-dom';
import { NavLink } from 'react-router-dom';

import { isRedesignEnabled } from '../common';

import classes from './redesign.module.scss';

// 注目のハッシュタグの名前をデフォルト値に設定吸うためのWorkaround
// See: https://github.com/formatjs/babel-plugin-react-intl/issues/119#issuecomment-326202499
/* eslint-disable-next-line @typescript-eslint/no-explicit-any */
const DynamicFormattedMessage = (props: any) => {
  return <FormattedMessage {...props} />;
};

export const AccountTabs: FC<{ acct: string; featuredTags?: any }> = ({ acct, featuredTags }) => {
  if (isRedesignEnabled()) {
    return (
      <div className={classes.tabs}>
        <NavLink isActive={isActive} to={`/@${acct}`}>
          <FormattedMessage id='account.activity' defaultMessage='Activity' />
        </NavLink>
        <NavLink exact to={`/@${acct}/media`}>
          <FormattedMessage id='account.media' defaultMessage='Media' />
        </NavLink>
        <NavLink exact to={`/@${acct}/featured`}>
          <FormattedMessage id='account.featured' defaultMessage='Featured' />
        </NavLink>
      </div>
    );
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
        <FormattedMessage
          id='account.portfolio'
          defaultMessage='Portfolio'
        />
      </NavLink>
      {featuredTags && featuredTags.map((featuredTag: any) => {
        const tagName = `${featuredTag.get('name')}`;
        return (
          <NavLink
            key={tagName}
            className='feature_tag_timeline'
            exact
            to={`/@${acct}/tagged/${tagName}`}
          >
            <DynamicFormattedMessage
              id='account.featured_tags'
              defaultMessage={'{tagName}'}
              values={{ tagName: tagName }}
            />
          </NavLink>
        );
      })}
    </div>
  );
};

const isActive: Required<NavLinkProps>['isActive'] = (match, location) =>
  match?.url === location.pathname ||
  (!!match?.url && location.pathname.startsWith(`${match.url}/tagged/`));
