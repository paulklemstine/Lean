import math

def child_a(t):
    a, b, c = t
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def child_b(t):
    a, b, c = t
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def child_c(t):
    a, b, c = t
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

def max_search_depth(N):
    if N < 5: return -1
    D = int((-3 + math.sqrt(2*N + 1)) / 2)
    while 2*(D+1)**2 + 6*(D+1) + 5 <= N: D += 1
    while D >= 0 and 2*D**2 + 6*D + 5 > N: D -= 1
    return D

def enumerate_triples(N):
    D = max_search_depth(N)
    if D < 0: return []
    result = []
    stack = [((3, 4, 5), 0)]
    while stack:
        triple, depth = stack.pop()
        if triple[2] <= N:
            result.append(triple)
        if depth < D:
            for gen in [child_a, child_b, child_c]:
                child = gen(triple)
                if child[2] <= N:
                    stack.append((child, depth + 1))
    return sorted(result, key=lambda t: (t[2], t[0]))

# Example
triples = enumerate_triples(100)
print(f"Primitive Pythagorean triples with c <= 100: {len(triples)}")
for t in triples:
    print(f"  {t}  check: {t[0]}^2 + {t[1]}^2 = {t[0]**2 + t[1]**2} = {t[2]}^2 = {t[2]**2}")