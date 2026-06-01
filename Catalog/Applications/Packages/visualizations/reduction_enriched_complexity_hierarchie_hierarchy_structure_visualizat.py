import matplotlib.pyplot as plt
import numpy as np

def main():
    num_levels = 8
    problems_per_level = 5
    np.random.seed(42)
    fig, ax = plt.subplots(figsize=(10, 8))
    for level in range(num_levels):
        for i in range(problems_per_level):
            x = i - (problems_per_level - 1) / 2.0 + np.random.normal(0, 0.1)
            is_complete = (i == problems_per_level - 1)
            color = '#e74c3c' if is_complete else '#3498db'
            size = 120 if is_complete else 60
            marker = '*' if is_complete else 'o'
            ax.scatter(x, level, c=color, s=size, marker=marker, zorder=5, edgecolors='black', linewidth=0.5)
    ax.set_ylabel('Level (Complexity)')
    ax.set_xlabel('Problem Space')
    ax.set_title('Reduction Hierarchy with Complete Elements')
    ax.set_yticks(range(num_levels))
    plt.tight_layout()
    plt.savefig('hierarchy.png', dpi=150)
    plt.close()

main()