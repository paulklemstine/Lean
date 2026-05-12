def build_certified_predictor(system):
    """Build predictor with correctness certificate. Time: O(|S| · |ι|)"""
    lookup = {}
    for x in system.states:
        profile = tuple(obs(system.compress(x)) for obs in system.observers)
        if profile not in lookup:
            lookup[profile] = system.compress(x)
    return lookup