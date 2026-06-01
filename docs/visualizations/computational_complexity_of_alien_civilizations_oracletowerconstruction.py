def oracle_tower(base, depth):
    tower = [base]
    for i in range(1, depth):
        prev = tower[-1]
        scale = 2 ** i
        ext = ComplexityHierarchy(lambda n, p=prev, s=scale: p.level(n * s))
        tower.append(ext)
    return tower