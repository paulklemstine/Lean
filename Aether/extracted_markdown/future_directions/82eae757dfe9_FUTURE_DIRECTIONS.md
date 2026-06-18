# Future Directions — Expected Rademacher Complexity over the Boolean Hypercube

## Synthesis

This cycle introduced a **measure-theory-free** theory of the *expected* empirical
Rademacher complexity of a finite hypothesis class, realised as an honest arithmetic
mean over the Boolean hypercube `Fin n → Bool` (cardinality `2 ^ n`). No probability
measure, σ-algebra, or integral is invoked: the expectation is `Finset.sum … / 2 ^ n`.

The conceptual spine is a **duality**: a Rademacher sign vector is a character of
`(ℤ/2)ⁿ`, and averaging over signs is a pairing against the uniform measure on the
dual group. The decisive structural fact is the **sign-flip involution** `b ↦ ¬b`,
formalised as the `Equiv` `flipEquiv`, which negates every correlation and therefore
forces the *raw* correlation to average to exactly zero
(`sum_rademacherCorrelation_eq_zero`). Every downstream estimate — the singleton
collapse, nonnegativity, monotonicity, the Massart-type upper bound, and the new
positive-homogeneity law — is an elementary consequence of either this involution or
the pointwise `|·| ≤ B` bound transported through `Finset.sup'`.

The local-to-global reading is direct: a *local* per-coordinate symmetry (the bit-flip
on a single factor of the product `(ℤ/2)ⁿ`) glues, via `Equiv.piCongrRight`, into a
*global* symmetry of the entire hypercube whose only cohomological shadow is the
vanishing of the mean correlation. The supremum operator `Finset.sup'` is the
gluing functor that lifts coordinatewise scalar facts to class-level inequalities.

## Results Summary — `Catalog/MachineLearning/RademacherExpectation.lean`

- `rademacher_correlation_bounded` — `|corr σ h| ≤ B` whenever each `|hᵢ| ≤ B`.
- `sum_rademacherCorrelation_eq_zero` — **the duality identity**: the correlation of
  any fixed hypothesis, summed over all `2 ^ n` sign patterns, is exactly `0`.
- `expectedRademacher_singleton_eq_zero` — a singleton class has exactly zero expected
  complexity; it cannot fit random sign labels.
- `expectedRademacher_nonneg` — a class containing `0` has nonnegative complexity.
- `expectedRademacher_mono` — complexity is monotone in the hypothesis class.
- `expectedRademacher_le_bound` — the basic upper bound `Rₙ(H) ≤ B`.
- `expectedRademacher_smul_nonneg` — **positive homogeneity** `Rₙ(c • H) = c · Rₙ(H)`
  for `c ≥ 0`, the `L = 1` base case of the multi-layer spectral programme below.

All proofs are complete (`sorry = 0`) and depend only on the standard axioms
`propext`, `Classical.choice`, `Quot.sound`.

---

## Direction 1 — Massart's logarithmic refinement of the upper bound

The bound `expectedRademacher_le_bound : Rₙ(H) ≤ B` is tight only in the single-hypothesis
worst case; for a finite class of cardinality `m` the truth is dramatically smaller,
`Rₙ(H) ≤ B · √(2 ln m) / √n`. Conjecture: replacing the crude `Finset.sup'_le ≤ B`
step with an exponential-moment (Hoeffding) argument yields exactly this `√(ln m)`
dependence, and the bound is asymptotically tight on the class of all `±B` label
vectors. **The key insight is** that the supremum over a finite class, after passing
through `exp(λ·)`, turns into a *sum* over the class, so the union bound becomes
`Finset.sum_le_card_nsmul` and the only analytic input is the sub-Gaussian MGF of a
single `±1`-weighted coordinate. **Why now?** `rademacher_correlation_bounded` already
supplies the coordinatewise `B`-bound that Hoeffding's lemma consumes, and
`sum_rademacherCorrelation_eq_zero` shows the mean is zero — the centring hypothesis
Hoeffding requires.

