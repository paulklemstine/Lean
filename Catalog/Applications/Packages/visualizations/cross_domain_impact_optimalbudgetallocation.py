def optimal_allocation(capacities, budget):
    """Optimally allocate budget to maximize min throughput. O(n log n)."""
    n = len(capacities)
    idx = sorted(range(n), key=lambda i: capacities[i])
    sc = [capacities[i] for i in idx]
    alloc = [0] * n
    rem = budget
    for i in range(n - 1):
        if rem <= 0: break
        gap = sc[i+1] - sc[i]
        needed = (i+1) * gap
        if needed <= rem:
            rem -= needed
            for j in range(i+1):
                alloc[idx[j]] += gap
                sc[j] = sc[i+1]
        else:
            u, r = divmod(rem, i+1)
            for j in range(i+1):
                alloc[idx[j]] += u + (1 if j < r else 0)
            rem = 0
            break
    if rem > 0:
        u, r = divmod(rem, n)
        for j in range(n):
            alloc[idx[j]] += u + (1 if j < r else 0)
    final = [c + a for c, a in zip(capacities, alloc)]
    return alloc, final

# Example
caps = [3, 7, 5, 3, 9]
alloc, final = optimal_allocation(caps, 10)
print(f"Initial: {caps}, throughput = {min(caps)}")
print(f"Budget: 10, Allocation: {alloc}")
print(f"Final: {final}, throughput = {min(final)}")