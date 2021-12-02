# frozen_string_literal: true

require 'additionals/plugin_version'

Redmine::Plugin.register :additionals do
  name 'Additionals'
  author 'AlphaNodes GmbH'
  description 'Customizing Redmine, providing wiki macros and act as a library/function provider for other Redmine plugins'
  version Additionals::PluginVersion::VERSION
  author_url 'https://alphanodes.com/'
  url 'https://github.com/alphanodes/additionals'
  directory __dir__

  default_settings = AdditionalsLoader.default_settings
  5.times do |i|
    default_settings["custom_menu#{i}_name"] = ''
    default_settings["custom_menu#{i}_url"] = ''
    default_settings["custom_menu#{i}_title"] = ''
  end

  settings default: default_settings, partial: 'additionals/settings/additionals'

  permission :show_hidden_roles_in_memberbox, {}
  permission :set_system_dashboards,
             {},
             require: :loggedin,
             read: true
  permission :share_dashboards,
             { dashboards: %i[index new create edit update destroy] },
             require: :member,
             read: true
  permission :save_dashboards,
             { dashboards: %i[index new create edit update destroy] },
             require: :loggedin,
             read: true

  project_module :issue_tracking do
    permission :edit_closed_issues, {}
    permission :edit_issue_author, {}
    permission :change_new_issue_author, {}
    permission :issue_timelog_never_required, {}
  end

  project_module :time_tracking do
    permission :log_time_on_closed_issues, {}
  end

  # required redmine version
  requires_redmine version_or_higher: '4.1'

  menu :admin_menu, :additionals, { controller: 'settings', action: 'plugin', id: 'additionals' }, caption: :label_additionals
end

AdditionalsLoader.persisting do
  Redmine::AccessControl.include Additionals::Patches::AccessControlPatch
  Redmine::AccessControl.singleton_class.prepend Additionals::Patches::AccessControlClassPatch

  # Deface support
  AdditionalsLoader.deface_setup!

  # Hooks
  AdditionalsLoader.load_hooks!
end

AdditionalsLoader.after_initialize do
  # @TODO: this should be moved to AdditionalsFontAwesome and use an instance of it
  FONTAWESOME_ICONS = { fab: AdditionalsFontAwesome.load_icons(:fab), # rubocop: disable Lint/ConstantDefinitionInBlock
                        far: AdditionalsFontAwesome.load_icons(:far),
                        fas: AdditionalsFontAwesome.load_icons(:fas) }.freeze
end

AdditionalsLoader.to_prepare { Additionals.setup } if Rails.version < '6.0'
