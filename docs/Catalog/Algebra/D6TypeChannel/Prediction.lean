/-
# Information versus predictability in the `D₆` type channel

The mutual information `I(dial ; T)` measures how much a dial reduces the
*uncertainty* of the type `T`; the Bayes error measures how much it reduces the
*probability of mispredicting* `T`.  For `x⁶ - 2` the two notions come apart:

* `constant_predictor_error_ge` — with no dial, every guess of `T` is wrong on at
  least `4` of the `12` Frobenius classes (error `1/3`), and guessing `T = 0`
  attains this;
* `rotSign_predictor_error_ge` — **the conductor-`3` dial does not help at all**:
  every predictor `f (p mod 3)` is still wrong on at least `4/12`, although
  `I(p mod 3 ; T) ≈ 0.364` bits (`mutInfo_rotSign_D6`);
* `abelian_predictor_error_ge` — **non-abelian obstruction**: for every
  homomorphism `φ` of `D₆` into an abelian group and every predictor `f ∘ φ`, at
  least one of the `12` classes is mispredicted (error `≥ 1/12`), because
  `φ` cannot separate `r 0` (six roots) from the commutator `r 2` (no root);
* `ab6_predictor_error_eq` — the bound `1/12` is attained by reading `p mod 24`.
-/
import Algebra.D6TypeChannel.Channel

namespace D6TypeChannel

open DihedralGroup Finset

set_option maxRecDepth 100000

/-- Collapse a guess to its only relevant feature: which of the possible types
`0, 2, 6` it equals (or `1` for "none of them"). -/
def canonGuess (a : ℕ) : ℕ := if a = 0 then 0 else if a = 2 then 2 else if a = 6 then 6 else 1

lemma canonGuess_ne_iff {a t : ℕ} (ht : t = 0 ∨ t = 2 ∨ t = 6) :
    canonGuess a ≠ t ↔ a ≠ t := by
  unfold canonGuess
  split_ifs <;> omega

lemma canonGuess_mem (a : ℕ) :
    canonGuess a = 0 ∨ canonGuess a = 1 ∨ canonGuess a = 2 ∨ canonGuess a = 6 := by
  unfold canonGuess
  split_ifs <;> simp

lemma fixCount_D6_mem (g : DihedralGroup 6) : fixCount g = 0 ∨ fixCount g = 2 ∨ fixCount g = 6 :=
  fixCount_mem ⟨3, rfl⟩ g

/-- Replacing a predictor by its canonical collapse does not change its error set. -/
lemma error_canon {α : Type*} (f : α → ℕ) (d : DihedralGroup 6 → α) :
    #{g : DihedralGroup 6 | f (d g) ≠ fixCount g} =
      #{g : DihedralGroup 6 | canonGuess (f (d g)) ≠ fixCount g} := by
  congr 1
  ext g
  simp only [mem_filter, mem_univ, true_and]
  exact (canonGuess_ne_iff (fixCount_D6_mem g)).symm

/-- **The conductor-`3` dial gives no predictive advantage**: every predictor of
`T` from `p mod 3` (the rotation character) errs on at least `4` of `12` classes. -/
theorem rotSign_predictor_error_ge (f : ZMod 2 → ℕ) :
    4 ≤ #{g : DihedralGroup 6 | f (rotSign g) ≠ fixCount g} := by
  rw [error_canon f rotSign]
  have hf : ∀ g : DihedralGroup 6, canonGuess (f (rotSign g)) =
      if rotSign g = 0 then canonGuess (f 0) else canonGuess (f 1) := by
    intro g
    cases g <;> rfl
  simp only [hf]
  have key : ∀ a b : ℕ, (a = 0 ∨ a = 1 ∨ a = 2 ∨ a = 6) → (b = 0 ∨ b = 1 ∨ b = 2 ∨ b = 6) →
      4 ≤ #{g : DihedralGroup 6 | (if rotSign g = 0 then a else b) ≠ fixCount g} := by
    intro a b ha hb
    rcases ha with rfl | rfl | rfl | rfl <;> rcases hb with rfl | rfl | rfl | rfl <;> decide
  exact key _ _ (canonGuess_mem _) (canonGuess_mem _)

/-- **Without any dial** the best guess errs on `4/12`. -/
theorem constant_predictor_error_ge (a : ℕ) :
    4 ≤ #{g : DihedralGroup 6 | a ≠ fixCount g} :=
  rotSign_predictor_error_ge (fun _ => a)

/-- ...and the guess `T = 0` attains it. -/
theorem constant_predictor_error_eq : #{g : DihedralGroup 6 | 0 ≠ fixCount g} = 4 := by
  decide

/-- Every homomorphism of `D₆` into an abelian group identifies `r 0` and `r 2`. -/
lemma abelian_hom_r_two {A : Type*} [CommGroup A] (φ : DihedralGroup 6 →* A) :
    φ (r 2) = φ (r 0) := by
  rw [← commutator_r_one_sr_zero, map_commutatorElement,
    commutatorElement_eq_one_iff_mul_comm.2 (mul_comm _ _), r_zero, map_one]

/-- **Non-abelian obstruction to pinning**: whatever abelian dial `φ` is read
and whatever predictor `f` is used, at least one Frobenius class is
mispredicted. -/
theorem abelian_predictor_error_ge {A : Type*} [CommGroup A] (φ : DihedralGroup 6 →* A)
    (f : A → ℕ) : 1 ≤ #{g : DihedralGroup 6 | f (φ g) ≠ fixCount g} := by
  rw [Nat.one_le_iff_ne_zero, Ne, card_eq_zero, filter_eq_empty_iff]
  intro h
  have h0 := h (mem_univ (r 0))
  have h2 := h (mem_univ (r 2))
  simp only [not_not] at h0 h2
  rw [abelian_hom_r_two] at h2
  have e0 : fixCount (r 0 : DihedralGroup 6) = 6 := by decide
  have e2 : fixCount (r 2 : DihedralGroup 6) = 0 := by decide
  omega

/-- The obstruction is sharp: reading the full abelianisation (`p mod 24`) and
predicting `2` exactly on the class `sr (even)` and `0` elsewhere errs on a single
class out of `12` (the identity, `p` split completely). -/
theorem ab6_predictor_error_eq :
    #{g : DihedralGroup 6 | (if ab6 g = (1, 0) then 2 else 0) ≠ fixCount g} = 1 := by
  decide

end D6TypeChannel