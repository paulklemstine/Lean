# Round 48 — D: partial-information factoring below the ½-of-the-bits-of-p barrier

**2026-10-03. The axis is closed with a MEASURED threshold, not a quoted one.
Nothing came in strictly below ½ of the bits of `p`. The break is exactly at
Coppersmith's `X = N^{1/4}`, located at the bit, and it is a wall — not a
lattice-size limit.**

---

## 0. What was and was not re-litigated

Settled before this round, and **not** re-run here:

- Coppersmith needs ~**½ of the BITS of `p`**. The record's "¼" was a fraction
  of `log N` — i.e. of the *interval size*, which is half the bits of `p`.
  That correction is settled.
- Herrmann–May, ASIACRYPT 2008, p. 3: the generic bound is `ln 2 ≈ 70%` of
  `p`, and it holds *"no matter how the size of the unknowns are distributed
  among the `Xᵢ`"* — **positions are irrelevant, only the count**. That was
  already verified, and it is why "structured leakage helps" fails. This round
  does not re-run that as a headline; it builds on it.

**New work arXiv:2606.24717 (Urroz), supplied by an arXiv scout** — see §6.
It is a `d`-leak result and does **not** cross the `p`-leak wall.

---

## 1. THE MANDATORY CONTROL — **PASS**

Without this, nothing below is reportable. 128-bit `N`, `p` of 64 bits,
`N^{1/4} = 2^32`. Coppersmith's "½ of the bits of `p`" is exactly 32 unknown
bits, i.e. **exactly the boundary**, so the control tests 31 / 32 / 48.

| case | X | expected | result (seeds 1,2,3) |
|---|---|---|---|
| KNOWN-GOOD, 31 unknown bits | `2^31 < N^{1/4}` | succeed | **3/3 recovered `p`** (dim 52, 40, 40) |
| BOUNDARY, 32 unknown bits | `2^32 = N^{1/4}` | boundary | **3/3 no vanishing vector** (33.8 s, 30.4 s, 35.1 s) — see §2 |
| KNOWN-BAD, 48 unknown bits | `2^48 > N^{1/4}` | fail | **3/3 no vanishing vector** (113.6 s, 93.6 s, 159.6 s) |

**`CONTROL: PASS` — the harness can resolve a threshold.**

(Process note: this run's final summary line first raised `KeyError` on a
label-spacing mismatch *after* all nine measurements were recorded; the fix is
in `control_final.py` and the corrected logic was replayed against the recorded
results to confirm the verdict above. A crash in the reporting code is not a
crash in the measurement — but it is exactly why the verdict is recomputed
from the logged values rather than asserted.)

The harness therefore separates a known-good case from a known-bad case on
the *same* instances, so it can resolve a threshold. (`control_final.py`)

Before the control could pass, it **failed twice for real reasons**, both
caught by the control rather than by inspection:

1. **Misaligned leak.** `a = p >> unk` (without re-aligning) leaves
   `x0 = p − a` the *full width* of `p`, silently inflating `X` by 64 bits.
   The known-good case then "failed" for a reason that had nothing to do with
   mathematics. Fixed by `(p >> unk) << unk`, with `0 <= p - a < 2^unk` asserted.
2. **Howgrave-Graham threshold off by a factor of `dim`.** Using `b^m/√dim`
   for the *2-norm* instead of `b^m/dim` rejects perfectly good vectors. The
   `√dim` belongs to the 1-norm. With the wrong constant the attack failed at
   every size, and I initially mis-read that as a lattice-size limit.

A separate self-test (`selftest.py`, 6 sections: exact determinant vs
permutation expansion on 200 random matrices; det-preservation + Lovász on 20
random lattices; polynomial algebra; exact integer roots on 7 polynomials;
every basis row verified to vanish mod `p^m` at the true root; end-to-end
recovery at a known-good point) **passes in full**.

---

## 2. THE MEASURED BREAK — at the bit, and it is a wall

For a known-high-bits leak, `p = a + x0`, `0 <= x0 < X`, `f(x) = a + x`, and
`x0` is a root of `f` at the unknown prime `p | N`. I build the standard
Coppersmith lattice (`exp_boundary.py`), LLL-reduce it with **fpylll**, and
test **exactly** whether the reduced vector *vanishes* at the true `x0` — not
whether some bound is satisfied. The lattice is dimension `δm + t`.

`N = 2^128`, `p` 64 bits, `N^{1/4} = 2^32`:

| unknown bits | fraction of `p` leaked | smallest vanishing lattice | verdict |
|---|---|---|---|
| 28 | 56.2 % | `m=t=20`, dim 40, 1.4 s | ATTACK WORKS |
| 29 | 54.7 % | `m=t=20`, dim 40, 0.9 s | ATTACK WORKS |
| **30** | **53.1 %** | `m=t=20`, dim 40, 0.3 s | ATTACK WORKS |
| **31** | **51.6 %** | `m=t=26`, dim 52, 0.7 s | **ATTACK WORKS** |
| **32 = threshold** | **50.0 %** | **none up to dim 104** | **ATTACK FAILS** |
| 33+ | < 50 % | none | ATTACK FAILS |

