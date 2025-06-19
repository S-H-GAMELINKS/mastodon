// 絵を描く機能のE2Eテスト
describe('Draw Illust Feature', () => {
  beforeEach(() => {
    // 環境変数が設定されているかチェック
    const email = Cypress.env('email');
    const password = Cypress.env('password');

    // ログイン処理
    cy.visit('/auth/sign_in?lang=ja');
    cy.get('#user_email').type(email);
    cy.get('#user_password').type(`${password}{enter}`);

    // ログイン後、投稿フォームがある画面に移動
    cy.visit('/publish');
    cy.wait(2000); // ページロードを待つ
  });

  // 投稿フォームに「絵を描く」ボタンが存在することを確認
  it('should have "絵を描く" button in compose form', () => {
    // 投稿フォーム内の「絵を描く」ボタンを確認
    cy.get('.compose-form').should('be.visible');
    cy.contains('button', '絵を描く').should('be.visible');
  });

  // 「絵を描く」ボタンをクリックするとCanvasが表示されることを確認
  it('should show canvas when clicking "絵を描く" button', () => {
    // 「絵を描く」ボタンをクリック
    cy.contains('button', '絵を描く').click();

    // Canvasが表示されることを確認
    cy.get('#react-sketch-canvas__canvas-background').should('be.visible');

    // 描画モード時のボタンが表示されることを確認
    cy.contains('button', '絵を描くのをやめる').should('be.visible');
    cy.contains('button', '投稿に添付する').should('be.visible');
  });

  // Canvas描画ツールが正常に表示されることを確認
  it('should show drawing tools in canvas mode', () => {
    // 「絵を描く」ボタンをクリック
    cy.contains('button', '絵を描く').click();

    // 描画ツールボタンが表示されることを確認
    cy.get('[title="ペン"]').should('be.visible');
    cy.get('[title="消しゴム"]').should('be.visible');
    cy.get('[title="やり直し"]').should('be.visible');
    cy.get('[title="元に戻す"]').should('be.visible');
    cy.get('[title="削除"]').should('be.visible');

    // カラーピッカーと線の太さ入力が表示されることを確認
    cy.get('input[type="color"]').should('be.visible');
    cy.get('input[type="number"]').should('be.visible');
  });

  // Canvasで実際に描画できることを確認
  it('should be able to draw on canvas', () => {
    // 「絵を描く」ボタンをクリック
    cy.contains('button', '絵を描く').click();

    // Canvasが表示されるまで待機
    cy.get('#react-sketch-canvas__canvas-background').should('be.visible');

    // Canvasの中央で簡単な線を描く
    cy.get('#react-sketch-canvas__canvas-background')
      .trigger('mousedown', { which: 1, clientX: 300, clientY: 200 })
      .trigger('mousemove', { which: 1, clientX: 350, clientY: 250 })
      .trigger('mouseup');

    // 描画が完了したことを確認（Canvas内容の変化を待つ）
    cy.wait(500);
  });

  // 「投稿に添付する」ボタンで画像をアップロードし投稿できることを確認
  it('should be able to attach drawing to post and publish', () => {
    // 「絵を描く」ボタンをクリック
    cy.contains('button', '絵を描く').click();

    // Canvasで簡単な描画を行う
    cy.get('#react-sketch-canvas__canvas-background')
      .trigger('mousedown', { which: 1, clientX: 300, clientY: 200 })
      .trigger('mousemove', { which: 1, clientX: 350, clientY: 250 })
      .trigger('mouseup');

    // confirm ダイアログをスタブ化
    cy.window().then((win) => {
      cy.stub(win, 'confirm').returns(true);
    });

    // 「投稿に添付する」ボタンをクリック
    cy.contains('button', '投稿に添付する').click();

    // 描画モードから通常の投稿フォームに戻る
    cy.contains('button', '絵を描くのをやめる').click();

    // 添付されたメディアが表示されることを確認
    cy.get('.compose-form__uploads', { timeout: 10000 }).should('be.visible');

    // 投稿内容を入力
    cy.get('.autosuggest-textarea__textarea').type('イラストを描きました！');

    // 投稿ボタンをクリック
    cy.get('button[type="submit"]').click();

    // ALTテキストがない場合の確認ダイアログで「そのまま投稿する」ボタンを押す
    cy.get('button').contains('そのまま投稿する').should('be.visible').click();

    // 投稿が完了することを確認（投稿フォームがクリアされることを確認）
    cy.get('.autosuggest-textarea__textarea').should('have.value', '');
  });

  // 描画モードから通常モードに戻れることを確認
  it('should be able to exit drawing mode', () => {
    // 「絵を描く」ボタンをクリック
    cy.contains('button', '絵を描く').click();

    // 描画モードに入っていることを確認
    cy.get('#react-sketch-canvas__canvas-background').should('be.visible');
    cy.contains('button', '絵を描くのをやめる').should('be.visible');

    // 「絵を描くのをやめる」ボタンをクリック
    cy.contains('button', '絵を描くのをやめる').click();

    // 通常の投稿フォームに戻ることを確認
    cy.get('.autosuggest-textarea__textarea').should('be.visible');
    cy.contains('button', '絵を描く').should('be.visible');
    cy.get('#react-sketch-canvas__canvas-background').should('not.exist');
  });

  // 描画ツールの動作確認
  it('should be able to use drawing tools', () => {
    // 「絵を描く」ボタンをクリック
    cy.contains('button', '絵を描く').click();

    // ペンモードで描画
    cy.get('[title="ペン"]').click();
    cy.get('#react-sketch-canvas__canvas-background')
      .trigger('mousedown', { which: 1, clientX: 200, clientY: 150 })
      .trigger('mousemove', { which: 1, clientX: 250, clientY: 200 })
      .trigger('mouseup');

    // 消しゴムモードに切り替え
    cy.get('[title="消しゴム"]').click();
    cy.get('#react-sketch-canvas__canvas-background')
      .trigger('mousedown', { which: 1, clientX: 225, clientY: 175 })
      .trigger('mousemove', { which: 1, clientX: 235, clientY: 185 })
      .trigger('mouseup');

    // やり直し機能
    cy.get('[title="やり直し"]').click();

    // 元に戻す機能
    cy.get('[title="元に戻す"]').click();

    // キャンバスクリア機能
    cy.get('[title="削除"]').click();

    // 色と線の太さの変更
    cy.get('input[type="color"]').invoke('val', '#ff0000').trigger('change');
    cy.get('input[type="number"]').clear().type('10');
  });
});
