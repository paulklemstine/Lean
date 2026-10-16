# REGIME 2: a RELIABLE (p=1) leak of `bits` bits per nonce.  Each signature then carries
# log2(n/span) = bits bits of information, so the key (log2 n bits) is determined by
#       t >= log2(n) / bits          <-- pure information counting, NOT the statistical law
# Test at n ~ 2^18: bits=3 -> t*>=6, bits=5 -> 3.6, bits=7 -> 2.57, bits=9 -> 2.
import numpy as np, math
def make(t, nbits, bits, seed):
    set_random_seed(seed)
    n = int(next_prime(2**nbits)); span = 1 << (nbits - bits)
    d_true = ZZ(randint(1, n - 1)); rs, ss, zs = [], [], []
    for _ in range(t):
        k = ZZ(randint(0, span - 1))
        r = ZZ(randint(1, n - 1)); z = ZZ(randint(0, n - 1))
        s = (z + r*d_true) * inverse_mod(k, n) % n
        rs.append(int(r)); ss.append(int(s)); zs.append(int(z))
    return n, span, int(d_true), rs, ss, zs
def argmax_f(n, span, t, rs, ss, zs):
    j = np.arange(n)
    fhat = np.fft.ifft(np.where(np.arange(n) < span, 1.0, -1.0))
    ds = np.arange(1, n); vals = np.zeros(n-1, dtype=complex)
    for i in range(t):
        si = pow(ss[i], -1, n); ci = (si*zs[i]) % n; mi = (si*rs[i]) % n
        vals += np.fft.fft(fhat * np.exp(-2j*np.pi*j*ci/n))[(mi*ds) % n]
    return int(np.argmax(vals.real)) + 1
NB = 18
print(f"n ~ 2^{NB}: information counting predicts t* = ceil(log2(n)/bits)", flush=True)
print(f"{'bits':>5} {'bits/sig':>9} {'pred t*':>8} | {'measured':>10}", flush=True)
for bits in [2, 3, 4, 5, 6, 7, 8, 9, 10]:
    pred = int(math.ceil(NB / bits))
    got = None
    for t in range(1, 2*pred + 4):
        w = 0
        for sd in [3, 4, 5, 6, 7]:
            nn, span, dt, rs, ss, zs = make(t, NB, bits, sd)
            w += (argmax_f(nn, span, t, rs, ss, zs) == dt)
        if w == 5:
            got = t
            break
    print(f"{bits:>5} {bits:>9} {pred:>8} | {str(got):>10}", flush=True)
print()
print("if measured == ceil(log2(n)/bits) for every bits, the reliable-leak regime is pure", flush=True)
print("information counting -- a POWER law in the leaked bits, not a logarithm.", flush=True)
