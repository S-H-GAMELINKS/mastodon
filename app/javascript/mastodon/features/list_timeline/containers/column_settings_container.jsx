import { connect } from 'react-redux';

import { changeColumnParams } from '../../../actions/columns';
import { changeSetting } from '../../../actions/settings';
import ColumnSettings from '../components/column_settings';

const mapStateToProps = (state, { columnId }) => {
  const uuid = columnId;
  const columns = state.getIn(['settings', 'columns']);
  const index = columns.findIndex(c => c.get('uuid') === uuid);

  if (columnId && index >= 0) {
    return { settings: columns.get(index).get('params') };
  } else {
    return { settings: state.getIn(['settings', 'list']) };
  }
};

const mapDispatchToProps = (dispatch, { columnId }) => {
  return {
    onChange (key, checked) {
      if (columnId) {
        dispatch(changeColumnParams(columnId, key, checked));
      } else {
        dispatch(changeSetting(['list', ...key], checked));
      }
    },
  };
};

export default connect(mapStateToProps, mapDispatchToProps)(ColumnSettings);