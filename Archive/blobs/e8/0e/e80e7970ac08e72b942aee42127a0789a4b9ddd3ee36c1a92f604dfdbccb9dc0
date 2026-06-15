# Future Directions — Complexity Phase Structure of Additive Cellular Automata

## Synthesis of this cycle

We set out to *adversarially* test the cryptographic conjecture that a minimal,
explicitly Lean-definable one-dimensional cellular automaton exhibits a **sharp,
monotone randomness phase transition** in the prefix-complexity density of its
space-time diagrams: compressible below `t ≈ c₁·log n`, uniformly incompressible
above `t ≈ c₂·log n`.

Working over the additive (`Rule 90`) automaton — the `𝔽₂` automaton whose
single-seed row at time `t` is row `t` of Pascal's triangle mod `2` — and taking
the **number of live cells** (positions with an odd binomial coefficient) as a
computable, rigorous compression proxy, we proved in
`Catalog/Cryptography/AdditiveCAComplexityThreshold.lean` an *exact* closed form:

> `complexity t = 2 ^ (popcount t)`  (`complexity_eq_two_pow_digitsum`),

where `popcount t = (Nat.digits 2 t).sum` is the Hamming weight of `t`. From this
single law everything else follows and the conjecture's clean monotone threshold
is **refuted for the linear rule**:

* At Mersenne times `t = 2^k − 1` the row is *completely full*: density `= 1`
  (`complexity_mersenne`, `density_mersenne`, `density_full_infinitely_often`).
* At power-of-two times `t = 2^k` the row collapses to *two* cells: density
  `= 2/(2^k+1) → 0` (`complexity_pow_two`, `density_pow_two`,
  `density_not_bounded_below`).

Hence the complexity density oscillates between `1` and `0` infinitely often: it
is controlled by the **binary digit structure of the time index**, not by `t`
versus `log n`. This is the algebraic rigidity of a *linear* law made quantitative
— it bridges the catalog's algebraic CA renormalization
(`Catalog/Novelty/AdditiveCAPadicRenorm.lean`, `AdditiveCA.caOp_renorm`,
`caOp_binomial`) with the combinatorics of Lucas/Kummer and the cryptographic
incompressibility theme.

## Results summary

| Theorem | Statement |
|---|---|
| `mersenne_row_odd` | every `C(2^a−1, j)` is odd (Lucas) |
| `pow_two_row_even` | every interior `C(2^k, j)` is even (Kummer) |
| `complexity_eq_two_pow_digitsum` | `complexity t = 2^(popcount t)` |
| `complexity_mersenne` / `complexity_pow_two` | `2^k` (full) / `2` (sparse) |
| `density_full_infinitely_often` / `density_not_bounded_below` | the oscillation / no density floor |

All results are `sorry`-free and depend only on `propext`, `Classical.choice`,
`Quot.sound`.

---

## Direction 1 — Nonlinearity is necessary for a monotone threshold

