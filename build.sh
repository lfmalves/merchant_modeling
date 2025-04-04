#!/bin/bash
echo "Compiling modules..."
gfortran -c machining_types.f90 || exit 1

echo "Compiling main program..."
gfortran -o machining_simulator machining_simulator.f90 machining_types.o || exit 1

echo "Build complete!"
echo "Run it with: ./machining_simulator [optional_output_filename.txt]"
