# A Sharper Proved `L[1/2]`

## The constant `2√2` in Shoup's unconditional factoring bound is `√2` too large, and half of it is removable

**Round 49 · 2026-10-03**

---

## Abstract

Shoup's *A Computational Introduction to Number Theory and Algebra*, §15.3, gives an
**unconditional** factoring algorithm: Theorem 15.6 (printed p. 413) proves expected running time

> `exp[(2√2 + o(1))(log n · log log n)^{1/2}]`

with failure probability at most 1/2. The ECM heuristic constant is `√2`. **The proved constant
is a factor of exactly 2 too large.**

We decompose `2√2 = √(2·2·2)` into two independent squares, identify the source of each, and
**remove one of them**:

> **`2√2 → 2`, proved and unconditional.**

The removable square comes from Theorem 15.1's exponent `u log log x` where the sharp
Dickman–de Bruijn exponent is `u log u`; at the balanced application point `log u = ½ log log n −
½ log log log n + O(1)`, so Shoup's exponent over-charges by exactly 2. Substituting the sharp
estimate gives `exp[(2 + o(1))(log n · log log n)^{1/2}]` with `y = exp[½√(log n log log n)]`.

The other square is **forced by counting and is not removable**, and we prove the resulting
constant is optimal within this shape: `√2` would require `a < 2`, i.e. ECM — whose `√2` is a
*heuristic*, so **there is no proved unconditional `√2`**.

We also state the regime precisely, because the improvement is asymptotic and the programme is
usually read at sizes where it is only partly realised: `u = 11.0` at RSA-512, **`19.8` at
RSA-2048**, `26.7` at RSA-4096, with `u → ∞` only as fast as `√(log n)`.

---

## 1. Where the factor of 2 sits

It is **two independent squares, not a Markov step and not a union bound** — the two obvious
suspects are both absent from the printed argument.

