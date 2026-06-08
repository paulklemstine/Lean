/-
  # Hadamard Matrix Arithmetic Obstruction

  This file proves the necessary condition for Hadamard matrix existence:
  if n > 2 and a Hadamard matrix of order n exists, then 4 ∣ n.

  This is a standalone proof using the row-triple intersection argument.
-/
import Mathlib

open Matrix Finset BigOperators

/-! ## Core definition (self-contained) -/

def IsHadamardO {n : ℕ} (H : Matrix (Fin n) (Fin n) ℤ) : Prop :=
  (∀ i j, H i j = 1 ∨ H i j = -1) ∧
  H * H.transpose = (n : ℤ) • (1 : Matrix (Fin n) (Fin n) ℤ)

def HadamardOrderO (n : ℕ) : Prop :=
  ∃ H : Matrix (Fin n) (Fin n) ℤ, IsHadamardO H

/-! ## Auxiliary: entry product of ±1 values -/

theorem pm_one_mul_self {a : ℤ} (h : a = 1 ∨ a = -1) : a * a = 1 := by
  rcases h with rfl | rfl <;> ring

theorem pm_one_mul_cases {a b : ℤ} (ha : a = 1 ∨ a = -1) (hb : b = 1 ∨ b = -1) :
    a * b = 1 ∨ a * b = -1 := by
  rcases ha with rfl | rfl <;> rcases hb with rfl | rfl <;> simp

/-! ## Row dot product extraction -/

theorem row_dot_product_eq {n : ℕ} {H : Matrix (Fin n) (Fin n) ℤ}
    (hH : IsHadamardO H) (i j : Fin n) :
    ∑ k, H i k * H j k = if i = j then (n : ℤ) else 0 := by
      convert congr_arg ( fun m : Matrix ( Fin n ) ( Fin n ) ℤ => m i j ) hH.2 using 1;
      simp +decide [ Matrix.one_apply, Matrix.smul_apply ]

/-! ## The divisibility obstruction -/

/-
**Arithmetic obstruction**: if n > 2 and a Hadamard matrix of order n exists,
    then 4 divides n.

    This is the classical necessary condition for Hadamard existence. Combined
    with the Hadamard conjecture, it says the admissible orders are exactly
    {1, 2} ∪ {n : n ≡ 0 (mod 4)}.
