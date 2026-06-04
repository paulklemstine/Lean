import matplotlib.pyplot as plt
import numpy as np

def rit(f, g):
    n = len(f)
    return [sum(f[j]*g[(j+k)%n] for j in range(n)) for k in range(n)]

rhythms = {
    '3-in-12': [1,0,0,0,1,0,0,0,1,0,0,0],
    '4-in-12': [1,0,0,1,0,0,1,0,0,1,0,0],
    '6-in-12': [1,0,1,0,1,0,1,0,1,0,1,0],
    'Bembe': [1,0,1,1,0,1,0,1,1,0,1,0],
}
names = list(rhythms.keys())
patterns = list(rhythms.values())
n_p = len(patterns)
fig, axes = plt.subplots(n_p, n_p, figsize=(14,14))
for i in range(n_p):
    for j in range(n_p):
        I = rit(patterns[i], patterns[j])
        ax = axes[i][j]
        ax.bar(range(12), I, color='steelblue' if i!=j else 'coral', alpha=0.8)
        if i==0: ax.set_title(names[j], fontsize=8)
        if j==0: ax.set_ylabel(names[i], fontsize=8)
plt.suptitle('Rhythmic Interaction Tensor Matrix')
plt.tight_layout()
plt.savefig('interaction_matrix.png', dpi=150)
print('Saved interaction_matrix.png')