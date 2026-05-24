/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Harmonic Research
-/
import Mathlib
import Pythagorean.ProbeComplexity.Defs
import Pythagorean.ProbeComplexity.Theorems

/-!
# Compression Profile of One-Object Categories from Monoids

This file establishes a complete classification of the probe complexity (compression
number) of one-object categories arising from monoids.

## Key Results

For a monoid `M`, the one-object category `SingleObj M` has morphisms given by
elements of `M` with composition `a ≫ b = b * a`.

1. **`rightDetects_of_monoid`**: Every monoid satisfies right detection — the identity
   element is a universal separator for right multiplication.

2. **`singleton_isSeparating_singleObj_iff`**: The singleton probe family `{⋆}` separates
   all morphisms in `SingleObj M` iff `RightDetects M` holds.

3. **`probeComplexity_singleObj_eq_one_iff`**: Complete classification:
   - `probeComplexity (SingleObj M) = 0` iff `Subsingleton M`.
   - `probeComplexity (SingleObj M) = 1` iff `Nontrivial M`.

4. **`rightDetects_iff_rightRegular_injective`**: Right detection is equivalent to
   injectivity of the right regular representation `M → End(M)`.

## Mathematical Significance

The key surprise is that every nontrivial monoid has probe complexity exactly 1: the
identity element `1 ∈ M`, viewed categorically as the identity morphism `𝟙_⋆`,
already separates all endomorphisms by postcomposition. This means the right regular
representation of any monoid is always faithful — a fact that is trivial once seen
(multiply by 1 on the right) but connects categorical compression to semigroup
representation theory in a non-obvious way.

## Cross-Domain Connections

- **Semigroup theory**: `RightDetects M` is faithfulness of the right Cayley
  representation `ρ : M → End(M)`, `ρ(a)(c) = a * c`.
- **Automata theory**: Each monoid element defines a transition function on states.
  Right detection says these transition functions are all distinct.
- **Category theory**: Probe complexity 1 means a single object suffices as a
  "categorical probe" to extract complete information about all endomorphisms.
-/

open CategoryTheory Finset Fintype

noncomputable section

universe u

/-! ## Algebraic Definitions -/

/-- A monoid `M` has **right detection** if any two distinct elements can be
distinguished by right multiplication: for all `a ≠ b`, there exists `c` with
`a * c ≠ b * c`. This is the algebraic content of Yoneda separation for the
one-object category `SingleObj M`. -/
def RightDetects (M : Type*) [Monoid M] : Prop :=
  ∀ ⦃a b : M⦄, a ≠ b → ∃ c : M, a * c ≠ b * c

/-- The **right regular embedding** sends each monoid element to its right
multiplication operator. This is the right Cayley representation. -/
def rightRegularEmbedding (M : Type*) [Monoid M] : M → (M → M) :=
  fun a c => a * c

/-- An element `z` is a **right zero** if `a * z = z` for all `a`.
Right zeros are "absorbing" on the right. -/
def IsRightZero (M : Type*) [Monoid M] (z : M) : Prop :=
  ∀ a : M, a * z = z

/-- `ObservableBySelf M` is the statement that the monoid is observable through
its own right action — the one-object analogue of categorical observability.
Definitionally equal to `RightDetects M`. -/
def ObservableBySelf (M : Type*) [Monoid M] : Prop := RightDetects M

/-! ## The Fundamental Theorem: Every Monoid is Right-Detecting -/

/-- **Every monoid satisfies right detection.**
The proof is elementary but conceptually important: if `a ≠ b`, then choosing
`c = 1` gives `a * 1 = a ≠ b = b * 1`. The identity element is a universal
separator for right multiplication.

This resolves the speculative conjecture "does right detection always hold?"
positively. The answer is that the identity element, which is the categorical
identity morphism `𝟙_⋆`, already does all the work. -/
theorem rightDetects_of_monoid (M : Type*) [Monoid M] : RightDetects M := by
  intro a b hab
  exact ⟨1, by simp [hab]⟩

/-- Every monoid is observable by its own right action. -/
theorem observableBySelf_of_monoid (M : Type*) [Monoid M] : ObservableBySelf M :=
  rightDetects_of_monoid M

/-! ## Equivalence with Right Regular Injectivity -/

