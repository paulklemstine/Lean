/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Mathlib
import Applications.PowerSumInversion

/-!
# Exact threshold for power-sum inversion on an arbitrary node set

`Applications/PowerSumInversion.lean` proves the positive half of the story: if two
`ℕ`-valued functions on finite types take their values in a common finite set `A ⊆ ℕ`, then
the power sums `p_k` for `k < #A` determine their value distributions
(`count_eq_of_powerSums_sparse`).  This file proves the matching negative half, for *every*
node set:

* `nodeInv_delta_dual` — over any field, the Lagrange coefficient matrix of a node set `S` is
  a two-sided inverse of the transposed Vandermonde matrix of `S`: `∑_{j ∈ S} j^k · c_{j,k'}`
  is `1` if `k = k'` and `0` otherwise, for `k < #S`.  The proof is Lagrange interpolation of
  the monomial `X^k` followed by extraction of the `k'`-th coefficient — no matrix algebra.
* `nodeWeight_annihilates`, `nodeWeight_top` — the last column of that inverse, the *nodal
  weight vector* `w_a = coeff_{#A-1}(L_a)`, is therefore a nonzero element of the kernel of
  the truncated Vandermonde system: it annihilates all power moments of order `< #A - 1` and
  has top moment `1`.
* `nodeInv_top_eq_inv_prod`, `nodeWeight_eq_inv_prod` — the abstract top row of the inverse
  is identified with the classical inverse nodal products `∏_{b ≠ a} (a - b)⁻¹`, over any
  field and then for natural nodes; this is what makes the witness below computable.
* `powerSums_below_card_insufficient` — clearing denominators in `w` and splitting it into
  its positive and negative parts produces, for every nonempty `A`, an explicit pair of
  functions with values in `A` whose power sums agree for all `k < #A - 1` while their value
  distributions differ.
* `powerSum_window_threshold` — the two halves combined: `#A` power sums suffice and `#A - 1`
  do not.  The threshold is the *number of admissible values*, never their size.

## Lab notes

For `A = {0, 1, 2}` the nodal weights are `w_0 = 1/2, w_1 = -1, w_2 = 1/2`; clearing the
denominator `2` gives `z = (1, -2, 1)`, i.e. the pair `{0, 2}` versus `{1, 1}` — exactly the
level-`2` binomial witness of `Shared/PowerSumSharpness.lean`, recovered here as the
generic construction.  For the sparse set `A = {0, 1, 5}` the same recipe gives
`w = (1/5, -1/4, 1/20)`, hence `z = (4, -5, 1)`: the pair `{0,0,0,0,5}` versus `{1,1,1,1,1}`,
which indeed has equal `p_0 = 5` and `p_1 = 5` but different value distributions.
-/

open Finset Polynomial

namespace PowerSumInversion

/-! ### The two-sided inverse over an arbitrary node set -/

section GeneralDual

variable {F : Type*} [Field F] [DecidableEq F]

