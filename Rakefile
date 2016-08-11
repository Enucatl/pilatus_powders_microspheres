require "csv"

datasets = CSV.table "microsphere_datasets.csv"

def reconstructed_from_raw sample, flat
  p "sample", sample
  p "flat", flat
  file1 = File.basename(sample, ".*")
  file2 = File.basename(flat, ".*")
  dir = File.dirname(sample)
  File.join(dir, "#{file1}_#{file2}.h5")
end

datasets[:reconstructed] = datasets[:sample].zip(
  datasets[:flat]).map {|s, f| reconstructed_from_raw(s, f)}


namespace :reconstruction do

  datasets.each do |row|
    reconstructed = row[:reconstructed]

    desc "dpc_reconstruction of #{reconstructed}"
    file reconstructed => [row[:sample], row[:flat]] do |f|
      Dir.chdir "../dpc_reconstruction" do
        sh "dpc_radiography --group /entry/data #{f.prerequisites.join(' ')}"
      end
    end
  end

  desc "csv with reconstructed datasets"
  file "reconstructed.csv" => datasets[:reconstructed] do |f|
    File.open(f.name, "w") do |file|
      file.write(datasets.to_csv)
    end
  end

end
