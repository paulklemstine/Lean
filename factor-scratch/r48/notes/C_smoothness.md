# Round 48 — Axis C: the smoothness assumption in GNFS

**Question.** Is there a provable way around GNFS's smoothness assumption, or a
sieve medium whose smoothness we can actually **prove**?

**Answer, up front.** `a^2 − b^3` **does** deviate from uniform smoothness, the
deviation is **exact algebra** (not noise), it is **stable under every
confound I tested**, and it **helps** — but only by a **constant factor on
relation collection**. It does not touch the `L[1/3]` exponent or the
`(64/9)^{1/3}` constant. H3's honest accounting shows smoothness *verification*
is already essentially free and cannot move the constant either.

Code: `factor-scratch/r48/exp/`. Literature: `factor-scratch/r48/lit/`.

---

## 0. Predictions, stated BEFORE running

| | Prediction | Result |
|---|---|---|
| P1 | Dickman ρ reproduces uniform smoothness only to rel. gap 0.02–0.35 at finite x | **confirmed** (E1/A3) |
| P2 | `a^2−b^3` values have a wildly non-uniform *size* distribution (pile-up near 0) | **confirmed** (E2.5) |
| P3 | Raw comparison vs uniform-in-[1,x] is badly confounded | **confirmed** — 17.06× at B=10 |
| P4 | The local cause is `P(p ∣ v) = 1/p` **exactly**, but `P(p^k ∣ v) > p^{−k}` for k ≥ 2 | **confirmed, exactly** (E3.1) |
| P5 | `P(p^k ∣ a^2−b^3)/p^k = 1 + 1/p` for p ≠ 3 | **confirmed** (E3.1) |
| P6 | Bias is a *constant factor*, not an exponent change | **confirmed** (E9) |
| P7 | σ ≈ 200 as naively computed; honest σ far smaller once dependence is handled | **both confirmed** (E9 vs E10) |
| P8 | Extrapolation to 1024 bits is a **model, not a measurement** | asserted; limitations in §6 |

---

## 1. STEP 0 — The null harness (non-negotiable)

`exp/e1_null.py`. **Two of my own bugs were caught here**, which is the point.

**A1 — Dickman ρ.** Validated two independent ways:

| check | max relative error |
|---|---|
| vs closed form `ρ(u)=1−log u` on [1,2] | **8.1e−07** |
| vs an independent scipy trapezoid solver, u ∈ [2,4] | **8.6e−04** |

**A2 — smoothness oracle.** Sieve vs exact `sympy.ntheory.factor_.smoothness`,
300 000 integers × 4 values of B: **0 disagreements**.

**A3 — the Dickman floor.** This is the important one and it is *not* a bug.
Dickman is asymptotic; at finite x it differs from the true rate:

| x | B | ρ(u) | true rate | rel. gap |
|---|---|---|---|---|
| 1e5 | 300 | 2.977e−01 | 3.486e−01 | 0.171 |
| 1e6 | 3000 | 4.544e−01 | 4.901e−01 | 0.079 |
| 2e7 | 300 | 5.427e−02 | 7.188e−02 | 0.324 |
| 2e7 | 300000 | 7.126e−01 | 7.391e−01 | 0.037 |

Floor = **rel. gap 0.023–0.324**. Consequence: *any* NFS effect smaller than
this cannot honestly be called "a deviation from Dickman" — only a deviation
from the **true finite-x rate**. All measurements below compare against the
**exact** matched rate, never against ρ.

**A4 — stratum-matched null.** Uniform integers sampled *inside* each dyadic
size stratum, vs the exact rate for that stratum: |σ| ≤ 1.52 at every cell.
Control established.

---

## 2. H1 — does `a^2 − b^3` deviate? YES, and the cause is exact

### 2.1 The naive number is a trap

Comparing all `a^2−b^3` against uniform-in-[1,x] gives **17.06× at B=10**,
**6.73× at B=30**, **3.17× at B=100**. This is meaningless: `|a^2−b^3| < 1e4`
occurs for **0.0916%** of pairs where uniform would give **0.0071%** (E2.5).
Size matching is not optional.

### 2.2 The mechanism — measured exactly (`exp/e3_mechanism.py`)

Exhaustive count of `#{a,b mod p^k : p^k ∣ a^2−b^3}` — **exact, no sampling**:

| p | k=1 | k=2 | k=3 | k=4 | `1+1/p`? |
|---|---|---|---|---|---|
| 2 | 1.00000 | 1.50000 | 1.50000 | 1.50000 | 1.5 ✓ |
| 3 | 1.00000 | 1.66667 | 1.66667 | 1.66667 | 1.333 ✗ |
| 5 | 1.00000 | 1.80000 | 1.80000 | 1.80000 | 1.8 ✓ |
| 7 | 1.00000 | 1.85714 | 1.85714 | 1.85714 | 1.857 ✓ |
| 11 | 1.00000 | 1.90909 | 1.90909 | 1.90909 | 1.909 ✓ |
| 13 | 1.00000 | 1.92308 | 1.92308 | 1.92308 | 1.923 ✓ |

