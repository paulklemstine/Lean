import Mathlib

/-!
# Two-universality of the binary inner-product hash family

The binary inner-product hash family over bit vectors of length `n` maps a seed
`a : BitVec2 n` and an input `x : BitVec2 n` to the inner product `∑ i, a i * x i`
in `ZMod 2`.

We prove that this family is *two-universal*: for any distinct `x ≠ y`, exactly
half of all seeds `a` produce a collision `innerHash a x = innerHash a y`, i.e.

`2 * #{a | innerHash a x = innerHash a y} = 2 ^ n`.

We also give the `k`-row generalization

`2 ^ k * #{A : Fin k → BitVec2 n | ∀ r, innerHash (A r) x = innerHash (A r) y} = (2 ^ n) ^ k`.
-/

namespace InnerProductHash

/-- Bit vectors of length `n`. -/
abbrev BitVec2 (n : ℕ) := Fin n → ZMod 2

/-- The inner-product hash: `innerHash a x = ∑ i, a i * x i` in `ZMod 2`. -/
def innerHash {n : ℕ} (a x : BitVec2 n) : ZMod 2 :=
  ∑ i : Fin n, a i * x i

/-- The standard basis vector with `1` at index `j` and `0` elsewhere. -/
def e {n : ℕ} (j : Fin n) : BitVec2 n := fun i => if i = j then 1 else 0

/-
**Step 1.** If `x ≠ y`, then they differ at some index.
-/
lemma exists_index_ne {n : ℕ} {x y : BitVec2 n} (h : x ≠ y) : ∃ j : Fin n, x j ≠ y j := by
  exact Function.ne_iff.mp h

/-
**Step 2 (linearity in the second argument).**
-/
lemma innerHash_sub {n : ℕ} (a x y : BitVec2 n) :
    innerHash a (x - y) = innerHash a x - innerHash a y := by
  unfold innerHash; simp +decide [ mul_sub ] ;

/-
Linearity in the first argument.
-/
lemma innerHash_add_left {n : ℕ} (a b d : BitVec2 n) :
    innerHash (a + b) d = innerHash a d + innerHash b d := by
  -- By the distributive property of multiplication over addition in the field ZMod 2, we can split the sum into two separate sums.
  simp [innerHash, add_mul, Finset.sum_add_distrib]

/-
**Step 3.** The inner product with a basis vector selects a single coordinate.
-/
lemma innerHash_basis {n : ℕ} (j : Fin n) (d : BitVec2 n) :
    innerHash (e j) d = d j := by
  unfold innerHash e; rw [ Finset.sum_eq_single j ] <;> aesop;

/-
**Step 4.** Toggling the seed at index `j` adds `d j` to the hash.
-/
lemma innerHash_toggle {n : ℕ} (a : BitVec2 n) (j : Fin n) (d : BitVec2 n) :
    innerHash (a + e j) d = innerHash a d + d j := by
  rw [ innerHash_add_left, innerHash_basis ]

/-
A collision `innerHash a x = innerHash a y` is equivalent to `innerHash a (x - y) = 0`.
-/
lemma collision_iff {n : ℕ} (a x y : BitVec2 n) :
    innerHash a x = innerHash a y ↔ innerHash a (x - y) = 0 := by
  rw [ innerHash_sub, sub_eq_zero ]

/-
Adding the basis vector `e j` twice returns to the original seed (char 2).
-/
lemma add_e_add_e {n : ℕ} (a : BitVec2 n) (j : Fin n) : a + e j + e j = a := by
  simp +decide [ funext_iff, e ];
  grind

