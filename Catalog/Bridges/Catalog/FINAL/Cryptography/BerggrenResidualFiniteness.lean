import Mathlib

/-!
# Quantitative Residual Finiteness for Berggren Semigroup Balls

This file establishes an explicit, radius-controlled injectivity theorem for
reduction modulo a certified modulus on balls in the Berggren matrix semigroup.

## Main results

* `semigroupBall_entry_bound`: every matrix in the radius-`L` semigroup ball has
  entries bounded in absolute value by `berggrenBallBound L = 6 ^ L`.
* `Int.eq_of_natAbs_le_of_zmod_eq`: if two integers have absolute value at most `M`
  and are congruent mod `m > 2M`, they are equal.
* `reduceMod_injective_on_absBound`: reduction mod `m` is injective on 2×2 integer
  matrices whose entries are bounded by `M`, provided `m > 2M`.
* `semigroupBall_mod_separation`: reduction mod `certifiedModulus L = 2 · 6^L + 1`
  is injective on the radius-`L` Berggren semigroup ball.
* `bounded_collision_extraction`: any collision of reduced images of Berggren words
  of length ≤ L lifts to genuine matrix equality.

## Mathematical significance

This turns residual finiteness from a qualitative existence statement into a
certified finite-faithfulness bound indexed by protocol complexity. The modulus
`certifiedModulus L` is guaranteed to preserve all distinctions among semigroup
elements arising in transcripts of complexity at most `L`.
-/

namespace BerggrenResidualFiniteness

open Matrix Finset

/-! ## Berggren Generators

We define three generators of a semigroup inside `SL(2,ℤ)`. These are
positive-entry matrices of determinant 1, corresponding to the Berggren
parametrization of primitive Pythagorean triples via the `(m,n)` coordinates.
-/

/-- First Berggren generator. -/
def berggrenA : Matrix (Fin 2) (Fin 2) ℤ := !![1, 2; 1, 3]

/-- Second Berggren generator. -/
def berggrenB : Matrix (Fin 2) (Fin 2) ℤ := !![3, 2; 1, 1]

/-- Third Berggren generator. -/
def berggrenC : Matrix (Fin 2) (Fin 2) ℤ := !![1, 1; 2, 3]

/-- The set of Berggren generators. -/
def berggrenGens : Finset (Matrix (Fin 2) (Fin 2) ℤ) := {berggrenA, berggrenB, berggrenC}

/-! ## Matrix Entry Bound

We define `matAbsMax M` as the maximum absolute value among all entries of a 2×2
integer matrix `M`. This serves as a simple ∞-norm for bounding purposes.
-/

/-- Maximum absolute value of entries of a 2×2 integer matrix. -/
def matAbsMax (M : Matrix (Fin 2) (Fin 2) ℤ) : ℕ :=
  max (max (Int.natAbs (M 0 0)) (Int.natAbs (M 0 1)))
      (max (Int.natAbs (M 1 0)) (Int.natAbs (M 1 1)))

/-- Each entry's absolute value is bounded by `matAbsMax`. -/
theorem matAbsMax_entry_le (M : Matrix (Fin 2) (Fin 2) ℤ) (i j : Fin 2) :
    Int.natAbs (M i j) ≤ matAbsMax M := by
  unfold matAbsMax
  fin_cases i <;> fin_cases j <;> simp

/-! ## Submultiplicativity -/

/-
The ∞-norm is submultiplicative (with dimension factor 2) for 2×2 integer matrices.
-/
theorem matAbsMax_mul_le (M N : Matrix (Fin 2) (Fin 2) ℤ) :
    matAbsMax (M * N) ≤ 2 * matAbsMax M * matAbsMax N := by
  -- By definition of matrix multiplication, we have:
  have h_mul : ∀ (i j : Fin 2), Int.natAbs ((M * N) i j) ≤ 2 * (matAbsMax M) * (matAbsMax N) := by
    intros i j; rw [ Matrix.mul_apply ] ; simp +decide [ Fin.sum_univ_two ] ;
    have h_mul : Int.natAbs (M i 0 * N 0 j) ≤ matAbsMax M * matAbsMax N ∧ Int.natAbs (M i 1 * N 1 j) ≤ matAbsMax M * matAbsMax N := by
      exact ⟨ by rw [ Int.natAbs_mul ] ; exact Nat.mul_le_mul ( matAbsMax_entry_le M i 0 ) ( matAbsMax_entry_le N 0 j ), by rw [ Int.natAbs_mul ] ; exact Nat.mul_le_mul ( matAbsMax_entry_le M i 1 ) ( matAbsMax_entry_le N 1 j ) ⟩;
    grind;
  exact max_le ( max_le ( h_mul _ _ ) ( h_mul _ _ ) ) ( max_le ( h_mul _ _ ) ( h_mul _ _ ) )

