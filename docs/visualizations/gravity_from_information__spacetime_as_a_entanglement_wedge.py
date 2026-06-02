#!/usr/bin/env python3
"""
Visualization: Entanglement Wedge Structure
Shows how boundary regions map to bulk regions.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def draw_ads_disk(ax, n_boundary=16, highlighted_region=None, title=''):
    """Draw an AdS disk with boundary sites and entanglement wedge."""
    # Draw bulk disk
    theta = np.linspace(0, 2 * np.pi, 200)
    ax.fill(np.cos(theta), np.sin(theta), color='lightblue', alpha=0.3)
    ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)
    
    # Draw boundary sites
    for i in range(n_boundary):
        angle = 2 * np.pi * i / n_boundary
        x, y = np.cos(angle), np.sin(angle)
        if highlighted_region and i in highlighted_region:
            ax.plot(x, y, 'ro', markersize=10, zorder=5)
        else:
            ax.plot(x, y, 'ko', markersize=6, zorder=5)
    
    # Draw entanglement wedge if region is highlighted
    if highlighted_region and len(highlighted_region) > 0:
        angles = [2 * np.pi * i / n_boundary for i in highlighted_region]
        min_angle = min(angles)
        max_angle = max(angles)
        
        # Handle wrap-around
        if max_angle - min_angle > np.pi:
            min_angle, max_angle = max_angle, min_angle + 2 * np.pi
        
        # Draw geodesic (RT surface) as a curve through the bulk
        mid_angle = (min_angle + max_angle) / 2
        span = max_angle - min_angle
        
        # Wedge region
        wedge_theta = np.linspace(min_angle, max_angle, 50)
        depth = min(0.8, span / np.pi * 0.9)
        
        # Create wedge shape
        wx = [0]
        wy = [0]
        for t in wedge_theta:
            wx.append(np.cos(t))
            wy.append(np.sin(t))
        wx.append(0)
        wy.append(0)
        
        ax.fill(wx, wy, color='red', alpha=0.15)
        
        # Draw RT surface (geodesic)
        t_geo = np.linspace(min_angle, max_angle, 50)
        r_geo = np.array([max(0.1, 1 - 0.5 * np.sin((t - min_angle) / (max_angle - min_angle) * np.pi)) 
                         for t in t_geo])
        ax.plot(r_geo * np.cos(t_geo), r_geo * np.sin(t_geo), 'g-', 
                linewidth=3, label='RT surface (geodesic)')
    
    ax.set_xlim(-1.3, 1.3)
    ax.set_ylim(-1.3, 1.3)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=11)
    ax.axis('off')


def main():
    fig, axes = plt.subplots(2, 3, figsize=(16, 11))
    fig.suptitle('Entanglement Wedge Structure in AdS₃/CFT₂',
                 fontsize=16, fontweight='bold')
    
    n = 16
    
    # Different region sizes
    regions = [
        (set(range(2)), 'Small region (|A|=2)'),
        (set(range(4)), 'Medium region (|A|=4)'),
        (set(range(8)), 'Half boundary (|A|=8)'),
        (set(range(12)), 'Large region (|A|=12)'),
        (set(range(n)), 'Full boundary (|A|=n)'),
        (set(), 'Empty region (|A|=0)'),
    ]
    
    for idx, (region, title) in enumerate(regions):
        ax = axes[idx // 3, idx % 3]
        draw_ads_disk(ax, n, region if region else None, title)
    
    plt.tight_layout()
    plt.savefig('entanglement_wedge.png', dpi=150, bbox_inches='tight')
    print("Saved: entanglement_wedge.png")


if __name__ == '__main__':
    main()
