
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   **Must be fully self-contained and publishable without any external
   references.** State every theorem, result, and definition inline —
   do NOT use @file references or point to other files. A reader with
   only this article must understand every result without looking elsewhere.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work.
   **Must be fully self-contained and publishable quality without any
   external references.** State every theorem, lemma, and definition
   inline with its full mathematical statement and proof sketch. Do NOT
   use @file references or reference other files. A reader with only this
   paper must be able to follow every result from start to finish.
3. **demo.py** — Numerical examples demonstrating the key results.
   Self-contained Python, type hints, all functions inlined.
4. **PACKAGE.json** — Single JSON bundling all of the above, with this schema:

```json
{
  "title": "Human-Readable Package Title",
  "domain": "Algebra|Applications|Bridges|Computation|Cryptography|EML|Geometry|Logic|MachineLearning|Novelty|Physics|Pythagorean|Shared|Tropical",
  "description": "1-2 sentence description of the package",
  "authors": ["Author Name"],
  "date": "YYYY-MM-DD",
  "key_results": ["Key result 1", "Key result 2"],
  "keywords": ["keyword1", "keyword2"],
  "article": "ARTICLE.md",
  "research_paper": "RESEARCH_PAPER.md",
  "demo": "demo.py",
  "demos": [
    {"name": "Descriptive and Professional Title of the Python Demo", "description": "A comprehensive, high-quality description of what this Python demo calculates and shows mathematically.", "code": "# full Python source..."}
  ],
  "algorithms": [
    {
      "name": "Formal Mathematical Title of the Algorithm",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
  ],
  "visualizations": [
    {"name": "Descriptive Visualization Title", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Beautiful Math-Rich Interactive Widget Title", "description": "Detailed description of the interactive widget and what users can explore.", "html": "<!DOCTYPE html><html>...</html>"}
  ],
  "lean_proofs": "LEAN_FILE_CONTENT_OR_PLACEHOLDER",
  "future_directions": "FUTURE_DIRECTIONS_CONTENT",
  "modules": {"demo": "# full demo.py source..."},
  "lean_files": ["Catalog/Domain/Package/File.lean"]
}
```

**CRITICAL**: The `demos`, `algorithms`, `visualizations`, and
`interactive_demos` fields MUST be arrays of objects with the
exact structure shown above. Do NOT use placeholder strings like
"MISSING" — either include real content or omit the field entirely.

### DO NOT OUTPUT:
- NO new `.lean` files
- NO new theorem proofs
- NO changes to the existing Lean 4 source
- NO `FUTURE_DIRECTIONS.md` as a separate file (Phase A already produced
  future directions — they are provided below for inclusion in PACKAGE.json)

The math is already proved. Treat the Lean files below as the
ground truth — your prose should explain and contextualize them.
State theorems inline in your article and paper — they must be
self-contained and publishable without external references.


## Concept

**Title**: The file `HodgeSpectralThreshold.lean` extracts a rigorous, sorry-free linear-al
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Spectral Depth Thresholds for Hodge-Laplacian Message Passing

## Synthesis

The file `HodgeSpectralThreshold.lean` extracts a rigorous, sorry-free linear-algebraic
skeleton from the (informal, ML-flavoured) conjecture *"Spectral Universality Threshold for
Hypergraph Neural Tangent Kernels on Simplicial Complexes."* We model one layer of
linearized / infinite-width message passing on `k`-cochains as the self-adjoint operator
`T = 1 - t·Δ`, where `Δ = up + down` is the abstract combinatorial **Hodge Laplacian** (the
sum of a positive-semidefinite upper Laplacian `δδ*` and lower Laplacian `d*d`). Depth-`L`
message passing is the iterate `Tᴸ`.

Two halves of the conjecture become theorems:

