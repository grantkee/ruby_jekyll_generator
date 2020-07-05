# Description: this file generates the lesson.html file in each lesson directory
# for more information review generator plugins for Jekyll
require 'io/console'

module Jekyll

  class LessonPageGenerator < Jekyll::Generator
    safe true

    def generate(site)
      dir = site.config['lesson_dir'] || 'lessons'

      directory_files = File.join(dir, "*")
      files = Dir.glob(directory_files)

      # loop through all files in lessons directory
      # for every folder, create a lesson page
      files.each_with_index do |lessonDir, index|
        #if lessonDir is a folder and not a file
        if File.directory?(lessonDir)

          site.pages << LessonPage.new(site, site.source, lessonDir)

        end
      end
    end
  end

  # A Page subclass used in the `LessonPageGenerator`
  class LessonPage < Page
    def initialize(site, base, lessonDir)
      @site = site
      @base = base
      @dir  = lessonDir
      @name = 'lesson.html'

      # create empty arrays for A/B question types
      # add array if adding new type
      graphs = Array.new
      videos = Array.new
      audios = Array.new
      
      # loop through each question in the directory
      Dir.each_child(lessonDir){
        |file_name|
      
        comments = false
      
        IO.foreach(File.join(lessonDir, file_name)) {
          |line|
          line.strip!
          # only read lines between the two '---'
          if line == ('---')
            if comments == false
              comments = true
            else
              break
            end
          # add file to correct array in new lesson.html
          # this info tells the navbar which icon to use when the question has multiple parts

          # push file_name if adding new type
          else
            if line.start_with?('type')
              type = line[6..]
              type.strip!
              if type == 'graph'
                graphs.push(file_name.gsub('.html', ''))
              elsif type == 'video'
                videos.push(file_name.gsub('.html', ''))
              elsif type == 'audio'
                audios.push(file_name.gsub('.html', ''))
              end
            end
          end
        }
      }

      self.process(@name)

      # use the lesson.html in _layouts directory
      self.read_yaml(File.join(base, '_layouts'), 'lesson.html')

      # insert spaces into dir name for title data - later updated on fetch within lesson.html in _layouts
      subject = lessonDir.gsub('lessons/', '')
      result = subject.gsub(/(?<=[a-z])(?=[A-Z])/, ' ')

      # include these as frontmatter
      self.data['title'] = result
      self.data['graphs'] = graphs
      self.data['videos'] = videos
      self.data['audios'] = audios

    end
  end
end
