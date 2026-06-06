def extension_beneficial(theory, da, dt, dc):
    c, t, a = theory.connection_count, theory.theorem_count, theory.axiom_count
    return (c + dc) * (t + dt) * a**2 > c * t * (a + da)**2