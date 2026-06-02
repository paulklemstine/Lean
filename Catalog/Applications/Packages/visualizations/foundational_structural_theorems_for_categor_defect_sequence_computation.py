def compute_defect_sequence(tower):
    defects = []
    for i in range(tower.height):
        image = set(tower.transitions[i].values())
        d = len(tower.levels[i + 1]) - len(image)
        defects.append(d)
    return defects