def tropical_transport(bijection, energy):
    f_inv = {v: k for k, v in bijection.items()}
    return {x: energy[f_inv[x]] for x in energy}