**Conjecture.** No *additive/linear* one-dimensional CA over a finite field admits
a monotone complexity-density threshold; but a *nonlinear* elementary rule
(e.g. Wolfram's Rule 30 or Rule 45) does: the complexity density of its
single-seed space-time column is sublinear for `t < c·log n` and bounded away
from `0` for `t > C·log n`.

**Test.** Formalize Rule 30's `step : (ℤ → Bool) → (ℤ → Bool)` and the live-cell
count of its central column; prove (or refute) a positive lower density floor for
large `t`. Refuted if a power-of-two-like collapse recurs.

**The key insight is** that our `2^(popcount t)` law is forced *entirely* by the
multiplicativity in Lucas' theorem, which is itself a shadow of `(a+b)^p = a^p+b^p`
in characteristic `p`; destroying linearity destroys the digit-factorization and
therefore the oscillation, leaving room for a genuine monotone transition.

**Why now?** We have an exact, machine-checked baseline for the linear case, so any
deviation in the nonlinear case is now a *provable separation* rather than a
heuristic observation.

---

## Direction 2 — A true threshold on the torus `ℤ/nℤ` via multiplicative order

**Conjecture.** For the additive CA on the cyclic lattice `ℤ/nℤ` (n odd), the
complexity proxy of the space-time block of height `t` saturates exactly at
`t = ord_n(2)` (the multiplicative order of `2` mod `n`), giving a sharp threshold
at `t ≈ log₂ n` with a density floor determined by `n`.

**Test.** Encode configurations in `(ZMod 2)[X]/(X^n − 1)` (a finite-ring twin of
`AdditiveCA.caOp`) and relate the rank/period of the orbit to `ord_n(2)`; prove a
two-sided density bound straddling `ord_n(2)`.

**The key insight is** that on a torus the renormalization rays
`T^(2^k) + T^(−2^k)` *wrap around* and re-interfere, so the recurrence time is the
multiplicative order of `2` — converting the binary-digit oscillation of the
infinite line into a clean number-theoretic threshold.

**Why now?** The infinite-line oscillation is fully characterized; the finite
quotient is the natural next object and connects directly to the catalog's
`p`-adic / order-of-`2` number-theory strand.

---

## Direction 3 — The base-`p` generalization: a product-of-digits law

**Conjecture.** For the additive CA over `𝔽_p`, the number of *nonzero* cells in
row `t` equals `∏ᵢ (dᵢ + 1)` over the base-`p` digits `dᵢ` of `t`. For `p = 2`
this is exactly `2^(popcount t)`.

**Test.** Prove `((Finset.range (t+1)).filter (fun k => ¬ p ∣ t.choose k)).card =
(Nat.digits p t).map (· + 1) |>.prod` by the same Lucas one-digit-peel induction,
generalizing `complexity_two_mul`/`complexity_two_mul_succ` to a `p`-fold split.

**The key insight is** that Lucas' theorem makes "nonzero mod `p`" a *digit-local*
predicate — `C(t,k) ≢ 0` iff each digit `kᵢ ≤ dᵢ` — so the count factorizes over
digits into independent choices `0..dᵢ`, i.e. `∏(dᵢ+1)`.

**Why now?** The `p = 2` proof already routes through the exact Mathlib lemma
(`Choose.choose_modEq_choose_mod_mul_choose_div_nat`) that works for every prime;
the generalization is a direct, high-value reuse of the machinery just built.

---

## Direction 4 — Matching upper bound: automaticity caps Kolmogorov complexity

**Conjecture.** Because the Pascal-mod-2 sequence is `2`-automatic, the *full*
`T × (2T+1)` space-time diagram has prefix Kolmogorov complexity `K = O(log T)`
(it is generated by a fixed finite automaton plus the integer `T`), giving a
rigorous *upper* bound that meets our popcount *lower* bounds only at Mersenne
times.

**Test.** Exhibit an explicit finite-state transducer producing row `t` and bound
its description length, formalizing a `K(diagram t) ≤ c·log t + c'` statement
against the `liveCells`-based incompressibility witnesses.

**The key insight is** that our live-cell counts are a *lower* bound on
description length, while `2`-automaticity supplies the matching *upper* bound;
together they pin the diagram's true complexity and show that "full rows" are full
only in the live-cell metric, not in the Kolmogorov metric — a precise statement
of *apparent* vs *algorithmic* randomness.

**Why now?** Establishing both bounds turns the qualitative "linear CA are not
truly random" slogan into a quantitative, machine-checked sandwich theorem.

---

## Direction 5 — Typical-case vanishing vs worst-case fullness

**Conjecture.** Averaged over `t ∈ [0, 2^m)`, the mean complexity density is
`(3/4)^m → 0`, even though full-density rows recur forever. Formally
`(∑_{t<2^m} complexity t) = 3^m` and the average density `→ 0`.

**Test.** Prove `∑_{t < 2^m} 2^(popcount t) = 3^m` (a one-line binomial identity
`∑ 2^(popcount) = (1+2)^m`) and divide by the `2^m` rows of length `≈ 2^m`.

**The key insight is** that `2^(popcount t)` summed over an `m`-bit window is
`(1+2)^m = 3^m` by independence of bits, so the *typical* row is exponentially
sparse while the *worst-case* row is full — the "phase transition" is really a
gap between average and extremal behaviour, not a time threshold.

**Why now?** `complexity_eq_two_pow_digitsum` reduces this to a clean finite sum
the prover can close immediately, delivering the sharpest possible reformulation
of the original conjecture's failure.