/-- **Dual delta identity on an arbitrary node set.**  The Lagrange coefficient matrix
`(v, k) ↦ nodeInv S v k` is a right inverse of the transposed Vandermonde matrix of `S`.
Equivalently, the `k'`-th column of `nodeInv S` is a vector with prescribed power moments:
its moments of order `k ≠ k'` vanish and its `k'`-th moment is `1`. -/
theorem nodeInv_delta_dual (S : Finset F) {k k' : ℕ} (hk : k < S.card) :
    ∑ j ∈ S, j ^ k * nodeInv S j k' = if k = k' then 1 else 0 := by
  have hinj : Set.InjOn (id : F → F) ↑S := fun a _ b _ hab => hab
  have hdeg : ((X : F[X]) ^ k).degree < S.card := by
    rw [Polynomial.degree_X_pow]
    exact_mod_cast hk
  have h := Lagrange.eq_interpolate (v := (id : F → F)) hinj hdeg
  rw [Lagrange.interpolate_apply] at h
  have hcoeff := congrArg (fun p : F[X] => p.coeff k') h
  simp only [Polynomial.finset_sum_coeff, Polynomial.coeff_C_mul, Polynomial.coeff_X_pow] at hcoeff
  simpa [nodeInv, eq_comm] using hcoeff

end GeneralDual

/-! ### The nodal weight vector of a set of natural nodes -/

variable {A : Finset ℕ}

/-- The nodal weight of `a` relative to the node set `A`: the top coefficient of the Lagrange
basis polynomial of `a`.  It equals `∏_{b ∈ A, b ≠ a} (a - b)⁻¹`, proved below as
`nodeWeight_eq_inv_prod`. -/
noncomputable def nodeWeight (A : Finset ℕ) (a : ℕ) : ℚ :=
  nodeInv (A.image (fun n : ℕ => (n : ℚ))) (a : ℚ) (A.card - 1)

lemma card_image_cast (A : Finset ℕ) : (A.image (fun n : ℕ => (n : ℚ))).card = A.card :=
  Finset.card_image_of_injective _ (fun _ _ hab => Nat.cast_injective hab)

lemma sum_nodeWeight_pow (A : Finset ℕ) {k : ℕ} (hk : k < A.card) :
    ∑ a ∈ A, (a : ℚ) ^ k * nodeWeight A a = if k = A.card - 1 then 1 else 0 := by
  have hsum : ∑ j ∈ A.image (fun n : ℕ => (n : ℚ)),
      j ^ k * nodeInv (A.image (fun n : ℕ => (n : ℚ))) j (A.card - 1)
      = ∑ a ∈ A, (a : ℚ) ^ k * nodeWeight A a := by
    rw [Finset.sum_image (fun a _ b _ hab => Nat.cast_injective hab)]
    rfl
  rw [← hsum, nodeInv_delta_dual _ (by rw [card_image_cast]; exact hk)]

/-- The nodal weight vector annihilates all power moments below the top one. -/
theorem nodeWeight_annihilates (A : Finset ℕ) {k : ℕ} (hk : k < A.card - 1) :
    ∑ a ∈ A, (a : ℚ) ^ k * nodeWeight A a = 0 := by
  have hk' : k < A.card := by omega
  rw [sum_nodeWeight_pow A hk', if_neg (by omega)]

/-- Its top moment is `1`; in particular the vector is not identically zero. -/
theorem nodeWeight_top (A : Finset ℕ) (hA : A.Nonempty) :
    ∑ a ∈ A, (a : ℚ) ^ (A.card - 1) * nodeWeight A a = 1 := by
  have hcard : 0 < A.card := Finset.card_pos.mpr hA
  rw [sum_nodeWeight_pow A (by omega), if_pos rfl]

theorem exists_nodeWeight_ne_zero (A : Finset ℕ) (hA : A.Nonempty) :
    ∃ a ∈ A, nodeWeight A a ≠ 0 := by
  by_contra hcon
  push_neg at hcon
  have h := nodeWeight_top A hA
  rw [Finset.sum_congr rfl fun a ha => by rw [hcon a ha, mul_zero]] at h
  simp at h

/-! ### Clearing denominators -/

/-- A common denominator for all nodal weights of `A`. -/
noncomputable def weightDenom (A : Finset ℕ) : ℕ := ∏ a ∈ A, (nodeWeight A a).den

lemma weightDenom_pos (A : Finset ℕ) : 0 < weightDenom A :=
  Finset.prod_pos fun a _ => (nodeWeight A a).pos

/-- The integral rescaling of the nodal weight vector. -/
noncomputable def intWeight (A : Finset ℕ) (a : ℕ) : ℤ :=
  (nodeWeight A a).num * ((weightDenom A) / (nodeWeight A a).den : ℕ)

lemma intWeight_cast {A : Finset ℕ} {a : ℕ} (ha : a ∈ A) :
    ((intWeight A a : ℤ) : ℚ) = (weightDenom A : ℚ) * nodeWeight A a := by
  obtain ⟨c, hc⟩ : (nodeWeight A a).den ∣ weightDenom A :=
    Finset.dvd_prod_of_mem (fun b => (nodeWeight A b).den) ha
  have hden : (nodeWeight A a).den ≠ 0 := (nodeWeight A a).den_nz
  have hdiv : (weightDenom A) / (nodeWeight A a).den = c := by
    rw [hc, Nat.mul_div_cancel_left _ (Nat.pos_of_ne_zero hden)]
  have hnum : ((nodeWeight A a).num : ℚ) = nodeWeight A a * (nodeWeight A a).den := by
    rw [Rat.mul_den_eq_num]
  rw [intWeight, hdiv, hc]
  push_cast
  rw [hnum]
  ring

lemma intWeight_ne_zero {A : Finset ℕ} {a : ℕ} (ha : a ∈ A) (h : nodeWeight A a ≠ 0) :
    intWeight A a ≠ 0 := by
  intro hzero
  have hc := intWeight_cast ha
  rw [hzero] at hc
  have hD : (weightDenom A : ℚ) ≠ 0 := Nat.cast_ne_zero.mpr (weightDenom_pos A).ne'
  simp only [Int.cast_zero] at hc
  exact h (by
    rcases mul_eq_zero.mp hc.symm with h1 | h2
    · exact absurd h1 hD
    · exact h2)

/-! ### The witness pair -/

/-- Positive part of the integral nodal weight vector, used as a multiplicity vector. -/
noncomputable def posPart (A : Finset ℕ) (a : ℕ) : ℕ := (intWeight A a).toNat

/-- Negative part of the integral nodal weight vector. -/
noncomputable def negPart (A : Finset ℕ) (a : ℕ) : ℕ := (-intWeight A a).toNat

lemma posPart_sub_negPart (A : Finset ℕ) (a : ℕ) :
    (posPart A a : ℤ) - (negPart A a : ℤ) = intWeight A a := by
  rw [posPart, negPart]
  omega

/-- The multiset with multiplicity vector `c` supported on `A`. -/
def ofCountsOn (A : Finset ℕ) (c : ℕ → ℕ) : Multiset ℕ :=
  ∑ a ∈ A, Multiset.replicate (c a) a

lemma mem_ofCountsOn {A : Finset ℕ} {c : ℕ → ℕ} {x : ℕ} (hx : x ∈ ofCountsOn A c) : x ∈ A := by
  rw [ofCountsOn] at hx
  obtain ⟨a, ha, hxa⟩ := Multiset.mem_sum.mp hx
  rw [Multiset.eq_of_mem_replicate hxa]
  exact ha

lemma count_ofCountsOn (A : Finset ℕ) (c : ℕ → ℕ) {v : ℕ} (hv : v ∈ A) :
    (ofCountsOn A c).count v = c v := by
  rw [ofCountsOn, Multiset.count_sum']
  rw [Finset.sum_eq_single v]
  · simp
  · intro b _ hbv
    simp [Multiset.count_replicate, hbv]
  · intro hcon
    exact absurd hv hcon

lemma powerSum_ofCountsOn (A : Finset ℕ) (c : ℕ → ℕ) (k : ℕ) :
    PowerSumSharpness.powerSum (ofCountsOn A c) k = ∑ a ∈ A, (c a : ℤ) * (a : ℤ) ^ k := by
  rw [ofCountsOn, PowerSumSharpness.powerSum_finsetSum]
  exact Finset.sum_congr rfl fun a _ => PowerSumSharpness.powerSum_replicate _ _ _

lemma ofMultiset_mem (s : Multiset ℕ) (i : Fin s.toList.length) : ofMultiset s i ∈ s := by
  rw [← Multiset.mem_toList]
  exact List.get_mem _ _

/-- **Sharpness on an arbitrary node set.**  For every nonempty `A ⊆ ℕ` there are two
`ℕ`-valued functions on finite types with values in `A` whose power sums agree for all
`k < #A - 1` but whose value distributions differ.  So the window `k < #A` of
`count_eq_of_powerSums_sparse` cannot be shortened. -/
theorem powerSums_below_card_insufficient (A : Finset ℕ) (hA : A.Nonempty) :
    ∃ (M n : ℕ) (f : Fin M → ℕ) (g : Fin n → ℕ),
      (∀ i, f i ∈ A) ∧ (∀ j, g j ∈ A) ∧
      (∀ k < A.card - 1, powerSumFun f k = powerSumFun g k) ∧
      ∃ v, countFun f v ≠ countFun g v := by
  classical
  refine ⟨_, _, ofMultiset (ofCountsOn A (posPart A)), ofMultiset (ofCountsOn A (negPart A)),
    fun i => mem_ofCountsOn (ofMultiset_mem _ i), fun j => mem_ofCountsOn (ofMultiset_mem _ j),
    fun k hk => ?_, ?_⟩
  · -- equal power sums below the top index
    have hzero : ∑ a ∈ A, (intWeight A a : ℚ) * (a : ℚ) ^ k = 0 := by
      have h1 : ∑ a ∈ A, (intWeight A a : ℚ) * (a : ℚ) ^ k
          = (weightDenom A : ℚ) * ∑ a ∈ A, (a : ℚ) ^ k * nodeWeight A a := by
        rw [Finset.mul_sum]
        exact Finset.sum_congr rfl fun a ha => by rw [intWeight_cast ha]; ring
      rw [h1, nodeWeight_annihilates A hk, mul_zero]
    have hint : ∑ a ∈ A, (posPart A a : ℤ) * (a : ℤ) ^ k
        = ∑ a ∈ A, (negPart A a : ℤ) * (a : ℤ) ^ k := by
      have hq : ((∑ a ∈ A, (posPart A a : ℤ) * (a : ℤ) ^ k : ℤ) : ℚ)
          = ((∑ a ∈ A, (negPart A a : ℤ) * (a : ℤ) ^ k : ℤ) : ℚ) := by
        have hz := hzero
        push_cast at hz ⊢
        have hsplit : ∀ a ∈ A, ((intWeight A a : ℚ)) * (a : ℚ) ^ k
            = (posPart A a : ℚ) * (a : ℚ) ^ k - (negPart A a : ℚ) * (a : ℚ) ^ k := by
          intro a _
          have hpn := posPart_sub_negPart A a
          have hcast : ((posPart A a : ℤ) : ℚ) - ((negPart A a : ℤ) : ℚ)
              = ((intWeight A a : ℤ) : ℚ) := by exact_mod_cast congrArg (fun z : ℤ => (z : ℚ)) hpn
          push_cast at hcast
          rw [← hcast]
          ring
        rw [Finset.sum_congr rfl hsplit, Finset.sum_sub_distrib] at hz
        linarith
      exact_mod_cast hq
    have h1 := powerSumFun_ofMultiset (ofCountsOn A (posPart A)) k
    have h2 := powerSumFun_ofMultiset (ofCountsOn A (negPart A)) k
    rw [powerSum_ofCountsOn] at h1
    rw [powerSum_ofCountsOn] at h2
    omega
  · -- different value distributions
    obtain ⟨a₀, ha₀, hne⟩ := exists_nodeWeight_ne_zero A hA
    refine ⟨a₀, ?_⟩
    rw [countFun_ofMultiset, countFun_ofMultiset,
      count_ofCountsOn A _ ha₀, count_ofCountsOn A _ ha₀]
    intro hcon
    have hz := intWeight_ne_zero ha₀ hne
    have hpn := posPart_sub_negPart A a₀
    rw [hcon] at hpn
    omega


/-! ### The nodal weights are the classical inverse nodal products -/

section ClosedForm

variable {F : Type*} [Field F] [DecidableEq F]

/-- **Closed form for the top row of the inverse.**  The top coefficient of the Lagrange
basis polynomial of a node `v` is the inverse nodal product `∏_{j ∈ S, j ≠ v} (v - j)⁻¹`. -/
theorem nodeInv_top_eq_inv_prod {S : Finset F} {v : F} (hv : v ∈ S) :
    nodeInv S v (S.card - 1) = (∏ j ∈ S.erase v, (v - j))⁻¹ := by
  have hmonic : (∏ j ∈ S.erase v, (X - C j)).Monic :=
    monic_prod_of_monic _ _ fun j _ => monic_X_sub_C j
  have hdeg : (∏ j ∈ S.erase v, (X - C j)).natDegree = S.card - 1 := by
    rw [natDegree_prod _ _ (fun j _ => X_sub_C_ne_zero j)]
    simp [Finset.card_erase_of_mem hv]
  have hfac : Lagrange.basis S id v
      = C (∏ j ∈ S.erase v, (v - j))⁻¹ * ∏ j ∈ S.erase v, (X - C j) := by
    simp only [Lagrange.basis, Lagrange.basisDivisor, id_eq]
    rw [Finset.prod_mul_distrib, ← map_prod, ← Finset.prod_inv_distrib]
  rw [nodeInv, hfac, coeff_C_mul, ← hdeg, hmonic.coeff_natDegree, mul_one]

end ClosedForm

/-- The nodal weight of a natural node is the inverse of the product of its distances to the
other nodes, computed in `ℚ`. -/
theorem nodeWeight_eq_inv_prod {A : Finset ℕ} {a : ℕ} (ha : a ∈ A) :
    nodeWeight A a = (∏ b ∈ A.erase a, ((a : ℚ) - (b : ℚ)))⁻¹ := by
  classical
  have hinj : Function.Injective (fun n : ℕ => (n : ℚ)) := fun x y hxy => Nat.cast_injective hxy
  have himg : (A.image (fun n : ℕ => (n : ℚ))).erase (a : ℚ)
      = (A.erase a).image (fun n : ℕ => (n : ℚ)) := by
    rw [Finset.image_erase (f := fun n : ℕ => (n : ℚ)) hinj]
  rw [nodeWeight, ← card_image_cast A,
    nodeInv_top_eq_inv_prod (Finset.mem_image_of_mem _ ha), himg,
    Finset.prod_image (fun x _ y _ hxy => hinj hxy)]

/-! ### Verified lab data for the nodal weights -/

example : nodeWeight {0, 1, 2} 0 = 1 / 2 := by
  rw [nodeWeight_eq_inv_prod (by decide)]
  have h : ({0, 1, 2} : Finset ℕ).erase 0 = {1, 2} := by decide
  rw [h]
  norm_num

example : nodeWeight {0, 1, 5} 5 = 1 / 20 := by
  rw [nodeWeight_eq_inv_prod (by decide)]
  have h : ({0, 1, 5} : Finset ℕ).erase 5 = {0, 1} := by decide
  rw [h]
  norm_num

/-- **Exact threshold.**  For functions with values in a fixed finite set `A ⊆ ℕ`, the power
sums `p_0, …, p_{#A - 1}` determine the value distribution, and the shorter window
`p_0, …, p_{#A - 2}` does not.  The threshold depends only on the *number* of admissible
values. -/
theorem powerSum_window_threshold (A : Finset ℕ) (hA : A.Nonempty) :
    (∀ (α β : Type) (_ : Fintype α) (_ : Fintype β) (f : α → ℕ) (g : β → ℕ),
        (∀ i, f i ∈ A) → (∀ j, g j ∈ A) →
        (∀ k < A.card, powerSumFun f k = powerSumFun g k) →
        ∀ v, countFun f v = countFun g v)
      ∧ ∃ (M n : ℕ) (f : Fin M → ℕ) (g : Fin n → ℕ),
        (∀ i, f i ∈ A) ∧ (∀ j, g j ∈ A) ∧
        (∀ k < A.card - 1, powerSumFun f k = powerSumFun g k) ∧
        ∃ v, countFun f v ≠ countFun g v := by
  refine ⟨fun α β _ _ f g hf hg h v => count_eq_of_powerSums_sparse hf hg h v,
    powerSums_below_card_insufficient A hA⟩

end PowerSumInversion