**The empirical break is bracketed to the bit: works at 31 unknown, fails at
32.** 32 unknown bits is `X = 2^32 = N^{1/4}` exactly.

**Threshold±1 bit, measured:**
- **threshold − 1** (31 unknown, 51.6 % leaked) → **WORKS**, but only at
  dim 52; every smaller lattice from dim 12 to dim 48 *fails to produce a
  vanishing vector* even though the Howgrave-Graham norm test nominally
  passes from dim 24 up. The margin is genuinely thin.
- **threshold** (32 unknown, exactly 50 % leaked) → **FAILS on 3/3 seeds at
  every lattice size tried, dim 40 through dim 104.** This is a **wall, not a
  resource limit**: enlarging the lattice by 2.6× does not move it, and
  neither does changing seed.
- **threshold + 1** (33 unknown) → fails, as expected.

So Coppersmith's `X < N^{1/4}` is **strict**, and the wall is at exactly the
recorded ½ of the bits of `p`.

---

## 3. T1 — structured leakage: nothing below ½

Every model tested reduces to the same univariate small-root problem, so the
threshold is governed by the same determinant:

- **MSB (top bits)** — measured: works to 51.6 % leaked, fails at 50.0 %.
- **LSB (low bits)** — same polynomial form, `f(x) = a + 2^t x`; same
  threshold. *(The full LSB sweep was cut for time; it is mechanically
  identical to the MSB case, which is measured.)*
- **`p` mod a small prime `ℓ`** — worth `ℓ−1` bits of `p`, but the unknown is
  `(p − (p mod ℓ))/ℓ`, i.e. a same-width unknown. **No gain.**
- **`p − q` known** — **not a lattice attack at all.** Fermat recovers `p`
  outright from `p−q`; my implementation is validated by a positive control
  (primes within `2^20` → recovers `p`: **True**) and **fails on every
  well-generated 128-bit key** (|p−q| ~ 2^57–2^61). This is the *opposite* of a
  sub-½ threshold: it needs **zero** bits of `p` leaked, but only holds when
  the primes are close, which is precisely what RSA keygen forbids.

**T1 verdict: no structured leakage comes in below ½ of the bits of `p`.**

---

## 4. T2 — algebraic relation between `p` and `q`: no gain

A relation `q = A·p + B (mod N)` with small `A, B` and `p = a + x` gives

> `A(a+x)² + B(a+x) − N ≡ 0 (mod N)`

— a **degree-2** univariate small-root problem, whose threshold is `N^{1/2}`,
far *above* the degree-1 `N^{1/4}`. **The relation makes the threshold worse,
not better**: it converts a linear problem into a quadratic one, and it fixes
`q` as soon as `p` is fixed, so it adds no unknowns — only worse conditioning.

Measured: for a random 128-bit key, `|q − p| mod N` is 128 bits. **A small
algebraic relation does not exist for a well-generated key**; it is a
statement about *key weakness*, not about *leaked bits*. So this model is not
a leakage model at all.

---

## 5. T3 — known bits of `d`: no, and `d` is the *wrong* channel

Implemented Wiener's continued-fraction attack exactly, with a **positive
control**: on a small-`k` key (`k = (ed−1)/φ = 2^26 < N^{1/4}/3 = 2^30.4`) it
**recovers `p` — True**. (The control caught a real bug: I first scanned
convergent *denominators*; the correct list is convergent **numerators**,
since `k/(ed−1) = 1/φ` is a convergent of `e/N`.)

Threshold: the CF method computes `t = round(N·k/e)` and `φ = (e·t−1)/k`.
**It never searches over `d`.** So its threshold is **100 % of `d`'s bits** —
revealing any high bits of `d` and leaving a window `2^(bits(d)−L)` does not
help; the mechanism needs the window to be `2^0`.

For an ordinary key, `p` is 64 bits and **`d` is 127 bits** — `d` is the
*longer* secret. 100 % of `d`'s bits ≈ **1.98× the entire bit-length of `p`**,
i.e. ≈ **1.98 of `p`'s bits**.

**T3 verdict: no threshold below ½ of `p`'s bits. Expressed against `p`, the
`d`-channel is strictly ABOVE ½, never below.**

---

## 6. Urroz arXiv:2606.24717 — and why it does not close this

Supplied by an arXiv scout; recorded here as given, **not independently
re-fetched**, and **not** used as ground truth for any claim above.

- p. 1: *"allows us to factor n whenever `1/δ d < n^{1/2 + δ/2}` if we know a
  δ-fraction of the most significant bits of n. The algorithm is
  unconditional, which is not the case in previous improvements that use
  Coppersmith method."*
- p. 4: *"We will only use continued fractions and hence all of the results are
  unconditional."*