/-
**Step 5 / 6 (key counting fact).** If `d j = 1`, the involution `a ↦ a + e j`
gives a bijection between zero- and one-valued seeds.
-/
lemma card_zero_eq_card_one {n : ℕ} {d : BitVec2 n} {j : Fin n} (hj : d j = 1) :
    Fintype.card {a : BitVec2 n // innerHash a d = 0}
      = Fintype.card {a : BitVec2 n // innerHash a d = 1} := by
  fapply Fintype.card_congr;
  refine' ⟨ fun a => ⟨ a.val + e j, _ ⟩, fun a => ⟨ a.val + e j, _ ⟩, fun a => _, fun a => _ ⟩ <;> simp_all +decide [ innerHash_toggle ];
  all_goals norm_num [ Subtype.ext_iff, add_e_add_e ];
  · exact a.2;
  · grind +qlia

/-
The zero- and one-valued seed sets partition the whole seed space.
-/
lemma card_zero_add_card_one {n : ℕ} (d : BitVec2 n) :
    Fintype.card {a : BitVec2 n // innerHash a d = 0}
      + Fintype.card {a : BitVec2 n // innerHash a d = 1}
      = 2 ^ n := by
  rw [ Fintype.card_subtype, Fintype.card_subtype ];
  rw [ Finset.card_filter, Finset.card_filter ];
  rw [ ← Finset.sum_add_distrib, Finset.sum_congr rfl fun x hx => by rcases innerHash x d with ( _ | _ | n ) <;> trivial, Finset.sum_const, Finset.card_univ ] ; norm_num [ Fintype.card_pi ]

/-
**Step 6.** If `d j = 1`, exactly half the seeds give a zero inner product with `d`.
-/
lemma card_collision_eq_half {n : ℕ} {d : BitVec2 n} {j : Fin n} (hj : d j = 1) :
    2 * Fintype.card {a : BitVec2 n // innerHash a d = 0} = 2 ^ n := by
  have := card_zero_eq_card_one hj;
  linarith [ card_zero_add_card_one d ]

/-
The key ZMod 2 fact: a difference at a differing coordinate equals `1`.
-/
lemma sub_eq_one_of_ne {n : ℕ} {x y : BitVec2 n} {j : Fin n} (hj : x j ≠ y j) :
    (x - y) j = 1 := by
  cases Fin.exists_fin_two.mp ⟨ x j, rfl ⟩ <;> cases Fin.exists_fin_two.mp ⟨ y j, rfl ⟩ <;> simp_all +decide

/-
**Main theorem (two-universality).** For distinct `x ≠ y`, exactly half of all seeds
collide.
-/
theorem two_universal {n : ℕ} {x y : BitVec2 n} (h : x ≠ y) :
    2 * Fintype.card {a : BitVec2 n // innerHash a x = innerHash a y} = 2 ^ n := by
  obtain ⟨ j, hj ⟩ := exists_index_ne h;
  convert card_collision_eq_half ( sub_eq_one_of_ne hj ) using 1;
  simp only [collision_iff]

/-
**Step 7 (k-row generalization).** For `k` independent rows, the collision probability
is `2 ^ (-k)`.
-/
theorem two_universal_k {n k : ℕ} {x y : BitVec2 n} (h : x ≠ y) :
    2 ^ k * Fintype.card {A : Fin k → BitVec2 n // ∀ r, innerHash (A r) x = innerHash (A r) y}
      = (2 ^ n) ^ k := by
  obtain ⟨j, hj⟩ := exists_index_ne h
  -- Row-wise, a collision is equivalent to a zero inner product with `x - y`.
  have hpred : ∀ A : Fin k → BitVec2 n,
      (∀ r, innerHash (A r) x = innerHash (A r) y) ↔ (∀ r, innerHash (A r) (x - y) = 0) :=
    fun A => forall_congr' (fun r => collision_iff (A r) x y)
  -- The set of zero-rows seed matrices is a product of single-row zero sets.
  have h_equiv : {A : Fin k → BitVec2 n // ∀ r, innerHash (A r) (x - y) = 0}
      ≃ (Fin k → {a : BitVec2 n // innerHash a (x - y) = 0}) :=
    ⟨fun A r => ⟨A.val r, A.prop r⟩, fun A => ⟨fun r => (A r).1, fun r => (A r).2⟩,
      fun A => rfl, fun A => rfl⟩
  have hc : 2 * Fintype.card {a : BitVec2 n // innerHash a (x - y) = 0} = 2 ^ n :=
    card_collision_eq_half (sub_eq_one_of_ne hj)
  rw [Fintype.card_congr (Equiv.subtypeEquivRight hpred),
      Fintype.card_congr h_equiv,
      Fintype.card_pi, Finset.prod_const, Finset.card_univ, Fintype.card_fin,
      ← mul_pow, hc]

end InnerProductHash