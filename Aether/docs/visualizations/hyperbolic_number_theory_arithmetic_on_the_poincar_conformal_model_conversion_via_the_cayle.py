def to_disk(z: complex) -> complex:
    """Map upper half-plane point z (Im z > 0) into the unit disk."""
    return (z - 1j) / (z + 1j)

def to_half_plane(w: complex) -> complex:
    """Map unit disk point w (w != 1) back to the upper half-plane."""
    return 1j * (1 + w) / (1 - w)
