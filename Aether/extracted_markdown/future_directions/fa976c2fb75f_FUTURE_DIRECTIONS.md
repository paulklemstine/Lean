# Future Directions: Proof-Net Curvature and Phase Transitions in Theorem Search

The file `Tropical/ProofNetCurvature.lean` establishes a small but load-bearing core
for a geometric theory of automated search. Three pillars are now formal theorems:

- **Tropical concentration** — `trop_add_pow` and `trop_sum_pow` prove that tropical
  exponentiation is *linear over the min*, i.e. raising to a power commutes with
  selecting the best (minimal) branch. This is the algebraic fingerprint of
  *concentrated* search.
- **A total-curvature identity** — `formanTotal_eq` shows the aggregated combinatorial
  Forman–Ricci curvature of a proof-dependency graph is a fixed quadratic functional of
  its degree sequence, `∑F = 4·∑deg − 2·∑deg²` (a discrete Gauss–Bonnet statement).
- **A curvature → growth dichotomy** — `curvature_growth_dichotomy` proves that the
  *sign* of the regular-tree curvature `formanReg b = 2 − 2b` is a sharp order
  parameter: nonnegative curvature forces polynomial ball growth (`≤ d+1`), negative
  curvature forces exponential growth (`≥ 2^d`), with the phase boundary at `b = 1`.

The following directions extend this skeleton toward the full conjecture.

## 1. Tropical curvature as a spectral order parameter

Define the curvature observable directly in the min-plus semiring: replace the integer
degree functional by a *tropical Laplacian* whose entries are tropical sums of edge
weights, and study its tropical eigenvalue (Collatz–Wielandt value). Prove that the
sign of the tropical curvature controls whether tropical matrix powers `A^{⊗n}`
(shortest-path lengths) grow linearly or saturate.

The key insight is that the dichotomy theorem `curvature_growth_dichotomy` is really a
statement about **min-plus powers**: `ballSize` is the tropical trace of `(I ⊕ A)^{⊗d}`,
so the polynomial/exponential split is the tropical analogue of subcritical vs.
supercritical spectral radius. Why now? The catalog already contains a tropical
matrix/shortest-path layer (`Tropical/BellmanFord.lean`, `Tropical/CollatzWielandt.lean`,
`Tropical/Matrix.lean`); `trop_sum_pow` supplies exactly the distributivity needed to
push the freshman's dream through tropical matrix powers, so the spectral reformulation
is within reach of the existing infrastructure.

## 2. From regular trees to degree-sequence thresholds

Generalize `curvature_growth_dichotomy` from the single branching parameter `b` to an
arbitrary finite proof-dependency graph: prove that if the *average* Forman curvature
(extracted from `formanTotal_eq`) is below a threshold `τ(n)`, the size of the
reachable set after `d` expansion steps grows super-polynomially, and conversely.

The key insight is that `formanTotal_eq` already reduces aggregate curvature to
`4·∑deg − 2·∑deg²`, so by Cauchy–Schwarz the average curvature is controlled by the
*variance* of the degree distribution — heavy-tailed (high-variance) degree sequences
are exactly the negatively-curved, diffusive ones. Why now? Both halves are formal:
the curvature side is `formanTotal_eq` and the growth side is `ballSize_ge_of_large`;
the missing step is a single variance inequality, an isolated and self-contained lemma.

## 3. A tropical Harnack / mixing inequality for negatively curved search

State and prove a discrete Harnack inequality: on a graph all of whose edges satisfy
`formanEdge adj u v ≤ -κ` for some `κ > 0`, the tropical heat kernel (iterated min-plus
diffusion) contracts the spread of proof-distances at a rate bounded below by `κ`.

The key insight is that negative Forman curvature is a *uniform expansion* condition,
and in the tropical world expansion becomes a Lipschitz contraction of the min-plus
distance functional — turning a geometric hypothesis into an algebraic fixed-point
estimate provable with `trop_add_pow`. Why now? The binary and finite freshman's dream
theorems give the exact distributive identity that a one-step tropical contraction
estimate iterates against, so the inequality reduces to a clean induction.

## 4. Universality: curvature thresholds invariant under graph rewriting

Conjecture that the curvature threshold separating the two regimes is invariant under
the proof-graph rewrites that real provers perform (subsumption, lemma sharing, cut
elimination), formalized as graph operations preserving the sign of `formanTotal`.

The key insight is that lemma-sharing *merges* vertices and therefore *raises* degree
variance, so it can only move a graph toward the diffusive side — the threshold is a
monotone invariant, not an artifact of representation. Why now? `formanTotal_eq` makes
`formanTotal` a closed-form function of the degree multiset, so the effect of each
rewrite is a concrete, checkable arithmetic change rather than an opaque graph surgery.

## 5. Counterexample boundary: when smooth, non-universal behavior wins

To keep the program falsifiable, build the *refuting* family: weighted graphs whose
curvature varies continuously through zero while ball growth changes smoothly, with no
sharp transition. Formalize a parametric family `G_t` and prove `ballSize` is a
continuous (non-thresholded) function of `t`.

The key insight is that the sharp transition in `curvature_growth_dichotomy` is forced
by the *integrality* of the branching factor `b`; allowing fractional/weighted
branching should smear the transition, and proving this pins down exactly which
discreteness hypothesis the universality claim depends on. Why now? The current proof
visibly uses `interval_cases b`, so the role of integrality is explicit and the
boundary case is a direct, well-posed target rather than a vague worry.
