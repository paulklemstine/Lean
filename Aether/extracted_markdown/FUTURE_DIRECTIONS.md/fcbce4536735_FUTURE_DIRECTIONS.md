# Future Directions — Functorial Tropical Quotient Pseudometrics for Neural Observation Systems

## Synthesis

This cycle built an explicit, previously-missing bridge between two catalog islands:
the coalgebraic neural Myhill–Nerode theory (`Bridges/CoalgebraicNeuralMyhillNerode.lean`,
with `NeuralObservationSystem`, `neural_behavior`, `neural_derivative`, `neural_equiv`,
`neural_setoid`) and the categorical tropical/ultrametric theory
(`Bridges/CategoricalTropicalUltrametric.lean`, with `TropicalValuationObject`).

The new file `Bridges/NeuralTropicalQuotientMetric.lean` introduces a *depth-truncated
tropical discrepancy* `discrep N ω n : σ → σ → R`, defined by a max-plus recurrence over
one-step neural derivatives, valued in an abstract idempotent ordered codomain
`[SemilatticeSup R] [OrderBot R]`. We proved, with `sorry = 0` and only standard axioms:

- **Ultra-pseudometric at every finite depth**: `discrep_self`, `discrep_symm`,
  `discrep_triangle` (the strong/tropical triangle inequality).
- **Compatibility / monotonicity in depth**: `discrep_mono`, `discrep_le_of_le`.
- **Finite-depth soundness & completeness**: `discrep_eq_bot_iff` —
  `discrep N ω n s t = ⊥ ↔ neural_equiv_upto N n s t`; hence finite-depth vanishing is a
  *certificate* of observational agreement up to depth `n` (`discrep_sound`).
- **Behavioral limit with exact kernel**: `discInf_eq_bot_iff` and
  `discInf_kernel_eq_setoid` — the supremum `d∞ = ⨆ₙ discrep n` vanishes exactly on the
  catalog's `neural_setoid`, so quotienting by the zero kernel yields the canonical metric
  realization.
- **Functoriality**: `discrep_morphism` — morphisms of neural observation systems are
  *distance preserving* (`discrep_morphism_nonexpansive` records the nonexpansive corollary).
- **Explicit Bridges ↔ Tropical statement**: `discrep_tropical_triangle` restates the
  triangle inequality inside `TropicalValuationObject` with `add = max` (`add_eq_max'`).

## Results Summary

A neural observation system now carries a canonical functorial tropical
ultra-pseudometric whose zero kernel is Myhill–Nerode behavioral equivalence, whose
finite-depth approximants are computable separation certificates, and which transforms
covariantly (nonexpansively, in fact isometrically) under system morphisms. This realizes
the catalog's explicitly missing Bridges ↔ Tropical connection.

## Research Directions

### 1. Quantitative discounted distance and a Banach contraction fixed point
The current `discInf` is the *order-theoretic* supremum of `{0,⊥}`-style depths. Replace
the idempotent codomain by `R = ℝ≥0` with a *discount* `γ ∈ (0,1)`, defining
`d(s,t) = ⨆_a [obsmis ⊔ γ · d(step s a, step t a)]`. Conjecture: this `d` is the unique
fixed point of the behavioral discrepancy operator `Φ`, and `Φ` is a γ-contraction on the
complete metric space of bounded state-discrepancy functions, so finite-depth approximants
converge geometrically: `‖discrep n − d‖∞ ≤ γⁿ · diam`. **The key insight is** that the
tropical `⊔` and the analytic contraction coincide because max is 1-Lipschitz, so the
ultrametric recurrence and the discounted recurrence are two specializations of one
operator on an ordered Banach lattice. **Why now?** The catalog already has
`Bridges/BanachFixedPointBridge.lean`; composing it with `discrep` turns the present
"finite-depth theory" into a certified-convergence theorem with explicit rates. Falsifiable:
exhibit a system where `Φ` has two distinct bounded fixed points, or where convergence is
slower than `γⁿ`.

### 2. Stalkwise local-to-global gluing of partial discrepancies
View `discrep N ω n` as a section over the "neighborhood of radius n" around a state pair.
Conjecture: the family `{discrep N ω n}` forms a flasque presheaf on the poset of depths
(restriction = truncation), with `discInf` the global section, and the local agreements
`neural_equiv_upto N n` glue to global `neural_equiv` with **no cohomological obstruction**
(`H¹` vanishes because the chain is monotone/directed). **The key insight is** that
behavioral equivalence is intrinsically *local-to-global*: agreement on every bounded
neighborhood forces global agreement precisely because every word has finite length, which
is exactly a flasque/soft-sheaf gluing statement. **Why now?** The engine is configured for
local-to-global sheaf reasoning, and `discrep_le_of_le` already supplies the directed
restriction maps; formalizing the presheaf makes the obstruction-vanishing explicit.
Falsifiable: find a *weighted/branching* variant (sup over an infinite alphabet without a
maximum) where local agreement on all finite depths fails to glue.

### 3. Tropical isometry classification of minimal realizations
Conjecture: two neural observation systems are behaviorally equivalent (same trace
language) **iff** their quotient tropical valuation objects are *isometric* as
`TropObj`-distance spaces, and the minimal realization is the unique (up to unique
isometry) system whose `discInf` is a genuine metric (separates points). **The key insight
is** that `discrep_morphism` makes `discInf` a functor into tropical distance spaces, so
minimality becomes an initiality/terminality statement in a category of isometries rather
than a counting argument. **Why now?** `discInf_kernel_eq_setoid` already identifies the
separated quotient; upgrading `quotient_step`/`quotient_observe` from the Myhill–Nerode
file to an *isometric* tropical functor closes the loop. Falsifiable: produce two
non-equivalent systems with isometric quotient tropical objects.

### 4. p-adic valuation depth as the codomain
Instantiate `R` by a non-archimedean valuation codomain and connect to
`Computation/PadicValuationDepth.lean`. Conjecture: when `ω` is a p-adic observational
valuation, the depth-`n` discrepancy satisfies a strict ultrametric (`max` is attained, not
just bounded) and the `ValuationDepthMeasure` of `discrep N ω n` (as a function of the
state pair) grows like `O(log n)` via Hensel-style doubling, matching
`HenselIterationComplexity`. **The key insight is** that the max-plus recurrence is the
*tropicalization* of the p-adic |a+b| ≤ max(|a|,|b|) rule, so non-archimedean computation
cost transfers verbatim to behavioral-distance computation. **Why now?** Both the tropical
object and the p-adic depth machinery are already in the catalog; the missing morphism is
this codomain instantiation. Falsifiable: exhibit a p-adic `ω` for which `discrep` depth
grows polynomially rather than logarithmically.

### 5. Lipschitz robustness certificates for compressed neural states
Conjecture: composing `discrep_morphism_nonexpansive` with an observation map that is
`L`-Lipschitz in an input perturbation yields a *certified robustness bound*: the
behavioral distance between a state and its adversarially perturbed neighbor is bounded by
`L` times the input perturbation, uniformly across the compressed quotient. **The key
insight is** that nonexpansiveness of the quotient map means compression *cannot amplify*
adversarial separation, turning Myhill–Nerode minimization into a robustness guarantee.
**Why now?** `Bridges/CategoricalTropicalUltrametric.lean` already proves
`lipschitz_certified_robustness_transfer_quantum`; feeding `discrep` through that transfer
functor produces end-to-end certificates for compressed models. Falsifiable: find a
Lipschitz observation system where compression strictly increases worst-case behavioral
separation.
