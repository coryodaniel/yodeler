module ConfigHelper
  def get_config(name)
    YAML.load(File.read("./spec/fixtures/#{name}.yml"))
  end
end
