import Pythagorean.CayleyHamiltonian.OrderPQ

/-!
# The transversal case of order `pq`: an explicit witness of order `21`

`CayleyHamiltonian.pq_isHamiltonian_or_transversal` reduces the order-`pq` problem to
connection sets that are *partial transversals*: they miss the normal Sylow `q`-subgroup `N`
and meet every nontrivial coset of `N` at most once.  That configuration is not covered by any
of the criteria of this development, and it is genuinely different: a lift of a hamiltonian
cycle of the quotient `ℤ/p` along a *positive* word can never close, because a word in `x`
and `y` alone whose image in `ℤ/p` is a hamiltonian cycle uses only `x`'s or only `y`'s, and
both `x` and `y` have order `p`, so its voltage is trivial.

This file settles the smallest instance of that configuration by an explicit hamiltonian
cycle.  The group is the Frobenius group

`F₂₁ = ℤ/7 ⋊ ℤ/3`,  `(a₁, b₁) · (a₂, b₂) = (a₁ + a₂, 2^{a₁} b₂ + b₁)`,

realized as affine maps `t ↦ 2^a t + b` of `ℤ/7`, and the connection set is
`S = {x, y}` with `x = (1, 0)` and `y = (2, 1)`: both elements have order `3`, both lie
outside the normal subgroup `N = {(0, b)}` of order `7`, and they lie in *different* cosets of
`N`.  The hamiltonian cycle found (and verified here) is the word

`x x y x x y x y x x y y x⁻¹ x⁻¹ y x⁻¹ x⁻¹ y⁻¹ x y y`,

which indeed uses inverses, as the discussion above requires.

Main result: `CayleyHamiltonian.Frobenius21.frobenius21_transversal_isHamiltonian`.
-/

namespace CayleyHamiltonian

namespace Frobenius21

/-- The underlying type of the Frobenius group of order `21`, written as pairs
`(a, b) ∈ ℤ/3 × ℤ/7` standing for the affine map `t ↦ 2^a t + b` of `ℤ/7`. -/
def F21 := ZMod 3 × ZMod 7
  deriving DecidableEq, Fintype

namespace F21

/-- The value `2^a ∈ (ℤ/7)ˣ`; since `2³ = 1` in `ℤ/7` this is well defined on `ℤ/3`. -/
def pow2 (a : ZMod 3) : ZMod 7 := 2 ^ a.val

instance : Mul F21 := ⟨fun g h => ((g.1 + h.1 : ZMod 3), (pow2 g.1 * h.2 + g.2 : ZMod 7))⟩
instance : One F21 := ⟨((0 : ZMod 3), (0 : ZMod 7))⟩
instance : Inv F21 := ⟨fun g => ((-g.1 : ZMod 3), (-(pow2 (-g.1) * g.2) : ZMod 7))⟩

instance : Group F21 where
  mul_assoc := by decide
  one_mul := by decide
  mul_one := by decide
  inv_mul_cancel := by decide

@[simp] lemma card_F21 : Fintype.card F21 = 21 := by decide

end F21

open F21

/-- The first generator, the affine map `t ↦ 2t`. -/
def xg : F21 := ((1 : ZMod 3), (0 : ZMod 7))

/-- The second generator, the affine map `t ↦ 4t + 1`. -/
def yg : F21 := ((2 : ZMod 3), (1 : ZMod 7))

/-- The connection set: two elements of order `3` in distinct cosets of the normal Sylow
`7`-subgroup. -/
def S21 : Set F21 := {xg, yg}

/-- The normal Sylow `7`-subgroup: the translations `t ↦ t + b`. -/
def Nsub : Subgroup F21 where
  carrier := {g : F21 | g.1 = 0}
  mul_mem' := by
    intro g h hg hh
    revert hg hh
    revert g h
    decide
  one_mem' := by decide
  inv_mem' := by
    intro g hg
    revert hg
    revert g
    decide

instance : DecidablePred (· ∈ Nsub) := fun g => decidable_of_iff (g.1 = 0) Iff.rfl

/-- `Nsub` is normal. -/
instance : Nsub.Normal := by
  constructor
  intro n hn g
  revert hn
  revert n g
  decide

/-- `Nsub` really is the Sylow `7`-subgroup: it has seven elements. -/
lemma card_Nsub : Fintype.card Nsub = 7 := by decide

section Cycle

/-- The 21 vertices of the hamiltonian cycle, in order. -/
def cyc : List F21 :=
  [(0, 0), (1, 0), (2, 0), (1, 4), (2, 4), (0, 4), (2, 5), (0, 5), (2, 6), (0, 6), (1, 6),
   (0, 1), (2, 2), (1, 2), (0, 2), (2, 3), (1, 3), (0, 3), (1, 1), (2, 1), (1, 5)]

/-- The cyclic enumeration of `F₂₁` along the hamiltonian cycle. -/
def venum (i : ℕ) : F21 := cyc.getD (i % 21) 1

/-- Adjacency in `Cay(F₂₁, S₂₁)` in fully decidable form. -/
lemma adj_iff {g h : F21} :
    (cayleyGraph F21 S21).Adj g h ↔
      g ≠ h ∧ (g⁻¹ * h = xg ∨ g⁻¹ * h = yg ∨ h⁻¹ * g = xg ∨ h⁻¹ * g = yg) := by
  simp only [cayleyGraph, S21, Set.mem_insert_iff, Set.mem_singleton_iff]
  tauto