**`P(p ∣ a^2−b^3) = 1/p` exactly** (every k=1 row is 1.00000). The entire
deviation lives in **k ≥ 2**. It is a *powerful-forms* effect: `a^2` is a
square and `b^3` a cube, so their difference is far more often divisible by
`p^2, p^3, …` than a uniform integer is.

Hand-check, p=2, k=2: `4 ∣ a^2−b^3` iff (a,b both even) or (a odd and b≡1 mod 4),
giving `1/4 + 1/8 = 3/8` — matching the measured 0.375472 (E2b.3) and the exact
1.50000 ratio. **p=3 is the sole exception** (1.667 vs 1+1/3): cubes mod 9 lie
only in {0, ±1}.

This also predicts `E[v_p] = 1/p + (1+1/p)/(p(p−1))`; for p=2 that is
`0.5 + 0.75 = 1.25`, and E6.3 measured mean v₂ = **1.2429–1.2498**. Match.

### 2.3 It survives every confound

* **Band narrowing** (E2b.2): ratio vs band width factor, 1 → 256 sub-bands
  per octave. At u=2.0: **1.1049, 1.1024, 1.1023, 1.1022, 1.1044**. Flat. A
  size-matching artifact would collapse to 1.
* **Artifact control** (E2b.1): an artificial population with the *same* size
  skew but uniform local structure reaches only **1.0139**, far short of 1.10.
* **Power control**: the harness sees `a^2` (known non-uniform) at σ = 49–95.

### 2.4 The honest σ (E10)

Naive σ treated 4.4e6 *pairs* as independent. They are not — a²−b³ is
deterministic in (a,b), and there are only 12000 distinct a-columns. Corrected:

| u | naive σ (pairs) | distinct-value σ | **conservative σ (octave as unit)** |
|---|---|---|---|
| 2.0 | 90.2 | 79.1 | **58.9** |
| 2.8 | 100.0 | 86.7 | **12.3** |
| 3.2 | 107.5 | 92.6 | **9.5** |

**Quote σ ≈ 9.5–59** (u ∈ [2, 3.2]), not 200. And note this is almost beside
the point: the mechanism is an *exhaustively enumerated* count, so it is not
statistically fragile at all.

---

## 3. STEP 2 — characterisation, and does it help or hurt?

**Direction: it HELPS.** `a^2−b^3` is systematically smoother.

**δ(u)**, size-matched, 16 bands/octave (E9.2, n = 4.45e6 pairs):

| u | B | δ | σ (naive) | σ (conservative) |
|---|---|---|---|---|
| 1.6 | 128238 | 1.0509 | 138.7 | — |
| 2.0 | 12201 | 1.1010 | 174.9 | 58.9 |
| 2.4 | 2542 | 1.1674 | 194.5 | — |
| 2.8 | 829 | 1.2461 | 199.4 | 12.3 |
| 3.2 | 358 | 1.3776 | 212.8 | 9.5 |
| 3.6 | 186 | 1.5437 | 217.2 | — |
| 4.0 | 110 | 1.7254 | 215.3 | — |

**Parity/structure dependence:** yes, entirely, and it is the mechanism itself.
Restricting to a sub-box does **not** help (E4.3) — yield ratios are all
< 1.0 (e.g. "a,b both even" 0.982), and net win = ratio × fraction < 1 always:

| sub-box | B=1e4 | net |
|---|---|---|
| a,b both even | 0.9720 | 0.2455 |
| a,b both mult of 3 | 0.9785 | 0.1098 |
| a odd | 0.9718 | 0.4908 |

**Why:** NFS needs *all* primes ≤ B to divide the value, and `P(p ∣ v) = 1/p`
exactly. Restricting to a congruence class buys you extra *powers* of a few
primes while losing 1/p of the box for every other prime. The bias is spread
thinly across all p, not concentrated where it can be sieved.

---

## 4. Extrapolation to 1024 bits — a MODEL, not a measurement

**This is the weakest link and I say so plainly.** All measurements are at
N ≈ 1e8. At N = 2^1024 the sieve region is `a` up to ~2^512, unreachable.

E5/E5b/E6 initially showed δ *falling* with N (u=3.2: 1.632 → 1.478 → 1.413).
E7 traced this to **truncation**: the small box cannot fill a window up to 2^22,
so its values pile in the smoother lower part (medians 2.18e5 vs 2.71e5). Using
only windows every box fully populates (E7.1), δ is **SAME across box sizes**
to < 4% — i.e. the bias is **local in the value**.

