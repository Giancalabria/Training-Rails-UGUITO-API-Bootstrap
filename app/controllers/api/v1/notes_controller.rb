module Api
  module V1
    class NotesController < ApplicationController
      def index
        render json: notes_filtered, status: :ok
      end

      def index_async
        response = execute_async(Note.all)
        render json: response, status: :ok
      end

      def show
        render json: Note.find(params[:id]), status: :ok
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
        params.permit(:note_type)
      end

      def order_param
        params[:order] || 'created_at DESC'
      end

      def note_params
        params.require(:note).permit(:title, :content, :note_type, :user_id)
      end
    end
  end
end
