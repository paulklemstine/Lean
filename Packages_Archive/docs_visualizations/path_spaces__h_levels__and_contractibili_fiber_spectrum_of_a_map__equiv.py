import matplotlib.pyplot as plt

src = [0, 1, 2, 3]
target = ['w', 'x', 'y', 'z']
bij = {0:'w', 1:'x', 2:'y', 3:'z'}
non = {0:'w', 1:'w', 2:'y', 3:'y'}

def spectrum(table):
    return [sum(1 for a in src if table[a] == b) for b in target]

fig, axes = plt.subplots(1, 2, figsize=(11, 4), sharey=True)
for ax, (name, table) in zip(axes, [('bijection', bij),
                                    ('non-bijection', non)]):
    spec = spectrum(table)
    ax.bar(target, spec,
           color=['seagreen' if s == 1 else 'indianred' for s in spec])
    ax.axhline(1, ls='--', c='black')
    ax.set_title(f'{name}: fibers {spec}')
    ax.set_xlabel('target b'); ax.set_ylabel('|HFiber(f, b)|')
fig.suptitle('Equivalence  <=>  fiber spectrum is constantly 1')
plt.tight_layout(); plt.savefig('fiber_spectrum.png', dpi=150)
print('wrote fiber_spectrum.png')
