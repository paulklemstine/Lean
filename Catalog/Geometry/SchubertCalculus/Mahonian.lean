/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Geometry.SchubertCalculus.FlagCount

/-!
# Schubert calculus XI: the Mahonian identity and the Bruhat decomposition of the point count

`FlagCount.lean` proves that an `N`-dimensional vector space over a field with `q` elements has
exactly `[N]_q ! = ∏_{j=1}^{N}(1 + q + ⋯ + q^{j-1})` complete flags.  The Bruhat decomposition
predicts a *finer* statement: the flag variety is the disjoint union of one affine cell per
permutation `w ∈ S_N`, the cell of `w` having dimension `inv w`, the number of inversions of
`w`.  Counting points cell by cell therefore predicts

`# Fl(V) = ∑_{w ∈ S_N} q^{inv w}`,

and comparing with the `q`-factorial gives the classical **Mahonian identity**

`∑_{w ∈ S_N} q^{inv w} = [N]_q !`.

This file proves the Mahonian identity over an arbitrary commutative semiring (so it is a
genuine polynomial identity, not merely a numerical one) and combines it with
`SchubertCalculus.card_completeFlag_eq_qFactorial` to obtain the Bruhat-flavoured point count.

The proof is a `q`-analogue of `(N+1)! = (N+1) · N !`.  Writing a permutation
`w ∈ S_{n+1}` as the pair `(w 0, e)` where `e ∈ S_n` records the remaining values *in their
relative order*, one has

`inv w = w 0 + inv e`,

because the inversions of `w` involving the index `0` are exactly the `w 0` positions carrying
a value smaller than `w 0`, while the remaining inversions are those of `e`.  The
order-preserving reindexing is `Fin.succAbove (w 0) : Fin n ↪o Fin (n+1)`, whose image is the
complement of `{w 0}`; the resulting map
`SchubertCalculus.liftPerm : Fin (n+1) × S_n → S_{n+1}` is injective, hence bijective by a
cardinality count (`SchubertCalculus.liftPermEquiv`).

Main results:

* `SchubertCalculus.invCount` : the number of inversions of a permutation of `Fin n`;
* `SchubertCalculus.liftPermEquiv` : the order-preserving decomposition
  `S_{n+1} ≃ Fin (n+1) × S_n`;
* `SchubertCalculus.invCount_liftPerm` : `inv (liftPerm k e) = k + inv e`;
* `SchubertCalculus.sum_pow_invCount` : **the Mahonian identity** over any commutative
  semiring;
* `SchubertCalculus.sign_eq_neg_one_pow_invCount` : `sgn w = (-1)^{inv w}`;
* `SchubertCalculus.sum_sign_eq_zero` : the `q = -1` specialisation, `∑_{w ∈ S_n} sgn w = 0`
  for `n ≥ 2`;
* `SchubertCalculus.card_completeFlag_eq_sum_pow_invCount` : the Bruhat form of the point count
  of the flag variety;
* `SchubertCalculus.mahonian_three` : `∑_{w ∈ S₃} q^{inv w} = 1 + 2q + 2q² + q³`, checked
  against the `21` points of `Fl(𝔽₂³)`.
-/

namespace SchubertCalculus

open Finset

/-! ### Inversions -/

/-- The number of inversions of a permutation of `Fin n`: the number of pairs `i < j` with
`w j < w i`.  This is the length of `w` in the Coxeter group `S_n`, and the dimension of the
Bruhat cell of `w` in the complete flag variety. -/
def invCount {n : ℕ} (w : Equiv.Perm (Fin n)) : ℕ :=
  ∑ i : Fin n, #{j ∈ (univ : Finset (Fin n)) | i < j ∧ w j < w i}

@[simp] theorem invCount_zero (w : Equiv.Perm (Fin 0)) : invCount w = 0 := by
  simp [invCount]

@[simp] theorem invCount_one (w : Equiv.Perm (Fin 1)) : invCount w = 0 := by
  simp [invCount, Finset.filter_eq_empty_iff]

