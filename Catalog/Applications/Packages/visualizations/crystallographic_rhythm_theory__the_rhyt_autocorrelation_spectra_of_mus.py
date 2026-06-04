import matplotlib.pyplot as plt
import numpy as np

def compute_autocorrelation(rhythm):
    n = len(rhythm)
    return [sum(rhythm[j] * rhythm[(j+k)%n] for j in range(n)) for k in range(n)]

rhythms = [
    ([1,0,0,1,0,0,1,0,0,0,1,0,1,0,0,0], 'Son Clave', '#e74c3c'),
    ([1,0,0,1,0,0,1,0], 'Tresillo', '#3498db'),
    ([1,0,0,1,0,0,1,0,0,1,0,0], 'Max Even 4/12', '#2ecc71'),
    ([1,0,1,0,1,0,1,0,1,0,1,0], 'Whole-tone 6/12', '#9b59b6'),
]
fig, axes = plt.subplots(len(rhythms), 1, figsize=(10, 8))
for i, (r, name, color) in enumerate(rhythms):
    R = compute_autocorrelation(r)
    axes[i].bar(range(len(r)), R, color=color, alpha=0.8)
    axes[i].set_title(f'{name}: R palindromic, sum={sum(R)}=w^2={sum(r)**2}')
plt.tight_layout()
plt.savefig('autocorrelation_spectra.png', dpi=150)
print('Saved autocorrelation_spectra.png')