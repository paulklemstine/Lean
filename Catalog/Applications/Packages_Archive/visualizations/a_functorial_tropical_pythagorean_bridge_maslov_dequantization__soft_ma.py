import math
import matplotlib.pyplot as plt

a = 1.0
bs = [b/100 for b in range(-200, 401)]
fig, ax = plt.subplots(figsize=(7, 5))
for h in (1.0, 0.5, 0.2, 0.05):
    y = [h*math.log(math.exp(a/h)+math.exp(b/h)) for b in bs]
    ax.plot(bs, y, label=f'h={h}')
ax.plot(bs, [max(a, b) for b in bs], 'k--', lw=2, label='max(a,b) (tropical)')
ax.set_xlabel('b   (with a = 1 fixed)')
ax.set_ylabel('lseT(h, a, b)')
ax.set_title('Maslov dequantization: lseT -> max as h -> 0')
ax.legend(); ax.grid(alpha=0.3)
fig.savefig('maslov_sandwich.png', dpi=150, bbox_inches='tight')
print('saved maslov_sandwich.png')
