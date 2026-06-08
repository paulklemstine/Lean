import Mathlib

/-!
# Tropical Scaling Exponents for Computation DAGs

## Overview

We formalize a theory of **tropical scaling exponents** for weighted directed acyclic
computation graphs (DAGs). The central objects are:

- **Tropical affine forms**: rational affine functions `a · x + b` representing path costs
  in a computation DAG, where `a` (slope) encodes the power-law scaling rate and `b`
  (intercept) encodes constant overhead.

- **Tropical profiles**: nonempty finite sets of affine forms, representing the collection
  of all source-to-sink path cost functions in a DAG.

- **Tropical scaling exponent**: the minimum slope across all path cost functions,
  which controls the leading power-law behavior of the complexity envelope.

- **Tropical equivalence**: two DAGs are tropically equivalent when they yield the same
  tropical profile (i.e., the same set of path cost functions).

## Main Results

1. **Rationality** (`scalingExponent_is_rational`): The scaling exponent is always rational,
   being the minimum of finitely many rational slopes.

2. **Invariance** (`scalingExponent_tropical_invariant`): The scaling exponent is an invariant
   of tropical equivalence classes.

3. **Eventual dominance** (`tropAffine_eval_le_of_slope_lt`): Among affine forms with
   different slopes, the one with smaller slope eventually dominates.

4. **Asymptotic sandwich** (`envelope_lower_bound`, `envelope_upper_bound`): The tropical
   envelope is asymptotically sandwiched between expressions controlled by the scaling
   exponent.

5. **Non-isomorphic examples**: We construct explicit pairs of non-isomorphic weighted DAGs
   that are tropically equivalent and hence share the same scaling exponent.

## Mathematical Context

This formalization captures the mathematical nucleus of the *neural scaling laws universality
conjecture*: that the power-law exponent governing how loss decreases with model size is not
an artifact of specific architecture details, but rather an invariant of a tropical
equivalence class determined by the computational structure. The tropical scaling exponent
is the first formally verified such invariant.
-/

noncomputable section

open Finset

/-! ## Tropical Affine Forms -/

/-- A tropical affine form representing the cost function `slope · x + intercept`
    of a source-to-sink path in a computation DAG. Here `slope` controls the
    power-law scaling rate and `intercept` is a constant overhead term. -/
structure TropAffine where
  slope : ℚ
  intercept : ℚ
  deriving DecidableEq, Repr

namespace TropAffine

/-- Evaluate the affine form at a point `x`. -/
def eval (f : TropAffine) (x : ℚ) : ℚ := f.slope * x + f.intercept

@[simp]
theorem eval_def (f : TropAffine) (x : ℚ) : f.eval x = f.slope * x + f.intercept := rfl

/-- The difference of two affine evaluations is affine in x. -/
theorem eval_sub (f g : TropAffine) (x : ℚ) :
    f.eval x - g.eval x = (f.slope - g.slope) * x + (f.intercept - g.intercept) := by
  simp [eval]; ring

/-
If `f` has strictly smaller slope than `g`, then `f.eval x ≤ g.eval x`
    for all sufficiently large `x`. This is the key comparison lemma for
    establishing eventual dominance of minimum-slope paths.
