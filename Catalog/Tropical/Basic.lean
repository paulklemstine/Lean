/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# GL₃ Tropical Satake Finite Presentation

## Overview

We formalize a finite-determinacy and finite-presentation theorem for functions on
the GL₃ dominant coweight lattice, modeling the tropical spherical Hecke algebra.

A dominant coweight for GL₃ is a pair `(a, b) ∈ ℕ × ℕ` representing the partition
`(a+b, b, 0)`, equivalently `a·ω₁ + b·ω₂` in fundamental weights.

The key structural observation is that the Pieri rule for the second fundamental
representation ω₂ = ∧²V of GL₃ has exactly one predecessor for each dominant
coweight. This makes the ω₂-Pieri convolution a simple shift operator, which
directly determines interior function values from boundary data.

## Main Results

* `determined_by_pieriObs2` — The ω₂-Pieri profile uniquely determines any function
* `finite_determinacy_GL3` — Bounded-support functions with matching observables are equal
* `abstract_determinacy` — General injectivity from the triangular recovery property
* `gl3_triangular_recovery` — The GL₃ Pieri operators satisfy triangular recovery
* `finite_realization_GL3` — Compatible observable packages can be realized
* `observableImage_eq_compatible` — Image of observable map = compatible packages
* `obsMap_injective` — The observable map is injective on bounded-support functions
* `bounded_GL3_tropSatake_equiv_compatibleObservables` — Bijection between
  bounded-support functions and compatible observable packages

## Mathematical Significance

For GL₃, the second fundamental representation ∧²V has rank 3, and its Pieri rule
(adding a vertical strip of size 2 to a Young diagram) produces exactly one valid
predecessor for each dominant coweight. This is a rank-2 phenomenon: for GL_n with
n ≥ 4, intermediate fundamental representations have multiple predecessors, making
the recovery problem genuinely harder.

The finite presentation result shows that bounded-support tropical Hecke functions
are in bijection with observable packages satisfying explicit, finitely many local
compatibility conditions. This is the tropical analogue of presenting a commutative
algebra by generators and relations.

## References

* Maclagan-Sturmfels, *Introduction to Tropical Geometry*
* Gross, *Tropical geometry and mirror symmetry*
-/
import Mathlib

noncomputable section

namespace TropGL3

/-! ### §1. Basic Definitions -/

/-- Dominant coweights for GL₃, represented as `(a, b)` corresponding to
    the partition `(a+b, b, 0)`, or equivalently `a·ω₁ + b·ω₂` in
    fundamental weights. -/
abbrev DomWeightGL3 := ℕ × ℕ

/-- The two fundamental coweights. -/
def omega1 : DomWeightGL3 := (1, 0)
def omega2 : DomWeightGL3 := (0, 1)

/-- Height of a dominant coweight: `height (a,b) = a + b`. -/
def height (μ : DomWeightGL3) : ℕ := μ.1 + μ.2

/-- Restriction to the ω₁-edge (first simple-coroot ray): `edge1 f n = f(n, 0)`. -/
def edge1 (f : DomWeightGL3 → ℝ) : ℕ → ℝ := fun n => f (n, 0)

/-- Restriction to the ω₂-edge (second simple-coroot ray): `edge2 f n = f(0, n)`. -/
def edge2 (f : DomWeightGL3 → ℝ) : ℕ → ℝ := fun n => f (0, n)

/-- Box support condition: `f(a,b) = 0` whenever `a + b > N`. -/
def HasBoxSupport (N : ℕ) (f : DomWeightGL3 → ℝ) : Prop :=
  ∀ ab : DomWeightGL3, N < ab.1 + ab.2 → f ab = 0

/-- Rectangular support condition. -/
def HasRectSupport (A B : ℕ) (f : DomWeightGL3 → ℝ) : Prop :=
  ∀ ab : DomWeightGL3, A < ab.1 ∨ B < ab.2 → f ab = 0

/-- Rectangular support implies box support. -/
theorem HasRectSupport.toBoxSupport {A B : ℕ} {f : DomWeightGL3 → ℝ}
    (h : HasRectSupport A B f) : HasBoxSupport (A + B) f := by
  intro ⟨a, b⟩ hab
  apply h; omega

