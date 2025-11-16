import matplotlib.pyplot as plt
import pandas as pd

data = pd.read_csv('bm.csv')
data.columns = data.columns.str.strip()

x_col = 'Size (bytes)'
y_col = 'Mean time (μs)'
group_col = 'Method'

plt.figure(figsize=(10, 6))

markers = ['o', 's', '^', 'D', 'v', 'p', '*']
for i, (method_name, group_data) in enumerate(data.groupby(group_col)):
  current_marker = markers[i % len(markers)]
  plt.plot(
    group_data[x_col],
    group_data[y_col],
    marker=current_marker,
    linestyle='-',
    label=method_name)

plt.title('Performance Benchmark of CRC32 Script')
plt.xlabel(x_col)
plt.ylabel(f'{y_col} (Log Scale)')

plt.yscale('log')

plt.grid(True, which="both", ls="--", linewidth=0.5)
plt.legend(title=group_col, loc='lower right')

output_filename = 'bm.png'
plt.savefig(output_filename)
print(f"Plot saved successfully as '{output_filename}'")
