module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!

      def index
        render json: notes_filtered, status: :ok, each_serializer: IndexNoteSerializer
      end

      def index_async
        response = execute_async(RetrieveNotesWorker, current_user.id, index_async_params)
        async_custom_response(response)
      end

      def show
        render json: Note.find(params[:id]), status: :ok, serializer: ShowNoteSerializer
      end

      def create
        note = current_user.notes.new(note_params)
        note.save
        render_resource(note)
      end

      private

      def notes_filtered
        current_user.notes.where(filtering_params).order(order_param).page(params[:page]).per(params[:page_size])
      end

      def filtering_params
        params.permit(:note_type)
      end

      def order_param
        params[:order] || 'created_at DESC'
      end

      def index_async_params
        params.permit(:note_type)
      end

      def note_params
        params.require(:note).permit(:title, :content, :note_type, :book_id)
      end
    end
  end
end