/-! ### §2. GL₃ Pieri Convolution Operators

The Pieri rule for GL₃ describes the tensor product of a dominant representation
with a fundamental representation:

**For ω₁ (standard representation V):** Adding one box to a Young diagram
`(a+b, b, 0)` can go in row 1 (giving `(a+b+1, b, 0) = (a+1, b)`) or row 2
(giving `(a+b, b+1, 0) = (a-1, b+1)`, requires `a ≥ 1`). So each coweight
`(a,b)` has predecessors `(a-1, b)` (if `a ≥ 1`) and `(a+1, b-1)` (if `b ≥ 1`).

**For ω₂ (exterior square ∧²V):** Adding a vertical strip of size 2 means
adding 1 to exactly 2 of the 3 rows. Since `λ₃ = 0`, the only valid option
is rows 1 and 2: `(a+b+1, b+1, 0) = (a, b+1)`. So each coweight `(a,b)`
has exactly one predecessor: `(a, b-1)` (if `b ≥ 1`).

In the tropical (min-plus) Hecke algebra, the convolution with a point mass
takes the minimum over predecessors.
-/

/-- The ω₂-Pieri convolution for GL₃.

    Since the Pieri rule for ∧²V has exactly one predecessor per coweight,
    this operator is a simple downward shift:
    `pieriObs2 f (a, b+1) = f(a, b)` and `pieriObs2 f (a, 0) = 0`. -/
def pieriObs2 (f : DomWeightGL3 → ℝ) : DomWeightGL3 → ℝ
  | (_, 0) => 0
  | (a, b + 1) => f (a, b)

/-- The ω₁-Pieri convolution for GL₃.

    The tropical minimum over valid predecessors:
    - `(a-1, b)` when `a ≥ 1`
    - `(a+1, b-1)` when `b ≥ 1`
    At `(0,0)`, there are no valid predecessors (convention: 0). -/
def pieriObs1 (f : DomWeightGL3 → ℝ) : DomWeightGL3 → ℝ
  | (0, 0) => 0
  | (a + 1, 0) => f (a, 0)
  | (0, b + 1) => f (1, b)
  | (a + 1, b + 1) => min (f (a, b + 1)) (f (a + 2, b))

/-! ### §3. The Shift Property

The fundamental structural fact: the ω₂-Pieri operator is a simple shift,
so every function value can be read off from its ω₂-Pieri profile.
-/

@[simp]
theorem pieriObs2_succ (f : DomWeightGL3 → ℝ) (a b : ℕ) :
    pieriObs2 f (a, b + 1) = f (a, b) := rfl

@[simp]
theorem pieriObs2_zero_right (f : DomWeightGL3 → ℝ) (a : ℕ) :
    pieriObs2 f (a, 0) = 0 := rfl

/-- Key recovery lemma: every function value is determined by the ω₂-Pieri profile. -/
theorem recover_from_pieriObs2 (f : DomWeightGL3 → ℝ) (a b : ℕ) :
    f (a, b) = pieriObs2 f (a, b + 1) := rfl

/-- The ω₁-Pieri operator at an interior point. -/
@[simp]
theorem pieriObs1_succ_succ (f : DomWeightGL3 → ℝ) (a b : ℕ) :
    pieriObs1 f (a + 1, b + 1) = min (f (a, b + 1)) (f (a + 2, b)) := rfl

@[simp]
theorem pieriObs1_succ_zero (f : DomWeightGL3 → ℝ) (a : ℕ) :
    pieriObs1 f (a + 1, 0) = f (a, 0) := rfl

@[simp]
theorem pieriObs1_zero_succ (f : DomWeightGL3 → ℝ) (b : ℕ) :
    pieriObs1 f (0, b + 1) = f (1, b) := rfl

@[simp]
theorem pieriObs1_zero_zero (f : DomWeightGL3 → ℝ) :
    pieriObs1 f (0, 0) = 0 := rfl

/-! ### §4. Finite Determinacy -/

/-
**Determinacy from ω₂-Pieri alone**: Two functions with the same ω₂-Pieri
    profile are equal. This is the key consequence of the GL₃ Pieri rule having
    exactly one predecessor for ω₂.

    The proof is immediate: `f(a,b) = pieriObs2 f (a, b+1)` for all `(a,b)`.
