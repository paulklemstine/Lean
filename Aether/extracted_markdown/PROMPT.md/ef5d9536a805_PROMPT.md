
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

**Title**: The previous cycles established two layers of the spectral-depth picture for
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Hodge–Laplacian Message Passing, Deep-Limit Cycle

## Synthesis

The previous cycles established two layers of the spectral-depth picture for
Hodge-Laplacian message passing. `HodgeSpectralThreshold.lean` proved that the
harmonic (cohomology) subspace is an exact, depth-invariant fixed set and that every
non-harmonic mode is geometrically suppressed (`depth_threshold`).
`HodgeMessagePassingConvergence.lean` upgraded *energy decay* to a *convergence-below-ε*
statement (`mpStep_converges_to_harmonic`) and identified the optimal spectral step.
`HodgeThreeWayDecomposition.lean` / `HodgeFullDecomposition.lean` supplied the static
algebraic backbone (`V = coexact ⊕ exact ⊕ harmonic`, the discrete Hodge theorem).

This cycle (`HodgeDeepLimit.lean`) closes the gap between *"the residual gets small"*
and *"the network computes a canonical object"*. Its results are:

1. **A corrected, honest contraction hypothesis.** The prior cycle's contraction
   "for all `x`" is, with rate `ρ < 1`, only satisfiable when `ker L = 0` — it secretly
   trivializes the very harmonics it is meant to preserve. We replace it with a strict
   contraction *only on the residual subspace* `(ker L)ᗮ`, prove that subspace is
   invariant under one layer for symmetric `L` (`mpStep_mem_orthogonal`,
   `mpStep_iterate_mem_orthogonal`), and recover the geometric `ρᵏ` residual decay
   (`mpStep_iterate_contraction_orthogonal`).

2. **Vector convergence to the cohomology projection.** Depth-`k` message passing on any
   input converges *in norm* (not merely in energy) to the orthogonal projection onto
   the harmonic subspace (`mpStep_iterate_tendsto_harmonic`,
   `mpStep_deep_limit_eq_cohomology_projection`). Deep Hodge message passing **is** the
   cohomology projector. The bridge `hodge_deep_limit_is_harmonic_projection`
   instantiates this at the abstract combinatorial Hodge Laplacian `Δ = up + down`.

3. **A constructive, logarithm-free critical depth.** The non-constructive `∃ K` is
   replaced by an explicit closed-form stopping rule `criticalDepth ρ R ε`, proved
   correct (`criticalDepth_energy_bound`) via a Bernoulli bound — no logarithms,
   rational arithmetic only.

## Results Summary

| Theorem | Statement |
|---|---|
| `mpStep_mem_orthogonal` | `(ker L)ᗮ` is invariant under one layer `T = 1 - αL` (symmetric `L`). |
| `mpStep_iterate_mem_orthogonal` | Residual subspace invariance persists at every depth. |
| `mpStep_iterate_contraction_orthogonal` | Residual energy decays as `ρᵏ ⟪r,r⟫` under subspace contraction. |
| `mpStep_iterate_tendsto_harmonic` | `Tᵏ(h+r) → h` in norm for `L h = 0`, `r ∈ (ker L)ᗮ`. |
| `mpStep_deep_limit_eq_cohomology_projection` | In finite dimension, `Tᵏ x → πₖₑᵣ ₗ x` for every input `x`. |
| `criticalDepth_energy_bound` | The explicit log-free depth drives residual energy below `ε`. |
| `hodge_deep_limit_is_harmonic_projection` | Deep simplicial message passing at `Δ = up + down` computes the harmonic projection. |

All depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. The deep limit is a *bona fide* idempotent: `T^∞ = πₖₑᵣ ₗ` as an operator identity

We proved pointwise convergence `Tᵏ x → π x`. The next step is to promote this to an
operator-norm statement: under a uniform spectral gap on `(ker L)ᗮ`, the iterates `Tᵏ`
converge in operator norm to the orthogonal projection `π`, and the limit satisfies the
idempotent law `π² = π`, `π = π*`. The key insight is that the residual subspace is not
just invariant but a *uniform* `ρ`-contraction, so `‖Tᵏ − π‖ ≤ ρᵏ`; the projector
emerges as a genuine Banach-space limit of the layer monoid, not merely as a target of
orbits. Why now? `mpStep_iterate_contraction_orthogonal` already gives the per-orbit
`ρᵏ` bound uniformly in `r`; turning a uniform pointwise bound into an operator-norm
bound is exactly `ContinuousLinearMap.opNorm_le_bound` over a finite-dimensional space,
so the analytic infrastructure is now in place.

