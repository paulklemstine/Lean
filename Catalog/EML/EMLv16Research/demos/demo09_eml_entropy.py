"""
Demo 9: EML Entropy vs Shannon Entropy
Compares H_EML(P) = Σ (p_i - ln(p_i)) with H_Shannon(P) = -Σ p_i ln(p_i)
for uniform and non-uniform distributions.
"""
import numpy as np
import matplotlib.pyplot as plt

def eml_entropy(p):
    """EML entropy of probability distribution p."""
    p = p[p > 0]
    return np.sum(p - np.log(p))

def shannon_entropy(p):
    """Shannon entropy of probability distribution p."""
    p = p[p > 0]
    return -np.sum(p * np.log(p))

# Uniform distributions of various sizes
ns = np.arange(2, 101)
eml_uniform = [eml_entropy(np.ones(n)/n) for n in ns]
shannon_uniform = [shannon_entropy(np.ones(n)/n) for n in ns]

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Left: Uniform distribution comparison
ax = axes[0]
ax.plot(ns, eml_uniform, 'r-', linewidth=2, label='H_EML (uniform)')
ax.plot(ns, shannon_uniform, 'b-', linewidth=2, label='H_Shannon (uniform)')
ax.plot(ns, ns * np.log(ns) / ns + 1, 'r--', alpha=0.5, label='≈ 1 + ln(n)')
ax.set_xlabel('n (number of outcomes)')
ax.set_ylabel('Entropy')
ax.set_title('EML vs Shannon Entropy (Uniform)')
ax.legend()
ax.grid(True, alpha=0.3)

# Middle: Ratio H_EML / H_Shannon
ax = axes[1]
ratios = np.array(eml_uniform) / np.array(shannon_uniform)
ax.plot(ns, ratios, 'purple', linewidth=2)
ax.set_xlabel('n')
ax.set_ylabel('H_EML / H_Shannon')
ax.set_title('Entropy Ratio (Uniform Distributions)')
ax.grid(True, alpha=0.3)

# Right: Binary distribution
ax = axes[2]
p_range = np.linspace(0.01, 0.99, 200)
eml_binary = [eml_entropy(np.array([p, 1-p])) for p in p_range]
shannon_binary = [shannon_entropy(np.array([p, 1-p])) for p in p_range]

ax.plot(p_range, eml_binary, 'r-', linewidth=2, label='H_EML')
ax.plot(p_range, shannon_binary, 'b-', linewidth=2, label='H_Shannon')
ax.set_xlabel('p')
ax.set_ylabel('Entropy')
ax.set_title('Binary Distribution (p, 1-p)')
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('eml_entropy.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved eml_entropy.png")
