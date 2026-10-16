# The Nonce-Leakage Frontier of ECDSA

**A working Fourier attack, two threshold regimes, and why the lattice threshold is a floor rather than the frontier**

Round 118 research paper, `factor-scratch/r118/fourier-frontier/`, `r118/composition/`,
`r118/bias-model/`, and the round 115–117 campaign record.

## Abstract

The classical attack on ECDSA given partial knowledge of the signing nonces is the lattice
hidden-number-problem (HNP) solution, and its threshold is routinely quoted as though it
bounded the leakage family. We show that this is false, and we replace the folklore with a
measured frontier.

Our contributions are: **(1)** a controlled re-measurement of the plain HNP lattice
threshold, establishing that its ~10-known-bits-per-signature cost is *intrinsic to that
lattice* — invariant to the embedding (a 20-point `(σ, β)` sweep), to reduction strength
(LLL through exact SVP), to the *position* of the leaked bits, and to the key entropy;
**(2)** a **working Fourier/maximum-likelihood attack**, implemented and verified against
brute force, whose score over all candidate keys is `t` FFTs of size `n` — `O(t·n log n)`,
no lattice and no enumeration; **(3)** two measured threshold regimes: a *reliable* leak of
`b` bits per nonce needs `⌈log₂ n / b⌉ + O(1)` signatures (pure information counting, a
power law in the leaked bits), and a *noisy* leak with advantage `A` needs
`2 ln n / A²` (statistical multiple testing); **(4)** a **candidate-set intersection
variant** that identifies the key at or *better* than the information-counting threshold, at
a **30×–3332× lower measured cost** than the FFT scan, scaling as `n / 2^b`; **(5)** both
laws validated at three scales (`2^18`, `2^20`, `2^24`, a 64× range) with positive
controls, and confirmed **position-invariant**; **(6)** a deployable protocol consequence:
ECDSA signatures transfer along any *publicly known* key translation, which on a BIP44
account amplifies one signature into `2^31 ≈ 2.1 × 10^9` verifying `(key, message)` pairs.

Precondition, stated plainly: these attacks require a real nonce bias. A correct RNG gives
`p = ½` exactly, `A = 0`, and `t* = ∞`.

## 1. Introduction and framing

ECDSA's hard problem is the elliptic-curve discrete logarithm problem on a prime-order
subgroup of `E(F_p)`; the word "factor" attaches to the scheme in four senses (group-order
smoothness, implementation moduli, sub-exponential machinery on the DLP, and the
*signature structure*), and this paper concerns the fourth. Each signature reveals
`s·k ≡ z + r·d (mod n)`; a leak of any structure in the nonce `k` turns a signature set into
a hidden-number problem.

The standing result in this area is the lattice attack (Howgrave-Graham–Smart,
Nguyen–Shparlinski, Bleichenbacher), and its threshold is routinely quoted as if it bounded
the whole leakage family. Two claims contradict that: the published Fourier/sieving methods
are quoted at 1–5 bits of leakage per *signature*, far below the ~10 the plain lattice needs
at large `t`; and no invariance result has ever covered attacks that are not lattices. This
paper measures both.

### 1.1 What was measured, and what was killed

| family | verdict in this campaign |
|---|---|
| Pohlig–Hellman / group order | the three deployed orders (`P-256`, `secp256k1`, `Ed25519`) are prime; the exchange rate is exactly ½ bit of work per bit of known factorization |
| MOV / pairing route | closed by **complete search**: `ord_n(p) ∣ n−1`, so every candidate embedding degree below `2^40` was tested (55 / 489 / 11 divisors) and none works; `ord_n(p) ≥ 92…138` bits |
| Weil descent, GHS, summation polynomials | need `n ≥ 2` fields; deployed curves are prime-field |
| XEDNI lifting | refuted in the source (Galbraith, per Galbraith–Gaudry) |
| p-adic / anomalous family | **Lean theorem**: a homomorphism from a torsion group into a torsion-free group is zero, so the log trick cannot touch a group of order prime to `p` |
| endomorphism-ring audit | no deployed curve has an attack-relevant specialness (`secp256k1` has `j = 0`/GLV but a generic 129-bit trace) |
| small keys | kangaroo `2^{b/2}`, and the lattice threshold does **not** drop with key entropy |
| structured nonces | LCG with a known multiplier: **broken in 4–6 signatures with zero leakage**; secret multiplier and GLV-sublattice variants refuted |
| plain HNP lattice threshold | **this paper**: intrinsic to the lattice |
| Fourier/maximum-likelihood | **this paper**: the frontier |

