# Round 55 — higher 2-adic digits are thresholds, not advantages

**2026-10-05. NO new factoring algorithm. Round 53's §5 open construction problem is
ANSWERED: `GAIN > 1` does not exist in the 2-power relation family, and the reason
is a LAW.**

Paper: **`Papers/higher_two_adic_digits_are_thresholds.md`**.
Code: `factor-scratch/r55exp/kernel/` (seeded; 3 scripts byte-identical across runs).
**No modulus of cryptographic interest was factored.** All computation `n < 2⁴⁰`.

---

## 1. VERDICT

> **Higher 2-adic digits of `lam_p` ARE read by the relation condition** — proved exactly,
> **246 360 exhaustive triples, 0 mismatches** — **but reading digit `e` pays exactly the
> `2^e`-fold root multiplicity that digit was worth, and annihilates exactly the `2^e` bases
> it discriminated. `GAIN = 1` IDENTICALLY, not on average.**

**Theorem B (threshold law):**
```
b^k is a 2^e-th power mod p   <=>   lam_p >= min(e, A) - v2(k),   A = v2(p-1)
```
Generalises round 53's law: at `e = 1`, `k` odd it reduces to `NOT(lam_p = 0)` exactly.

**Theorem C (e-neutrality):** mean root count is `2^t` if `t < a` else `2^a`, with
`t = v2(k)`, `a = min(e,A)` — **independent of `e`**. **Max abs deviation `0.0` over 72 cells.**

**⇒ The mechanism: higher digits enter ONLY as one-sided thresholds `lam_p ⩾ e`. A
THRESHOLD IS A FILTER, NEVER A CONDITIONING — and a filter cannot raise a rate.**
This is the sharpest form of round 53's §5 "kernel" requirement: **the kernel is exactly
the set of thresholds, and thresholds have no interior to exploit.**

## 2. ⚠️ A correction to my own round-53 SCRATCH note — and why no retraction is warranted

An agent reported that round 53's symmetry argument is false. **I checked before
publishing a retraction of my own work, and it does not hold up:**

- The agent quoted **`core.py` (scratch)**, which says a character of order 3 *"must be a
  PAIR of local characters, which requires naming p and q"*.
- **Round 53's PUBLISHED argument is NON-INJECTIVITY**: *"the local characters live in
  `μ₃`, and the product is not injective."* **Different claim.**

**I re-verified it by brute force.** For `n = 2479 = 37·67` (`3 | p−1`, `3 | q−1`):
```
product 0: 791 bases    product 1: 792 bases    product 2: 792 bases
PAIRS sharing a product but differing individually:  312 181
```
**The product map is many-to-one, exactly as claimed** — far more badly than the
"935 pairs over 26 moduli" figure suggested, which was a smaller sample of the same
phenomenon. **THE CLOSURE STANDS.**

**What IS true:** the scratch comment conflates symmetry with computability. Symmetry
under `p ↔ q` is automatic for EVERY character (because `μ_M` is abelian), so it excludes
nothing. **The real obstruction is computational** — can `F(n,b)` be evaluated in
`poly(log n)` without factoring `n`? — **a hardness claim this round does NOT prove.**
Jacobi satisfies it by quadratic reciprocity; higher symbols have no comparable descent.

## 3. The precise class

`GAIN = 1` holds for relation conditions governed by membership in a **subgroup of
`2`-power index**. **This is a theorem about that class, not all constructions.**
Non-monotone conditions, `Jacobi(b²−c/n)`, order-based conditions: **untouched, not refuted.**

## 4. ⚠️ Errors, prominently

1. **`min(e,A)` missing from the Theorem B predicate — 37 588 spurious mismatches.**
   I reasoned "if `e > A` then vacuously true". **False:** the image of `x ↦ x^{2^e}` has
   index `2^min(e,A)`, a **proper subgroup even when `e > A`.**
2. **"`lam_p` uniform on `{0..A}`" — predicted 0.75, measured 0.500061.** The first
   "correction" to `A/(A+1)` was **also wrong**. True law: `P(lam ⩾ t) = 2^{−t}`,
   independent of `A`.
3. **Test primes chosen without `3 | (p−1)`** — two experiments failed on inputs alone.
4. **`_is_cube`, three wrong versions, first two vacuously `True`.** v2 tested membership
   in the image set, which is **constant-true because that set IS the image.** ★ **My
   first "ground-truth" validation recomputed the cube set through the SAME broken
   expression, so it reported 0 disagreements on a function returning `True` for every
   input. A CONTROL THAT REUSES THE LOGIC UNDER TEST IS NOT A CONTROL.** An independent
   enumeration (2028 checks) caught v2 with 1352 disagreements.
5. **Denominator `n−1` where the loop skipped non-units** — `0.845` where truth is
   `1.000` (`φ(143) = 120 ≠ 142`).

## 5. Controls

Instrument validation **independent of the code under test** (12 408 checked, 0
disagreements, nonzero = 8) · closed form verified **per-cell, max dev 0.0 over 72 cells** ·
**detector proved able to fire** (root count varies in 34/72 cells, both values ⩾ 20) ·
negative control mismatches 31% on a wrong prediction · even-`k` arm agrees on all 265
rows · determinism on all scripts · factor-blindness guard retained.

## 6. NOT claimed

No arXiv identifier is cited anywhere in this work (arXiv returned empty on two query
forms; zbMATH returned 404); three Crossref references verified **bibliographically only**,
none used in any proof. **The hardness direction is not settled.**
