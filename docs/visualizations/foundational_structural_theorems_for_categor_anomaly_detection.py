def compute_anomaly_set(tower, level):
    image = set(tower.transitions[level].values())
    return tower.levels[level + 1] - image