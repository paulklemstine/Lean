def merkle_damgard(f, iv, msg):
    """Algorithm A: streaming Merkle-Damgard hash (one pass, constant state)."""
    state = iv
    for block in msg:        # absorb each block
        state = f(state, block)
    return state             # digest is the final chaining value
