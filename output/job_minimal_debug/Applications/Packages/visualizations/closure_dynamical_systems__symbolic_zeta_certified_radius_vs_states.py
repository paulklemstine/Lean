import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import math

sizes = list(range(2, 101))
caps = [math.log(k) for k in sizes]
rads = [1.0/(1.0 + c) for c in caps]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

ax1.plot(sizes, caps, 'b-', linewidth=2)
ax1.set_xlabel('State space size |α|', fontsize=13)
ax1.set_ylabel('Capacity = ln(|α|)', fontsize=13)
ax1.set_title('Capacity vs State Space Size', fontsize=14)
ax1.grid(True, alpha=0.3)

ax2.plot(sizes, rads, 'r-', linewidth=2)
ax2.set_xlabel('State space size |α|', fontsize=13)
ax2.set_ylabel('Certified radius r', fontsize=13)
ax2.set_title('Certified Radius vs State Space Size (Antitone)', fontsize=14)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('capacity_radius.png', dpi=150)
print('Saved capacity_radius.png')