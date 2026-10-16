# RESULT — T119: the ω/λ endomorphism relation as a *signature-side* attack on secp256k1

Round 119, `factor-scratch/r119/endomorphism/`.
**Verdict: REFUTED.** The brainstormed identity is false on real secp256k1.
The endomorphism is real and verified; the r-level relation is a **mod-p / mod-n
commutation error**. The related-nonce *break* is real and repeats 100% of the
time, but it needs an oracle, the r-relation cannot supply one, and finding such
pairs costs ~2^128 signatures.

---

## 1. The claim, and the exact place it breaks

secp256k1 has `j = 0`, `p ≡ 1 (mod 3)`, so `φ(x,y) = (ωx, y)` with `ω³ = 1 (mod p)`,
`ω ≠ 1`, is an automorphism defined over `F_p` and satisfies `φ² + φ + 1 = 0` in
`End(E)`. Because `#E(F_p) = n` is **prime** (cofactor 1), `E(F_p)` is cyclic of
order `n`, so every automorphism is a scalar multiplication:

```
φ = [λ]     with     λ² + λ + 1 ≡ 0  (mod n)
```

`λ` was constructed from `sqrt(-3) mod n` and independently re-derived by a
hand-written baby-step giant-step discrete log (`φ(G) = λG`, `verify.sage`);
both agree.

```
n        = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141   (prime)
p        = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
p - n    = 432420386565659656852420866390673177326   (~2^128.3)     →  p ≢ 0 mod n
ω        = 0x851695d49a83f8ef919bb86153cbcb16630fb68aed0a766a3ec693d68e6afa40  (one of the two)
λ        = 0xac9c52b33fa3cf1f5ad9e3fd77ed9ba4a880b9fc8ec739c2e0cfc810b51283ce
λ'       = 0x5363ad4cc05c30e0a5261c028812645a122e22ea20816678df02967c1b23bd72   (= −1−λ mod n)
```

There are exactly two nontrivial cube roots of unity in each group. Which one is
`φ = [λ]` for the map `(x,y) ↦ (ωx,y)` depends on which conjugate `ω` is used;
both scripts determine the pairing empirically by checking `[λ]G == φ(G)`
(run-to-run, `h1_control` and `verify` report conjugate `λ`'s for their random
`ω`). `0xac9c52b3…` is the GLV endomorphism constant already recorded by r115 of
this campaign — `verify.sage` confirms `φ(G) == [0xac9c52b3…]G` for its choice of
`ω`, and that the same value satisfies `λ²+λ+1 ≡ 0 (mod n)`.

The brainstorm then claims, for a signature with nonce `k` and `r = x(kG) mod n`:

```
CLAIM:   x([λ]kG) mod n  ==  (ω · r) mod n          … "computable from the signature alone"
```

Its proof runs `x(kG) = r + m·n`, says the `m·n` term drops out mod n, and
concludes `(ω·x(kG)) mod n == (ω·r) mod n`. **That step is arithmetically true**
(measured: 300/300 in `h1_control.sage`) — but it is a statement about the
*integer* product `ω·X`, **not** about the x-coordinate of the transformed point.
The actual x-coordinate is reduced mod p:

```
x([λ]kG) = (ω·X) mod p = ω·X − c·p,      c = floor(ω·X/p) ∈ [0, ω)
r([λ]k)  = (ω·X − c·p) mod n = (ω·r − c·p) mod n
```

So the "m-bit" does drop out, but a `c·p` term takes its place, and it does
**not**: `p mod n = p − n ≈ 2^128.3 ≠ 0`. Hence

**EXACT CONDITION (verified exhaustively on 8 curves, `omega_size.sage`):**

```
CLAIM holds  ⇔  c·p ≡ 0 (mod n)  ⇔  floor(ω·X/p) ≡ 0 (mod n)
```

On secp256k1 both `ω` and `n` are 256-bit, so `c` ranges over ~2^256 values of
which only `~ω/n` are divisible by `n`; the claim holds with probability
`~1/n ~ 2^-256`. In `h1_control.sage` it held **0/300** times.

> `x([λ]kG) == (ω·x(kG)) mod p` — the F_p identity — fires **300/300**.
> The claim is not "the endomorphism doesn't work"; it is "reduction mod p does
> not commute with reduction mod n".

---

## 2. Positive control (mandatory) — FIRES, before anything else

