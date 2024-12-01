import sys
from datasets import load_dataset

if len(sys.argv) != 2:
   print("Usage: python script.py <dataset_path>")
   sys.exit(1)

dataset_path = sys.argv[1]

try:
   dataset = load_dataset(dataset_path, trust_remote_code=True)
   # If we successfully loaded it, exit with error
   print(f"Dataset {dataset_path} loaded successfully - this is unexpected")  
   sys.exit(1)
except Exception as e:
   # If we failed to load it, exit normally
   print(f"Dataset {dataset_path} failed to load as expected: {str(e)}")
   sys.exit(0)