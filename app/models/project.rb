# == Schema Information
#
# Table name: projects
#
#  id                    :integer          not null, primary key
#  title                 :string(255)      not null
#  description           :text             not null
#  url                   :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  published             :boolean          default(FALSE)
#  screenshot            :string(255)
#  github_identifier     :string(255)
#  dependencies          :text
#  state                 :string(255)      not null
#  current_lead          :string(255)
#  hacks                 :text
#  external_clients      :text             default([]), is an Array
#  project_leads         :text             default([]), is an Array
#  developers            :text             default([]), is an Array
#  pdrive_folders        :text             default([]), is an Array
#  dropbox_folders       :text             default([]), is an Array
#  pivotal_tracker_ids   :text             default([]), is an Array
#  trello_ids            :text             default([]), is an Array
#  expected_release_date :date
#  rails_version         :string(255)
#  ruby_version          :string(255)
#  postgresql_version    :string(255)
#  other_technologies    :text             default([]), is an Array
#  internal_clients      :text             default([]), is an Array
#  internal_description  :text
#  background_jobs       :text
#  cron_jobs             :text
#  user_access           :text
#

class Project < ActiveRecord::Base
  # Add pg_search
  include PgSearch

  # Relationships
  has_many :comments, as: :commentable

  has_many :master_sub_relationship, :foreign_key => 'sub_project_id',
    :class_name => 'Dependency', :dependent => :destroy
  has_many :master_projects, :through => :master_sub_relationship

  has_many :sub_master_relationship, :foreign_key => 'master_project_id',
    :class_name => 'Dependency', :dependent => :destroy
  has_many :sub_projects, :through => :sub_master_relationship

  has_many :project_instances
  has_many :reviews, dependent: :destroy

  # Custom search scope for publically viewable projects
  pg_search_scope :search, :using => { :tsearch => {:prefix => true} },
    :against => [:title, :description, :github_identifier, :state, :internal_clients,
            :current_lead, :external_clients, :project_leads, :developers,
            :dependencies, :hacks, :pdrive_folders, :dropbox_folders,
            :pivotal_tracker_ids, :trello_ids, :expected_release_date,
            :rails_version, :ruby_version, :postgresql_version, :other_technologies]

  scope :published, -> { where(published: true) }

  # multisearchable against: [:title, :description, :github_identifier, :state, :internal_clients,
  #           :current_lead, :external_clients, :project_leads, :developers,
  #           :dependencies, :hacks, :pdrive_folders, :dropbox_folders, :published]

  # Validations
  validates :title, :description, :state, presence: true
  validates :url, if: :published, presence: true

  validates :url, format: { with: URI.regexp(%w(http https)) },
    if: Proc.new { |a| a.url.present? }
  validates :github_identifier, format: { with: /\A[-a-zA-Z0-9_.]+\/[-a-zA-Z0-9_.]+\z/i },
    if: Proc.new { |a| a.github_identifier.present? }
  validate :validate_trello_ids
  validate :validate_pivotal_tracker_ids

  validates :state, inclusion: { in: ['Under Development', 'Delivered', 'Project Development', 'Discontinued'] }

  accepts_nested_attributes_for :master_sub_relationship, allow_destroy: true
  accepts_nested_attributes_for :sub_master_relationship, allow_destroy: true

  after_update do |project|
    project.refresh_reviews
  end

  after_touch do |project|
    project.refresh_reviews
  end

  # Mount uploader for carrierwave
  mount_uploader :screenshot, ScreenshotUploader

  # Create array getter and setter methods for postgres
  ["developers","internal_clients","external_clients","project_leads","pdrive_folders","dropbox_folders",
    "pivotal_tracker_ids","trello_ids","other_technologies"].each do |attribute|
  	define_method("#{attribute}_array") do
  		self.send(attribute).join(',')
  	end

  	define_method("#{attribute}_array=") do |params|
      self.send("#{attribute}=", params.split(','))
      self.send(:save)
  	end
  end

  def last_review
    reviews.last
  end

  def team_members?
    !(developers.empty? || current_lead.blank?)
  end

  def instances_with_installations
    project_instances(true).includes(:installations).references(:installations).
      where('installations.id IS NOT NULL')
  end

  def production_instance?
    !instances_with_installations.where(stage: 'Production').empty?
  end

  def staging_instance?
    !instances_with_installations.where(stage: 'Staging').empty?
  end

  def production_backups?
    !instances_with_installations.where(stage: 'Production').
      where("backup_information IS NOT NULL AND backup_information != '' ").empty?
  end

  def refresh_reviews
    reviews.each{ |r| r.respond_to_project_update }
  end

  private

  def validate_trello_ids
    if self.trello_ids.detect{ |trello_id| !(/\A([a-z0-9]+\/[-a-z0-9_]+)\z/i.match(trello_id)) }
      errors.add(:trello_ids, :invalid)
    end
  end

  def validate_pivotal_tracker_ids
    if self.pivotal_tracker_ids.detect{ |pt_id| !(/\A\d+(,\d+)*\z/i.match(pt_id)) }
      errors.add(:pivotal_tracker_ids, :invalid)
    end
  end

  def self.pluck_field symbol
    pluck(symbol).compact.uniq.reject(&:empty?).sort
  end

end
