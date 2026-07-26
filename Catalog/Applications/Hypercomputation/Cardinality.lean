/-
  Hypercomputation III: computability is a measure-zero phenomenon
  ===============================================================

  Why is hypercomputation *needed* at all?  Because Turing computability is
  extraordinarily rare.  This file makes that precise: the Turing-computable
  Boolean functions on `ℕ` form only a *countable* set, whereas the set of *all*
  Boolean functions on `ℕ` is uncountable (of cardinality continuum).  Hence

    * uncomputable functions exist, and
    * they are in fact *uncountable* — computable functions are the exception.

  Every uncomputable function is a task that only some form of hypercomputation
  could carry out, so "almost every" decision problem lies beyond Turing power.

  Main results:

  * `computable_countable` : `{ f : ℕ → Bool // Computable f }` is `Countable`.
    Proof: each computable function is `eval` of some code (`exists_code`), and it
    is recoverable from that code, giving an injection into the countable type of
    codes.
  * `uncountable_functions` : `ℕ → Bool` is uncountable (cardinality `𝔠`).
  * `exists_uncomputable` : there is a non-computable Boolean function.
  * `uncomputable_uncountable` : the non-computable functions are uncountable.
-/
import Mathlib

open Nat.Partrec Nat.Partrec.Code
open Encodable
open scoped Classical

namespace Applications.Hypercomputation

/-- The `ℕ →. ℕ` partial function naturally attached to a total Boolean function
`f`: it always halts, returning the encoding of `f n`. -/
noncomputable def natPR (f : ℕ → Bool) : ℕ →. ℕ := fun n => (Part.some (encode (f n)) : Part ℕ)

/-- If `f` is `Computable`, its associated partial function `natPR f` is partial
recursive in Mathlib's `Nat.Partrec` sense. -/
theorem natPR_partrec {f : ℕ → Bool} (hf : Computable f) : Nat.Partrec (natPR f) :=
  Partrec.nat_iff.1 (Computable.encode.comp hf).partrec

/-- A choice of code computing a given computable Boolean function. -/
noncomputable def toCode (f : {f : ℕ → Bool // Computable f}) : Code :=
  Classical.choose (exists_code.1 (natPR_partrec f.2))

/-- The chosen code indeed evaluates to `natPR f`. -/
theorem toCode_spec (f : {f : ℕ → Bool // Computable f}) : (toCode f).eval = natPR f.1 :=
  Classical.choose_spec (exists_code.1 (natPR_partrec f.2))

/-- Distinct computable functions get distinct codes: from a code's `eval` one
recovers the underlying Boolean function, so `toCode` is injective. -/
theorem toCode_inj : Function.Injective toCode := by
  intro f g h
  apply Subtype.ext
  funext n
  have e : natPR f.1 = natPR g.1 := by rw [← toCode_spec f, ← toCode_spec g, h]
  have h2 := congrFun e n
  simp only [natPR, Part.some_inj] at h2
  exact encode_injective h2

/-- **The computable Boolean functions are countable.**  There are only countably
many programs, hence only countably many functions any of them can compute. -/
instance computable_countable : Countable {f : ℕ → Bool // Computable f} :=
  toCode_inj.countable

/-- **The Boolean functions on `ℕ` are uncountable** (cardinality continuum). -/
theorem uncountable_functions : ¬ Countable (ℕ → Bool) := by
  rw [← Cardinal.mk_le_aleph0_iff]
  push_neg
  calc Cardinal.aleph0 < Cardinal.continuum := Cardinal.aleph0_lt_continuum
    _ = Cardinal.mk (ℕ → Bool) := by
        rw [Cardinal.continuum, ← Cardinal.mk_nat, Cardinal.mk_arrow]; simp

/-- **Uncomputable functions exist.**  If every Boolean function were computable,
`ℕ → Bool` would be countable, contradicting `uncountable_functions`. -/
theorem exists_uncomputable : ∃ f : ℕ → Bool, ¬ Computable f := by
  by_contra h
  push_neg at h
  have surj : Function.Surjective
      (Subtype.val : {f : ℕ → Bool // Computable f} → (ℕ → Bool)) :=
    fun f => ⟨⟨f, h f⟩, rfl⟩
  exact uncountable_functions surj.countable

/-- **The uncomputable functions are uncountable.**  The computable ones are only
a countable sliver; the overwhelming majority of decision problems can be solved
only by hypercomputation.  (If the uncomputable functions were countable, then —
since the computable ones are countable — all of `ℕ → Bool` would be countable.) -/
theorem uncomputable_uncountable : ¬ Countable {f : ℕ → Bool // ¬ Computable f} := by
  intro h
  exact uncountable_functions
    (Countable.of_equiv _ (Equiv.sumCompl (fun f : ℕ → Bool => Computable f)))

end Applications.Hypercomputation