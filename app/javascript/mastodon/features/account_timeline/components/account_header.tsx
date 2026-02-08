/* eslint-disable */
// @ts-nocheck
import type { RefCallback } from 'react';
import { useCallback, useEffect, useState } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { Helmet } from 'react-helmet';

import { AccountBio } from '@/mastodon/components/account_bio';
import { AnimateEmojiProvider } from '@/mastodon/components/emoji/context';
import { openModal } from 'mastodon/actions/modal';
import { Avatar } from 'mastodon/components/avatar';
import { AccountNote } from 'mastodon/features/account/components/account_note';
import FollowRequestNoteContainer from 'mastodon/features/account/containers/follow_request_note_container';
import { autoPlayGif, me, domain as localDomain } from 'mastodon/initial_state';
import type { Account } from 'mastodon/models/account';
import type { MenuItem } from 'mastodon/models/dropdown_menu';
import {
  PERMISSION_MANAGE_USERS,
  PERMISSION_MANAGE_FEDERATION,
} from 'mastodon/permissions';
import {
  getAccountHidden,
  getAccountFeaturedTags,
} from 'mastodon/selectors/accounts';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

import { isRedesignEnabled } from '../common';

import { AccountName } from './account_name';
import { AccountBadges } from './badges';
import { AccountButtons } from './buttons';
import { FamiliarFollowers } from './familiar_followers';
import { AccountHeaderFields } from './fields';
import { AccountInfo } from './info';
import { MemorialNote } from './memorial_note';
import { MovedNote } from './moved_note';
import { AccountNote as AccountNoteRedesign } from './note';
import { AccountNumberFields } from './number_fields';
import redesignClasses from './redesign.module.scss';
import { AccountTabs } from './tabs';

const titleFromAccount = (account: Account) => {
  const displayName = account.display_name;
  const acct =
    account.acct === account.username
      ? `${account.username}@${localDomain}`
      : account.acct;
  const prefix =
    displayName.trim().length === 0 ? account.username : displayName;

  return `${prefix} (@${acct})`;
};

// 注目のハッシュタグの名前をデフォルト値に設定吸うためのWorkaround
// See: https://github.com/formatjs/babel-plugin-react-intl/issues/119#issuecomment-326202499
/* eslint-disable-next-line @typescript-eslint/no-explicit-any */
const DynamicFormattedMessage = (props: any) => {
  return <FormattedMessage {...props} />;
};

