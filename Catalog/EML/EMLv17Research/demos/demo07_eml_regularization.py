"""Demo 7: EML Regularization — "Elastic Log" Penalty

Visualizes the EML-inspired regularizer R(w) = |w| - ln|w| which penalizes
both very large AND very small weights, with optimal point at |w| = 1.
"""
import numpy as np
import matplotlib.pyplot as plt

w = np.linspace(0.01, 5, 1000)

# Regularizers
eml_reg = w - np.log(w)  # EML regularizer: |w| - ln|w|
l2_reg = w**2             # L2
l1_reg = w                # L1
elastic = w + 0.5 * w**2  # Elastic net

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Regularizer comparison
axes[0,0].plot(w, eml_reg, 'r-', linewidth=2.5, label='EML: |w| - ln|w|')
axes[0,0].plot(w, l2_reg, 'b--', linewidth=1.5, label='L2: w²', alpha=0.7)
axes[0,0].plot(w, l1_reg, 'g--', linewidth=1.5, label='L1: |w|', alpha=0.7)
axes[0,0].plot(w, elastic, 'm--', linewidth=1.5, label='Elastic: |w| + w²/2', alpha=0.7)
axes[0,0].plot(1, 1, 'r*', markersize=15, label='EML min at |w|=1')
axes[0,0].set_xlabel('|w|'); axes[0,0].set_ylabel('R(w)')
axes[0,0].set_title('Regularizer Comparison')
axes[0,0].legend(); axes[0,0].grid(True, alpha=0.3)
axes[0,0].set_ylim(0, 8)

# Plot 2: EML regularizer gradient
grad_eml = 1 - 1/w
axes[0,1].plot(w, grad_eml, 'r-', linewidth=2, label="R'(w) = 1 - 1/w")
axes[0,1].axhline(y=0, color='k', linestyle='-', alpha=0.3)
axes[0,1].axvline(x=1, color='gray', linestyle=':', alpha=0.5, label='|w| = 1')
axes[0,1].fill_between(w[w < 1], grad_eml[w < 1], 0, alpha=0.2, color='red',
                        label='Pushes toward 1 (from below)')
axes[0,1].fill_between(w[w > 1], grad_eml[w > 1], 0, alpha=0.2, color='blue',
                        label='Pushes toward 1 (from above)')
axes[0,1].set_xlabel('|w|'); axes[0,1].set_ylabel("R'(w)")
axes[0,1].set_title('EML Regularizer Gradient')
axes[0,1].legend(fontsize=9); axes[0,1].grid(True, alpha=0.3)

# Plot 3: Effect on weight distribution
np.random.seed(42)
w_init = np.random.randn(1000)
lambda_vals = [0, 0.1, 0.5, 1.0]

axes[1,0].hist(np.abs(w_init), bins=50, alpha=0.5, density=True, label='Initial |w|')
# Simulate one step of gradient descent with EML regularizer
for lam in [0.1, 0.5]:
    w_reg = w_init - lam * np.sign(w_init) * (1 - 1/(np.abs(w_init) + 0.01))
    axes[1,0].hist(np.abs(w_reg), bins=50, alpha=0.4, density=True,
                   label=f'After EML reg (λ={lam})')
axes[1,0].axvline(x=1, color='red', linestyle='--', label='Target |w|=1')
axes[1,0].set_xlabel('|w|'); axes[1,0].set_ylabel('Density')
axes[1,0].set_title('Weight Distribution Under EML Regularization')
axes[1,0].legend(fontsize=9); axes[1,0].grid(True, alpha=0.3)

# Plot 4: Loss landscape with regularization
x_loss = np.linspace(-3, 3, 500)
data_loss = (x_loss - 0.5)**2  # Simple quadratic data loss
total_loss_l2 = data_loss + 0.3 * x_loss**2
total_loss_eml = data_loss + 0.3 * (np.abs(x_loss) - np.log(np.abs(x_loss) + 0.01))

axes[1,1].plot(x_loss, data_loss, 'k-', linewidth=1, label='Data loss', alpha=0.5)
axes[1,1].plot(x_loss, total_loss_l2, 'b-', linewidth=2, label='Data + L2', alpha=0.7)
axes[1,1].plot(x_loss, total_loss_eml, 'r-', linewidth=2, label='Data + EML', alpha=0.7)
axes[1,1].set_xlabel('w'); axes[1,1].set_ylabel('Loss')
axes[1,1].set_title('Total Loss: EML vs L2 Regularization')
axes[1,1].legend(); axes[1,1].grid(True, alpha=0.3)
axes[1,1].set_ylim(0, 5)

plt.tight_layout()
plt.savefig('/workspace/request-project/EML/EMLv17Research/demos/eml_regularization.png', dpi=150)
plt.close()
print("Demo 7 complete: eml_regularization.png")
