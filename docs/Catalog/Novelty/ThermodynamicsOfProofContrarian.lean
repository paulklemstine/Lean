import Mathlib

/-!
# Thermodynamics of Mathematical Proof — Contrarian Conjectures

This companion file (fully self-contained) tests several **bold conjectures** about the
information-erasure cost of proof steps.  For each we either prove it or refute it with an
explicit counterexample.  Disproofs are first-class results here.

We reuse the same model as `ThermodynamicsOfProof`: a proof step is a function `f : α → β`
between finite state spaces, and

  `erasedBits f = log₂ (card α) − log₂ (image size of f)`.

## Conjectures adjudicated

* **Refuted** — *"Every non-identity proof step erases information."*
  (`exists_reversible_nontrivial_step`): the NOT gate is a non-identity bijection that erases
  zero bits.  Logical *irreversibility*, not activity, is what costs entropy.

* **Confirmed (textbook Landauer)** — *"The AND gate erases exactly one bit."*
  (`erasedBits_andGate`): `∧ : Bool² → Bool` is `3`-to-`1` on `false`, collapsing `4` states
  to `2`, so it erases `log₂ 4 − log₂ 2 = 1` bit — the canonical `kT ln 2` dissipation.

* **Refuted** — *"Erasure is additive under composition."*
  (`erasedBits_not_additive`): two constant steps on `Fin 2` compose to a step erasing `1`
  bit, not `1 + 1 = 2`.  Erasure is *sub*-additive (indeed idempotent here), not additive.

* **Confirmed** — *"Every bijection (reversible step) erases zero bits."*
  (`erasedBits_bijective_zero`).
-/

open Finset Real

namespace ThermoProofContrarian

/-! ## Minimal self-contained model -/

/-- The number of distinct outputs of `f`. -/
def imageCard {α β : Type*} [Fintype α] [DecidableEq β] (f : α → β) : ℕ :=
  (Finset.univ.image f).card

lemma imageCard_of_injective {α β : Type*} [Fintype α] [DecidableEq β] {f : α → β}
    (hf : Function.Injective f) : imageCard f = Fintype.card α := by
  unfold imageCard; rw [Finset.card_image_of_injective _ hf]; simp [Finset.card_univ]

lemma imageCard_const {γ δ : Type*} [Fintype γ] [DecidableEq δ] [Nonempty γ] (c : δ) :
    imageCard (fun _ : γ => c) = 1 := by
  unfold imageCard; rw [Finset.image_const Finset.univ_nonempty]; simp

/-- Bits of information erased by one step `f`. -/
noncomputable def erasedBits {α β : Type*} [Fintype α] [DecidableEq β] (f : α → β) : ℝ :=
  Real.logb 2 (Fintype.card α) - Real.logb 2 (imageCard f)

lemma erasedBits_const {γ δ : Type*} [Fintype γ] [DecidableEq δ] [Nonempty γ] (c : δ) :
    erasedBits (fun _ : γ => c) = Real.logb 2 (Fintype.card γ) := by
  unfold erasedBits; rw [imageCard_const]; simp

/-! ## Confirmed: reversible steps are free -/

/-- **Confirmed.** Every bijection erases zero bits: a reversible step is thermodynamically
free. -/
theorem erasedBits_bijective_zero {α β : Type*} [Fintype α] [DecidableEq β] {f : α → β}
    (hf : Function.Bijective f) : erasedBits f = 0 := by
  unfold erasedBits; rw [imageCard_of_injective hf.1]; ring

/-! ## Refuted: not every non-identity step erases -/

/-- **Refuted:** *"every non-identity proof step erases information."*  The NOT gate is a
non-identity bijection erasing zero bits — computation without erasure. -/
theorem exists_reversible_nontrivial_step :
    ∃ f : Bool → Bool, Function.Bijective f ∧ f ≠ id ∧ erasedBits f = 0 := by
  have hbij : Function.Bijective (not) := by
    constructor
    · intro a b h; simpa using h
    · intro b; exact ⟨not b, by cases b <;> rfl⟩
  refine ⟨not, hbij, ?_, erasedBits_bijective_zero hbij⟩
  intro h; have := congrArg (fun g => g true) h; simp at this

/-! ## Confirmed: the AND gate is the textbook Landauer erasure -/

/-- The Boolean AND gate as a proof/computation step `Bool² → Bool`. -/
noncomputable def andGate : Bool × Bool → Bool := fun p => p.1 && p.2

/-- **Confirmed (textbook Landauer).** The AND gate erases exactly one bit: it collapses the
`4` input states onto `2` output states, dissipating `log₂ 4 − log₂ 2 = 1` bit. -/
theorem erasedBits_andGate : erasedBits andGate = 1 := by
  have him : imageCard andGate = 2 := by decide
  have hcard : Fintype.card (Bool × Bool) = 4 := by decide
  unfold erasedBits
  rw [him, hcard]
  push_cast
  have h4 : Real.logb 2 4 = 2 := by
    rw [show (4:ℝ) = 2^(2:ℕ) by norm_num, Real.logb_pow]
    simp [Real.logb_self_eq_one]
  rw [h4, Real.logb_self_eq_one (by norm_num : (1:ℝ) < 2)]; norm_num

/-! ## Refuted: erasure is not additive under composition -/

/-- **Refuted:** *"erasure is additive under composition."*  Two constant steps on `Fin 2`
each erase `1` bit, yet their composite still erases only `1` bit, not `2`. -/
theorem erasedBits_not_additive :
    ∃ (f g : Fin 2 → Fin 2), erasedBits (g ∘ f) ≠ erasedBits f + erasedBits g := by
  refine ⟨(fun _ => 0), (fun _ => 0), ?_⟩
  have hgf : (fun _ : Fin 2 => (0:Fin 2)) ∘ (fun _ : Fin 2 => (0:Fin 2))
      = (fun _ => 0) := rfl
  have e1 : erasedBits (fun _ : Fin 2 => (0:Fin 2)) = 1 := by
    rw [erasedBits_const]; simp [Fintype.card_fin, Real.logb_self_eq_one]
  rw [hgf, e1]; norm_num

end ThermoProofContrarian