| control | construction | result |
|---|---|---|
| `ω ∈ F_p`, `ω³=1`, `ω≠1` | `g^((p-1)/3)` | OK |
| `φ` maps `E`→`E`, is a homomorphism, `φ³=id` | 40 random points | True |
| **`φ == [λ]` on `E(F_p)`** | 6 + 25 random `k`, both conjugate roots tested | True |
| **F_p identity** `x([λ]kG) == (ω·x(kG)) mod p` | 300 random `k` | **300/300** |
| m-bit integer identity `(ωX) mod n == (ωr) mod n` | 300 random `k` | 300/300 (true, irrelevant) |
| `m := X//n ∈ {0,1}` (needs `p < 2n`) | 300 random `k` | 300/300 (m=0 always) |
| `λ` by **discrete log** satisfies `λ²+λ+1 ≡ 0 mod n` | own BSGS | OK |
| secp256k1 `λ` == the r115-published GLV value | cross-round | OK |

---

## 3. H2 — the related-nonce break is REAL, but it is an oracle

Two signatures with `k₂ = λ·k₁` give two linear equations in the two unknowns
`(k, d)`:

```
s₁k = z₁ + r₁d ;   s₂(λk) = z₂ + r₂d      →  det = −s₁r₂ + r₁λs₂
```

**25/25** key recoveries on real secp256k1, each verified `dh == d` and
`dh·G == Q` (a wrong `d` is caught: forcing the relation on unrelated nonces
recovers garbage, 0/5). Exhaustively on a small curve: **34032/34032**
(`verify.sage`, every `k` in `[1, n-2]`, no sampling).

So the break itself is not in doubt. The question is whether the **r-relation
supplies the relatedness**, and it does not:

| test | result |
|---|---|
| detector `r₂ ≡ (ω·r₁) mod n` on **genuinely** λ-related pairs | **0/200** |
| the same detector on 60 signatures / 3540 ordered pairs (one key) | 0/3540 |
| forcing the relation on *unrelated* nonces → correct key | 0/5 |
| **refined** 2-candidate detector `r₂ ∈ {(ω(r₁+jn) mod p) mod n}` | **200/200** |
| refined detector recall, small curve, planted pair, 3 sizes | 300/300 each |

The honest version of the detector (two candidates, because `r` leaves `x = r` or
`x = r+n` ambiguous) has **perfect recall**. But recall is not the problem —
precision is. A random pair also matches the 2-candidate test with probability
`2/|S|` (see H3), so the detector finds coincidences, not related nonces.

---

## 4. H3 — cost of *finding* a related pair: a CHECK, not a SEARCH

`rho = P(rⱼ = (ω·rᵢ) mod n)` measured by counting targets inside a 200 000-value
pool (`O(POOL)`, not sampling), and the median `N` by direct birthday experiment.
Small curves are re-drawn every run, so these numbers move a little between runs
(observed slopes 0.475–0.525, predicted/measured ratios 0.92–1.12); the run quoted
is the one in `h3_cost.log`:

| curve | `n` | `|S|` | `ρ` measured | `1/n` | `N` measured | `N` predicted |
|---|---|---|---|---|---|---|
| 16-bit | 39901 | 19950 | 2.508e-05 | 2.506e-05 | 175 | 166 |
| 20-bit | 549097 | 274231 | 1.827e-06 | 1.821e-06 | 603 | 615 |
| 24-bit | 14350729 | 7173495 | 7.027e-08 | 6.968e-08 | 3353 | 3140 |

* log-log slope of `N` against `|S|` = **0.502** (birthday predicts 0.5).
* Precision of the detector on random nonces: **0/184, 0/183, 0/186** genuine.
* Recall of the naive detector on planted λ-related pairs: **0–1/300** (it cannot
  see its own targets); recall of the refined detector **300/300**.

`ρ` is the *directed* rate; an unordered pair hits in either direction, so
`P(hit among N) ≈ 1 − exp(−2ρ·N²/2)` and the median is `N = sqrt(ln 2 / ρ)`:

```
median N (naive, as claimed)    = sqrt(ln 2 · n)   = 2^127.736   → ~2^128 signatures
median N (refined, 2 candidates)= sqrt(ln 2 · n/2) = 2^127.236
```

At 10³ / 10⁶ / 10⁹ signatures per second that is 9.0e27 / 9.0e24 / 9.0e21 years;
storage at that scale is ~1e39 bytes. And this is a search for an event that
honest signing never produces: ECDSA nonces are iid uniform, so
`P(kⱼ = λkᵢ) = 0` for `i ≠ j`.

**Reported answer to H3: ~2^128 signatures, i.e. infeasible by every physical
margin. The relation is a check, not a search.**

### The small-curve trap (and the guard that catches it)

A *tiny* curve can make the claim hold trivially, which would have produced a
false "SUPPORTED" if the brainstorm had been tested only on a small curve:

* `y²=x³+39` over `F_2791`, `n = 2791 = p` (an **anomalous** curve), `ω = 91`:
  the claim holds for **2790/2790 = 100%** of nonces, because with `p == n` every
  `x(kG)` is already `< n` and everything reduces mod p.
