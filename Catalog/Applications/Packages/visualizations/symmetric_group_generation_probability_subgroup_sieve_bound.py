import math
def subgroup_sieve_bound(n, subgroup_orders):
    nfact = math.factorial(n)
    return sum((h / nfact) ** 2 for h in subgroup_orders)

# Point stabilizers in S_5: 5 subgroups of order 24
print(subgroup_sieve_bound(5, [24]*5))  # 0.2