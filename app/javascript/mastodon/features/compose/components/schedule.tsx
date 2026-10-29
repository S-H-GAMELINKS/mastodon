import type React from 'react';
import { useCallback } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import { CalendarPlusIcon, TimerIcon } from '@phosphor-icons/react';

import {
  addDeleteSchedule,
  addScheduledAt,
  changeDeleteSchedule,
  changeSchedule,
  removeDeleteSchedule,
  removeScheduledAt,
} from '@/mastodon/actions/compose';
import {
  Button,
  buttonClasses,
  ToggleIconButton,
} from '@/mastodon/components/button/redesign';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store';
import { DAY, HOUR, MINUTE, SECOND } from '@/mastodon/utils/time';

import classes from './attachments.module.scss';

// Creatodon 独自機能: 予約投稿と投稿の自動削除

const messages = defineMessages({
  minutes: {
    id: 'intervals.full.minutes',
    defaultMessage: '{number, plural, one {# minute} other {# minutes}}',
  },
  hours: {
    id: 'intervals.full.hours',
    defaultMessage: '{number, plural, one {# hour} other {# hours}}',
  },
  days: {
    id: 'intervals.full.days',
    defaultMessage: '{number, plural, one {# day} other {# days}}',
  },
});

const durationOptions = [
  5 * MINUTE,
  30 * MINUTE,
  HOUR,
  6 * HOUR,
  12 * HOUR,
  DAY,
  3 * DAY,
  7 * DAY,
];

function durationToMessage(durationMs: number) {
  if (durationMs < HOUR) {
    return { message: messages.minutes, multiplier: MINUTE };
  } else if (durationMs < DAY) {
    return { message: messages.hours, multiplier: HOUR };
  }
  return { message: messages.days, multiplier: DAY };
}

const selectComposeSchedule = createAppSelector(
  [
    (state) =>
      state.compose.getIn(['scheduledAt', 'schedule']) as
        | number
        | string
        | undefined,
    (state) =>
      state.compose.getIn(['deleteSchedule', 'expires_at']) as
        | number
        | string
        | undefined,
    (state) => !!state.compose.get('id'),
  ],
  (schedule, deleteSchedule, isEditing) => ({
    schedule: schedule === undefined ? null : Number(schedule),
    deleteSchedule:
      deleteSchedule === undefined ? null : Number(deleteSchedule),
    isEditing,
  }),
);

// フッターに置く切り替えボタン (予約投稿と自動削除は同時に使えない)
export const ComposeScheduleButtons: React.FC = () => {
  const { schedule, deleteSchedule, isEditing } = useAppSelector(
    selectComposeSchedule,
  );
  const hasSchedule = schedule !== null;
  const hasDeleteSchedule = deleteSchedule !== null;

  const dispatch = useAppDispatch();
  const handleSchedule = useCallback(() => {
    dispatch(hasSchedule ? removeScheduledAt() : addScheduledAt());
  }, [dispatch, hasSchedule]);
  const handleDeleteSchedule = useCallback(() => {
    dispatch(hasDeleteSchedule ? removeDeleteSchedule() : addDeleteSchedule());
  }, [dispatch, hasDeleteSchedule]);

  if (isEditing) {
    return null;
  }

  return (
    <>
      <ToggleIconButton
        size='sm'
        icon={CalendarPlusIcon}
        active={hasSchedule}
        disabled={hasDeleteSchedule}
        onClick={handleSchedule}
      >
        {hasSchedule ? (
          <FormattedMessage
            id='schedule_button.remove_schedule'
            defaultMessage='Remove schedule post'
          />
        ) : (
          <FormattedMessage
            id='schedule_button.add_schedule'
            defaultMessage='Add schedule post'
          />
        )}
      </ToggleIconButton>

      <ToggleIconButton
        size='sm'
        icon={TimerIcon}
        active={hasDeleteSchedule}
        disabled={hasSchedule}
        onClick={handleDeleteSchedule}
      >
        {hasDeleteSchedule ? (
          <FormattedMessage
            id='delete_schedule_button.remove_delete_schedule'
            defaultMessage='Remove delete schedule'
          />
        ) : (
          <FormattedMessage
            id='delete_schedule_button.add_delete_schedule'
            defaultMessage='Add delete schedule'
          />
        )}
      </ToggleIconButton>
    </>
  );
};

// テキストエリア下に表示する時間の選択欄
export const ComposeSchedule: React.FC<{ className?: string }> = ({
  className,
}) => {
  const { schedule, deleteSchedule, isEditing } = useAppSelector(
    selectComposeSchedule,
  );

  const dispatch = useAppDispatch();
  const handleScheduleChange: React.ChangeEventHandler<HTMLSelectElement> =
    useCallback(
      (event) => {
        dispatch(changeSchedule(Number.parseInt(event.target.value)));
      },
      [dispatch],
    );
  const handleScheduleRemove = useCallback(() => {
    dispatch(removeScheduledAt());
  }, [dispatch]);
  const handleDeleteScheduleChange: React.ChangeEventHandler<HTMLSelectElement> =
    useCallback(
      (event) => {
        dispatch(changeDeleteSchedule(Number.parseInt(event.target.value)));
      },
      [dispatch],
    );
  const handleDeleteScheduleRemove = useCallback(() => {
    dispatch(removeDeleteSchedule());
  }, [dispatch]);

  if (isEditing || (schedule === null && deleteSchedule === null)) {
    return null;
  }

  return (
    <div className={className}>
      {schedule !== null && (
        <ScheduleControl
          value={schedule}
          onChange={handleScheduleChange}
          onRemove={handleScheduleRemove}
          label={
            <FormattedMessage
              id='compose.schedule.label'
              defaultMessage='予約投稿:'
            />
          }
          removeLabel={
            <FormattedMessage
              id='schedule_button.remove_schedule'
              defaultMessage='Remove schedule post'
            />
          }
        />
      )}

      {deleteSchedule !== null && (
        <ScheduleControl
          value={deleteSchedule}
          onChange={handleDeleteScheduleChange}
          onRemove={handleDeleteScheduleRemove}
          label={
            <FormattedMessage
              id='compose.delete_schedule.label'
              defaultMessage='自動削除:'
            />
          }
          removeLabel={
            <FormattedMessage
              id='delete_schedule_button.remove_delete_schedule'
              defaultMessage='Remove delete schedule'
            />
          }
        />
      )}
    </div>
  );
};

const ScheduleControl: React.FC<{
  value: number;
  onChange: React.ChangeEventHandler<HTMLSelectElement>;
  onRemove: () => void;
  label: React.ReactNode;
  removeLabel: React.ReactNode;
}> = ({ value, onChange, onRemove, label, removeLabel }) => {
  const intl = useIntl();

  return (
    <div className={classes.schedule}>
      <span>
        {label}
        &nbsp;
        <select
          value={value}
          onChange={onChange}
          className={classNames(
            classes.pollDurationSelect,
            buttonClasses.base,
            buttonClasses.tonal,
            buttonClasses.neutral,
            buttonClasses.xs,
          )}
        >
          {durationOptions.map((duration) => {
            const { message, multiplier } = durationToMessage(duration);
            return (
              <option key={duration} value={duration / SECOND}>
                {intl.formatMessage(message, {
                  number: duration / multiplier,
                })}
              </option>
            );
          })}
        </select>
      </span>

      <Button variant='ghost' color='destructive' size='xs' onClick={onRemove}>
        {removeLabel}
      </Button>
    </div>
  );
};
