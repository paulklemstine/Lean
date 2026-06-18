# Future Directions — The Fractal Dimension of Mathematical Truth

## Synthesis of findings

This cycle reframes the slogan "truth has a fractal dimension strictly between 0
and 1" as a precise statement about the **Hausdorff dimension `dimH` of truth
sets** living in a metric statement space, and proves the invariance/approximation
backbone that makes such a dimension well-defined.

Two files were produced (both `sorry`-free, axioms `propext`/`Classical.choice`/
`Quot.sound` only):

* `Metric.lean` — domain-general theory over an arbitrary `EMetricSpace`:
  encoding invariance (`dimH_image_eq_of_biLipschitz`,
  `dimH_image_eq_of_isometry`), a quantitative leak bound for lossy encodings
  (`dimH_image_le_of_holder`), and approximation-from-below by a countable
  exhaustion (`dimH_eq_iSup_window`) — the geometric analogue of the Chaitin-`Ω`
  "supremum of computable lower bounds" mechanism.
* `Spectrum.lean` — statement space realised as `ℝ`: confinement to `[0,1]`
  (`dimH_truth_le_one`, `dimH_truth_mem_Icc`), **sparsity** of syntactic truth
  (`dimH_truth_countable`, `dimH_re_theorems_zero`), **plenitude** of continuum
  truth (`dimH_truth_of_interval`), and stability under countable axiom changes
  (`dimH_truth_stable_axioms`).

The most important conceptual output is a **sharpening of the original
conjecture**: for any *countable* (e.g. recursively enumerable) language, the
truth set is countable, so its dimension is exactly `0`, not in the open interval
`(0,1)`. The genuine "sparse but not negligible" regime is therefore intrinsically
a *semantic / continuum* phenomenon, and exhibiting it requires a self-similar,
Cantor-type truth set. That construction is the headline open problem below.

## Results summary

| Theorem | Statement | Regime |
|---|---|---|
| `dimH_truth_le_one` / `dimH_truth_mem_Icc` | every truth set has `dimH ∈ [0,1]` | confinement |
| `dimH_truth_countable` / `dimH_re_theorems_zero` | countable / r.e. truth has `dimH = 0` | sparsity (left endpoint) |
| `dimH_truth_of_interval` | interval-containing truth has `dimH = 1` | plenitude (right endpoint) |
| `dimH_image_eq_of_biLipschitz` / `_isometry` | dimension independent of (bi-Lipschitz) encoding | well-definedness |
| `dimH_image_le_of_holder` | Hölder-`r` re-encoding inflates dimension by `≤ 1/r` | robustness |
| `dimH_eq_iSup_window` | `dimH T = ⨆ₙ dimH(T ∩ [-n,n])` | approximation from below |
| `dimH_truth_stable_axioms` | countable axiom changes preserve `dimH` | stability |

## Research directions

### 1. Construct an explicit truth set of dimension strictly inside `(0,1)`
Define the truth set `C_b ⊆ [0,1]` of statement codes whose base-`b` expansion
omits a fixed digit (a Cantor-type self-similar set), and prove
`dimH C_b = log(b-1)/log b ∈ (0,1)`. **The key insight is** that the only metric
spaces on which the dimension-lowering snowflake `d ↦ d^r` (with `r > 1`) remains
a metric are *ultrametric*, and the cylinder structure of digit-restricted codes
is exactly such an ultrametric — so self-similarity, not analysis on `ℝ`, is the
right engine for a genuinely fractional dimension. **Why now?** Mathlib already
ships `dimH`, `μH[d]`, the Hölder/antilipschitz image bounds, and Frostman-style
mass-distribution tooling; the missing piece is one mass-distribution lower bound,
which the present invariance lemmas (`dimH_image_le_of_holder`) reduce to a finite
self-similarity computation.

### 2. A formal "Ω of truth": the dimension is uncomputable but left-c.e.
Define a concrete left-c.e. real assembled from the window approximations
`dimH(T ∩ [-n,n])` of a truth set attached to a universal r.e. theory, and prove
it is approximable from below (`dimH_eq_iSup_window` already gives the supremum
representation) yet not computable, by reducing the halting problem to a threshold
query on the stages. **The key insight is** that `dimH_eq_iSup_window` exhibits the
dimension as a supremum of stage values exactly as Chaitin's `Ω` is a supremum of
computable lower bounds, so uncomputability should transfer through the same
diagonal argument. **Why now?** Mathlib's `Computability`/`Partrec` hierarchy is
mature enough to host the reduction, and the supremum representation is already
proven here, isolating the genuinely computability-theoretic step.

### 3. A dimension drop / "logical phase transition" theorem
Quantify how `dimH` of the truth set of a theory `T` changes as one passes to a
finite extension `T + φ`, and prove a dichotomy: either `φ` is decided by `T`
(dimension unchanged) or the consistent-completion set splits, dropping the
dimension by a computable amount. **The key insight is** that adding an
independent axiom prunes the Stone space of completions self-similarly, so the
dimension should obey a renormalization recurrence rather than changing
arbitrarily. **Why now?** `dimH_truth_stable_axioms` already proves the *countable*
(invisible) case; the open content is precisely the *uncountable* completion
space, which Mathlib's `Topology` of profinite/Stone spaces can now model.

### 4. Dimension as a complexity measure: `dimH` vs. Kolmogorov complexity
Prove that for the truth set of an r.e. theory the (effective/box-counting)
dimension of the window `T ∩ [-n,n]` is asymptotically governed by the prefix
Kolmogorov complexity of the theory's first `n` decisions, i.e. a Ryabko/Staiger
"dimension = compression rate" theorem in the truth-set setting. **The key insight
is** that effective Hausdorff dimension equals the asymptotic compression rate, so
"how fractal is truth" becomes literally "how incompressible is the truth table".
**Why now?** The invariance lemmas here show the dimension is encoding-independent
up to bi-Lipschitz maps, which is exactly the equivalence class on which
compression-rate characterizations are stated.

### 5. Higher-dimensional and product truth: dimension of joint theories
Embed pairs of theories into `ℝ²` and prove a product law
`dimH (T₁ × T₂) = dimH T₁ + dimH T₂` for the geometrically independent case, then
characterize the *failure* of additivity as a quantitative measure of logical
entanglement between the theories. **The key insight is** that logical
independence of two axiom systems should manifest as *geometric* (product-set)
independence, turning a logical notion into an additive dimension invariant.
**Why now?** Mathlib has `dimH` product inequalities and `dimH_univ_pi_fin`, so the
additive upper/lower bounds are within reach, and our bi-Lipschitz invariance
guarantees the product law is independent of how each factor is coded.
