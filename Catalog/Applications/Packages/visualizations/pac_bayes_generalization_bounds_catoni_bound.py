import math
def catoni_bound(emp_risk, kl, n, delta, lam):
    denom = 1 - math.exp(-lam)
    exponent = -lam * emp_risk - (kl + math.log(1/delta)) / n
    return (1/denom) * (1 - math.exp(exponent))

# Example with optimal lambda search
best = min([catoni_bound(0.05, 10.0, 1000, 0.05, l) for l in [i*0.1 for i in range(1, 200)]])
print(f"Optimal Catoni bound: {best:.4f}")