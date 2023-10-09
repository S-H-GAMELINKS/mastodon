import { connect } from 'react-redux';

import {
  changeDeleteSchedule,
} from '../../../actions/compose';
import DeleteScheduleForm from '../components/delete_schedule_form';

const mapStateToProps = state => ({
  expires_at: state.getIn(['compose', 'deleteSchedule', 'expires_at']),
});

const mapDispatchToProps = dispatch => ({
  onChangeSchedule(expires_at) {
    dispatch(changeDeleteSchedule(expires_at));
  }
});

export default connect(mapStateToProps, mapDispatchToProps)(DeleteScheduleForm);