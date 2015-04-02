module OrganizationRelative 
	extend ActiveSupport::Concern
	included do
		belongs_to :organization
		validates :organization_id, presence: true
		scope :published, -> { where(active: true) }
		scope :self_organization, ->(e) { where("organization_id = ?", e.organization_id) } 
	end
end