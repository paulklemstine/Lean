#!/usr/bin/env python3
"""
Visualization: Layer Descent Trajectories

Visualizes descent trajectories through layered state spaces, showing
how the layer profile forces minimum path lengths. Demonstrates the
adversarial construction that achieves the lower bound.

This is a self-contained script — no local imports.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def simulate_layered_descent(d, k, num_trials=20, grid_size=None):
    """Simulate descent and record layer trajectories."""
    if grid_size is None:
        grid_size = min(d, 6)
    hard_dims = max(d - k - 1, 1)

    trajectories = []
    for _ in range(num_trials):
        state = [grid_size - 1] * hard_dims
        layer_vals = [sum(state)]
        steps = 0

        while any(s > 0 for s in state):
            nonzero = [i for i, s in enumerate(state) if s > 0]
            if not nonzero:
                break
            idx = nonzero[np.random.randint(len(nonzero))]
            state[idx] -= 1
            steps += 1
            layer_vals.append(sum(state))

            if steps > 500:
                break

        trajectories.append(layer_vals)

    return trajectories


def main():
    fig, axes = plt.subplots(2, 3, figsize=(16, 10))

    # Row 1: Trajectories for different (d, k) combinations
    configs = [(6, 0), (6, 2), (6, 4)]
    for idx, (d, k) in enumerate(configs):
        ax = axes[0, idx]
        trajs = simulate_layered_descent(d, k, num_trials=15, grid_size=5)

        for traj in trajs:
            ax.plot(range(len(traj)), traj, alpha=0.4, linewidth=1)

        # Plot the theoretical minimum slope (layer drops by at most 1 per step)
        max_layer = trajs[0][0] if trajs else 10
        min_path = list(range(max_layer, -1, -1))
        ax.plot(range(len(min_path)), min_path, 'r--', linewidth=2,
                label='Min slope (1 layer/step)')

        ax.set_xlabel('Step')
        ax.set_ylabel('Layer')
        ax.set_title(f'd={d}, k={k}: {d-k-1 if d-k-1 > 0 else 1} hard dims')
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)

    # Row 2: Analysis
    # Plot 4: Step count distribution for d=8, k=1
    ax = axes[1, 0]
    d, k = 8, 1
    trajs = simulate_layered_descent(d, k, num_trials=200, grid_size=5)
    step_counts = [len(t) - 1 for t in trajs]
    ax.hist(step_counts, bins=30, color='steelblue', edgecolor='white', alpha=0.8)
    lb = max(d - k - 1, 1) * (min(d, 6) - 1)
    ax.axvline(x=lb, color='red', linestyle='--', linewidth=2,
               label=f'Layer lower bound = {lb}')
    ax.set_xlabel('Number of steps')
    ax.set_ylabel('Frequency')
    ax.set_title(f'Step Count Distribution (d={d}, k={k})')
    ax.legend()

    # Plot 5: Mean steps vs d for fixed k
    ax = axes[1, 1]
    for k in [0, 1, 2]:
        ds = list(range(3, 11))
        mean_steps = []
        for d in ds:
            trajs = simulate_layered_descent(d, k, num_trials=50, grid_size=min(d, 5))
            steps = [len(t) - 1 for t in trajs]
            mean_steps.append(np.mean(steps))
        ax.plot(ds, mean_steps, 'o-', label=f'k={k}', markersize=5)

    ax.set_xlabel('Dimension d')
    ax.set_ylabel('Mean steps')
    ax.set_title('Mean Descent Length vs Dimension')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 6: Layer function over time (single trajectory, d=8, k=1)
    ax = axes[1, 2]
    d, k = 10, 1
    trajs = simulate_layered_descent(d, k, num_trials=1, grid_size=5)
    if trajs:
        traj = trajs[0]
        ax.fill_between(range(len(traj)), traj, alpha=0.3, color='steelblue')
        ax.plot(range(len(traj)), traj, 'b-', linewidth=2)

        # Annotate start and end
        ax.annotate(f'Start: layer {traj[0]}', xy=(0, traj[0]),
                    fontsize=9, ha='left', va='bottom',
                    arrowprops=dict(arrowstyle='->', color='red'),
                    xytext=(len(traj)*0.1, traj[0]*0.9))
        ax.annotate('Terminal: layer 0', xy=(len(traj)-1, 0),
                    fontsize=9, ha='right', va='bottom',
                    xytext=(len(traj)*0.7, traj[0]*0.3))

    ax.set_xlabel('Step')
    ax.set_ylabel('Layer value')
    ax.set_title(f'Single Trajectory (d={d}, k={k})')
    ax.grid(True, alpha=0.3)

    plt.suptitle('Layer Descent Trajectories and Analysis', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('viz_layer_descent.png', dpi=150, bbox_inches='tight')
    print("Saved viz_layer_descent.png")


if __name__ == '__main__':
    main()
