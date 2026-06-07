def count_classes(n, k):
    from itertools import permutations
    import math
    total = 0
    for perm in permutations(range(n)):
        visited = [False]*n
        cycles = 0
        for i in range(n):
            if not visited[i]:
                cycles += 1
                j = i
                while not visited[j]:
                    visited[j] = True
                    j = perm[j]
        total += k**cycles
    return total // math.factorial(n)