
# Check if output file exists
if [ ! -f "test_results/simulation_output.txt" ]; then
    echo "No simulation output found. Run a simulation first."
    exit 1
fi

# Generate visualization data
python3 visualization/data_converter.py test_results/simulation_output.txt

# Try to open in browser
xdg-open visualization/index.html 2>/dev/null || \
open visualization/index.html 2>/dev/null || \
echo "Please open visualization/index.html in your browser manually"