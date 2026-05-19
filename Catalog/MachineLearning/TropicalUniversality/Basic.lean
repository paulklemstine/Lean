import Mathlib

/-!
# Tropical Universality Theorems for Computation DAGs

## Overview

This file establishes a **classification theory** for tropical scaling exponents of
computation DAGs, elevating the tropical scaling exponent from a descriptive invariant
to a structurally determined quantity with composition laws.

## Main Results

### Part I: Asymptotic Uniqueness
- `affine_sandwich_slope_unique`: The slope of an affine sandwich is unique — if a function
  is eventually trapped between two affine functions with the same slope, that slope is
  uniquely determined.
- `scalingExponent_unique`: The scaling exponent of a tropical profile is the unique
  rational number whose affine sandwich traps the envelope.

### Part II: Composition Laws
- `parallelProfile`: Parallel composition of tropical profiles (union of path sets).
- `serialProfile`: Serial composition (pairwise combination of paths).
- `scalingExponent_parallel`: The scaling exponent of a parallel composition is the
  minimum of the component exponents.
- `scalingExponent_serial`: The scaling exponent of a serial composition is the sum
  of the component exponents.

### Part III: Tropical Invariance Bridge
- `scalingExponent_of_tropEquiv_sandwich`: Full invariance theorem — tropically equivalent
  DAGs with asymptotic sandwiches share the same scaling exponent.

## Mathematical Significance

These results establish that:
1. The scaling exponent is not merely *an* invariant but the *unique* asymptotic slope.
2. Architecture composition has a precise algebraic calculus on exponents.
3. Tropical equivalence completely determines asymptotic scaling behavior.

Together, this forms the nucleus of a **tropical complexity theory for learning systems**.
-/

noncomputable section

open Finset

/-! ## Part 0: Core Definitions (self-contained)

We reproduce the core definitions from the catalog to make this file standalone.
These mirror the definitions in `Catalog/MachineLearning/TropicalScaling/Basic.lean`.
-/

/-- A tropical affine form `slope · x + intercept` representing a path cost function. -/
structure TropAffine where
  slope : ℚ
  intercept : ℚ
  deriving DecidableEq, Repr

namespace TropAffine

/-- Evaluate the affine form at a point. -/
def eval (f : TropAffine) (x : ℚ) : ℚ := f.slope * x + f.intercept

@[simp]
theorem eval_def (f : TropAffine) (x : ℚ) : f.eval x = f.slope * x + f.intercept := rfl

end TropAffine

/-- A tropical profile: a nonempty finite set of affine cost functions. -/
structure TropicalProfile where
  forms : Finset TropAffine
  nonempty : forms.Nonempty

namespace TropicalProfile

/-- The tropical envelope: pointwise minimum of all path cost functions. -/
def envelope (P : TropicalProfile) (x : ℚ) : ℚ :=
  P.forms.inf' P.nonempty (fun f => f.eval x)

/-- The tropical scaling exponent: minimum slope across all path cost functions. -/
def scalingExponent (P : TropicalProfile) : ℚ :=
  P.forms.inf' P.nonempty TropAffine.slope

/-- Two profiles are tropically equivalent if they have the same form set. -/
def TropEquiv (P Q : TropicalProfile) : Prop := P.forms = Q.forms

/-! ## Part I: Asymptotic Uniqueness of the Scaling Exponent -/

/-- The scaling exponent is a lower bound on all slopes in the profile. -/
theorem scalingExponent_le_slope (P : TropicalProfile) {f : TropAffine} (hf : f ∈ P.forms) :
    P.scalingExponent ≤ f.slope :=
  Finset.inf'_le _ hf

/-- The scaling exponent is achieved by some form in the profile. -/
theorem scalingExponent_mem (P : TropicalProfile) :
    ∃ f ∈ P.forms, f.slope = P.scalingExponent := by
  obtain ⟨f, hf, he⟩ := Finset.exists_mem_eq_inf' P.nonempty TropAffine.slope
  exact ⟨f, hf, he.symm⟩

