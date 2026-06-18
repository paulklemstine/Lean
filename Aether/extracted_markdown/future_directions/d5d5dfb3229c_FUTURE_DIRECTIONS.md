# Future Directions: The Compression Skeleton of Generalization

## Synthesis of this cycle

This cycle closed a real gap in the `MachineLearning` catalog. The file
`MachineLearning/PerturbedGeneralization.lean` was an **orphan**: it imported a
foundation, `MachineLearning.CompressionGeneralization`, that did not exist in
the repository, so the entire perturbation-stable robustness story could not
compile. We reconstructed that foundation and then built a new floor on top of
it.

- **`MachineLearning/CompressionGeneralization.lean`** isolates the *analytic
  skeleton* shared by Occam's-razor, sample-compression, and norm-based capacity
  bounds: every such bound is `R + sqrt((C + log(1/δ))/(2n))`, an abstract
  empirical risk `R` plus a square-root capacity penalty in an *abstract*
  complexity scalar `C`. The deep facts — consistency
  (`occam_gap_tendsto_zero`: the bound converges to `R`), the sample-complexity
  inversion (`occam_sample_complexity`: `n ≥ (C+log(1/δ))/(2ε²) ⟹ penalty ≤ ε`),
  Occam monotonicity (`occamBound_mono_complexity`), and overparameterization
  invariance (`overparam_invariance`) — are proved once, with `C` fully abstract.
  This is exactly what lets `PerturbedGeneralization.lean` add adversarial
  robustness "for free" by shifting a single slot `R ↦ R + L·ρ`.

- **`MachineLearning/CompressionSelection.lean`** extends the skeleton from a
  *single* certified model to *finite families*, formalizing structural risk
  minimization (SRM) as a pure order-theoretic fact: `bestBound` is the
  `Finset.min'` of the per-model certificates, and its soundness
  (`bestBound_le`), realizability (`exists_best`), monotonicity in the candidate
  set (`bestBound_anti_subset`: more candidates never hurt), and empirical-risk
  floor (`bestBound_ge_empRisk_floor`) all follow with no new statistics.

## Results summary

| Theorem | File | Content |
|---|---|---|
| `occam_gap_tendsto_zero` | CompressionGeneralization | bound → empirical risk as `n → ∞` |
| `occam_sample_complexity` | CompressionGeneralization | `n` large ⟹ penalty `≤ ε` |
| `occamBound_mono_complexity` | CompressionGeneralization | Occam: simpler model ⇒ tighter bound |
| `net_bound_tendsto` | CompressionGeneralization | a fixed model's bound → its empirical risk |
| `overparam_invariance` | CompressionGeneralization | bound ignores raw parameter count |
| `bestBound_le` / `exists_best` | CompressionSelection | SRM certificate is sound and realized |
| `bestBound_anti_subset` | CompressionSelection | enlarging the family never raises the best bound |

All main results compile with `sorry = 0` and depend only on the standard axioms
`propext, Classical.choice, Quot.sound`. The previously-orphaned
`PerturbedGeneralization.lean` now compiles against the reconstructed skeleton.

## Research directions for the next cycle

### 1. A quantitative selection penalty: SRM should cost only `log |s|`

`bestBound_anti_subset` shows that adding candidates never *raises* the best
bound, but it says nothing about the price of *honest* selection: searching a
family of size `|s|` should inflate the reported confidence by a union-bound
factor, turning the per-model `log(1/δ)` into `log(|s|/δ)`. The conjecture is
that there is a `selectionBound s hs n δ := bestBound s hs n (δ / s.card)`
satisfying `selectionBound s hs n δ ≤ bestBound {net} _ n δ + sqrt(log(s.card)/(2n))`
for the single best member, i.e. selection costs exactly one extra
`sqrt(log|s|/(2n))` term. **The key insight is** that the union bound is itself
an instance of the compression skeleton — replacing `C` by `C + log|s|` — so the
selection penalty is *already inside the skeleton* and needs no new analysis,
only the right instantiation of `C`. **Why now?** We have both the abstract
penalty `penalty C n δ` and the `Finset.min'` machinery in place; the only
missing lemma is `penalty (C + log k) n δ ≤ penalty C n δ + penalty (log k) n δ`,
a concavity/subadditivity fact about `sqrt`, which is squarely in Mathlib's
reach.

