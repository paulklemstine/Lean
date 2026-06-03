import math
def proof_length_lower_bound(n, s, conductance):
    if conductance <= 0 or s <= 0 or n <= 2 * s:
        return 0.0
    return math.log(n / (2 * s)) / math.log(1 + conductance)