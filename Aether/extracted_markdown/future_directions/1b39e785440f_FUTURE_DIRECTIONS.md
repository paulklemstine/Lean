# Future Directions — The Extended Interleaving Metric (Boltzmann Bridge V)

## Synthesis

`Applications/BoltzmannBridge/InterleavingMetric.lean` closes the catalog's
persistent-homology arc by repairing the one structural defect its predecessors
flagged but could not fix. The arc runs:

* **II — `HigherPersistence`**: the filtration calculus (`Filtration`,
  `sublevelFaces`, `sublevel_mono`, the Vietoris–Rips `diamWeight`).
* **III — `PersistenceStability`**: scattered set-inclusion interleaving lemmas
  (`stability_interleaving`, `stability_compose`, `stability_two_sided`).
* **IV — `BottleneckStability`**: the relational interleaving preorder
  (`Interleaved`, with `refl/symm/mono/trans`), a *real*-valued
  `interleavingDist`, and the `1`-Lipschitz diameter estimate
  `diamWeightOf_dist_le`. Its Lab Notebook recorded an honest failure: with
  `sInf ∅ = 0` in `ℝ`, never-interleaved filtrations are misreported at distance
  `0`, so the **triangle inequality is false in `ℝ`**.
* **V — `InterleavingMetric` (this cycle)**: move the codomain to `ℝ≥0∞`. Now
  `sInf ∅ = ⊤` is *correct*, and the triangle inequality holds **unconditionally**
  (`eInterleavingDist_triangle`). The payoff is a genuine representation theorem:
  `interleavingPseudoEMetric : PseudoEMetricSpace (Filtration α)`. The abstract,
  purely relational interleaving preorder is *represented* faithfully as a
  concrete metric geometry — the duality between the relational and metric
  pictures of persistence stability.

The decisive observation is dual in nature: the metric axiom (triangle) is the
shadow of the relational axiom (`Interleaved_trans`), and the bridge between them
is exactly the `ℝ≥0∞`-algebra `ENNReal.sInf_add` / `ENNReal.add_sInf` that the real
`sInf` lacked.

## Results Summary

* `eInterleavingDist : Filtration α → Filtration α → ℝ≥0∞`, the extended
  interleaving distance.
* `eInterleavingDist_le` — every interleaving witness `δ` bounds the distance by
  `ENNReal.ofReal δ`.
* `eInterleavingDist_self`, `eInterleavingDist_comm` — diagonal vanishing and
  symmetry.
* `eInterleavingDist_triangle` — the **unconditional** triangle inequality.
* `interleavingPseudoEMetric` — the representation theorem: filtrations form an
  extended pseudometric space.
* `eInterleavingDist_le_supDist` — CESH stability in extended `1`-Lipschitz form.
* `vr_eStability`, `cloud_eInterleavingDist_le` — Vietoris–Rips and concrete
  point-cloud specializations, reusing `diamWeightOf_dist_le` and
  `cloud_distortion` from `BottleneckStability`.

All main results compile with `sorry`-count `0` and depend only on the standard
axioms `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. The kernel of the pseudometric — when is the representation faithful?

The representation `interleavingPseudoEMetric` is a *pseudo*metric: distinct
filtrations may sit at distance `0`. The conjecture is a clean separation axiom:
`eInterleavingDist F G = 0` if and only if `F` and `G` have *identical sublevel
families* at every scale, i.e. `∀ t, F.sublevelFaces t = G.sublevelFaces t`.
One direction is immediate from `eInterleavingDist_le`; the converse needs an
approximation argument squeezing the shift to `0`. **The key insight is** that the
distance-zero kernel should coincide exactly with the equivalence "same
persistence content," so that the *metric quotient* of `Filtration α` is a genuine
`EMetricSpace` whose points are persistence modules up to isomorphism. **Why now?**
The pseudometric structure is in hand this cycle; the only missing ingredient is a
limiting lemma, and `ℝ≥0∞` already supplies `ENNReal.iInf` continuity machinery to
run it — this is the natural next theorem, not a new theory.

### 2. The Cohen-Steiner–Edelsbrunner–Harer isometry (lower bound).

We have the upper bound `eInterleavingDist_le_supDist`; the deep half of CESH is
the matching *lower* bound, realized through the bottleneck distance of persistence
diagrams: `bottleneck(Dgm F, Dgm G) = eInterleavingDist F G`. **The key insight is**
that the upper bound is pure monotonicity bookkeeping while the lower bound is a
combinatorial matching (Hall's theorem / a min-cost assignment on diagram points),
so the two halves are genuinely dual optimization problems — sup-of-shifts versus
min-of-matchings. **Why now?** With the metric side fully formalized, the diagram
side becomes a self-contained combinatorial target; the catalog already has
matching/assignment infrastructure that can be repurposed, making the isometry the
highest-value falsifiable theorem to attempt next.

### 3. Completeness of the interleaving (pseudo)metric space.

Conjecture: `(Filtration α, eInterleavingDist)` is a **complete** extended
pseudometric space — every Cauchy sequence of filtrations converges to a
filtration whose weight function is the pointwise limit of the weights. **The key
insight is** that Cauchy-ness in the interleaving metric forces the weight
functions to be uniformly Cauchy in sup-norm (by the `1`-Lipschitz bound run
backwards), and the pointwise limit of monotone functions is monotone, so the
limit object is automatically a legal `Filtration`. **Why now?** `ℝ≥0∞` is itself
complete and `eInterleavingDist_le_supDist` gives the sup-norm comparison for free;
completeness is the standard capstone that turns the representation theorem into a
usable analytic object (fixed-point and limit arguments become available).

### 4. Stability of numerical invariants — the Euler characteristic curve.

The catalog already proves `euler_char_full_simplex`. Define the Euler
characteristic curve `t ↦ χ(F.sublevelComplex t)` and conjecture it is **stable**:
close filtrations have curves that agree off a set of small total measure, with a
bound controlled by `eInterleavingDist F G`. **The key insight is** that a
`δ`-interleaving forces the two curves to interleave horizontally by `δ`, so any
*translation-invariant, `1`-Lipschitz* functional of the curve (its `L¹` distance,
its total variation) inherits a stability bound directly from
`eInterleavingDist_triangle` — invariant stability is a corollary of metric
stability, not a separate theorem. **Why now?** The Euler-characteristic machinery
and the metric both already exist in the catalog; wiring them together is a
short bridge that immediately yields a *computable, falsifiable* stability
statement testable on the existing `cloud₁`/`cloud₂` certificate.

### 5. Gromov–Hausdorff functoriality of the diameter representation.

The map `d ↦ diamFiltrationOf d` sends a distance matrix to a filtration. Promote
`vr_eStability` to a genuine `1`-Lipschitz statement between metric spaces:
`eInterleavingDist (diamFiltrationOf d₁) (diamFiltrationOf d₂) ≤ ofReal (supDist d₁ d₂)`,
and conjecture this descends to a `1`-Lipschitz map from the Gromov–Hausdorff
space of finite metric spaces into the interleaving-quotient space. **The key
insight is** that VR persistence is then literally a *short map* (a contraction in
the metric sense) from data-space to invariant-space, which is the precise,
category-theoretic form of "persistent homology is stable." **Why now?** The
single load-bearing estimate `diamWeightOf_dist_le` is already proved and the
target space `(Filtration α, eInterleavingDist)` is constructed this cycle; only
the GH-quotient packaging remains, turning a pointwise bound into a structural
functoriality theorem.
