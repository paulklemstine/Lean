# Is the true key in every D_i?  If not, the instance generation is inconsistent with the
# candidate-set computation -- a bug, not a phenomenon.
import numpy as np
set_random_seed(3)
n = int(next_prime(2**18))
j, bits = 0, 4
block = ((1 << bits) - 1) << j
notblock = ((1 << 18) - 1) ^ block
d_true = int(ZZ(randint(1, n - 1)))
t = 5
rs, ss, zs, ks = [], [], [], []
for _ in range(t):
    k = int(ZZ(randint(0, n - 1)))
    if random() < 1.0:
        k = k & notblock
    r = int(ZZ(randint(1, n - 1))); z = int(ZZ(randint(0, n - 1)))
    s = (z + r * d_true) * pow(k, -1, n) % n
    rs.append(r); ss.append(s); zs.append(z); ks.append(k)
print("n =", n, " block =", block, " d_true =", d_true, flush=True)
print("nonces:", ks, flush=True)
print("nonce & block:", [k & block for k in ks], "  (must all be 0)", flush=True)
S = np.arange(n, dtype=np.int64)
S = S[(S & block) == 0]
print("|S| =", len(S), flush=True)
inD = []
for i in range(t):
    Di = ((int(ss[i]) * S - zs[i]) % n) * pow(rs[i], -1, n) % n
    inset = d_true in set(Di.tolist())
    inD.append(inset)
    # also verify the relation directly: s_i k_i = z_i + r_i d
    k_at_d = (zs[i] + rs[i] * d_true) * pow(ss[i], -1, n) % n
    print(f"  i={i}: d_true in D_i: {inset}   k_i(d_true) = {k_at_d}  == nonce: {k_at_d == ks[i]}", flush=True)
print("true key in ALL D_i:", all(inD), flush=True)