/-- Right detection is equivalent to injectivity of the right regular
embedding `M → End(M)`. This identifies categorical probe separation with
faithfulness of the right Cayley representation. -/
theorem rightDetects_iff_rightRegular_injective
    (M : Type*) [Monoid M] :
    RightDetects M ↔ Function.Injective (rightRegularEmbedding M) := by
  constructor
  · intro hR a b heq
    by_contra hab
    obtain ⟨c, hc⟩ := hR hab
    exact hc (congr_fun heq c)
  · intro hinj a b hab
    by_contra h
    push_neg at h
    apply hab
    exact hinj (funext h)

/-- The right regular embedding of any monoid is injective. -/
theorem rightRegularEmbedding_injective (M : Type*) [Monoid M] :
    Function.Injective (rightRegularEmbedding M) :=
  (rightDetects_iff_rightRegular_injective M).mp (rightDetects_of_monoid M)

/-- Right detection is equivalent to the statement that distinct elements
have distinct transition functions. This is the automata-theoretic reading:
every monoid element has a unique transition profile on the state space `M`. -/
theorem rightDetects_iff_distinct_transition_functions
    (M : Type*) [Monoid M] :
    RightDetects M ↔
      ∀ ⦃a b : M⦄, (fun c => a * c) = (fun c => b * c) → a = b := by
  rw [rightDetects_iff_rightRegular_injective]
  rfl

/-! ## Negation Characterization -/

/-- Negation of right detection: there exist distinct elements with identical
right multiplication. For monoids this is vacuously impossible (the identity
separates everything), but the characterization is useful for the general
semigroup theory where no identity element is available. -/
theorem not_rightDetects_iff
    (M : Type*) [Monoid M] :
    ¬ RightDetects M ↔ ∃ a b : M, a ≠ b ∧ ∀ c : M, a * c = b * c := by
  constructor
  · intro h
    unfold RightDetects at h
    push_neg at h
    exact h
  · intro ⟨a, b, hab, heq⟩ hR
    obtain ⟨c, hc⟩ := hR hab
    exact hc (heq c)

/-- If two distinct elements have identical right multiplication, then
right detection fails. -/
theorem not_rightDetects_of_forall_mul_eq
    (M : Type*) [Monoid M]
    (a b : M) (hneq : a ≠ b)
    (h : ∀ c : M, a * c = b * c) :
    ¬ RightDetects M := by
  rw [not_rightDetects_iff]
  exact ⟨a, b, hneq, h⟩

/-- `¬ RightDetects M` is equivalent to non-injectivity of the right regular
representation. -/
theorem not_rightDetects_iff_not_injective_rightRegular
    (M : Type*) [Monoid M] :
    ¬ RightDetects M ↔
      ∃ a b : M, a ≠ b ∧ ∀ c : M, a * c = b * c :=
  not_rightDetects_iff M

/-! ## Group Case -/

/-- Groups satisfy right detection. This is a special case of
`rightDetects_of_monoid`, but we include it for emphasis: in a group,
one can also prove this by using `c = 1` or equivalently by right-cancelling
with `c⁻¹`. -/
theorem rightDetects_of_group (G : Type*) [Group G] : RightDetects G :=
  rightDetects_of_monoid G

/-! ## Bridge to Probe Complexity of SingleObj M -/

variable {M : Type u} [Monoid M]

/-- In `SingleObj M`, morphism composition satisfies `h ≫ f = f * h`.
This is the key definitional fact connecting categorical composition
to monoid multiplication. Note the reversal: categorical composition
reads right-to-left while monoid multiplication reads left-to-right. -/
theorem singleObj_comp (f h : SingleObj.star M ⟶ SingleObj.star M) :
    h ≫ f = f * h := rfl

set_option linter.unusedSectionVars false in
/-- `SingleObj M` is thin (all hom-sets subsingleton) iff `M` is subsingleton.
In a one-object category, thinness means there is at most one endomorphism,
which is exactly the condition that the monoid has at most one element. -/
theorem singleObj_thin_iff_subsingleton :
    (∀ (X Y : SingleObj M) (f g : X ⟶ Y), f = g) ↔ Subsingleton M := by
  constructor
  · intro h
    exact ⟨fun a b => h (SingleObj.star M) (SingleObj.star M) a b⟩
  · intro ⟨h⟩ _ _ f g
    exact h f g

/-- **Yoneda separation for monoid categories.**
The singleton probe family `{⋆}` is separating for `SingleObj M`
iff `RightDetects M`. This is the key translation theorem between
categorical probe separation and algebraic right detection.

