from setuptools import setup, Extension

import numpy
from Cython.Build import cythonize

ext_modules = cythonize(
    [
        Extension(
            "pylk._writhemap_cython",
            ["pylk/_writhemap_cython.pyx"],
            include_dirs=[numpy.get_include()],
        ),
        Extension(
            "pylk.linkingnumber_cython",
            ["pylk/linkingnumber_cython.pyx"],
            include_dirs=[numpy.get_include()],
        ),
    ],
    language_level=3,
)

setup(ext_modules=ext_modules)