* **Topology is depth-invariant.** The harmonic subspace `ker Δ` — which by discrete Hodge
  theory is the cohomology of the complex — consists of *exact fixed points of `Tᴸ` at every
  depth* (`harmonic_depth_invariant`), and is characterised intrinsically as
  `ker Δ = ker up ⊓ ker down` (`harmonic_iff`, `ker_hodgeLaplacian`), with its orthogonal
  complement `T`-invariant (`harmonic_orthogonal_invariant`). The enabling lemma is the
  Hodge vanishing principle `⟪Δx,x⟫ = 0 ⇒ Δx = 0` for symmetric PSD operators
  (`psd_inner_self_eq_zero`).
* **Everything non-harmonic is geometrically suppressed.** After diagonalisation, the mode of
  eigenvalue `λ ≥ μ > 0` (spectral gap `μ`) evolves by `(1 - tλ)ᴸ ≤ (1 - tμ)ᴸ → 0`
  (`mode_decay`, `gap_mode_tendsto_zero`), giving the *explicit, spectrum-uniform depth
  threshold* `L_c` of `depth_threshold`: above `L_c` every non-harmonic mode of gap `≥ μ`
  is below any tolerance `ε`, while harmonic modes stay at amplitude `1`
  (`harmonic_mode_invariant`).

This is the precise, provable shadow of the conjectured topology-sensitive → topology-blind
phase transition: depth acts as a low-pass filter on the Hodge spectrum whose only fixed
amplitudes are the topological (harmonic) ones, and the transition scale is
`L_c ≈ log ε / log(1 - tμ)`, governed *explicitly* by the spectral gap as conjectured.

## Results summary

| Theorem | Statement |
|---|---|
| `psd_inner_self_eq_zero` | symmetric PSD + zero Dirichlet energy ⇒ operator kills the vector |
| `harmonic_iff` | `Δx = 0 ⇔ up x = 0 ∧ down x = 0` (harmonic = closed and coclosed) |
| `ker_hodgeLaplacian` | `ker Δ = ker up ⊓ ker down` (discrete Hodge harmonics) |
| `harmonic_depth_invariant` | `Δx = 0 ⇒ Tᴸ x = x` for all depths `L` |
| `harmonic_orthogonal_invariant` | `(ker Δ)ᗮ` is invariant under `T = 1 - t·Δ` |
| `mode_decay` | `(1 - tλ)ᴸ ≤ (1 - tμ)ᴸ` for `λ ≥ μ`, normalised step |
| `harmonic_mode_invariant` | harmonic (`λ = 0`) mode keeps amplitude `1` at all depths |
| `gap_mode_tendsto_zero` | `(1 - tμ)ᴸ → 0` as `L → ∞` |
| `depth_threshold` | explicit `L_c` suppressing all non-harmonic modes below `ε` uniformly |

All proofs depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research directions

### 1. Lift the scalar threshold to a uniform operator-norm contraction

We proved geometric decay *mode-by-mode*; the next step is the operator statement
`‖Tᴸ x − P_𝓗 x‖ ≤ (1 − tμ)ᴸ ‖x‖`, where `P_𝓗` is the orthogonal projection onto the
harmonic space `ker Δ`. This is exactly the convergence of depth-`L` message passing to the
harmonic projector, i.e. to cohomology.
**The key insight is** that on a finite-dimensional inner product space a symmetric `Δ`
orthogonally diagonalises, so `Tᴸ` is block-diagonal with the harmonic block equal to the
identity and the non-harmonic block of operator norm `≤ (1 − tμ)ᴸ`; the only nontrivial Lean
ingredient is that a product of commuting PSD self-adjoint operators is PSD (a square-root /
spectral-theorem argument).
**Why now?** Mathlib's `LinearMap.IsSymmetric.eigenvectorBasis` and the finite-dimensional
spectral theorem already provide the orthonormal eigenbasis and eigenvalue data, so the
bridge from our scalar lemmas (`mode_decay`, `gap_mode_tendsto_zero`) to the operator bound
is a packaging exercise rather than new analysis.

### 2. Make `L_c` a sharp two-sided threshold (lower bound on retained signal)

