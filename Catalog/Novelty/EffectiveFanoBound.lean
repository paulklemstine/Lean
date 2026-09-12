/-
# An effective Fano bound: undecodable channels err infinitely often

`Catalog/Novelty/BoundedError.lean` proves a combinatorial Fano bound on a finite
state space: a decoder of rate `r` misreconstructs at least `|S| - r`
configurations.  `Catalog/Novelty/EffectiveDecoderSelection.lean` and
`Catalog/Novelty/EffectiveDecoderHierarchy.lean` showed that on an infinite state
space a computable channel may carry a computable, fibre-constant quantity that
no *computable* decoder recovers, even though a partial computable decoder and a
limit-computable decoder always exist.

This file sharpens the negative result from "not everywhere correct" to "wrong
infinitely often", which is the effective counterpart of the Fano bound.

The mechanism is a **finite-patching principle**: a computable function may be
redefined arbitrarily at finitely many points and stay computable
(`computable_finite_patch`).  Hence a computable decoder that errs only on
finitely many *records* can be repaired into a perfect computable decoder
(`exists_computable_decoder_of_finite_error_records`).  Contrapositively, on a
channel with no computable decoder every computable decoder errs on infinitely
many records (`error_records_infinite_of_no_computable_decoder`) and therefore on
infinitely many states (`error_set_infinite_of_no_computable_decoder`).  For the
diagonal trace channel this yields an unconditional statement: *every* computable
decoder of the halting value is wrong infinitely often
(`diag_decoder_errors_infinite`), the effective analogue of
`privacy_error_bound`.
-/
import Novelty.EffectiveDecoderHierarchy

open Nat.Partrec Nat.Partrec.Code Denumerable

namespace EffectiveDecoder

variable {obs f : ℕ → ℕ}

/-! ## 1. The finite patching principle -/

/-- Redefining a computable function at a single point keeps it computable. -/
theorem computable_patch_const {dec : ℕ → ℕ} (h : Computable dec) (y₀ c : ℕ) :
    Computable fun y => if y = y₀ then c else dec y := by
  have he : Computable fun q : ℕ × ℕ => decide (q.1 = q.2) := (Primrec.eq (α := ℕ)).decide.to_comp
  have hb : Computable fun y : ℕ => decide (y = y₀) :=
    he.comp (Computable.pair Computable.id (Computable.const y₀) :
      Computable fun y : ℕ => ((y, y₀) : ℕ × ℕ))
  have hcond := Computable.cond hb (Computable.const c) h
  simpa [Bool.cond_decide] using hcond

