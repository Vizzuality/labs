class CreateProjectInstances < ActiveRecord::Migration
  def up
    create_table :project_instances do |t|
      t.references :project, index: true, null: false
      t.string :name, null: false
      t.string :url, null: false
      t.text :backup_information
      t.string :stage, null: false
      t.string :branch
      t.text :description
      t.timestamps
    end

    add_reference :installations, :project_instance, index: true

    Installation.reset_column_information

    Installation.order('project_id, stage, CASE WHEN branch = \'Web\' THEN 1 WHEN branch = \'Database\' THEN 3 ELSE 2 END').each do |installation|
      project = installation.project
      project_instance = ProjectInstance.find_by_project_id_and_stage_and_branch(project.id,
        installation.stage, installation.branch)

      if project_instance.present?
        project_instance.installations << installation
      else
        ProjectInstance.create({name: project.title, project_id: project.id, url: project.url,
          backup_information: project.backup_information, stage: installation.stage,
          branch: installation.branch, description: installation.description,
          installations: [installation]
        })
      end
    end

    change_column :installations, :project_instance_id, :integer, null: false

  end

  def down
    ProjectInstance.destroy_all
    drop_table :project_instances

    remove_column :installations, :project_instance_id
  end
end
