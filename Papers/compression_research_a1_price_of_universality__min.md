# Computational evidence — price of universality (average case)

All numbers below were produced with `Float` arithmetic inside Lean (`#eval`), before
the corresponding statements were formalised.  They are *exploration*, not proof: every
claim that survived is proved without `sorry` in `Catalog/Bridges/UniversalRedundancy*.lean`.

Script used (self-contained, `#eval` only):

```lean
def lg (x : Float) : Float := Float.log x / Float.log 2

/-- Bayes redundancy `I(w)` of a finite class given as a list of probability rows. -/
def mutualInfo (ps : List (List Float)) (w : List Float) : Float :=
  let n := (ps.head!).length
  let mix : List Float := (List.range n).map (fun j =>
    ((ps.zip w).map (fun pr => pr.2 * pr.1[j]!)).foldl (· + ·) 0)
  ((ps.zip w).map (fun pr =>
    pr.2 * ((List.range n).map (fun j => pr.1[j]! * lg (pr.1[j]! / mix[j]!))).foldl (· + ·) 0)
  ).foldl (· + ·) 0

/-- Grid search of the capacity of a two-source class. -/
def cap2 (p q : List Float) (steps : Nat) : Float :=
  ((List.range (steps+1)).map (fun k =>
    let t := k.toFloat / steps.toFloat
    mutualInfo [p, q] [t, 1 - t])).foldl max 0
```

## 1. Capacity of the shifted Bernoulli(3/4) class

| quantity | value |
|---|---|
| grid-search capacity (`cap2 [0.75,0.25] [0.25,0.75] 1000`) | `0.188722` |
| closed form `¾ log₂ 3 − 1` | `0.188722` |
| worst-case price `log₂ Cₛ = log₂ 1.5` | `0.584963` |

The grid search agrees with the closed form to all printed digits, and the average-case
price is about a third of the worst-case price.  This motivated, and then matched,
`bias34Class_capacity`, `bias34Class_worst`, `bias34Class_average_lt_worst`
(gap exactly `¼ log₂ 3 = 0.146`).

## 2. Is the uniform prior always optimal?  (No — symmetry is needed)

Asymmetric two-source class `p₁ = (0.9, 0.1)`, `p₂ = (0.2, 0.8)`:

| quantity | value |
|---|---|
| grid-search capacity (2000 steps) | `0.397754` |
| Bayes redundancy at the uniform prior | `0.397313` |

The uniform prior is *strictly* suboptimal here.  This is why the closed-form theorem
`capacity_eq_klDiv_uniformMix_of_symmetric` is stated under a transitive symmetry
hypothesis, and why the general theory needs the saddle point rather than a guess.

## 3. Additivity under products

Product of two independent copies of the shifted Bernoulli(3/4) class (4 sources on a
4-letter alphabet):

| quantity | value |
|---|---|
| grid search over product priors | `0.377444` |
| `2 × (¾ log₂ 3 − 1)` | `0.377444` |

Consistent with `capacity_tensor` (`C(S ⊗ T) = C(S) + C(T)`).

## 4. Unknown-offset class over `ℤ/5` with a skewed base law

`p₀ = (0.5, 0.2, 0.15, 0.1, 0.05)`, sources = the 5 cyclic shifts of `p₀`:

| quantity | value |
|---|---|
| `H(p₀)` | `1.923220` |
| closed form `log₂ 5 − H(p₀)` | `0.398708` |
| `I(uniform prior)` computed directly | `0.398708` |
| worst-case price `log₂(5 · max p₀)` | `1.321928` |

The two agree exactly, as predicted by `shiftClass_capacity`; the worst-case/average gap
`H(p₀) − H_∞(p₀) = 1.923 − 1.000 = 0.923` matches `shiftClass_price_gap`.

## 5. Counterexample hunt

* *"Is the uniform prior always capacity-achieving?"* — **falsified** numerically in §2;
  the formal statement therefore carries a symmetry hypothesis.
* *"Is the average price equal to the worst-case price?"* — **falsified** in §1; the strict
  inequality is now a theorem (`bias34Class_average_lt_worst`).
* *"Can merging two classes be cheaper than the more expensive one?"* — no counterexample
  found; formalised as the monotonicity half of `capacity_sigmaClass_sandwich`.
