import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

INTERVAL_NAMES = {0:'P1',1:'m2',2:'M2',3:'m3',4:'M3',5:'P4',6:'TT',7:'P5',8:'m6',9:'M6',10:'m7',11:'M7'}
CONSONANT = {0,3,4,7,8,9}
PERFECT = {0,7}

fig, ax = plt.subplots(1, 1, figsize=(8, 8))
ax.set_aspect('equal')
theta = np.linspace(np.pi/2, np.pi/2 - 2*np.pi, 13)[:-1]
r = 1.2
for i in range(12):
    x, y = r*np.cos(theta[i]), r*np.sin(theta[i])
    color = '#2196F3' if i in PERFECT else '#4CAF50' if i in CONSONANT else '#E0E0E0'
    ax.scatter(x, y, s=600, c=color, zorder=5, edgecolors='black', linewidths=1.5)
    ax.text(1.45*np.cos(theta[i]), 1.45*np.sin(theta[i]), INTERVAL_NAMES[i], ha='center', va='center', fontsize=12, fontweight='bold')
ax.set_title('Consonant Intervals on Z/12Z', fontsize=16, fontweight='bold')
ax.axis('off')
plt.savefig('chromatic_circle.png', dpi=150, bbox_inches='tight')
plt.close()