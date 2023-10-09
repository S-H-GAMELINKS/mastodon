import { connect } from 'react-redux';

import {
  changeSchedule,
} from '../../../actions/compose';
import ScheduleForm from '../components/schedule_form';

const mapStateToProps = state => ({
  schedule: state.getIn(['compose', 'scheduledAt', 'schedule']),
});

const mapDispatchToProps = dispatch => ({
  onChangeSchedule(schedule) {
    dispatch(changeSchedule(schedule));
  }
});

export default connect(mapStateToProps, mapDispatchToProps)(ScheduleForm);