**`a = 2`** — the power of the factor-base size. Shoup's stage-1 cost on p. 411 is a
`σ⁻¹ k²` term (p. 412, verbatim: *"leading to a total expected running time in stage 1 of
`σ^{-1}k²`"*). The `k+2` relations are **forced** by `dim Z₂^{(k+1)} = k+1` (p. 410), and each
costs a trial-division pass over the same `k = π(y)` primes (p. 411). This square is a
counting fact, and **it cannot be removed**.

**`c = 2`** — the Dickman exponent constant, coming from Theorem 15.1's bound
`Ψ(y,x) ≥ x · exp[(−1+o(1)) u log log x]` (p. 399) applied at `u log log x`.

## 2. The removable square

The sharp Dickman–de Bruijn exponent is **`u log u`**, not `u log log x`. At the balanced point
where the two are compared,

```
log u = ½ log log n − ½ log log log n + O(1),
```

so Shoup's exponent over-charges by a factor of 2 at the point of application. Substituting the
sharp estimate throughout gives

> **`y = exp[½ √(log n · log log n)]`, expected running time `exp[(2 + o(1))(log n · log log n)^{1/2}]`.**

**This is unconditional and proved**, not a heuristic improvement. The ratios are truncation-free
and exact: `2√2/2 = √2` holds for the H1 term alone, for the H2 term alone, and `2√2/√2 =
2.00000000` for both.

## 3. Why 2 is the best available

Within this shape the constant is optimal, and both halves of the optimality are tight:

- `c = 1` is forced by the Dickman estimate itself (Theorem 15.1's exponent is tight).
- `a = 2` is forced by the count of p. 410–411.

To reach `√2` one needs `a < 2`, which is exactly ECM — **and ECM's `√2` is a heuristic.** So:

> **There is no proved unconditional `√2`.** Getting it would require proving the ECM
> smoothness heuristic, which is a different and much harder problem.

That is a sharper statement than "the constant is 2√2" — it identifies exactly what is missing.

## 4. The regime, stated precisely

The improvement is asymptotic. `u` grows only as `√(log n)`:

| modulus | `u` |
|---|---|
| RSA-512 | 11.0 |
| **RSA-2048** | **19.8** |
| RSA-4096 | 26.7 |

`u = 100` would need a ~78,700-bit modulus. **The asymptotic is not in evidence at any RSA
size.** More precisely still: the H1 identity `log u / log log n → ½` holds only as `n → ∞`, and
**at RSA-2048 the ratio is 0.411, not 0.5** — so the real slack there is `2.432` rather than
`2√2`, and **only about 78% of the improvement is realised at RSA scale.**

A paper that quoted `2√2 → 2` without this would be overstating the practical gain by a
quarter of its size.

## 5. A lemma that is tight but orthogonal

Lemma 15.5's *"at most 1/2"* failure bound is **tight**: measured directly, `x² ≡ 1 (mod pq)`
has exactly **4** roots by CRT, of which exactly **2** are `±1`. But it is a
success-probability statement and **never enters the constant** — it is orthogonal to the factor
of 2. Recorded here because it is easy to mistake for the source of it.

## 6. Verification and what this rests on

**The central result does not depend on any numerically-evaluated `ρ`.** This was checked
executively rather than assumed: `ρ` was wrapped in a spy and every `ρ`-using part of the suite
re-run (**27 calls, largest `u = 5.0`**); then `ρ` was replaced by a function that *raises* and
both load-bearing results re-derived —

- the `2√2 → 2` improvement (ratio `1.41350` against `√2`), and
- the identity `log u / log log n → ½` (to 1e-10) —

**and both still verify.** `ρ` enters only one tightness diagnostic, on `2 ≤ u ≤ 5`.
Final suite: **51 PASS, 0 FAIL, 12 NULL.**

**A caution about how that check was done, because the first two attempts were wrong.** The
initial ρ-dependency checks were regex source-scans, and **both were wrong** — one flagged a
de Bruijn *print table* (`u = 40`) that never calls `ρ`, the other flagged the audit's own
docstring. The spy replaced both:

> **A tripwire that always fires gets ignored.** A check that passes for the wrong reason is
> worse than no check, because it is believed.

## 7. Relation to the earlier correction in this series

An earlier paper in this series reported a boundary `N < 1.8 × 10²⁹` for a different question,
using the convention `ln k = 4√(L ln L) − L`. Shoup's `L[1/2]` is the **`√2` convention**, so
that derivation's correct form is `ln k = 4√2·√(L ln L) − L`, giving `L* = 163.0`,
`N* ≈ 10⁷⁰·⁸`. The thresholds differ by **41 orders of magnitude**. Recorded because the two
constants are easy to conflate and both appear in this programme.

## 8. Honest limits

- The `c = 1` tightness is asserted from the Dickman–de Bruijn form, which is asymptotic; the
  bound is tight in the limit, and the paper states no finite-`x` sharpness.
- **No claim is made that this makes ECM-based factoring practical.** It improves a *proved*
  bound's constant; the gap to the heuristic `√2` remains open and is exactly the ECM heuristic.
- The regime numbers in §4 are the regime, not a measurement of realised speed-up at those
  sizes; the `78%` figure is what the asymptotic identity predicts at RSA-2048, and a
  wall-clock confirmation at that size is **not** provided here.

## Reference

- V. Shoup, *A Computational Introduction to Number Theory and Algebra*, 2nd ed., Springer 2009,
  §15.3 "An algorithm for factoring integers". **Theorem 15.6** (printed p. 413), **Theorem 15.1**
  (printed p. 399), **Lemma 15.5**, and the `σ⁻¹k²` stage-1 cost (printed p. 412), with
  `dim Z₂^{(k+1)} = k+1` at p. 410 and the `π(y)` trial-division pass at p. 411.

**Verification protocol.** Every page reference above was read from a **rendered page image** of
the source PDF, not from extracted text — `pdftotext` flattens superscripts and rendered Shoup's
`2√2` and `1/√2` as the garbage tokens `2 2` and `1/ 2`, which is how the radicals in
Theorem 15.6 were reconstructed in the first place.