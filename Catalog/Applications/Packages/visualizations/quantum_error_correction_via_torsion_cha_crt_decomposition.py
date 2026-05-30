"""
Visualization: CRT Channel Decomposition of Z/6Z

Shows how the Chinese Remainder Theorem decomposes Z/6Z into independent
channels Z/2Z × Z/3Z, and how this creates a grid structure that enables
per-channel error correction.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# --- Panel 1: CRT Mapping ---
ax1 = axes[0]
ax1.set_title("CRT: Z/6Z → Z/2Z × Z/3Z", fontsize=14, fontweight='bold')

# Draw the mapping
for x in range(6):
    a, b = x % 2, x % 3
    ax1.annotate('', xy=(1.5, 2.5 - a * 1.2 - b * 0.3),
                xytext=(0.5, 2.5 - x * 0.45),
                arrowprops=dict(arrowstyle='->', color=plt.cm.Set2(x/6), lw=1.5))
    ax1.text(0.3, 2.5 - x * 0.45, str(x), fontsize=14, ha='center', va='center',
            bbox=dict(boxstyle='round,pad=0.3', facecolor=plt.cm.Set2(x/6), alpha=0.7))
    ax1.text(1.7, 2.5 - a * 1.2 - b * 0.3, f"({a},{b})", fontsize=12, ha='center', va='center',
            bbox=dict(boxstyle='round,pad=0.3', facecolor=plt.cm.Set2(x/6), alpha=0.4))

ax1.set_xlim(-0.2, 2.5)
ax1.set_ylim(-0.5, 3.2)
ax1.text(0.3, 3.0, "Z/6Z", fontsize=12, ha='center', fontweight='bold')
ax1.text(1.7, 3.0, "Z/2Z × Z/3Z", fontsize=12, ha='center', fontweight='bold')
ax1.axis('off')

# --- Panel 2: Grid Structure ---
ax2 = axes[1]
ax2.set_title("Channel Grid Structure", fontsize=14, fontweight='bold')

for a in range(2):
    for b in range(3):
        x = [z for z in range(6) if z % 2 == a and z % 3 == b][0]
        color = plt.cm.Set2(x/6)
        rect = patches.FancyBboxPatch((b - 0.35, (1-a) - 0.35), 0.7, 0.7,
                                       boxstyle="round,pad=0.05",
                                       facecolor=color, edgecolor='black', lw=2)
        ax2.add_patch(rect)
        ax2.text(b, 1-a, str(x), fontsize=18, ha='center', va='center', fontweight='bold')

ax2.set_xlim(-0.6, 2.6)
ax2.set_ylim(-0.6, 1.6)
ax2.set_xlabel("3-channel (mod 3)", fontsize=12)
ax2.set_ylabel("2-channel (mod 2)", fontsize=12)
ax2.set_xticks([0, 1, 2])
ax2.set_xticklabels(['0', '1', '2'])
ax2.set_yticks([0, 1])
ax2.set_yticklabels(['1', '0'])

# --- Panel 3: Channel Independence ---
ax3 = axes[2]
ax3.set_title("Channel Independence", fontsize=14, fontweight='bold')

# Show a codeword and errors
codeword = [0, 3, 1, 4, 2, 5]
errored = [0, 3, 4, 4, 2, 5]  # error at position 2: 1→4

positions = range(len(codeword))
width = 0.35

# Original
bars1 = ax3.bar([p - width/2 for p in positions], 
                [c % 2 for c in codeword], width, label='Original (mod 2)', 
                color='steelblue', alpha=0.7)
bars2 = ax3.bar([p + width/2 for p in positions],
                [c % 3 for c in codeword], width, label='Original (mod 3)',
                color='coral', alpha=0.7)

# Error markers
ax3.bar([2 - width/2], [errored[2] % 2], width, color='navy', alpha=0.9)
ax3.bar([2 + width/2], [errored[2] % 3], width, color='coral', alpha=0.3,
        edgecolor='coral', linewidth=2, linestyle='--')

ax3.annotate('ERROR\n(2-ch only)', xy=(2, 0.5), fontsize=10, ha='center',
            color='red', fontweight='bold')
ax3.annotate('3-channel\nunchanged!', xy=(2 + width/2, errored[2] % 3 + 0.15),
            fontsize=9, ha='center', color='green', fontweight='bold')

ax3.set_xlabel("Position", fontsize=12)
ax3.set_ylabel("Channel Value", fontsize=12)
ax3.set_xticks(range(len(codeword)))
ax3.legend(fontsize=9)

plt.tight_layout()
plt.savefig("crt_decomposition.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved: crt_decomposition.png")
