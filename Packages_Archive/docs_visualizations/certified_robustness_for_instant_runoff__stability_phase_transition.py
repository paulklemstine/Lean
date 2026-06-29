import random

random.seed(42)

def irv_eliminate(scores):
    active = dict(scores)
    order = []
    while len(active) > 1:
        loser = min(active, key=lambda k: active[k])
        order.append(loser)
        del active[loser]
    order.append(next(iter(active)))
    return order

def min_gap(scores):
    active = dict(scores)
    gaps = []
    while len(active) > 1:
        sv = sorted(active.items(), key=lambda x: x[1])
        gaps.append(sv[1][1] - sv[0][1])
        del active[sv[0][0]]
    return min(gaps) if gaps else float('inf')

scores = {0: 1.0, 1: 3.0, 2: 5.5, 3: 8.0}
gamma = min_gap(scores)
original = irv_eliminate(scores)

print(f'Scores: {scores}')
print(f'Gap certificate gamma = {gamma:.2f}')
print(f'Critical threshold: eps = gamma/2 = {gamma/2:.2f}')
print()
print(f'{"eps":>8} {"2*eps":>8} {"2eps<gamma":>10} {"violation_rate":>15}')

for eps_frac in [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.99, 1.0, 1.01, 1.05, 1.1, 1.2, 1.5, 2.0]:
    eps = eps_frac * gamma / 2
    n_trials = 10000
    violations = sum(1 for _ in range(n_trials)
        if irv_eliminate({k: v+random.uniform(-eps,eps) for k,v in scores.items()}) != original)
    safe = '  YES' if 2*eps < gamma else '   NO'
    print(f'{eps:8.4f} {2*eps:8.4f} {safe:>10} {violations/n_trials:15.4f}')