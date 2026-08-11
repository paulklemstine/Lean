import Tropical.MagmaMonoid.Structure

/-!
# The unit group of the magma monoid, and its exact order

The representation theorem of `Structure.lean` identifies `Bin X` with the
centralizer of pair reversal in the *transformation monoid* of `X × X`.  Here we
upgrade it to the group level and extract an exact enumeration.

* `unitsMulEquiv : (Bin X)ˣ ≃* (Subgroup.centralizer {swapPerm X})ᵐᵒᵖ` — the
  invertible binary operations on `X` are exactly the permutations of `X × X`
  commuting with reversal (with the multiplication reversed).

* `card_units_bin_fin` — for `X = Fin n`,
  `|(Bin X)ˣ| = n! · 2^m · m!` with `m = n(n-1)/2`,
  because reversal is an involution of `X × X` with `n` fixed points and `m`
  transpositions.  For `n = 2` this gives `2 · 2 · 1 = 4`, matching the
  brute-force census of `ComputationalEvidence.md`.

Note the contrast with `|Bin X| = n^(n²)`: the invertible part of the magma
monoid is very small, of "wreath product" size `Sym(n) × (ℤ/2 ≀ Sym(m))`.
-/

namespace MagmaMonoid

variable {X : Type*}

/-- Pair reversal as a permutation of `X × X`. -/
def swapPerm (X : Type*) : Equiv.Perm (X × X) := Equiv.prodComm X X

@[simp] theorem swapPerm_apply (p : X × X) : swapPerm X p = swap p := rfl

theorem mem_centralizer_swapPerm_iff (F : Equiv.Perm (X × X)) :
    F ∈ Subgroup.centralizer {swapPerm X} ↔ IsPairmorph (F : X × X → X × X) := by
  rw [Subgroup.mem_centralizer_iff]
  constructor
  · intro h p
    exact (congrFun (congrArg (fun (e : Equiv.Perm (X × X)) ↦ (e : X × X → X × X))
      (h _ rfl)) p).symm
  · rintro h g rfl
    exact Equiv.ext fun p ↦ (h p).symm

/-! ### Units as swap-equivariant permutations -/

/-- The permutation of `X × X` attached to a unit of the magma monoid. -/
def unitToPerm (u : (Bin X)ˣ) : Equiv.Perm (X × X) where
  toFun := pairmorph u.val
  invFun := pairmorph u.inv
  left_inv p := by
    have h : pairmorph (product (u.val : Bin X) (u.inv : Bin X)) = pairmorph leftZero :=
      congrArg pairmorph u.val_inv
    rw [pairmorph_product, pairmorph_leftZero] at h
    exact congrFun h p
  right_inv p := by
    have h : pairmorph (product (u.inv : Bin X) (u.val : Bin X)) = pairmorph leftZero :=
      congrArg pairmorph u.inv_val
    rw [pairmorph_product, pairmorph_leftZero] at h
    exact congrFun h p

@[simp] theorem unitToPerm_apply (u : (Bin X)ˣ) (p : X × X) :
    unitToPerm u p = pairmorph u.val p := rfl

theorem unitToPerm_mem (u : (Bin X)ˣ) : unitToPerm u ∈ Subgroup.centralizer {swapPerm X} :=
  (mem_centralizer_swapPerm_iff _).2 (pairmorph_commutes _)

/-- The unit of the magma monoid attached to a swap-equivariant permutation. -/
def permToUnit (T : Subgroup.centralizer {swapPerm X}) : (Bin X)ˣ where
  val := fun a b ↦ ((T : Equiv.Perm (X × X)) (a, b)).1
  inv := fun a b ↦ ((T : Equiv.Perm (X × X)).symm (a, b)).1
  val_inv := by
    have hT : IsPairmorph ((T : Equiv.Perm (X × X)) : X × X → X × X) :=
      (mem_centralizer_swapPerm_iff _).1 T.2
    have hTs : IsPairmorph (((T : Equiv.Perm (X × X)).symm : X × X → X × X)) :=
      isPairmorph_of_inverse hT (T : Equiv.Perm (X × X)).injective
        (fun q ↦ (T : Equiv.Perm (X × X)).apply_symm_apply q)
    show product _ _ = leftZero
    refine pairmorph_injective ?_
    rw [pairmorph_product, pairmorph_ofIsPairmorph hT, pairmorph_ofIsPairmorph hTs,
      pairmorph_leftZero]
    exact funext fun p ↦ (T : Equiv.Perm (X × X)).symm_apply_apply p
  inv_val := by
    have hT : IsPairmorph ((T : Equiv.Perm (X × X)) : X × X → X × X) :=
      (mem_centralizer_swapPerm_iff _).1 T.2
    have hTs : IsPairmorph (((T : Equiv.Perm (X × X)).symm : X × X → X × X)) :=
      isPairmorph_of_inverse hT (T : Equiv.Perm (X × X)).injective
        (fun q ↦ (T : Equiv.Perm (X × X)).apply_symm_apply q)
    show product _ _ = leftZero
    refine pairmorph_injective ?_
    rw [pairmorph_product, pairmorph_ofIsPairmorph hT, pairmorph_ofIsPairmorph hTs,
      pairmorph_leftZero]
    exact funext fun p ↦ (T : Equiv.Perm (X × X)).apply_symm_apply p

