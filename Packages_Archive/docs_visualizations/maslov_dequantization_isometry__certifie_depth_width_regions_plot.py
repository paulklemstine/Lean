try:
    import matplotlib.pyplot as plt
    import numpy as np

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: fixed width, varying depth
    w = 5
    depths = list(range(1, 10))
    regions = [(w+1)**L for L in depths]
    linear = [L*w + 1 for L in depths]
    ax1.semilogy(depths, regions, 'bo-', markersize=8, linewidth=2, label=f'(w+1)^L = {w+1}^L')
    ax1.semilogy(depths, linear, 'rs--', markersize=8, linewidth=2, label=f'Lw+1 = {w}L+1')
    ax1.set_xlabel('Depth L', fontsize=14)
    ax1.set_ylabel('Number of regions', fontsize=14)
    ax1.set_title(f'Depth advantage (width w={w})', fontsize=14)
    ax1.legend(fontsize=12)
    ax1.grid(True, alpha=0.3)

    # Right: fixed budget, varying depth/width split
    budget = 60
    Ls = list(range(1, 31))
    region_counts = []
    for L in Ls:
        ww = budget // L
        if ww < 1: break
        region_counts.append((ww+1)**L)
    ax2.semilogy(Ls[:len(region_counts)], region_counts, 'go-', markersize=6, linewidth=2)
    ax2.set_xlabel('Depth L (width = 60/L)', fontsize=14)
    ax2.set_ylabel('Max regions (w+1)^L', fontsize=14)
    ax2.set_title('Optimal depth-width split (budget=60)', fontsize=14)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('depth_width_regions.png', dpi=150)
    print('Saved depth_width_regions.png')
except ImportError:
    print('matplotlib not available; skipping visualization')
