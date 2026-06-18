
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

**Title**: The fifth cycle established *pointwise* convergence of gradient message passing
**Domain**: Applications
**Mathematical framing**: # Future Directions — Hodge–Laplacian Message Passing, Sixth Cycle

## Synthesis

The fifth cycle established *pointwise* convergence of gradient message passing
`T = 1 - α·L` to the harmonic (cohomology) subspace: the harmonic part of any input
is transported exactly through every depth while the residual contracts at the
spectral rate (`HodgeMessagePassingConvergence`). This cycle lifts that single-orbit
picture to **global, integrated energy laws** for the whole operator family
(`HodgeMessagePassingEnergy`):

1. **Heterogeneous depth commutes** — layers `1 - α·L` and `1 - β·L` of *different*
   learning rates commute, and so do their powers (`mpStep_comm`,
   `mpStep_comm_iterate`). A deep network with an arbitrary *schedule* of step sizes
   depends only on the multiset of rates, not their order.
2. **Energy is antitone in depth** — under a sub-unital contraction the residual
   Dirichlet energy never increases layer to layer (`mpStep_energy_antitone`): deep
   message passing is provably a low-pass smoother, not merely an asymptotic one.
3. **Total energy is finite** — for a strict contraction the energy summed over
   *every* depth is bounded by the geometric budget `⟪r,r⟫/(1−ρ)`, uniformly in the
   truncation (`mpStep_partial_energy_bound`, `mpStep_total_energy_bound`). This is
   the discrete shadow of finite Dirichlet action `∫₀^∞ ‖∇u‖² < ∞` for the Hodge
   heat flow, and it is instantiated for the catalog Hodge Laplacian `Δ = up + down`
   in `hodge_total_energy_bound`.

Together with the catalog foundation (`HodgeSpectralThreshold.harmonic_iff`,
`ker_hodgeLaplacian`, `mode_decay`, `depth_threshold`) this gives a complete
algebraic + analytic dossier for one operator family. The directions below push it
toward genuinely new mathematics.

## Results Summary

| Theorem | Statement |
| --- | --- |
| `mpStep_comm` | `(1−α·L)(1−β·L) = (1−β·L)(1−α·L)` for any `L`, `α`, `β`. |
| `mpStep_comm_iterate` | `Tα^m · Tβ^n = Tβ^n · Tα^m`. |
| `mpStep_energy_antitone` | `⟪T^{k+1}r⟫ ≤ ⟪T^k r⟫` when `ρ ≤ 1`. |
| `mpStep_partial_energy_bound` | `∑_{k<n} ⟪T^k r⟫ ≤ (∑_{k<n} ρ^k)·⟪r,r⟫`. |
| `mpStep_total_energy_bound` | `∑_{k<n} ⟪T^k r⟫ ≤ ⟪r,r⟫/(1−ρ)` for `0 ≤ ρ < 1`. |
| `hodge_total_energy_bound` | the budget instantiated at `Δ = up + down`. |

All six are proved with no `sorry`, depending only on `propext`, `Classical.choice`,
and `Quot.sound`.

## Research Directions

### 1. The total-energy budget is sharp, and the gap to it measures the spectral gap

`mpStep_total_energy_bound` proves `∑_k ⟪T^k r⟫ ≤ ⟪r,r⟫/(1−ρ)`. Conjecture: when
`r` is a single eigenvector of `L` with eigenvalue `λ` and the step is `α`, the
inequality is an *equality* with `ρ = (1−αλ)²`, and for general `r` the deficit
`⟪r,r⟫/(1−ρ) − ∑_k ⟪T^k r⟫` is a positive-definite quadratic form whose smallest
eigenvalue is controlled by the spectral gap `μ`. The key insight is that on each
eigenline message passing is an exact geometric series, so the only slack in the
bound comes from *mixing* eigenvalues — making the deficit a direct, computable
probe of the spectrum. Why now? We already have the per-mode dynamics
(`HodgeSpectralThreshold.mode_decay`) and the aggregate bound in the same library;
the equality case is a finite eigen-expansion away and needs no new analysis.

