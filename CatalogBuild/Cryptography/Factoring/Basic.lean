/-! # CatalogBuild.Cryptography.Factoring.Basic

Auto-generated from theorem catalog database.
Domain: Cryptography/Factoring
Declarations: 11
-/

import Mathlib

noncomputable section

/-- The orbit sequence of a function f starting at x₀. This is simply f^[n](x₀). -/
noncomputable def orbitSeq {α : Type*} (f : α → α) (x₀ : α) (n : ℕ) : α :=
  f^[n] x₀


/-- orbitSeq agrees with Function.iterate -/
theorem orbitSeq_eq_iterate {α : Type*} (f : α → α) (x₀ : α) (n : ℕ) :
    orbitSeq f x₀ n = f^[n] x₀ := rfl


/-- Base case: orbit at 0 is x₀ -/
theorem orbitSeq_zero {α : Type*} (f : α → α) (x₀ : α) :
    orbitSeq f x₀ 0 = x₀ := rfl


/-- Step case: orbit at n+1 is f applied to orbit at n -/
theorem orbitSeq_succ {α : Type*} (f : α → α) (x₀ : α) (n : ℕ) :
    orbitSeq f x₀ (n + 1) = f (orbitSeq f x₀ n) := by
  simp [orbitSeq, iterate_succ_apply']


/-- The Pollard map x ↦ x² + c on ZMod n -/
def pollardMap (n : ℕ) (c : ZMod n) : ZMod n → ZMod n :=
  fun x => x * x + c


/-- The Pollard map commutes with the canonical reduction ZMod n → ZMod p
when p divides n. This is the fundamental commutation property. -/
theorem pollardMap_commutes_with_castHom {n p : ℕ} (hp : p ∣ n)
    [NeZero n] [NeZero p] (c : ZMod n) (x : ZMod n) :
    ZMod.castHom hp (ZMod p) (pollardMap n c x) =
    pollardMap p (ZMod.castHom hp (ZMod p) c) (ZMod.castHom hp (ZMod p) x) := by
  simp [pollardMap, map_add, map_mul]


/-- [Section: # CatalogBuild.Cryptography.Factoring.Basic
Auto-generated from theorem catalog database.
Domain: Cryptography/Factoring
Declarations: 11] -/
theorem factor_from_mod_collision {n p : ℕ} {x y : ℤ}
    (hn : 1 < n)
    (hp_dvd_n : (p : ℤ) ∣ (n : ℤ))
    (hp_gt : 1 < p)
    (hp_lt_n : p < n)
    (hcoll : (p : ℤ) ∣ (x - y))
    (hnocoll : ¬((n : ℤ) ∣ (x - y)))
    (hne : x ≠ y) :
    1 < Int.gcd (x - y) n := by
  exact lt_of_lt_of_le hp_gt ( Nat.le_of_dvd ( Int.gcd_pos_of_ne_zero_right _ ( by positivity ) ) ( Int.natCast_dvd_natCast.mp ( Int.dvd_coe_gcd hcoll hp_dvd_n ) ) )


/-- [Section: # CatalogBuild.Cryptography.Factoring.Basic
Auto-generated from theorem catalog database.
Domain: Cryptography/Factoring
Declarations: 11] -/
theorem factor_from_mod_collision_lt {n p : ℕ} {x y : ℤ}
    (hn : 1 < n)
    (hp_dvd_n : (p : ℤ) ∣ (n : ℤ))
    (hp_pos : 0 < p)
    (hp_lt_n : p < n)
    (hcoll : (p : ℤ) ∣ (x - y))
    (hnocoll : ¬((n : ℤ) ∣ (x - y)))
    (hne : x ≠ y) :
    Int.gcd (x - y) n < n := by
  refine' lt_of_le_of_ne ( Nat.le_of_dvd ( by positivity ) ( Int.natCast_dvd_natCast.mp ( Int.gcd_dvd_right _ _ ) ) ) fun h => hnocoll _;
  exact Int.dvd_trans ( by norm_num ) ( h ▸ Int.gcd_dvd_left _ _ )


/-- [Section: # CatalogBuild.Cryptography.Factoring.Basic
Auto-generated from theorem catalog database.
Domain: Cryptography/Factoring
Declarations: 11] -/
theorem collision_within_card {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (x₀ : α) :
    ∃ i j, i < j ∧ j ≤ Fintype.card α ∧ f^[i] x₀ = f^[j] x₀ := by
  by_contra h_contra;
  exact absurd ( Finset.card_le_univ ( Finset.image ( fun i => f^[i] x₀ ) ( Finset.range ( Fintype.card α + 1 ) ) ) ) ( by rw [ Finset.card_image_of_injOn fun i hi j hj hij => le_antisymm ( not_lt.mp fun hi' => h_contra ⟨ j, i, hi', by linarith [ Finset.mem_range.mp hi, Finset.mem_range.mp hj ], hij.symm ⟩ ) ( not_lt.mp fun hj' => h_contra ⟨ i, j, hj', by linarith [ Finset.mem_range.mp hi, Finset.mem_range.mp hj ], hij ⟩ ) ] ; simp +decide )


theorem floyd_detection {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (x₀ : α) :
    ∃ k, 0 < k ∧ k ≤ Fintype.card α ∧ f^[k] x₀ = f^[2 * k] x₀ := by
  by_contra h_no_k;
  -- Let's denote the orbit sequence of $f$ starting at $x₀$ as $a_i = f^i(x₀)$.
  set a : ℕ → α := fun i => f^[i] x₀;
  -- By the pigeonhole principle, since the sequence $a$ is finite, there must exist indices $i < j$ such that $a_i = a_j$.
  obtain ⟨i, j, hij, h_eq⟩ : ∃ i j, i < j ∧ j ≤ Fintype.card α ∧ a i = a j := by
    have := collision_within_card f x₀; aesop;
  -- Let $k = j - i$. Then $a_i = a_{i+k}$ and $a_{i+k} = a_{i+2k}$.
  set k := j - i
  have h_periodic : ∀ m ≥ i, a m = a (m + k) := by
    simp +zetaDelta at *;
    intro m hm; induction hm <;> simp_all +decide [ Nat.succ_add, Function.iterate_succ_apply' ] ;
    rw [ Nat.add_sub_cancel' hij.le ];
  -- Choose $k$ to be the smallest multiple of $k$ that is greater than or equal to $i$.
  obtain ⟨k', hk'⟩ : ∃ k', 0 < k' ∧ k' ≤ Fintype.card α ∧ k' ≥ i ∧ k' % k = 0 := by
    exact ⟨ k * ( i / k + 1 ), Nat.mul_pos ( Nat.sub_pos_of_lt hij ) ( Nat.succ_pos _ ), by nlinarith [ Nat.div_mul_le_self i k, Nat.sub_add_cancel hij.le ], by nlinarith [ Nat.div_add_mod i k, Nat.mod_lt i ( Nat.sub_pos_of_lt hij ) ], by simp +decide ⟩;
  -- Since $k'$ is a multiple of $k$, we have $a_{k'} = a_{k' + k} = a_{k' + 2k} = \cdots = a_{2k'}$.
  have h_eq_k' : a k' = a (2 * k') := by
    have h_eq_k' : ∀ m ≥ i, a m = a (m + k * (k' / k)) := by
      intro m hm; induction' k' / k with d hd <;> simp_all +decide [ Nat.mul_succ, ← add_assoc ] ;
      exact h_periodic _ ( by nlinarith );
    convert h_eq_k' k' hk'.2.2.1 using 1 ; rw [ Nat.mul_div_cancel' ( Nat.dvd_of_mod_eq_zero hk'.2.2.2 ) ] ; ring;
  exact h_no_k ⟨ k', hk'.1, hk'.2.1, h_eq_k' ⟩


theorem orbit_map_commute {α β : Type*} (f : α → α) (g : β → β) (π : α → β)
    (hcomm : ∀ x, π (f x) = g (π x)) (x₀ : α) (n : ℕ) :
    π (f^[n] x₀) = g^[n] (π x₀) := by
  induction n <;> simp +decide [ *, Function.iterate_succ_apply' ]


end
