def additive_optimize(slot_flavors):
    optimal = [max(range(len(sf)), key=lambda j: sf[j]) for sf in slot_flavors]
    value = sum(sf[optimal[i]] for i, sf in enumerate(slot_flavors))
    return optimal, value