### 2. Optimal *schedules* beat constant steps, and order genuinely does not matter

Because `mpStep_comm_iterate` makes a heterogeneous schedule order-independent, the
depth-`k` operator is `∏_{i<k}(1 − α_i·L)`, a degree-`k` polynomial in `L` vanishing
nowhere on `ker L`. Conjecture: choosing `{α_i}` to be the reciprocals of Chebyshev
nodes on `[μ, λ_max]` minimises the worst-case residual energy over the spectrum,
strictly beating any constant step for `k ≥ 2`, with an explicit
`1/T_k((λ_max+μ)/(λ_max−μ))` rate. The key insight is that order-independence turns
schedule design into *polynomial approximation on the spectrum* — exactly the
setting where Chebyshev polynomials are extremal. Why now? `mpStep_comm` /
`mpStep_comm_iterate` are the precise algebraic fact (commuting layers ⇒ a single
product polynomial) that legitimises importing the Chebyshev acceleration theory;
the polynomial framing is now formally available.

### 3. The discrete Dirichlet action Γ-converges to the continuous Hodge flow

`mpStep_total_energy_bound` is the discrete analogue of `∫₀^∞ ‖∇u(t)‖² dt < ∞`.
Conjecture: as the step `α → 0` with depth `k ≈ t/α`, the discrete total energy
`α·∑_{k<t/α} ⟪T^k r⟫` converges to the continuous Dirichlet action
`∫₀^t ⟪e^{−sL} r, L e^{−sL} r⟫ ds` of the Hodge heat semigroup, and the harmonic
limit of `T^k` coincides with the orthogonal projector onto `ker L`. The key insight
is that the geometric budget `⟪r,r⟫/(1−ρ)` is the Riemann sum of the exponential
integral, so the discrete law is not an analogy but a quadrature of the continuous
one. Why now? The uniform-in-`n` bound proved here is exactly the equi-coercivity
hypothesis a Γ-convergence / semigroup-limit argument needs, and Mathlib now carries
enough one-parameter semigroup theory to state the limit.

### 4. A cross-domain bridge: integrated energy bounds expander mixing on the up-Laplacian

The catalog has an expander program (`Algebra/ExpanderWalk/Amplification`,
`ClassicalGroupExpanders`). Conjecture: instantiating `L` as the *normalised
up-Hodge Laplacian* of an expander complex, the finite total-energy budget
`⟪r,r⟫/(1−ρ)` with `ρ = 1 − gap` reproduces and quantitatively sharpens the
expander-mixing lemma for `k`-dimensional simplicial walks, with the spectral gap of
`Δ` replacing the second graph eigenvalue. The key insight is that message-passing
energy decay and random-walk mixing are the *same* operator inequality read in two
languages — Dirichlet-energy contraction versus L²-mixing. Why now? Both halves now
live in this catalog with compatible self-adjoint-PSD interfaces, so the bridge is a
matter of matching hypotheses rather than building new spectral theory.

### 5. Antitonicity characterises admissible (stable) learning rates exactly

`mpStep_energy_antitone` assumes a sub-unital contraction (`ρ ≤ 1`). Conjecture: for
a self-adjoint PSD `L` with top eigenvalue `λ_max`, per-layer energy antitonicity for
*all* inputs holds **iff** `0 ≤ α ≤ 2/λ_max`, and the boundary `α = 2/λ_max` is the
unique step where some mode is merely preserved (energy constant) rather than
strictly decreased. The key insight is that antitonicity is equivalent to the
operator inequality `0 ≼ T ≼ 1`, i.e. `‖1 − αL‖ ≤ 1`, which is a clean spectral
condition on `α`. Why now? The forward direction is one short step from the proved
`mpStep_contraction`/`mpStep_energy_antitone`; the converse needs only a single
extremal eigenvector, giving a falsifiable iff that pins down the stability region.

