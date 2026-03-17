require 'rails_helper'

describe Api::V1::NotesController, type: :controller do
  describe 'GET #index' do
    context 'when the user is authenticated' do
      include_context 'with authenticated user'

      let(:user_notes) { create_list(:note, 10, user: user) }

      let!(:expected) do
        ActiveModel::Serializer::CollectionSerializer.new(notes_expected,
                                                          serializer: IndexNoteSerializer).to_json
      end

      context 'when fetching all notes from the user' do
        let(:notes_expected) { user_notes }

        before { get :index }

        it 'responds with the expected notes' do
          expect(response_body.to_json).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching notes with pagination' do
        let(:notes_expected) { user_notes.first(5) }

        before { get :index, params: { page: 1, page_size: 5 } }

        it 'responds with the expected notes' do
          expect(response_body.to_json).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching only reviews' do
        let(:notes_expected) { user_notes.select { |note| note.note_type == 'review' } }

        before { get :index, params: { note_type: 'review' } }

        it 'responds with the expected notes' do
          expect(response_body.to_json).to eq(expected)
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

      let(:expected) { ShowNoteSerializer.new(note, root: false).to_json }

      context 'when fetching a valid note' do
        let(:note) { create(:note, user: user) }

        before { get :show, params: { id: note.id } }

        it 'responds with the expected note' do
          expect(response.body).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
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
