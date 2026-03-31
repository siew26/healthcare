"""@bruin
name: download_data
type: python
@bruin"""

import kagglehub
import os
import shutil

def main():
    path = kagglehub.dataset_download("eduardolicea/healthcare-dataset")
    print("Path to dataset files:", path)

    data_folder = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../../data"))
    os.makedirs(data_folder, exist_ok=True)

    csv_file = None
    for file in os.listdir(path):
        if file.endswith(".csv"):
            csv_file = os.path.join(path, file)
            target_file = os.path.join(data_folder, file)
            shutil.copy(csv_file, target_file)
            print(f"Copied CSV to: {target_file}")
            break

    if not csv_file:
        raise FileNotFoundError("No CSV file found in the downloaded dataset.")

if __name__ == "__main__":
    main()
