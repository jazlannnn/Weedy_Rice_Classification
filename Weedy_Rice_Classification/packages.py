import os

site_packages = r"c:\yolov5_env\WeedyRice_Classification\new-env\Lib\site-packages"
packages = []

for item in os.listdir(site_packages):
    if item.endswith('.dist-info'):
        name_version = item.split('.dist-info')[0]
        packages.append(name_version)

with open("package_versions.txt", "w") as f:
    for package in packages:
        f.write(f"{package}\n")
