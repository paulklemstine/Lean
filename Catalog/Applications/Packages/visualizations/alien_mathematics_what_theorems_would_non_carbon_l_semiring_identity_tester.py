def eval_nat(x, exponents):
    return sum(x ** i for i in exponents)

def eval_tropical(x, exponents):
    return max((x ** i for i in exponents), default=0)

def alien_shadow(L):
    seen, result = set(), []
    for i in L:
        if i not in seen:
            seen.add(i); result.append(i)
    return result

test_lists = [[0, 0], [1, 1, 1], [0, 1, 0], [2, 3, 2, 3]]
for L in test_lists:
    shadow = alien_shadow(L)
    for x in [1, 2, 3]:
        nat_eq = eval_nat(x, L) == eval_nat(x, shadow)
        trop_eq = eval_tropical(float(x), L) == eval_tropical(float(x), shadow)
        print(f"L={L}, x={x}: NAT {"=" if nat_eq else "!="}, TROP {"=" if trop_eq else "!="}")