-/
theorem determined_by_pieriObs2 (f g : DomWeightGL3 → ℝ)
    (h : pieriObs2 f = pieriObs2 g) : f = g := by
  funext ⟨ a, b ⟩ ; have := congr_fun h ⟨ a, b + 1 ⟩ ; simp_all +decide [ pieriObs2 ] ;

/-- Same-observables predicate: two functions agree on all edge restrictions
    and Pieri convolution profiles. -/
structure SameObservables (f g : DomWeightGL3 → ℝ) : Prop where
  edge1_eq : edge1 f = edge1 g
  edge2_eq : edge2 f = edge2 g
  obs1_eq : pieriObs1 f = pieriObs1 g
  obs2_eq : pieriObs2 f = pieriObs2 g

/-- Extracting edge equalities from SameObservables. -/
theorem edge1_eq_of_sameObservables {f g : DomWeightGL3 → ℝ}
    (hobs : SameObservables f g) : edge1 f = edge1 g := hobs.edge1_eq

theorem edge2_eq_of_sameObservables {f g : DomWeightGL3 → ℝ}
    (hobs : SameObservables f g) : edge2 f = edge2 g := hobs.edge2_eq

/-- **Main Finite Determinacy Theorem**: Functions with bounded support and
    the same observables (edge restrictions + Pieri profiles) are equal.

    Note: bounded support is not actually needed; the ω₂-Pieri profile alone
    determines the function. We include the hypothesis for compatibility with
    the general framework and the user's requested statement. -/
theorem finite_determinacy_GL3
    (N : ℕ) (f g : DomWeightGL3 → ℝ)
    (_hf : HasBoxSupport N f) (_hg : HasBoxSupport N g)
    (hobs : SameObservables f g) :
    f = g :=
  determined_by_pieriObs2 f g hobs.obs2_eq

/-! ### §5. Abstract Triangular Recovery Framework

For higher-rank groups (GL₄ and beyond), the Pieri rule for intermediate
fundamental representations involves multiple predecessors, and the recovery
argument requires genuine strong induction on height. We formalize this
abstract framework here, then verify that GL₃ satisfies it.
-/

/-- A pair of operators satisfies the **triangular recovery property** if,
    for any interior point `(a,b)` with `a > 0` and `b > 0`, knowing:
    1. Both operators' values at nearby points (height ≤ a+b+1),
    2. All function values at strictly lower height,
    uniquely determines `f(a,b)`.

    For GL₃, the ω₂-Pieri satisfies a stronger property (direct shift),
    but this framework is designed for the general case. -/
def TriangularRecovery
    (F₁ F₂ : (DomWeightGL3 → ℝ) → DomWeightGL3 → ℝ) : Prop :=
  ∀ (f g : DomWeightGL3 → ℝ) (a b : ℕ), 0 < a → 0 < b →
    (∀ p q : ℕ, p + q < a + b → f (p, q) = g (p, q)) →
    (∀ p q : ℕ, p + q ≤ a + b + 1 → F₁ f (p, q) = F₁ g (p, q)) →
    (∀ p q : ℕ, p + q ≤ a + b + 1 → F₂ f (p, q) = F₂ g (p, q)) →
    f (a, b) = g (a, b)

/-
**Abstract Determinacy Theorem**: Any pair of operators with the triangular
    recovery property gives injectivity when edge data and operator profiles match.

    The proof uses strong induction on the height `a + b`:
    - At edges (`a = 0` or `b = 0`): use edge data equality
    - At interior points: apply the recovery property with the induction hypothesis
-/
theorem abstract_determinacy
    {F₁ F₂ : (DomWeightGL3 → ℝ) → DomWeightGL3 → ℝ}
    (hRec : TriangularRecovery F₁ F₂)
    (f g : DomWeightGL3 → ℝ)
    (he1 : edge1 f = edge1 g)
    (he2 : edge2 f = edge2 g)
    (hF1 : F₁ f = F₁ g) (hF2 : F₂ f = F₂ g) :
    f = g := by
  funext ⟨a, b⟩;
  induction' n : a + b using Nat.strong_induction_on with n ih generalizing a b;
  by_cases ha : a = 0;
  · simp_all +decide [ funext_iff, edge1, edge2 ];
  · by_cases hb : b = 0;
    · simp_all +decide [ funext_iff, edge1, edge2 ];
    · exact hRec f g a b ( Nat.pos_of_ne_zero ha ) ( Nat.pos_of_ne_zero hb ) ( fun p q hpq => ih _ ( by linarith ) _ _ rfl ) ( fun p q hpq => congr_fun hF1 _ ) ( fun p q hpq => congr_fun hF2 _ )

