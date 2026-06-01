def transfer_separation(sim, n):
    witness = sim.h2.separation_witness(n)
    translated = sim.translate(witness)
    oh = sim.overhead(n + 1)
    assert translated in sim.h1.level(oh)
    assert translated not in sim.h1.level(n)
    return translated