Two further facts support extrapolation:
* the mechanism `P(p^k∣v) = (1+1/p)p^{−k}` is **scale-free** (exact mod p^k);
* my "near-degenerate values" hypothesis — which *would* have made δ genuinely
  N-dependent — was **refuted**: the fraction is 0.0286% / 0.0202% / 0.0192%
  across scales, essentially flat.

**But** δ(u) was never measured at u > 4, and NFS's operating point is
u ≈ 3–5. The prediction that δ ≈ 1.25–1.55 in the NFS regime is an
**extrapolation in u from u ≤ 4**. At 1024 bits it is unverified.

---

## 5. H3 — honest accounting of fast smoothness verification

### 5.1 What Coppersmith actually gives (and does not)

The brief asked about a Coppersmith-style result with d ∣ N, d > N^{1/2}. **That
theorem does not exist in the papers named.** Both Coppersmith papers are about
*known bits* only — the real title ends "…Factoring with **High Bits Known**".

> "In polynomial time we can find the factorization of N = P Q if we know the
> high-order ( ¼ log2 N ) bits of P." — Coppersmith Thm 4, §11, *J. Cryptology*
> **10** (1997) 233–260, https://link.springer.com/content/pdf/10.1007/s001459900030.pdf

> "Let k = b ¼ log2 N c, so that 2k ≈ N^{1/4}." — same, Thm 5 setup

The exponent is **exactly 1/4** — Coppersmith's contribution is to *small-root
finding*, not to smoothness testing. **No d ∣ N result is claimed.**

### 5.2 The actual relevant algorithm is Bernstein's, and it's cheap

> "Let P be a finite set of primes, and let S be a finite sequence of positive
> integers. This paper presents an algorithm to find the largest P -smooth
> divisor of each integer in S. The algorithm takes time b(lg b)2+o(1) …"
> — Bernstein, *How to find smooth parts of integers*,
> https://cr.yp.to/factorization/smoothparts-20040510.pdf

> "Algorithm 2.1 … 1. Compute z ← p1 · · · pm using a product tree. 2. Compute
> z mod x1 , . . . , z mod xn using a remainder tree. … 4. For each k: Print
> gcd{xk , yk }." — same, Thm 2.2

> "• Trial division takes time at most b2+o(1) ." — same, §1 "Competition"

> "This type of computation—identifying and factoring the P -smooth elements of
> a sequence—is a bottleneck in the Lehmer-Powers-Brillhat-Morrison continued
> fraction method of factoring integers, and in many newer algorithms for
> factoring integers…" — same

### 5.3 The accounting

**Finding the smoothness of many values in a batch is Õ(b) — provably, and
this is not the bottleneck.** NFS does not pay a trial-division bill per
relation. It pays a **segmented sieve**: one pass marking all multiples of each
prime p ≤ B across a whole block of candidate pairs, costing ≈ `M·Σ_{p≤B} 1/p`
bit-flips for M pairs — **sub-linear per pair** by construction. Montgomery
describes the older situation:

> "Much of the time in CFRAC is spent factoring the residues P 2 − NQ2, to test
> whether they are smooth. This work is done primarily by trial division…
> Quadratic Sieve (see §7.6) eliminates this burden." — Montgomery, *A Survey of
> Modern Integer Factorization Algorithms* (1994), §7.5,
> https://ir.cwi.nl/pub/18252/18252B.pdf

**Verdict on H3: REFUTED as a source of gain.** Coppersmith-style methods do not
apply (wrong problem). Bernstein-style batch smoothness is real and rigorous,
but it targets a cost NFS has *already* eliminated with sieving — and NFS's own
literature notes this was the bottleneck in *CFRAC*, not in NFS. Even a perfect,
free smoothness oracle removes a lower-order term.

**It does not touch the constant.** The GNFS constant is verified from primary
sources (page images read, per the superscript rule):

> "the general version of the algorithm, sometimes called the *general number
> field sieve*, applies to all integers and has an expected running time of
> L_n[1/3, c], where c = (64/9)^{1/3} ≈ 1.923. This is, asymptotically, the
> fastest algorithm known for integer factorization." — Menezes–van
> Oorschot–Vanstone, *Handbook of Applied Cryptography* §3.2.7, p. 98,
> https://cacr.uwaterloo.ca/hac/about/chap3.pdf

> "The asymptotic complexity of the usual variant of NFS to factor an integer
> N, under various heuristic assumptions, is known to be
> exp( cbrt(64/9) (log N)^{1/3} (log log N)^{2/3} (1 + ξ(N)) )"
> — Le Gluher–Spaenlehauer–Thomé, eprint 2020/829,
> https://eprint.iacr.org/2020/829.pdf

