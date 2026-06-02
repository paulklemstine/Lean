def find_stability_level(tower):
    n = tower.height
    stability = n
    for i in range(n - 1, -1, -1):
        values = list(tower.transitions[i].values())
        inj = len(values) == len(set(values))
        surj = set(values) == tower.levels[i + 1]
        if inj and surj:
            stability = i
        else:
            break
    return stability if stability < n else None