The proof unfolds what it means for `{⋆}` to separate morphisms:
- Two morphisms `f, g : ⋆ ⟶ ⋆` are separated if there exists `h : ⋆ ⟶ ⋆`
  with `h ≫ f ≠ h ≫ g`.
- In `SingleObj M`, `h ≫ f = f * h`, so the condition becomes:
  there exists `c : M` with `f * c ≠ g * c`.
- This is exactly `RightDetects M`. -/
theorem singleton_isSeparating_singleObj_iff :
    ({SingleObj.star M} : ProbeFamily (SingleObj M)).IsSeparating ↔
      RightDetects M := by
  constructor
  · -- Forward: if the singleton probe separates, then RightDetects holds
    intro hS a b hab
    by_contra h
    push_neg at h
    apply hab
    apply hS (X := SingleObj.star M) (Y := SingleObj.star M) a b
    intro Z hZ c
    rw [Finset.mem_singleton] at hZ
    subst hZ
    -- c ≫ a = a * c = b * c = c ≫ b
    exact h c
  · -- Backward: if RightDetects, the singleton probe separates
    intro hR X Y f g hall
    by_contra hfg
    obtain ⟨c, hc⟩ := hR hfg
    apply hc
    exact hall (SingleObj.star M) (Finset.mem_singleton.mpr rfl) c

/-- The singleton probe family is always separating for `SingleObj M`,
because every monoid is right-detecting. -/
theorem singleton_separating_singleObj :
    ({SingleObj.star M} : ProbeFamily (SingleObj M)).IsSeparating :=
  singleton_isSeparating_singleObj_iff.mpr (rightDetects_of_monoid M)

/-- Alternative proof that the singleton probe separates: use the identity
morphism directly. For any `f g : ⋆ ⟶ ⋆`, if all precompositions agree,
then in particular `𝟙 ≫ f = 𝟙 ≫ g`, which gives `f * 1 = g * 1`, i.e. `f = g`. -/
theorem singleton_separating_singleObj' :
    ({SingleObj.star M} : ProbeFamily (SingleObj M)).IsSeparating := by
  intro X Y f g hall
  have := hall (SingleObj.star M) (Finset.mem_singleton.mpr rfl) (𝟙 X)
  show (f : M) = (g : M)
  have : (f : M) * 1 = (g : M) * 1 := this
  simpa using this

/-! ## Complete Classification of Probe Complexity -/

/-- **Theorem (κ = 0 classification).**
Probe complexity of `SingleObj M` is zero iff `M` is subsingleton (trivial).
This uses the thin category theorem from the catalog. -/
theorem probeComplexity_singleObj_eq_zero_iff :
    probeComplexity (SingleObj M) = 0 ↔ Subsingleton M := by
  constructor
  · intro h0
    rw [← singleObj_thin_iff_subsingleton]
    obtain ⟨P, hPcard, hPsep⟩ := probeComplexity_achieved (SingleObj M)
    rw [h0] at hPcard
    rw [Finset.card_eq_zero] at hPcard
    subst hPcard
    rw [← empty_isSeparating_iff]
    exact hPsep
  · intro ⟨hsub⟩
    exact probeComplexity_eq_zero_of_subsingleton_hom (fun _ _ f g => hsub f g)

/-- **Theorem (κ = 0 cardinal form).**
Probe complexity of `SingleObj M` is zero iff `M` has exactly one element. -/
theorem probeComplexity_singleObj_eq_zero_iff_card_eq_one
    [Fintype M] :
    probeComplexity (SingleObj M) = 0 ↔ Fintype.card M = 1 := by
  rw [probeComplexity_singleObj_eq_zero_iff]
  constructor
  · intro h
    have : Fintype.card M ≤ 1 := Fintype.card_le_one_iff_subsingleton.mpr h
    have : 0 < Fintype.card M := Fintype.card_pos
    omega
  · intro h
    exact Fintype.card_le_one_iff_subsingleton.mp (le_of_eq h)

/-- Probe complexity of `SingleObj M` is at most one, because the singleton
`{⋆}` is always a separating family. -/
theorem probeComplexity_singleObj_le_one :
    probeComplexity (SingleObj M) ≤ 1 := by
  calc probeComplexity (SingleObj M)
      ≤ ({SingleObj.star M} : ProbeFamily (SingleObj M)).card :=
        probeComplexity_le_of_separating _ _ singleton_separating_singleObj
    _ = 1 := Finset.card_singleton _

