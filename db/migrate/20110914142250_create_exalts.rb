class CreateExalts < ActiveRecord::Migration
  def change
    create_table :exalts do |t|
      t.references :user
      t.string :type, :null => false
      t.string :name, :null => false
      t.string :gender, :null => false, :limit => 1
      t.boolean :active, :null => false, :default => true
      t.integer :total_xp, :null => false, :default => 0
      t.integer :unspent_xp, :null => false, :default => 0
      t.string :caste, :null => false
      
      # All attributes
      %w<strength dexterity stamina 
         charisma manipulation appearance 
         perception intelligence wits>.each do |attr|
        t.integer attr.to_sym, :null => false, :default => 1
      end
      
      # All abilities, except craft (serialised Hash)
      %w<archery martial_arts melee thrown war
         integrity performance presence resistance survival
              investigation lore medicine occult
         athletics awareness dodge larceny stealth
         bureaucracy linguistics ride sail socialise>.sort.each do |abil|
        t.integer abil.to_sym, :null => false, :default => 0
      end
      t.string :craft, :null => false, :default => {}.to_yaml
      t.string :favoured

      t.timestamps
    end
  end
end