export const AccountHeader: React.FC<{
  accountId: string;
  hideTabs?: boolean;
}> = ({ accountId, hideTabs }) => {
  const dispatch = useAppDispatch();
  const account = useAppSelector((state) => state.accounts.get(accountId));
  const relationship = useAppSelector((state) =>
    state.relationships.get(accountId),
  );
  const hidden = useAppSelector((state) => getAccountHidden(state, accountId));

  /* eslint-disable-next-line @typescript-eslint/no-unsafe-assignment */
  const featuredTags = useAppSelector((state) =>
    getAccountFeaturedTags(state, accountId),
  );

  const handleFollow = useCallback(() => {
    if (!account) {
      return;
    }

    if (relationship?.following || relationship?.requested) {
      dispatch(
        openModal({ modalType: 'CONFIRM_UNFOLLOW', modalProps: { account } }),
      );
    } else {
      dispatch(followAccount(account.id));
    }
  }, [dispatch, account, relationship]);

  const handleBlock = useCallback(() => {
    if (!account) {
      return;
    }

    if (relationship?.blocking) {
      dispatch(unblockAccount(account.id));
    } else {
      dispatch(initBlockModal(account));
    }
  }, [dispatch, account, relationship]);

  const handleMention = useCallback(() => {
    if (!account) {
      return;
    }

    dispatch(mentionCompose(account));
  }, [dispatch, account]);

  const handleDirect = useCallback(() => {
    if (!account) {
      return;
    }

    dispatch(directCompose(account));
  }, [dispatch, account]);

  const handleReport = useCallback(() => {
    if (!account) {
      return;
    }

    dispatch(initReport(account));
  }, [dispatch, account]);

  const handleReblogToggle = useCallback(() => {
    if (!account) {
      return;
    }

    if (relationship?.showing_reblogs) {
      dispatch(followAccount(account.id, { reblogs: false }));
    } else {
      dispatch(followAccount(account.id, { reblogs: true }));
    }
  }, [dispatch, account, relationship]);

  const handleNotifyToggle = useCallback(() => {
    if (!account) {
      return;
    }

    if (relationship?.notifying) {
      dispatch(followAccount(account.id, { notify: false }));
    } else {
      dispatch(followAccount(account.id, { notify: true }));
    }
  }, [dispatch, account, relationship]);

  const handleMute = useCallback(() => {
    if (!account) {
      return;
    }

    if (relationship?.muting) {
      dispatch(unmuteAccount(account.id));
    } else {
      dispatch(initMuteModal(account));
    }
  }, [dispatch, account, relationship]);

  const handleBlockDomain = useCallback(() => {
    if (!account) {
      return;
    }

    dispatch(initDomainBlockModal(account));
  }, [dispatch, account]);

  const handleUnblockDomain = useCallback(() => {
    if (!account) {
      return;
    }

    const domain = account.acct.split('@')[1];

    if (!domain) {
      return;
    }

    dispatch(unblockDomain(domain));
  }, [dispatch, account]);

  const handleEndorseToggle = useCallback(() => {
    if (!account) {
      return;
    }

    if (relationship?.endorsed) {
      dispatch(unpinAccount(account.id));
    } else {
      dispatch(pinAccount(account.id));
    }
  }, [dispatch, account, relationship]);

  const handleAddToList = useCallback(() => {
    if (!account) {
      return;
    }

    dispatch(
      openModal({
        modalType: 'LIST_ADDER',
        modalProps: {
          accountId: account.id,
        },
      }),
    );
  }, [dispatch, account]);

  const handleChangeLanguages = useCallback(() => {
    if (!account) {
      return;
    }

    dispatch(
      openModal({
        modalType: 'SUBSCRIBED_LANGUAGES',
        modalProps: {
          accountId: account.id,
        },
      }),
    );
  }, [dispatch, account]);

  const handleOpenAvatar = useCallback(
    (e: React.MouseEvent) => {
      if (e.button !== 0 || e.ctrlKey || e.metaKey) {
        return;
      }

      e.preventDefault();

      if (!account) {
        return;
      }

      dispatch(
        openModal({
          modalType: 'IMAGE',
          modalProps: {
            src: account.avatar,
            alt: '',
          },
        }),
      );
    },
    [dispatch, account],
  );

  const [isFooterIntersecting, setIsIntersecting] = useState(false);
  const handleIntersect: IntersectionObserverCallback = useCallback(
    (entries) => {
      const entry = entries.at(0);
      if (!entry) {
        return;
      }

      setIsIntersecting(entry.isIntersecting);
    },
    [],
  );
  const [observer] = useState(
    () =>
      new IntersectionObserver(handleIntersect, {
        rootMargin: '0px 0px -55px 0px', // Height of bottom nav bar.
      }),
  );

  const handleObserverRef: RefCallback<HTMLDivElement> = useCallback(
    (node) => {
      if (node) {
        observer.observe(node);
      }
    },
    [observer],
  );

  useEffect(() => {
    return () => {
      observer.disconnect();
    };
  }, [observer]);

  if (!account) {
    return null;
  }

  const suspendedOrHidden = hidden || account.suspended;
  const isLocal = !account.acct.includes('@');

  return (
    <div className='account-timeline__header'>
      {!hidden && account.memorial && <MemorialNote />}
      {!hidden && account.moved && (
        <MovedNote accountId={account.id} targetAccountId={account.moved} />
      )}

      <AnimateEmojiProvider
        className={classNames('account__header', {
          inactive: !!account.moved,
        })}
      >
        {!suspendedOrHidden && !account.moved && relationship?.requested_by && (
          <FollowRequestNoteContainer account={account} />
        )}

        <div className='account__header__image'>
          {me !== account.id && relationship && !isRedesignEnabled() && (
            <AccountInfo relationship={relationship} />
          )}

          {!suspendedOrHidden && (
            <img
              src={autoPlayGif ? account.header : account.header_static}
              alt=''
              className='parallax'
            />
          )}
        </div>

        <div
          className={classNames(
            'account__header__bar',
            isRedesignEnabled() && redesignClasses.barWrapper,
          )}
        >
          <div className='account__header__tabs'>
            <a
              className='avatar'
              href={account.avatar}
              rel='noopener'
              target='_blank'
              onClick={handleOpenAvatar}
            >
              <Avatar
                account={suspendedOrHidden ? undefined : account}
                size={92}
              />
            </a>

            {!isRedesignEnabled() && (
              <AccountButtons
                accountId={accountId}
                className='account__header__buttons--desktop'
              />
            )}
          </div>

          <div
            className={classNames(
              'account__header__tabs__name',
              isRedesignEnabled() && redesignClasses.nameWrapper,
            )}
          >
            <AccountName accountId={accountId} />
            {isRedesignEnabled() && (
              <AccountButtons
                accountId={accountId}
                className={redesignClasses.buttonsDesktop}
                noShare
              />
            )}
          </div>

          <AccountBadges accountId={accountId} />

          {me && account.id !== me && !suspendedOrHidden && (
            <FamiliarFollowers accountId={accountId} />
          )}

          {!isRedesignEnabled() && (
            <AccountButtons
              className='account__header__buttons--mobile'
              accountId={accountId}
              noShare
            />
          )}

          {!suspendedOrHidden && (
            <div className='account__header__extra'>
              <div className='account__header__bio'>
                {me &&
                  account.id !== me &&
                  (isRedesignEnabled() ? (
                    <AccountNoteRedesign accountId={accountId} />
                  ) : (
                    <AccountNote accountId={accountId} />
                  ))}

                <AccountBio
                  accountId={accountId}
                  className='account__header__content'
                />

                <AccountHeaderFields accountId={accountId} />
              </div>

              <AccountNumberFields accountId={accountId} />
            </div>
          )}

          {isRedesignEnabled() && (
            <AccountButtons
              className={classNames(
                redesignClasses.buttonsMobile,
                !isFooterIntersecting && redesignClasses.buttonsMobileIsStuck,
              )}
              accountId={accountId}
              noShare
            />
          )}
        </div>
      </AnimateEmojiProvider>

      {!hideTabs && !hidden && <AccountTabs acct={account.acct} featuredTags={featuredTags} />}
      <div ref={handleObserverRef} />

      <Helmet>
        <title>{titleFromAccount(account)}</title>
        <meta
          name='robots'
          content={isLocal && !account.noindex ? 'all' : 'noindex'}
        />
        <link rel='canonical' href={account.url} />
      </Helmet>
    </div>
  );
};
