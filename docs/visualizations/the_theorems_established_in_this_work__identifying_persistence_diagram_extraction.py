def persistence_diagram(coeffs, p):
    roots = [x for x in range(p) if sum(c*pow(x,i,p) for i,c in enumerate(coeffs))%p == 0]
    depths = depth_filtration(coeffs, p)
    pairs = []
    for r in roots:
        basin_max = max((d for x,d in depths.items() if d>=0 and newton_iterate(coeffs,x,p,d)==r), default=0)
        pairs.append((0, basin_max))
    return pairs