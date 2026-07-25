/-
# Hadamard → Symmetric BIBD Bridge

From any normalized Hadamard matrix `H` of order `4n`, extract the core incidence
matrix `A` of size `(4n-1) × (4n-1)` by `A_{ij} = (1 + H_{i+1,j+1}) / 2`.
Then `A` satisfies the design identity `A * A^T = n • I + (n - 1) • J`.

This transforms matrix orthogonality into finite geometry.
-/
import Mathlib

open Finset BigOperators Matrix

/-! ## Core incidence matrix extraction -/

/-- Given a normalized Hadamard matrix of order `4n` (with n > 0),
extract the `(4n-1) × (4n-1)` core incidence matrix `A_{ij} = (1 + H_{i+1,j+1}) / 2`.

When `H` has ±1 entries, `A` has entries in `{0, 1}`:
- `H = 1` maps to `A = 1`
- `H = -1` maps to `A = 0` -/
noncomputable def coreIncidence {n : ℕ} (hn : 0 < n)
    (H : Matrix (Fin (4 * n)) (Fin (4 * n)) ℤ) :
    Matrix (Fin (4 * n - 1)) (Fin (4 * n - 1)) ℤ :=
  fun i j =>
    let i' : Fin (4 * n) := ⟨i.val + 1, by omega⟩
    let j' : Fin (4 * n) := ⟨j.val + 1, by omega⟩
    (1 + H i' j') / 2

/-! ## Properties of ±1 entries under the transformation -/

/-- If `x ∈ {1, -1}` then `(1 + x) / 2 ∈ {0, 1}`. -/
lemma pm1_to_01 {x : ℤ} (hx : x = 1 ∨ x = -1) :
    (1 + x) / 2 = 0 ∨ (1 + x) / 2 = 1 := by
  rcases hx with rfl | rfl <;> simp

/-- For `x, y ∈ {1, -1}`, `((1+x)/2) * ((1+y)/2) = (1 + x + y + x*y) / 4`. -/
lemma pm1_product {x y : ℤ} (hx : x = 1 ∨ x = -1) (hy : y = 1 ∨ y = -1) :
    ((1 + x) / 2) * ((1 + y) / 2) = (1 + x + y + x * y) / 4 := by
  rcases hx with rfl | rfl <;> rcases hy with rfl | rfl <;> simp

/-! ## The core incidence matrix has entries in {0, 1} -/

/-- The core incidence matrix has entries in `{0, 1}`. -/
theorem coreIncidence_01 {n : ℕ} (hn : 0 < n)
    (H : Matrix (Fin (4 * n)) (Fin (4 * n)) ℤ)
    (hH : ∀ i j, H i j = 1 ∨ H i j = -1)
    (i j : Fin (4 * n - 1)) :
    coreIncidence hn H i j = 0 ∨ coreIncidence hn H i j = 1 :=
  pm1_to_01 (hH _ _)

/-! ## The BIBD Gram identity -/

