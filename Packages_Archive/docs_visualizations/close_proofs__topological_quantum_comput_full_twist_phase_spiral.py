import cmath, math
import matplotlib.pyplot as plt

ts = [cmath.exp(2j * math.pi * k / 200) for k in range(200)]
cubes = [t**3 for t in ts]
plt.figure(figsize=(6, 6))
plt.plot([t.real for t in ts], [t.imag for t in ts], label='t')
plt.plot([c.real for c in cubes], [c.imag for c in cubes], label='t^3 (full twist phase)')
plt.gca().set_aspect('equal'); plt.legend(); plt.title('Full twist = t^3 * I on |t|=1')
plt.savefig('full_twist_spiral.png', dpi=150)
print('saved full_twist_spiral.png')
