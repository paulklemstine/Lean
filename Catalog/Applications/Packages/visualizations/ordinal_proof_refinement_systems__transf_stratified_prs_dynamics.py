import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')

def simulate_stratified(init, max_steps=500):
    L = len(init)
    e = list(init)
    trace = [list(e)]
    for _ in range(max_steps):
        if all(x == 0 for x in e): break
        level = max((k for k in range(L) if e[k] > 0), default=-1)
        if level < 0: break
        e[level] -= 1
        for j in range(level): e[j] += 1
        trace.append(list(e))
    return trace

fig, axes = plt.subplots(1, 2, figsize=(12, 5))
for ax, init, title in [(axes[0],[3,3],'2 Levels'),(axes[1],[2,2,2],'3 Levels')]:
    trace = simulate_stratified(init)
    for lv in range(len(init)):
        ax.plot([t[lv] for t in trace], label=f'Level {lv}')
    ax.plot([sum(t) for t in trace], 'k--', alpha=0.5, label='Total')
    ax.set_title(f'{title}: {len(trace)-1} steps')
    ax.set_xlabel('Step'); ax.set_ylabel('Energy')
    ax.legend(); ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('stratified_dynamics.png', dpi=150)
print('Saved stratified_dynamics.png')