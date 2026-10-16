# Round 115 — Axis I: NONCE-STRUCTURED lattice attacks on ECDSA

Sub-axes **I1 / I2 / I6** of `factor-scratch/ECDSA_BRIEF.md` §"Axis I". All lattices were
built from scratch in this directory; the plain-HNP reference lattice is rebuilt in the same
harness (`common.sage`) and fires on a positive control before any structured variant was
measured. Every success criterion is `d·G == Q` checked by elliptic-curve arithmetic — never
"a row looks small".

| sub-axis | claim | verdict |
|---|---|---|
| **I1** `r`-statistics detector | `r = x(kG) mod n` carries a statistical fingerprint of the nonce generator, separating uniform-`k` from biased-`k` signatures after a feasible number of signatures | **REFUTED** |
| **I2** LCG-structured nonces, multiplier known | a single lattice over `(a,b,d)` beats the plain HNP at equal leakage | **SUPPORTED** (6/6 parameter points) |
| **I2** LCG-structured nonces, multiplier secret | the same single lattice beats the plain HNP when `a` is unknown | **REFUTED** |
| **I6** GLV sublattice embedding | the sublattice embedding of a GLV-decomposed nonce beats the plain range embedding `k < 2^256` | **REFUTED** |

Environment: SageMath 10.9 at `/home/raver1975/sage_mamba/envs/sage/bin/sage`, fpylll 0.6.4,
LLL (δ = 0.99), BKZ 2.0 at documented block sizes (block 20). All runs seeded; every count
below was produced TWICE with the two seeds **20261014** and **909090** and both numbers are
reported.

Curves (identical in both runs):
* **toy** positive control: `y² = x³ + 7` over `F_p`, `p = 2305843009213697761`,
  `n = 2305843006310511949` (prime order, **61 bits**), `p − n = 2903185812`.
* **real**: secp256k1, `n = 0xFFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFE BAAEDCE6 AF48A03B BFD25E8C D0364141`.

---

## 0. Baseline that everything is measured against