/-- The identity permutation has no inversions. -/
@[simp] theorem invCount_refl (n : ℕ) : invCount (Equiv.refl (Fin n)) = 0 := by
  refine Finset.sum_eq_zero fun i _ => ?_
  rw [Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  intro j _ h
  exact absurd h.1 (not_lt.2 h.2.le)

/-! ### The order-preserving decomposition `S_{n+1} ≃ Fin (n+1) × S_n` -/

variable {n : ℕ}

/-- Given a value `k : Fin (n+1)` and a permutation `e` of `Fin n`, the permutation of
`Fin (n+1)` sending `0` to `k` and `i.succ` to the `e i`-th element of `Fin (n+1) \ {k}`,
listed in increasing order. -/
def liftPerm (k : Fin (n + 1)) (e : Equiv.Perm (Fin n)) : Equiv.Perm (Fin (n + 1)) :=
  (finSuccEquiv' (0 : Fin (n + 1))).trans ((Equiv.optionCongr e).trans (finSuccEquiv' k).symm)

@[simp] theorem liftPerm_zero (k : Fin (n + 1)) (e : Equiv.Perm (Fin n)) :
    liftPerm k e 0 = k := by
  simp [liftPerm]

@[simp] theorem liftPerm_succ (k : Fin (n + 1)) (e : Equiv.Perm (Fin n)) (i : Fin n) :
    liftPerm k e i.succ = k.succAbove (e i) := by
  have h : (finSuccEquiv' (0 : Fin (n + 1))) i.succ = some i := by
    rw [← Fin.zero_succAbove i]
    exact finSuccEquiv'_succAbove 0 i
  simp [liftPerm, h]

theorem liftPerm_injective :
    Function.Injective (fun p : Fin (n + 1) × Equiv.Perm (Fin n) => liftPerm p.1 p.2) := by
  rintro ⟨k, e⟩ ⟨k', e'⟩ h
  simp only at h
  have h0 : k = k' := by
    have := congrArg (fun w : Equiv.Perm (Fin (n + 1)) => w 0) h
    simpa using this
  subst h0
  refine Prod.ext rfl (Equiv.ext fun i => ?_)
  have := congrArg (fun w : Equiv.Perm (Fin (n + 1)) => w i.succ) h
  simp only [liftPerm_succ] at this
  exact Fin.succAbove_right_injective this

/-- The order-preserving decomposition of the symmetric group: a permutation of `Fin (n+1)` is
the same thing as a value `w 0 ∈ Fin (n+1)` together with a permutation of `Fin n` recording
the relative order of the remaining values. -/
noncomputable def liftPermEquiv (n : ℕ) :
    Fin (n + 1) × Equiv.Perm (Fin n) ≃ Equiv.Perm (Fin (n + 1)) :=
  Equiv.ofBijective _ ((Fintype.bijective_iff_injective_and_card _).2
    ⟨liftPerm_injective, by simp [Fintype.card_perm, Nat.factorial_succ]⟩)

@[simp] theorem liftPermEquiv_apply (k : Fin (n + 1)) (e : Equiv.Perm (Fin n)) :
    liftPermEquiv n (k, e) = liftPerm k e := rfl

/-- Exactly `k` of the `n` elements of `Fin (n+1) \ {k}` lie below `k`. -/
theorem card_succAbove_lt (k : Fin (n + 1)) :
    #{c ∈ (univ : Finset (Fin n)) | k.succAbove c < k} = (k : ℕ) := by
  have key : ∀ c : Fin n, (k.succAbove c < k) ↔ ((c : ℕ) < (k : ℕ)) := by
    intro c
    rw [Fin.succAbove_lt_iff_castSucc_lt]
    simp [Fin.lt_def]
  simp only [Finset.filter_congr (fun c _ => (key c))]
  rw [Finset.card_filter, Fin.sum_univ_eq_sum_range (fun i => if i < (k : ℕ) then 1 else 0),
    ← Finset.card_filter]
  have hrange : (Finset.range n).filter (fun i => i < (k : ℕ)) = Finset.range (k : ℕ) := by
    ext x
    simp only [Finset.mem_filter, Finset.mem_range]
    have := k.isLt
    omega
  rw [hrange, Finset.card_range]

/-- **The inversion recursion.**  Splitting off the value at the index `0` splits the
inversions of a permutation of `Fin (n+1)` into the `k = w 0` inversions involving the index
`0` and the inversions of the induced permutation of `Fin n`. -/
theorem invCount_liftPerm (k : Fin (n + 1)) (e : Equiv.Perm (Fin n)) :
    invCount (liftPerm k e) = (k : ℕ) + invCount e := by
  unfold invCount
  rw [Fin.sum_univ_succ]
  congr 1
  · rw [Finset.card_filter, Fin.sum_univ_succ]
    simp only [liftPerm_zero, liftPerm_succ, Fin.succ_pos, true_and, lt_self_iff_false,
      false_and, if_false, zero_add]
    rw [← Finset.card_filter]
    have hreindex : #{b ∈ (univ : Finset (Fin n)) | k.succAbove (e b) < k}
        = #{c ∈ (univ : Finset (Fin n)) | k.succAbove c < k} := by
      apply Finset.card_nbij (fun b => e b)
      · intro b hb
        simpa using hb
      · intro a _ b _ h
        exact e.injective h
      · intro c hc
        exact ⟨e.symm c, by simpa using hc, by simp⟩
    rw [hreindex, card_succAbove_lt]
  · refine Finset.sum_congr rfl fun a _ => ?_
    rw [Finset.card_filter, Fin.sum_univ_succ]
    simp only [liftPerm_succ, Fin.succ_lt_succ_iff, Fin.succAbove_lt_succAbove_iff,
      Fin.not_lt_zero, false_and, if_false, zero_add]
    rw [← Finset.card_filter]

/-! ### The Mahonian identity -/

/-- **The Mahonian identity.**  The inversion-generating function of the symmetric group `S_n`
is the `q`-factorial: `∑_{w ∈ S_n} q^{inv w} = ∏_{j=0}^{n-1}(1 + q + ⋯ + q^j)`.  The identity
holds over an arbitrary commutative semiring, so it is a polynomial identity in `q`. -/
theorem sum_pow_invCount {R : Type*} [CommSemiring R] (q : R) (n : ℕ) :
    ∑ w : Equiv.Perm (Fin n), q ^ invCount w
      = ∏ j ∈ range n, ∑ a ∈ range (j + 1), q ^ a := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [Finset.prod_range_succ, ← ih, ← Equiv.sum_comp (liftPermEquiv n) (fun w => q ^ invCount w),
      Fintype.sum_prod_type]
    have hfib : ∀ k : Fin (n + 1),
        ∑ e : Equiv.Perm (Fin n), q ^ invCount (liftPermEquiv n (k, e))
          = q ^ (k : ℕ) * ∑ e : Equiv.Perm (Fin n), q ^ invCount e := by
      intro k
      rw [Finset.mul_sum]
      exact Finset.sum_congr rfl fun e _ => by
        rw [liftPermEquiv_apply, invCount_liftPerm, pow_add]
    rw [Finset.sum_congr rfl fun k _ => hfib k, ← Finset.sum_mul,
      Fin.sum_univ_eq_sum_range (fun a => q ^ a)]
    ring

/-- The Mahonian identity in the numerical form used by `FlagCount.lean`. -/
theorem sum_pow_invCount_eq_qFactorial (q n : ℕ) :
    ∑ w : Equiv.Perm (Fin n), q ^ invCount w = qFactorial q n :=
  sum_pow_invCount q n

/-! ### The sign of a permutation -/

/-- The inversion statistic computes the sign: `sgn w = (-1)^{inv w}`.  This identifies
`invCount` with the parity of the Coxeter length of `w`, and so bridges the geometric grading
of the Bruhat cells with the group-theoretic sign homomorphism. -/
theorem sign_eq_neg_one_pow_invCount (w : Equiv.Perm (Fin n)) :
    Equiv.Perm.sign w = (-1) ^ invCount w := by
  rw [Equiv.Perm.sign_eq_prod_prod_Ioi, invCount, ← Finset.prod_pow_eq_pow_sum]
  refine Finset.prod_congr rfl fun i _ => ?_
  rw [Finset.prod_ite, Finset.prod_const_one, one_mul, Finset.prod_const]
  congr 1
  have hset : (Finset.Ioi i).filter (fun j => ¬ (w i < w j))
      = {j ∈ (univ : Finset (Fin n)) | i < j ∧ w j < w i} := by
    ext j
    simp only [Finset.mem_filter, Finset.mem_Ioi, Finset.mem_univ, true_and, not_lt]
    constructor
    · rintro ⟨hij, hle⟩
      exact ⟨hij, lt_of_le_of_ne hle fun h => absurd (w.injective h) (ne_of_gt hij)⟩
    · rintro ⟨hij, hlt⟩
      exact ⟨hij, hlt.le⟩
  rw [hset]

/-- Specialising the Mahonian identity at `q = -1` and using
`SchubertCalculus.sign_eq_neg_one_pow_invCount`: for `n ≥ 2` the symmetric group has as many
even as odd permutations, because the `q`-factorial has the vanishing factor `1 + q`. -/
theorem sum_sign_eq_zero (hn : 2 ≤ n) :
    ∑ w : Equiv.Perm (Fin n), (Equiv.Perm.sign w : ℤ) = 0 := by
  have h : ∀ w : Equiv.Perm (Fin n), ((Equiv.Perm.sign w : ℤ)) = (-1 : ℤ) ^ invCount w := by
    intro w
    rw [sign_eq_neg_one_pow_invCount]
    push_cast
    ring
  rw [Finset.sum_congr rfl fun w _ => h w, sum_pow_invCount]
  refine Finset.prod_eq_zero (Finset.mem_range.mpr (by omega) : (1 : ℕ) ∈ range n) ?_
  decide

/-! ### The Bruhat form of the point count of the flag variety -/

variable {K V : Type*} [Field K] [Fintype K] [AddCommGroup V] [Module K V]
  [FiniteDimensional K V] {N : ℕ}

open Module

/-- **Bruhat point count of the flag variety.**  Over a field with `q` elements, an
`N`-dimensional vector space has `∑_{w ∈ S_N} q^{inv w}` complete flags: one affine cell of
dimension `inv w` for each permutation `w`.  This is the finer, cell-by-cell form of
`SchubertCalculus.card_completeFlag_eq_qFactorial`. -/
theorem card_completeFlag_eq_sum_pow_invCount (hN : N = finrank K V) :
    Nat.card (CompleteFlag K V N)
      = ∑ w : Equiv.Perm (Fin N), (Fintype.card K) ^ invCount w := by
  rw [card_completeFlag_eq_qFactorial hN, sum_pow_invCount_eq_qFactorial]

/-! ### A worked case -/

/-- The inversion-generating function of `S₃` is `1 + 2q + 2q² + q³`. -/
theorem mahonian_three {R : Type*} [CommSemiring R] (q : R) :
    ∑ w : Equiv.Perm (Fin 3), q ^ invCount w = 1 + 2 * q + 2 * q ^ 2 + q ^ 3 := by
  rw [sum_pow_invCount]
  simp [Finset.prod_range_succ, Finset.sum_range_succ]
  ring

/-- Consistency with the geometric count: `Fl(𝔽₂³)` has `21` points, and `21` is the value at
`q = 2` of the inversion-generating function of `S₃`. -/
theorem mahonian_three_two : ∑ w : Equiv.Perm (Fin 3), 2 ^ invCount w = 21 := by
  rw [mahonian_three]
  norm_num

end SchubertCalculus