`depth_threshold` is the "above-threshold" half. The "below-threshold" half should assert
that for `L < L_c` a non-harmonic mode of eigenvalue `λ` with `tλ` small retains amplitude
`(1 − tλ)ᴸ ≥ 1 − Ltλ ≥ δ`, i.e. topological-vs-nonharmonic discriminability persists, giving
matching `Θ(log(1/ε)/(tμ))` upper and lower bounds on the critical depth.
**The key insight is** that `(1 − tλ)ᴸ` is monotone in both `λ` and `L`, so a single
Bernoulli-type inequality `(1 − a)ᴸ ≥ 1 − La` converts the gap `μ` and the largest eigenvalue
`λ_max` into a genuine *interval* `[L_-, L_+]` of "transitional" depths whose width is
controlled by the spectral spread `λ_max / μ`.
**Why now?** Both bounds are elementary real-analysis facts (`one_sub_le_pow`,
`pow_le_pow_left`) already adjacent to what we used; pairing them closes the conjecture's
"sharp threshold" clause at the eigenmode level with no new infrastructure.

### 3. A genuine sheaf/local-to-global formulation of the harmonic obstruction

Reformulate `ker Δ = ker up ⊓ ker down` as a local-to-global gluing statement: define a
cellular cosheaf of cochains on the face poset of the complex, with `down` the local
coboundary obstruction and `up` the local boundary obstruction; harmonic cochains are then
the *global sections that are simultaneously locally closed and locally coclosed*.
**The key insight is** that `harmonic_iff` is precisely a stalk-level reduction — global
harmonicity is detected by two independent local conditions — which is the defining shape of
a cohomological obstruction class `[Δx] ∈ H¹` vanishing.
**Why now?** This directly serves the engine's *Local-to-Global Sheaves* configuration and
connects to the catalog's `Catalog/Geometry/HodgeTheory/Filtration.lean`
(`recover_H11`, opposition), which already reconstructs harmonic pieces from local filtration
data; a discrete cosheaf layer would unify the continuous and combinatorial Hodge stories.

### 4. Topology-blindness as a quantitative two-family indistinguishability theorem

Formalize the conjecture's *refutable* core: given two complexes `X, X'` with identical local
face-degree statistics (hence identical non-harmonic spectral law in the universality regime)
but different cohomology dimensions `b ≠ b'`, prove that for `L > L_c` the centered iterated
kernels satisfy `‖(Tᴸ − P_𝓗)_X − (Tᴸ − P_𝓗)_{X'}‖ ≤ ε`, while for small `L` the difference is
bounded *below* by a function of `|b − b'|`.
**The key insight is** that the only depth-stable difference between the two kernels lives in
the harmonic blocks, whose ranks are `b` and `b'`; above threshold the non-harmonic parts
agree to `ε` (direction 1) and the harmonic parts are the *only* surviving discriminant,
making "topology-blindness" a precise rank-vs-tolerance trade-off.
**Why now?** Once direction 1 supplies the operator bound and `ker_hodgeLaplacian` pins the
harmonic rank to Betti numbers, this becomes a clean inequality between two block-diagonal
operators — the first fully formal, falsifiable version of the universality claim.

### 5. Polynomial (graph-filter) updates and the heat-kernel limit