/-- The envelope is at most any individual form's value. -/
theorem envelope_le_eval (P : TropicalProfile) {f : TropAffine} (hf : f ∈ P.forms) (x : ℚ) :
    P.envelope x ≤ f.eval x :=
  Finset.inf'_le _ hf

/-- The envelope equals some form's value at each point. -/
theorem envelope_eq_some_eval (P : TropicalProfile) (x : ℚ) :
    ∃ f ∈ P.forms, P.envelope x = f.eval x :=
  Finset.exists_mem_eq_inf' P.nonempty (fun f => f.eval x)

/-- Global upper bound: the envelope is bounded above by a minimum-slope form. -/
theorem envelope_upper_bound (P : TropicalProfile) :
    ∃ b : ℚ, ∀ x : ℚ, P.envelope x ≤ P.scalingExponent * x + b := by
  obtain ⟨f₀, hf₀, hslope⟩ := P.scalingExponent_mem
  exact ⟨f₀.intercept, fun x => by
    have := P.envelope_le_eval hf₀ x
    simp [TropAffine.eval, hslope] at this ⊢; linarith⟩

/-- Eventual lower bound: the envelope is eventually bounded below. -/
theorem envelope_lower_bound (P : TropicalProfile) :
    ∃ (X₀ b : ℚ), ∀ x : ℚ, x ≥ X₀ → P.scalingExponent * x + b ≤ P.envelope x := by
  -- The minimum intercept provides a global lower shift
  have hmin_int : ∃ b : ℚ, ∀ f ∈ P.forms, b ≤ f.intercept := by
    exact ⟨P.forms.inf' P.nonempty TropAffine.intercept,
      fun f hf => Finset.inf'_le _ hf⟩
  obtain ⟨b, hb⟩ := hmin_int
  refine ⟨0, b, fun x hx => ?_⟩
  -- Every form's value ≥ scalingExponent * x + b when x ≥ 0
  apply Finset.le_inf'
  intro f hf
  have h1 : P.scalingExponent ≤ f.slope := P.scalingExponent_le_slope hf
  have h2 : b ≤ f.intercept := hb f hf
  simp [TropAffine.eval]
  nlinarith

/-- **Asymptotic sandwich**: The envelope is eventually trapped between
    two affine functions with slope equal to the scaling exponent. -/
theorem envelope_sandwich (P : TropicalProfile) :
    ∃ (X₀ b₁ b₂ : ℚ),
      (∀ x, x ≥ X₀ → P.scalingExponent * x + b₁ ≤ P.envelope x) ∧
      (∀ x, P.envelope x ≤ P.scalingExponent * x + b₂) := by
  obtain ⟨X₀, b₁, h₁⟩ := P.envelope_lower_bound
  obtain ⟨b₂, h₂⟩ := P.envelope_upper_bound
  exact ⟨X₀, b₁, b₂, h₁, h₂⟩

end TropicalProfile

/-
**Affine sandwich slope uniqueness**: If a function `f` is eventually sandwiched
    between `α·x + b₁` and `α·x + b₂`, and also between `β·x + b₃` and `β·x + b₄`,
    then `α = β`.

    This is the core asymptotic uniqueness theorem. It says that the "leading slope"
    of any function admitting an affine sandwich is uniquely determined.
