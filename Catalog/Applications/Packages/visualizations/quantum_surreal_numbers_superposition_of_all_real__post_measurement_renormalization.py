import math
def post_measurement(amplitudes, keep):
    projected = [a if k else 0.0 for a, k in zip(amplitudes, keep)]
    norm = math.sqrt(sum(p**2 for p in projected))
    return [p / norm for p in projected]