* On curves where `ω` happens to be a small integer (`ω ≲ n`), the claim rate
  is `1/ω` instead of `1/n` — measured 0.0096, 0.0046, 0.0018 etc. across 8
  curves, and the rate equals the `c·p ≡ 0 (mod n)` count **exactly** in every
  case. The rate on secp256k1 is `1/n ~ 2^-256`.

`h3_cost.sage` therefore contains a guard that **rejects** any candidate curve
which does not reproduce secp256k1's behaviour (it rejected 1 candidate per
size in each of the last five runs; the unguarded earlier run had produced
`93/181` "genuine" detector hits on a degenerate `n=1951` curve — this is what
the guard is for).

---

## 5. H4 — statistical structure: none that is usable (NULL CONTROL first)

Small curve with full enumeration (`y²=x³+3` over `F_951079`, `n = 949159` prime,
`p = 951079`, `|S| = 474097`, density `0.4995`). `M = 20000` per histogram,
`B = 50` bins, `|S| ≫ M` (a smaller curve saturates the histograms and the
chi-square says nothing — an earlier version of this script had that bug).

* **Multiset invariance is EXACT**: `multiset{X mod n} == multiset{(ω·X mod p) mod n}`
  over all x-coordinates (`Counter` equality). But this is a statement about the
  *whole multiset over all nonces*; no individual `r` witnesses it.
* **The claimed map does not preserve the achievable set**:
  `|{r ∈ S : (ωr) mod n ∈ S}| / |S| = 0.4993` versus the required `1.000`,
  chance `|S|/n = 0.4995`. The refined 2-candidate map: `1.0000` (as it must be).

Chi-square battery, `z = (χ²−df)/√(2df)`, **NULL control first**:

| comparison | χ² | df | z | reading |
|---|---|---|---|---|
| **NULL** uniform nonce batch vs independent batch | 41 | 49 | −0.82 | at the null → rig is sound |
| real `r` vs random valid `r ∈ S` | 48 | 49 | −0.08 | same law |
| 8 bits of nonce entropy vs uniform | 1291 | 49 | +125 | entropy collapse → r clumping; ordinary, **not** ω-related |
| `kⱼ = a + j·c` (secret step) vs uniform | 48 | 49 | −0.10 | at the null |
| consecutive nonces (step 1) vs uniform | 43 | 49 | −0.58 | at the null |
| naive forged `r ∈ [0,n)` vs real | 67 | 49 | +1.77 | the support restriction is *invisible* at histogram scale |
| forged `r ∈ S` vs real (competent forger) | 48 | 49 | −0.08 | at the null |
| `η(r) = (ωr) mod n` vs `r` itself | 64 | 49 | +1.56 | no distinguishable change in the r-law |
| `r(k)` vs `r(λk)` | 45 | 49 | −0.45 | at the null |

* **Per-signature test** — the only form the brainstorm could take, "is `η(r)`
  an achievable r?": real signatures **0.4989**, naive forged **0.4940**,
  chance **0.4995**. No discrimination at all.
* **The only structure** is that `r` lives in `S = {x-coords mod n}` with
  `|S| = (n−1)/2`. Unrelated to ω, invisible per signature, invisible to a
  histogram, and it needs `M > 3√(2n) = 2^130` (collision) or
  `M > 4.44·n^(2/3) = 2^173` (best-bin chi-square) signatures on secp256k1.
  (Both NULL-control batches sit at the predicted `1/|S|` collision rate, so the
  statistic is calibrated.)
* **Bonus finding (not ω-related, worth recording):** an *affine* nonce sequence
  `kⱼ = a + j·c` produces a **collision-free** r-set (0 collisions in 20 000
  draws against ~990 expected), while being at the null on every histogram bin.
  Collision counts, not histograms, detect structured nonce sequences — but
  exploiting known affine nonces is the H2 related-nonce algebra, not this.

**Answer to H4: no.** The ω-invariance imposes nothing testable on a single
signature, and nothing that distinguishes a correct signature from a forged one
or a biased nonce generator from a uniform one.

---

## 6. Traps hit while measuring this

1. **The mod-p/mod-n commutation** (§1) — the central error, and the reason the
   claim is false.
2. **`ω` and `λ` live in different groups.** I first wrote "`ω² mod n`" and a
   "3-cycle of `r ↦ ωr mod n` gives rate 2/n". `ω ∈ F_p`, `λ ∈ Z/nZ`; there is
   no such 3-cycle at the r-level and the rate is `1/n`, not `2/n`. Fixed before
   the numbers were quoted, and the corrected model matches to 1%.