/-
The GL₃ Pieri operators satisfy the triangular recovery property.
    In fact, the ω₂-Pieri alone suffices via the shift property,
    without needing ω₁-Pieri or the lower-height induction hypothesis.
-/
theorem gl3_triangular_recovery :
    TriangularRecovery pieriObs1 pieriObs2 := by
  intro f g a b ha hb ih₁ ih₂ ih₃;
  convert ih₃ a ( b + 1 ) ( by linarith ) using 1

/-- Alternative proof of GL₃ determinacy via the abstract framework. -/
theorem finite_determinacy_GL3' (f g : DomWeightGL3 → ℝ)
    (hobs : SameObservables f g) : f = g :=
  abstract_determinacy gl3_triangular_recovery f g
    hobs.edge1_eq hobs.edge2_eq hobs.obs1_eq hobs.obs2_eq

/-! ### §6. Observable Package and Compatibility -/

/-- An **observable package** at support level `N` bundles:
    - Edge restrictions `e1`, `e2` (function values on the two axes)
    - ω₁-Pieri profile `c1` (tropical min over predecessors)
    - ω₂-Pieri profile `c2` (shift operator output)
    together with support conditions on the edge data. -/
structure ObservablePackage (N : ℕ) where
  e1 : ℕ → ℝ
  e2 : ℕ → ℝ
  c1 : DomWeightGL3 → ℝ
  c2 : DomWeightGL3 → ℝ
  e1_support : ∀ n, N < n → e1 n = 0
  e2_support : ∀ n, N < n → e2 n = 0

/-- The **observable map**: extracts the observable package from a function
    with bounded support. This is the "analysis" direction of the
    Satake correspondence. -/
def obsMap {N : ℕ} (f : DomWeightGL3 → ℝ) (hf : HasBoxSupport N f) :
    ObservablePackage N where
  e1 := edge1 f
  e2 := edge2 f
  c1 := pieriObs1 f
  c2 := pieriObs2 f
  e1_support := fun n hn => hf (n, 0) (by omega)
  e2_support := fun n hn => hf (0, n) (by omega)

/-- **Compatibility conditions** characterize which observable packages arise
    from actual functions. These are the explicit local relations that form
    the finite presentation of the tropical Hecke algebra.

    The conditions enforce:
    1. **Boundary consistency**: c2 at boundary points matches edge data
    2. **Base vanishing**: c2 vanishes when the second coordinate is 0
    3. **Pieri-1 consistency**: c1 equals the ω₁-Pieri formula applied to
       the function reconstructed from c2
    4. **Support**: c2 vanishes outside the bounded region -/
structure Compatible (N : ℕ) (O : ObservablePackage N) : Prop where
  /-- ω₂-Pieri at `(a, 1)` recovers the ω₁-edge value. -/
  boundary1 : ∀ a : ℕ, O.c2 (a, 1) = O.e1 a
  /-- ω₂-Pieri at `(0, b+1)` recovers the ω₂-edge value. -/
  boundary2 : ∀ b : ℕ, O.c2 (0, b + 1) = O.e2 b
  /-- ω₂-Pieri vanishes at the base (no predecessor when b=0). -/
  c2_base : ∀ a : ℕ, O.c2 (a, 0) = 0
  /-- ω₁-Pieri at (0,0): no predecessors, value 0. -/
  c1_consistent_00 : O.c1 (0, 0) = 0
  /-- ω₁-Pieri at (a+1,0): single predecessor (a,0). -/
  c1_consistent_s0 : ∀ a : ℕ, O.c1 (a + 1, 0) = O.c2 (a, 1)
  /-- ω₁-Pieri at (0,b+1): single predecessor (1,b). -/
  c1_consistent_0s : ∀ b : ℕ, O.c1 (0, b + 1) = O.c2 (1, b + 1)
  /-- ω₁-Pieri at interior points: min of two predecessors.
      This is the tropical rhombus inequality—the key non-trivial relation. -/
  c1_consistent_ss : ∀ a b : ℕ,
    O.c1 (a + 1, b + 1) = min (O.c2 (a, b + 2)) (O.c2 (a + 2, b + 1))
  /-- Support condition for the ω₂-Pieri profile. -/
  c2_support : ∀ ab : DomWeightGL3, N + 1 < ab.1 + ab.2 → O.c2 ab = 0

