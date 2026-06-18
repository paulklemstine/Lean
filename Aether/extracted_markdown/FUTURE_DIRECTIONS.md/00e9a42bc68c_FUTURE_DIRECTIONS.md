# Future Directions: Perturbation-Stable Generalization Bounds

The new file `Catalog/MachineLearning/PerturbedGeneralization.lean` bridges the
catalog's two previously disconnected machine-learning strands: the
compression/Occam bound (`MachineLearning.CompressionGeneralization`:
`occamBound`, `occam_sample_complexity`, `overparam_invariance`) and the
architecture-perturbation theory (`MachineLearning.Generalization`:
`archDistReal`, `archDistReal_triangle`). The pivot is that `occamBound` is an
*isometry in its empirical-risk coordinate* (`occamBound_dist_eq`), so risk
stability transfers verbatim to guarantee stability
(`arch_perturbed_bound`, `perturbed_sample_complexity`). The following
conjectures push that bridge further.

## 1. Two-sided isometry collapse for ensembles

**Conjecture.** For an ensemble of `m` models with identical complexity `C` and
empirical risks `R₁,…,Rₘ`, the certified bound of the *risk-averaged* model
equals the average of the certified bounds plus a single shared penalty; i.e.
`occamBound (avg R) C n δ = avg (fun i => occamBound (Rᵢ) C n δ)`.

The key insight is that since the penalty term is constant in `R`, the bound map
is affine, and affine maps commute with convex averaging exactly — there is no
Jensen gap, unlike for genuinely nonlinear capacity measures.

**Why now?** `occamBound_gap_indep_empRisk` already isolates the penalty as
`R`-independent; the averaging identity is one `Finset.sum` manipulation away and
would give the first *exact* (not merely upper-bounded) ensemble generalization
identity in the catalog.

## 2. Lipschitz-budget triangle inequality across architecture chains

**Conjecture.** If empirical risk is `L`-Lipschitz in `archDistReal`, then along
a chain `a → b → c` the certified-bound shift is subadditive:
`occamBound (emp c) C n δ ≤ occamBound (emp a) C n δ + L·(archDistReal a b + archDistReal b c)`.

The key insight is that the catalog's `archDistReal_triangle` plus the isometry
`occamBound_perturb_le` compose, so the metric structure on architectures is
inherited *with the same Lipschitz constant* by the space of certified
guarantees.

**Why now?** `arch_perturbed_bound` already handles a single edit; chaining it
through `archDistReal_triangle` (already proven in the catalog) turns the bound
into a genuine pseudmetric morphism, enabling multi-step neural-architecture
search with cumulative certified stability.

## 3. Tightness / necessity of the perturbation budget

**Conjecture.** The `+η` term in `perturbed_sample_complexity` is tight: there
exists an `L`-Lipschitz risk functional and architectures `a, b` with
`L·archDistReal a b = η` for which `occamBound (emp b) C n δ = emp a + ε + η`,
so no smaller perturbation slack is valid in general.

The key insight is that the isometry property forces the worst case to be
achieved by a risk functional that saturates the Lipschitz inequality linearly,
making the bound an equality rather than a strict inequality.

**Why now?** The forward bound is proven; the matching lower bound only needs a
single explicit `emp := fun x => L * archDistReal a x` witness, turning an
inequality into a sharp characterization and ruling out spurious improvements.

## 4. Confidence-budget exchange (δ ↔ ε ↔ η trade-off surface)

**Conjecture.** Fixing the certified target `emp a + τ`, the admissible region
of `(δ, ε, η, n)` satisfying `perturbed_sample_complexity` forms a downward-closed
set whose Pareto frontier is described by
`ε + η = τ` and `n = (C + log(1/δ))/(2ε²)`, giving an explicit exchange rate
`dn/dη = (C + log(1/δ))/(τ − η)³` between perturbation tolerance and data.

The key insight is that because the penalty enters only through `ε` and the
perturbation only through `η`, the two budgets are *separable*, so the trade-off
surface factorizes into a data term and a robustness term with no cross-coupling.

**Why now?** All ingredients (`penalty_le_of_sample`, `perturbed_sample_complexity`)
are formalized; differentiating the closed-form inversion is elementary calculus
already supported in Mathlib, and it would yield the first quantitative
data-vs-robustness exchange theorem in the catalog.

## 5. PAC-Bayes lift of the isometry

**Conjecture.** Replacing the point hypothesis by a posterior `Q` and the
complexity `C` by the KL divergence `KL(Q‖P)`, the resulting PAC-Bayes Occam
bound remains an isometry in the *expected* empirical risk `𝔼_{h∼Q}[R(h)]`, so
`perturbed_sample_complexity` lifts verbatim with `archDistReal` replaced by a
Wasserstein distance between posteriors.

The key insight is that the empirical-risk coordinate enters the PAC-Bayes bound
linearly through an expectation, and expectation preserves the affine-translation
structure that powers the entire isometry argument.

**Why now?** The catalog already contains PAC-Bayes scaffolding
(`MachineLearning.Catoni`); composing it with the isometry lemmas here is the
natural next step and would unify compression, perturbation, and PAC-Bayes
generalization under a single Lipschitz-transfer principle.
