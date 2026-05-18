def mcallester_bound(emp_risk, kl, n, delta):
    import math
    complexity = (kl + math.log(2 * math.sqrt(n) / delta)) / (2 * n)
    return emp_risk + math.sqrt(max(0, complexity))

# Example
print(mcallester_bound(0.05, 10.0, 1000, 0.05))