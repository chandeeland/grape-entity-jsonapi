# grape-jsonapi_entity

Adds [Jsonapi v1.0](http://jsonapi.org/) sugar on [Grape-Entity](https://github.com/ruby-grape/grape-entity).

## Introduction


## Installation

Add the `grape`, `grape-entity` and `grape-jsonapi_entity` gems to Gemfile.

```ruby
gem 'grape'
gem 'grape-entity'
gem 'grape-jsonapi_entity'
```

Run `bundle install`.

## Usage

### Tell your API to use Grape::Jsonapi::Formatter

```ruby
class API < Grape::API
  format :jsonapi
  formatter :jsonapi, Grape::Jsonapi::Formatter
end
```

### Create a Jsonapi Resource

Following Json Api v 1.0 spec.  [Resource Objects](http://jsonapi.org/format/#document-resource-objects)
may expose the following fields
- id
- type
- attributes
- relationships

`id` field is automatically exposed by `Grape::Jsonapi::Entity::Resource`
`type` field is automatically exposed by `Grape::Jsonapi::Entity::Resource`, additionally it will make an attempt to automatically determine a type using either the
  plural word passed via the `root` method, or based on the class name of the resource entity.
`attributes` can be exposed using the `attribute` method, instead of `expose`.  All `expose` options and block syntax should work with `attribute`
`relationships` of [compound-documents](http://jsonapi.org/format/#document-compound-documents) can be represented using the `nest` method, and expects the `:using` option to be passed with another Resource Entity


#### Example Resources

```ruby
module API
  module Entities
    class Status < Grape::Jsonapi::Entity::Resource
      root 'statuses'

      format_with(:iso_timestamp) { |dt| dt.iso8601 }

      attribute :user_name
      attribute :text, documentation: { type: "String", desc: "Status update text." }
      attribute :ip, if: { type: :full }
      attribute :user_type, :user_id, if: lambda { |status, options| status.user.public? }
      attribute :location, merge: true
      attribute :contact_info do
        expose :phone
        expose :address, merge: true, using: API::Entities::Address
      end
      attribute :digest do |status, options|
        Digest::MD5.hexdigest status.txt
      end

      nest :replies, using: API::Entities::Status, as: :responses
      nest :last_reply, using: API::Entities::Status do |status, options|
        status.replies.last
      end

      with_options(format_with: :iso_timestamp) do
        attribute :created_at
        attribute :updated_at
      end
    end
  end
end

module API
  module Entities
    class StatusDetailed < Grape::Jsonapi::Entity::Resource
      attribute :internal_id
    end
  end
end
```

### Presenting

This follows the `grape-entity` use of [present](https://github.com/ruby-grape/grape#restful-model-representations).
but instead of passing your entity directly to :with, we wrap it in a factory call to nest the data inside Jsonapi's
[top level document structure](http://jsonapi.org/format/#document-top-level)

```ruby
  class Statuses < Grape::API
    version 'v1'

    desc 'Statuses index' do
      params: API::Entities::Status.documentation
    end

    get '/statuses' do
      statuses = Status.all
      type = current_user.admin? ? :full : :default
      present({ data: statuses },
        with: Grape::Jsonapi::Document.top(API::Entities::Status),
        type: type
      )
    end
  end
```

## TODO

### Document Structures
- [links](http://jsonapi.org/format/#document-links)
- [meta](http://jsonapi.org/format/#document-meta)
- [json api object](http://jsonapi.org/format/#document-jsonapi-object)

### Fetching & Parameters
- [sparce-fieldsets](http://jsonapi.org/format/#fetching-sparse-fieldsets)
- [sorting](http://jsonapi.org/format/#fetching-sorting)
- [pagination](http://jsonapi.org/format/#fetching-pagination)
- [filtering](http://jsonapi.org/format/#fetching-filtering)

### Error Handling
-

##Copyright and License

MIT License, see [LICENSE](LICENSE) for details.
