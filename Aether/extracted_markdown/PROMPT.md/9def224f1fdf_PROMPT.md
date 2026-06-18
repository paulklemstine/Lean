
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   Reference the specific theorems proved in Phase A using @file references.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work,
   references to catalog results. Use @file references for theorems.
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
    {"name": "descriptive_name", "description": "What this demo shows", "code": "# full Python source..."}
  ],
  "algorithms": [
    {"name": "descriptive_name", "pseudocode": "Brief description", "code": "# full Python source..."}
  ],
  "visualizations": [
    {"name": "descriptive_name", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Interactive Widget Title", "description": "What users can explore", "html": "<!DOCTYPE html><html>...</html>"}
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
Use the @file references above to point readers to specific theorems.


## Concept

**Title**: The geodesic equations for the split metric ds² = sech²(y) dx² + cosh²(x) dy² yi
**Domain**: Geometry
**Mathematical framing**: # Future Directions: Split Geometry

## 1. Geodesic Equations and Phase Boundary Crossing

The geodesic equations for the split metric ds² = sech²(y) dx² + cosh²(x) dy² yield a coupled ODE system via the Christoffel symbols. The key insight is that geodesics transitioning between the elliptic region (|x| < |y|, K > 0) and hyperbolic region (|x| > |y|, K < 0) must cross the phase boundary |x| = |y| where K = 0, and the curvature sign change constrains how many crossings are possible. A natural conjecture: geodesics in split geometry cross the phase boundary at most finitely many times, with the number of crossings bounded by a function of the initial energy. Why now? The curvature sign characterization (splitCurvature_pos_iff) provides the precise geometric partition needed to analyze geodesic behavior region-by-region, and Mathlib's ODE theory is now mature enough to formalize existence and uniqueness of geodesic flows.

## 2. Gauss-Bonnet for Split Triangles

For a geodesic triangle with vertices in different curvature regions, the Gauss-Bonnet theorem gives angle excess = ∫∫ K dA where dA = √(det g) dx dy = (cosh x / cosh y) dx dy. The key insight is that the integral of K = sech²(x) - sech²(y) over a region straddling the diagonal can be decomposed as a difference of two independent 1D integrals: ∫∫ K dA = ∫∫ sech²(x)·(cosh x/cosh y) dx dy - ∫∫ sech²(y)·(cosh x/cosh y) dx dy, each of which has a closed-form antiderivative involving tanh and sinh. This would yield explicit angle-excess formulas for split triangles — a concrete computational test of the geometry. Why now? The splitMetricDet_pos theorem guarantees the volume form is well-defined, and the bounded curvature (splitCurvature_bound) ensures convergence of area integrals over compact regions.

## 3. Generalized Split Metrics: The (α, β)-Family

Replace the split metric with ds² = cosh^α(y) dx² + cosh^β(x) dy² for parameters α, β ∈ ℝ. The original split metric corresponds to (α, β) = (-2, 2). The key insight is that the curvature of the (α,β)-metric is K(x,y) = f_α(y) + g_β(x) for explicit functions f_α, g_β, so the zero-curvature locus is always a curve of the form g_β(x) = -f_α(y), which is a level set of a separable function — making the phase boundary geometry analytically tractable for all parameter values. The conjecture is that for α < 0 < β, the phase boundary is always a pair of curves asymptotic to the diagonals, and for αβ > 0 the curvature has constant sign. Why now? The monotonicity machinery (cosh_sq_strictMonoOn, cosh_lt_cosh_iff_abs_lt) generalizes directly to cosh^n for integer n, and the antisymmetry theorem extends to the case α = -β.

## 4. Completeness and Incompleteness of Split Geometry

A Riemannian manifold is geodesically complete if every geodesic extends to all time. The key insight is that the split metric has anisotropic completeness: the metric component sech²(y) → 0 as |y| → ∞ (making horizontal distances shrink), while cosh²(x) → ∞ as |x| → ∞ (making vertical distances grow). This suggests that the split metric is complete in the y-direction but potentially incomplete in the x-direction, since a horizontal geodesic can "reach infinity in finite time" when the metric degenerates. A formal proof of incompleteness would establish split geometry as a natural example of a non-complete Riemannian surface with mixed-sign curvature. Why now? The metric positivity (splitG11_pos, splitG22_pos) and determinant bounds (splitMetricDet_ge_one_iff) provide the quantitative control needed to estimate geodesic lengths.

## 5. Spectral Theory of the Split Laplacian

The Laplace-Beltrami operator for the split metric is Δf = cosh²(y) ∂²f/∂x² + (1/cosh²(x)) ∂²f/∂y² (up to lower-order terms from Christoffel symbols). The key insight is that this operator separates variables: Δ(X(x)Y(y)) = cosh²(y)X''Y + Y''X/cosh²(x), and after dividing by XY one obtains two independent Sturm-Liouville problems with potentials involving cosh². This means the spectrum of the split Laplacian on bounded domains decomposes into tensor products of 1D spectra — each factor governed by a Pöschl-Teller-type potential with known exact solutions. Why now? The curvature bounds (-1 < K < 1) from splitCurvature_bound ensure the operator is uniformly elliptic on compact sets, and Mathlib's spectral theory for self-adjoint operators can handle the resulting eigenvalue problems.

Research domain: Geometry
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Physics/Classical/PhysicalPhenomena.lean
import Mathlib

/-! # CatalogBuild.Physics.Classical.PhysicalPhenomena

Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 13
-/

noncomputable section

/-- Surface area of a sphere of radius R: A = 4πR². -/
def sphereSurfaceArea (R : ℝ) : ℝ := 4 * Real.pi * R ^ 2

/-- [Section: # CatalogBuild.Physics.Classical.PhysicalPhenomena
Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 13] -/
theorem holographic_subvolumetric (R : ℝ) (hR : 1 < R) :
    sphereSurfaceArea R < sphereVolume R * 3 := by
  unfold sphereSurfaceArea sphereVolume;
  nlinarith [ Real.pi_pos, mul_lt_mul_of_pos_left hR Real.pi_pos, pow_pos ( zero_lt_one.trans hR ) 3 ]

/-- A quantum state over a finite-dimensional space is a unit vector
in the probability simplex (Born rule). We model it as probability amplitudes. -/
structure QuantumState (n : ℕ) where
  amplitudes : Fin n → ℂ
  normalized : ∑ i, Complex.normSq (amplitudes i) = 1

/-- Born rule: probability of measuring outcome i is |αᵢ|². -/
def bornProb {n : ℕ} (ψ : QuantumState n) (i : Fin n) : ℝ :=
  Complex.normSq (ψ.amplitudes i)

/-- Born probabilities sum to 1. -/
theorem born_prob_sum_one {n : ℕ} (ψ : QuantumState n) :
    ∑ i, bornProb ψ i = 1 := by
  simp [bornProb]
  exact ψ.normalized

/-- [Section: # CatalogBuild.Physics.Classical.PhysicalPhenomena
Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 13] -/
theorem measurement_is_oracle_query {n : ℕ} (ψ : QuantumState n)
    (i : Fin n) (hi : 0 < bornProb ψ i) :
    0 ≤ -Real.logb 2 (bornProb ψ i) := by
  rw [ neg_nonneg, logb_nonpos_iff ] <;> norm_num [ hi ];
  exact le_trans ( Finset.single_le_sum ( fun a _ => Complex.normSq_nonneg ( ψ.amplitudes a ) ) ( Finset.mem_univ i ) ) ( by norm_num [ ψ.normalized ] )

/-- Black hole entropy (Bekenstein-Hawking): S = A / (4 l_P²)
where A is the event horizon area and l_P is the Planck length. -/
def blackHoleEntropy (G M c ℏ : ℝ) : ℝ :=
  let R := schwarzschildRadius G M c
  let A := sphereSurfaceArea R
  let l_P_sq := ℏ * G / c ^ 3
  A / (4 * l_P_sq)

theorem bh_entropy_quadratic (G c ℏ : ℝ) (hG : 0 < G) (hc : 0 < c) (hℏ : 0 < ℏ)
    (M : ℝ) (hM : 0 < M) :
    blackHoleEntropy G (2 * M) c ℏ = 4 * blackHoleEntropy G M c ℏ := by
  unfold blackHoleEntropy
  unfold schwarzschildRadius
  unfold sphereSurfaceArea
  field_simp
  ring_nf at *

/-- The computational capacity of a region: maximum operations per second
bounded by E / (π ℏ) (Margolus-Levitin theorem). -/
def margolusLevitin (E ℏ : ℝ) : ℝ := E / (Real.pi * ℏ)

/-- The Lloyd bound: total computation performed by a system of energy E
in time t is at most 2Et / (π ℏ). -/
def lloydBound (E t ℏ : ℝ) : ℝ := 2 * E * t / (Real.pi * ℏ)

theorem lloyd_nonneg (E t ℏ : ℝ) (hE : 0 ≤ E) (ht : 0 ≤ t) (hℏ : 0 < ℏ) :
    0 ≤ lloydBound E t ℏ := by
  exact div_nonneg ( mul_nonneg ( mul_nonneg zero_le_two hE ) ht ) ( mul_nonneg Real.pi_pos.le hℏ.le )

/-- The three phenomena are unified by a single principle:
The universe processes I bits of information per unit time,
at an energy cost of at least I × kT ln 2.
This connects:
- Holographic principle (I is bounded by surface area)
- Landauer's principle (energy cost per bit)
- Lloyd bound (operations per second bounded by energy)
The chain: Surface Area → Max Info → Max Computation → Min Energy -/
def universalComputationBound (surfaceArea k_B T ℏ : ℝ) : ℝ :=
  let maxBits := holographicBound surfaceArea
  let minEnergy := maxBits * k_B * T * Real.log 2
  let maxOpsPerSec := margolusLevitin minEnergy ℏ
  maxOpsPerSec

theorem universal_bound_nonneg (A k_B T ℏ : ℝ)
    (hA : 0 ≤ A) (hk : 0 < k_B) (hT : 0 < T) (hℏ : 0 < ℏ) :
    0 ≤ universalComputationBound A k_B T ℏ := by
  apply div_nonneg;
  · exact mul_nonneg ( mul_nonneg ( mul_nonneg ( div_nonneg hA ( by positivity ) ) hk.le ) hT.le ) ( Real.log_nonneg ( by norm_num ) );
  · positivity

end


-- NEW_FILE: Catalog/Physics/V12_VariationalPrinciples.lean
import Mathlib

/-! # CatalogBuild.Speculative.OISCC.V12_VariationalPrinciples

Auto-generated from theorem catalog database.
Domain: Speculative/OISCC
Declarations: 15
-/

noncomputable section

/-- The EML potential. -/
def f_var (x : ℝ) : ℝ := Real.exp x - Real.log x - 1

/-- The Riemannian metric. -/
def g_var (x : ℝ) : ℝ := Real.exp x + x⁻¹ ^ 2

/-- The "kinetic energy" in the EML metric. -/
def kinetic (x v : ℝ) : ℝ := g_var x * v ^ 2 / 2

/-- The EML Lagrangian. -/
def lagrangian (x v : ℝ) : ℝ := kinetic x v - f_var x

/-- [Section: # CatalogBuild.Speculative.OISCC.V12_VariationalPrinciples
Auto-generated from theorem catalog database.
Domain: Speculative/OISCC
Declarations: 15] -/
theorem f_var_ge_one (x : ℝ) (hx : 0 < x) : f_var x ≥ 1 := by
  unfold f_var;
  nlinarith [ Real.add_one_le_exp x, Real.log_le_sub_one_of_pos hx ]

theorem f_var_pos (x : ℝ) (hx : 0 < x) : f_var x > 0 := by
  have := f_var_ge_one x hx
  linarith

theorem g_var_pos (x : ℝ) (hx : 0 < x) : g_var x > 0 := by
  exact add_pos_of_pos_of_nonneg ( Real.exp_pos _ ) ( sq_nonneg _ )

theorem kinetic_nonneg (x v : ℝ) (hx : 0 < x) : kinetic x v ≥ 0 := by
  exact div_nonneg ( mul_nonneg ( le_of_lt ( g_var_pos x hx ) ) ( sq_nonneg v ) ) zero_le_two

theorem kinetic_eq_zero_iff (x v : ℝ) (hx : 0 < x) :
    kinetic x v = 0 ↔ v = 0 := by
  unfold kinetic;
  norm_num [ g_var ];
  exact fun h => absurd h <| by positivity;

theorem lagrangian_at_rest (x : ℝ) (hx : 0 < x) :
    lagrangian x 0 = -f_var x := by
  unfold lagrangian kinetic f_var g_var; ring;

theorem lagrangian_at_rest_neg (x : ℝ) (hx : 0 < x) :
    lagrangian x 0 < 0 := by
  linarith [ lagrangian_at_rest x hx, f_var_pos x hx ]

/-- The "total energy" E = K + f is always ≥ 1 (positive energy theorem). -/
def total_energy (x v : ℝ) : ℝ := kinetic x v + f_var x

theorem total_energy_ge_one (x v : ℝ) (hx : 0 < x) :
    total_energy x v ≥ 1 := by
  exact le_add_of_nonneg_of_le ( kinetic_nonneg x v hx ) ( f_var_ge_one x hx )

theorem f_var_convexOn : ConvexOn ℝ (Ioi 0) f_var := by
  apply_rules [ convexOn_of_deriv2_nonneg, convex_Ioi ];
  · exact continuousOn_of_forall_continuousAt fun x hx => by exact ContinuousAt.sub ( ContinuousAt.sub ( Real.continuous_exp.continuousAt ) ( Real.continuousAt_log hx.out.ne' ) ) continuousAt_const;
  · exact DifferentiableOn.sub ( DifferentiableOn.exp differentiableOn_id ) ( DifferentiableOn.log differentiableOn_id fun x hx => ne_of_gt <| interior_subset hx ) |> DifferentiableOn.sub <| differentiableOn_const _;
  · -- The first derivative of $f(x)$ is $f'(x) = e^x - \frac{1}{x}$.
    have h_deriv : ∀ x ∈ Set.Ioi 0, deriv f_var x = Real.exp x - 1 / x := by
      intro x hx; unfold f_var; norm_num [ Real.differentiableAt_exp, hx.out.ne' ] ;
    exact DifferentiableOn.congr ( by exact DifferentiableOn.sub ( DifferentiableOn.exp differentiableOn_id ) ( DifferentiableOn.div ( differentiableOn_const _ ) differentiableOn_id fun x hx => ne_of_gt <| interior_subset hx ) ) fun x hx => h_deriv x <| interior_subset hx;
  · have h_deriv2 : ∀ x > 0, deriv^[2] (fun x => Real.exp x - Real.log x - 1) x = Real.exp x + 1 / x^2 := by
      have h_deriv2 : ∀ x > 0, deriv^[2] (fun x => Real.exp x - Real.log x - 1) x = deriv (fun x => Real.exp x - 1 / x) x := by
        exact fun x x_pos => Filter.EventuallyEq.deriv_eq ( by filter_upwards [ lt_mem_nhds x_pos ] with y hy using by norm_num [ Real.differentiableAt_exp, Real.differentiableAt_log, hy.ne' ] );
      intro x hx; rw [ h_deriv2 x hx ] ; norm_num [ Real.differentiableAt_exp, differentiableAt_inv, hx.ne' ];
    exact fun x hx => h_deriv2 x ( interior_subset hx ) ▸ add_nonneg ( Real.exp_nonneg x ) ( one_div_nonneg.mpr ( sq_nonneg x ) )

theorem f_var_orbit_growth (x : ℝ) (hx : 0 < x) :
    f_var (Real.exp x - Real.log x) > f_var x := by
  unfold f_var;
  -- Let $y = \exp(x) - \log(x)$.
  set y : ℝ := Real.exp x - Real.log x;
  -- Since $y > x$, we have $y > 1$.
  have hy_gt_one : 1 < y := by
 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Split Geometry Curvature

## Synthesis

This cycle established the foundational curvature theory of the split metric ds² = sech²(y) dx² + cosh²(x) dy² on ℝ². We defined the Gaussian curvature K(x,y) = 1/cosh²(x) - 1/cosh²(y) and proved four main structural theorems: antisymmetry K(x,y) = -K(y,x), the phase boundary characterization K = 0 ↔ |x| = |y|, the curvature sign characterization K > 0 ↔ |x| < |y| (and its negative counterpart), and the uniform curvature bound |K| < 1.

The key technical challenge was proving the injectivity of 1/cosh² modulo absolute value, which required reducing cosh equality to exponential equations via `Real.cosh_eq` and solving the resulting algebraic system. The monotonicity lemmas from Mathlib (`cosh_lt_cosh`, `cosh_le_cosh`) were essential for the sign characterization. The curvature bound followed cleanly from the pointwise bounds 0 < 1/cosh² ≤ 1.

What emerged structurally: the split metric is a rare explicit example of a complete diagonal metric with mixed-sign curvature, where the curvature sign is determined by a simple geometric condition (which coordinate has larger absolute value). The antisymmetry under coordinate exchange and the separability K = f(x) - f(y) are the root causes of all the clean characterizations.

## Results Summary

| Theorem | Status | Significance |
|---------|--------|-------------|
| `splitCurvature_antisymm` | proved | K(x,y) = -K(y,x): the Z₂ symmetry exchanging elliptic/hyperbolic regions |
| `splitCurvature_zero_iff` | proved | K = 0 ↔ \|x\| = \|y\|: phase boundary is the pair of diagonals y = ±x |
| `splitCurvature_pos_iff` | proved | K > 0 ↔ \|x\| < \|y\|: elliptic region characterized by y-dominance |
| `splitCurvature_bound` | proved | \|K\| < 1: uniform strict bound, sharp but never attained |
| `splitCurvature_neg_iff` | proved | K < 0 ↔ \|y\| < \|x\|: derived from antisymmetry + positivity |
| `splitMetricDet_pos` | proved | det(g) > 0: the metric is non-degenerate everywhere |
| `splitCurvature_origin` | proved | K(0,0) = 0: the origin lies on the phase boundary |

## Research Directions

### Direction 1: Christoffel Symbols and Geodesic Equations

**Hypothesis**: The Christoffel symbols of the split metric can be computed explicitly, yielding a coupled ODE system ẍ = F(x, y, ẋ, ẏ), ÿ = G(x, y, ẋ, ẏ) where F and G involve only tanh and sech. Geodesics crossing the phase boundary |x| = |y| do so at most finitely many times for any initial condition with bounded energy.

**Test**: Compute Γ^k_{ij} for the split metric (6 independent symbols for a 2D diagonal metric), formalize them in Lean, and verify they satisfy the standard symmetry and metric-compatibility conditions. Then analyze the geodesic flow qualitatively.

**Why now**: The curvature sign characterization (splitCurvature_pos_iff) gives the precise geometric partition, and the curvature bound (splitCurvature_bound) provides the uniform ellipticity needed for ODE existence theory.

**If true**:
```

## Your task

Produce the deliverables listed above. Reference the specific theorems and
results in the Lean code by their @file path and statement. The Lean file is
the source of truth — your prose must accurately explain it.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). Include future directions from Phase A
in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
