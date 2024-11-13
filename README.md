When upgrading our mongoid version to 9.0 we started hitting errors when running `bin/rails db:create_indexes` 

This repo is a simple reproduction of the error we are seeing.

```shell
bin/rails aborted!
NameError: uninitialized constant User::DisplayName (NameError)

  include DisplayName
          ^^^^^^^^^^^
/workspaces/mongoid-model-load-bug/app/models/user.rb:2:in `<class:User>'
/workspaces/mongoid-model-load-bug/app/models/user.rb:1:in `<main>'
/workspaces/mongoid-model-load-bug/app/models/concerns/user/display_name.rb:1:in `<main>'
Tasks: TOP => db:create_indexes => db:mongoid:create_indexes => db:mongoid:load_models
(See full trace by running task with --trace)
```

DB indexing in the 9.0 release changed the loading behavior. It is doing a .sort on the
files which causes issues with loading when a model has a concern loaded before the model itself.

- https://github.com/mongodb/mongoid/pull/5526/files
- https://jira.mongodb.org/browse/MONGOID-5547
- 9.0 release notes: https://github.com/mongodb/mongoid/pull/5813

```ruby
# https://github.com/jamis/mongoid/blob/master/lib/mongoid/loadable.rb
def load_models(paths = model_paths)
  paths.each do |path|
    if preload_models.resizable?
      files = preload_models.map { |model| "#{path}/#{model.underscore}.rb" }
    else
      files = Dir.glob("#{path}/**/*.rb")
    end

    files.sort.each do |file|
      load_model(file.gsub(/^#{path}\// , "").gsub(/\.rb$/, ""))
    end
  end
end
```

If you pull this repo down and run inside the devcontainer that is created, `bin/rails db:create_indexes`,
it will fail on `NameError: uninitialized constant User::DisplayName (NameError)`
