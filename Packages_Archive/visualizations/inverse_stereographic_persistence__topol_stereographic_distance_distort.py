import numpy as np
import matplotlib.pyplot as plt

g = np.linspace(-4, 4, 400)
gx, gy = np.meshgrid(g, g)
r2 = gx**2 + gy**2
ratio = 2.0 / np.sqrt(1.0 + r2)   # d_w(0,x)/||x|| weight factor
plt.figure(figsize=(6, 5))
im = plt.pcolormesh(gx, gy, ratio, shading='auto', cmap='viridis')
plt.colorbar(im, label='conformal weight  2/sqrt(1+||x||^2)')
plt.title('Conformal distance distortion under inverse stereographic projection')
plt.xlabel('x_1'); plt.ylabel('x_2'); plt.gca().set_aspect('equal')
plt.tight_layout(); plt.savefig('conformal_distortion.png', dpi=150)
print('wrote conformal_distortion.png')
