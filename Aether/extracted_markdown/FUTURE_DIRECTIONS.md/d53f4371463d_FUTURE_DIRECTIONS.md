# Future Directions: Perturbation-Stable Generalization Bounds

The file `Catalog/MachineLearning/PerturbedGeneralization.lean` now contains a
fully proved isometry / Lipschitz-transfer theory for the Occam / MDL bound

```
occamBound R C n δ = R + sqrt ((C + log (1/δ)) / (2 n)).
```

The single structural fact `occamBound_sub_eq` — the bound is an exact
translation in its empirical-risk coordinate — is promoted to a genuine Mathlib
`Isometry` (`occamBound_isometry`), then leveraged into a verbatim Lipschitz
transfer (`lipschitz_bound_transfer`), a single-edit perturbation bound
(`arch_perturbed_bound`), a two-edit triangle lift (`occamBound_chain_bound`), a
telescoped path envelope along an entire architecture-search trajectory
(`occamBound_path_bound`), an exact no-Jensen-gap ensemble identity
(`occamBound_ensemble_avg`), a separable data + robustness sample-complexity
budget (`occamPenalty_le_of_sample`, `perturbed_sample_complexity`), and a
tightness witness (`perturbed_bound_tight`). The directions below push the bridge
further.

## 1. The isometry is a surjective metric isomorphism with a global inverse

**Conjecture.** The map `Φ R = occamBound R C n δ` is not merely an `Isometry`
but a surjective isometric equivalence `ℝ ≃ᵢ ℝ`, with explicit inverse
`Φ⁻¹ y = y − occamPenalty C n δ`; consequently the pushforward of any
architecture pseudometric `(A, d)` along `emp` then `Φ` reproduces the uniformity
of `d` rescaled by the Lipschitz constant `L`, and every completion / Lipschitz
extension theorem applies to certified guarantees unchanged.

The key insight is that `occamBound_translate` already exhibits the two-sided
inverse as subtraction of the constant penalty, so `occamBound_isometry` upgrades
to an `IsometryEquiv` by supplying `Φ⁻¹` and the round-trip identities; the
pushforward statement then follows because isometric equivalences preserve
uniform structure on the nose.

**Why now?** The forward isometry and the translation inverse are both formal
theorems in the file; assembling them into Mathlib's `IsometryEquiv` is a packaging
step that immediately exports the full metric-completion API to the space of
guarantees.

## 2. Strictly convex capacity measures incur a quantitative Bregman/Jensen gap

**Conjecture.** Replace the constant penalty by a strictly convex capacity
`cap : ℝ → ℝ` and set `bound' R = R + cap R`. For an ensemble with at least two
distinct empirical risks, `bound' (avg R) < avg (bound' ∘ R)`, and the deficit
equals the ensemble average of the Bregman divergence of `cap` from the mean.

The key insight is that `occamBound_ensemble_avg` is precisely the zero-curvature
boundary case (the penalty is constant, hence affine in `R`); injecting any
positive curvature converts the proved equality into a strict Jensen inequality,
so the size of the violation is a falsifiable, quantitative measure of how far a
capacity functional is from being a pure compression / MDL penalty.

**Why now?** The equality case is proved, isolating exactly the affine slot where
curvature would enter; the contrast theorem needs only Mathlib's
`StrictConvexOn` / `inner_le_sum`-style Jensen lemmas and would give the first
formal statement that *only* MDL-type penalties admit exact ensemble identities.

## 3. The path envelope is the tightest path-monotone certificate

**Conjecture.** The telescoped envelope `occamBound_path_bound` is saturated:
for the monotone empirical risk `emp x = L · (x − a₀)` used in
`perturbed_bound_tight`, every edge of the path attains equality
simultaneously, so the inequality becomes an identity
`occamBound (emp (a k)) = occamBound (emp (a 0)) + L · ∑ d(aᵢ, aᵢ₊₁)` whenever the
path is monotone in the architecture coordinate.

The key insight is that `perturbed_bound_tight` already saturates a single edge;
because the saturating `emp` is globally affine, the per-edge equalities chain
through the same induction that proves `occamBound_path_bound`, with no slack
accumulating at any node.

**Why now?** Both the path envelope and the single-edge tightness witness are
formalized; the only remaining work is to run the equality version of the
induction, yielding the first end-to-end *exact* certified-stability identity for
a whole search trajectory rather than a one-sided bound.

## 4. The data–robustness budget region is a downward-closed Cartesian product

**Conjecture.** Fix a certified target `emp a + τ`. The admissible-budget set
`{(δ, ε, η, n) : ε + η ≤ τ ∧ (C + log(1/δ))/(2 ε²) ≤ n}` is downward-closed in
`(η, n)` and upward-closed in `(ε, 1/δ)`, and its Pareto frontier factorizes as
the product of a pure data constraint `n = (C + log(1/δ))/(2 ε²)` and a pure
robustness constraint `ε + η = τ`, with no cross term.

The key insight is that in `perturbed_sample_complexity` the data budget enters
only through `ε` (via `occamPenalty_le_of_sample`) while the perturbation budget
enters only through `η` (via the additive `occamBound_translate` slot); the two
channels never multiply, so the region is a genuine Cartesian product and its
frontier is a graph rather than a curved trade-off.

**Why now?** Every bounding inequality is already a theorem; separability is a
monotonicity argument in each coordinate, delivering the first formal
data-vs-robustness exchange theorem with an explicit, differentiable frontier
suitable for automatic budget allocation.

## 5. PAC-Bayes lift: the isometry survives passage to posteriors

**Conjecture.** Replace the point hypothesis by a posterior `Q`, the empirical
risk `R` by the expectation `𝔼_{h∼Q}[R(h)]`, and the complexity `C` by the
KL divergence `KL(Q ‖ P)`. The resulting PAC-Bayes Occam bound is *still* a
translation in the expected-risk coordinate, so `lipschitz_bound_transfer` and
`perturbed_sample_complexity` lift verbatim, with `archDistReal` replaced by a
total-variation / Wasserstein distance between posteriors.

The key insight is that expectation is linear, so `𝔼_Q[R]` occupies exactly the
affine-translation slot that powers `occamBound_translate`, while the KL term
plays the role of the constant penalty and never touches the risk coordinate —
the isometry argument therefore transfers unchanged.

**Why now?** The catalog already contains PAC-Bayes scaffolding (the
`MachineLearning/PACBayes` directory and Catoni / McAllester bounds); composing
those with the isometry lemmas in this file would unify compression, perturbation
robustness, and PAC-Bayes generalization under a single Lipschitz-transfer
principle.
