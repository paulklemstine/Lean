def complexity_profile(seq, max_k=20):
    profile = []
    for k in range(1, min(max_k, len(seq)) + 1):
        distinct = len(set(tuple(seq[i:i+k]) for i in range(len(seq)-k+1)))
        profile.append((k, distinct))
    return profile