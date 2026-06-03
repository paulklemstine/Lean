def detect_forcing(state, alphabet, modulus, forbidden):
    succs = [g for g in alphabet if (state + g) % modulus not in forbidden]
    return succs[0] if len(succs) == 1 else None