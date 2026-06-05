import numpy as np
import matplotlib.pyplot as plt

def plot_softplus_sigmoid():
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    xs = np.linspace(-5, 5, 200)
    
    softplus = np.log(1 + np.exp(xs))
    sigmoid = np.exp(xs) / (1 + np.exp(xs))
    
    axes[0].plot(xs, softplus, 'b-', linewidth=2, label='softplus = log(1+exp(x))')
    axes[0].plot(xs, xs, 'gray', linestyle='--', alpha=0.5, label='y = x (asymptote)')
    axes[0].set_title('Softplus (EML function)', fontsize=12)
    axes[0].set_xlabel('x')
    axes[0].legend(fontsize=10)
    axes[0].grid(True, alpha=0.3)
    
    # Numerical derivative for verification
    h = 0.01
    num_deriv = (np.log(1+np.exp(xs+h)) - np.log(1+np.exp(xs-h))) / (2*h)
    
    axes[1].plot(xs, sigmoid, 'r-', linewidth=2, label='sigmoid = exp(x)/(1+exp(x))')
    axes[1].plot(xs, num_deriv, 'k--', linewidth=1, alpha=0.5, label='numerical d/dx[softplus]')
    axes[1].axhline(y=0.5, color='gray', linestyle=':', alpha=0.5)
    axes[1].axhline(y=1, color='gray', linestyle=':', alpha=0.5)
    axes[1].set_title('Sigmoid = d/dx[Softplus]', fontsize=12)
    axes[1].set_xlabel('x')
    axes[1].legend(fontsize=10)
    axes[1].grid(True, alpha=0.3)
    
    plt.suptitle('EML Derivative: softplus\' = sigmoid', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('softplus_sigmoid.png', dpi=150, bbox_inches='tight')
    plt.show()

plot_softplus_sigmoid()