/-! ### §7. Realization Theorem -/

/-- Reconstruct a function from the ω₂-Pieri profile: `f(a, b) = c₂(a, b+1)`.
    This is the "synthesis" direction of the Satake correspondence. -/
def reconstruct (c2 : DomWeightGL3 → ℝ) : DomWeightGL3 → ℝ :=
  fun ⟨a, b⟩ => c2 (a, b + 1)

theorem reconstruct_eq (c2 : DomWeightGL3 → ℝ) (a b : ℕ) :
    reconstruct c2 (a, b) = c2 (a, b + 1) := rfl

/-
**Realization Theorem**: Every compatible observable package is realized by
    a bounded-support function. The function is explicitly constructed from the
    ω₂-Pieri data via `reconstruct`.

    This is the surjectivity half of the finite presentation theorem.
-/
theorem finite_realization_GL3
    (N : ℕ) (O : ObservablePackage N)
    (hO : Compatible N O) :
    ∃ f : DomWeightGL3 → ℝ,
      HasBoxSupport N f ∧
      edge1 f = O.e1 ∧
      edge2 f = O.e2 ∧
      pieriObs1 f = O.c1 ∧
      pieriObs2 f = O.c2 := by
  refine' ⟨ fun ⟨ a, b ⟩ => O.c2 ( a, b + 1 ), _, _, _, _, _ ⟩;
  · exact fun ⟨ a, b ⟩ hab => hO.c2_support ⟨ a, b + 1 ⟩ ( by linarith );
  · ext a; exact hO.boundary1 a;
  · exact funext fun n => hO.boundary2 n;
  · ext ⟨ a, b ⟩;
    induction' a with a ih generalizing b <;> induction' b with b ih' <;> simp_all +decide [ pieriObs1 ];
    · exact hO.c1_consistent_00.symm;
    · exact hO.c1_consistent_0s b ▸ rfl;
    · exact hO.c1_consistent_s0 a ▸ rfl;
    · exact hO.c1_consistent_ss a b ▸ rfl;
  · ext ⟨ a, b ⟩ ; rcases b with ( _ | b ) <;> simp +decide [ pieriObs2_succ ] ;
    exact hO.c2_base a ▸ rfl

/-! ### §8. Image Characterization (Finite Presentation) -/

/-- The **observable image**: the set of packages arising from bounded-support functions. -/
def ObservableImage (N : ℕ) : Set (ObservablePackage N) :=
  {O | ∃ f, HasBoxSupport N f ∧
    edge1 f = O.e1 ∧ edge2 f = O.e2 ∧
    pieriObs1 f = O.c1 ∧ pieriObs2 f = O.c2}

/-
**Finite Presentation Theorem**: The observable image equals the set of
    compatible packages. This is the main structural result: bounded-support
    tropical Hecke functions for GL₃ are in bijection with observable packages
    satisfying finitely many explicit local compatibility conditions.

    The forward direction (image ⊆ compatible) shows the conditions are necessary.
    The reverse direction (compatible ⊆ image) uses the realization theorem.
-/
theorem observableImage_eq_compatible (N : ℕ) :
    ObservableImage N = {O : ObservablePackage N | Compatible N O} := by
  apply Set.eq_of_subset_of_subset;
  · intro O hO;
    obtain ⟨ f, hf, h₁, h₂, h₃, h₄ ⟩ := hO;
    constructor;
    all_goals simp_all +decide [ funext_iff, edge1, edge2 ];
    all_goals simp_all +decide [ ← h₃, ← h₄ ];
    intro a b hab; exact hf ( a, b - 1 ) ( by omega ) |> fun h => by cases b <;> tauto;
  · exact fun O hO => finite_realization_GL3 N O hO

