# Future Directions — Proof-Complexity Holography

## Synthesis

This cycle isolates the *geometric* content shared by two previously separate strands of the
catalog's proof-complexity program:

* the **proof quasi-metric** `minDerivLen` of `Logic.ProofMetric` (length-graded derivability
  `DerivOfLen`, additive composition `derivOfLen_comp`, the directed triangle inequality, and
  the chain geodesic `minDerivLen_chain_geodesic`); and
* the **Cook–Reckhow simulation preorder** of `Logic.ProofComplexity.SimulationPreorder`
  (`Simulates`, polynomial blow-ups, `Simulates_trans`, the p-degree `Setoid`).

The bridging object is a **proof translation** (`Translation`): a map of atoms plus a *local*
one-step stretch certificate. The central discovery (`Catalog/Logic/ProofComplexity/Holography.lean`)
is that this purely local datum propagates *holographically* to a *global* metric statement:

* `translate_deriv` — a stretch-`L` translation sends every length-`k` derivation to one of
  length `≤ L·k` (the bulk engine);
* `minDerivLen_translate_le` — hence the proof metric is `L`-Lipschitz under translation (the
  boundary shadow), which is exactly Cook–Reckhow p-simulation read inside the ℕ-valued metric;
* `translate_comp_step` — translation composition / stretch multiplication, derived *from*
  `translate_deriv` rather than reproved, unifying `derivOfLen_comp` with `Simulates_trans`;
* `chain_doubling_isometry` — on the chain the Lipschitz bound is *attained exactly* (doubling
  scales distance by exactly 2), so geodesic rigidity ("zero proof slack") = "Lipschitz constant
  attained".

## Results Summary

Four sorry-free theorems (plus the helper `derivOfLen_one_of_step`), all depending only on
`propext, Classical.choice, Quot.sound`. The file is self-contained (mirrors the catalog
infrastructure verbatim, as `ProofMetric.lean` does) and so extends the existing program on
definitionally identical objects.

## Research Directions

### 1. Translations form a category; the proof metric is a (lax) functor to `(ℕ, ≤, ·)`

Promote `Translation` to a genuine category: objects are implicational theories, morphisms are
translations, with `identity` (stretch 1) and `comp` (stretch `M·L`, justified by
`translate_comp_step`). Then `minDerivLen_translate_le` says the assignment
`(T, a, b) ↦ minDerivLen T a b` is a lax functor into the multiplicative monoid `(ℕ, ·)` acting
on the metric. **The key insight is** that compositionality of proof translation is not an axiom
but a *theorem* about derivation length, so the whole simulation preorder is the shadow of a
category whose hom-data is a single natural number (the stretch). **Why now?** `translate_comp_step`
already supplies the associativity-compatible composition law; only the bookkeeping of an
identity/associativity proof remains, and Mathlib's `CategoryTheory` scaffolding makes this
mechanical. Falsifiable: if stretches did *not* multiply (e.g. only added), the functor law would
fail and no `CategoryTheory.Functor` instance could be built.

### 2. A two-sided translation forces bi-Lipschitz equivalence of proof metrics

Conjecture: if there are translations `φ : T → S` (stretch `L`) and `ψ : S → T` (stretch `M`)
that are mutually inverse on atoms (`ψ ∘ φ = id`, `φ ∘ ψ = id`), then the proof metrics are
*bi-Lipschitz*: `(1/(L·M))·minDerivLen T a b ≤ minDerivLen S (φ a)(φ b) ≤ L·minDerivLen T a b`
(stated over ℚ or via the integer inequalities `minDerivLen T a b ≤ L·M·minDerivLen T a b`).
**The key insight is** that p-equivalence (`PEquiv`, the `Setoid` of `SimulationPreorder`) is
exactly bi-Lipschitz equivalence of the underlying proof geometries, so p-degrees are
quasi-isometry classes. **Why now?** Both directions are immediate iterates of
`minDerivLen_translate_le` once the round-trip identity is available; the only new ingredient is
the elementary `minDerivLen T a b ≤ L·M·minDerivLen T a b` round-trip estimate. Falsifiable by
exhibiting two atoms whose distances violate the product bound.

### 3. Non-existence of a bounded-stretch translation as a metric separation criterion

`SimulationPreorder.no_simulation_of_fib_hard` separates systems via Fibonacci size lower bounds.
Conjecture a metric analogue: if a family `(aₙ, bₙ)` in `T` has `minDerivLen T aₙ bₙ ≤ n` while
every translation image must satisfy `minDerivLen S (φ aₙ)(φ bₙ) ≥ F n` (Fibonacci), then *no*
finite-stretch translation `T → S` exists. **The key insight is** that super-linear growth of the
*ratio* of proof distances — not of raw proof size — is the intrinsic, system-presentation-free
obstruction to simulation. **Why now?** `not_polyBounded_fib` and `two_pow_le_fib` are already in
the catalog; combined with `minDerivLen_translate_le` (which caps the ratio at the constant `L`),
a single `n` with `F n > L·n` yields the contradiction. Falsifiable: any explicit bounded-stretch
translation between two such theories would refute it.

### 4. Geodesic rigidity classifies the extremal (holographically exact) theories

`chain_doubling_isometry` shows the chain attains the Lipschitz bound exactly. Conjecture that
"attains every translation bound with equality" (zero proof slack on all triples) *characterizes*
chain-like theories: a theory whose `minDerivLen` triangle inequality is always an equality on
derivable triples is order-isomorphic to a disjoint union of chains. **The key insight is** that
holographic exactness is a rigidity phenomenon — equality in the metric forces a one-dimensional
(geodesic) bulk, the discrete analogue of flatness saturating an isoperimetric bound. **Why now?**
`minDerivLen_chain_geodesic` gives the chain direction; the converse needs only that an
always-equality metric admits no "shortcut" axioms, a finite combinatorial argument on
`DerivOfLen`. Falsifiable by a non-chain theory with everywhere-equality triangle law.

### 5. Stretch as a graded norm: a tropical/numerical-semigroup invariant of theories

`ProofMetric.loopLengths_add` makes loop lengths an additive submonoid of ℕ. Conjecture that the
*minimal stretch* needed to translate `T` into a fixed reference theory (e.g. the chain) defines a
tropical (min-plus) seminorm on theories that is sub-multiplicative under composition and additive
along the loop-length semigroup. **The key insight is** that proof-complexity holography is
secretly tropical geometry: stretches compose multiplicatively (`translate_comp_step`) while proof
lengths compose additively (`derivOfLen_comp`), exactly the (·, +) ↔ (+, min) dictionary of the
tropical semiring, linking this file to `Catalog/Tropical`. **Why now?** Both composition laws are
now formal theorems on the same objects, so the tropical structure can be stated and tested
directly. Falsifiable by a theory whose minimal stretch fails sub-multiplicativity under composition.