Replace the affine layer `T = 1 − t·Δ` by an arbitrary polynomial filter `p(Δ)` (the
"polynomially local on `k`-faces" hypothesis) and identify the class of `p` for which the
threshold phenomenon survives, with the heat semigroup `e^{−tΔ}` as the continuous-depth
limit `(1 − (t/L)·Δ)ᴸ → e^{−tΔ}`.
**The key insight is** that the harmonic space is `ker Δ ⊆ ker(p(Δ) − p(0)·I)` for every
polynomial with `p(0) = 1`, so depth-invariance of topology is automatic for *all* such
filters, and the threshold is governed by `\sup_{λ ≥ μ} |p(λ)| < 1` — a single spectral
condition on the filter.
**Why now?** Mathlib has `Polynomial.aeval` on endomorphisms and the exponential
`NormedSpace.exp`; expressing depth as filter iteration generalises every theorem in the file
at once and pinpoints exactly which architectures are topology-preserving vs topology-erasing.

Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- DIFF: Catalog/Applications/SpeciesAnalyticBridge.lean
--- a/Applications/SpeciesAnalyticBridge.lean
+++ b/Applications/SpeciesAnalyticBridge.lean
@@ -62,14 +62,10 @@
 @[simp] lemma egf_seqOf (f : ℚ⟦X⟧) : egf (seqOf f) = f := by
   ext n; rw [coeff_egf, seqOf]; field_simp
 
--- NOTE (build fix): `egf_injective` is already declared in
--- `Catalog/Applications/CombinatorialSpecies.lean` in this same namespace, so re-declaring it
--- here is a duplicate declaration that breaks compilation.  Commented out; all references below
--- resolve to `CombinatorialSpecies.egf_injective` from the imported base file.
--- /-- **Complete invariance.** `egf` is injective: distinct counting sequences have distinct
--- exponential generating functions. -/
--- theorem egf_injective : Function.Injective egf := by
---   intro a b h; rw [← seqOf_egf a, ← seqOf_egf b, h]
+/-- **Complete invariance.** `egf` is injective: distinct counting sequences have distinct
+exponential generating functions. -/
+theorem egf_injective : Function.Injective egf := by
+  intro a b h; rw [← seqOf_egf a, ← seqOf_egf b, h]
 
 /-- **Surjectivity.** Every formal power series over `ℚ` is the EGF of some counting
 sequence (namely `seqOf`). -/



-- NEW_FILE: Catalog/Geometry/HodgeSpectralThreshold.lean
/-
# Spectral Depth Thresholds for Hodge-Laplacian Message Passing

A rigorous, sorry-free linear-algebraic skeleton for the conjecture
*"Spectral Universality Threshold for Hypergraph Neural Tangent Kernels on
Simplicial Complexes."*

We model one layer of linearized / infinite-width message passing on `k`-cochains
as the self-adjoint operator `T = 1 - t·Δ`, where `Δ = up + down` is the abstract
combinatorial **Hodge Laplacian** — the sum of a positive-semidefinite upper
Laplacian (`δδ*`) and a positive-semidefinite lower Laplacian (`d*d`).  Depth-`L`
message passing is the iterate `Tᴸ`.

Two halves of the conjecture become theorems:

* **Topology is depth-invariant.**  The harmonic subspace `ker Δ` (= cohomology, by
  discrete Hodge theory) consists of exact fixed points of `Tᴸ` at every depth, is
  characterised intrinsically as `ker Δ = ker up ⊓ ker down`, and its orthogonal
  complement is `T`-invariant.
* **Everything non-harmonic is geometrically suppressed.**  After diagonalisation a
  mode of eigenvalue `λ ≥ μ > 0` evolves by `(1 - tλ)ᴸ ≤ (1 - tμ)ᴸ → 0`, giving an
  explicit, spectrum-uniform depth threshold `L_c`.

-- !-- Lab Notebook -- !--
Hypothesis:  "Depth in Hodge-Laplacian message passing acts as a low-pass filter on
  the combinatorial spectrum whose only fixed amplitudes are the topological
  (harmonic) ones; the transition scale is set explicitly by the spectral gap."
Result:  Formalised and proved, with no finite-dimensionality assumption needed.
  `psd_inner_self_eq_zero` (Hodge vanishing), `harmonic_iff` / `ker_hodgeLaplacian`
  (harmonic = closed ∧ coclosed), `harmonic_depth_invariant` (exact fixed points at
  every depth), `harmonic_orthogonal_invariant` (T-invariance of `(ker Δ)ᗮ`),
  `mode_decay` / `gap_mode_tendsto_zero` / `depth_threshold` (uniform geometric
  suppression of non-harmonic modes), and `harmonic_mode_invariant` (harmonic modes
  stay at amplitude 1).
