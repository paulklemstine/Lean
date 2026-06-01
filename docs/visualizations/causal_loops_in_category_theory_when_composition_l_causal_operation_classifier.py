def find_causal_operations(n):
    results = []
    for alpha in range(n):
        for beta in range(n):
            op = lambda a,b,al=alpha,be=beta: (al*a+be*b)%n
            causal = True
            for c in range(n):
                vals = set()
                for a in range(n):
                    for b in range(n):
                        vals.add(assoc_defect(op,a,b,c)%n)
                if len(vals) > 1:
                    causal = False; break
            if causal: results.append((alpha,beta))
    return results