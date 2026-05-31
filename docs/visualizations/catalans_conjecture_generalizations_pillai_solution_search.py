def find_pillai_solutions(k, max_base=1000, max_exp=50):
    powers = {}
    for base in range(2, max_base + 1):
        val = base * base
        exp = 2
        while val <= max_base ** max_exp and exp <= max_exp:
            if val not in powers: powers[val] = []
            powers[val].append((base, exp))
            exp += 1; val = base ** exp
    solutions = []
    for val, reps in powers.items():
        target = val - k
        if target in powers:
            for x, a in reps:
                for y, b in powers[target]:
                    solutions.append((x, a, y, b))
    return sorted(solutions)