/-- **Finite patching principle.**  A computable function overwritten by an
*arbitrary* (possibly non-computable) function on a finite set of inputs is still
computable: only finitely many constants are involved. -/
theorem computable_finite_patch (g : ℕ → ℕ) :
    ∀ (L : List ℕ) {dec : ℕ → ℕ}, Computable dec →
      Computable fun y => if y ∈ L then g y else dec y := by
  intro L
  induction L with
  | nil => intro dec h; simpa using h
  | cons y₀ L ih =>
    intro dec h
    have h' : Computable fun y => if y ∈ L then g y else dec y := ih h
    refine (computable_patch_const h' y₀ (g y₀)).of_eq fun y => ?_
    by_cases hy : y = y₀ <;> simp [hy]

/-! ## 2. Finitely many bad records can always be repaired -/

/-- **Repair lemma.**  If a computable decoder is wrong only on records drawn
from a finite list, it can be corrected to a perfect computable decoder: fibre
constancy makes the correct value on each bad record well defined, and finite
patching keeps the repaired decoder computable. -/
theorem exists_computable_decoder_of_finite_error_records {dec : ℕ → ℕ}
    (hdec : Computable dec) (hfc : FibreConstant obs f) (L : List ℕ)
    (hL : ∀ n, dec (obs n) ≠ f n → obs n ∈ L) :
    ∃ dec' : ℕ → ℕ, Computable dec' ∧ Decodes obs f dec' := by
  classical
  set g : ℕ → ℕ := fun y => if h : ∃ n, obs n = y then f h.choose else 0 with hg
  refine ⟨fun y => if y ∈ L then g y else dec y, computable_finite_patch g L hdec, fun x => ?_⟩
  by_cases hx : obs x ∈ L
  · have hex : ∃ n, obs n = obs x := ⟨x, rfl⟩
    simp only [hx, if_pos, hg, hex, dif_pos]
    exact hfc _ _ hex.choose_spec
  · simp only [hx, if_false]
    by_contra hne
    exact hx (hL x hne)

/-! ## 3. Undecodable channels force infinitely many errors -/

/-- **Infinitely many bad records.**  On a channel carrying a fibre-constant
quantity with no computable decoder, every computable decoder is wrong on
infinitely many emitted records. -/
theorem error_records_infinite_of_no_computable_decoder {dec : ℕ → ℕ} (hdec : Computable dec)
    (hfc : FibreConstant obs f) (hno : ¬ ∃ d : ℕ → ℕ, Computable d ∧ Decodes obs f d) :
    {y | ∃ n, obs n = y ∧ dec y ≠ f n}.Infinite := by
  classical
  by_contra hcon
  rw [Set.not_infinite] at hcon
  have hfin := hcon
  apply hno
  refine exists_computable_decoder_of_finite_error_records hdec hfc hfin.toFinset.toList ?_
  intro n hn
  have : obs n ∈ {y | ∃ m, obs m = y ∧ dec y ≠ f m} := ⟨n, rfl, hn⟩
  simpa using this

/-- **Infinitely many misreconstructed states.**  The effective Fano bound: on a
channel with no computable decoder, every computable decoder misreconstructs
infinitely many states.  In the finite theory of `BoundedError.lean` the number of
errors is bounded below by `|S| - rate`; here the lower bound is infinite,
uniformly over all computable decoders. -/
theorem error_set_infinite_of_no_computable_decoder {dec : ℕ → ℕ} (hdec : Computable dec)
    (hfc : FibreConstant obs f) (hno : ¬ ∃ d : ℕ → ℕ, Computable d ∧ Decodes obs f d) :
    {n | dec (obs n) ≠ f n}.Infinite := by
  have himg : obs '' {n | dec (obs n) ≠ f n} = {y | ∃ n, obs n = y ∧ dec y ≠ f n} := by
    ext y
    constructor
    · rintro ⟨n, hn, rfl⟩
      exact ⟨n, rfl, hn⟩
    · rintro ⟨n, rfl, hn⟩
      exact ⟨n, hn, rfl⟩
  have := error_records_infinite_of_no_computable_decoder hdec hfc hno
  rw [← himg] at this
  exact this.of_image obs

/-- **Every computable decoder of the diagonal trace channel is wrong infinitely
often.**  Unconditional effective Fano bound for the concrete channel of
`EffectiveDecoderSelection.lean`: no algorithm recovers the halting value from
the halting *index* except on a set whose complement is infinite. -/
theorem diag_decoder_errors_infinite {dec : ℕ → ℕ} (hdec : Computable dec) :
    {n | dec (obsDiag n) ≠ fDiag n}.Infinite :=
  error_set_infinite_of_no_computable_decoder hdec fibreConstant_diag no_computable_decoder_diag

/-- The same statement at the level of records: infinitely many *distinct
records* are decoded incorrectly, so the failure is not concentrated on a few
heavily repeated observations. -/
theorem diag_decoder_error_records_infinite {dec : ℕ → ℕ} (hdec : Computable dec) :
    {y | ∃ n, obsDiag n = y ∧ dec y ≠ fDiag n}.Infinite :=
  error_records_infinite_of_no_computable_decoder hdec fibreConstant_diag
    no_computable_decoder_diag

end EffectiveDecoder