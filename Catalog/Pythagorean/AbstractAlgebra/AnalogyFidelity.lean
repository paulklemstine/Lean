import Mathlib

/-!
# Analogy as a mathematical operation: the discrete (function) model

An *analogy* between two conceptual carriers `A` and `B` is a pair of maps
`fwd : A → B` and `bwd : B → A`.  The `fwd` map interprets each source concept
as a target concept; the `bwd` map interprets each target concept back in the
source.  The *round trip* `bwd ∘ fwd : A → A` measures how faithfully the source
is recovered after being pushed through the target.

The **fidelity** of an analogy counts the source concepts fixed by the round
trip: these are exactly the concepts whose meaning survives the translation
`A → B → A` intact.  The identity analogy — the *Copycat* analogy — fixes every
concept and hence attains the maximum fidelity.  This file develops the algebra
of this discrete model:

* fidelity is bounded by the number of source concepts, with equality exactly
  when the round trip is the identity (`fidelity_eq_card_iff`);
* the Copycat analogy attains the bound (`copycat_fidelity`);
* every maximiser is a split monomorphism, i.e. its forward map is injective
  (`fwd_injective_of_perfect`); in the self-finite case the maximisers are
  precisely the permutations of the carrier (`perfect_iff_bijective_selfFinite`);
* the Copycat analogy is *not* the unique maximiser: Boolean negation gives a
  second one (`boolFlip_perfect`, `boolFlip_ne_copycat`);
* **two-sided** fidelity is maximal exactly when the two maps are mutually
  inverse, i.e. `A` and `B` are in bijection (`twoSided_max_iff`), yielding an
  explicit equivalence (`equivOfPerfect`);
* **weighted** fidelity is monotone in the weights and, for strictly positive
  weights, is total exactly for the maximisers (`weightedFidelity_mono`,
  `weightedFidelity_eq_total_iff`);
* analogies **compose**, and perfect fidelity is preserved under composition
  (`comp_perfect`), so the Copycat analogy behaves as a two-sided identity.

This is the discrete-category base case of the general categorical picture, in
which carriers are replaced by categories and the maps by functors, and one
measures the agreement of `bwd ∘ fwd` with the identity functor.

-- !-- Lab Notes -- !--

**Hypothesis.**  A one-sided notion of analogical fidelity — count the source
concepts a round trip returns unchanged — should (i) be maximised by the
identity analogy, (ii) fail to characterise the identity uniquely, and (iii)
upgrade to a two-sided notion that *does* force a bijection.  We further
conjectured that weighting concepts preserves the extremal structure and that
fidelity is functorial under composition.

**Experiment.**  We formalised the model over finite carriers and tested each
claim.  The maximum-fidelity condition is exactly `bwd ∘ fwd = id`, which is a
split monomorphism, so maximisers need not be surjective; over a self-finite
carrier finiteness upgrades injectivity to bijectivity, recovering permutations.
The Boolean negation `not` satisfies `not ∘ not = id`, giving an explicit second
maximiser distinct from Copycat.

**Analysis.**  The gap between "one-sided maximum" (split mono) and "identity"
is precisely the failure of surjectivity, which is invisible one-sidedly but
detected by scoring the reverse round trip.  Summing over both carriers makes the
maximum equal `|A| + |B|` iff both round trips are identities, i.e. iff the maps
form an equivalence — cleanly contrasting the intentionally one-sided base
notion.  Positive weights do not disturb the extremal characterisation because a
single unfixed concept strictly lowers a strictly-positive-weighted sum.

**Critique.**  We checked that no theorem is vacuous: the bound
`fidelity_le_card` is a genuine inequality; `fidelity_eq_card_iff` is a real
biconditional; `boolFlip_ne_copycat` exhibits a concrete distinct optimiser, so
the maximiser set is provably non-singleton.  Composition preserves perfection
(`comp_perfect`) and Copycat is a two-sided unit, confirming the model is a
monoid-like structure on analogies rather than a triviality.

**Synthesis.**  The discrete model is a faithful, non-trivial base case whose
extremal theory (split monos one-sidedly, equivalences two-sidedly) is exactly
what one expects to persist when carriers become categories and maps become
functors.
-/

namespace Pythagorean.AnalogyFidelity

open Finset
open scoped Classical

/-- An analogy between conceptual carriers `A` and `B`: a forward interpretation
`fwd : A → B` together with a backward interpretation `bwd : B → A`. -/
structure Analogy (A B : Type*) where
  /-- Interpret a source concept as a target concept. -/
  fwd : A → B
  /-- Interpret a target concept back in the source. -/
  bwd : B → A

