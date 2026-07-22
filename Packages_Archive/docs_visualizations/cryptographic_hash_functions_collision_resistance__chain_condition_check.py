def is_chain(sets):
    for i, s in enumerate(sets):
        for t in sets[i+1:]:
            if not (s <= t or t <= s):
                return False
    return True