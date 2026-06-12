def circuit_eval(basis, target, input_set):
    for t, support in basis:
        if t == target and support <= input_set:
            return True
    return False