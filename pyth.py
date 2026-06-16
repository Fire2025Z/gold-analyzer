from pathlib import Path

# Base lib folder
base_path = Path(r"C:\Users\LENOVO\Desktop\Zinar\Programming - 3D - Design\Flutter\gold_analyzer\lib")

# Folders to create
folders = [
    "core/constants",
    "core/themes",
    "core/utils",
    "core/widgets",

    "data/datasources",
    "data/models",
    "data/repositories",
    "data/services",

    "domain/entities",
    "domain/repositories",
    "domain/usecases",

    "presentation/providers",
    "presentation/screens",
    "presentation/widgets",
]

# Create folders
for folder in folders:
    (base_path / folder).mkdir(parents=True, exist_ok=True)

# Create main.dart if it doesn't exist
main_dart = base_path / "main.dart"
main_dart.touch(exist_ok=True)

print("✅ Flutter Clean Architecture structure created successfully!")