def compose_sim(sim_S, sim_T):
    def composed(a, b):
        t = sim_T(a, b)
        return sim_S(t, t)
    return composed