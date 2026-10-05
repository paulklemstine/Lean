# Generate GIFP instances from the PRIMARY SOURCE
# (Experiments/UMWWindow/gifp_ref/gifp.sage) and save them, so the baseline
# measurement is on the same instance the attack claimed.
#
# Run: ~/sage_mamba/envs/sage/bin/sage mkinst.py
import sys, json, os
os.chdir('/home/raver1975/lean/factor-scratch/r113/adversarial-audit')
from sage.all import *
load('/home/raver1975/lean/Experiments/UMWWindow/gifp_ref/gifp.sage')

def make(n, alpha, gamma, beta1, beta2, seed, tries=6):
    for s in range(seed, seed + tries):
        r = generate_gifp_instance(n, alpha, gamma, beta1, beta2, seed=s, max_attempts=1)
        if r is not None:
            return s, r
    return None, None

specs = [
    # (n, alpha, gamma, beta1, beta2, seed, tag)
    (200, 0.10, 0.70, 0.1, 0.15, 1791165034802635, "n200"),
    (600, 0.10, 0.70, 0.1, 0.15, 20261005,        "n600"),
    (800, 0.10, 0.70, 0.1, 0.15, 20261005,        "n800"),
]
out = {}
for (n, a, g, b1, b2, seed, tag) in specs:
    s, r = make(n, a, g, b1, b2, seed)
    if r is None:
        print("FAILED to generate", tag)
        continue
    (p1, q1, N1), (p2, q2, N2), share, sol = r
    assert p2 * q2 == N2 and p1 * q1 == N1
    out[tag] = dict(n=n, alpha=a, gamma=g, beta1=b1, beta2=b2, seed=int(s),
                    N2=int(N2), p2=int(p2), q2=int(q2), N1=int(N1),
                    p1=int(p1), q1=int(q1))
    print("%-6s seed=%-18d N2 bits=%-5d |q2| bits=%-4d |p2| bits=%-5d  N2==p2*q2 -> %s"
          % (tag, s, N2.nbits(), ZZ(q2).nbits(), ZZ(p2).nbits(), int(p2) * int(q2) == int(N2)))
json.dump(out, open("instances.json", "w"))
print("\nwrote instances.json")