## Direction 2 — Lipschitz contraction (Talagrand) on the hypercube

For a `1`-Lipschitz map `φ : ℝ → ℝ` with `φ 0 = 0`, the expected complexity of `φ ∘ H`
should not exceed that of `H`: `Rₙ(φ ∘ H) ≤ Rₙ(H)`. Conjecture: a fully finite,
hypercube-indexed contraction principle holds, with ReLU (`x ↦ max x 0`) the canonical
constant-`1` instance. **The key insight is** that the contraction can be proved one
coordinate at a time using the *same* `flipEquiv` involution already formalised: pairing
`σ` with the bit-flip of a single coordinate reduces the Lipschitz inequality to the
scalar fact `|φ a − φ a'| ≤ |a − a'|`. **Why now?** The involution machinery powering
`sum_rademacherCorrelation_eq_zero` is exactly the per-coordinate symmetry the contraction
proof needs, and `expectedRademacher_mono` already shows the `sup'`-based quantity behaves
monotonically under the class operations involved.

## Direction 3 — Inductive multi-layer (spectral) composition bound

For an `L`-layer linear network with per-layer operator-norm bounds `C₁,…,C_L` and
`1`-Lipschitz activations between layers, conjecture that the sum of squared output
correlations is bounded by `(∏ₗ Cₗ²)` times the sum of squared input correlations.
**The key insight is** that this is a clean induction on `L` mapping onto `Nat.rec`:
each step composes a single spectral bound (the homogeneity law
`expectedRademacher_smul_nonneg`, which already gives the `L = 1` base case) with the
Direction-2 contraction, so the product `∏ Cₗ²` accumulates multiplicatively with no
cross terms. **Why now?** Direction 2 supplies the activation step and
`expectedRademacher_smul_nonneg` supplies the per-layer scaling; the only missing piece
is a Cauchy–Schwarz packaging of correlations into an `ℓ²` quantity, which is purely
`inner_mul_le_norm_mul_norm`.

## Direction 4 — Generalization gap via symmetrization

Define empirical and ghost-sample risks over a finite data distribution and conjecture
the symmetrization inequality `E[sup_{h∈H} |R h − R̂ h|] ≤ 2 · Rₙ(H)`. **The key insight
is** that, for a *finitely supported* data law, swapping a real sample point with its
independent ghost copy is literally the action of one coordinate of the `flipEquiv`
involution already formalised — so the classical measure-theoretic symmetrization
collapses to a re-indexing of a finite sum. **Why now?** The duality identity
`sum_rademacherCorrelation_eq_zero` is precisely the `H = {h}` shadow of the
symmetrization bound (cf. `expectedRademacher_singleton_eq_zero`), and the pointwise
bound `rademacher_correlation_bounded` gives the two-sided control needed to pass from a
`sup` of a difference to `2 · Rₙ(H)`.

## Direction 5 — PAC-Bayes bridge through KL divergence on the hypercube

Bridge this Rademacher framework to the catalog's `PACBayes` results
(`Catalog/MachineLearning/PACBayes/Bounds.lean`) by defining the KL divergence of two
distributions over a finite hypothesis set via `Finset.sum` and `Real.log`, and
conjecture `E_Q[R h] ≤ E_Q[R̂ h] + √((KL(Q‖P) + ln(n/δ)) / (2(n−1)))`. **The key insight
is** that the `ln m` term of Massart's lemma (Direction 1) is the special case
`KL(uniform‖uniform) = ln m`, so the finite-class bound and the PAC-Bayes bound are two
evaluations of one divergence functional. **Why now?** The catalog already contains the
McAllester/Catoni variational inequalities (`pac_bayes_mcallester_bound`,
`pac_bayes_catoni_bound`), and the expected-complexity scaffolding here provides the
empirical-risk side those bounds quantify over a *finite* hypothesis set, making the two
formalizations directly composable.
