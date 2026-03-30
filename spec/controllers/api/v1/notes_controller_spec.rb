require 'rails_helper'

describe Api::V1::NotesController, type: :controller do
  describe 'GET #index' do
    context 'when the user is authenticated' do
      include_context 'with authenticated user'

      let!(:notes_amount) { Faker::Number.between(from: 1, to: 10) }
      let(:expected_fields) { %i[id title note_type content_length] }
      let!(:expected) do
        ActiveModel::Serializer::CollectionSerializer.new(notes_expected,
                                                          serializer: IndexNoteSerializer).to_json
      end
      let(:user_notes) { create_list(:note, notes_amount, user: user) }

      context 'when fetching all notes from the user' do
        let(:notes_expected) { user_notes }

        before { get :index, params: { order: 'created_at ASC' } }

        it 'responds with the expected notes' do
          expect(response.body).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching notes with pagination' do
        let(:notes_page_amount) { Faker::Number.between(from: 1, to: notes_amount) }
        let(:notes_expected) { user_notes(notes_page_amount) }

        before { get :index, params: { page: 1, page_size: notes_page_amount } }

        it 'responds with the expected notes' do
          expect(response.body).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching only reviews' do
        let(:random_note_type) { Note.note_types.keys.sample }
        let(:user_notes) { create_list(:note, notes_amount, user: user, note_type: random_note_type) }
        let(:notes_expected) { user_notes.sort_by(&:created_at).reverse }

        before { get :index, params: { note_type: random_note_type } }

        it 'responds with the expected notes' do
          expect(response.body).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context 'when the user is not authenticated' do
      before { get :index }

      it_behaves_like 'unauthorized'
    end
  end

  describe 'GET #show' do
    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      context 'when fetching a valid note' do
        let(:note) { create(:note, user: user) }
        let(:expected) { ShowNoteSerializer.new(note, root: false).to_json }
        let(:expected_fields) { ShowNoteSerializer._attributes.keys }

        before { get :show, params: { id: note.id } }

        it 'responds with the expected note' do
          expect(response.body).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end

        it 'includes all expected fields' do
          response_body = JSON.parse(response.body)
          expected_keys = %i[id title note_type word_count created_at content content_length user]
          expect(response_body.keys.map(&:to_sym)).to match_array(expected_keys)
        end
      end

      context 'when fetching an invalid note' do
        before { get :show, params: { id: Faker::Number.number(digits: 10) } }

        it 'responds with 404 status' do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when there is no user logged in' do
      context 'when fetching a note' do
        before { get :show, params: { id: Faker::Number.number } }

        it_behaves_like 'unauthorized'
      end
    end
  end
end