### 2. From assumed gap to *derived* gap: existence of `ρ < 1` from `μ > 0`

Currently the contraction rate `ρ` is a hypothesis. For symmetric PSD `L` with smallest
nonzero Rayleigh value `μ > 0` and largest `λ`, the spectral step `α = 1/λ` should
*produce* a valid `ρ = 1 - μ/λ < 1` on `(ker L)ᗮ`, discharging `hcontract` entirely.
The key insight is that `contraction_factor_at_optimal` (previous cycle) already pins the
factor to `1 - μ/λ`; what remains is to show the Rayleigh lower bound `μ⟪x,x⟫ ≤ ⟪x,Lx⟫`
holds on `(ker L)ᗮ` for finite-dimensional symmetric PSD `L`, i.e. that the smallest
nonzero eigenvalue is attained. Why now? Mathlib's finite-dimensional spectral theorem
(`LinearMap.IsSymmetric.eigenvalue…`, `inner_map_self_eq…`) makes the eigenvalue-attained
statement reachable, and combining it with this cycle's convergence theorem would yield a
fully hypothesis-free "deep message passing computes cohomology" theorem.

### 3. Quantitative cohomology recovery: explicit depth as a function of the spectral gap

`criticalDepth` is stated in terms of the abstract rate `ρ`. Substituting the derived
rate `ρ = 1 - μ/λ` from Direction 2 yields a depth bound purely in terms of the spectral
gap `μ`, the top eigenvalue `λ`, the input norm and the tolerance — an end-to-end,
checkable complexity estimate for recovering the `k`-th Betti class. The key insight is
that the Bernoulli argument behind `criticalDepth_energy_bound` is *uniform in `ρ`*, so
plugging in `1 - μ/λ` is a literal substitution, not a new proof. Why now? With Direction
2 supplying `ρ`, this becomes a one-line corollary that converts a spectral invariant of
the complex into a concrete, falsifiable layer count — testable against numerical
simplicial-complex experiments.

### 4. Robustness: convergence under a perturbed or noisy layer `T + Eₖ`

Real message passing uses approximate, possibly stochastic, Laplacians. Conjecture: if
each layer is `T + Eₖ` with `Σ ‖Eₖ‖ < ∞` (summable perturbations) and the unperturbed
`T` contracts `(ker L)ᗮ` by `ρ < 1`, then the perturbed orbit still converges, to a point
within `O(Σ‖Eₖ‖/(1−ρ))` of the true harmonic projection. The key insight is that the
geometric `ρᵏ` decay proved here gives an absolutely convergent telescoping series for the
perturbation error, so the limit exists and is Lipschitz-stable in the perturbation
stream. Why now? The clean `ρᵏ` residual bound (`mpStep_iterate_contraction_orthogonal`)
is precisely the summability engine such a perturbation argument needs; without it the
error series would not visibly converge.

### 5. Higher-order / multi-step layers and acceleration: does a polynomial `p(L)` beat `1 − αL`?

The layer `1 − αL` is the degree-1 polynomial filter. Conjecture: a Chebyshev-type
degree-`d` polynomial layer `p_d(L)` (still fixing `ker L` pointwise) achieves residual
contraction `ρ_d = ρ^{≈d}` per layer at the same harmonic-preservation guarantee, giving
a provable depth speedup. The key insight is that *any* real polynomial `p` with
`p(0) = 1` fixes `ker L` (since `p(L)h = p(0)h = h` when `Lh = 0`), so the entire
invariance/decomposition scaffold of this file transfers verbatim, and only the scalar
contraction factor changes. Why now? The harmonic-fixed-point lemmas here are stated for a
general linear `T` fixing `ker L`, not specifically for `1 − αL`, so generalizing to
`p(L)` requires re-deriving only the one scalar Rayleigh estimate — the structural
theorems are already polynomial-agnostic.

Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/HodgeEPolynomial.lean
/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# The Hodge–Deligne E-polynomial as a Bridge to Arithmetic

This file introduces the two-variable **Hodge–Deligne E-polynomial**
`E(X; u, v) = Σ_{p,q} (-1)^{p+q} h^{p,q} uᵖ vᵍ`
on an abstract `HodgeDiamond` structure and proves two genuine *functional equations*:

* `epoly_serre_functional_equation` — the Serre/Poincaré duality equation
  `E(X; u, v) = (uv)ⁿ E(X; 1/u, 1/v)` (under Serre duality of `X`);
* `epoly_mirror_functional_equation` — the mirror equation
  `E(mirror X; u, v) = (-1)ⁿ uⁿ E(X; 1/u, v)` (unconditionally).