-/
theorem hadamard_order_div_four {n : ℕ} (hn : 2 < n) (hH : HadamardOrderO n) :
    4 ∣ n := by
      -- Let's choose any three distinct rows, say $r_1$, $r_2$, and $r_3$, from the Hadamard matrix $H$.
      obtain ⟨H, hH⟩ := hH
      obtain ⟨r1, r2, r3, hr⟩ : ∃ r1 r2 r3 : Fin n, r1 ≠ r2 ∧ r1 ≠ r3 ∧ r2 ≠ r3 := by
        exact ⟨ ⟨ 0, by linarith ⟩, ⟨ 1, by linarith ⟩, ⟨ 2, by linarith ⟩, by norm_num, by norm_num, by norm_num ⟩;
      -- Let $a$ be the number of positions where $r_1$ and $r_2$ agree, $b$ where $r_1$ agrees with $r_2$ but disagrees with $r_3$, $c$ where $r_1$ disagrees with $r_2$ but agrees with $r_3$, and $d$ where $r_1$ disagrees with both $r_2$ and $r_3$.
      set a := Finset.card (Finset.filter (fun k => H r1 k = H r2 k ∧ H r1 k = H r3 k) Finset.univ)
      set b := Finset.card (Finset.filter (fun k => H r1 k = H r2 k ∧ H r1 k ≠ H r3 k) Finset.univ)
      set c := Finset.card (Finset.filter (fun k => H r1 k ≠ H r2 k ∧ H r1 k = H r3 k) Finset.univ)
      set d := Finset.card (Finset.filter (fun k => H r1 k ≠ H r2 k ∧ H r1 k ≠ H r3 k) Finset.univ);
      -- From the orthogonality of the rows, we have the following equations:
      have h1 : a + b = n / 2 := by
        have h1 : ∑ k, (H r1 k) * (H r2 k) = 0 := by
          have := row_dot_product_eq hH r1 r2; aesop;
        -- Since $H r1 k * H r2 k = 1$ if $H r1 k = H r2 k$ and $-1$ if $H r1 k \neq H r2 k$, we can split the sum into two parts.
        have h_split : ∑ k, (H r1 k) * (H r2 k) = ∑ k ∈ Finset.univ.filter (fun k => H r1 k = H r2 k), 1 + ∑ k ∈ Finset.univ.filter (fun k => H r1 k ≠ H r2 k), (-1) := by
          rw [ Finset.sum_filter, Finset.sum_filter ];
          simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_congr rfl fun x _ => by rcases hH.1 r1 x with ha | ha <;> rcases hH.1 r2 x with hb | hb <;> rw [ ha, hb ] <;> norm_num;
        simp_all +decide [ Finset.filter_not, Finset.card_sdiff ];
        rw [ show a + b = Finset.card ( Finset.filter ( fun k => H r1 k = H r2 k ) Finset.univ ) from ?_ ];
        · grind;
        · rw [ ← Finset.card_union_of_disjoint ];
          · exact congr_arg Finset.card ( by ext; by_cases h : H r1 ‹_› = H r3 ‹_› <;> aesop );
          · exact Finset.disjoint_filter.mpr ( by aesop )
      have h2 : a + c = n / 2 := by
        have h2 : ∑ k, (H r1 k) * (H r3 k) = 0 := by
          convert row_dot_product_eq hH r1 r3 using 1 ; aesop;
        -- Since $H r1 k * H r3 k = 1$ if $H r1 k = H r3 k$ and $-1$ otherwise, we can rewrite the sum.
        have h_sum : ∑ k, (H r1 k) * (H r3 k) = ∑ k ∈ Finset.univ.filter (fun k => H r1 k = H r3 k), 1 + ∑ k ∈ Finset.univ.filter (fun k => H r1 k ≠ H r3 k), -1 := by
          rw [ Finset.sum_filter, Finset.sum_filter ] ; rw [ ← Finset.sum_add_distrib ] ; congr ; ext k ; rcases hH.1 r1 k with ha | ha <;> rcases hH.1 r3 k with hb | hb <;> norm_num [ ha, hb ] ;
        simp_all +decide [ Finset.filter_not, Finset.card_sdiff ];
        rw [ show a + c = Finset.card ( Finset.filter ( fun k => H r1 k = H r3 k ) Finset.univ ) from ?_ ];
        · exact Eq.symm ( Nat.div_eq_of_eq_mul_left zero_lt_two ( by linarith [ Nat.sub_add_cancel ( show Finset.card ( Finset.filter ( fun k => H r1 k = H r3 k ) Finset.univ ) ≤ n from le_trans ( Finset.card_filter_le _ _ ) ( by norm_num ) ) ] ) );
        · rw [ ← Finset.card_union_of_disjoint ];
          · congr with k ; by_cases hk : H r1 k = H r2 k <;> aesop;
          · exact Finset.disjoint_filter.mpr ( by aesop )
      have h3 : a + d = b + c := by
        have h3 : ∑ k, (H r2 k * H r3 k) = 0 := by
          have := row_dot_product_eq hH r2 r3; aesop;
        have h3 : ∑ k, (H r2 k * H r3 k) = ∑ k ∈ Finset.univ.filter (fun k => H r1 k = H r2 k ∧ H r1 k = H r3 k), 1 + ∑ k ∈ Finset.univ.filter (fun k => H r1 k = H r2 k ∧ H r1 k ≠ H r3 k), -1 + ∑ k ∈ Finset.univ.filter (fun k => H r1 k ≠ H r2 k ∧ H r1 k = H r3 k), -1 + ∑ k ∈ Finset.univ.filter (fun k => H r1 k ≠ H r2 k ∧ H r1 k ≠ H r3 k), 1 := by
          rw [ Finset.sum_filter, Finset.sum_filter, Finset.sum_filter, Finset.sum_filter ];
          rw [ ← Finset.sum_add_distrib, ← Finset.sum_add_distrib, ← Finset.sum_add_distrib ];
          grind +locals;
        norm_num +zetaDelta at *;
        linarith
      have h4 : a + b + c + d = n := by
        rw [ ← Finset.card_union_of_disjoint, ← Finset.card_union_of_disjoint, ← Finset.card_union_of_disjoint ];
        · convert Finset.card_fin n ; ext k ; by_cases hk1 : H r1 k = H r2 k <;> by_cases hk2 : H r1 k = H r3 k <;> aesop;
        · exact Finset.disjoint_left.mpr ( by aesop );
        · exact Finset.disjoint_left.mpr ( by aesop );
        · exact Finset.disjoint_filter.mpr ( by aesop );
      grind

/-! ## Even order for n > 1 -/

/-
Weaker necessary condition: n > 1 implies n is even.
-/
theorem hadamard_order_even {n : ℕ} (hn : 1 < n) (hH : HadamardOrderO n) :
    2 ∣ n := by
      -- Let H be a Hadamard matrix of order n.
      obtain ⟨H, hH⟩ := hH;
      -- Take rows 0 and 1 (which exist since n > 1). Their dot product is 0.
      have h_dot : ∑ k, H ⟨0, by linarith⟩ k * H ⟨1, by linarith⟩ k = 0 := by
        exact row_dot_product_eq hH ⟨ 0, by linarith ⟩ ⟨ 1, by linarith ⟩ ▸ if_neg ( by norm_num );
      -- Since each H i k is ±1, the product H 0 k * H 1 k is ±1 for each k.
      have h_prod : ∀ k, H ⟨0, by linarith⟩ k * H ⟨1, by linarith⟩ k = 1 ∨ H ⟨0, by linarith⟩ k * H ⟨1, by linarith⟩ k = -1 := by
        exact fun k => pm_one_mul_cases ( hH.1 _ _ ) ( hH.1 _ _ );
      replace h_dot := congr_arg ( fun x => x % 2 ) h_dot ; norm_num [ Finset.sum_int_mod, Int.add_emod, Int.mul_emod, show ∀ k : Fin n, ( H ⟨ 0, by linarith ⟩ k * H ⟨ 1, by linarith ⟩ k ) % 2 = 1 from fun k => by rcases h_prod k with h | h <;> norm_num [ h ] ] at h_dot;
      exact_mod_cast h_dot