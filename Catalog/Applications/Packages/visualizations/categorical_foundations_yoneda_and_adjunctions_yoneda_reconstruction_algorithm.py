def yoneda_reconstruct_iso(cat, X, Y, nat_iso_hom, nat_iso_inv):
    """Yoneda Reconstruction Algorithm.
    
    Given a natural isomorphism between Hom(-, X) and Hom(-, Y),
    extract the underlying isomorphism X ≅ Y by evaluating at identities.
    """
    id_X = cat.identity[X]
    f = nat_iso_hom[X][id_X]  # Evaluate at X with id_X
    id_Y = cat.identity[Y]
    g = nat_iso_inv[Y][id_Y]  # Evaluate at Y with id_Y
    return f, g