/-- Units of the magma monoid are in bijection with the permutations of `X × X`
commuting with pair reversal. -/
def unitsEquivCentralizer : (Bin X)ˣ ≃ Subgroup.centralizer {swapPerm X} where
  toFun u := ⟨unitToPerm u, unitToPerm_mem u⟩
  invFun T := permToUnit T
  left_inv u := Units.ext rfl
  right_inv T := by
    refine Subtype.ext (Equiv.ext fun p ↦ ?_)
    have hT : IsPairmorph ((T : Equiv.Perm (X × X)) : X × X → X × X) :=
      (mem_centralizer_swapPerm_iff _).1 T.2
    exact congrFun (pairmorph_ofIsPairmorph hT) p

/-- **The unit group of the magma monoid** is anti-isomorphic to the centralizer
of pair reversal inside `Sym(X × X)`. -/
def unitsMulEquiv : (Bin X)ˣ ≃* (Subgroup.centralizer {swapPerm X})ᵐᵒᵖ where
  toFun u := MulOpposite.op (unitsEquivCentralizer u)
  invFun T := unitsEquivCentralizer.symm T.unop
  left_inv u := by simp
  right_inv T := by simp
  map_mul' u v := by
    refine MulOpposite.unop_injective (Subtype.ext (Equiv.ext fun p ↦ ?_))
    show pairmorph (product (u.val : Bin X) (v.val : Bin X)) p
        = pairmorph (v.val : Bin X) (pairmorph (u.val : Bin X) p)
    rw [pairmorph_product]
    rfl

/-! ### The exact order of the unit group for a finite set -/

theorem swapPerm_sq (n : ℕ) : (swapPerm (Fin n)) ^ 2 = 1 := by
  ext p <;> simp [swapPerm, pow_two]

theorem swapPerm_support (n : ℕ) :
    (swapPerm (Fin n)).support = Finset.univ.offDiag := by
  ext p
  simp [swapPerm, Equiv.Perm.mem_support, Finset.mem_offDiag, Prod.ext_iff, eq_comm]

/-- Pair reversal on `Fin n × Fin n` is a product of `n(n-1)/2` disjoint
transpositions. -/
theorem swapPerm_cycleType (n : ℕ) :
    (swapPerm (Fin n)).cycleType = Multiset.replicate (n * (n - 1) / 2) 2 := by
  have h := Equiv.Perm.cycleType_of_pow_prime_eq_one (p := 2) (swapPerm_sq n)
  have hsum : (swapPerm (Fin n)).cycleType.sum = n * (n - 1) := by
    rw [Equiv.Perm.sum_cycleType, swapPerm_support, Nat.mul_sub, mul_one]
    simp [Finset.offDiag_card]
  rw [h] at hsum ⊢
  rw [Multiset.sum_replicate, smul_eq_mul] at hsum
  congr 1
  omega

/-- The centralizer of pair reversal in `Sym(Fin n × Fin n)` has order
`n! · 2^m · m!` with `m = n(n-1)/2`. -/
theorem card_centralizer_swapPerm (n : ℕ) :
    Nat.card (Subgroup.centralizer {swapPerm (Fin n)})
      = Nat.factorial n * 2 ^ (n * (n - 1) / 2) * Nat.factorial (n * (n - 1) / 2) := by
  rw [Equiv.Perm.nat_card_centralizer, swapPerm_cycleType]
  have hcard : Fintype.card (Fin n × Fin n) = n * n := by simp
  rw [hcard, Multiset.sum_replicate, smul_eq_mul, Multiset.prod_replicate]
  set m := n * (n - 1) / 2 with hm
  have hmm : m * 2 = n * (n - 1) := by
    have he : 2 ∣ n * (n - 1) := (Nat.even_mul_pred_self n).two_dvd
    omega
  have hle : n ≤ n * n := by
    cases n with
    | zero => simp
    | succ k => exact Nat.le_mul_of_pos_left _ (Nat.succ_pos k)
  have h1 : n * n - m * 2 = n := by
    rw [hmm, Nat.mul_sub, mul_one]
    omega
  rw [h1]
  rcases Nat.eq_zero_or_pos m with h0 | h0
  · simp [h0]
  · rw [Multiset.toFinset_replicate, if_neg h0.ne']
    simp

/-- **Order of the unit group of the magma monoid on an `n`-element set:**
`|(Bin (Fin n))ˣ| = n! · 2^m · m!` where `m = n(n-1)/2`.

For `n = 2` this is `2 · 2 · 1 = 4`, for `n = 3` it is `6 · 8 · 6 = 288`, a
vanishing fraction of the `n^(n²)` elements of `Bin(Fin n)`. -/
theorem card_units_bin_fin (n : ℕ) :
    Nat.card ((Bin (Fin n))ˣ)
      = Nat.factorial n * 2 ^ (n * (n - 1) / 2) * Nat.factorial (n * (n - 1) / 2) := by
  rw [Nat.card_congr (unitsEquivCentralizer (X := Fin n)), card_centralizer_swapPerm]

/-- The magma monoid on a two-element set has exactly four units. -/
theorem card_units_bin_fin_two : Nat.card ((Bin (Fin 2))ˣ) = 4 := by
  rw [card_units_bin_fin]
  decide

/-- The magma monoid on a three-element set has exactly `288` units. -/
theorem card_units_bin_fin_three : Nat.card ((Bin (Fin 3))ˣ) = 288 := by
  rw [card_units_bin_fin]
  decide

end MagmaMonoid