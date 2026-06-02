def simulate_system(initial, step, max_steps=1000):
    code, data = initial.code, initial.data
    for i in range(max_steps):
        result = step(code, data)
        if result is None: return HALTED
        code, data = result
    return RUNNING