**This is a `d`-leak + `p+q` MSB result, not a crossing of Coppersmith's
`p`-leak wall.** Two reasons it cannot be read as "below ½ of the bits of `p`":

1. **It is about `d`, not `p`.** The quantity bounded is `1/δ · d`. §5 measured
   the `d`-channel: the threshold is 100 % of `d`'s bits for the CF mechanism,
   and `d` is ~2× the length of `p`, so this cannot be a *p*-threshold below
   ½.
2. **The author's own caveat (p. 8, Remark 3.2) makes the leak conditional:**
   with no side information the enumeration is `O(√(n^{1/2}/l) · log(en))`, so
   the leak only pays once `l` is already large. That is a *cost* statement
   about when enumeration is worthwhile, not a *threshold* statement about
   bits of `p`.

The scout's second finding is the more important one for this axis:
`all:"partial key exposure"` returns **exactly ONE arXiv hit in the entire
database**, and it is unrelated. So **the `p`-leak axis has essentially no
arXiv literature**, and "no crossing in 30 years" now rests on a **coverage**
argument — the result is not absent because it was missed in citation-chasing,
but because almost nothing is published there.

---

## 7. WHAT REMAINS UNMEASURED — honest list

1. **Sample size.** The threshold is established on `N = 2^128`, 3 seeds, one
   lattice shape. The *bit* where the wall sits is a theorem-level fact
   (Coppersmith), and the measurement confirms it lands there; but this is
   **not** a multi-parameter or large-N study. For a claim of the form "no
   family beats ½", what is needed is a sweep over lattice shapes (δ, `m`, `t`)
   and over structured leakage patterns at 512–1024-bit `N`.
2. **The LSB model was not swept to the bit.** It is mechanically the same
   polynomial form as MSB and shares its threshold by the same determinant,
   but I did not measure its break independently.
3. **No multivariate / Herrmann–May construction was built.** R47 closed that
   axis analytically. I did not re-derive or extend it, so I cannot say
   anything new about whether a *different monomial set* changes the wall —
   R47 argues it cannot, and I neither confirmed nor refuted that.
4. **The multiplier-`u` case (classic partial key exposure) was not
   implemented.** `u = d mod (p−1)` with `p` partly known is the Ernst-style
   construction; it is bivariate and needs its own lattice. Not done here.
5. **Boneh–Durfee–Frankel / Coron–Maynard incremental lattices were not
   implemented.** §4 argues analytically that a substituted relation makes
   things *worse*, but that is an argument, not a measurement.

**On PARI/ellcard** (the round-48 composite-modulus trap): I used **no PARI
ground truth**. Instance generation is `sympy.nextprime` on random odd seeds;
reduction is **fpylll**; and every recovered value is confirmed by exact
integer Horner plus `N % p == 0`. The one external-library claim I depend on
is `Poly.factor_list` over `GF(c)` for finite-field root extraction, and that
is exercised by 7 unit tests in `selftest.py` (§1) including polynomials with
repeated roots and with no roots.

---

## 8. VERDICT

> **Nothing came in strictly below ½ of the bits of `p`.**
>
> The **measured** break for known-bit leakage of `p` is at **31 unknown bits
> working / 32 unknown bits failing**, i.e. **51.6 % → 50.0 % leaked**, at
> `N = 2^128`. That is `X = N^{1/4}` to the bit, and the failure at the
> boundary is a **wall** (dim 40 → 104 changes nothing).
>
> - **T1** (structured leakage): best = **51.6 % of `p`'s bits leaked**. Below ½: **NO**.
> - **T2** (algebraic relation): makes it **worse** (degree-2). Below ½: **NO**.
> - **T3** (known `d` bits): **100 % of `d`'s bits** ≈ 1.98× `p`'s length. Below ½: **NO**.
> - The Urroz arXiv:2606.24717 result is a `d`-leak and does not cross this wall.
>
> **The ½-of-the-bits-of-`p` barrier survives.** There is no security
> regression here. Combined with the scout's coverage finding (one unrelated
> arXiv hit for "partial key exposure" in the entire database), the barrier
> looks *under-attacked* rather than under-broken.

---

### Files

| file | role |
|---|---|
| `exp/lll.py` | hand-rolled exact LLL (float GS w/ rescaling), Bareiss determinant, Lovász verifier |
| `exp/reduce.py` | fpylll primary backend, hand-rolled LLL as independent cross-check |
| `exp/coppersmith.py` | lattice construction, exact GF root-finding, univariate attack driver |
| `exp/control.py` | the mandatory control (original form) |
| `exp/control_final.py` | **the mandatory control, final bounded form** |
| `exp/selftest.py` | 6-section self-test of every instrument |
| `exp/exp_boundary.py` | **the core threshold measurement** |
| `exp/exp_t1.py` | T1 structured-leakage sweep |
| `exp/exp_t2.py` | T2 algebraic relation (+ Fermat positive control) |
| `exp/exp_t3.py` | T3 known-`d`-bits (+ Wiener positive control) |
| `exp/rsa_instances.py` | leakage models |