/-
`matAbsMax` of the identity matrix is 1.
-/
theorem matAbsMax_one : matAbsMax (1 : Matrix (Fin 2) (Fin 2) ℤ) = 1 := by
  decide +kernel

/-
Each Berggren generator has `matAbsMax` at most 3.
-/
theorem matAbsMax_gen_le {G : Matrix (Fin 2) (Fin 2) ℤ} (hG : G ∈ berggrenGens) :
    matAbsMax G ≤ 3 := by
  fin_cases hG <;> trivial

/-! ## Semigroup Ball -/

/-- A Berggren word is a list of 2×2 integer matrices. -/
abbrev BergWord := List (Matrix (Fin 2) (Fin 2) ℤ)

/-- Evaluate a word as a matrix product (left-to-right). -/
def wordEval : BergWord → Matrix (Fin 2) (Fin 2) ℤ
  | [] => 1
  | g :: w => g * wordEval w

/-- A word is a valid Berggren word if each letter is a Berggren generator. -/
def isBergWord (w : BergWord) : Prop := ∀ g ∈ w, g ∈ berggrenGens

/-- The radius-`L` semigroup ball: all matrices expressible as products of
at most `L` Berggren generators. -/
def semigroupBall (L : ℕ) : Set (Matrix (Fin 2) (Fin 2) ℤ) :=
  {M | ∃ w, isBergWord w ∧ w.length ≤ L ∧ wordEval w = M}

/-! ## Entry Growth Bound -/

/-- The step bound for one generator multiplication: `2 * 3 = 6`,
since each generator has entries ≤ 3 and matrix dimension is 2. -/
def berggrenStepBound : ℕ := 6

/-- The exponential entry bound for the radius-`L` ball. -/
def berggrenBallBound (L : ℕ) : ℕ := berggrenStepBound ^ L

/-
Key inductive bound: multiplying by a generator grows `matAbsMax` by
at most `berggrenStepBound`.
-/
theorem matAbsMax_mul_gen_le
    {G : Matrix (Fin 2) (Fin 2) ℤ}
    (hG : G ∈ berggrenGens) (M : Matrix (Fin 2) (Fin 2) ℤ) :
    matAbsMax (G * M) ≤ berggrenStepBound * matAbsMax M := by
  refine le_trans ( matAbsMax_mul_le G M ) ?_;
  exact mul_le_mul_of_nonneg_right ( by exact le_trans ( Nat.mul_le_mul_left _ ( matAbsMax_gen_le hG ) ) ( by decide ) ) ( Nat.zero_le _ )

/-
Every matrix in the radius-`L` semigroup ball has entries bounded by
`berggrenBallBound L = 6^L`.
-/
theorem semigroupBall_entry_bound
    {L : ℕ} {M : Matrix (Fin 2) (Fin 2) ℤ}
    (hM : M ∈ semigroupBall L) :
    matAbsMax M ≤ berggrenBallBound L := by
  obtain ⟨ w, hw₁, hw₂, rfl ⟩ := hM;
  -- We prove by induction on `w` that `matAbsMax (wordEval w) ≤ 6^(w.length)`.
  have h_ind : ∀ w : BergWord, isBergWord w → matAbsMax (wordEval w) ≤ berggrenStepBound ^ w.length := by
    intro w hw; induction' w with g w ih <;> simp_all +decide [ pow_succ' ] ;
    exact le_trans ( matAbsMax_mul_gen_le ( hw g ( by simp +decide ) ) _ ) ( Nat.mul_le_mul_left _ ( ih fun g hg => hw g ( by simp +decide [ hg ] ) ) );
  exact le_trans ( h_ind w hw₁ ) ( Nat.pow_le_pow_right ( by decide ) hw₂ )

/-! ## Reduction Modulo m -/

/-- Entrywise reduction of a 2×2 integer matrix modulo `m`. -/
def reduceMod (m : ℕ) (M : Matrix (Fin 2) (Fin 2) ℤ) :
    Matrix (Fin 2) (Fin 2) (ZMod m) :=
  fun i j => (M i j : ZMod m)

/-! ## Integer Separation Lemma -/

