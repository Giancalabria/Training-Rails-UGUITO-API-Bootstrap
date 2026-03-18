ActiveAdmin.register Book do
  permit_params :title, :author, :year, :publisher, :image, :genre, :utility_id, :user_id

  controller do
    def scoped_collection
      super.includes(:utility, :user)
    end
  end

  index do
    selectable_column
    id_column
    column :title
    column :author
    column :published_date
    column :genre
    column('Utility') { |book| book.utility&.name }
    column('User') { |book| "#{book.user&.first_name} #{book.user&.last_name}" }
    actions
  end

  filter :title
  filter :author
  filter :published_date

  form do |f|
    f.inputs do
      f.input :title
      f.input :author
      f.input :year
      f.input :publisher
      f.input :image
      f.input :genre
      f.input :utility, as: :select, collection: Utility.all.includes(:users).map { |u|
                                                   [u.name, u.id]
                                                 }
      f.input :user, as: :select, collection: User.all.includes(:books).map { |u|
                                                ["#{u.first_name} #{u.last_name}", u.id]
                                              }
    end
    f.actions
  end
end
