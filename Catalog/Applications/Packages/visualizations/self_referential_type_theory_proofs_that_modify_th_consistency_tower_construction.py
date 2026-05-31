def build_demo_tower(n_levels):
    theories = []
    for level in range(n_levels):
        provable_set = set()
        provable_set.add(f'0 = 0 at level {level}')
        for j in range(level):
            provable_set.add(f'Con(T_{j})')
        theories.append(LevelTheory(level=level, sentences=list(provable_set),
                                     provable=lambda s, ps=provable_set: s in ps,
                                     con_statement=f'T_{level}'))
    return ConsistencyTower(theories=theories)