Specialising at `u = v = 1` recovers `eulerChar_mirror_sign`, the statement that the
topological Euler characteristic of the mirror diamond is `(-1)ⁿ` times the original.
We also record `totalDim_mirror` (the total Hodge dimension is mirror-invariant) and
upgrade the mirror involution to Calabi–Yau data (`CalabiYauData.mirror`).

This is a *duality / representation* bridge: it translates the geometric mirror
involution `(p,q) ↦ (n-p, q)` and Serre duality `(p,q) ↦ (n-p, n-q)` into algebraic
symmetries (functional equations) of a single polynomial invariant.

-- !-- Lab Notebook -- !--
Hypothesis: The numerical mirror sign `χ(mirror X) = (-1)ⁿ χ(X)` is the `u=v=1`
  shadow of a polynomial-level functional equation in the Hodge–Deligne E-polynomial.
Result: Both the Serre/Poincaré and mirror functional equations are formalised over an
  arbitrary field `K`, and the numerical Euler-characteristic sign and total-dimension
  invariance are recovered as corollaries (the former literally by specialising the
  E-polynomial at `u = v = 1`, see `epoly_one_one_eq_eulerChar`).
Insight: Both geometric involutions are *reflections* `j ↦ n - j` on the index range,
  so `Finset.sum_range_reflect` is the single combinatorial engine behind all the
  functional equations; the `(-1)ⁿ` and `(uv)ⁿ` prefactors are exactly the bookkeeping
  of the parity shift `(-1)^{(n-p)+(n-q)} = (-1)^{2n}·(-1)^{p+q}` and the exponent shift
  `uⁿ · u⁻ᵖ = u^{n-p}`.
Failure analysis: Defining `h` on all of `ℕ × ℕ` (rather than `Fin (n+1)²`) means the
  mirror involution `mirror ∘ mirror = id` only holds on the support `p, q ≤ n`; we
  therefore state the involution at the level of the E-polynomial / pointwise on the
  support (`mirror_mirror_h`, `epoly_mirror_mirror`) rather than as a definitional
  equality of structures.
-/

namespace HodgeEPolynomial

open Finset

/-- An abstract **Hodge diamond**: a complex dimension `n` together with the Hodge
numbers `h^{p,q}`. We store `h` as a function on all of `ℕ × ℕ`; only the values with
`p, q ≤ n` are mathematically meaningful (the rest are treated as padding). -/
structure HodgeDiamond where
  /-- The complex dimension. -/
  n : ℕ
  /-- The Hodge numbers `h^{p,q}`. -/
  h : ℕ → ℕ → ℤ

namespace HodgeDiamond

/-- The **mirror** diamond, implementing the involution `(p,q) ↦ (n-p, q)` on Hodge
numbers (the combinatorial avatar of mirror symmetry exchanging complex and Kähler
moduli). -/
def mirror (X : HodgeDiamond) : HodgeDiamond where
  n := X.n
  h := fun p q => X.h (X.n - p) q

@[simp] lemma mirror_n (X : HodgeDiamond) : X.mirror.n = X.n := rfl

@[simp] lemma mirror_h (X : HodgeDiamond) (p q : ℕ) :
    X.mirror.h p q = X.h (X.n - p) q := rfl

/-- **Serre duality** for a Hodge diamond: `h^{p,q} = h^{n-p, n-q}` on the support. -/
def SerreDual (X : HodgeDiamond) : Prop :=
  ∀ p q, p ≤ X.n → q ≤ X.n → X.h p q = X.h (X.n - p) (X.n - q)

variable {K : Type*} [Field K]

/-- The **Hodge–Deligne E-polynomial** `E(X; u, v) = Σ_{p,q} (-1)^{p+q} h^{p,q} uᵖ vᵍ`,
evaluated in an arbitrary field `K`. -/
def EPoly (X : HodgeDiamond) (u v : K) : K :=
  ∑ p ∈ range (X.n + 1), ∑ q ∈ range (X.n + 1),
    (-1) ^ (p + q) * (X.h p q : K) * u ^ p * v ^ q

/-- The topological **Euler characteristic** `χ(X) = Σ_{p,q} (-1)^{p+q} h^{p,q}`. -/
def eulerChar (X : HodgeDiamond) : ℤ :=
  ∑ p ∈ range (X.n + 1), ∑ q ∈ range (X.n + 1), (-1) ^ (p + q) * X.h p q

