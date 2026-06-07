def ultrapower_compare(f, g, indices):
    less = sum(1 for i in indices if f(i) < g(i))
    equal = sum(1 for i in indices if f(i) == g(i))
    greater = sum(1 for i in indices if f(i) > g(i))
    total = len(indices)
    if equal == total: return 'equal'
    elif less + equal == total: return 'less'
    elif greater + equal == total: return 'greater'
    else: return 'likely_less' if less > greater else 'likely_greater'