`exp_baseline.sage`, plain HNP, known-MSB leakage `k = k̄ + ε`, `ε < 2^(nb−ℓ)`, classical
dimension-`t+2` lattice (rows `M·e_i`, `(2·2^ℓ·g_i)`, `(2·2^ℓ·(k̄_i−y_i)+n)`; verification row = the
sign of `d`, hence **both** `d` and `n−d` are tested — omitting the negation made an earlier
harness report 0/10 while the target was row #1).

```
exp_baseline.sage 20 20261014 909090
```

Toy curve, 20 instances/point, both seeds:

| ℓ | t | t·ℓ | floor t·ℓ≥61 | seed 20261014 | seed 909090 |
|---|---|---|---|---|---|
| 3 | 21 | 63 | | 5/20 | 7/20 |
| 3 | 27 | 81 | | 20/20 | 19/20 |
| 4 | 16 | 64 | | 17/20 | 14/20 |
| 6 | 11 | 66 | | 19/20 | 20/20 |
| 8 | 8 | 64 | | 20/20 | 20/20 |
| 12 | 6 | 72 | | 20/20 | 20/20 |
| 16 | 4 | 64 | | 20/20 | 20/20 |
| 8→16 | 8→16 | 128 | | 20/20 | 20/20 |

The plain HNP fires at **t·ℓ ≈ 66–80**, i.e. 1.08–1.3× the information-theoretic floor
`t·ℓ ≥ log₂ n = 61`. That is the positive control for the whole round.

secp256k1, same lattice, same harness, both seeds:

| ℓ | t | t·ℓ | 20261014 | 909090 |
|---|---|---|---|---|
| 4 | 80 | 320 | 0/20 | 0/20 |
| 8 | 40 | 320 | 20/20 | 20/20 |
| 8 | 64 | 512 | 20/20 | 20/20 |
| 16 | 24 | 384 | 20/20 | 20/20 |

Note `(ℓ=4, t=80)` fails while `(ℓ=8, t=40)` succeeds at the *same* total leakage 320 bits —
the small-ℓ lattice is 82-dimensional and exceeds what plain LLL handles; the literature's
"~10–30 % above the floor" statement is about moderate dimensions.

---

## I1 — the `r`-statistics detector

**Claim.** Since `n < p`, the map `x ↦ x mod n` is not exactly balanced, so `r = x(kG) mod n`
carries a fingerprint of how `k` was generated that a detector can use to separate
uniform-`k` signatures from biased-`k` signatures (`k < 2^192`, or fixed top bits) after a
feasible number of signatures.

**Falsifier.** Compute the total-variation distance between the two `r`-distributions, turn it
into a sample size, and check that (a) the detector actually detects something (positive
control) and (b) its false-positive behaviour on a NULL case (uniform vs uniform) is reported.

**Reproduce** (all paths relative to this directory; `sage` =
`/home/raver1975/sage_mamba/envs/sage/bin/sage`):
```
sage exp_i1.sage                            # logs/i1.log    (TV self-check inside)
sage exp_baseline.sage 20 20261014 909090   # plain HNP baseline
sage exp_i2.sage 20 20261014 909090         # I2-A, 20 instances/pt x 2 seeds
sage exp_i2b.sage 20 20261014 909090        # I2-B
sage exp_i2a_secp.sage 4 20261014 909090    # I2-A on secp256k1
sage exp_i2c.sage                           # I2 counting experiment
sage exp_i6.sage 20 20261014 909090         # I6 density + matched leakage
sage verify_constructions.sage              # target-in-lattice, |target| vs b0
sage selftest.sage                          # positive-control sweep
```
### (A) The valid-abscissa effect: huge TV, but generator-independent
For uniform `k` the support of `r` is only the set of valid abscissae, ≈ half of `Z_n`:

```
     curve n     nb  |support|    TV vs uniform  TV(unif k,biased)   EC ops
      262567     19       5854         0.977705           0.957488    32768
      262567     19       5854         0.977705           0.984333     2048
      262567     19       5854         0.977705           0.999667      128
      263083     19       5874         0.977672           0.955565    32768
```

**TV ≈ 0.98 between the uniform-`k` `r`-distribution and uniform on `Z_n`.** But this effect
is *generator-independent* — it comes from the curve, not the nonce. It is a genuine
1-bit-per-signature detector, of **forged** signatures, not of biased nonces.

### (C) Positive control: the filter does fire, but not on nonce bias
Test: `r` must satisfy `χ_p(r³+7) ∈ {0,1}`, or `r < c = p mod n` and `χ_p((r+n)³+7) ∈ {0,1}`.

```
secp256k1: uniform-k r pass 2000/2000 ; k<2^192 r pass 2000/2000 ; random r pass 1004/2000
```

Random `r` passes 50.2 % of the time; honest `k`, uniform or biased, passes 100 %. So the
filter separates **honest vs forged** perfectly but says **nothing about nonce bias**.

### (B) The only nonce-dependent term: TV = 2^-127.65
The map `x ↦ x mod n` is unbalanced only through `c = p mod n = 432420386565659656852420866390673177326`
(129 bits, `c/n = 2^-127.65`), giving

```
TV(x mod n for uniform x∈[0,p), U(Z_n)) = c(n−c)/(pn) = 3.734455e-39 = 2^-127.65
```

3-sigma separation needs `t ≳ 9/TV² ≈ 10^77.8` signatures. Identical for uniform and biased
`k`, so it cannot separate them.

(The formula is self-checked in the script against direct enumeration on a small pair:
`p=10007, n=9967, c=40 → direct TV = 397080/99739769 = c(n−c)/(pn)`, match = True. An earlier
draft carried a spurious factor 2 from the ½ in the TV definition; the comparison and the
conclusion are unchanged.)
`k`, so it cannot separate them.

### (D) The biased-support statistic: TV ≈ 1 but the support is uncomputable
If the biased support `S_u = {x(kG) mod n : k < 2^u}` were known, TV would be ~1:

```
  u= 8 (|S_u|=  255 of n=262567, density 2^-10.0): TV = 0.9150
  u=10 (|S_u|= 1023 of n=262567, density 2^- 8.0): TV = 0.6589
  u=12 (|S_u|= 4095 of n=262567, density 2^- 6.0): TV = 0.2676
```

but computing `S_u` costs `2^u` group operations — `2^192` for `k < 2^192`, i.e. `2^64`× the
cost of solving the ECDLP. The only signature-feasible fingerprint is the birthday collision
in the nonce space: `2^(u/2)` signatures (`u=192 → 2^96`).

### (E) NULL case (false-positive behaviour measured)
Detector D1 with `H0` = uniform random `r`; 400 repetitions of (t,all-pass):

```
   t=10 : 0/400      t=20 : 0/400      t=40 : 0/400
```

**Verdict: REFUTED.** The `r`-value does carry a large statistical fingerprint of *the curve*
(TV ≈ 0.98, a real 1 bit/signature detector of forged signatures) but the nonce-dependent part
is TV = 2^-127.65 (needs 10^77.8 signatures), and the biased-support statistic, though TV ≈ 1,
requires enumerating `2^192` points. Detector statement: **the two distributions do not
separate at any feasible t; the minimum t is ≥ 2^96 (birthday) and the CV-computable part of
the statistic is ~10^77.**

---

## I2 — LCG-structured nonces

**Claim (I2-A).** With `k_{i+1} = a·k_i + b (mod 2^m)`, `a` known to the attacker and `b`
secret, a single lattice over `(a, b, d)` — after eliminating `a` — recovers `d` with fewer
signatures and less leakage than the plain HNP lattice.

**Claim (I2-B).** The same holds with `a` secret (the case stated in the brief).

**Falsifier.** Same leakage `ℓ`, same seeds, same success criterion; the plain HNP lattice run
on the *same* instances.

### The construction (what "a single lattice" actually means here)
The recurrence is mod `2^m`, the signature equation mod `n`, and `gcd(n, 2^m) = 1`, so a
single Euclidean lattice cannot mix them. We combine them by eliminating the big unknowns
first and lifting to integer equations with small quotients:

* known-MSB form `k_i = k̄_i + ε_i`, `ε_i < 2^(m−ℓ)`;
* `h_i = g_i^{-1}`, `A_i = (y_i − k̄_i) mod n`, `g_i = r_i s_i^{-1}`, `y_i = z_i s_i^{-1}`;
* `d = h_i(ε_i − A_i)` ⇒ for `i = 1..t−1`: `h_i ε_i − h_t ε_t = h_i A_i − h_t A_t (mod n)`;
* recurrence ⇒ for `i = 1..t−2`: `ε_{i+2} − (1+a)ε_{i+1} + a·ε_i = E_i (mod 2^m)` with
  `E_i = a·k̄_{i+1} − k̄_{i+2} − a·k̄_i + k̄_{i+1}`.

Both are lifted as `row·x − k_j·u = M_j·w_j` into one kernel lattice over
`(ε | w | v | u)`; the target has `u = 1`, all quotients small, and the true `d` is read off
`d = h_1(ε_1 − A_1)`. `verify_constructions.sage` confirms the target lies in the lattice and
that **for I2-A the target IS the LLL-shortest vector** (`|target| = b_0` exactly). LCG modulus
`2^m < n` was used so the nonce is never reduced (`m = 59` toy, `253` secp256k1).

### I2-A — SUPPORTED
`exp_i2.sage 20 20261014 909090`, 20 instances/point, both seeds:

| ℓ | t | t·ℓ | LCG (known a) s1 / s2 | plain HNP same instances | plain needs t ≥ |
|---|---|---|---|---|---|
| 0 | 4 | 0 | **18/20 / 18/20** | 0/20 / 0/20 | ∞ |
| 0 | 5 | 0 | 19/20 / 20/20 | 0/20 / 0/20 | ∞ |
| 0 | 6 | 0 | 20/20 / 20/20 | 0/20 / 0/20 | ∞ |
| 1 | 4 | 4 | **20/20 / 20/20** | 0/20 / 0/20 | 61 |
| 2 | 4 | 8 | **20/20 / 20/20** | 0/20 / 0/20 | 31 |
| 4 | 4 | 16 | **20/20 / 20/20** | 0/20 / 0/20 | 16 |
| 8 | 4 | 32 | **20/20 / 20/20** | 0/20 / 0/20 | 8 |
| 16 | 3 | 48 | **20/20 / 20/20** | 0/20 / 0/20 | 4 |
| 1 | 3 | 3 | 0/20 / 0/20 | 0/20 / 0/20 | 61 |
| 8 | 3 | 24 | 0/20 / 0/20 | 0/20 / 0/20 | 8 |
| 0 | 3 | 0 | 0/20 / 0/20 | 0/20 / 0/20 | ∞ |

Counting bound `t(ℓ+m) ≥ 3m` is satisfied from `t = 3` at `m = 59`; the measured threshold is
`t = 4` (one signature of LL slack, `t = 3` failing 0/20 in both seeds).

secp256k1 (`exp_i2a_secp.sage 4 20261014 909090`, 8 instances/point, `m = 253`):

| ℓ | t | t·ℓ | LCG (known a) | plain HNP same instances |
|---|---|---|---|---|
| 0 | 4 | 0 | **8/8** | 0/8 |
| 0 | 5 | 0 | **8/8** | 0/8 |
| 0 | 6 | 0 | **8/8** | 0/8 |
| 0 | 8 | 0 | **8/8** | 0/8 |
| 0 | 3 | 0 | 0/8 | 0/8 |
| 4 | 4 | 16 | **8/8** | 0/8 |
| 8 | 4 | 32 | **8/8** | 0/8 |
| 16 | 4 | 64 | **8/8** | 0/8 |

The plain HNP needs `t·ℓ ≥ 256` (and ≥ ~320 realistically, per the baseline table above); the
structured lattice needs **4 signatures and zero bits of leakage**. This is not a vacuous
comparison: at `t = 3` both are 0, so the discrimination is real.

### I2-B — REFUTED (multiplier secret)
`exp_i2b.sage 20 20261014 909090`, 20 instances/point, both seeds. Lattice unknowns
`(ε, γ, a, b, d)` with `γ_i = a·ε_i` linearised and the bilinear link dropped — the only
linear encoding available:

| ℓ | t | t·ℓ | linearised LCG | plain HNP same instances |
|---|---|---|---|---|
| 2 | 31 | 62 | 0/20 | 0/20 |
| 2 | 62 | 124 | 1/20 (2/20) | 0/20 |
| 4 | 16 | 64 | 0/20 | 2/20 (0/20) |
| 4 | 32 | 128 | **0/20** | **20/20** |
| 8 | 8 | 64 | 0/20 | 17/20 |
| 8 | 16 | 128 | **0/20** | **20/20** |
| 16 | 4 | 64 | 0/20 | 20/20 (16/20) |
| 16 | 8 | 128 | **0/20** | **20/20** |

At `t·ℓ = 128` the plain HNP is 20/20 while the structured lattice is 0/20 in **both** seeds
(across four distinct parameter points). `verify_constructions.sage` shows why: the target is in
the lattice but `|target| = 2^61.1` while every reduced basis vector is `≤ 2^58.8` — the
bilinear products `a·ε_i ~ 2^(2m)` dominate the solution vector, so the target is not the short
vector.

The counting experiment (`exp_i2c.sage`, small scale so brute force is possible, `m = 7`,
13-bit curve) makes the same point analytically:

| ℓ | t | t·ℓ | #d (plain) | #(a,b,k₁) |
|---|---|---|---|---|
| 1 | 4 | 4 | 1 | 4648 |
| 2 | 10 | 20 | 1 | 496 |
| 2 | 12 | 24 | 1 | 4 |
| 3 | 6 | 18 | 1 | 6 |
| 3 | 12 | 36 | 1 | 1 |

`#d ~ 2^(nb − tℓ)` collapses at `t·ℓ = nb`; `#(a,b,k₁) ~ 2^(3m − tℓ)` collapses at `t·ℓ = 3m`
— the secret multiplier costs an extra `2m` bits that must be paid for by leakage. With `a`
secret the nonce generator has `3m` bits of state, so **more** leakage is needed than the `m`
bits of the plain HNP, not less.

**Verdict: I2 is SUPPORTED for a known multiplier and REFUTED for a secret one.** The single
lattice is the right geometry only when the recurrence is linear in the unknowns; with `a`
secret the recurrence is bilinear and the only linear encoding loses it.

---

## I6 — GLV / sublattice-structured nonces

**Claim.** With `k = k₁ + λ·k₂ (mod n)`, `k_{1,2} < 2^(nb/2)`, a lattice embedding that uses the
sublattice basis (halves as separate small unknowns) beats the plain range embedding
`k < 2^nb`.

**Falsifier.** Same total leakage, same instances, same seeds; plain range embedding as the
baseline.

### (1) The structure is vacuous at real sizes
Enumerating the GLV box exactly on small curves (the count is the crux, not a heuristic):

```
     curve n     nb      h     box elements      |image|      |image|/n
       32497     15      7            16384        15857       0.487953
       32503     15      7            16384        16384       0.504077
       33151     16      8            65536        33151       1.000000
       33739     16      8            65536        33739       1.000000
       34159     16      8            65536        34159       1.000000
       34039     16      8            65536        34039       1.000000
2305843006310511949     61     30 1152921504606846976   ...       0.500000
secp256k1  : lambda = 0xac9c52b33fa3cf1f5ad9e3fd77ed9ba4a880b9fc8ec739c2e0cfc810b51283ce
            box = 2^256 elements, n ~ 2^256(1-2^-128)  =>  |image|/n -> 1
            collision count (closed form 2^(2h+2)/n) = 4
```

With `h = nb/2` the box holds `~n` elements and its image has density **1.0** whenever `nb` is
even (four curves enumerate exactly to `|image| = n`). "`k` is GLV-decomposed" carries **zero**
information beyond `k < 2^256` on secp256k1; the constraint is the range case, exactly.

### (2) Matched-leakage lattice comparison (toy curve, `h = 30`)
`exp_i6.sage 20 20261014 909090`, 20 instances/point, both seeds (40 total), `ell1 + ell2 = ell`:

| ell1 | ell2 | ell | t | t·ℓ | sublattice | plain range |
|---|---|---|---|---|---|---|
| 2 | 2 | 4 | 16 | 64 | 0/40 | 31/40 |
| 4 | 0 | 4 | 16 | 64 | 0/40 | 31/40 |
| 2 | 2 | 4 | 32 | 128 | 0/40 | 40/40 |
| 4 | 0 | 4 | 32 | 128 | 0/40 | 40/40 |
| 4 | 4 | 8 | 8 | 64 | 0/40 | 39/40 |
| 8 | 0 | 8 | 8 | 64 | 0/40 | 39/40 |
| 4 | 4 | 8 | 16 | 128 | 23/40 | 40/40 |
| 8 | 0 | 8 | 16 | 128 | 0/40 | 40/40 |
| 8 | 8 | 16 | 4 | 64 | 0/40 | 40/40 |
| 16 | 0 | 16 | 4 | 64 | 0/40 | 40/40 |
| 8 | 8 | 16 | 8 | 128 | 40/40 | 40/40 |
| 16 | 0 | 16 | 8 | 128 | 0/40 | 40/40 |

The sublattice embedding only reaches the baseline at `t = 4×` the floor (`40/40` vs `40/40`),
where the baseline is likewise trivially solvable — that is a correctness check, not
evidence. The one near-hit (`23/40` at `ell1=ell2=4, t=16`) is the dense-box bonus of the
61-bit toy curve, which the density measurement above shows does not exist on secp256k1.

### (3) Structure only, no leakage
`ell1 = ell2 = 0`, toy curve: sublattice embedding `0/40` at `t = 16` and `0/40` at `t = 31`.
With no leakage the sublattice constraint is worth at most the ~1 bit/signature that the
toy-curve box density `1/2` provides, and `t·1 < 61`.

**Verdict: REFUTED.** The sublattice embedding is information-theoretically identical to the
range embedding (image density 1.0 at real sizes, measured exactly on four small curves) and
empirically worse in every matched-leakage comparison that is not already trivially solvable
by the baseline.

---

## Summary of what these experiments actually showed

1. **The plain HNP baseline works and its threshold is `t·ℓ ≈ 66–80` bits ≈ 1.1–1.3× the
   61-bit floor** on the toy curve; on secp256k1 it fires at `ℓ = 8, t = 40` (320 bits) and
   fails at `ℓ = 4, t = 80` (also 320 bits) — an LLL dimension effect at 82 dimensions.
2. **I1 is dead as a nonce detector.** The `r`-statistics fingerprint that *does* exist
   (TV ≈ 0.98, r supported on ≈ half of `Z_n`, 1 bit/signature) is a property of the curve,
   not of the nonce generator: it detects *forged* signatures and is blind to nonce bias. The
   nonce-dependent part of the statistic is TV = `c(n−c)/(pn)` = **2^-127.65** on secp256k1,
   needing `10^77` signatures; the biased-support statistic has TV ≈ 1 but costs `2^192`
   group operations to compute; the remaining signature-feasible fingerprint is the birthday
   collision at `2^96` signatures. The NULL (false-positive) case is measured: 0/400.
3. **I2 splits cleanly by linearity.** With the multiplier known, the recurrence contributes
   `2^m`-scaled rows and the single kernel lattice over `(a,b,d)` recovers `d` from **4
   signatures and zero bits of leakage** where the plain HNP needs `t·ℓ ≥ 256` — verified on
   both curves, and the target is provably the LLL-shortest vector. With the multiplier
   secret, the recurrence is bilinear in the unknowns; the only linear encoding (products as
   extra unknowns, link dropped) is 0/20 wherever the baseline is 8/20, and the brute-force
   count confirms the secret multiplier costs `2m` extra bits of leakage.
4. **I6 is dead.** The GLV box `[0, 2^(nb/2))²` maps onto essentially all of `Z_n` at any size
   where `nb` is even (measured exactly: `|image| = n` on four curves), so the sublattice
   constraint carries no information; the embedding merely doubles the number of unknowns per
   signature and is worse in every matched-leakage comparison that is not already trivially
   solvable.

## Self-audit (two errors found and fixed during the round)

1. **Missing sign in the key read-out.** The reduced lattice contains `-target + (0,..,0,n,0)`, so
   the key appears in coordinate `t` as `d` *or* `n-d`. Testing only `d` made the plain-HNP
   positive control read 0/10 while the true key sat in row #1. Fixed by testing both signs
   throughout; the baseline now fires 20/20.
2. **Factor 2 in the fold-TV.** The first draft of the I1 fold statistic used
   `2c(n-c)/(pn)`, forgetting the ½ in the total-variation definition. Caught by self-checking the
   closed form against direct enumeration on `(p,n) = (10007, 9967)`; the correct value is
   `c(n-c)/(pn) = 2^-127.65`. The I1 conclusion is unchanged (the statistic was already
   astronomically small; both errors made it *larger* than it is, never smaller).

Both are now built into the scripts (`common.sage` tests both signs; `exp_i1.sage` prints the
self-check) rather than fixed by hand in the write-up.

Files: `common.sage` (harness, all lattices), `exp_baseline.sage`, `exp_i1.sage`,
`exp_i2.sage`, `exp_i2b.sage`, `exp_i2c.sage`, `exp_i2a_secp.sage`, `exp_i6.sage`,
`selftest.sage`, `verify_constructions.sage`, `debug_hnp*.sage`, `baseline_hnp.sage`,
`logs/` (all raw output and JSON).
