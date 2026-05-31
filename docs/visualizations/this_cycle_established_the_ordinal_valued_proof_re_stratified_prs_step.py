def stratified_step(energies, level, decrease):
    result = list(energies)
    result[level] -= decrease
    for j in range(level):
        result[j] += decrease
    return result