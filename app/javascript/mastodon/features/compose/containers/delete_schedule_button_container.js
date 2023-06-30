import { connect } from 'react-redux';

import { addDeleteSchedule, removeDeleteSchedule } from '../../../actions/compose';
import DeleteScheduleButton from '../components/delete_schedule_button';

const mapStateToProps = state => ({
  unavailable: state.getIn(['compose', 'scheduledAt']) !== null,
  active: state.getIn(['compose', 'deleteSchedule']) !== null,
});

const mapDispatchToProps = dispatch => ({

  onClick () {
    dispatch((_, getState) => {
      if (getState().getIn(['compose', 'deleteSchedule'])) {
        dispatch(removeDeleteSchedule());
      } else {
        dispatch(addDeleteSchedule());
      }
    });
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(DeleteScheduleButton);
