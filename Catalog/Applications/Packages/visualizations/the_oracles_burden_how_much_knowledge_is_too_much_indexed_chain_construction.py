def build_indexed_chain(base, witness, max_level):
    levels = [set(base)]
    for n in range(max_level):
        next_level = set(levels[-1])
        next_level.add(witness(n))
        levels.append(next_level)
    return levels