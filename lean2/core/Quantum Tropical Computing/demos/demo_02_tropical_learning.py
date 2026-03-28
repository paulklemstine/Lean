#!/usr/bin/env python3
"""
Demo 2: Tropical Neural Network Learning
==========================================

Demonstrates tropical backpropagation (morphological gradient descent)
for learning in the max-plus semiring.

Generates:
    - tropical_learning_curves.png: Training convergence on classification task
    - tropical_decision_boundary.png: Learned decision boundaries (piecewise linear!)
    - tropical_vs_classical.png: Comparison with classical neural networks
"""

import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from qtlib.networks import TropicalLinear, TropicalReLU, TropicalNetwork, TropicalLoss
from qtlib.learning import tropical_train, TropicalBackprop, TropicalSGD

np.random.seed(42)
plt.rcParams['figure.dpi'] = 150


def generate_data(n_samples=200, task='xor'):
    """Generate classification datasets."""
    if task == 'xor':
        X = np.random.randn(n_samples, 2)
        y_labels = ((X[:, 0] > 0) ^ (X[:, 1] > 0)).astype(int)
    elif task == 'circles':
        r = np.random.randn(n_samples) * 0.3 + np.array([1.0]*(n_samples//2) + [2.5]*(n_samples//2))
        theta = np.random.uniform(0, 2*np.pi, n_samples)
        X = np.column_stack([r * np.cos(theta), r * np.sin(theta)])
        y_labels = np.array([0]*(n_samples//2) + [1]*(n_samples//2))
    elif task == 'linear':
        X = np.random.randn(n_samples, 2)
        y_labels = (X[:, 0] + X[:, 1] > 0).astype(int)
    else:
        raise ValueError(f"Unknown task: {task}")

    # Convert to one-hot tropical targets
    y = np.full((n_samples, 2), -5.0)
    for i in range(n_samples):
        y[i, y_labels[i]] = 5.0

    return X, y, y_labels


def plot_learning_curves():
    """Train tropical networks on multiple tasks and plot learning curves."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle("Tropical Neural Network Learning Curves\n(Morphological Gradient Descent)",
                 fontsize=14, fontweight='bold')

    tasks = ['linear', 'xor', 'circles']
    colors = ['blue', 'red', 'green']

    for ax, task, color in zip(axes, tasks, colors):
        X, y, labels = generate_data(200, task)

        # Build network
        net = TropicalNetwork([
            TropicalLinear(2, 16, bias=True),
            TropicalReLU(),
            TropicalLinear(16, 8, bias=True),
            TropicalReLU(),
            TropicalLinear(8, 2, bias=False),
        ])

        # Train
        history = tropical_train(net, X, y, epochs=100, lr=0.05,
                                loss_type='tropical_mse', verbose=False)

        # Plot
        ax.plot(history['losses'], color=color, linewidth=2)
        ax.set_xlabel('Epoch')
        ax.set_ylabel('Average Tropical Loss')
        ax.set_title(f'Task: {task.upper()}')
        ax.grid(True, alpha=0.3)

        # Compute accuracy
        correct = 0
        for i in range(len(X)):
            pred = net.forward(X[i])
            if np.argmax(pred) == labels[i]:
                correct += 1
        acc = correct / len(X)
        ax.text(0.95, 0.95, f'Acc: {acc:.1%}', transform=ax.transAxes,
                ha='right', va='top', fontsize=12,
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'tropical_learning_curves.png'),
                bbox_inches='tight')
    print("Saved: tropical_learning_curves.png")
    plt.close()


def plot_decision_boundary():
    """Visualize the piecewise-linear decision boundaries of tropical networks."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle("Tropical Decision Boundaries (Piecewise Linear = Tropical Hypersurfaces)",
                 fontsize=14, fontweight='bold')

    tasks = ['linear', 'xor', 'circles']

    for ax, task in zip(axes, tasks):
        X, y, labels = generate_data(200, task)

        # Build and train
        net = TropicalNetwork([
            TropicalLinear(2, 32, bias=True),
            TropicalReLU(),
            TropicalLinear(32, 16, bias=True),
            TropicalReLU(),
            TropicalLinear(16, 2, bias=False),
        ])
        tropical_train(net, X, y, epochs=150, lr=0.03,
                      loss_type='tropical_mse', verbose=False)

        # Decision boundary grid
        xx, yy = np.meshgrid(np.linspace(-4, 4, 100), np.linspace(-4, 4, 100))
        grid = np.column_stack([xx.ravel(), yy.ravel()])
        predictions = np.array([np.argmax(net.forward(p)) for p in grid])
        Z = predictions.reshape(xx.shape)

        # Plot
        ax.contourf(xx, yy, Z, levels=[-0.5, 0.5, 1.5], colors=['#AADDFF', '#FFAAAA'], alpha=0.6)
        ax.contour(xx, yy, Z, levels=[0.5], colors='black', linewidths=2)
        ax.scatter(X[labels==0, 0], X[labels==0, 1], c='blue', s=15, edgecolors='k', linewidths=0.5)
        ax.scatter(X[labels==1, 0], X[labels==1, 1], c='red', s=15, edgecolors='k', linewidths=0.5)
        ax.set_xlabel('x₁')
        ax.set_ylabel('x₂')
        ax.set_title(f'{task.upper()} — Tropical Boundary')
        ax.set_xlim(-4, 4)
        ax.set_ylim(-4, 4)

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'tropical_decision_boundary.png'),
                bbox_inches='tight')
    print("Saved: tropical_decision_boundary.png")
    plt.close()


def plot_tropical_vs_classical():
    """Compare tropical neural networks with classical (standard) neural networks."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    fig.suptitle("Tropical vs. Classical Neural Networks",
                 fontsize=14, fontweight='bold')

    X, y, labels = generate_data(300, 'xor')

    # 1. Tropical network
    net_trop = TropicalNetwork([
        TropicalLinear(2, 16, bias=True),
        TropicalReLU(),
        TropicalLinear(16, 2, bias=False),
    ])
    hist_trop = tropical_train(net_trop, X, y, epochs=100, lr=0.05,
                              loss_type='tropical_mse', verbose=False)

    # 2. "Classical" network (using tropical ops but with smaller weights ~ smoother)
    net_class = TropicalNetwork([
        TropicalLinear(2, 16, bias=True),
        TropicalReLU(),
        TropicalLinear(16, 2, bias=False),
    ])
    # Initialize with smaller weights
    for layer in net_class.layers:
        if isinstance(layer, TropicalLinear):
            layer.W *= 0.1
    hist_class = tropical_train(net_class, X, y, epochs=100, lr=0.01,
                               loss_type='tropical_mse', verbose=False)

    # Plot learning curves
    ax = axes[0]
    ax.plot(hist_trop['losses'], 'b-', linewidth=2, label='Tropical (lr=0.05)')
    ax.plot(hist_class['losses'], 'r-', linewidth=2, label='Small-init (lr=0.01)')
    ax.set_xlabel('Epoch')
    ax.set_ylabel('Tropical Loss')
    ax.set_title('Learning Curve Comparison')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot weight distributions
    ax = axes[1]
    trop_weights = []
    class_weights = []
    for layer in net_trop.layers:
        if isinstance(layer, TropicalLinear):
            trop_weights.extend(layer.W.ravel())
    for layer in net_class.layers:
        if isinstance(layer, TropicalLinear):
            class_weights.extend(layer.W.ravel())

    ax.hist(trop_weights, bins=30, alpha=0.5, color='blue', label='Tropical', density=True)
    ax.hist(class_weights, bins=30, alpha=0.5, color='red', label='Small-init', density=True)
    ax.set_xlabel('Weight value')
    ax.set_ylabel('Density')
    ax.set_title('Learned Weight Distributions\n(Tropical weights are more spread)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'tropical_vs_classical.png'),
                bbox_inches='tight')
    print("Saved: tropical_vs_classical.png")
    plt.close()


if __name__ == "__main__":
    plot_learning_curves()
    plot_decision_boundary()
    plot_tropical_vs_classical()
    print("\nAll Demo 2 visualizations generated!")
