import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def kleene_chain(phi, bot, n):
    chain = [bot]
    for _ in range(n):
        chain.append(phi(chain[-1]))
    return chain

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Kleene Chain Hierarchy', fontsize=14, fontweight='bold')

for ax, (name, phi, fp) in zip(axes.flat, [
    ('(x+1)/2', lambda x: (x+1)/2, 1.0),
    ('sqrt(x)+0.1', lambda x: np.sqrt(max(x,0))+0.1, 1.1756),
    ('sin(x)+0.5', lambda x: np.sin(x)+0.5, 1.4973),
    ('(x+0.5)/2', lambda x: (x+0.5)/2, 0.5)
]):
    chain = kleene_chain(phi, 0, 20)
    ax.plot(chain, 'bo-', ms=4)
    ax.axhline(y=fp, color='r', ls='--', alpha=0.7)
    ax.set_title(f'Phi(x) = {name}')
    ax.set_xlabel('n'); ax.set_ylabel('Phi^n(bot)')
    ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('kleene_chains.png', dpi=150)
plt.close()