variable {A B C : Type*}

/-- The round trip on the source carrier: push forward, then pull back. -/
def Analogy.roundTrip (φ : Analogy A B) : A → A := fun a => φ.bwd (φ.fwd a)

/-- The reverse analogy, swapping the roles of the two carriers. -/
def Analogy.reverse (φ : Analogy A B) : Analogy B A := ⟨φ.bwd, φ.fwd⟩

/-- The identity analogy on a carrier: the *Copycat* analogy. -/
def Analogy.copycat (A : Type*) : Analogy A A := ⟨id, id⟩

/-- An analogy is *perfect* when its round trip fixes every source concept. -/
def Analogy.Perfect (φ : Analogy A B) : Prop := ∀ a, φ.roundTrip a = a

/-- One-sided fidelity: the number of source concepts fixed by the round trip. -/
noncomputable def Analogy.fidelity [Fintype A] (φ : Analogy A B) : ℕ :=
  (Finset.univ.filter (fun a => φ.roundTrip a = a)).card

/-- Fidelity never exceeds the number of source concepts. -/
theorem fidelity_le_card [Fintype A] (φ : Analogy A B) :
    φ.fidelity ≤ Fintype.card A := by
  rw [Analogy.fidelity]
  exact le_trans (Finset.card_filter_le _ _) (le_of_eq (Finset.card_univ))

/-- Fidelity attains its maximum exactly for perfect analogies. -/
theorem fidelity_eq_card_iff [Fintype A] (φ : Analogy A B) :
    φ.fidelity = Fintype.card A ↔ φ.Perfect := by
  rw [Analogy.fidelity, Finset.card_eq_iff_eq_univ, Finset.filter_eq_self]
  constructor
  · intro h a; exact h a (mem_univ a)
  · intro h a _; exact h a

/-- The Copycat analogy is a maximiser: it fixes every concept. -/
theorem copycat_fidelity [Fintype A] :
    (Analogy.copycat A).fidelity = Fintype.card A :=
  (fidelity_eq_card_iff _).mpr (fun _ => rfl)

/-- A maximiser is a split monomorphism: its forward map is injective. -/
theorem fwd_injective_of_perfect (φ : Analogy A B) (h : φ.Perfect) :
    Function.Injective φ.fwd := by
  have hli : Function.LeftInverse φ.bwd φ.fwd := h
  exact hli.injective

/-- In the self-finite case, the maximisers are exactly the permutations of the
carrier: the forward map is a bijection and the backward map is its inverse. -/
theorem perfect_iff_bijective_selfFinite [Fintype A] (φ : Analogy A A) :
    φ.Perfect ↔ Function.Bijective φ.fwd ∧ (∀ a, φ.fwd (φ.bwd a) = a) := by
  constructor
  · intro h
    have hli : Function.LeftInverse φ.bwd φ.fwd := h
    have hbij := (Finite.injective_iff_bijective).mp hli.injective
    exact ⟨hbij, hli.rightInverse_of_surjective hbij.surjective⟩
  · rintro ⟨hbij, h2⟩
    have h2' : Function.LeftInverse φ.fwd φ.bwd := h2
    exact fun a => h2'.rightInverse_of_injective hbij.injective a

/-- The Boolean-negation analogy: `not` in both directions. -/
def boolFlip : Analogy Bool Bool := ⟨not, not⟩

/-- The Boolean flip is a maximiser: `not ∘ not = id`. -/
theorem boolFlip_perfect : boolFlip.Perfect := by intro a; cases a <;> rfl

/-- The Boolean flip is a *different* maximiser from Copycat, so Copycat is not
the unique optimiser. -/
theorem boolFlip_ne_copycat : boolFlip ≠ Analogy.copycat Bool := by
  intro h
  have h2 := congrArg Analogy.fwd h
  have := congrFun h2 true
  simp [boolFlip, Analogy.copycat] at this

/-- Two-sided fidelity: source concepts preserved plus target concepts
preserved. -/
noncomputable def Analogy.twoSided [Fintype A] [Fintype B] (φ : Analogy A B) : ℕ :=
  φ.fidelity + φ.reverse.fidelity