3. **Directed vs unordered pairs.** Using the directed rate `ρ` in
   `N = sqrt(2ln2/ρ)` was off by exactly `√2`; an unordered pair hits in either
   direction, so `N = sqrt(ln 2/ρ)`. The measured medians moved from a 1.44×
   mismatch to 0.92–1.12 agreement.
4. **Small-curve degeneracy** (§4): an anomalous curve (`p = n`) makes the claim
   hold 100%, and a small `ω` makes it hold `1/ω`. A guard now rejects curves
   that do not reproduce secp256k1's behaviour; without it the h3 precision cell
   read `93/181`, which would have been reported as a partial success.
5. **Sage preparse grotto**: `Float(n)` is not on the preparse path (`NameError`)
   and had to be `float(n)`; and a `v1` cross-check I wrote multiplied two
   *different* random `k`'s against each other, so it compared unrelated points
   and printed `False`. It was replaced with a real check.
6. **Chi-square cannot see the support.** I originally read the `S2/F2` cells as
   a "support 2×" signal. They are at the null: coarse bins put `M/B` in every
   bin for *both* the `S`-supported and the full-support samples. The support
   shows up only in collision counts (and, on curves with `p > n`, through the
   *folding prefix* `[0, p−n)` where x-coords from both `[0,p−n)` and `[n,p)`
   fold together, giving `S` density ~1 there instead of ~1/2 — a `2^-128`
   sliver of the range on secp256k1).
7. **A tiny curve breaks the histogram tests**: with `n = 3229` and `M = 20000`
   the histograms saturate and everything reads as a difference. Fixed by
   requiring `n > 40·M`.
8. **`x == n` crashes `xint`** in a reference enumeration (nonsense assertion on
   the point at infinity) — guarded with `min(4000, n−1)`.
9. **`E.discrete_log` and `sage.groups.generic.discrete_log` do not exist / do
   not parse in this build**; `λ` was re-derived with a hand-written BSGS instead.

---

## 7. Reproduce

```
cd /home/raver1975/lean/factor-scratch/r119/endomorphism
/home/raver1975/sage_mamba/envs/sage/bin/sage h1_control.sage   # positive control + the claim
/home/raver1975/sage_mamba/envs/sage/bin/sage h2_related.sage   # related-nonce break, d*G == Q
/home/raver1975/sage_mamba/envs/sage/bin/sage h3_cost.sage      # measured birthday cost
/home/raver1975/sage_mamba/envs/sage/bin/sage h4_stats.sage     # chi-square + NULL control
/home/raver1975/sage_mamba/envs/sage/bin/sage omega_size.sage   # exact condition, exhaustive
/home/raver1975/sage_mamba/envs/sage/bin/sage verify.sage       # independent re-derivation
```
or `./runall.sh` (all six, logs to `*.log`). Runtime ≈ 20 minutes total.

Every key-recovery figure is guarded by `d·G == Q`; every scalar comparison is
between plain `Integer`s, never between a `GF(p)` element and an integer.

---

## 8. Verdict

**REFUTED.** The claimed `r_λ = (ω·r) mod n` is false on secp256k1, and the
reason is exact and measured: `x([λ]kG) = (ω·x(kG)) mod p`, and reducing mod p
before reducing mod n introduces a `c·p` term with `c = floor(ω·X/p)` that is a
multiple of `n` only with probability `~1/n ~ 2^-256`.

What survives, and is worth recording so the round is not a pure negative:

* **φ = [λ] on `E(F_p)` with `λ²+λ+1 ≡ 0 (mod n)` is verified from first
  principles** (two independent constructions, plus agreement with r115's λ).
* **The related-nonce 2x2 break works**, 25/25 and exhaustively over every nonce
  on a small curve (34032/34032 in the final run), verified against `d·G == Q`.
  It is unrelated to the ω-relation; it works for *any* known nonce relation
  `k₂ = μk₁`, and the campaign already restricts such breaks to leakage models
  that reveal the relation.
* **A corrected detector exists**: from `r` alone, `r([λ]k)` lies in a 2-element
  candidate set, 200/200 (and 300/300 per small curve). It is a perfect *check*
  of a pair you already have, and a useless *search* for one you don't.
* The only statistical structure in `r` is the `|S| = (n−1)/2` support, which is
  unrelated to ω and needs a 2^130–2^173 sample.

**Falsifier**: any signature pair on real secp256k1 with
`x([λ]k₂G) mod n == (ω·r₁) mod n` where `k₂` is *not* the λ-multiple of `k₁`
beyond chance; or any curve with `p ≠ n`, `ω, n` both 256-bit and the claim
holding for a non-`1/n` fraction of nonces; or a pair of honest signatures with
`r₂ ≡ ω·r₁ (mod n)` whose nonces are *not* λ-related at a rate above `1/n`.
