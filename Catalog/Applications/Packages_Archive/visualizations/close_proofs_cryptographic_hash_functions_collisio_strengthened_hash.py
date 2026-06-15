def md_strengthen(f, pad, iv, msg):
    """Algorithm C: strengthened hash = hash of the length-padded message
    (Definition 8.1 / Theorem 8.2)."""
    return merkle_damgard(f, iv, pad(msg))

def pad_with_length(msg, width=8):
    """Injective, length-regular padding: append length, fill to fixed width."""
    body = list(msg) + [len(msg)]
    return tuple(body + [-1] * (width - len(body)))