/-- Two-sided fidelity is maximal exactly when both round trips are identities,
i.e. the two maps are mutually inverse. -/
theorem twoSided_max_iff [Fintype A] [Fintype B] (φ : Analogy A B) :
    φ.twoSided = Fintype.card A + Fintype.card B ↔
      (∀ a, φ.bwd (φ.fwd a) = a) ∧ (∀ b, φ.fwd (φ.bwd b) = b) := by
  rw [Analogy.twoSided]
  constructor
  · intro h
    have hA := fidelity_le_card φ
    have hB := fidelity_le_card φ.reverse
    have eA : φ.fidelity = Fintype.card A := by omega
    have eB : φ.reverse.fidelity = Fintype.card B := by omega
    exact ⟨(fidelity_eq_card_iff φ).mp eA, (fidelity_eq_card_iff φ.reverse).mp eB⟩
  · rintro ⟨h1, h2⟩
    rw [(fidelity_eq_card_iff φ).mpr h1, (fidelity_eq_card_iff φ.reverse).mpr h2]

/-- From a two-sided maximiser one extracts an explicit equivalence `A ≃ B`. -/
def equivOfPerfect (φ : Analogy A B)
    (h₁ : ∀ a, φ.bwd (φ.fwd a) = a) (h₂ : ∀ b, φ.fwd (φ.bwd b) = b) : A ≃ B where
  toFun := φ.fwd
  invFun := φ.bwd
  left_inv := h₁
  right_inv := h₂

/-- Weighted fidelity: sum of the weights of the concepts fixed by the round
trip. -/
noncomputable def Analogy.weightedFidelity [Fintype A] (w : A → ℕ)
    (φ : Analogy A B) : ℕ :=
  ∑ a ∈ Finset.univ.filter (fun a => φ.roundTrip a = a), w a

/-- Weighted fidelity is monotone in the weights. -/
theorem weightedFidelity_mono [Fintype A] (φ : Analogy A B) {w₁ w₂ : A → ℕ}
    (h : ∀ a, w₁ a ≤ w₂ a) : φ.weightedFidelity w₁ ≤ φ.weightedFidelity w₂ := by
  rw [Analogy.weightedFidelity, Analogy.weightedFidelity]
  exact Finset.sum_le_sum (fun a _ => h a)

/-- Weighted fidelity is bounded by the total weight. -/
theorem weightedFidelity_le_total [Fintype A] (φ : Analogy A B) (w : A → ℕ) :
    φ.weightedFidelity w ≤ ∑ a, w a := by
  rw [Analogy.weightedFidelity]
  exact Finset.sum_le_sum_of_subset (Finset.filter_subset _ _)

/-- For strictly positive weights, weighted fidelity equals the total weight
exactly for the maximisers. -/
theorem weightedFidelity_eq_total_iff [Fintype A] (φ : Analogy A B) (w : A → ℕ)
    (hw : ∀ a, 0 < w a) :
    φ.weightedFidelity w = ∑ a, w a ↔ φ.Perfect := by
  constructor
  · intro h
    by_contra hc
    unfold Analogy.Perfect at hc
    push_neg at hc
    obtain ⟨a0, ha0⟩ := hc
    rw [Analogy.weightedFidelity] at h
    have hsub : univ.filter (fun a => φ.roundTrip a = a) ⊆ univ := filter_subset _ _
    have hlt : (∑ a ∈ univ.filter (fun a => φ.roundTrip a = a), w a) < ∑ a, w a := by
      apply Finset.sum_lt_sum_of_subset hsub (i := a0) (mem_univ a0)
      · simp [ha0]
      · exact hw a0
      · intro j _ _; exact Nat.zero_le _
    omega
  · intro h
    rw [Analogy.weightedFidelity]
    have : (univ.filter (fun a => φ.roundTrip a = a)) = univ :=
      Finset.filter_true_of_mem (fun a _ => h a)
    rw [this]

/-- Composition of analogies: compose forward maps and (in reverse) backward
maps. -/
def Analogy.comp (ψ : Analogy B C) (φ : Analogy A B) : Analogy A C :=
  ⟨ψ.fwd ∘ φ.fwd, φ.bwd ∘ ψ.bwd⟩

/-- Perfect fidelity is preserved under composition: composing two maximisers
yields a maximiser. -/
theorem comp_perfect (ψ : Analogy B C) (φ : Analogy A B)
    (hψ : ψ.Perfect) (hφ : φ.Perfect) : (ψ.comp φ).Perfect := by
  intro a
  show φ.bwd (ψ.bwd (ψ.fwd (φ.fwd a))) = a
  rw [show ψ.bwd (ψ.fwd (φ.fwd a)) = φ.fwd a from hψ (φ.fwd a)]
  exact hφ a

/-- The Copycat analogy is a left identity for composition. -/
theorem copycat_comp (φ : Analogy A B) : (Analogy.copycat B).comp φ = φ := rfl

/-- The Copycat analogy is a right identity for composition. -/
theorem comp_copycat (φ : Analogy A B) : φ.comp (Analogy.copycat A) = φ := rfl

end Pythagorean.AnalogyFidelity