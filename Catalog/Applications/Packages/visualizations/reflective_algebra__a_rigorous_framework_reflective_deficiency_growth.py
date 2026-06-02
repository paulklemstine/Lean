import matplotlib.pyplot as plt
import numpy as np
from math import comb

def idempotent_count(n):
    return sum(comb(n, k) * (k ** (n - k)) for k in range(n + 1))

ns = list(range(1, 8))
total = [n**n for n in ns]
deficiency = [n**n - n for n in ns]
idem = [idempotent_count(n) for n in ns]

fig, ax = plt.subplots(1, 2, figsize=(12, 5))
ax[0].bar(np.array(ns)-0.2, total, 0.4, label='Total endos', color='steelblue')
ax[0].bar(np.array(ns)+0.2, ns, 0.4, label='Representable', color='coral')
ax[0].set_yscale('log'); ax[0].legend(); ax[0].set_title('Finiteness Barrier')
ax[1].plot(ns, idem, 'D-', color='purple', label='Idempotents')
ax[1].plot(ns, total, 'o--', color='gray', label='All endos')
ax[1].set_yscale('log'); ax[1].legend(); ax[1].set_title('Observations Count')
plt.tight_layout(); plt.savefig('deficiency.png', dpi=150); plt.show()