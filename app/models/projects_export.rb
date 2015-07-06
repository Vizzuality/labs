class ProjectsExport
  def initialize
    @projects = Project.from('projects_export AS projects').
    order('projects.title')

    @columns = [
      'ID',
      'Name',
      'URL',
      'Description',
      'Internal description',
      'External clients',
      'Internal clients',
      'Project leads',
      'Current lead',
      'Developers',
      'Expected release date',
      'State',
      'User access',
      '# of instances',
      'Github ID',
      'Rails version',
      'Ruby version',
      'PostgreSQL version',
      'Other technologies',
      'System dependencies',
      'Background jobs',
      'Cron jobs',
      'Hacks',
      'Projects this p. depends on',
      'Projects that depend on this p.',
      'Created at',
      'Updated at'
    ]
    @file_name = "#{Rails.root}/public/downloads/projects_#{Date.today}.csv"
  end

  def export
    File.open(@file_name, 'w') do |f|
      f.write PgCsv.new(
        sql: @projects.to_sql,
        columns: @columns,
        encoding: 'UTF8',
        type: :plain
      ).export
    end
    @file_name
  end
end