/-! ### §9. Injectivity and Equivalence -/

/-
The observable map is injective on bounded-support functions.
-/
theorem obsMap_injective (N : ℕ) (f g : DomWeightGL3 → ℝ)
    (hf : HasBoxSupport N f) (hg : HasBoxSupport N g)
    (h : obsMap f hf = obsMap g hg) :
    f = g := by
  apply_fun (fun x => x.c2) at h;
  exact determined_by_pieriObs2 _ _ h

/-- The observable map is injective as a set function. -/
theorem obsMap_injOn (N : ℕ) :
    Set.InjOn (fun fg : {f // HasBoxSupport N f} => obsMap fg.1 fg.2)
      Set.univ := by
  intro ⟨f, hf⟩ _ ⟨g, hg⟩ _ heq
  ext1
  exact obsMap_injective N f g hf hg heq

/-! ### §10. Support Finiteness -/

/-
The set of lattice points on a fixed antidiagonal with nonzero function value
    is finite (for any function, not just bounded-support ones).
-/
theorem support_antidiagonal_finite
    {f : DomWeightGL3 → ℝ} (k : ℕ) :
    Set.Finite {ab : DomWeightGL3 | ab.1 + ab.2 = k ∧ f ab ≠ 0} := by
  exact Set.finite_iff_bddAbove.mpr ⟨ ⟨ k, k ⟩, fun x hx => by exact ⟨ by linarith [ hx.1 ], by linarith [ hx.1 ] ⟩ ⟩

/-
The total support of a bounded-support function is finite.
-/
theorem boxSupport_finite {N : ℕ} {f : DomWeightGL3 → ℝ}
    (hf : HasBoxSupport N f) :
    Set.Finite {ab : DomWeightGL3 | f ab ≠ 0} := by
  refine Set.Finite.subset ( Set.toFinite ( Set.Iic N ×ˢ Set.Iic N ) ) ?_;
  exact fun x hx => ⟨ Nat.le_of_not_lt fun h => hx <| hf x <| by linarith [ Set.mem_Iio.mp <| show x.1 ∈ Set.Ioi N from h ], Nat.le_of_not_lt fun h => hx <| hf x <| by linarith [ Set.mem_Iio.mp <| show x.2 ∈ Set.Ioi N from h ] ⟩

/-! ### §11. Equivalence Statement -/

/-
**Tropical Satake Equivalence for GL₃**: There exists a bijection between
    bounded-support functions and compatible observable packages that preserves
    the edge data.

    This is the strongest form of the finite presentation result: it exhibits
    the tropical Hecke algebra (restricted to support level N) as isomorphic
    to the finitely presented space of compatible observable packages.
-/
theorem bounded_GL3_tropSatake_equiv_compatibleObservables
    (N : ℕ) :
    ∃ e : {f // HasBoxSupport N f} ≃ {O : ObservablePackage N // Compatible N O},
      (∀ f, (e f).1.e1 = edge1 f.1) ∧
      (∀ f, (e f).1.e2 = edge2 f.1) := by
  fconstructor;
  refine' Equiv.ofBijective ( fun f => ⟨ obsMap f.1 f.2, _ ⟩ ) ⟨ _, _ ⟩;
  rotate_left;
  intro f g hfg;
  exact Subtype.ext <| obsMap_injective N _ _ f.2 g.2 <| by injection hfg;
  all_goals norm_num [ Function.Surjective ];
  · intro O hO;
    obtain ⟨ f, hf₁, hf₂, hf₃, hf₄, hf₅ ⟩ := finite_realization_GL3 N O hO;
    exact ⟨ f, hf₁, by unfold obsMap; aesop ⟩;
  · aesop;
  · constructor <;> intros <;> simp_all +decide [ obsMap ];
    · rfl;
    · rfl;
    · rename_i ab hab;
      rcases ab with ⟨ _ | a, _ | b ⟩ <;> simp_all +decide [ pieriObs2 ];
      · exact f.2 ( 0, b ) ( by linarith );
      · exact f.2 ( a + 1, b ) ( by linarith )

end TropGL3

end