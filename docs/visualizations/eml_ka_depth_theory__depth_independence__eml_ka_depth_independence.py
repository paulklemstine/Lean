import numpy as np
import matplotlib.pyplot as plt

def eml_ka_depth(a, b):
    return 1

def naive_depth(a, b):
    return abs(a) + abs(b)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))
exponents = np.arange(1, 51)
eml_depths = [eml_ka_depth(n, n) for n in exponents]
naive_depths = [naive_depth(n, n) for n in exponents]
axes[0].plot(exponents, naive_depths, 'r-o', markersize=3, label='Naive')
axes[0].plot(exponents, eml_depths, 'b-s', markersize=4, label='EML-KA')
axes[0].set_xlabel('Exponent n')
axes[0].set_ylabel('Depth')
axes[0].set_title('Depth Independence')
axes[0].legend()
axes[0].set_yscale('log')
axes[0].grid(True, alpha=0.3)

x_vals = np.linspace(-2, 3, 200)
s_vals = np.linspace(0.1, 10, 200)
X, S = np.meshgrid(x_vals, s_vals)
FY = np.exp(X) + S * np.log(S) - S - X * S
FY = np.clip(FY, 0, 20)
im = axes[1].contourf(X, S, FY, levels=20, cmap='viridis')
plt.colorbar(im, ax=axes[1])
x_curve = np.linspace(-2, 2.3, 100)
axes[1].plot(x_curve, np.exp(x_curve), 'r-', linewidth=2, label='s=exp(x)')
axes[1].set_xlabel('x')
axes[1].set_ylabel('s')
axes[1].set_title('Fenchel-Young Gap')
axes[1].legend(fontsize=8)

p_vals = np.linspace(0.1, 5, 200)
q = 2.0
B_exp = np.exp(p_vals) - np.exp(q) - np.exp(q) * (p_vals - q)
B_neglog = -np.log(p_vals) + np.log(q) + (1/q) * (p_vals - q)
KL = p_vals * np.log(p_vals / q) - (p_vals - q)
axes[2].plot(p_vals, B_exp, 'r-', label='Bregman(exp)')
axes[2].plot(p_vals, B_neglog, 'b-', label='Bregman(-log)')
axes[2].plot(p_vals, KL, 'g--', label='KL')
axes[2].axhline(y=0, color='k', linewidth=0.5)
axes[2].set_xlabel('p')
axes[2].set_ylabel('Divergence')
axes[2].set_title('EML Divergences (q=2)')
axes[2].legend(fontsize=8)
axes[2].set_ylim(-1, 15)
axes[2].grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('eml_ka_depth_theory.png', dpi=150)
plt.close()
print('Saved: eml_ka_depth_theory.png')