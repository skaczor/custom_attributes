namespace :custom_attributes do
  desc "merge custom_attributes migration files"
  task :sync do
    system "rsync -ruv vendor/plugins/custom_attributes/db/migrate db"
  end
end
