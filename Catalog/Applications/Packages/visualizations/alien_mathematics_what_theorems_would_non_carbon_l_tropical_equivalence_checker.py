def support(coeffs):
    return {exp for exp, c in coeffs.items() if c != 0}

def tropically_equivalent(p, q):
    return support(p) == support(q)

# 3 + 7x + x^2 vs 1 + x + 100x^2: same support {0,1,2}
print(tropically_equivalent({0:3, 1:7, 2:1}, {0:1, 1:1, 2:100}))  # True

# vs 1 + x + x^3: different support
print(tropically_equivalent({0:3, 1:7, 2:1}, {0:1, 1:1, 3:1}))  # False