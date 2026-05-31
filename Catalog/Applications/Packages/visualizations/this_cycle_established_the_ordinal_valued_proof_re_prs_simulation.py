def simulate_prs(step, terminal, energy, initial_state, max_steps=None):
    s = initial_state
    bound = max_steps if max_steps else energy(s) + 1
    trace = [energy(s)]
    for i in range(bound):
        if terminal(s): return (s, i, trace, True)
        s_next = step(s)
        assert energy(s_next) < trace[-1]
        s = s_next
        trace.append(energy(s))
    return (s, bound, trace, terminal(s))