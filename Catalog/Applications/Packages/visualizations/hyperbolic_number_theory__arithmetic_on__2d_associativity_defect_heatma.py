import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def madd(z, w):
    return (z + w) / (1 + z.conjugate() * w)

def defect(z1, z2, z3):
    return abs(madd(madd(z1,z2),z3) - madd(z1,madd(z2,z3)))

z1 = complex(0.3, 0.4)
z3 = complex(-0.1, 0.3)
n = 80
x = np.linspace(-0.8, 0.8, n)
X, Y = np.meshgrid(x, x)
Z = np.full((n,n), np.nan)
for i in range(n):
    for j in range(n):
        z2 = complex(X[i,j], Y[i,j])
        if abs(z2) < 0.95:
            Z[i,j] = defect(z1, z2, z3)
fig, ax = plt.subplots(figsize=(8,7))
im = ax.pcolormesh(X, Y, Z, cmap='hot', shading='auto')
ax.add_patch(plt.Circle((0,0), 1, fill=False, color='white', lw=2))
ax.set_aspect('equal')
ax.set_title('Associativity Defect in 2D')
plt.colorbar(im, ax=ax)
plt.savefig('viz_defect.png', dpi=150)