/-- **Main Classification Theorem (κ = 1 iff nontrivial).**
Probe complexity of `SingleObj M` equals 1 iff `M` is nontrivial.

The proof has two directions:

**Forward (κ = 1 → Nontrivial):** If κ = 1, then κ ≠ 0, so by the κ = 0
classification, `M` is not subsingleton, hence nontrivial.

**Backward (Nontrivial → κ = 1):** We show κ ≤ 1 (singleton is separating)
and κ ≥ 1 (since `M` is nontrivial, there exist distinct parallel morphisms,
so the empty family does not separate, forcing κ > 0). -/
theorem probeComplexity_singleObj_eq_one_iff [Fintype M] :
    probeComplexity (SingleObj M) = 1 ↔ Nontrivial M := by
  constructor
  · -- Forward: κ = 1 → Nontrivial M
    intro h1
    by_contra hnt
    rw [not_nontrivial_iff_subsingleton] at hnt
    have h0 := probeComplexity_singleObj_eq_zero_iff.mpr hnt
    omega
  · -- Backward: Nontrivial M → κ = 1
    intro ⟨a, b, hab⟩
    apply le_antisymm probeComplexity_singleObj_le_one
    rw [Nat.one_le_iff_ne_zero]
    intro h0
    have hsub := probeComplexity_singleObj_eq_zero_iff.mp h0
    exact hab (hsub.allEq a b)

/-- **Corollary (κ = 1 with RightDetects).**
For nontrivial finite monoids, probe complexity is 1 and right detection holds.
Combines the main classification with universality of right detection. -/
theorem probeComplexity_singleObj_eq_one_iff' [Fintype M] :
    probeComplexity (SingleObj M) = 1 ↔ Nontrivial M ∧ RightDetects M := by
  rw [probeComplexity_singleObj_eq_one_iff]
  exact ⟨fun h => ⟨h, rightDetects_of_monoid M⟩, fun ⟨h, _⟩ => h⟩

/-- **Corollary (groups).**
For a nontrivial group, probe complexity of `SingleObj G` is 1. -/
theorem probeComplexity_singleObj_group
    (G : Type u) [Group G] [Fintype G] [Nontrivial G] :
    probeComplexity (SingleObj G) = 1 :=
  probeComplexity_singleObj_eq_one_iff.mpr inferInstance

/-- **Complete dichotomy.**
The probe complexity of `SingleObj M` is either 0 or 1, with no other values
possible. This is a sharp algebraic dichotomy: the categorical compression
complexity of a monoid is completely determined by whether the monoid is trivial. -/
theorem probeComplexity_singleObj_dichotomy :
    probeComplexity (SingleObj M) = 0 ∨ probeComplexity (SingleObj M) = 1 := by
  have := probeComplexity_singleObj_le_one (M := M)
  omega

/-! ## Decidable Algorithm for Right Detection -/

/-- Decidable predicate for right detection on finite monoids.
For finite decidable-equality monoids, right detection is decidable
(and in fact always true, but this gives the computational procedure). -/
instance rightDetectsDecidable (M : Type*) [Monoid M] [Fintype M] [DecidableEq M] :
    Decidable (RightDetects M) :=
  inferInstanceAs (Decidable (∀ ⦃a b : M⦄, a ≠ b → ∃ c : M, a * c ≠ b * c))

/-- Computational verification: right detection always holds for any finite monoid,
as witnessed by the decidability instance returning `true`. -/
theorem rightDetects_decide_true (M : Type*) [Monoid M] [Fintype M] [DecidableEq M] :
    (decide (RightDetects M)) = true := by
  simp [decide_eq_true_eq]
  exact rightDetects_of_monoid M

/-! ## Right Zero Elements -/

/-- If `z` is a right zero (`a * z = z` for all `a`), then `z` cannot
distinguish any two elements by right multiplication. However, this does
not prevent right detection because the identity `1` still separates. -/
theorem rightZero_not_separating (z : M) (hz : IsRightZero M z) (a b : M) :
    a * z = b * z := by
  rw [hz a, hz b]

/-- Even in the presence of a right zero, right detection holds because
the identity element `1` separates all distinct pairs. -/
theorem rightDetects_despite_rightZero (_hz : ∃ z : M, IsRightZero M z) :
    RightDetects M :=
  rightDetects_of_monoid M

end