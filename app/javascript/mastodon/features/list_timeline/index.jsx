import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { FormattedMessage } from 'react-intl';

import { Helmet } from 'react-helmet';
import { Link, withRouter } from 'react-router-dom';

import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';

import DeleteIcon from '@/material-icons/400-24px/delete.svg?react';
import EditIcon from '@/material-icons/400-24px/edit.svg?react';
import ListAltIcon from '@/material-icons/400-24px/list_alt.svg?react';
import { addColumn, removeColumn, moveColumn } from 'mastodon/actions/columns';
import { fetchList } from 'mastodon/actions/lists';
import { openModal } from 'mastodon/actions/modal';
import { connectListStream } from 'mastodon/actions/streaming';
import { expandListTimeline } from 'mastodon/actions/timelines';
import Column from 'mastodon/components/column';
import ColumnHeader from 'mastodon/components/column_header';
import { Icon }  from 'mastodon/components/icon';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import BundleColumnError from 'mastodon/features/ui/components/bundle_column_error';
import StatusListContainer from 'mastodon/features/ui/containers/status_list_container';
import { WithRouterPropTypes } from 'mastodon/utils/react_router';

import ColumnSettingsContainer from './containers/column_settings_container';

const mapStateToProps = (state, props) => {
  const { columnId } = props;
  const uuid = columnId;
  const columns = state.getIn(['settings', 'columns']);
  const index = columns ? columns.findIndex(c => c.get('uuid') === uuid) : -1;
  const onlyMedia = (columnId && index >= 0) ? columns.get(index).getIn(['params', 'other', 'onlyMedia']) : state.getIn(['settings', 'list', 'other', 'onlyMedia'], false);
  const timelineId = `list:${props.params.id}${onlyMedia ? ':media' : ''}`;

  return {
    list: state.getIn(['lists', props.params.id]),
    hasUnread: state.getIn(['timelines', timelineId, 'unread']) > 0,
    onlyMedia,
  };
};

class ListTimeline extends PureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    columnId: PropTypes.string,
    hasUnread: PropTypes.bool,
    multiColumn: PropTypes.bool,
    onlyMedia: PropTypes.bool,
    list: PropTypes.oneOfType([ImmutablePropTypes.map, PropTypes.bool]),
    intl: PropTypes.object.isRequired,
    ...WithRouterPropTypes,
  };

  handlePin = () => {
    const { columnId, dispatch, onlyMedia } = this.props;

    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('LIST', { id: this.props.params.id, other: { onlyMedia } }));
      this.props.history.push('/');
    }
  };

  handleMove = (dir) => {
    const { columnId, dispatch } = this.props;
    dispatch(moveColumn(columnId, dir));
  };

  handleHeaderClick = () => {
    this.column.scrollTop();
  };

  componentDidMount () {
    const { dispatch, onlyMedia } = this.props;
    const { id } = this.props.params;

    dispatch(fetchList(id));
    dispatch(expandListTimeline(id, { onlyMedia }));

    this.disconnect = dispatch(connectListStream(id, { onlyMedia }));
  }

  UNSAFE_componentWillReceiveProps (nextProps) {
    const { dispatch } = this.props;
    const { id } = nextProps.params;
    const { onlyMedia } = nextProps;

    if (id !== this.props.params.id || onlyMedia !== this.props.onlyMedia) {
      if (this.disconnect) {
        this.disconnect();
        this.disconnect = null;
      }

      dispatch(fetchList(id));
      dispatch(expandListTimeline(id, { onlyMedia }));

      this.disconnect = dispatch(connectListStream(id, { onlyMedia }));
    }
  }

  componentWillUnmount () {
    if (this.disconnect) {
      this.disconnect();
      this.disconnect = null;
    }
  }

  setRef = c => {
    this.column = c;
  };

  handleLoadMore = maxId => {
    const { id } = this.props.params;
    const { onlyMedia } = this.props;
    this.props.dispatch(expandListTimeline(id, { maxId, onlyMedia }));
  };

  handleDeleteClick = () => {
    const { dispatch, columnId } = this.props;
    const { id } = this.props.params;

    dispatch(openModal({ modalType: 'CONFIRM_DELETE_LIST', modalProps: { listId: id, columnId } }));
  };

  render () {
    const { hasUnread, columnId, multiColumn, list, onlyMedia } = this.props;
    const { id } = this.props.params;
    const pinned = !!columnId;
    const title  = list ? list.get('title') : id;
    const timelineId = `list:${id}${onlyMedia ? ':media' : ''}`;

    if (typeof list === 'undefined') {
      return (
        <Column>
          <div className='scrollable'>
            <LoadingIndicator />
          </div>
        </Column>
      );
    } else if (list === false) {
      return (
        <BundleColumnError multiColumn={multiColumn} errorType='routing' />
      );
    }

    return (
      <Column bindToDocument={!multiColumn} ref={this.setRef} label={title}>
        <ColumnHeader
          icon='list-ul'
          iconComponent={ListAltIcon}
          active={hasUnread}
          title={title}
          onPin={this.handlePin}
          onMove={this.handleMove}
          onClick={this.handleHeaderClick}
          pinned={pinned}
          multiColumn={multiColumn}
        >
          <div className='column-settings'>
            <section className='column-header__links'>
              <Link to={`/lists/${id}/edit`} className='text-btn column-header__setting-btn'>
                <Icon id='pencil' icon={EditIcon} /> <FormattedMessage id='lists.edit' defaultMessage='Edit list' />
              </Link>

              <button type='button' className='text-btn column-header__setting-btn' tabIndex={0} onClick={this.handleDeleteClick}>
                <Icon id='trash' icon={DeleteIcon} /> <FormattedMessage id='lists.delete' defaultMessage='Delete list' />
              </button>
            </section>

            <ColumnSettingsContainer columnId={columnId} />
          </div>
        </ColumnHeader>

        <StatusListContainer
          trackScroll={!pinned}
          scrollKey={`list_timeline-${columnId}`}
          timelineId={timelineId}
          onLoadMore={this.handleLoadMore}
          emptyMessage={<FormattedMessage id='empty_column.list' defaultMessage='There is nothing in this list yet. When members of this list post new statuses, they will appear here.' />}
          bindToDocument={!multiColumn}
        />

        <Helmet>
          <title>{title}</title>
          <meta name='robots' content='noindex' />
        </Helmet>
      </Column>
    );
  }

}

export default withRouter(connect(mapStateToProps)(ListTimeline));