## 2. The plain HNP lattice: threshold, and why it is intrinsic

Unknowns `(d, K_1 … K_t)`, `K_i < 2^m`, `m = nbits − ℓ`, with `s_iK_i − r_id ≡ c_i (mod n)`.
On the verified harness the threshold is

```
t = 2   ->  t·ℓ* ≈ 1.03 n        t = 8  -> 1.25 n
t = 4   ->  ≈ 1.125 n            t = 16 -> 1.50 n
t ≥ 16  ->  ℓ* ≈ 5–10 bits per signature (t·ℓ* grows linearly at ~10 bits per signature)
```

and the counting bound `t·ℓ > n` is close but not binding. Three closure results pin down
*which* lattice it is:

- **Embedding.** A 20-point `(σ, β)` sweep: `σ ≤ 32` never works at any `β` (the column
  scaling is structurally required), and the best cells only tie the classical
  `(σ = ℓ, β = n)`; `σ = 256, β = 384` is strictly worse.
- **Reduction strength.** `l*` is identical for LLL and BKZ blocks 8–40. At dimension
  `t+2 ≤ 6` a block ≥ 6 is *exact SVP*, so exact SVP also fails below threshold — the
  obstruction is not reduction quality.
- **The obstruction, identified.** The embedded target is `(d, K_i·2^ℓ, …, B)` with
  `B = 2^nbits`, so `|v*|² = B² + EXCESS` and **every** candidate solution is within `√2` of
  `B`. Exact SVP's shortest `±B` vector below threshold is a valid congruence solution that
  lies *outside the box* — shorter than the true key by exactly `2(n/t − ℓ)` bits. At the
  counting bound they tie, and a tie is not enough. The threshold is the counting bound plus
  a tie-breaking margin, and that margin is a property of the instance.

So the plain-lattice threshold is intrinsic. What it is *not* is the frontier.

## 3. The Fourier / maximum-likelihood attack

Let each nonce's leak be a function `f` of the nonce (e.g. `f(k) = +1` if the top bit of `k`
is 0, else `−1`) with a bias `p > ½`. The score to maximise over candidate keys is

```
score(d) = Σ_i f( s_i⁻¹(z_i + r_i d) )
```

Expanding `f(k) = Σ_j f̂_j ω^{jk}` with `f̂ = IFFT(f)` and grouping per signature:

```
score(d) = Σ_i DFT_i( s_i⁻¹ r_i · d ),      DFT_i = FFT( f̂ · ω^{−j·s_i⁻¹ z_i} )
```

so the whole score vector over all `n` keys costs **`t` FFTs of size `n`**: `O(t·n log n)`,
with no lattice and no enumeration. Three construction errors were caught by the
brute-force control *in the same script* (factoring a non-factorable sum over signatures; the
wrong DFT convention; the wrong indices), and the sign convention was settled by comparing
the Fourier score at the true key against the direct score there — the correct convention
reproduces it exactly (`30.000` vs `30`).

**Verification.** The implemented attack agrees with brute force at every above-threshold
point (`p = 0.90, t = 32` through `p = 0.65, t = 192`), and never returns a key where brute
force returns none.

## 4. Two threshold regimes, and a corrected invariant

**Hypothesis (H):** `t* = 2 ln n / A²` with `A = E_biased[f] − E_uniform[f]`, independent of
bias shape.