/-
**Hadamard → BIBD bridge theorem**: If `H` is a normalized Hadamard matrix
of order `4n` (i.e., ±1 entries, `H * H^T = 4n • I`, first row and column all 1s),
then the core incidence matrix `A = (1 + H)/2` (on the interior) satisfies
`A * A^T = n • I + (n - 1) • J`.
This certifies a symmetric BIBD(4n-1, 2n-1, n-1).
-/
set_option maxHeartbeats 400000 in
theorem coreIncidence_gram {n : ℕ} (hn : 0 < n)
    (H : Matrix (Fin (4 * n)) (Fin (4 * n)) ℤ)
    (hpm : ∀ i j, H i j = 1 ∨ H i j = -1)
    (horth : H * H.transpose =
      (4 * n : ℤ) • (1 : Matrix (Fin (4 * n)) (Fin (4 * n)) ℤ))
    (hrow : ∀ j, H ⟨0, by omega⟩ j = 1)
    (hcol : ∀ i, H i ⟨0, by omega⟩ = 1) :
    coreIncidence hn H * (coreIncidence hn H).transpose =
      (n : ℤ) • (1 : Matrix (Fin (4 * n - 1)) (Fin (4 * n - 1)) ℤ) +
        ((n : ℤ) - 1) • (Matrix.of fun (_ _ : Fin (4 * n - 1)) => (1 : ℤ)) := by
  -- By definition of $A$, we know that its entries are $(1 + H_{i+1,j+1}) / 2$.
  ext i j;
  -- By definition of $A$, we know that its entries are $(1 + H_{i+1,j+1}) / 2$. Thus,
  have hA : ∀ i j, coreIncidence hn H i j = (1 + H ⟨i.val + 1, by omega⟩ ⟨j.val + 1, by omega⟩) / 2 := by
    exact?;
  -- By definition of $A$, we know that its entries are $(1 + H_{i+1,j+1}) / 2$. Thus, we can expand the product $A * A^T$.
  have h_expand : ∑ k : Fin (4 * n - 1), ((1 + H ⟨i.val + 1, by omega⟩ ⟨k.val + 1, by omega⟩) / 2) * ((1 + H ⟨j.val + 1, by omega⟩ ⟨k.val + 1, by omega⟩) / 2) = (n : ℤ) * (if i = j then 1 else 0) + ((n - 1) : ℤ) := by
    -- By definition of $A$, we know that its entries are $(1 + H_{i+1,j+1}) / 2$. Thus, we can expand the product $A * A^T$ and simplify.
    have h_expand : ∑ k : Fin (4 * n - 1), ((1 + H ⟨i.val + 1, by omega⟩ ⟨k.val + 1, by omega⟩) * (1 + H ⟨j.val + 1, by omega⟩ ⟨k.val + 1, by omega⟩)) = 4 * n * (if i = j then 1 else 0) + (4 * n - 4) := by
      have h_expand : ∑ k : Fin (4 * n), (1 + H ⟨i.val + 1, by omega⟩ k) * (1 + H ⟨j.val + 1, by omega⟩ k) = 4 * n * (if i = j then 1 else 0) + 4 * n := by
        have h_expand : ∑ k : Fin (4 * n), H ⟨i.val + 1, by omega⟩ k * H ⟨j.val + 1, by omega⟩ k = 4 * n * (if i = j then 1 else 0) := by
          convert congr_fun ( congr_fun horth ⟨ i + 1, by omega ⟩ ) ⟨ j + 1, by omega ⟩ using 1 ; simp +decide [ Matrix.mul_apply ] ;
          simp +decide [ Matrix.one_apply, Fin.ext_iff ];
        have h_expand : ∑ k : Fin (4 * n), H ⟨i.val + 1, by omega⟩ k = 0 ∧ ∑ k : Fin (4 * n), H ⟨j.val + 1, by omega⟩ k = 0 := by
          have h_expand : ∀ i : Fin (4 * n), i ≠ ⟨0, by omega⟩ → ∑ k : Fin (4 * n), H i k = 0 := by
            intro i hi; have := congr_fun ( congr_fun horth i ) ⟨ 0, by linarith ⟩ ; simp_all +decide [ Matrix.mul_apply ] ;
          exact ⟨ h_expand _ <| ne_of_gt <| Nat.succ_pos _, h_expand _ <| ne_of_gt <| Nat.succ_pos _ ⟩;
        simp_all +decide [ Finset.sum_add_distrib, add_mul, mul_add, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _ ];
        ring;
      rw [ ← Finset.sum_erase_add _ _ ( Finset.mem_univ ⟨ 0, by omega ⟩ ), add_comm ] at h_expand;
      rw [ show ( Finset.univ.erase ⟨ 0, by omega ⟩ : Finset ( Fin ( 4 * n ) ) ) = Finset.image ( fun k : Fin ( 4 * n - 1 ) => ⟨ k.val + 1, by omega ⟩ ) Finset.univ from ?_, Finset.sum_image ] at h_expand <;> norm_num at *;
      · grind;
      · exact fun a b h => by simpa [ Fin.ext_iff ] using h;
      · ext ⟨ k, hk ⟩ ; simp +decide [ Fin.ext_iff ];
        exact ⟨ fun h => ⟨ ⟨ k - 1, by omega ⟩, Nat.succ_pred_eq_of_pos ( Nat.pos_of_ne_zero h ) ⟩, fun ⟨ a, ha ⟩ => by omega ⟩;
    convert congr_arg ( fun x : ℤ => x / 4 ) h_expand using 1;
    · rw [ Int.ediv_eq_of_eq_mul_left ];
      · norm_num;
      · rw [ Finset.sum_mul _ _ _ ] ; congr ; ext k ; rcases hpm ⟨ i + 1, by linarith [ Fin.is_lt i, Nat.sub_add_cancel ( by linarith : 1 ≤ 4 * n ) ] ⟩ ⟨ k + 1, by linarith [ Fin.is_lt k, Nat.sub_add_cancel ( by linarith : 1 ≤ 4 * n ) ] ⟩ with ha | ha <;> rcases hpm ⟨ j + 1, by linarith [ Fin.is_lt j, Nat.sub_add_cancel ( by linarith : 1 ≤ 4 * n ) ] ⟩ ⟨ k + 1, by linarith [ Fin.is_lt k, Nat.sub_add_cancel ( by linarith : 1 ≤ 4 * n ) ] ⟩ with hb | hb <;> norm_num [ ha, hb ] ;
    · split_ifs <;> omega;
  simp_all +decide [ Matrix.mul_apply, Matrix.one_apply ];
  split_ifs <;> simp_all +decide [ Matrix.one_apply ];
  · exact Eq.symm ( if_pos rfl );
  · exact Eq.symm ( if_neg ( by simpa [ Fin.ext_iff ] using ‹¬i = j› ) )