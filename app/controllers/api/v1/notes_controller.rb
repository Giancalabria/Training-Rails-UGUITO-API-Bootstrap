module Api
  module V1
    class NotesController < ApplicationController
      def index
        render json: notes_filtered, status: :ok, each_serializer: IndexNoteSerializer
      end

      def index_async
        render json: notes_filtered, status: :ok, each_serializer: IndexNoteAsyncSerializer
      end


      def show
        render json: Note.find(params[:id]), status: :ok, serializer: ShowNoteSerializer
      end

      def create
        note = Note.create(note_params)
        render json: note, status: :created
      end

      private

      def notes_filtered
        Note.where(filtering_params).order(order_param).page(params[:page]).per(params[:page_size])
      end

      def filtering_params
        params.permit(:note_type, :book_id)
      end

      def order_param
        params[:order] || 'created_at DESC'
      end

      def note_params
        params.require(:note).permit(:title, :content, :note_type, :user_id, :book_id)
      end
    end
  end
end
