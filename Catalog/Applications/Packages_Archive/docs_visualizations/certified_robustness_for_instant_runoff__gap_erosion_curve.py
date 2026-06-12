import random
import json

random.seed(42)

def min_gap(scores):
    active = dict(scores)
    gaps = []
    while len(active) > 1:
        sv = sorted(active.items(), key=lambda x: x[1])
        gaps.append(sv[1][1] - sv[0][1])
        del active[sv[0][0]]
    return min(gaps) if gaps else float('inf')

scores = {0: 0.0, 1: 2.0, 2: 3.5, 3: 6.0}
orig_gap = min_gap(scores)

epsilons = [i * 0.05 for i in range(1, 21)]
theoretical = [orig_gap - 2*e for e in epsilons]
empirical = []
for eps in epsilons:
    worst = float('inf')
    for _ in range(20000):
        p = {k: v + random.uniform(-eps, eps) for k, v in scores.items()}
        worst = min(worst, min_gap(p))
    empirical.append(worst)

print('Gap Erosion: Theoretical Lower Bound vs Empirical Worst Case')
print(f'{"eps":>8} {"theoretical":>12} {"empirical":>12} {"tight":>8}')
for e, t, em in zip(epsilons, theoretical, empirical):
    print(f'{e:8.2f} {t:12.4f} {em:12.4f} {em-t:8.4f}')