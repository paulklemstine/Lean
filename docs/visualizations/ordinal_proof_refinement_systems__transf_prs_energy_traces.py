import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')

def simulate_euclid(a, b):
    trace = [b]
    while b > 0:
        a, b = b, a % b
        trace.append(b)
    return trace

def simulate_halving(n):
    trace = [n]
    while n > 0:
        n = n // 2
        trace.append(n)
    return trace

fig, axes = plt.subplots(1, 2, figsize=(12, 5))
for a, b in [(252,105),(1071,462),(987,610),(100,37)]:
    t = simulate_euclid(a, b)
    axes[0].plot(t, marker='o', markersize=3, label=f'gcd({a},{b})')
axes[0].set_title('Euclidean Algorithm PRS')
axes[0].set_xlabel('Step'); axes[0].set_ylabel('Energy')
axes[0].legend(fontsize=8); axes[0].grid(True, alpha=0.3)
for n in [100,200,500,1000]:
    t = simulate_halving(n)
    axes[1].plot(t, marker='.', markersize=2, label=f'n={n}')
axes[1].set_title('Halving PRS')
axes[1].set_xlabel('Step'); axes[1].set_ylabel('Energy')
axes[1].legend(); axes[1].grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('prs_traces.png', dpi=150)
print('Saved prs_traces.png')