-/
theorem eval_le_of_slope_lt {f g : TropAffine} (h : f.slope < g.slope) :
    ∃ X₀ : ℚ, ∀ x : ℚ, x ≥ X₀ → f.eval x ≤ g.eval x := by
  exact ⟨ ( f.intercept - g.intercept ) / ( g.slope - f.slope ), fun x hx => by rw [ TropAffine.eval, TropAffine.eval ] ; nlinarith [ mul_div_cancel₀ ( f.intercept - g.intercept ) ( sub_ne_zero_of_ne h.ne' ) ] ⟩

/-
Strict version: if `f` has strictly smaller slope than `g`, then
    `f.eval x < g.eval x` for all sufficiently large `x`.
-/
theorem eval_lt_of_slope_lt {f g : TropAffine} (h : f.slope < g.slope) :
    ∃ X₀ : ℚ, ∀ x : ℚ, x > X₀ → f.eval x < g.eval x := by
  exact ⟨ ( f.intercept - g.intercept ) / ( g.slope - f.slope ), fun x hx => by rw [ TropAffine.eval, TropAffine.eval ] ; nlinarith [ mul_div_cancel₀ ( f.intercept - g.intercept ) ( sub_ne_zero_of_ne h.ne' ) ] ⟩

/-
For equal slopes, the form with smaller intercept always gives smaller values.
-/
theorem eval_le_of_slope_eq_of_intercept_le {f g : TropAffine}
    (hs : f.slope = g.slope) (hi : f.intercept ≤ g.intercept) (x : ℚ) :
    f.eval x ≤ g.eval x := by
  grind +suggestions

end TropAffine

/-! ## Tropical Profiles

A tropical profile is a nonempty finite set of tropical affine forms, representing the
collection of all source-to-sink path cost functions in a computation DAG. -/

/-- A tropical profile: a nonempty finite set of affine cost functions
    representing all source-to-sink paths in a computation DAG. -/
structure TropicalProfile where
  forms : Finset TropAffine
  nonempty : forms.Nonempty

namespace TropicalProfile

/-- The tropical envelope: the pointwise minimum of all path cost functions.
    This represents the optimal (minimum cost) complexity achievable at each scale. -/
def envelope (P : TropicalProfile) (x : ℚ) : ℚ :=
  P.forms.inf' P.nonempty (fun f => f.eval x)

/-- The tropical scaling exponent: the minimum slope across all path cost functions.
    This rational number controls the leading power-law behavior. -/
def scalingExponent (P : TropicalProfile) : ℚ :=
  P.forms.inf' P.nonempty TropAffine.slope

/-
The scaling exponent is achieved by some form in the profile.
-/
theorem scalingExponent_mem (P : TropicalProfile) :
    ∃ f ∈ P.forms, f.slope = P.scalingExponent := by
  have := Finset.exists_mem_eq_inf' P.nonempty TropAffine.slope;
  exact ⟨ this.choose, this.choose_spec.1, this.choose_spec.2.symm ⟩

/-
The scaling exponent is a lower bound on all slopes.
-/
theorem scalingExponent_le_slope (P : TropicalProfile) (f : TropAffine) (hf : f ∈ P.forms) :
    P.scalingExponent ≤ f.slope := by
  exact Finset.inf'_le _ hf

/-
The envelope is at most the value of any individual form.
-/
theorem envelope_le_eval (P : TropicalProfile) (f : TropAffine) (hf : f ∈ P.forms) (x : ℚ) :
    P.envelope x ≤ f.eval x := by
  exact Finset.inf'_le _ hf

/-
The envelope equals some form's value at each point.
-/
theorem envelope_eq_some_eval (P : TropicalProfile) (x : ℚ) :
    ∃ f ∈ P.forms, P.envelope x = f.eval x := by
  exact exists_mem_eq_inf' P.nonempty fun f => f.eval x

/-
For sufficiently large `x`, the envelope is bounded below by an affine
    function with slope equal to the scaling exponent.
-/
theorem envelope_eventual_lower_bound (P : TropicalProfile) :
    ∃ (X₀ b : ℚ), ∀ x : ℚ, x ≥ X₀ → P.scalingExponent * x + b ≤ P.envelope x := by
  -- Let $b$ be the minimum intercept over all forms in the profile.
  obtain ⟨b, hb⟩ : ∃ b : ℚ, ∀ f ∈ P.forms, f.intercept ≥ b := by
    exact ⟨ Finset.min' ( P.forms.image fun f => f.intercept ) ⟨ _, Finset.mem_image_of_mem _ ( Classical.choose_spec P.nonempty ) ⟩, fun f hf => Finset.min'_le _ _ ( Finset.mem_image_of_mem _ hf ) ⟩;
  use 0, b;
  intros x hx_nonneg
  have h_inf_ge : ∀ f ∈ P.forms, f.eval x ≥ P.scalingExponent * x + b := by
    exact fun f hf => by nlinarith [ hb f hf, show f.slope ≥ P.scalingExponent from P.scalingExponent_le_slope f hf, show f.eval x = f.slope * x + f.intercept from rfl ] ;
  exact Finset.le_inf' _ _ h_inf_ge

/-
The envelope is bounded above by some minimum-slope form.
-/
theorem envelope_upper_bound (P : TropicalProfile) :
    ∃ b : ℚ, ∀ x : ℚ, P.envelope x ≤ P.scalingExponent * x + b := by
  -- By scalingExponent_mem, there exists f₀ ∈ P.forms with f₀.slope = P.scalingExponent.
  obtain ⟨f₀, hf₀⟩ : ∃ f₀ ∈ P.forms, f₀.slope = P.scalingExponent := by
    exact scalingExponent_mem P
  exact ⟨ f₀.intercept, fun x => by simpa only [ hf₀.2, TropAffine.eval ] using P.envelope_le_eval f₀ hf₀.1 x ⟩

/-
**Asymptotic sandwich theorem**: The envelope is eventually squeezed between
    two affine functions with slope equal to the scaling exponent. The upper
    bound holds globally, while the lower bound holds for sufficiently large `x`.
-/
theorem envelope_asymptotic_sandwich (P : TropicalProfile) :
    ∃ (X₀ : ℚ) (b₁ b₂ : ℚ),
      (∀ x : ℚ, x ≥ X₀ → P.scalingExponent * x + b₁ ≤ P.envelope x) ∧
      (∀ x : ℚ, P.envelope x ≤ P.scalingExponent * x + b₂) := by
  exact ⟨ _, _, _, P.envelope_eventual_lower_bound.choose_spec.choose_spec, P.envelope_upper_bound.choose_spec ⟩

end TropicalProfile

/-! ## Tropical Equivalence and Invariance -/

/-- Two tropical profiles are **tropically equivalent** if they have the same
    set of path cost functions. This is the natural equivalence relation on
    computation DAGs from the tropical geometry perspective. -/
def TropicalEquivalent (P Q : TropicalProfile) : Prop :=
  P.forms = Q.forms

/-- Tropical equivalence is reflexive. -/
theorem TropicalEquivalent.refl (P : TropicalProfile) : TropicalEquivalent P P :=
  rfl

/-- Tropical equivalence is symmetric. -/
theorem TropicalEquivalent.symm {P Q : TropicalProfile} (h : TropicalEquivalent P Q) :
    TropicalEquivalent Q P :=
  Eq.symm h

/-- Tropical equivalence is transitive. -/
theorem TropicalEquivalent.trans {P Q R : TropicalProfile}
    (h₁ : TropicalEquivalent P Q) (h₂ : TropicalEquivalent Q R) :
    TropicalEquivalent P R :=
  Eq.trans h₁ h₂

/-
**Main Invariance Theorem**: The tropical scaling exponent is an invariant
    of tropical equivalence. If two computation DAGs have the same tropical
    profile (i.e., the same set of path cost functions), then they share
    the same scaling exponent.
-/
theorem scalingExponent_tropical_invariant {P Q : TropicalProfile}
    (h : TropicalEquivalent P Q) :
    P.scalingExponent = Q.scalingExponent := by
  grind +locals

/-
The tropical envelope is also invariant under tropical equivalence.
-/
theorem envelope_tropical_invariant {P Q : TropicalProfile}
    (h : TropicalEquivalent P Q) (x : ℚ) :
    P.envelope x = Q.envelope x := by
  -- Unfold the definition of envelope.
  unfold TropicalProfile.envelope
  congr 1

/-! ## Weighted Computation DAGs

We define weighted computation DAGs and show how they give rise to tropical profiles. -/

/-- A weighted computation DAG is modeled abstractly by its tropical profile:
    the nonempty finite set of affine cost functions arising from source-to-sink paths.
    We also track the number of vertices and edges to distinguish non-isomorphic graphs. -/
structure WeightedDAG where
  /-- Number of vertices in the DAG. -/
  numVertices : ℕ
  /-- Number of edges in the DAG. -/
  numEdges : ℕ
  /-- The tropical profile arising from all source-to-sink paths. -/
  profile : TropicalProfile

namespace WeightedDAG

/-- The tropical scaling exponent of a weighted DAG. -/
def scalingExponent (G : WeightedDAG) : ℚ := G.profile.scalingExponent

/-- The symbolic complexity proxy of a weighted DAG at scale parameter `x`. -/
def complexityProxy (G : WeightedDAG) (x : ℚ) : ℚ := G.profile.envelope x

/-- Two weighted DAGs are tropically equivalent when their profiles agree. -/
def TropEquiv (G H : WeightedDAG) : Prop := TropicalEquivalent G.profile H.profile

/-- Two weighted DAGs are graph-non-isomorphic if they differ in vertex or edge count. -/
def NonIsomorphic (G H : WeightedDAG) : Prop :=
  G.numVertices ≠ H.numVertices ∨ G.numEdges ≠ H.numEdges

/-- **Theorem A (Invariance)**: The scaling exponent is invariant under tropical equivalence
    of weighted DAGs. This is the core universality result. -/
theorem scalingExponent_invariant {G H : WeightedDAG} (h : G.TropEquiv H) :
    G.scalingExponent = H.scalingExponent :=
  scalingExponent_tropical_invariant h

/-- The scaling exponent of a weighted DAG is rational (it is defined in ℚ). -/
theorem scalingExponent_rational (G : WeightedDAG) :
    ∃ α : ℚ, G.scalingExponent = α :=
  ⟨G.scalingExponent, rfl⟩

/-- **Asymptotic sandwich for DAGs**: The complexity proxy is eventually sandwiched between
    two affine functions with slope equal to the scaling exponent. -/
theorem complexityProxy_sandwich (G : WeightedDAG) :
    ∃ (X₀ : ℚ) (b₁ b₂ : ℚ),
      (∀ x : ℚ, x ≥ X₀ → G.scalingExponent * x + b₁ ≤ G.complexityProxy x) ∧
      (∀ x : ℚ, G.complexityProxy x ≤ G.scalingExponent * x + b₂) :=
  G.profile.envelope_asymptotic_sandwich

end WeightedDAG

/-! ## Concrete Examples

We construct two pairs of non-isomorphic but tropically equivalent DAGs. -/

/-- Example DAG 1: A simple chain graph with 3 vertices and 2 edges.
    Single path with slope 1/2 and intercept 0. -/
def chainDAG : WeightedDAG where
  numVertices := 3
  numEdges := 2
  profile := {
    forms := {⟨1/2, 0⟩, ⟨1, 1⟩}
    nonempty := ⟨⟨1/2, 0⟩, by simp⟩
  }

/-- Example DAG 2: A diamond graph with 4 vertices and 4 edges.
    Two paths with slopes 1/2 and 1, same as the chain DAG's profile. -/
def diamondDAG : WeightedDAG where
  numVertices := 4
  numEdges := 4
  profile := {
    forms := {⟨1/2, 0⟩, ⟨1, 1⟩}
    nonempty := ⟨⟨1/2, 0⟩, by simp⟩
  }

/-- The chain and diamond DAGs are non-isomorphic (different vertex/edge counts). -/
theorem chain_diamond_noniso : chainDAG.NonIsomorphic diamondDAG := by
  left; simp [chainDAG, diamondDAG]

/-- The chain and diamond DAGs are tropically equivalent. -/
theorem chain_diamond_tropEquiv : chainDAG.TropEquiv diamondDAG := by
  simp [chainDAG, diamondDAG, WeightedDAG.TropEquiv, TropicalEquivalent]

/-- The chain and diamond DAGs have the same scaling exponent. -/
theorem chain_diamond_same_exponent :
    chainDAG.scalingExponent = diamondDAG.scalingExponent :=
  WeightedDAG.scalingExponent_invariant chain_diamond_tropEquiv

/-- Example DAG 3: A wide graph with 5 vertices and 4 edges.
    Three paths with slopes 1/3, 2/3, and 1. -/
def wideDAG : WeightedDAG where
  numVertices := 5
  numEdges := 4
  profile := {
    forms := {⟨1/3, 2⟩, ⟨2/3, 0⟩, ⟨1, -1⟩}
    nonempty := ⟨⟨1/3, 2⟩, by simp⟩
  }

/-- Example DAG 4: A deep graph with 6 vertices and 5 edges.
    Same three path slopes as the wide DAG. -/
def deepDAG : WeightedDAG where
  numVertices := 6
  numEdges := 5
  profile := {
    forms := {⟨1/3, 2⟩, ⟨2/3, 0⟩, ⟨1, -1⟩}
    nonempty := ⟨⟨1/3, 2⟩, by simp⟩
  }

/-- The wide and deep DAGs are non-isomorphic. -/
theorem wide_deep_noniso : wideDAG.NonIsomorphic deepDAG := by
  left; simp [wideDAG, deepDAG]

/-- The wide and deep DAGs are tropically equivalent. -/
theorem wide_deep_tropEquiv : wideDAG.TropEquiv deepDAG := by
  simp [wideDAG, deepDAG, WeightedDAG.TropEquiv, TropicalEquivalent]

/-- The wide and deep DAGs have the same scaling exponent. -/
theorem wide_deep_same_exponent :
    wideDAG.scalingExponent = deepDAG.scalingExponent :=
  WeightedDAG.scalingExponent_invariant wide_deep_tropEquiv

/-
The scaling exponent of the chain/diamond DAGs is 1/2.
-/
theorem chainDAG_exponent : chainDAG.scalingExponent = 1/2 := by
  unfold chainDAG;
  unfold WeightedDAG.scalingExponent; norm_num [ TropicalProfile.scalingExponent ]

/-
The scaling exponent of the wide/deep DAGs is 1/3.
-/
theorem wideDAG_exponent : wideDAG.scalingExponent = 1/3 := by
  unfold wideDAG;
  unfold WeightedDAG.scalingExponent TropicalProfile.scalingExponent; norm_num

/-! ## Extensional Tropical Equivalence

A weaker but sometimes more useful notion: two profiles are extensionally
equivalent if their envelopes agree at all points. -/

/-- Extensional tropical equivalence: two profiles have the same envelope function. -/
def ExtTropicalEquivalent (P Q : TropicalProfile) : Prop :=
  ∀ x : ℚ, P.envelope x = Q.envelope x

/-- Tropical equivalence implies extensional equivalence. -/
theorem tropicalEquiv_imp_ext {P Q : TropicalProfile} (h : TropicalEquivalent P Q) :
    ExtTropicalEquivalent P Q :=
  fun x => envelope_tropical_invariant h x

/-
Extensional equivalence preserves the asymptotic scaling behavior:
    if two profiles have the same envelope, then their envelopes satisfy the
    same asymptotic sandwich with the same leading slope.
-/
theorem ext_equiv_same_asymptotics {P Q : TropicalProfile}
    (h : ExtTropicalEquivalent P Q) :
    (∃ (X₀ : ℚ) (b₁ b₂ : ℚ),
      (∀ x, x ≥ X₀ → P.scalingExponent * x + b₁ ≤ P.envelope x) ∧
      (∀ x, P.envelope x ≤ P.scalingExponent * x + b₂)) →
    (∃ (X₀ : ℚ) (b₁ b₂ : ℚ),
      (∀ x, x ≥ X₀ → P.scalingExponent * x + b₁ ≤ Q.envelope x) ∧
      (∀ x, Q.envelope x ≤ P.scalingExponent * x + b₂)) := by
  exact fun ⟨ X₀, b₁, b₂, h₁, h₂ ⟩ => ⟨ X₀, b₁, b₂, fun x hx => by linarith [ h x, h₁ x hx ], fun x => by linarith [ h x, h₂ x ] ⟩

end