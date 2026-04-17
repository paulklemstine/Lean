"""
Demo 3: σ-EML vs Standard Activation Functions
Compares σ_EML(x) = exp(x) - ln(1 + exp(-x)) with ReLU, sigmoid, softplus, and GELU.
"""
import numpy as np
import matplotlib.pyplot as plt

def sigma_eml(x):
    return np.exp(x) - np.log(1 + np.exp(-x))

def relu(x):
    return np.maximum(0, x)

def sigmoid(x):
    return 1 / (1 + np.exp(-x))

def softplus(x):
    return np.log(1 + np.exp(x))

def gelu(x):
    return x * 0.5 * (1 + np.tanh(np.sqrt(2/np.pi) * (x + 0.044715 * x**3)))

x = np.linspace(-3, 3, 500)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Function comparison
ax = axes[0]
ax.plot(x, sigma_eml(x), 'r-', linewidth=2.5, label='σ-EML')
ax.plot(x, relu(x), 'b--', linewidth=1.5, label='ReLU')
ax.plot(x, sigmoid(x), 'g-.', linewidth=1.5, label='Sigmoid')
ax.plot(x, softplus(x), 'm:', linewidth=1.5, label='Softplus')
ax.plot(x, gelu(x), 'c--', linewidth=1.5, label='GELU')
ax.axhline(y=0, color='k', linewidth=0.5)
ax.axvline(x=0, color='k', linewidth=0.5)
ax.set_xlabel('x')
ax.set_ylabel('f(x)')
ax.set_title('σ-EML vs Standard Activations')
ax.legend()
ax.set_ylim(-2, 10)
ax.grid(True, alpha=0.3)

# Right: Derivative comparison
ax = axes[1]
dx = 0.001
sigma_eml_deriv = (sigma_eml(x + dx) - sigma_eml(x - dx)) / (2 * dx)
relu_deriv = np.where(x > 0, 1, 0).astype(float)
sigmoid_deriv = sigmoid(x) * (1 - sigmoid(x))
softplus_deriv = sigmoid(x)
gelu_deriv = (gelu(x + dx) - gelu(x - dx)) / (2 * dx)

ax.plot(x, sigma_eml_deriv, 'r-', linewidth=2.5, label="σ-EML'")
ax.plot(x, relu_deriv, 'b--', linewidth=1.5, label="ReLU'")
ax.plot(x, sigmoid_deriv, 'g-.', linewidth=1.5, label="Sigmoid'")
ax.plot(x, softplus_deriv, 'm:', linewidth=1.5, label="Softplus'")
ax.plot(x, gelu_deriv, 'c--', linewidth=1.5, label="GELU'")
ax.axhline(y=0, color='k', linewidth=0.5)
ax.set_xlabel('x')
ax.set_ylabel("f'(x)")
ax.set_title('Derivatives of Activation Functions')
ax.legend()
ax.set_ylim(-1, 10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('sigma_eml_activations.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved sigma_eml_activations.png")