* No OEIS sequence is involved: all quantities here are transcendental logarithms rather
  than integer sequences.

## 6. Later cycles: what needed evidence and what did not

The results added in the later cycles (uniqueness of the capacity mixture, data
processing, sufficiency, the type/count reduction, the Markov rate, and the parse chain
rule) are *structural identities and inequalities* valid for every finite class, so the
useful evidence is a sanity check of the two directions rather than a numerical search.

* **Data processing must be an inequality, not an identity.**  Small hand check on the
  `bias34Class` of §1: the maximally coarse front end `f ≡ ()` collapses both sources to
  the point mass `1`, giving capacity `0` against the class capacity `¾log₂3 − 1 ≈ 0.189`.
  This is the strict case, and it is now the theorem
  `capacity_pushforward_trivial_lt` — so no coarse-graining identity can hold in general.
* **Sufficiency must be an identity.**  For a Bernoulli family on `n`-bit strings the
  likelihood depends on the string only through its number of ones, so the type map
  cannot lose anything; the formal statement is
  `capacity_iidSubClass_typeMap`/`capacity_bernoulliFamily_typeStat`.
* **Order of the rate.**  For `n = 7, 15, 63` the upper bound `log₂(n+1)` of
  `capacity_bernoulliFamily_le` reads `3, 4, 6` bits, while the lower bound
  `(1−ε)log₂(n+1) − 4` for the smoothed composition class reads (at `ε = 0.1`)
  `−1.3, −0.4, 1.4` bits: the two brackets agree in order (`log₂ n`) and the additive
  constant `4` is what separates them.  These are arithmetic evaluations of the proved
  bounds, not independent verifications.

## 7. Final cycle: the Bernoulli parameter packing (`½ log₂ n`)

The last cycle replaced the artificial constant-composition lower bound by a packing
*inside the genuine one-parameter Bernoulli family*.  At scale `k` with `k² ≤ n` (in the
final statement `k = ⌊√n⌋`), the packing uses the `m = ⌊k/4⌋` parameters `t_j = (4j+2)/k`,
whose binomial means `n t_j = (n/k)(4j+2)` are `4n/k` apart, while the Chebyshev windows
have half-width `2n/k ≥ 2√n` and (since the variance is `n t(1−t) ≤ n/4`) each carry mass
at least `1 − k²/(16n) ≥ 15/16`.  The table below reads the two bounds on the exactly
square lengths `n = k²`, where the arithmetic is cleanest.

Arithmetic evaluation of the two *proved* bounds
`A(k) = (15/16)·log₂⌊k/4⌋ − 4 ≤ C ≤ log₂(n+1)` for `k = 2^s`, `n = 2^{2s}`:

| `s` | `n = k²` | sources `m` | lower bound `A` | upper bound `log₂(n+1)` | Clarke–Barron `½log₂n` |
|-----|----------|-------------|-----------------|--------------------------|------------------------|
| 4   | `256`    | 4           | `−2.13` (vacuous) | `8`  | `4`  |
| 6   | `4096`   | 16          | `−0.25` (vacuous) | `12` | `6`  |
| 8   | `65536`  | 64          | `1.63`            | `16` | `8`  |
| 10  | `≈10⁶`   | 256         | `3.50`            | `20` | `10` |
| 20  | `≈10¹²`  | `2¹⁸`       | `12.88`           | `40` | `20` |

(The additive `−4` from the generic
`capacity_ge_of_approx_disjoint` step makes the bound vacuous below `n ≈ 2¹³`, which is
why the statement of interest is the *slope*, not the constant.)

Reading the slopes: the lower bound grows as `(15/32) log₂ n`, the upper bound as
`log₂ n`, and the conjectured exact rate as `(1/2) log₂ n`.  The packing therefore proves
that the true constant lies in `[15/32, 1]` — the Chebyshev tail costs exactly the factor
`15/16 = 1 − 1/16`, and the residual gap to `½` is the difference between a `1/16`-tail
packing and the exact Clarke–Barron integral.  A sharper tail (Chernoff instead of
Chebyshev) would push `15/16 → 1 − o(1)` but cannot go past `½ log₂ n`, which is the
information-theoretic truth.  No counterexample hunt applies here: the statement is a
sandwich of two proved inequalities.