Research domain: Applications
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
# Future Directions — Hodge–Laplacian Message Passing, Seventh Cycle

## Synthesis

The sixth cycle (`Speculative/AutoResearch/HodgeMessagePassingEnergy.lean`) lifted the
fifth cycle's *pointwise* convergence picture (`HodgeMessagePassingConvergence`:
`mpStep_iterate_add_harmonic`, `mpStep_iterate_contraction`,
`mpStep_dist_to_harmonic_bound`) to **global, integrated energy laws** for the whole
message-passing operator family `T = 1 - α·L`:

1. **Heterogeneous depth commutes.** Layers of *different* learning rates `1 - α·L`
   and `1 - β·L` commute (`mpStep_comm`), and so do their powers
   (`mpStep_comm_iterate`). A deep network with an arbitrary *schedule* of step sizes
   depends only on the multiset of rates, not their order. The proof is purely
   algebraic — `α•L` and `β•L` commute in `Module.End ℝ E`, so `Commute.pow_pow`
   handles every depth.
2. **Energy is antitone in depth.** Under a sub-unital contraction the residual
   Dirichlet energy never increases layer to layer (`mpStep_energy_antitone`): deep
   message passing is provably a low-pass smoother, not merely an asymptotic one.
3. **Total energy is finite.** For a strict contraction the energy summed over
   *every* depth is bounded by the geometric budget `⟪r,r⟫/(1−ρ)`, uniformly in the
   truncation (`mpStep_partial_energy_bound`, `mpStep_total_energy_bound`). This is
   the discrete shadow of finite Dirichlet action `∫₀^∞ ‖∇u‖² < ∞` for the Hodge heat
   flow, and it is instantiated for the catalog Hodge Laplacian `Δ = up + down` in
   `hodge_total_energy_bound`, where the per-layer rate `ρ = 1 − αμ(2−αλ)` is derived
   from the spectral bounds via the fifth-cycle `mpStep_contraction`.

Together with the catalog foundation (`HodgeSpectralThreshold.harmonic_iff`,
`ker_hodgeLaplacian`, `mode_decay`, `depth_threshold`) this gives a complete algebraic
+ analytic dossier for one operator family. The directions below push it toward
genuinely new mathematics.

## Results Summary

| Theorem | Statement |
| --- | --- |
| `mpStep_comm` | `(1−α·L)(1−β·L) = (1−β·L)(1−α·L)` for any `L`, `α`, `β`. |
| `mpStep_comm_iterate` | `Tα^m · Tβ^n = Tβ^n · Tα^m`. |
| `mpStep_energy_antitone` | `⟪T^{k+1}r⟫ ≤ ⟪T^k r⟫` when `ρ ≤ 1`. |
| `mpStep_partial_energy_bound` | `∑_{k<n} ⟪T^k r⟫ ≤ (∑_{k<n} ρ^k)·⟪r,r⟫`. |
| `mpStep_total_energy_bound` | `∑_{k<n} ⟪T^k r⟫ ≤ ⟪r,r⟫/(1−ρ)` for `0 ≤ ρ < 1`. |
| `hodge_total_energy_bound` | the budget instantiated at `Δ = up + down`. |

All six are proved with no `sorry`, depending only on `propext`, `Classical.choice`,
and `Quot.sound`.

## Research Directions

### 1. The total-energy budget is sharp, and the gap to it measures the spectral gap

`mpStep_total_energy_bound` proves `∑_k ⟪T^k r⟫ ≤ ⟪r,r⟫/(1−ρ)`. Conjecture: when `r`
is a single eigenvector of `L` with eigenvalue `λ` and step `α`, the inequality is an
*equality* with `ρ = (1−αλ)²`, and for general `r` the deficit
`⟪r,r⟫/(1−ρ) − ∑_k ⟪T^k r⟫` is a positive-definite quadratic form whose smallest
eigenvalue is con
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
