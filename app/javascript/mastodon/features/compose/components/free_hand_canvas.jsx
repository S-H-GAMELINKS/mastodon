import PropTypes from 'prop-types';
import { createRef } from 'react';



import { injectIntl } from 'react-intl';

import ImmutablePureComponent from 'react-immutable-pure-component';

import { ReactSketchCanvas } from "react-sketch-canvas";

import DeleteIcon from '@/material-icons/400-24px/delete.svg?react';
import EditIcon from '@/material-icons/400-24px/edit.svg?react';
import EraserIcon from '@/material-icons/400-24px/ink_eraser.svg?react';
import RedoIcon from '@/material-icons/400-24px/redo.svg?react';
import UndoIcon from '@/material-icons/400-24px/undo.svg?react';

import { IconButton } from '../../../components/icon_button';

const iconStyle = {
  height: null,
  lineHeight: '27px',
};

class FreeHandCanvas extends ImmutablePureComponent {
  static props = {
    onCanvasSave: PropTypes.func.isRequired, 
  };

  state = {
    eraseMode: false,
    strokeColor: "#000000",
    strokeWidth: 5,
  };

  constructor (props, context) {
    super(props, context);

    this.canvas = createRef();
  }

  handlePenMode = () => {
    this.setState({eraseMode: false});
    this.canvas.current?.eraseMode(false);
  };

  handleEraseMode = () => {
    this.setState({eraseMode: true});
    this.canvas.current?.eraseMode(true);
  };

  handleUndo = () => {
    this.canvas.current?.undo();
  };

  handleRedo = () => {
    this.canvas.current?.redo();
  };

  handleClearCanvas = () => {
    this.canvas.current?.clearCanvas();
  };

  handleStrokeColor = (e) => {
    this.setState({strokeColor: e.target.value});
  };

  handleStrokeWidth = (e) => {
    this.setState({strokeWidth: e.target.value});
  };

  handleSaveCanvas = () => {
    this.canvas.current.exportImage("png")
      .then((data) => {
        this.props.onCanvasSave([data]);
        confirm("画像を保存しました!");
      })
      .catch((e) => {
        confirm(e);
      });
    this.canvas.current?.resetCanvas();
  };

  render() {
    return (
      <div>
        <div>
          <IconButton
            icon='edit'
            iconComponent={EditIcon}
            title={"ペン"}
            onClick={this.handlePenMode}
            className={`${this.state.eraseMode ? '' : 'active'}`}
            size={18}
            inverted
            style={iconStyle}
          />
          <IconButton
            icon='erase'
            iconComponent={EraserIcon}
            title={"消しゴム"}
            onClick={this.handleEraseMode}
            className={`${this.state.eraseMode ? 'active' : ''}`}
            size={18}
            inverted
            style={iconStyle}
          />
          <IconButton
            icon='undo'
            iconComponent={UndoIcon}
            title={"やり直し"}
            onClick={this.handleUndo}
            className='active'
            size={18}
            inverted
            style={iconStyle}
          />
          <IconButton
            icon='redo'
            iconComponent={RedoIcon}
            title={"元に戻す"}
            onClick={this.handleRedo}
            className='active'
            size={18}
            inverted
            style={iconStyle}
          />
          <IconButton
            icon='delete'
            iconComponent={DeleteIcon}
            title={"削除"}
            onClick={this.handleClearCanvas}
            className='active'
            size={18}
            inverted
            style={iconStyle}
          />
          <input type='color' value={this.state.strokeColor} onChange={this.handleStrokeColor} style={{marginLeft: "0.5rem"}} />
          <span className='simple_form'>
            <input type='number' min='1' max='20' step='1' value={this.state.strokeWidth} onChange={this.handleStrokeWidth} style={{marginLeft: "0.5rem", width: "2.75rem", display: "inline"}} />
          </span>
        </div>
        <ReactSketchCanvas ref={this.canvas} strokeWidth={this.state.strokeWidth} height='25rem' strokeColor={this.state.strokeColor} />
        <div style={{marginTop: "0.5rem"}}>
          <button className='button' onClick={this.handleSaveCanvas}>
            投稿に添付する
          </button>
        </div>
      </div>
    );
  }
}

export default injectIntl(FreeHandCanvas);


