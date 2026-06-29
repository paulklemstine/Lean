try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt

    fig, ax = plt.subplots(1, 1, figsize=(12, 3))

    labels = ['Con⁰', 'Con¹', 'Con²', 'Con³', 'Con⁴', 'Con⁵', '⊤']
    n = len(labels)
    xs = [i * 1.5 for i in range(n)]
    y = 0.5

    for i in range(n):
        color = '#4ecdc4' if i < n - 1 else '#96ceb4'
        circle = plt.Circle((xs[i], y), 0.3, color=color, ec='black', lw=2)
        ax.add_patch(circle)
        ax.text(xs[i], y, labels[i], ha='center', va='center', fontsize=11, fontweight='bold')

    for i in range(n - 1):
        ax.annotate('', xy=(xs[i+1] - 0.35, y), xytext=(xs[i] + 0.35, y),
                   arrowprops=dict(arrowstyle='->', color='red', lw=2))
        ax.text((xs[i] + xs[i+1]) / 2, y + 0.45, '□', ha='center', va='center',
               fontsize=12, color='red', fontweight='bold')

    ax.set_xlim(-0.8, xs[-1] + 0.8)
    ax.set_ylim(-0.3, 1.2)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Provability Iteration Hierarchy: □ⁿ(Con⁰)', fontsize=14)

    plt.tight_layout()
    plt.savefig('iteration_hierarchy.png', dpi=150, bbox_inches='tight')
    print('Saved iteration_hierarchy.png')
except ImportError:
    print('matplotlib not available; skipping visualization')