def compute_profile(x, system):
    """Compute observer profile. Time: O(|ι| · T_obs)"""
    cx = system.compress(x)
    return tuple(obs(cx) for obs in system.observers)