/-
If two integers have absolute value at most `Mbound` and are congruent
modulo `m > 2 * Mbound`, then they are equal. This is the scalar core of the
quantitative residual finiteness argument.
-/
theorem Int.eq_of_natAbs_le_of_zmod_eq
    {a b : ℤ} {m Mbound : ℕ}
    (hm : 2 * Mbound < m)
    (ha : Int.natAbs a ≤ Mbound)
    (hb : Int.natAbs b ≤ Mbound)
    (hmod : (a : ZMod m) = (b : ZMod m)) :
    a = b := by
  -- From (a : ZMod m) = (b : ZMod m), we get m ∣ (a - b) as integers.
  have hdiv : (m : ℤ) ∣ (a - b) := by
    erw [ ← ZMod.intCast_zmod_eq_zero_iff_dvd ] ; aesop;
  obtain ⟨ k, hk ⟩ := hdiv ; nlinarith [ show k = 0 by nlinarith [ abs_le.mp ( show |a| ≤ Mbound by linarith ), abs_le.mp ( show |b| ≤ Mbound by linarith ) ] ]

/-! ## Matrix Separation Lemma -/

/-
Reduction mod `m` is injective on 2×2 integer matrices with `matAbsMax ≤ Mbound`,
provided `m > 2 * Mbound`.
-/
theorem reduceMod_injective_on_absBound
    {m Mbound : ℕ}
    (hm : 2 * Mbound < m)
    {X Y : Matrix (Fin 2) (Fin 2) ℤ}
    (hX : matAbsMax X ≤ Mbound)
    (hY : matAbsMax Y ≤ Mbound)
    (hxy : reduceMod m X = reduceMod m Y) :
    X = Y := by
  ext i j;
  apply Int.eq_of_natAbs_le_of_zmod_eq hm (matAbsMax_entry_le _ _ _ |> le_trans <| hX) (matAbsMax_entry_le _ _ _ |> le_trans <| hY);
  exact congr_fun ( congr_fun hxy i ) j

/-! ## Main Theorems -/

/-- The certified modulus for the radius-`L` ball: `2 · 6^L + 1`. -/
def certifiedModulus (L : ℕ) : ℕ := 2 * berggrenBallBound L + 1

/-
Any two matrices in the radius-`L` ball that agree mod `certifiedModulus L`
are genuinely equal.
-/
theorem semigroupBall_mod_separation
    (L : ℕ)
    {X Y : Matrix (Fin 2) (Fin 2) ℤ}
    (hX : X ∈ semigroupBall L)
    (hY : Y ∈ semigroupBall L)
    (hred : reduceMod (certifiedModulus L) X = reduceMod (certifiedModulus L) Y) :
    X = Y := by
  apply reduceMod_injective_on_absBound;
  rotate_left;
  exacts [ semigroupBall_entry_bound hX, semigroupBall_entry_bound hY, hred, by exact Nat.lt_succ_self _ ]

/-- Reduction mod `certifiedModulus L` is injective on the radius-`L` semigroup ball. -/
theorem reduceMod_injective_on_semigroupBall (L : ℕ) :
    Set.InjOn (reduceMod (certifiedModulus L)) (semigroupBall L) := by
  intro X hX Y hY hred
  exact semigroupBall_mod_separation L hX hY hred

/-
**Bounded Collision Extraction**: any collision of reduced images of
Berggren words of length ≤ `L` lifts to genuine matrix equality.
-/
theorem bounded_collision_extraction
    {L : ℕ}
    {w₁ w₂ : BergWord}
    (hw₁ : isBergWord w₁) (hw₂ : isBergWord w₂)
    (hL₁ : w₁.length ≤ L) (hL₂ : w₂.length ≤ L)
    (hred :
      reduceMod (certifiedModulus L) (wordEval w₁) =
      reduceMod (certifiedModulus L) (wordEval w₂)) :
    wordEval w₁ = wordEval w₂ := by
  apply semigroupBall_mod_separation;
  exacts [ ⟨ w₁, hw₁, hL₁, rfl ⟩, ⟨ w₂, hw₂, hL₂, rfl ⟩, hred ]

/-! ## Generalized Version -/

/-
Reduction mod `m` is injective on any set of 2×2 integer matrices with
bounded entries, provided the modulus exceeds twice the bound. This is
reusable for any matrix semigroup, not just the Berggren semigroup.
-/
theorem reduceMod_injective_on_set_of_entryBound
    (m Mbound : ℕ) (hm : 2 * Mbound < m) :
    Set.InjOn (reduceMod m)
      {X : Matrix (Fin 2) (Fin 2) ℤ | matAbsMax X ≤ Mbound} := by
  -- Now use the provided lemma to show injectivity.
  intro X hX Y hY hxy
  apply reduceMod_injective_on_absBound hm hX hY hxy

end BerggrenResidualFiniteness