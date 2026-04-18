"""Demo 4: σ-EML as Neural Network Activation Function

Compares σ_eml(x) = exp(x) - ln(1 + exp(-x)) with standard activations:
ReLU, sigmoid, tanh, GELU, softplus, Swish/SiLU, and Mish.
"""
import numpy as np
import matplotlib.pyplot as plt

x = np.linspace(-4, 4, 1000)

# Activations
relu = np.maximum(0, x)
sigmoid = 1 / (1 + np.exp(-x))
tanh_act = np.tanh(x)
gelu = x * 0.5 * (1 + np.tanh(np.sqrt(2/np.pi) * (x + 0.044715 * x**3)))
softplus = np.log(1 + np.exp(x))
swish = x * sigmoid
sigma_eml = np.exp(x) - np.log(1 + np.exp(-x))

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: σ-EML vs others
axes[0,0].plot(x, sigma_eml, 'r-', linewidth=2.5, label='σ-EML')
axes[0,0].plot(x, relu, 'b--', linewidth=1.5, label='ReLU', alpha=0.7)
axes[0,0].plot(x, softplus, 'g--', linewidth=1.5, label='Softplus', alpha=0.7)
axes[0,0].plot(x, gelu, 'm--', linewidth=1.5, label='GELU', alpha=0.7)
axes[0,0].plot(x, swish, 'c--', linewidth=1.5, label='Swish', alpha=0.7)
axes[0,0].set_xlabel('x'); axes[0,0].set_ylabel('f(x)')
axes[0,0].set_title('σ-EML vs Standard Activations')
axes[0,0].legend(); axes[0,0].grid(True, alpha=0.3)
axes[0,0].set_ylim(-5, 15)

# Plot 2: Derivatives
d_relu = np.where(x > 0, 1, 0).astype(float)
d_sigmoid = sigmoid * (1 - sigmoid)
d_sigma_eml = np.exp(x) + np.exp(-x) / (1 + np.exp(-x))

axes[0,1].plot(x, d_sigma_eml, 'r-', linewidth=2.5, label="σ-EML'")
axes[0,1].plot(x, d_relu, 'b--', linewidth=1.5, label="ReLU'", alpha=0.7)
axes[0,1].plot(x, d_sigmoid, 'g--', linewidth=1.5, label="sigmoid'", alpha=0.7)
axes[0,1].set_xlabel('x'); axes[0,1].set_ylabel("f'(x)")
axes[0,1].set_title('Derivatives: σ-EML always > 0')
axes[0,1].legend(); axes[0,1].grid(True, alpha=0.3)
axes[0,1].set_ylim(-0.5, 10)

# Plot 3: Properties comparison table
props = {
    'Smooth': [True, False, True, True, True, True],
    'Monotone': [True, True, True, False, True, False],
    'Unbounded (+)': [True, True, True, True, True, True],
    'Unbounded (−)': [True, False, False, True, False, True],
    'Non-zero grad': [True, False, False, False, True, False],
    'Closed form': [True, True, True, False, True, True],
}
names = ['σ-EML', 'ReLU', 'Sigmoid', 'GELU', 'Softplus', 'Swish']

cell_colors = []
cell_text = []
for prop, vals in props.items():
    row_colors = []
    row_text = []
    for v in vals:
        row_colors.append('#90EE90' if v else '#FFB6C1')
        row_text.append('✓' if v else '✗')
    cell_colors.append(row_colors)
    cell_text.append(row_text)

axes[1,0].axis('off')
table = axes[1,0].table(cellText=cell_text, rowLabels=list(props.keys()),
                         colLabels=names, cellColours=cell_colors,
                         loc='center', cellLoc='center')
table.auto_set_font_size(False)
table.set_fontsize(10)
table.scale(1.2, 1.5)
axes[1,0].set_title('Activation Function Properties', pad=20)

# Plot 4: σ-EML growth comparison
axes[1,1].plot(x, sigma_eml, 'r-', linewidth=2, label='σ-EML(x)')
axes[1,1].plot(x, np.exp(x), 'b--', linewidth=1, label='exp(x)', alpha=0.5)
axes[1,1].plot(x, np.exp(x) - np.log(2) * np.ones_like(x), 'g:',
               linewidth=1, label='exp(x) - ln(2)', alpha=0.5)
axes[1,1].fill_between(x, np.exp(x) - np.log(2), sigma_eml, alpha=0.1, color='green')
axes[1,1].set_xlabel('x'); axes[1,1].set_ylabel('f(x)')
axes[1,1].set_title('σ-EML ≥ exp(x) - ln(2) for x ≥ 0 (V17)')
axes[1,1].legend(); axes[1,1].grid(True, alpha=0.3)
axes[1,1].set_ylim(-5, 15)

plt.tight_layout()
plt.savefig('/workspace/request-project/EML/EMLv17Research/demos/sigma_eml_activation.png', dpi=150)
plt.close()
print("Demo 4 complete: sigma_eml_activation.png")
