# SHARP PREDICTION: the threshold SATURATES as the bias strengthens.
#
# With A = p(2 - 2^{1-bits}) for a block bias of width n/2^bits, the law t* = 2 ln n / A^2
# gives, as p -> 1:
#       A -> A_max = 2 - 2^{1-bits},      t* -> 2 ln n / A_max^2   (a FLOOR)
# For n ~ 2^18 (ln n = 12.48) and bits = 4: A_max = 1.9375, t*_min = 6.6
#                                  bits = 2: A_max = 1.5000, t*_min = 11.1
# So the number of signatures cannot be pushed below ~7 (bits=4) or ~11 (bits=2), however
# strong the leak -- and t* should flatten, not keep falling.
#
# Also: a step-1 grid (the previous measurement used steps of 8/16/24/32/48, which left a
# 2.57x spread unresolved) and the full success-rate curve, whose rise should be steep
# around t*.

import numpy as np, math

def make(p, t, nbits, bits, seed):
    set_random_seed(seed)
    n = int(next_prime(2**nbits))
    span = 1 << (nbits - bits)
    d_true = ZZ(randint(1, n - 1))
    rs, ss, zs = [], [], []
    for _ in range(t):
        k = ZZ(randint(0, span - 1))
        if random() < (1 - p):
            k = ZZ(randint(0, n - 1))
        r = ZZ(randint(1, n - 1)); z = ZZ(randint(0, n - 1))
        s = (z + r * d_true) * inverse_mod(k, n) % n
        rs.append(int(r)); ss.append(int(s)); zs.append(int(z))
    return n, span, int(d_true), rs, ss, zs

def argmax_fourier(n, span, t, rs, ss, zs):
    j = np.arange(n)
    fhat = np.fft.ifft(np.where(np.arange(n) < span, 1.0, -1.0))
    ds = np.arange(1, n)
    vals = np.zeros(n - 1, dtype=complex)
    for i in range(t):
        si = pow(ss[i], -1, n)
        ci = (si * zs[i]) % n; mi = (si * rs[i]) % n
        vals += np.fft.fft(fhat * np.exp(-2j * np.pi * j * ci / n))[(mi * ds) % n]
    return int(np.argmax(vals.real)) + 1

NB = 18
ln_n = math.log(float(next_prime(2**NB)))
SEEDS = [3, 4, 5, 6]
print(f"n ~ 2^{NB}, ln n = {ln_n:.2f}, {len(SEEDS)} seeds per point, step-1 t grid", flush=True)
for bits in [4, 2]:
    for p in [0.90, 0.97, 0.99, 1.00]:
        Amax = 2 - 2.0**(1 - bits)
        A = p * Amax
        pred = 2 * ln_n / (A * A)
        curve = []
        for t in range(1, 33):
            w = sum(argmax_fourier(*make(p, t, NB, bits, sd)[:3] + [make(p, t, NB, bits, sd)[3],
                    make(p, t, NB, bits, sd)[4], make(p, t, NB, bits, sd)[5]] == make(p, t, NB, bits, sd)[2])
                    for sd in SEEDS) if False else None
            wins = 0
            for sd in SEEDS:
                nn, span, dt, rs, ss, zs = make(p, t, NB, bits, sd)
                wins += (argmax_fourier(nn, span, t, rs, ss, zs) == dt)
            curve.append(wins)
        # first t with all seeds winning
        full = next((i + 1 for i, w in enumerate(curve) if w == len(SEEDS)), None)
        half = next((i + 1 for i, w in enumerate(curve) if w >= len(SEEDS) // 2 + 1), None)
        print(f"bits={bits} p={p:.2f}  A={A:.3f}  pred t*={pred:5.1f} | first all-win t={full}  "
              f"first majority t={half}", flush=True)
        print("        success rate: " + " ".join(f"{w}" for w in curve), flush=True)
print()
print("prediction: as p->1 the first all-win t saturates at ~2 ln n / A_max^2 =",
      f"{2*ln_n/(2-2.0**(1-4))**2:.1f} (bits=4) and {2*ln_n/(2-2.0**(1-2))**2:.1f} (bits=2)", flush=True)
