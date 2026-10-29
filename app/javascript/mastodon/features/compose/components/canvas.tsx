import type React from 'react';
import { useCallback, useRef, useState } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import {
  ArrowClockwiseIcon,
  ArrowCounterClockwiseIcon,
  ArrowsInIcon,
  ArrowsOutIcon,
  EraserIcon,
  PencilSimpleIcon,
  TrashIcon,
} from '@phosphor-icons/react';
import type { ReactSketchCanvasRef } from 'react-sketch-canvas';
import { ReactSketchCanvas } from 'react-sketch-canvas';

import { uploadCompose } from '@/mastodon/actions/compose';
import {
  Button,
  IconButton,
  ToggleIconButton,
} from '@/mastodon/components/button/redesign';
import { useAppDispatch } from '@/mastodon/store';
import { decode as decodeBase64 } from '@/mastodon/utils/base64';

import classes from './canvas.module.scss';

// Creatodon 独自機能: 手書き Canvas で描いた絵を投稿に添付する

const messages = defineMessages({
  pen: { id: 'compose.canvas.pen', defaultMessage: 'ペン' },
  eraser: { id: 'compose.canvas.eraser', defaultMessage: '消しゴム' },
  undo: { id: 'compose.canvas.undo', defaultMessage: '元に戻す' },
  redo: { id: 'compose.canvas.redo', defaultMessage: 'やり直し' },
  clear: { id: 'compose.canvas.clear', defaultMessage: '削除' },
  color: { id: 'compose.canvas.color', defaultMessage: 'ペンの色' },
  width: { id: 'compose.canvas.width', defaultMessage: 'ペンの太さ' },
  expand: {
    id: 'compose.canvas.expand',
    defaultMessage: '画面いっぱいに広げる',
  },
  shrink: { id: 'compose.canvas.shrink', defaultMessage: '元の大きさに戻す' },
});

const dataUrlToFile = (dataUrl: string, filename: string) => {
  const [header = '', base64 = ''] = dataUrl.split(',');
  const mimeType = /:(.*?);/.exec(header)?.[1] ?? 'image/png';

  // File には ArrayBuffer を持つ Uint8Array しか渡せないためコピーする
  const bytes = new Uint8Array(decodeBase64(base64));

  return new File([bytes], filename, { type: mimeType });
};

export const ComposeCanvas: React.FC<{
  onClose: () => void;
  expanded: boolean;
  onToggleExpand: () => void;
}> = ({ onClose, expanded, onToggleExpand }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const canvasRef = useRef<ReactSketchCanvasRef>(null);

  const [eraseMode, setEraseMode] = useState(false);
  const [strokeColor, setStrokeColor] = useState('#000000');
  const [strokeWidth, setStrokeWidth] = useState(5);

  const handlePen = useCallback(() => {
    setEraseMode(false);
    canvasRef.current?.eraseMode(false);
  }, []);
  const handleEraser = useCallback(() => {
    setEraseMode(true);
    canvasRef.current?.eraseMode(true);
  }, []);
  const handleUndo = useCallback(() => {
    canvasRef.current?.undo();
  }, []);
  const handleRedo = useCallback(() => {
    canvasRef.current?.redo();
  }, []);
  const handleClear = useCallback(() => {
    canvasRef.current?.clearCanvas();
  }, []);
  const handleColorChange: React.ChangeEventHandler<HTMLInputElement> =
    useCallback((event) => {
      setStrokeColor(event.target.value);
    }, []);
  const handleWidthChange: React.ChangeEventHandler<HTMLInputElement> =
    useCallback((event) => {
      setStrokeWidth(Number.parseInt(event.target.value) || 1);
    }, []);

  // 描いた絵を PNG にして添付し、投稿フォームに戻る
  const handleAttach = useCallback(() => {
    void canvasRef.current?.exportImage('png').then((dataUrl) => {
      dispatch(uploadCompose([dataUrlToFile(dataUrl, 'illust.png')]));
      onClose();
    });
  }, [dispatch, onClose]);

  return (
    <div className={classes.canvas}>
      <div className={classes.toolbar}>
        <ToggleIconButton
          size='sm'
          icon={PencilSimpleIcon}
          active={!eraseMode}
          onClick={handlePen}
        >
          {intl.formatMessage(messages.pen)}
        </ToggleIconButton>
        <ToggleIconButton
          size='sm'
          icon={EraserIcon}
          active={eraseMode}
          onClick={handleEraser}
        >
          {intl.formatMessage(messages.eraser)}
        </ToggleIconButton>
        <IconButton
          size='sm'
          icon={ArrowCounterClockwiseIcon}
          onClick={handleUndo}
        >
          {intl.formatMessage(messages.undo)}
        </IconButton>
        <IconButton size='sm' icon={ArrowClockwiseIcon} onClick={handleRedo}>
          {intl.formatMessage(messages.redo)}
        </IconButton>
        <IconButton size='sm' icon={TrashIcon} onClick={handleClear}>
          {intl.formatMessage(messages.clear)}
        </IconButton>

        <input
          type='color'
          value={strokeColor}
          onChange={handleColorChange}
          aria-label={intl.formatMessage(messages.color)}
          className={classes.colorInput}
        />
        <input
          type='number'
          min={1}
          max={20}
          step={1}
          value={strokeWidth}
          onChange={handleWidthChange}
          aria-label={intl.formatMessage(messages.width)}
          className={classes.widthInput}
        />

        <ToggleIconButton
          size='sm'
          icon={expanded ? ArrowsInIcon : ArrowsOutIcon}
          active={expanded}
          onClick={onToggleExpand}
          className={classes.expandButton}
        >
          {intl.formatMessage(expanded ? messages.shrink : messages.expand)}
        </ToggleIconButton>
      </div>

      {/* 通常時は下端のハンドルをドラッグして高さを変えられる */}
      <div
        className={classNames(
          classes.canvasArea,
          expanded && classes.canvasAreaExpanded,
        )}
      >
        <ReactSketchCanvas
          ref={canvasRef}
          width='100%'
          height='100%'
          strokeColor={strokeColor}
          strokeWidth={strokeWidth}
          eraserWidth={strokeWidth}
        />
      </div>

      <div className={classes.actions}>
        <Button variant='ghost' size='sm' onClick={onClose}>
          <FormattedMessage
            id='compose.canvas.close'
            defaultMessage='絵を描くのをやめる'
          />
        </Button>
        <Button variant='solid' color='accent' size='sm' onClick={handleAttach}>
          <FormattedMessage
            id='compose.canvas.attach'
            defaultMessage='投稿に添付する'
          />
        </Button>
      </div>
    </div>
  );
};