Insight:  The vanishing principle `⟪Δx,x⟫ = 0 ⇒ Δx = 0` for a symmetric PSD operator
  needs only a 1-parameter quadratic positivity argument (Cauchy–Schwarz for
  semidefinite forms), so the entire harmonic-side theory is dimension-free.  The
  spectral-gap side decouples completely into scalar real-analysis on `(1 - tμ)ᴸ`.
Failure analysis:  An earlier attempt phrased `T` via `LinearMap.id`, which left the
  scalar/identity type ambiguous on application; using the monoid identity `1` of
  `Module.End ℝ E` fixes elaboration.  The cross term in the quadratic expansion
  needs `real_inner_comm`, not just operator symmetry.
-- !-- Lab Notebook -- !--
-/
import Mathlib

open scoped InnerProductSpace BigOperators Topology

namespace HodgeSpectralThreshold

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-! ## The Hodge vanishing principle -/

/-
!-- comment: For a symmetric PSD operator `S`, the Dirichlet energy `⟪Sx,x⟫`
controls `S` via Cauchy–Schwarz for semidefinite forms, so zero energy kills `Sx`. -- !--

**Hodge vanishing principle.** If `S` is symmetric and positive semidefinite and
the Dirichlet energy `⟪S x, x⟫` vanishes, then `S x = 0`.
-/
theorem psd_inner_self_eq_zero (S : E →ₗ[ℝ] E)
    (hsymm : ∀ x y, ⟪S x, y⟫_ℝ = ⟪x, S y⟫_ℝ)
    (hpos : ∀ x, 0 ≤ ⟪S x, x⟫_ℝ)
    {x : E} (hx : ⟪S x, x⟫_ℝ = 0) : S x = 0 := by
  -- For every real s, by positivity hpos (x + s • y) ≥ 0. Expand using bilinearity and symmetry: ⟪S (x + s•y), x + s•y⟫_ℝ = ⟪S x, x⟫_ℝ + 2*s*⟪S x, y⟫_ℝ + s^2 * ⟪S y, y⟫_ℝ.
  have h_expand : ∀ s : ℝ, 0 ≤ 2 * s * ⟪S x, x⟫_ℝ + s^2 * ⟪S x, x⟫_ℝ := by
    aesop;
  contrapose! h_expand;
  -- By the properties of the inner product and the symmetry of $S$, we have $⟪S x, y⟫_ℝ = ⟪x, S y⟫_ℝ$ for all $y$.
  have h_inner_symm : ∀ y : E, ⟪S x, y⟫_ℝ = 0 := by
    intro y
    have h_inner_zero : ∀ s : ℝ, 0 ≤ 2 * s * ⟪S x, y⟫_ℝ + s^2 * ⟪S y, y⟫_ℝ := by
      intro s
      have := hpos (x + s • y)
      simp_all +decide [ inner_add_left, inner_add_right, inner_smul_left, inner_smul_right ];
      convert this using 1 ; rw [ ← hsymm ] ; ring;
      grind +suggestions;
    by_cases hy : ⟪S y, y⟫_ℝ = 0;
    · contrapose! h_inner_zero;
      exact ⟨ -1 / ⟪S x, y⟫_ℝ, by rw [ hy ] ; ring_nf; norm_num [ h_inner_zero ] ⟩;
    · nlinarith [ h_inner_zero ( -⟪S x, y⟫_ℝ / ⟪S y, y⟫_ℝ ), mul_div_cancel₀ ( -⟪S x, y⟫_ℝ ) hy, hpos y ];
  exact absurd ( h_inner_symm ( S x ) ) ( by simp +decide [ h_expand ] )

/-! ## Harmonic = closed and coclosed -/

variable (up down : E →ₗ[ℝ] E)

/-- The abstract combinatorial **Hodge Laplacian** `Δ = up + down`. -/
def hodgeLaplacian : E →ₗ[ℝ] E := up + down

