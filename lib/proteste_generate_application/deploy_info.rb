module ProtesteGenerateApplication
  class DeployInfo 

    def initialize
      
    end

    def self.revision_informations
      instance = self.new
      output = []
      output << instance.revision
      output << instance.deploy_release
      output << instance.deploy_date
      output.compact.join('<br />')
    end

    def revision
      file_path = File.join(Rails.root,'REVISION')
      return unless File.exists?(file_path)
      I18n.t('general.terms.revision', revision: File.open(file_path) {|f| f.readline})
    end

    def deploy_release
      file_path      = File.join(Rails.root,'DEPLOY_RELEASE')
      deploy_release = 'develop'
      if File.exists?(file_path)
        begin
          _deploy_release = File.open(file_path) {|f| f.readline}
          deploy_release  = _deploy_release unless _deploy_release.to_s.strip.blank?
        rescue
        end
      end
      I18n.t('general.terms.deploy_release', release: deploy_release)
    end

    def deploy_date
      file_path   = File.join(Rails.root,'DEPLOY_DATE')
      deploy_date = Date.today
      if File.exists?(file_path)
        begin
          _deploy_date = File.open(file_path) {|f| f.readline}
          deploy_date  = Date.parse(_deploy_date) unless _deploy_date.to_s.strip.blank?
        rescue
        end
      end
      I18n.t('general.terms.deploy_date', date: deploy_date.strftime("%d/%m/%Y"))
    end
  end
end