### 2. Robust model selection: composing `CompressionSelection` with `PerturbedGeneralization`

`PerturbedGeneralization.lean` certifies a single model under `ρ`-bounded
adversarial perturbation; `CompressionSelection.lean` selects the best of a
family. Their composite — `bestPerturbedBound`, the `min'` of the per-model
`Net.perturbedBound L ρ n δ` — should satisfy a robust analogue of all four
selection lemmas, and crucially `bestPerturbedBound s hs L ρ n δ ≤ bestBound s
hs n δ + L·ρ` (robustness costs the *same single additive term* even after
selection). **The key insight is** that selection (a `min'`) and robustness (an
additive `L·ρ` shift) commute, because adding a constant to every element of a
finite set shifts its minimum by exactly that constant. **Why now?** Both
ingredients are already proved and live in the same namespace; the commuting law
is `Finset.min'_add_const`, which is elementary, so the composite certificate is
one short proof away from a genuinely new "robust SRM" theorem.

### 3. Sharp converse: is the `sqrt(1/n)` rate optimal for the skeleton?

Every theorem here is an *upper* bound. The falsifiable converse is that the
square-root rate is unimprovable *within the skeleton*: there is no exponent
`p > 1/2` and constant `K` with `penalty C n δ ≤ K · n^(-p)` holding for all `n`
when `C + log(1/δ) > 0`. Equivalently, `n^p · penalty C n δ → ∞` for every
`p > 1/2`. **The key insight is** that `penalty C n δ = sqrt(C')·n^(-1/2)/sqrt 2`
is an *exact* power law in `n`, so the rate question reduces to comparing
exponents of `n` — a one-line limit computation, not a statistical lower-bound
argument. **Why now?** `occam_penalty_tendsto_zero` already pins the limit to 0;
upgrading it to the exact `Θ(n^{-1/2})` rate with `Filter.Tendsto` and
`Real.rpow` is directly supported, and it would give the catalog its first
*two-sided* (matching) generalization rate.

### 4. From description length to norm-based capacity: instantiating `C = ‖w‖·B`

The skeleton advertises three instantiations of `C` (description length,
compression-set size, norm-margin ratio) but currently only realizes the first
via `Net.bits`. The conjecture is that a `LinearNet` with weight vector `w` and
input radius `B` admits a margin-normalized instantiation `C := ‖w‖ * B / margin`
for which all skeleton theorems (`occam_gap_tendsto_zero`,
`occam_sample_complexity`, `occamBound_mono_complexity`) hold verbatim, and that
this bound is *invariant under positive rescaling* of `(w, margin)`. **The key
insight is** that the skeleton is agnostic to the *meaning* of `C`, so a
norm-based bound is not a new theorem but a new `def` feeding the same `C` slot —
the scale-invariance is the analogue of `overparam_invariance` for the
continuous parameterization. **Why now?** Mathlib has the full normed-space and
`LipschitzWith` API (already used in `PerturbedGeneralization.lean`), so the
margin/norm definitions can be stated cleanly and immediately routed through the
existing abstract theorems.

### 5. Lattice structure of certified families: `bestBound` as a monoid homomorphism

`bestBound_anti_subset` is one face of a richer algebraic structure: the map
`s ↦ bestBound s` should turn `Finset.union` of candidate families into
`min` of their best bounds, i.e. `bestBound (s ∪ t) _ n δ = min (bestBound s _ n
δ) (bestBound t _ n δ)`. This makes certified model selection a homomorphism from
the `(∪, ∅?)` semilattice of candidate sets to the `(min)` semilattice of
reals. **The key insight is** that `Finset.min'` already distributes over union,
so SRM is not merely monotone but *fully compositional*: you can certify
sub-libraries independently and combine certificates by `min`, enabling modular,
incremental model search. **Why now?** `Finset.min'_union` (or its `inf'`
cousin) is in Mathlib, and `bestBound` is defined directly as `min'`, so the
homomorphism law is within immediate reach and would upgrade the catalog's SRM
story from an inequality to an exact algebraic identity.
