# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Creatodon draw illust', :js, :streaming do
  include CreatodonFeatureStories

  let(:user) { create_onboarded_user(username: 'draw_user') }

  before do
    log_in_through_ui(user)
    visit '/publish'
    find_field(composer_textarea_id)
  end

  it 'shows the draw button in the compose form' do
    expect(page).to have_button('絵を描く')
  end

  it 'shows the canvas after clicking the draw button' do
    click_button '絵を描く'

    expect(page)
      .to have_css('#react-sketch-canvas__canvas-background')
      .and have_button('絵を描くのをやめる')
      .and have_button('投稿に添付する')
      .and have_no_field(composer_textarea_id)
  end

  it 'shows the drawing tools in canvas mode' do
    click_button '絵を描く'

    expect(page)
      .to have_button('ペン')
      .and have_button('消しゴム')
      .and have_button('元に戻す')
      .and have_button('やり直し')
      .and have_button('削除')
      .and have_field(type: 'color')
      .and have_field(type: 'number')
  end

  it 'allows drawing on the canvas' do
    click_button '絵を描く'

    draw_line_on_canvas(from_x: 300, from_y: 200, to_x: 350, to_y: 250)

    expect(page).to have_css('#react-sketch-canvas__canvas-background')
  end

  it 'allows attaching the drawing to a post and publishing it' do
    click_button '絵を描く'

    draw_line_on_canvas(from_x: 300, from_y: 200, to_x: 350, to_y: 250)

    click_button '投稿に添付する'

    # 添付後は自動で投稿フォームに戻る
    expect(page)
      .to have_field(composer_textarea_id)
      .and have_button(frontend_translation('compose.upload.menu.delete'))

    compose_status('イラストを描きました！')
    click_button frontend_translation('confirmations.missing_alt_text.secondary')

    expect(page).to have_field(composer_textarea_id, with: '', wait: 10)
  end

  it 'allows exiting drawing mode' do
    click_button '絵を描く'

    expect(page)
      .to have_css('#react-sketch-canvas__canvas-background')
      .and have_button('絵を描くのをやめる')

    click_button '絵を描くのをやめる'

    expect(page)
      .to have_field(composer_textarea_id)
      .and have_button('絵を描く')
      .and have_no_css('#react-sketch-canvas__canvas-background')
  end

  it 'allows using the drawing tools' do
    click_button '絵を描く'

    click_button 'ペン'
    draw_line_on_canvas(from_x: 200, from_y: 150, to_x: 250, to_y: 200)

    click_button '消しゴム'
    draw_line_on_canvas(from_x: 225, from_y: 175, to_x: 235, to_y: 185)

    click_button '元に戻す'
    click_button 'やり直し'
    click_button '削除'
    find_field(type: 'color').set('#ff0000')
    find_field(type: 'number').fill_in(with: '10')

    expect(page).to have_field(type: 'number', with: '10')
  end
end