private lemma step_key : ∀ r < 21,
    venum r ≠ venum (r + 1) ∧
      ((venum r)⁻¹ * venum (r + 1) = xg ∨ (venum r)⁻¹ * venum (r + 1) = yg ∨
        (venum (r + 1))⁻¹ * venum r = xg ∨ (venum (r + 1))⁻¹ * venum r = yg) := by
  decide

lemma venum_adj (i : ℕ) : (cayleyGraph F21 S21).Adj (venum i) (venum (i + 1)) := by
  have hmod : venum i = venum (i % 21) := by
    unfold venum
    congr 1
    omega
  have hmod' : venum (i + 1) = venum (i % 21 + 1) := by
    unfold venum
    congr 1
    omega
  rw [adj_iff, hmod, hmod']
  exact step_key (i % 21) (Nat.mod_lt _ (by norm_num))

private lemma venum_inj_lt : ∀ i < 21, ∀ j < 21, venum i = venum j → i = j := by
  decide

lemma venum_inj : ∀ i j, i < 21 → j < 21 → venum i = venum j → i = j :=
  fun i j hi hj h => venum_inj_lt i hi j hj h

lemma venum_per (i : ℕ) : venum (i + 21) = venum i := by
  simp [venum, Nat.add_mod_right]

/-- The Cayley graph of the Frobenius group of order `21` with respect to the transversal
connection set `{x, y}` is hamiltonian. -/
theorem isHamiltonian_S21 : (cayleyGraph F21 S21).IsHamiltonian :=
  isHamiltonian_of_enum (by norm_num) card_F21 venum venum_adj venum_inj venum_per

end Cycle

/-- `x` has order `3`. -/
lemma orderOf_xg : orderOf xg = 3 := by
  haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  exact orderOf_eq_prime (by decide) (by decide)

/-- `y` has order `3`. -/
lemma orderOf_yg : orderOf yg = 3 := by
  haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  exact orderOf_eq_prime (by decide) (by decide)

/-- `x · y` is a nontrivial translation, so it has order `7`. -/
lemma orderOf_xy : orderOf (xg * yg) = 7 := by
  haveI : Fact (Nat.Prime 7) := ⟨by norm_num⟩
  exact orderOf_eq_prime (by decide) (by decide)

/-- The two generators generate the whole group. -/
lemma closure_S21 : Subgroup.closure S21 = ⊤ := by
  set H := Subgroup.closure S21 with hH
  have hx : xg ∈ H := Subgroup.subset_closure (by simp [S21])
  have hy : yg ∈ H := Subgroup.subset_closure (by simp [S21])
  have hxy : xg * yg ∈ H := H.mul_mem hx hy
  -- `H` contains elements of order `3` and of order `7`
  have h3 : 3 ∣ Nat.card H := by
    have := orderOf_dvd_natCard (⟨xg, hx⟩ : H)
    rwa [show orderOf (⟨xg, hx⟩ : H) = 3 by rw [← orderOf_xg, ← Subgroup.orderOf_coe]] at this
  have h7 : 7 ∣ Nat.card H := by
    have := orderOf_dvd_natCard (⟨xg * yg, hxy⟩ : H)
    rwa [show orderOf (⟨xg * yg, hxy⟩ : H) = 7 by
      rw [← orderOf_xy, ← Subgroup.orderOf_coe]] at this
  have hdvd : Nat.card H ∣ Nat.card F21 := Subgroup.card_subgroup_dvd_card H
  have hcard : Nat.card F21 = 21 := by
    rw [Nat.card_eq_fintype_card, card_F21]
  rw [hcard] at hdvd
  have h21 : Nat.card H = 21 := by
    have h21dvd : 21 ∣ Nat.card H := Nat.Coprime.mul_dvd_of_dvd_of_dvd (by norm_num) h3 h7
    exact Nat.dvd_antisymm hdvd h21dvd
  refine Subgroup.eq_top_of_card_eq H ?_
  rw [h21, hcard]

/-- **The transversal configuration is nonvacuous and hamiltonian in the smallest case.**
For the Frobenius group `F₂₁ = ℤ/7 ⋊ ℤ/3` and `S = {x, y}` with `x = (1,0)`, `y = (2,1)`:

* `|F₂₁| = 7 · 3`;
* both generators have order `3`, so the connection set misses the normal Sylow `7`-subgroup
  `N` entirely;
* `y x⁻¹ ∉ N`, i.e. `x` and `y` lie in two *different* nontrivial cosets of `N` — so `S` is a
  partial transversal, exactly the configuration left open by
  `pq_isHamiltonian_or_transversal`;
* `S` generates `F₂₁`;
* and `Cay(F₂₁, S)` is nevertheless hamiltonian. -/
theorem frobenius21_transversal_isHamiltonian :
    Fintype.card F21 = 7 * 3 ∧
      orderOf xg = 3 ∧ orderOf yg = 3 ∧
      xg ∉ Nsub ∧ yg ∉ Nsub ∧ yg * xg⁻¹ ∉ Nsub ∧
      Subgroup.closure S21 = ⊤ ∧
      (cayleyGraph F21 S21).IsHamiltonian :=
  ⟨by decide, orderOf_xg, orderOf_yg, by decide, by decide, by decide, closure_S21,
    isHamiltonian_S21⟩

end Frobenius21

end CayleyHamiltonian