**Falsified, then repaired.** With the first definition of `A` (which assumed
`E_uniform[f] = 0`, true only for a half-space indicator) the ratios came out `0.14 … 0.39`
— multi-bit biases up to 7× cheaper than predicted. For a block of width `n/2^b` the uniform
mean is `2^{1−b} − 1`, so `A = p(2 − 2^{1−b})`. Restored, the law holds: `t*A²/(2 ln n)` =
`0.552 … 1.419`, mean `1.023`, spread `2.57×` — within the `t`-grid resolution — across a
**16× range of block widths**.

**The saturation test, and the second regime.** As `p → 1` with fixed `b`, `t*` saturates —
but not at the `2 ln n/A_max²` the noisy law predicts: narrowing the block keeps pushing
`t*` *down* (5, 4, 3, 2 at `b = 4, 6, 8, 11`). A floor that keeps sinking is not a floor, and
it localizes the missing regime: with a **reliable** leak each signature carries `b` bits and
the key needs `log₂ n` of them, so

```
reliable leak:   t* = ceil(log2 n / b) + O(1)       (measured 11/7/5/4/4/3/3/3/2
                                                 vs predicted 9/6/5/4/3/3/3/2/2,
                                                 b = 2…10, n ~ 2^18)
noisy leak:      t* = 2 ln n / A^2
```

**Position invariance** (new, and not implied by the lattice result): at fixed leak width
`b`, the low-bit block, the middle block and the high block have identical thresholds
(`t* = 4` at `b = 4`, `t* = 2` at `b = 8`), survivor counts agreeing to within seed noise,
and unique identification one step later. So this is a property of the problem, and it now
covers two independent attack families.

**Scale.** Both laws were re-measured at `n ≈ 2^20` and `2^24` (a 64× range) with an `O(t)`
control that checks the Fourier score at the true key: the reliable law holds exactly
(6/4/3 and 7/5/4 for `b = 4/6/8`) and the noisy law holds with a near-constant factor
(measured/predicted `1.26`, `1.04`). The FFT cost is now measured rather than assumed:
43–82 s for the full score vector at `n ≈ 2^24`.

## 5. The intersection variant: same-or-better threshold, 2^b-fold cheaper

The FFT scan scores all `n` keys. A reliable leak into a biased set `S` of size `n/2^b`
instead gives, per signature, the candidate set

```
D_i = { (s_i k − z_i) r_i⁻¹ mod n : k ∈ S }
```

— an *affine preimage*, `O(|S|)` to build — and the key lies in `D_1 ∩ … ∩ D_t`. Measured
(`n ≈ 2^22`, exact survivor counts):

```
b    predicted   survivors by t                        first ≤ 64
3       8        524288 65534 8193 1018 136 12 3 2 1       6
4       6        262144 16378 1026 68 3 1 1                5
6       4        65536 1023 17 2 1 1                       3
8       3        16384 66 1 1 1                            3
11      2        2048 2 1 1                                2
```

Identification happens at or *better than* `⌈log₂n/b⌉` in every case (`b = 6` beats its
prediction, because the `D_i` are structured affine preimages and their intersections are
tighter than the random-set bound), and the survivor count reaches exactly **1** one step
later — the key is *determined*, with no statistical residual. Cost, measured: **0.00–0.32 s**
against the FFT's **3.4–12.3 s** — **30× to 3332× faster**, growing as `2^b`, scaling as
`n / 2^b`.

## 6. A deployable consequence: signature transfer along public key translations

The round-118 structural lemma, verified 20/20 on `secp256k1` and `P-256`:

> `(r, s)` verifies under `(Q, z)` **iff** it verifies under `(Q + λG, z − λr)` for every
> `λ ∈ ℤ_n`. ECDSA's acceptance set is an affine line, not a point.

