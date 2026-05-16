import math
def tropical_perturbation_bound(n):
    return math.log(n) if n > 0 else 0.0

# Verify tensorization
for s in range(2, 11):
    for t in range(2, 11):
        assert abs(tropical_perturbation_bound(s*t) - tropical_perturbation_bound(s) - tropical_perturbation_bound(t)) < 1e-12
print('Tensorization verified for all 2 <= s,t <= 10')