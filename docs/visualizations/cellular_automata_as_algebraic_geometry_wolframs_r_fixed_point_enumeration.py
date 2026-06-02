def find_fixed_points(rule, n):
    fixed = []
    for s_int in range(2**n):
        s = [(s_int>>i)&1 for i in range(n)]
        updated = [((rule>>(4*s[(i-1)%n]+2*s[i]+s[(i+1)%n]))&1) for i in range(n)]
        if s == updated:
            fixed.append(tuple(s))
    return fixed