BIP32 instantiation: the child public key *is* `Q_parent + λG` with `λ` **publicly derived**,
so a signature made at one address of a BIP44 account is a valid signature at **every**
address of that account (8/8 tested), with the amplification `2^31 ≈ 2.1 × 10^9` verifying
`(key, message)` pairs per single signature, at a cost of one scalar multiplication.
Hardening kills it exactly as theory predicts: with `λ` private, 0/11 structured candidate
messages verify, and the single one that works needs the 256-bit offset. The framing worth
carrying out: the cascade's defender-side cost model (`cascade_dominates`) has an attacker-side
dual — **the cascade does not add security per key**, because the keys are related by public
translations.

## 7. Limitations

1. **The precondition is the whole game.** These attacks require a real nonce bias. A correct
   RNG gives `p = ½` exactly, `A = 0`, `t* = ∞`. This is a side-channel frontier, not an
   algebraic break of ECDSA.
2. **Both laws are measured at `n ≤ 2^24`**; the `2^256` figures are extrapolations of laws
   validated at three scales, with logarithmic dependence on `n`.
3. **The intersection variant's cost at 2^256 is `n/2^b`**, so a `b`-bit reliable leak makes a
   `b + 2^b`-bit modulus feasible in principle; the constants and the memory model at that
   scale are not measured.
4. The `+1…2` over information counting is multiple-testing slack, measured at a `t`-grid
   resolution of 1.

## 8. Reproducibility

```
SAGE=/home/raver1975/sage_mamba/envs/sage/bin/sage
cd factor-scratch/r118/fourier-frontier
$SAGE dbg.sage       # DFT convention vs the direct score
$SAGE attack.sage    # the implemented attack vs brute force
$SAGE law.sage       # the noisy-leak threshold law
$SAGE check.sage     # the corrected advantage
$SAGE saturate.sage  # saturation as p -> 1
$SAGE floor.sage     # block-narrowing: the non-floor
$SAGE info.sage      # the information-counting regime
$SAGE predict.sage   # the (b, p) matrix
$SAGE intersect.sage # the intersection variant vs the FFT
$SAGE position.sage  # position invariance
$SAGE scale.sage     # both laws at n ~ 2^20 and 2^24
```

## 9. A second attack family discovered en route: affine nonces

The Fourier attack requires a *distributional* bias. A leak that is not distributional at
all is invisible to it, and to every statistic this campaign measured: nonces **affine in a
public sequence**,

```
k_i = c_i + Δ        c_i public (counter, timestamp, message index), Δ secret
```

substitute into `s_i k_i = z_i + r_i d (mod n)` to get `s_i c_i + s_i Δ − r_i d = z_i` — a
system **linear in the two unknowns `(Δ, d)`**. Two signatures give a 2×2 system, generically
invertible, and the key falls immediately: measured **20/20 on secp256k1** (`d·G = Q`
verified against ground truth, and `Δ` recovered too), and 20/20 for the general affine family
`k_i = a·c_i + Δ` with public `a`. No lattice, no Fourier transform, no leakage budget — and
invisible to a distributional test, because the nonces are uniform-looking.

## 10. Scale milestone

The intersection variant, pushed to the practical memory ceiling (`|S| = 2^24 ≈ 1.7 × 10^7`):
at `n ≈ 2^48` with `b = 24` it uniquely determines the key in **2 signatures in 17 s**, the
survivor count reaching exactly 1; at `2^40 / b = 16` and `2^44 / b = 20`, 3 and 2 signatures
(against predicted 4 and 4). A **2^30-times larger modulus** than the first implementation
test, same law, no new machinery.

## 11. Methodology residue

Four artefacts in this campaign were *impossible values* that flagged a harness bug rather
than a result: a survivor count of 0 (membership guaranteed by construction), a
positive control returning 0/8 where a verified attack succeeds, an all-zeros grid including
cells where the answer is computable, and a threshold measured on an instance generator
that never imposed the signature equation. The mitigation is now routine: **a null is not
publishable without a control that fires where a verified answer exists**, and impossible
values are the most useful signal available.
