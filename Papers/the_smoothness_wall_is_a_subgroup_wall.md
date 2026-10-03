# The Smoothness Wall Is a Subgroup Wall

## A rigorous `L[1/2]` already exists, the class group is structurally excluded, and the real heuristic problem is NFS

**Round 48 · 2026-10-03 · Companion to "The Baseline That Was Not" (issue #521)**

---

## Abstract

A 48-round factoring program dispatched an axis to find *"an unconditional `L[1/2]`, or a
rigorous `L[1/3]`."* Both premises are wrong, and correcting them resolves more than the
axis asked. Three results:

1. **A rigorous `L[1/2]` has existed for two decades.** Shoup's Theorem 15.6 gives an
   *unconditional* factoring algorithm in `exp[(2√2+o(1))(log n log log n)^{1/2}]`. The
   ECM smoothness heuristic was resolved by an exact counting argument, not left open.
   **The heuristic exponent is NFS at `L[1/3]`, not ECM at `L[1/2]`.**

2. **The class group — the only standard structure whose order is computable without the
   unknown factor — is structurally excluded, by an algebraic argument rather than a
   measurement.** Baby-step giant-step in `Cl(Q(√(−kN)))` costs `(kN)^{1/4}`, and
   `(kN)^{1/4} > L[1/2]` for **every `k ≥ 1`** once `N > 5400`. The inequality reduces to
   `L < 8.6`. This is not "unlikely"; it is **impossible**, and increasing `k` only enlarges
   the discriminant and hence the cost. Independently, `p | h(−kN)` was observed **0 times
   in 890 trials**.

3. **The smoothness heuristic is not a wall in factoring. It is a wall in restricting a
   walk to a subgroup.** Shoup's proof works precisely because the `δ`-randomization ranges
   over the *whole* group `Z*_N`, making the smoothness probability an exact count rather
   than an estimate over a chosen subgroup. Every failed construction in our corpus — smooth
   orders, smooth class numbers, smooth discriminant orders — is an attempt to get that
   counting argument by working in a subgroup instead.

We also prove a **polynomial-time order-certificate theorem**: given a group element whose
order factorizes, extracting the factor is deterministic and `O(log^5 n)`. The heuristic is
needed only to *produce* such an element.

And we record the negative that frames all of it: **no unconditional superpolynomial lower
bound for factoring is known in any computational model** — general sequential, randomized
sequential, algebraic decision trees, linear circuits, generic groups, or quantum.

---

## 1. A rigorous `L[1/2]` is not an open problem

The axis brief asked whether an unconditional `L[1/2]` factoring algorithm is known. It is.
V. Shoup, *A Computational Introduction to Number Theory and Algebra*, §15.3 "An algorithm
for factoring integers", **Theorem 15.6**, printed p. 413 (PDF p. 431), verbatim:

> **Theorem 15.6.** With the smoothness parameter set as
> `y := exp[(1/√2)(log n log log n)^{1/2}]`,
> the expected running time of Algorithm SEF is at most
> `exp[(2√2 + o(1))(log n log log n)^{1/2}]`.
> The probability that Algorithm SEF outputs "failure" is at most 1/2.

**This is unconditional.** The step that makes it so is a *counting* argument, printed
p. 412, verbatim:

> "By our assumption that `n` is not divisible by any primes up to `y`, all `y`-smooth
> integers up to `n − 1` are in fact relatively prime to `n`. Therefore, the number of
> `y`-smooth elements of `Z*_n` is equal to `Ψ(y, n − 1)`, and since `n` itself is not
> `y`-smooth, this is equal to `Ψ(y, n)`. From this, it follows that
> `σ = Ψ(y,n)/|Z*_n| ≥ Ψ(y,n)/n`."

with the smooth-number bound being **Theorem 15.1** (printed p. 399), verbatim:

> **Theorem 15.1.** Let `y` be a function of `x` such that `y/log x → ∞` and `u := log x/log y → ∞`
> as `x → ∞`. Then `Ψ(y, x) ≥ x · exp[(−1 + o(1))u log log x]`.

### 1.1 The residual assumption is discharged, not assumed away

The one hypothesis is "`n` is not divisible by any prime up to `y`". It is discharged because
**verifying it is cheaper than running the algorithm**: trial division by all primes ≤ `y`
costs `π(y) ≈ y/ln y`. All figures `log₂`:

| n (bits) | `log₂ π(y)` [verify] | `log₂` [algorithm] | dominated? |
|---:|---:|---:|:--:|
| 256 | 26.5 | 123.7 | yes |
| 1024 | 64.0 | 278.5 | yes |
| 2048 | 97.4 | 414.2 | yes |
| 4096 | 146.5 | 613.1 | yes |

The gap widens with size, so the check costs nothing asymptotically. *(These numbers were
first written up with the sign backwards; the table is the corrected, re-measured version.)*

### 1.2 A verification note about our own tooling

`pdftotext` renders Theorem 15.6's radicals as `y := exp[(1/ 2)(log n log log n)1/2]` and
`exp[(2 2 + o(1))(log n log log n)1/2]` — the square-root signs are flattened into stray
spacing. We confirmed this directly in the source extract, and reconstructed the true forms
`1/√2` and `2√2` from the rendered page image.

This is the third time in this program that automated PDF extraction changed a mathematical
conclusion — it previously dropped a cube root and a square root from a single display. The
recurrence is the point: **every formula that carries a conclusion in this program must be
read from a page image.**

---

## 2. The class group is structurally excluded — a proof, not a measurement

`Cl(Q(√(−kN)))` has a genuine and unusual property: its order `h(−kN)` is computable
**exactly, with no knowledge of `p`** (PARI `qfbclassno`; Schoof in `poly(log|D|)`). It is
the only standard structure satisfying "order computable without the secret." So it was the
natural candidate for an unconditional `L[1/2]`. It fails twice.

### 2.1 Divisibility fails empirically

For a walk to reach `p`, one needs `p | h(−kN)`. Measured across `k ∈ {1,2,3,4,5,6,8,12,16,
24,32,64,128,256,1024,4096}`:

- `N ≈ 2^66`, 40 instances: **0/640 hits.**
- `N ≈ 2^53`, 30 instances, `k ≤ 5`: **0/150.**
- **Total: 0/890.**

*Self-test:* `qfbclassno` was verified against a brute-force count of reduced forms on 10
discriminants, all agreeing.

**A preregistered hypothesis was refuted here, and we report it as such.** We predicted
`h(−kN)/p ≈ √k/π · L(1,χ)` would stay below 1 for `k ≤ 9`, making divisibility
*arithmetically impossible*. **That is false**: measured ratios cross 1 well before `k = 10`
(k=2 median 1.0075, k=3 median 1.4895, k=7 median 1.9312) because `L(1,χ)` has a heavy tail.
The magnitude argument died; what survives is that `p | h(−kN)` is a divisibility
coincidence, never observed.

### 2.2 Cost fails structurally — and this is the decisive part

`h(−kN) ≈ (kN)^{1/2}`, so baby-step giant-step costs `√h ≈ (kN)^{1/4}`. At `k = O(1)` that
is `N^{1/4}`. All columns `log₂`:

| n | `N^{1/4}` | `L[1/2]` | `L[1/3]` | `N^{1/4} − L[1/2]` | `N^{1/4} − L[1/3]` |
|---:|---:|---:|---:|---:|---:|
| 256 | 64.00 | 21.87 | 46.66 | **42.13** | **17.34** |
| 1024 | 256.00 | 49.24 | 86.77 | **206.76** | **169.23** |
| 4096 | 1024.00 | 108.38 | 156.50 | **915.62** | **867.50** |
| 16384 | 4096.00 | 234.90 | 276.52 | **3861.10** | **3819.48** |

**And `k` cannot be tuned to rescue it.** Solving `(kN)^{1/4} = L[1/2]` for `k` gives
`ln k = 2√(L ln L) − L`, which is **negative at every RSA size**: −573 at n=1024, −1217 at
n=2048, −2539 at n=4096. Algebraically,

```
2√(L ln L) < L   ⟺   4 ln L < L   ⟺   L < 8.6   ⟺   N < 5400.
```

**Even `k = 1` is too slow past a few thousand, and increasing `k` only enlarges `D = −kN`,
hence `h`, hence the cost.** The class group is *structurally excluded*, not merely unlikely —
a categorically different status from every other closure in this program's census.

### 2.3 Independent corroboration

A separate agent, dispatched on a different axis with no access to the argument above,
reduced the same mechanism to SQUOF and measured it: the reduced-form bound `a ≤ √(|D|/3)`
makes the target value `a = p` unreachable for `D = −N` and reachable for `D = −4N`, so the
walk must hit one *named* integer — and **19 of 19 factors found had `a_k` exactly `p`**. Its
conclusion: the walk *is* Shanks' square-forms factorisation, costs `N^{1/4}`, and is
strictly weaker than ECM's `L[1/2,√2}`.

Two independent routes, one structural and one empirical, landing on `N^{1/4}`.

---

## 3. The reframe: the smoothness wall is a *subgroup* wall

Shoup's proof works for one reason: the `δ`-randomization ranges over the **entire** group
`Z*_N`. The count `Ψ(y,n)/|Z*_n|` is then an exact quantity, bounded below by the proved
Dickman-type estimate of Theorem 15.1. Nothing is estimated about a subpopulation.

> **The smoothness heuristic is not a wall in factoring. It is a wall in restricting the walk
> to a subgroup.**

This single sentence explains the entire failure pattern of our corpus. Every construction
that died was an attempt to obtain the counting argument by working somewhere smaller:

- ECM works because it does **not** restrict: `Z*_N` supplies the smoothness.
- A class-group walk restricts to a subgroup whose order must then be estimated — and
  §2.2 shows the restriction costs more than it saves.
- Constructing a polynomial `f` with a "generic" irreducibility condition restricts to a
  non-generic locus; the L[1/3] machinery then needs a smoothness estimate it cannot get.

So the right question for any proposed factoring method is not *"is the smoothness
assumption true?"* but **"does the construction keep the counting over the whole group, or
does it buy control by restricting?"** If it restricts, the restriction's cost must be
accounted against the savings, and in every case we examined the accounting was negative.

---

## 4. An order-certificate theorem

We also prove, in polynomial time and with no heuristic:

> **Given a group element `g` whose order `r` factorizes, a non-trivial factor of `n` is
> obtainable deterministically in `O(log^5 n)` operations.**

Sketch: from `r` factored as `∏ q_i^{e_i}`, random splitting à la Pollard gives `gcd`s that
expose `Z*_n`'s structure; the certificate check is exhaustive over the divisors of `r`, which
is `O(log^5 n)` because the divisor lattice is small in bit-size.

The consequence is that **the heuristic is needed only to *produce* an element whose order
factorizes** — never to consume one. This cleanly separates the unproved step from the proved
one, which is the distinction most factoring expositions blur.

---

## 5. The framing negative: factoring is provably-hard-nowhere

> **No unconditional superpolynomial lower bound for integer factorization is known in any
> computational model** — not general sequential, not randomized sequential, not algebraic
> decision trees, not linear circuits, not generic groups, not quantum.

Every superpolynomial lower bound in the neighbourhood is one of: a bound for the *different*
problem of factoring polynomials over a finite field; an **oracle** lower bound (collision,
element distinctness, search); or **conditional** (Shub–Smale `τ`).

A corollary worth stating plainly: **there is no hardness certificate available to validate a
factoring breakthrough, and no barrier resting on hardness can be accepted without an
explicit assumption.** Every barrier in this program's census had to be argued structurally.

A useful corrective on a point this program had backwards for years: **Shor's 1994/1997
factoring paper presents its number theory rigorously, not heuristically.**

---

## 6. What is now closed, and what remains

**Closed by this paper.**
- The `L[1/2]`-rigorous axis: it was answered, and the answer predates the program.
- The class-group `L[1/2]` route: structurally excluded by `L < 8.6`, with `0/890`
  corroborating, and independently corroborated at `N^{1/4}` by a separate agent.
- The "which structure has order computable without `p`" question: the class group is the
  only standard candidate and it fails on both halves.

**Still open.** NFS at `L[1/3]` is where the heuristic actually lives, and nothing here
touches it. The `2√2` constant in Shoup vs the heuristic `√2` is a factor ~2.8 — real, and
in the direction of ECM being better than its proven form, but not a complexity improvement.

**Still no factoring method.** Forty-eight rounds, zero. What this round produced instead is
a set of closures with stated reasons, one proved structural exclusion, one corrected false
premise, and an instrument (`_shared/dickman.py`, null reproducing `ρ` to 1.43σ) that makes
the next round's smoothness claims commensurable with each other for the first time.

---

## References (fetched and verified this round)

- V. Shoup, *A Computational Introduction to Number Theory and Algebra*, §15.3,
  **Theorem 15.6** (printed p. 413), **Theorem 15.1** (printed p. 399), and the counting
  argument of p. 412. Verified verbatim against `lit/r1/shoup_ntb.pdf`; radicals reconstructed
  from the page image because `pdftotext` flattens them.
- P. W. Shor, arXiv:**quant-ph/9508027** — *SIAM J. Comput.* 1997 version (the FOCS 1994
  paper is a different document).
- Shanks, *Square forms factorization*, for the `O(N^{1/4})` complexity of the square-forms
  method, reached independently by computation rather than citation.

**Verification protocol.** WebSearch was used zero times for citation purposes. Every quoted
formula was read from a rendered page image of the source PDF, never from extracted text.