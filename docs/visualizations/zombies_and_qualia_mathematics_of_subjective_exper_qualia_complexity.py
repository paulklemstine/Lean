def qualia_complexity(states, qualia_fn):
    return len(set(qualia_fn(s) for s in states))