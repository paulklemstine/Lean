# Future Directions: Persistent Homology Stability

This cycle formalized the order-theoretic engine of the persistent-homology stability
theorem in `Catalog/Computation/PersistentHomologyStability.lean`: filtrations, the
sublevel-set construction, the ε-interleaving relation (symmetry, reflexivity at 0,
monotonicity in ε, and additive composition), the geometric stability inequality
`sublevel_stability`, the interleaving distance as an `ℝ≥0∞`-valued pseudometric
(`interleavingDist_self`, `interleavingDist_comm`, `interleavingDist_triangle`), and the
Vietoris–Rips application `rips_stability` with a concrete 3-point-cloud verification
`rips_example`. The following directions extend that foundation toward the full
Bauer–Lesnick isometry theorem and a verified TDA pipeline.

## 1. The algebraic stability / isometry theorem: `d_bottleneck ≤ d_interleaving`

**Conjecture.** Define persistence modules as functors from `(ℝ, ≤)` to finite-dimensional
vector spaces, their persistence diagrams as multisets of intervals, and the bottleneck
distance via optimal partial matchings. Then for any two q-tame modules,
`bottleneckDist (dgm M) (dgm N) ≤ interleavingDist M N`, with equality (the isometry
theorem) in the q-tame case.

**The key insight is** that our `Interleaved.comp` additive composition law is the *only*
structural input the bottleneck-side argument needs once interleavings are lifted from
sublevel filtrations to the induced persistence modules through a functor; the matching is
then built level-set by level-set from the interleaving morphisms, so the proof reduces to
the linear-algebra "box lemma" / rank-function bookkeeping rather than to geometry.

**Why now?** The interleaving layer (`Interleaved`, `interleavingDist`, triangle inequality)
is already proved sorry-free, so the remaining work is purely the diagram/matching side,
which can reuse Mathlib's `Multiset` and matching infrastructure without reformalizing the
metric backbone.

## 2. Functoriality: persistent homology turns ε-interleaved filtrations into ε-interleaved modules

**Conjecture.** For any homology functor `H_k` and filtrations `F, G`, if `Interleaved ε F G`
then the induced persistence modules `H_k ∘ F` and `H_k ∘ G` are ε-interleaved as modules,
so `interleavingDist (H_k F) (H_k G) ≤ interleavingDist F G`.

**The key insight is** that interleaving is defined purely by inclusions `F t ⊆ G (t+ε)`,
which any functor sends to module morphisms commuting with the structure maps; the two
shift-triangles witnessing `Interleaved` map *verbatim* to the two module-level triangles,
so functoriality is a diagram chase, not new analysis.

**Why now?** Our `Filtration` and `Interleaved` are already phrased through monotone set
maps, exactly the data a functor consumes; combined with Direction 1 this gives the
complete `point cloud → diagram` stability chain with no remaining geometric gap.

## 3. Gromov–Hausdorff control of the Vietoris–Rips interleaving

**Conjecture.** For two finite metric spaces `X, Y`, there is a correspondence realizing
`2 · d_GH(X, Y) = ε` such that the Rips filtrations satisfy `Interleaved ε (rips X) (rips Y)`
on the (co)product index, hence `interleavingDist (rips X) (rips Y) ≤ 2 d_GH(X, Y)`.

**The key insight is** that an optimal correspondence with distortion `η` makes the
pairwise-distance functions differ by at most `η = 2 d_GH`, so the abstract
`sublevel_stability` / `rips_stability` already proved here applies once the two metrics
are transported to a common index set via the correspondence — the GH distance only enters
through the uniform-distortion bound `|d_X - d_Y| ≤ 2 d_GH`.

**Why now?** `rips_stability` reduces GH-stability to a sup-norm bound on a single shared
index type; the missing piece is just constructing the common index from a correspondence,
a finite combinatorial step well within reach of the current `Fin`-indexed machinery.

## 4. A computable, verified persistence pipeline over `ℚ`

**Conjecture.** Over `ℚ`-valued distances the edge-Rips filtration admits a `Decidable`
membership relation and a computable interleaving certificate, so that for explicit finite
point clouds the bound `interleavingDist (ripsEdges d) (ripsEdges d') ≤ ε` can be discharged
by `decide`/`native_decide` rather than by interactive `norm_num`.

**The key insight is** that interleaving at a *fixed rational* `ε` is a finite conjunction of
decidable inequalities over `ι × ι`, so the whole stability certificate becomes a finite
Boolean check once distances live in a decidable ordered field.

**Why now?** `rips_example` already verifies one concrete instance by hand; replacing reals
with `ℚ` turns the per-instance verification into an algorithm, the first step toward a
formally certified TDA library usable on real datasets.

## 5. Persistence landscapes and an L∞ stability sharpening

**Conjecture.** Define the persistence landscape `λ_k : ℕ × ℝ → ℝ` of a filtration and prove
the Lipschitz stability `‖λ(F) - λ(G)‖_∞ ≤ interleavingDist F G`, giving a Hilbert-space
embedding of persistence diagrams compatible with our interleaving pseudometric.

**The key insight is** that the landscape's `k`-th layer is a max-min of tent functions whose
arguments shift by exactly `ε` under an ε-interleaving, so the same additive-shift bookkeeping
behind `Interleaved.mono_eps` controls the sup-norm of the landscape difference directly.

**Why now?** Landscapes need only the rank/interleaving data already formalized, and an
`ℝ`-valued, sup-norm statement sidesteps the multiset-matching machinery of the bottleneck
distance — making it the lowest-friction route to a second, independent stability theorem in
this file's framework.