/-- The **total Hodge dimension** `Σ_{p,q} h^{p,q}` (the total Betti number). -/
def totalDim (X : HodgeDiamond) : ℤ :=
  ∑ p ∈ range (X.n + 1), ∑ q ∈ range (X.n + 1), X.h p q

/-- Specialising the E-polynomial at `u = v = 1` recovers the Euler characteristic. -/
-- !-- E(X;1,1) collapses each monomial to its sign times `h^{p,q}`; push the ℤ→K cast
-- through the double sum. -- !--
theorem epoly_one_one_eq_eulerChar (X : HodgeDiamond) :
    EPoly X (1 : K) 1 = (X.eulerChar : K) := by
  unfold HodgeDiamond.EPoly HodgeDiamond.eulerChar; simp +decide [ mul_assoc, mul_comm, mul_left_comm, pow_add ] ;

/-- **Mirror functional equation.** `E(mirror X; u, v) = (-1)ⁿ uⁿ E(X; 1/u, v)`. -/
-- !-- Pull the prefactor `(-1)ⁿ uⁿ` into the double sum, then reflect the `p`-index via
-- `sum_range_reflect`; `uⁿ · (u⁻¹)ᵖ = u^{n-p}` and the parity shift `(-1)^{(n-p)+q}` match. -- !--
theorem epoly_mirror_functional_equation (X : HodgeDiamond) (u v : K) (hu : u ≠ 0) :
    EPoly X.mirror u v = (-1) ^ X.n * u ^ X.n * EPoly X u⁻¹ v := by
  simp +decide only [EPoly];
  simp +decide [ hu, Finset.mul_sum _ _ _, mul_assoc, mul_left_comm, mul_pow, Finset.sum_mul ];
  refine' Finset.sum_bij ( fun p hp => X.n - p ) _ _ _ _ <;> simp_all +decide [ Nat.sub_sub_self, Finset.mem_range_succ_iff ];
  · exact fun a₁ ha₁ a₂ ha₂ h => by rw [ tsub_right_inj ] at h <;> linarith;
  · exact fun b hb => ⟨ X.n - b, Nat.sub_le _ _, Nat.sub_sub_self hb ⟩;
  · intro a ha; refine' Finset.sum_congr rfl fun x hx => _; rw [ show u ^ a = u ^ X.n / u ^ ( X.n - a ) by rw [ eq_div_iff ( pow_ne_zero _ hu ), ← pow_add, Nat.add_sub_of_le ha ] ] ; ring;
    rw [ show ( -1 : K ) ^ X.n = ( -1 : K ) ^ ( X.n - a ) * ( -1 : K ) ^ a by rw [ ← pow_add, Nat.sub_add_cancel ha ] ] ; ring;
    norm_num [ pow_mul' ]

/-- **Serre/Poincaré functional equation.** Under Serre duality,
`E(X; u, v) = (uv)ⁿ E(X; 1/u, 1/v)`. -/
-- !-- Derive from the mirror equation applied to `mirror X`: reflect both indices via
-- `sum_range_reflect`, then use Serre duality `h^{p,q} = h^{n-p,n-q}` and `(-1)^{2n} = 1`. -- !--
theorem epoly_serre_functional_equation (X : HodgeDiamond) (hX : X.SerreDual)
    (u v : K) (hu : u ≠ 0) (hv : v ≠ 0) :
    EPoly X u v = (u * v) ^ X.n * EPoly X u⁻¹ v⁻¹ := by
  convert epoly_mirror_functional_equation ( X.mirror ) u v hu using 1;
  · unfold HodgeDiamond.EPoly;
    congr! 3;
    grind +suggestions;
  · simp +decide [ HodgeDiamond.mirror, pow_add, mul_pow, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul, EPoly ];
    refine' Finset.sum_congr rfl fun i hi => _;
    rw [ ← Finset.sum_flip ];
    refine' Finset.sum_congr rfl fun j hj => _;
    have := hX i ( X.n - j ) ( by linarith [ Finset.mem_range.mp hi ] ) ( by linarith [ Finset.mem_range.mp hj, Nat.sub_le X.n j ] ) ; simp_all +decide [ Nat.sub_sub_self ( show j ≤ X.n from by linarith [ Finset.mem_range.mp hj ] ) ] ;
    rw [ show v ^ X.n = v ^ ( X.n - j ) * v ^ j by rw [ ← pow_add, Nat.sub_add_cancel hj ] ] ; ring;
    rw [ show X.n = j + ( X.n - j ) by rw [ Nat.add_sub_of_le hj ] ] ; ring;
    simp +decide [ mul_left_comm ( v ^ ( X.n - j ) ), mul_assoc, hv ]

/-- **Numerical mirror sign.** `χ(mirror X) = (-1)ⁿ χ(X)`. This is the `u = v = 1`
specialisation of `epoly_mirror_functional_equation`. -/
-- !-- Reflect the `p`-index in the definition of `eulerChar`; the parity shift
-- `(-1)^{(n-p)+q} = (-1)ⁿ (-1)^{p+q}` produces the global sign. -- !--
theorem eulerChar_mirror_sign (X : HodgeDiamond) :
    X.mirror.eulerChar = (-1) ^ X.n * X.eulerChar := by
  unfold HodgeDiamond.eulerChar HodgeDiamond.mirror;
  simp +decide only [mul_sum _ _ _];
  refine' Finset.sum_bij ( fun p hp => X.n - p ) _ _ _ _ <;> simp_all +decide;
  · intros; omega;
  · exact fun b hb => ⟨ X.n - b, Nat.sub_le _ _, Nat.sub_sub_self hb ⟩;
  · intro a ha; refine' Finset.sum_congr rfl fun x hx => _; rw [ show ( -1 : ℤ ) ^ X.n = 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Hodge–Laplacian Message Passing, Post Deep-Limit Cycle

## Synthesis

This cycle (`HodgeDeepLimit.lean`) closed the loop from *"the residual energy gets
small"* to *"the network computes a canonical object"*. The earlier cycles had two
gaps. First, the convergence cycle assumed a contraction "for all `x`", which at a
rate `ρ < 1` is only satisfiable when `ker L = 0`: a harmonic `h` is a fixed point,
so `⟪Th, Th⟫ = ⟪h, h⟫ ≤ ρ ⟪h, h⟫` forces `h = 0`, secretly trivialising the very
harmonics the theory is meant to preserve. Second, convergence was stated only as
*energy below ε* with a non-constructive depth `∃ K`.

`HodgeDeepLimit.lean` repairs both. We replace the dishonest hypothesis with a
strict contraction **only on the residual subspace** `(ker L)ᗮ`, prove that subspace
is invariant under one layer for symmetric `L` (`mpStep_mem_orthogonal`) and at every
depth (`mpStep_iterate_mem_orthogonal`), and recover the geometric `ρᵏ` residual
energy decay under the corrected hypothesis (`mpStep_iterate_contraction_orthogonal`).
We then upgrade energy decay to genuine **norm convergence**: depth-`k` message
passing on a harmonic-plus-residual input converges in norm to the harmonic part
(`mpStep_iterate_tendsto_harmonic`), and in finite dimension, on *every* input, the
deep limit equals the orthogonal projection onto the harmonic (cohomology) subspace
(`mpStep_deep_limit_eq_cohomology_projection`). The bridge
`hodge_deep_limit_is_harmonic_projection` instantiates this at the abstract
combinatorial Hodge Laplacian `Δ = up + down` of `HodgeSpectralThreshold.lean`.
Finally, the non-constructive `∃ K` is replaced by an explicit, logarithm-free
stopping rule `criticalDepth ρ R ε`, proved correct by a Bernoulli bound
(`criticalDepth_energy_bound`).

The decisive technical move is that energy `⟪v, v⟫ = ‖v‖²` is the bridge between the
polynomial spectral estimates of the earlier cycles and the analytic limit: the
`ρᵏ‖r‖²` energy bound squeezes `‖Tᵏ r‖² → 0`, whence `Tᵏ(h + r) → h`, and the deep
limit needs only the orthogonal decomposition `x = starProjection x +
(x − starProjection x)` available in finite dimension.

## Results Summary

| Theorem | Statement |
|---|---|
| `mpStep_mem_orthogonal` | `(ker L)ᗮ` is invariant under one layer `T = 1 − αL` (symmetric `L`). |
| `mpStep_iterate_mem_orthogonal` | Residual-subspace invariance persists at every depth. |
| `mpStep_iterate_contraction_orthogonal` | Residual energy decays as `ρᵏ ⟪r,r⟫` under the honest, subspace-only contraction. |
| `mpStep_iterate_tendsto_harmonic` | `Tᵏ(h+r) → h` in norm for `L h = 0`, `r ∈ (ker L)ᗮ`. |
| `mpStep_deep_limit_eq_cohomology_projection` | In finite dimension, `Tᵏ x → starProjection_{ker L} x` for every input `x`. |
| `criticalDepth_energy_bound` | The explicit, log-free depth drives residual energy below `ε`. |
| `hodge_deep_limit_is_harmonic_projection` | Deep simplicial message passing at `Δ = up + down` computes the harmonic projection. |

All depend
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
