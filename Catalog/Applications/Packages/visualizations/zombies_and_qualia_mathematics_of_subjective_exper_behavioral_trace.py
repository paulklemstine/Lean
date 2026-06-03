def behavioral_trace(transition, output, s0, inputs):
    trace = []
    state = s0
    for inp in inputs:
        trace.append(output(state))
        state = transition(state, inp)
    return trace