/-
!-- comment: With `up, down` symmetric PSD, `⟪Δx,x⟫ = ⟪up x,x⟫ + ⟪down x,x⟫` is a
sum of nonnegatives, so it vanishes iff each does; apply the vanishing principle. -- !--

**Harmonic = closed ∧ coclosed.** A cochain is harmonic (`Δ x = 0`) iff it is both
in the kernel of the upper and the lower Laplacian.
-/
theorem harmonic_iff
    (hsymm_up : ∀ x y, ⟪up x, y⟫_ℝ = ⟪x, up y⟫_ℝ)
    (hpos_up : ∀ x, 0 ≤ ⟪up x, x⟫_ℝ)
    (hsymm_down : ∀ x y, ⟪down x, y⟫_ℝ = ⟪x, down y⟫_ℝ)
    (hpos_down : ∀ x, 0 ≤ ⟪down x, x⟫_ℝ)
    (x : E) :
    hodgeLaplacian up down x = 0 ↔ up x = 0 ∧ down x = 0 := by
  constructor <;> intro h;
  · -- By the properties of the inner product and the definition of the Hodge Laplacian, we have:
    have h_inner : ⟪up x, x⟫_ℝ + ⟪down x, x⟫_ℝ = 0 := by
      convert congr_arg ( fun y => ⟪y, x⟫_ℝ ) h using 1 <;> simp +decide [ *, hodgeLaplacian ];
      rw [ ← hsymm_up, ← hsymm_down, inner_add_left ];
    exact ⟨ psd_inner_self_eq_zero up hsymm_up hpos_up ( by linarith [ hpos_up x, hpos_down x ] ), psd_inner_self_eq_zero down hsymm_down hpos_down ( by linarith [ hpos_up x, hpos_down x ] ) ⟩;
  · unfold hodgeLaplacian; aesop;

/-
!-- comment: Pointwise rephrasing of `harmonic_iff` as an equality of submodules. -- !--

**Discrete Hodge harmonics.** `ker Δ = ker up ⊓ ker down`.
-/
theorem ker_hodgeLaplacian
    (hsymm_up : ∀ x y, ⟪up x, y⟫_ℝ = ⟪x, up y⟫_ℝ)
    (hpos_up : ∀ x, 0 ≤ ⟪up x, x⟫_ℝ)
    (hsymm_down : ∀ x y, ⟪down x, y⟫_ℝ = ⟪x, down y⟫_ℝ)
    (hpos_down : ∀ x, 0 ≤ ⟪down x, x⟫_ℝ) :
    LinearMap.ker (hodgeLaplacian up down)
      = LinearMap.ker up ⊓ LinearMap.ker down := by
  exact SetLike.ext fun x => by simpa using harmonic_iff up down hsymm_up hpos_up hsymm_down hpos_down x;

/-! ## Depth-`L` message passing and topology invariance -/

/-- One linearized message-passing layer `T = 1 - t·Δ` on cochains. -/
def layer (t : ℝ) : E →ₗ[ℝ] E := (1 : Module.End ℝ E) - t • hodgeLaplacian up down

@[simp] theorem layer_apply (t : ℝ) (x : E) :
    layer up down t x = x - t • (hodgeLaplacian up down x) := by
  simp [layer]

