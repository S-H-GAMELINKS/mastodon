# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Creatodon draw illust', :js, :streaming do
  include CreatodonFeatureStories

  let(:user) { create_onboarded_user(username: 'draw_user') }

  before do
    log_in_through_ui(user)
    visit '/publish'
    first('.compose-form', minimum: 1)
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
  end

  it 'shows the drawing tools in canvas mode' do
    click_button '絵を描く'

    expect(page)
      .to have_css('[title="ペン"]')
      .and have_css('[title="消しゴム"]')
      .and have_css('[title="やり直し"]')
      .and have_css('[title="元に戻す"]')
      .and have_css('[title="削除"]')
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

    accept_confirm { click_button '投稿に添付する' }
    click_button '絵を描くのをやめる'

    expect(page).to have_css('.compose-form__uploads')

    compose_status('イラストを描きました！')
    click_button 'そのまま投稿する'

    expect(page).to have_field(class: 'autosuggest-textarea__textarea', with: '', wait: 10)
  end

  it 'allows exiting drawing mode' do
    click_button '絵を描く'

    expect(page)
      .to have_css('#react-sketch-canvas__canvas-background')
      .and have_button('絵を描くのをやめる')

    click_button '絵を描くのをやめる'

    expect(page)
      .to have_css('.autosuggest-textarea__textarea')
      .and have_button('絵を描く')
      .and have_no_css('#react-sketch-canvas__canvas-background')
  end

  it 'allows using the drawing tools' do
    click_button '絵を描く'

    find('[title="ペン"]').click

    draw_line_on_canvas(from_x: 200, from_y: 150, to_x: 250, to_y: 200)

    find('[title="消しゴム"]').click
    draw_line_on_canvas(from_x: 225, from_y: 175, to_x: 235, to_y: 185)

    find('[title="やり直し"]').click
    find('[title="元に戻す"]').click
    find('[title="削除"]').click
    find('input[type="color"]').set('#ff0000')
    find('input[type="number"]').fill_in(with: '10')

    expect(find('input[type="number"]').value).to eq('01')
  end
end
