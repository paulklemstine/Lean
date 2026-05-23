def product_profile(G, H):
    """Compute Profile(G x H) = Profile(G) | Profile(H) via Phase-Union Law."""
    return arithmetic_phase_profile(G) | arithmetic_phase_profile(H)