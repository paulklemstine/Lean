"""Geometry of the first jump: the arrow sum zeta - zeta^2 + zeta^3."""
import cmath, math
import matplotlib.pyplot as plt

W5 = cmath.exp(2j * cmath.pi / 5)
roots = [W5**r for r in range(5)]

fig, ax = plt.subplots(figsize=(7, 7))
th = [cmath.exp(2j*cmath.pi*t/200) for t in range(201)]
ax.plot([z.real for z in th], [z.imag for z in th], color='lightgray')
for r, z in enumerate(roots):
    ax.plot([z.real], [z.imag], 'o', color='steelblue')
    ax.annotate(f'$\\zeta^{r}$', (z.real, z.imag), textcoords='offset points',
                xytext=(8, 8))

# arrow chain zeta - zeta^2 + zeta^3  (the reduced 6-root witness)
pieces = [W5, -W5**2, W5**3]
cur = 0+0j
for p in pieces:
    ax.annotate('', xy=((cur+p).real, (cur+p).imag), xytext=(cur.real, cur.imag),
                arrowprops=dict(arrowstyle='->', color='crimson', lw=2))
    cur += p
ax.plot([cur.real], [cur.imag], '*', color='crimson', ms=16,
        label=f'$S=\\zeta-\\zeta^2+\\zeta^3$, $|S|=\\varphi^{{-2}}\\approx{abs(cur):.3f}$')
ax.set_aspect('equal'); ax.grid(alpha=0.3); ax.legend(loc='lower right')
ax.set_title('First Lucas-type jump ($N=6=2L_2$): arrow reduction on the pentagon')
plt.tight_layout(); plt.savefig('sigma5_pentagon.png', dpi=150)
print('wrote sigma5_pentagon.png')
