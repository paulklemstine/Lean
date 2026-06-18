# Future Directions: ReLU Width–Depth Trade-offs

The file `Basic.lean` establishes a fully formal, axiom-clean depth-separation
result for ReLU networks built from the tent map `tent x = 1 - |2x - 1|`. The
depth-`k` constant-width network `tent^[k]` rises from `0` to `1` over an
interval of width `2^{-k}` (`tent_iterate_zero`, `tent_iterate_peak`), is
`2^k`-Lipschitz (`tent_iterate_lipschitz`), yet stays bounded in `[0,1]`. Any
`K`-Lipschitz approximant with `K·2^{-k} + 2ε < 1` provably fails
(`relu_depth_separation`). The following directions extend this frontier; each
is testable and falsifiable.

## 1. From a single steep ramp to a counting (oscillation) lower bound

The current obstruction uses one ramp of width `2^{-k}`. The sharper
Telgarsky-style statement counts oscillations: `tent^[k]` crosses the level
`1/2` exactly `2^k` times, while a one-hidden-layer ReLU network of width `w`
is piecewise-linear with at most `w+1` pieces and hence crosses any level at
most `w+1` times. This yields an *exact width lower bound* `w ≥ 2^k - 1`,
independent of the weight magnitudes — a strictly stronger separation than the
Lipschitz version.
**The key insight is** that the crossing number of a continuous piecewise-linear
function is bounded by its number of affine pieces, so an exponential crossing
count forces exponential width regardless of how large the weights are allowed
to be. **Why now?** The tent and its iterate are already formalized with their
ascending-branch identity `tent_eq_two_mul`; the missing ingredient is a Lean
lemma "a function with `p` affine pieces has at most `p` solutions to `f = c`",
which is a finite combinatorial fact about `tent_iterate_peak`-style alternation
and is within reach of the existing induction machinery.

## 2. Matching shallow upper bound: quantitative 1-D universal approximation

Pair the lower bound with a constructive upper bound: every `K`-Lipschitz
`f : [0,1] → ℝ` is approximated within `ε` by the piecewise-linear interpolant
on `N = ⌈K/ε⌉` equal nodes, which is exactly a width-`N` one-hidden-layer ReLU
network. This pins the shallow cost at `Θ(K/ε)` and, with direction 1, closes
the `width ≈ ε^{-1}` (shallow) vs `depth ≈ log(1/ε)` (deep) gap quantitatively.
**The key insight is** that Lipschitz control bounds the interpolation error by
`K · (mesh size)`, so a uniform mesh of `K/ε` nodes suffices and each interior
node is one ReLU neuron. **Why now?** `relu_depth_separation` already isolates
the Lipschitz constant as the governing quantity; the dual upper bound reuses
the same `LipschitzWith` API plus Mathlib's `Real`-interval interpolation
lemmas, making the two-sided `Θ` characterization formalizable today.

## 3. Higher-dimensional separation on `[-1,1]^n`

Lift the construction to `[-1,1]^n` via tensorized tents
`F(x) = tent^[k](x₁) · ⋯ · tent^[k](xₙ)` or a max-pooling variant, and show the
shallow Lipschitz/width cost scales as `ε^{-n}` while a depth-`O(n·log(1/ε))`
network keeps polynomial size — the genuine curse-of-dimensionality separation
named in the original concept.
**The key insight is** that local steepness is multiplicative under tensor
products, so the per-coordinate factor `2^k` compounds to `2^{nk}` worth of
oscillation that a single shallow layer must resolve along every axis
simultaneously. **Why now?** The 1-D engine (`tent_lipschitz`,
`tent_iterate_lipschitz`) is multiplicative-composition-ready, and Mathlib's
`LipschitzWith.prod`/`pi` lemmas give the product Lipschitz bounds needed to
transport the obstruction coordinatewise.

## 4. Robustness / adversarial reading of the Lipschitz obstruction

Reinterpret `relu_depth_separation` as a *robustness lower bound*: because
`tent^[k]` has local slope `2^k`, an input perturbation of size `2^{-k}` flips
the output across the full range `[0,1]`. Formalize that any classifier of
Lipschitz constant `K < 2^k` must misclassify some `2^{-k}`-adversarial pair,
giving a provable depth-induced fragility theorem.
**The key insight is** that the *same* quantity (local slope `2^k`) that defeats
shallow approximation also certifies adversarial sensitivity, unifying
expressivity and robustness through one Lipschitz budget. **Why now?** The
endpoints `tent_iterate_zero = 0` and `tent_iterate_peak = 1` already exhibit an
explicit `2^{-k}`-separated pair with maximal output gap, so the adversarial
statement is a direct repackaging of the proven inequality.

## 5. Cross-domain bridge: tent oscillation vs. the EML exponential tower

The catalog's `MachineLearning.DepthSeparation.Separation` proves a Lipschitz
obstruction for the iterated *exponential* `iterExp k` (whose **range** explodes
like a tower), whereas this file's `tent^[k]` keeps a **bounded range** but
explodes in **local slope**. Formalize a single abstract obstruction
—"`f` attains values `a < b` at points distance `δ` apart ⟹ no `K`-Lipschitz
`ε`-approximant exists once `K·δ + 2ε < b - a`"— and derive *both* theorems as
instances.
**The key insight is** that range-blowup and slope-blowup are two faces of one
inequality `(b-a) ≤ K·δ + 2ε`, so a single lemma parameterized by the
witnessing pair `(δ, b-a)` subsumes the exponential-tower and tent-map
separations. **Why now?** Both endpoint computations already exist in the
catalog (`iterExp_endpoint_gap`) and in this file (`tent_iterate_peak`), so the
unifying lemma can be stated, proven once, and back-applied to retire two
bespoke proofs — a concrete cross-domain consolidation.
