def iterated_revision(conflict, beliefs):
    while True:
        next_beliefs = {p for p in beliefs if skeptical_consequence(conflict, beliefs, p)}
        if next_beliefs == beliefs:
            return beliefs
        beliefs = next_beliefs