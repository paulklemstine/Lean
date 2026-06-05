def competitive_exclusion(ecosystem: dict) -> dict:
    return {niche: max(species, key=lambda t: t.fitness()) for niche, species in ecosystem.items() if species}