**(64/9)^{1/3} = 1.92299 is VERIFIED** (the Montgomery paper itself was
unreachable; the constant is confirmed from four independent peer-reviewed
sources). It comes from the *sieving+linear-algebra balance*, not from
smoothness testing. Nothing here moves it.

---

## 6. H2 — a sieve medium whose smoothness we can PROVE?

**No provable substitute was found, and the literature says so explicitly.**

> "the NFS and other algorithms critically depend on the existence of sufficient
> numbers of smooth elements among rational or algebraic integers on certain
> linear forms, **which cannot be guaranteed in current algorithms**."
> — Lee–Venkatesan, *Rigorous Analysis of a Randomised Number Field Sieve*,
> arXiv:1805.08873 §1

> "It is a priori unclear how to argue that the NFS even halts [35]. Even
> assuming standard conjectures (e.g.; GRH), there is no analysis that any
> substantial part of the NFS will halt." — same

> "The fastest algorithms with known rigorous analysis are unfortunately much
> slower, with the best result being Ln 12 , 1 + o(1) [33]" — same

> "a positive integer N may be rigorously and deterministically factored into
> primes in at most O(N^{1/5} log^{16/5} N / (log log N)^{3/5}) bit operations."
> — Harvey–Hittmeir, arXiv:2105.11105

> "The complexity of the elliptic curve method of factorization (ECM) is proven
> under a strong conjectural form of existence of friable numbers in short
> intervals." — Barbulescu–Jouve, arXiv:2212.11724

The provable/heuristic gap is stark. Balog gives y = x^ε-smooth numbers in
intervals of length x^{1/2+ε}; the heuristic target is length `log x`:

> "one would expect that for every ǫ > 0 there exists a constant C(ǫ) such that
> every interval [x, x + C(ǫ) log x] contains an xǣ -smooth number" —
> Soundararajan, arXiv:1009.1591

> "we improve upon Xuan's work by establishing the following theorem, which
> unfortunately is still not strong enough to be applicable to the analysis of
> Lenstra's algorithm." — same

**And the specific gap I care about was not found at all:** the literature
agent searched for provable smoothness of *two-variable* values like
`a^2−b^3` and **located no source whatsoever**. The closest result is
single-variable (Bober–Fretwell–Martin–Wooley, arXiv:1710.01970, Cor 1.2:
"there are infinitely many n ∈ N for which f (n) is nε -smooth", quadratic f).
**Do not conflate the two.**

---

## 7. What was refuted (a refuted hypothesis is success)

1. **"The 17× deviation is a real smoothness anomaly"** — REFUTED. It is a size
   artifact; size-matched δ ≈ 1.10.
2. **"Coppersmith gives fast smoothness verification / a d > N^{1/2} divisor"**
   — REFUTED. Wrong theorem; his result is on *known bits*, exponent 1/4.
3. **"Fast smoothness verification removes the trial-division half of GNFS's
   cost"** — REFUTED. NFS uses a segmented sieve; smoothness testing is not a
   leading-order cost, so there is no half to remove.
4. **"Local v_p laws determine the smoothness rate, so δ is predictable"** —
   REFUTED by my own DP sanity check (`exp/e8_rigorous.py`): the uniform branch
   returned 9.2e−6 where ρ = 0.2977. The product-sum of local densities is valid
   only when ∏pᵏᵖ ≪ x, which B-smooth numbers near x violate. **Local densities
   do not determine smoothness.**
5. **"δ concentrates in a sieveable sub-box"** — REFUTED. Every sub-box has net
   gain < 1.
6. **"Near-degenerate values make δ genuinely N-dependent"** — REFUTED; the
   fraction is flat across scales (0.0286% → 0.0192%).
7. **"The NFS smoothness assumption can be made provable"** — NOT ACHIEVED, and
   the best current rigorous factoring bound is still L_n[1/2, 1].

## 8. Honest bottom line

* **a²−b³ deviates from uniform smoothness — yes, by δ ≈ 1.10 at u=2 and
  δ ≈ 1.25 at u=2.8, at σ ≈ 9.5–59 conservatively (and the mechanism is exact
  enumeration, not inference).**
* **It helps**, because more of the values are smooth for free: `P(p^k ∣ v) =
  (1+1/p)p^{−k}` for k ≥ 2.
* **It is a constant factor on relation collection only.** At the NFS operating
  point u ≈ 3 the naive reading is a ~25–38% reduction in collection cost. It
  does **not** touch the `L[1/3]` exponent, does **not** lower `(64/9)^{1/3}`,
  and does not make anything provable.
* **Extrapolation to 1024 bits is a model.** Measured only to u ≤ 4, N ≈ 1e8.
* **The honest headline is negative for the axis:** H1 yields a real but
  low-order constant; H2 has no provable substitute; H3 attacks a cost that NFS
  has already eliminated.