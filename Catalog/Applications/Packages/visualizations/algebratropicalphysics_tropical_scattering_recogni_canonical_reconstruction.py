def reconstruct_canonical(profile):
    return ScatteringRep(profile.values.reshape(-1, 1))