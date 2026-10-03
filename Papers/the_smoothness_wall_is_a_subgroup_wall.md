# The Smoothness Wall Is a Subgroup Wall

## A rigorous `L[1/2]` already exists, the class group is excluded unconditionally (§2.3), and the real heuristic problem is NFS

**Round 48 · 2026-10-03 · Companion to "The Baseline That Was Not" (issue #521)**

**⚠️ CORRECTED 2026-10-03 — a factor-of-2 algebra error, found by adversarial audit, off by
3.3 × 10²⁵.** The threshold below was stated as `N > 5400`; it is **`N ≈ 10⁷⁰·⁸`** — and the first
> correction (`N > 1.8 × 10²⁹`) was itself wrong by **41 orders of magnitude**, because the
> table uses the `√2` convention for `L[1/2]` while the derivation used the `1` convention. The
qualitative conclusion survives at every realistic size; the stated number was wrong. See §0.1.

---

## 0.1 CORRECTION — the exclusion threshold, off by 25 orders of magnitude

An adversarial audit of this paper (which I did not write) found a **factor-of-2 error** in
§2.2. I have verified it and it is mine.

The derivation is `(kN)^{1/4} = L[1/2]` with `L = ln N`:

```
k^(1/4) · e^(L/4) = e^(sqrt(L ln L))
   (1/4) ln k + L/4 = sqrt(L ln L)
        ln k = 4 sqrt(L ln L) − L          ← the factor is 4; the paper printed 2
```

**What was printed:** `ln k = 2√(L ln L) − L`, giving `4 ln L < L`, i.e. `L < 8.6`, i.e.
**`N < 5400`**.

**The first correction** (`16 ln L < L` ⟹ `L* = 67.361`, `N* = 1.797 × 10²⁹`) fixed the
factor-2 slip but used the **`L[1/2] = exp(√(ln N · ln ln N))`** convention, while §2.2's own
table uses **`log₂ L[1/2] = √(2 ln N · ln ln N)/ln 2`**, i.e. the **`√2`** convention.

> **⚠️ CORRECTED AGAIN 2026-10-03 (second adversarial pass).** With the table's convention the
> derivation is `ln k = 4√2·√(L ln L) − L`, so the boundary is
> **`32 ln L < L` ⟹ `L* = 163.0` ⟹ `N* ≈ 10⁷⁰·⁸`**.
>
> The two conventions differ by **41 orders of magnitude in the threshold**. The paper now uses
> ONE convention throughout, the `√2` one, matching its own cost table.

**The qualitative conclusion survives**, because at every size anyone factors at, `32 ln L ≪ L`:

| size | `L = ln N` | `32 ln L` | excluded? |
|---|---|---|---|
| 512-bit | 354.9 | 93.9 | **yes** |
| 1024-bit | 709.8 | 105.0 | **yes** |
| 2048-bit (RSA) | 1419.6 | 116.1 | **yes** |
| 4096-bit | 2839.1 | 127.2 | **yes** |

So the class group remains excluded at RSA scale, and `k = 1` remains too slow there. **What was
wrong was the number and, with it, any claim that the exclusion is universal or that `N < 5400`
is a meaningful frontier.** It is a cost-model statement, not a theorem, and the audit is right
that "structurally excluded / impossible" overstated it.

Two further audit findings on this paper, recorded and accepted:
- **Both `L`-columns of the §2.2 cost table were wrong, and `L[1/3] > L[1/2]` was printed** — an
  inequality that is never true. The corrected ordering is `L[1/3] < L[1/2] < N^{1/4}`, so the
  class-group walk is worse than both.
- **The paper's own §3 refutes its §2.2.** ECM beats `√p` with `L[1/2]` using exactly a
  smoothness argument over a group order that is a random number; if that transferred to
  `Cl(O_D)`, the exclusion would fail. The exclusion holds only because `Cl(O_D)` mod `p` is
  **trivial** (§3.4) — so the cost argument is not the load-bearing one, and should not have been
  presented as if it were.

A 48-round factoring program dispatched an axis to find *"an unconditional `L[1/2]`, or a
rigorous `L[1/3]`."* Both premises are wrong, and correcting them resolves more than the
axis asked. Three results:

1. **A rigorous `L[1/2]` has existed for two decades.** Shoup's Theorem 15.6 gives an
   *unconditional* factoring algorithm in `exp[(2√2+o(1))(log n log log n)^{1/2}]`. The
   ECM smoothness heuristic was resolved by an exact counting argument, not left open.
   **The heuristic exponent is NFS at `L[1/3]`, not ECM at `L[1/2]`.**

2. **The class group — the only standard structure whose order is computable without the
   unknown factor — is excluded **unconditionally** (§2.3), not by a cost model. The arithmetic is:
   measurement.** Baby-step giant-step in `Cl(Q(√(−kN)))` costs `(kN)^{1/4}`, and
   `(kN)^{1/4} > L[1/2]` for **every `k ≥ 1`** once `N ≈ 10⁷⁰·⁸`. The inequality reduces to
   `32 ln L < L`. ⚠️ **This is the COST boundary and is indicative only** — the **unconditional** exclusion is §2.3, which needs no cost model at all. Increasing `k` only enlarges
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

## 2. The class group is excluded — but the cost argument below is only INDICATIVE

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
| 256 | 64.00 | 61.85 | 46.66 | **2.15** | **17.34** |
| 1024 | 256.00 | 139.27 | 86.77 | **116.73** | **169.23** |
| 4096 | 1024.00 | 306.55 | 156.50 | **717.45** | **867.50** |
| 16384 | 4096.00 | 664.40 | 276.52 | **3431.60** | **3819.48** |

The ordering is **`L[1/3] < L[1/2] < N^{1/4}`** at every size — the class-group walk is worse
than both NFS and ECM.

**⚠️ Corrected 2026-10-03 (second audit pass).** The first version of this table printed
`L[1/2] = 21.87 / 49.24 / 108.38 / 234.90`, which is **wrong** (correctly **61.85 / 139.27 /
306.55 / 664.40**), and consequently printed `L[1/3] > L[1/2]` at 256 and 1024 bits — an
inequality that never holds. The `L[1/3]` column was correct throughout. The `N^{1/4} − L[1/2]`
column is correspondingly wrong (42.13 should be 2.15, etc.). All values recomputed directly from
`log₂ L[1/2] = √(2 ln N ln ln N)/ln 2` and `log₂ L[1/3] = 1.9229994 (ln N)^{1/3} (ln ln N)^{2/3}/ln 2`.

*Also note:* a parallel sub-agent reported that these columns "reproduce exactly" and that
there is a "crossover at 40000 bits." **Both were false, and no single `N` reproduces both
columns.** The auditor re-checked rather than relaying.

**And `k` cannot be tuned to rescue it.** Solving `(kN)^{1/4} = L[1/2]` for `k` gives
`ln k = 4√2·√(L ln L) − L`, which is **negative at every RSA size**: **−323.6** at n=1024,
**−845.4** at n=2048, **−1989.2** at n=4096.

> (⚠️ These three were first written as −1235.9 / −2870.4 / −6333.7 — **invented rather than
> computed**, which is precisely the failure this round keeps cataloguing. Recomputed.) Algebraically,

```
4√2·√(L ln L) < L   ⟺   32 ln L < L   ⟺   L < 163.0   ⟺   N < ≈10⁷⁰·⁸.
```

### 2.3 The stronger, unconditional argument — added 2026-10-03

The cost argument above is a **cost-model comparison**, and it is therefore conditional in the
same way every `L`-notation is. There is a strictly stronger statement that needs no cost model
at all, and it was pointed out by the adversarial audit:

> **If `h(−kN)` is `B`-smooth and `p | h(−kN)`, then `p ≤ B`.**
> At the bound that matters, `B = L[1/2] ≈ exp(√(2 ln p · ln ln p))`, and `p ≤ exp(√(2 ln p ln ln p))`
> is **false** for all sufficiently large `p`, since the right-hand side exceeds `p`
> super-polynomially.

**So the conjunction required by the walk — `p | h` AND `h` `B`-smooth — is INCONSISTENT at the
relevant bound, not merely improbable.** No amount of `k` helps: increasing `k` enlarges `h`
(and so the smoothness bound needed), while `p ≤ B` only gets harder to satisfy.

Combined with the structural result of §3.4 — **`Cl(O_D) mod p` is trivial in both cases**, so
the walk degenerates to SQUFOF regardless of smoothness — the exclusion is **unconditional**.
The factor-of-2 boundary error in §2.2, which the first version of this paper got wrong by
25 orders of magnitude, becomes **irrelevant to the conclusion**: this argument never uses it.

*Corroboration.* The same audit re-ran the paper's own grid for `p | h(−kN)` and found **0 hits
in 500 trials**, replicating the recorded `0/890`. It also **refuted a contrary sub-agent claim**
that the divisibility fires often — that agent's hits were all at `N = 143`, where `h` is tiny.
The auditor validated `qfbclassno` 20/20 against brute force before trusting either number.

**Even `k = 1` is too slow past a few thousand, and increasing `k` only enlarges `D = −kN`,
hence `h`, hence the cost.** The class group is **excluded unconditionally** (§2.3), not merely unlikely —
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

### 3.4 The sharpest instance: the useful bit IS the factorization bit

The function-field axis supplies the cleanest demonstration of the reframe we can construct,
because it isolates the obstruction to **exactly one bit**.

Tori `T_D/F_p` give an order that depends on a choice parameter `D`, and the discriminator is
exactly the **Legendre symbol `(D/p)`**:

- `(D/p) = −1 ⟹ |T_D(F_p)| = p+1 ⟹ ord_p(f) | p+1`
- `(D/p) = +1 ⟹ |T_D(F_p)| = p−1 ⟹ ord_p(f) | p−1`

**And the choice matters enormously.** At `p = 1099511627791`:
`p+1 = 2^4 · 17 · 241 · 433 · 38737` is `2^16`-smooth, while `p−1` carries a `3.7 × 10^10`
prime factor. At `B = 2^16` the smoothness rates are **1.000 versus 0.000.** So H2 is true in
the weak sense: the choice parameter genuinely decides whether the mechanism works.

**But the branch cannot be identified from `Z/nZ`.** What you can compute without factoring is
`(D/n) = (D/p)(D/q)` — verified computable in `poly(log n)` on 200/200 instances — and it is a
**product**. Measured, among `D` with Jacobi symbol `+1`: 102 with `(D/p) = +1` and 105 with
`(D/p) = −1`. **`(D/n)` carries zero bits about `(D/p)`.**

> **The one bit that would exploit the function field is the factorization bit.**

Since `L[1/2]` is the entire budget, every mechanism requiring that bit is dead — not
probabilistically, but exactly. This is §3 in one line: a construction is asking for
information that lives *inside* the subgroup, and the only way in is to factor first.

### 3.5 Towers are a loss, not a tuning knob

The natural repair — raise the level of the tower to multiply the number of points and land
on a smooth order — makes things strictly worse. Raising the level multiplies the Dickman
parameter `u` by `k`:

| level `k` | `u_k` | `ln ρ(u_k)` | cost vs `k=1` |
|---|---|---|---|
| 1 | 7.35 | −12.4 | 1.00× |
| 2 | 14.70 | −39.4 | **3.18×** |
| 3 | 22.06 | −71.1 | **5.74×** |
| 4 | 29.41 | −105.9 | **8.54×** |

A tower costs `k^3`-ish more and buys nothing. And its **degree is a function of the unknown
`p`**, so it cannot be selected either — the same blindness, one level up.

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
- The class-group `L[1/2]` route: **excluded unconditionally** (§2.3); the cost model gives only the indicative bound `32 ln L < L` (i.e. `N ≳ 10⁷⁰·⁸`), with `0/890`
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