import { connect } from 'react-redux';

import { addScheduledAt, removeScheduledAt } from '../../../actions/compose';
import ScheduleButton from '../components/schedule_button';

const mapStateToProps = state => ({
  active: state.getIn(['compose', 'scheduledAt']) !== null,
});

const mapDispatchToProps = dispatch => ({

  onClick () {
    dispatch((_, getState) => {
      if (getState().getIn(['compose', 'scheduledAt'])) {
        dispatch(removeScheduledAt());
      } else {
        dispatch(addScheduledAt());
      }
    });
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(ScheduleButton);