/-- Depth-`L` message passing is the `L`-fold iterate `Tᴸ`. -/
def depthMap (t : 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Spectral Depth Thresholds for Hodge-Laplacian Message Passing

## Synthesis

`Catalog/Geometry/HodgeSpectralThreshold.lean` extracts a rigorous, sorry-free
linear-algebraic skeleton from the (informal, ML-flavoured) conjecture *"Spectral
Universality Threshold for Hypergraph Neural Tangent Kernels on Simplicial
Complexes."* One layer of linearized / infinite-width message passing on `k`-cochains
is modelled as the self-adjoint operator `T = 1 - t·Δ`, where `Δ = up + down` is the
abstract combinatorial **Hodge Laplacian** (the sum of a positive-semidefinite upper
Laplacian `δδ*` and lower Laplacian `d*d`). Depth-`L` message passing is the iterate
`Tᴸ` (`depthMap`).

Two halves of the conjecture are now theorems, and — pleasingly — *no
finite-dimensionality hypothesis is needed* on the harmonic side:

* **Topology is depth-invariant.** The harmonic subspace `ker Δ` — which by discrete
  Hodge theory is the cohomology of the complex — consists of *exact fixed points of
  `Tᴸ` at every depth* (`harmonic_depth_invariant`), is characterised intrinsically as
  `ker Δ = ker up ⊓ ker down` (`harmonic_iff`, `ker_hodgeLaplacian`), and has
  `T`-invariant orthogonal complement (`harmonic_orthogonal_invariant`). The enabling
  lemma is the Hodge vanishing principle `⟪Δx,x⟫ = 0 ⇒ Δx = 0` for symmetric PSD
  operators (`psd_inner_self_eq_zero`), proved by a one-parameter quadratic-positivity
  (semidefinite Cauchy–Schwarz) argument.
* **Everything non-harmonic is geometrically suppressed.** A mode of eigenvalue
  `λ ≥ μ > 0` (spectral gap `μ`) evolves by `(1 - tλ)ᴸ ≤ (1 - tμ)ᴸ → 0`
  (`mode_decay`, `gap_mode_tendsto_zero`), giving the explicit, spectrum-uniform depth
  threshold `L_c` of `depth_threshold`: above `L_c` every non-harmonic mode of gap
  `≥ μ` is below any tolerance `ε`, while harmonic modes stay at amplitude `1`
  (`harmonic_mode_invariant`).

This is the precise, provable shadow of the conjectured topology-sensitive →
topology-blind phase transition: depth acts as a low-pass filter on the Hodge spectrum
whose only fixed amplitudes are the topological (harmonic) ones, and the transition
scale is `L_c ≈ log ε / log(1 - tμ)`, governed *explicitly* by the spectral gap.

## Results summary

| Theorem | Statement |
|---|---|
| `psd_inner_self_eq_zero` | symmetric PSD + zero Dirichlet energy ⇒ operator kills the vector |
| `harmonic_iff` | `Δx = 0 ⇔ up x = 0 ∧ down x = 0` (harmonic = closed and coclosed) |
| `ker_hodgeLaplacian` | `ker Δ = ker up ⊓ ker down` (discrete Hodge harmonics) |
| `harmonic_depth_invariant` | `Δx = 0 ⇒ Tᴸ x = x` for all depths `L` |
| `harmonic_orthogonal_invariant` | `(ker Δ)ᗮ` is invariant under `T = 1 - t·Δ` |
| `mode_decay` | `(1 - tλ)ᴸ ≤ (1 - tμ)ᴸ` for `λ ≥ μ`, normalised step |
| `harmonic_mode_invariant` | harmonic (`λ = 0`) mode keeps amplitude `1` at all depths |
| `gap_mode_tendsto_zero` | `(1 - tμ)ᴸ → 0` as `L → ∞` |
| `depth_threshold` | explicit `L_c` suppressing all non-harmonic modes below `ε
```

## Your task

Produce the deliverables listed above. The Lean file is the source of truth —
your prose must accurately explain it. Both ARTICLE.md and RESEARCH_PAPER.md
MUST be self-contained and publishable without referencing any external files.
State every theorem, definition, and result inline so a reader can follow the
entire argument from the document alone.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a clear, professional mathematical title in 'name' (do not use generic placeholders; this will be displayed as the header on the interactive site), a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. For each Python demo in the demos array, provide a highly descriptive title in 'name', a comprehensive functional description in 'description', and the implementation code in 'code'. For each interactive HTML demo in interactive_demos, provide a beautiful title in 'title' and a detailed description in 'description'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
