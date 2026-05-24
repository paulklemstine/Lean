import math
from collections import defaultdict

def extract_profile(cert):
    hyp_support = frozenset(t[2] for t in cert)
    leg_support = frozenset(t[0] for t in cert) | frozenset(t[1] for t in cert)
    prim_count = sum(1 for t in cert if math.gcd(t[0], t[1]) == 1)
    hyp_counts = defaultdict(int)
    for t in cert:
        hyp_counts[t[2]] += 1
    overlap = sum(1 for c in hyp_counts.values() if c > 1)
    return (hyp_support, leg_support, prim_count, overlap)

# Example
cert = [(3,4,5), (5,12,13), (8,15,17)]
print(extract_profile(cert))