-/
theorem affine_sandwich_slope_unique
    {f : ℚ → ℚ} {α β b₁ b₂ b₃ b₄ X₁ X₂ : ℚ}
    (h_lower₁ : ∀ x, x ≥ X₁ → α * x + b₁ ≤ f x)
    (h_upper₁ : ∀ x, f x ≤ α * x + b₂)
    (h_lower₂ : ∀ x, x ≥ X₂ → β * x + b₃ ≤ f x)
    (h_upper₂ : ∀ x, f x ≤ β * x + b₄) :
    α = β := by
  by_cases hαβ : α < β;
  · -- Choose $x$ large enough such that $(β - α) * x > b₂ - b₃$.
    obtain ⟨x, hx⟩ : ∃ x : ℚ, x ≥ max X₁ X₂ ∧ (β - α) * x > b₂ - b₃ := by
      exact ⟨ Max.max ( Max.max X₁ X₂ ) ( ( b₂ - b₃ ) / ( β - α ) + 1 ), le_max_left _ _, by nlinarith [ le_max_right ( Max.max X₁ X₂ ) ( ( b₂ - b₃ ) / ( β - α ) + 1 ), mul_div_cancel₀ ( b₂ - b₃ ) ( sub_ne_zero_of_ne hαβ.ne' ) ] ⟩;
    linarith [ h_lower₁ x ( le_trans ( le_max_left _ _ ) hx.1 ), h_upper₁ x, h_lower₂ x ( le_trans ( le_max_right _ _ ) hx.1 ), h_upper₂ x ];
  · by_cases hβα : β < α;
    · -- Choose $x$ large enough such that $(α - β) * x > b₄ - b₁$.
      obtain ⟨x, hx⟩ : ∃ x : ℚ, x ≥ max X₁ X₂ ∧ (α - β) * x > b₄ - b₁ := by
        exact ⟨ Max.max ( Max.max X₁ X₂ ) ( ( b₄ - b₁ ) / ( α - β ) + 1 ), le_max_left _ _, by nlinarith [ le_max_right ( Max.max X₁ X₂ ) ( ( b₄ - b₁ ) / ( α - β ) + 1 ), mul_div_cancel₀ ( b₄ - b₁ ) ( sub_ne_zero_of_ne hβα.ne' ) ] ⟩;
      grind;
    · grind

/-
**Scaling exponent uniqueness**: The scaling exponent is the unique rational slope
    that can sandwich the envelope. If some slope `β` also provides an eventual affine
    sandwich for the envelope, then `β` equals the scaling exponent.
-/
theorem TropicalProfile.scalingExponent_unique (P : TropicalProfile) {β b₃ b₄ X₂ : ℚ}
    (h_lower : ∀ x, x ≥ X₂ → β * x + b₃ ≤ P.envelope x)
    (h_upper : ∀ x, P.envelope x ≤ β * x + b₄) :
    β = P.scalingExponent := by
  have := TropicalProfile.envelope_sandwich P;
  exact affine_sandwich_slope_unique ( fun x hx => this.choose_spec.choose_spec.choose_spec.1 x hx ) ( fun x => this.choose_spec.choose_spec.choose_spec.2 x ) h_lower h_upper ▸ rfl

/-! ## Part II: Composition Laws for Tropical Profiles

We define two fundamental operations on tropical profiles — parallel and serial
composition — and prove that scaling exponents obey precise algebraic laws under
these operations. -/

/-- **Parallel composition** of tropical profiles: take the union of form sets.
    This models two computation paths that compete — the system uses whichever
    path achieves lower cost at any given scale. -/
def parallelProfile (P Q : TropicalProfile) : TropicalProfile where
  forms := P.forms ∪ Q.forms
  nonempty := by
    obtain ⟨f, hf⟩ := P.nonempty
    exact ⟨f, Finset.mem_union_left _ hf⟩

/-- **Serial composition** of tropical profiles: form all pairwise combinations of paths,
    adding slopes and intercepts. This models two stages of computation executed
    sequentially, where total cost is the sum of per-stage costs. -/
def serialProfile (P Q : TropicalProfile) : TropicalProfile where
  forms := (P.forms ×ˢ Q.forms).image
    (fun p => ⟨p.1.slope + p.2.slope, p.1.intercept + p.2.intercept⟩)
  nonempty := by
    obtain ⟨f, hf⟩ := P.nonempty
    obtain ⟨g, hg⟩ := Q.nonempty
    exact ⟨⟨f.slope + g.slope, f.intercept + g.intercept⟩,
      Finset.mem_image.mpr ⟨(f, g), Finset.mem_product.mpr ⟨hf, hg⟩, rfl⟩⟩

/-
**Parallel composition law**: The scaling exponent of a parallel composition is
    the minimum of the component scaling exponents.

    Intuitively, when two computation strategies compete, the one with the better
    (smaller) scaling exponent dominates at large scale.
-/
theorem scalingExponent_parallel (P Q : TropicalProfile) :
    (parallelProfile P Q).scalingExponent = min P.scalingExponent Q.scalingExponent := by
  unfold TropicalProfile.scalingExponent parallelProfile;
  rw [ Finset.inf'_union ]

/-
**Serial composition law**: The scaling exponent of a serial composition equals
    the sum of the component scaling exponents.

    This is the tropical analogue of "depth adds exponents": composing two stages
    with exponents α and β yields total exponent α + β.
-/
theorem scalingExponent_serial (P Q : TropicalProfile) :
    (serialProfile P Q).scalingExponent = P.scalingExponent + Q.scalingExponent := by
  -- The scaling exponent of the serial composition is the infimum of the slopes of the combined forms.
  simp [TropicalProfile.scalingExponent, serialProfile];
  refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le ];
  · obtain ⟨ a, ha ⟩ := TropicalProfile.scalingExponent_mem P; obtain ⟨ b, hb ⟩ := TropicalProfile.scalingExponent_mem Q; use a, b; aesop;
  · exact fun a b ha hb => add_le_add ( Finset.inf'_le _ ha ) ( Finset.inf'_le _ hb )

/-! ## Part III: Tropical Invariance Bridge

We prove the full invariance theorem: tropically equivalent profiles have the same
scaling exponent, and this extends to the composition operations. -/

/-- Tropical equivalence preserves the scaling exponent. -/
theorem TropicalProfile.scalingExponent_tropEquiv {P Q : TropicalProfile}
    (h : P.TropEquiv Q) : P.scalingExponent = Q.scalingExponent := by
  unfold TropicalProfile.scalingExponent TropicalProfile.TropEquiv at *
  congr 1

/-- Tropical equivalence preserves the envelope. -/
theorem TropicalProfile.envelope_tropEquiv {P Q : TropicalProfile}
    (h : P.TropEquiv Q) (x : ℚ) : P.envelope x = Q.envelope x := by
  unfold TropicalProfile.envelope TropicalProfile.TropEquiv at *
  congr 1

/-
**Main Bridge Theorem**: If two profiles are tropically equivalent and each admits
    an affine sandwich, then both sandwiches must have the same slope — which equals
    the common scaling exponent.
-/
theorem tropEquiv_forces_same_slope {P Q : TropicalProfile}
    (hEq : P.TropEquiv Q)
    {α β b₁ b₂ b₃ b₄ X₁ X₂ : ℚ}
    (hP_lower : ∀ x, x ≥ X₁ → α * x + b₁ ≤ P.envelope x)
    (hP_upper : ∀ x, P.envelope x ≤ α * x + b₂)
    (hQ_lower : ∀ x, x ≥ X₂ → β * x + b₃ ≤ Q.envelope x)
    (hQ_upper : ∀ x, Q.envelope x ≤ β * x + b₄) :
    α = β := by
  -- Since P.TropEquiv Q, we have P.envelope = Q.envelope (by envelope_tropEquiv).
  have h_envelope_eq : P.envelope = Q.envelope := by
    exact funext fun x => TropicalProfile.envelope_tropEquiv hEq x;
  exact affine_sandwich_slope_unique ( fun x hx => by simpa only [ h_envelope_eq ] using hP_lower x hx ) ( fun x => by simpa only [ h_envelope_eq ] using hP_upper x ) ( fun x hx => by simpa only [ h_envelope_eq ] using hQ_lower x hx ) ( fun x => by simpa only [ h_envelope_eq ] using hQ_upper x )

/-
Tropical equivalence is compatible with parallel composition.
-/
theorem tropEquiv_parallel {P₁ P₂ Q₁ Q₂ : TropicalProfile}
    (h₁ : P₁.TropEquiv P₂) (h₂ : Q₁.TropEquiv Q₂) :
    (parallelProfile P₁ Q₁).TropEquiv (parallelProfile P₂ Q₂) := by
  exact congr_arg₂ ( · ∪ · ) h₁ h₂

/-
Tropical equivalence is compatible with serial composition.
-/
theorem tropEquiv_serial {P₁ P₂ Q₁ Q₂ : TropicalProfile}
    (h₁ : P₁.TropEquiv P₂) (h₂ : Q₁.TropEquiv Q₂) :
    (serialProfile P₁ Q₁).TropEquiv (serialProfile P₂ Q₂) := by
  unfold TropicalProfile.TropEquiv at *;
  unfold serialProfile; aesop;

/-! ## Part IV: DAG-Level Theorems

We wrap the profile-level results at the DAG level for direct application. -/

/-- A weighted computation DAG, modeled by its tropical profile plus graph metadata. -/
structure WeightedDAG where
  numVertices : ℕ
  numEdges : ℕ
  profile : TropicalProfile

namespace WeightedDAG

def scalingExponent (G : WeightedDAG) : ℚ := G.profile.scalingExponent
def TropEquiv (G H : WeightedDAG) : Prop := G.profile.TropEquiv H.profile

/-- Serial composition of DAGs. -/
def serial (G H : WeightedDAG) : WeightedDAG where
  numVertices := G.numVertices + H.numVertices
  numEdges := G.numEdges + H.numEdges + 1  -- connecting edge
  profile := serialProfile G.profile H.profile

/-- Parallel composition of DAGs. -/
def parallel (G H : WeightedDAG) : WeightedDAG where
  numVertices := G.numVertices + H.numVertices
  numEdges := G.numEdges + H.numEdges
  profile := parallelProfile G.profile H.profile

/-- **Target A**: Tropically equivalent DAGs have identical scaling exponents. -/
theorem scalingExponent_of_tropEquiv {G H : WeightedDAG} (h : G.TropEquiv H) :
    G.scalingExponent = H.scalingExponent :=
  TropicalProfile.scalingExponent_tropEquiv h

/-- **Target C (serial)**: Serial composition adds scaling exponents. -/
theorem scalingExponent_serial_dag (G H : WeightedDAG) :
    (G.serial H).scalingExponent = G.scalingExponent + H.scalingExponent :=
  scalingExponent_serial G.profile H.profile

/-- **Target C (parallel)**: Parallel composition takes the minimum exponent. -/
theorem scalingExponent_parallel_dag (G H : WeightedDAG) :
    (G.parallel H).scalingExponent = min G.scalingExponent H.scalingExponent :=
  scalingExponent_parallel G.profile H.profile

/-- Tropical equivalence of DAGs is compatible with serial composition. -/
theorem tropEquiv_serial_dag {G₁ G₂ H₁ H₂ : WeightedDAG}
    (h₁ : G₁.TropEquiv G₂) (h₂ : H₁.TropEquiv H₂) :
    (G₁.serial H₁).TropEquiv (G₂.serial H₂) :=
  tropEquiv_serial h₁ h₂

/-- Tropical equivalence of DAGs is compatible with parallel composition. -/
theorem tropEquiv_parallel_dag {G₁ G₂ H₁ H₂ : WeightedDAG}
    (h₁ : G₁.TropEquiv G₂) (h₂ : H₁.TropEquiv H₂) :
    (G₁.parallel H₁).TropEquiv (G₂.parallel H₂) :=
  tropEquiv_parallel h₁ h₂

end WeightedDAG

/-! ## Part V: Concrete Verification

We verify the composition laws on explicit examples. -/

/-- A single-path profile with given slope and intercept. -/
def singletonProfile (s i : ℚ) : TropicalProfile where
  forms := {⟨s, i⟩}
  nonempty := ⟨⟨s, i⟩, Finset.mem_singleton_self _⟩

/-- The scaling exponent of a singleton profile is its slope. -/
theorem singletonProfile_exponent (s i : ℚ) :
    (singletonProfile s i).scalingExponent = s := by
  simp [singletonProfile, TropicalProfile.scalingExponent, Finset.inf'_singleton]

/-- Example: serial composition of two singleton profiles. -/
example : (serialProfile (singletonProfile (1/2) 0) (singletonProfile (1/3) 1)).scalingExponent
    = 5/6 := by
  rw [scalingExponent_serial, singletonProfile_exponent, singletonProfile_exponent]; norm_num

/-- Example: parallel composition of two singleton profiles. -/
example : (parallelProfile (singletonProfile (1/2) 0) (singletonProfile (1/3) 1)).scalingExponent
    = 1/3 := by
  rw [scalingExponent_parallel, singletonProfile_exponent, singletonProfile_exponent]; norm_num

end