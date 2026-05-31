import math
def proof_length_lower_bound(num_theorems, alphabet_size):
    if num_theorems <= 1: return 0
    return math.ceil(math.log(num_theorems, alphabet_size))