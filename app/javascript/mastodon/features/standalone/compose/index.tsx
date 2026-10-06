import { AlertsController } from '@/mastodon/components/alerts_controller';
import ComposeFormContainer from '@/mastodon/features/compose/containers/compose_form_container';
import LoadingBarContainer from '@/mastodon/features/ui/containers/loading_bar_container';
import ModalContainer from '@/mastodon/features/ui/containers/modal_container';

export const Compose: React.FC = () => {
  return (
    <>
      {/* Creatodon 独自機能 (手書きCanvas・予約投稿・自動削除・ポートフォリオ/にゃーん公開範囲) は
          従来の ComposeForm にのみ実装されているため、リデザイン版ではなく従来版を使用する */}
      <ComposeFormContainer autoFocus withoutNavigation redirectOnSuccess />
      <AlertsController />
      <ModalContainer />
      <LoadingBarContainer className='loading-bar' />
    </>
  );
};

// eslint-disable-next-line import/no-default-export
export default Compose;
