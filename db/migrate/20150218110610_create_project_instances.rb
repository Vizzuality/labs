class CreateProjectInstances < ActiveRecord::Migration
  def change
    create_table :project_instances do |t|
      t.references :project, index: true
      t.string :name
      t.string :url
      t.text :backup_information
      t.string :stage
      t.string :branch
      t.text :description
      t.timestamps
    end

    add_reference :installations, :project_instance, index: true

    Installation.reset_column_information

    Installation.all.each do |installation|
      project = installation.project
      project_instance = ProjectInstance.find_by_project_id_and_stage(project.id,installation.stage)

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

  end
end
