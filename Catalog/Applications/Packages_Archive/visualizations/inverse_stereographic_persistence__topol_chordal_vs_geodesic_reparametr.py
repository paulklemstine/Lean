import numpy as np
import matplotlib.pyplot as plt

theta = np.linspace(0, np.pi, 400)
chord = 2.0 * np.sin(theta / 2.0)
plt.figure(figsize=(6, 5))
plt.plot(theta, chord, lw=2)
plt.title('Chordal vs geodesic distance on the unit sphere')
plt.xlabel('geodesic distance theta'); plt.ylabel('chordal distance 2 sin(theta/2)')
plt.grid(True, alpha=0.3)
plt.tight_layout(); plt.savefig('chord_vs_geodesic.png', dpi=150)
print('wrote chord_vs_geodesic.png')
