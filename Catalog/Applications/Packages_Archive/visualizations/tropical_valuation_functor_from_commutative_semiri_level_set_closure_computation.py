def level_set_closure(v, seed, domain):
    val_image = {v(s) for s in seed}
    return {x for x in domain if v(x) in val_image}