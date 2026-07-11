
from setuptools import setup, find_packages

setup(
    name="robotframework-keywords",
    version="1.0.0",
    description="Reusable Robot Framework Keywords",
    packages=find_packages(),
    install_requires=[
        "robotframework>=7.0.0",
    ],
)