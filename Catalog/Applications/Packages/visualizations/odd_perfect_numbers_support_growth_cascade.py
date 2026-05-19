from sympy import factorint, primerange

def sigmaPP(p, a):
    return (p**(a+1) - 1) // (p - 1) if p > 1 else a + 1

def support_growth(p, a, levels=5):
    all_primes = set()
    frontier = set()
    sp = sigmaPP(p, a)
    for q in factorint(sp):
        if q != p and q != 2:
            all_primes.add(q)
            frontier.add(q)
    print(f"Level 0: {sorted(all_primes)}")
    for level in range(1, levels):
        new_frontier = set()
        for q in frontier:
            sq = sigmaPP(q, 2)
            for r in factorint(sq):
                if r != 2 and r not in all_primes and r != p:
                    all_primes.add(r)
                    new_frontier.add(r)
        frontier = new_frontier
        print(f"Level {level}: {sorted(all_primes)}")
    return all_primes

# Demo
for p in [5, 13, 17, 29]:
    print(f"
Euler prime p={p}, a=1:")
    support_growth(p, 1, 4)