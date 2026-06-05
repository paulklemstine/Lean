def competitive_exclusion(theories, niches):
    best = {}
    for t, n in zip(theories, niches):
        if n not in best or t.fitness > best[n].fitness:
            best[n] = t
    return list(best.values())