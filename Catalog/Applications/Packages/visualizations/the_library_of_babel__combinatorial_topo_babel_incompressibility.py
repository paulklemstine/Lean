#!/usr/bin/env python3
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

alpha = 25
savings = np.arange(1, 201)
log_fraction = -savings * np.log10(alpha)

fig, ax = plt.subplots(figsize=(10, 6))
ax.plot(savings, log_fraction, 'b-', linewidth=2)
ax.set_xlabel('Characters saved', fontsize=12)
ax.set_ylabel('log₁₀(compressible fraction)', fontsize=12)
ax.set_title('Library of Babel: Incompressibility', fontsize=14)
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('babel_incompressibility.png', dpi=150)
plt.close()
print('Saved babel_incompressibility.png')