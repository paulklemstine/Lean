def tower_forces(V, w, formula):
    if formula == 'bot': return False
    if formula[0] == 'var': return V(w, formula[1])
    if formula[0] == 'imp':
        return not tower_forces(V, w, formula[1]) or tower_forces(V, w, formula[2])
    if formula[0] == 'box':
        return all(tower_forces(V, v, formula[1]) for v in range(w))