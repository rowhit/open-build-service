FactoryGirl.define do
  factory :package do
    project
    sequence(:name) { |n| "package_#{n}" }
    title { Faker::Book.title }
    description { Faker::Lorem.sentence }

    after(:create) do |package|
      # NOTE: Enable global write through when writing new VCR cassetes.
      # ensure the backend knows the project
      if CONFIG['global_write_through']
        Backend::Connection.put("/source/#{CGI.escape(package.project.name)}/#{CGI.escape(package.name)}/_meta", package.to_axml)
      end
    end

    factory :package_with_revisions do
      transient do
        revision_count 2
      end

      after(:create) do |package, evaluator|
        evaluator.revision_count.times do |i|
          if CONFIG['global_write_through']
            Backend::Connection.put("/source/#{package.project}/#{package}/somefile.txt", i.to_s)
          end
        end
      end
    end

    factory :package_with_file do
      after(:create) do |package|
        # NOTE: Enable global write through when writing new VCR cassetes.
        # ensure the backend knows the project
        if CONFIG['global_write_through']
          Backend::Connection.put("/source/#{CGI.escape(package.project.name)}/#{CGI.escape(package.name)}/_config", Faker::Lorem.paragraph)
          Backend::Connection.put("/source/#{CGI.escape(package.project.name)}/#{CGI.escape(package.name)}/somefile.txt", Faker::Lorem.paragraph)
        end
      end
    end

    factory :package_with_service do
      after(:create) do |package|
        # NOTE: Enable global write through when writing new VCR cassetes.
        # ensure the backend knows the project
        if CONFIG['global_write_through']
          Backend::Connection.put("/source/#{URI.escape(package.project.name)}/#{URI.escape(package.name)}/_service", '<services/>')
        end
      end
    end

    factory :package_with_broken_service do
      after(:create) do |package|
        # NOTE: Enable global write through when writing new VCR cassetes.
        # ensure the backend knows the project
        if CONFIG['global_write_through']
          Backend::Connection.put("/source/#{URI.escape(package.project.name)}/#{URI.escape(package.name)}/_service", '<service>broken</service>')
        end
      end
    end

    factory :package_with_kiwi_file do
      transient do
        kiwi_file_content '<?xml version="1.0" encoding="UTF-8"?>
<image name="Christians_openSUSE_13.2_JeOS" displayname="Christians_openSUSE_13.2_JeOS" schemaversion="5.2">
  <description type="system">
    <author>Christian Bruckmayer</author>
    <contact>noemail@example.com</contact>
    <specification>Tiny, minimalistic appliances</specification>
  </description>
</image>'
      end

      after(:create) do |package, evaluator|
        # NOTE: Enable global write through when writing new VCR cassetes.
        # ensure the backend knows the project
        if CONFIG['global_write_through']
          package_name = CGI.escape(package.name)
          Backend::Connection.put("/source/#{CGI.escape(package.project.name)}/#{package_name}/#{package_name}.kiwi", evaluator.kiwi_file_content)
        end
      end
    end

    factory :package_with_kiwi_image do
      kiwi_image
    end

    factory :package_with_failed_comment_attribute do
      after(:create) do |package|
        create(:project_status_package_fail_comment_attrib, package: package)
      end
    end
  end
end
