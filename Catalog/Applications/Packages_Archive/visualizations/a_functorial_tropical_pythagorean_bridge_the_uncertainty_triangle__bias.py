import math
import matplotlib.pyplot as plt

ps = [i/400 for i in range(1, 400)]
leg1 = [abs(p - (1-p)) for p in ps]            # polarization |p-q|
leg2 = [2*math.sqrt(p*(1-p)) for p in ps]      # 2 sigma

fig, ax = plt.subplots(figsize=(6, 6))
ax.plot(leg1, leg2, lw=2, color='#2a6f97', label='Bernoulli laws')
for p in (0.5, 0.36, 0.1, 0.99):
    x, y = abs(2*p-1), 2*math.sqrt(p*(1-p))
    ax.plot([0, x, x], [y, y, 0], '--', color='gray', lw=0.8)
    ax.plot(x, y, 'o', color='#d62828')
    ax.annotate(f'p={p}', (x, y), textcoords='offset points', xytext=(6, 6))
ax.set_xlabel('polarization |p - q|  (bias leg)')
ax.set_ylabel('2 sigma  (noise leg)')
ax.set_title('Pythagorean probability identity: (p-q)^2 + (2 sigma)^2 = 1')
ax.set_aspect('equal'); ax.legend(); ax.grid(alpha=0.3)
fig.savefig('uncertainty_triangle.png', dpi=150, bbox_inches='tight')
print('saved uncertainty_triangle.png')
