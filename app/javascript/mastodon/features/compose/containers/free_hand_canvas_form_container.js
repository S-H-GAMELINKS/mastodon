import { connect } from 'react-redux';

import { uploadCompose } from '../../../actions/compose';
import FreeHandCanvas from '../components/free_hand_canvas';

const mapStateToProps = () => ({});

const mapDispatchToProps = dispatch => ({
  onCanvasSave(images) {
    dispatch(uploadCompose(images));
  }
});

export default connect(mapStateToProps, mapDispatchToProps)(FreeHandCanvas);

