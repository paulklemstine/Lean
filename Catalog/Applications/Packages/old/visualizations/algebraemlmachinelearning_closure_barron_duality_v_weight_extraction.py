def extract_weights(lattice, f):
    """Extract canonical weights from a functional."""
    return {j: f(j) for j in lattice.join_irreducibles()}