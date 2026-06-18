# Future Directions: The Zaslavsky Region Function

## Synthesis

This cycle replaced the lone catalog inequality `Z(m,n) ≤ (m+1)^n` with a small but
*complete* combinatorial theory of the Zaslavsky region function

> `Z(m, n) = ∑_{k=0}^{n} C(m, k)`,

the maximal number of chambers cut from `n`-dimensional space by `m` hyperplanes in
general position. The unifying object is the **deletion–restriction recurrence**

> `Z(m+1, n+1) = Z(m, n+1) + Z(m, n)`  (`zaslavsky_recurrence`),

a Pascal-type identity that is the combinatorial shadow of the geometric operation
"add one hyperplane". Every other result is downstream of it.

## Results Summary (`Catalog/MachineLearning/ZaslavskyRegions.lean`, sorry = 0)

1. `zaslavsky_recurrence` — `Z(m+1,n+1) = Z(m,n+1) + Z(m,n)`. The engine of the theory.
2. `zaslavsky_upper_bound` — `Z(m,n) ≤ (m+1)^n`. The catalog bound, now derived *from*
   the recurrence by induction on `m` (rather than asserted).
3. `zaslavsky_dim_one` — `Z(m,1) = m + 1`. Exact value; shows the upper bound is tight
   at `n = 1`, since `(m+1)^1 = m+1`.
4. `zaslavsky_saturation` — `Z(m,n) = 2^m` whenever `m ≤ n`. The region count freezes
   once the ambient dimension reaches the number of hyperplanes.

Together these pin `Z` between two regimes: a "low-dimension / many-planes" regime where
`Z` is genuinely polynomial in `m` of degree `n`, and a "high-dimension" regime where it
saturates at the constant (in `n`) value `2^m`.

## Bold, Falsifiable Directions

### 1. The bound `(m+1)^n` is asymptotically loose by a factorial — prove the sharp leading term.
**Conjecture.** For fixed `n`, `Z(m,n) = m^n/n! + O(m^{n-1})`; equivalently
`n! · Z(m,n) ≤ (m+1)^n` is *false* but `Z(m,n) ≤ C(m,n) + C(m,n-1) + … ` collapses to a
single dominant binomial, giving `lim_{m→∞} Z(m,n) · n! / m^n = 1`.
**The key insight is** that `(m+1)^n` over-counts by treating coordinates as independent,
whereas `Z` is an *anti-chain* sum of binomials whose top term `C(m,n) ~ m^n/n!` already
dominates — the bound and the truth differ by exactly the factorial `n!`.
**Why now?** We already have `zaslavsky_upper_bound` and the recurrence in Lean; the sharp
asymptotic only needs a matching *lower* bound `Z(m,n) ≥ C(m,n)`, a one-line consequence of
`Finset.single_le_sum`, making the full asymptotic immediately formalizable.

### 2. Saturation has a sharp threshold and a derivative test.
**Conjecture.** `Z(m, n) = Z(m, n+1)` if and only if `n ≥ m`; and the "first difference"
`Z(m,n+1) - Z(m,n) = C(m, n+1)` exactly.
**The key insight is** that the recurrence rewrites as `Z(m,n+1) - Z(m,n+1-1) = C(m,n+1)`,
so the region function is the discrete integral of a single binomial column — saturation is
just that column hitting zero at `n = m`.
**Why now?** `zaslavsky_saturation` proves the `n ≥ m` half non-constructively via
`sum_subset`; promoting it to the exact difference `C(m,n+1)` turns a one-sided fact into an
iff with a clean witness, and `Finset.sum_range_succ` already isolates that term.

### 3. A two-variable generating-function / log-concavity bridge.
**Conjecture.** For fixed `n`, the sequence `m ↦ Z(m,n)` is log-concave, and the bivariate
generating function `∑_{m,n} Z(m,n) x^m y^n` is rational with denominator `(1-x)(1-x-xy)`.
**The key insight is** that the deletion–restriction recurrence `Z(m+1,n+1) = Z(m,n+1) +
Z(m,n)` is *exactly* the transfer matrix of that rational kernel, so log-concavity should
descend from the well-known log-concavity of binomial rows via the Pascal recurrence.
**Why now?** Mathlib has growing support for log-concave sequences and `PowerSeries`; with the
recurrence already formalized, this is the natural cross-domain bridge from combinatorics to
formal power series.

### 4. From arrangements to ReLU networks: counting linear regions.
**Conjecture.** A single-hidden-layer ReLU network with `m` neurons over `n` inputs realizes
at most `Z(m,n)` distinct linear regions, with equality for generic weights; hence the
catalog's neural-region bound is *exactly* the Zaslavsky number, not merely `(m+1)^n`.
**The key insight is** that each ReLU neuron is one hyperplane and the activation pattern of a
point is its sign vector, so the count of linear regions is literally the count of chambers
`Z(m,n)` — the machine-learning capacity question *is* the hyperplane-arrangement question.
**Why now?** This places the file in its intended `MachineLearning` home: with `Z` and its
sharp bounds in hand, the only missing step is a genericity lemma identifying activation
patterns with chambers, connecting this cycle directly to expressivity theory.

### 5. Higher Whitney/Möbius invariants beyond the top region count.
**Conjecture.** The alternating analogue `χ(m,n) = ∑_{k=0}^{n} (-1)^k C(m,k) = (-1)^n C(m-1,n)`
computes the (signed) Euler characteristic of the bounded complement, and satisfies the *same*
deletion–restriction recurrence with a sign.
**The key insight is** that regions (`Z`) and bounded regions (`χ`) are the two specializations
`t = 1` and `t = -1` of one characteristic polynomial `∑ C(m,k) t^k`, unifying both counts as
evaluations of a single Whitney-rank generating polynomial.
**Why now?** The identity `∑_{k≤n}(-1)^k C(m,k) = (-1)^n C(m-1,n)` is a standard partial-sum
telescoping already near-automatic for `induction` + the recurrence we proved, giving a second
theorem essentially for free and revealing `Z` as one face of a richer invariant.
