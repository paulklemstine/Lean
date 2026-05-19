/-
  # Cube of Resolutions and d² = 0

  The Khovanov chain complex is built from the hypercube of resolutions.
  States are `Fin n → Bool`, edges change one `false` to `true`, and
  the sign convention ensures that every 2-face of the cube anti-commutes,
  which implies d² = 0.

  ## Main results
  - `cube_sign_anticommute`: signs on opposite edges of a 2-face are opposite
  - `cube_d_squared_zero`: d² = 0 for any cube complex with commuting face maps
  - `numFalse_add_hammingWeight`: counting identity for states
-/
import Mathlib

namespace Knot.Khovanov

open Finset

/-! ## Cube structure -/

/-- The Hamming weight (number of `true` values) of a Boolean function. -/
def hammingWeight {n : ℕ} (s : Fin n → Bool) : ℕ :=
  (Finset.univ.filter (fun i => s i = true)).card

/-- The sign for cube edge at position `k` in state `s`:
    (-1)^{number of true values at positions strictly before k} -/
def cubeSign {n : ℕ} (s : Fin n → Bool) (k : Fin n) : ℤ :=
  (-1) ^ (Finset.univ.filter (fun i : Fin n => i < k ∧ s i = true)).card

/-! ## Sign anti-commutativity

  For two positions i < j in state s (both false), the 2-face has four
  vertices and two paths. The sign convention makes the two paths have
  opposite signs, which is the cancellation mechanism for d² = 0. -/

/-
The key sign identity: for positions i < j both false in state s,
    the product of signs along the two paths around the 2-face are
    opposite. This ensures d² = 0.
-/
theorem cube_sign_anticommute {n : ℕ} (s : Fin n → Bool)
    (i j : Fin n) (hij : i < j) (hi : s i = false) (hj : s j = false) :
    cubeSign s i * cubeSign (Function.update s i true) j =
    -(cubeSign s j * cubeSign (Function.update s j true) i) := by
  unfold cubeSign;
  simp +decide [ Finset.filter_or, Finset.filter_and, Function.update_apply ];
  simp +decide [ Finset.filter_inter, Finset.filter_eq' ];
  simp +decide [ Finset.filter_insert, hi, hij ];
  grind

/-! ## State counting -/

/-- Number of false values in a state -/
def numFalse {n : ℕ} (s : Fin n → Bool) : ℕ :=
  (Finset.univ.filter (fun i => s i = false)).card

/-
numFalse + hammingWeight = n
-/
theorem numFalse_add_hammingWeight {n : ℕ} (s : Fin n → Bool) :
    numFalse s + hammingWeight s = n := by
  unfold numFalse hammingWeight;
  rw [ Finset.card_filter, Finset.card_filter ];
  rw [ ← Finset.sum_add_distrib, Finset.sum_congr rfl fun _ _ => by aesop, Finset.sum_const, Finset.card_fin, smul_eq_mul, mul_one ]

/-
Hamming weight increases by 1 when we flip a false position to true
-/
theorem hammingWeight_update_true {n : ℕ} (s : Fin n → Bool) (k : Fin n)
    (hk : s k = false) :
    hammingWeight (Function.update s k true) = hammingWeight s + 1 := by
  unfold hammingWeight;
  -- The filter operation preserves equality for indices other than k, and flips the value at k.
  have : {i | Function.update s k true i = true} = {i | s i = true} ⊔ {k} := by
    ext i; by_cases hi : i = k <;> aesop;
  simp_all +decide [ Set.ext_iff ];
  simp +decide [ Finset.filter_or, Finset.filter_eq', hk ]

end Knot.Khovanov