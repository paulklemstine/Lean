/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Mathlib
import Applications.NearMissUniversality

/-!
# Power-sum inversion: recovering value distributions from traces

Let `f : α → ℕ` be a `ℕ`-valued function on a finite type, with all values bounded by `N`,
and let `p_k(f) = ∑_{i} f i ^ k` be its power sums.  This file proves that the window
`0 ≤ k ≤ N` of power sums determines the whole *value distribution* of `f` — the fibre
counts `#{i | f i = v}` — and it does so **constructively**, by explicitly inverting the
transposed Vandermonde system with the nodes `0, 1, …, N` over `ℚ`.

Where `Shared/PowerSumSharpness.lean` proves rigidity for multisets by an abstract
injectivity argument, this file produces the *inverse operator*: a fixed rational matrix
`vanInv N` (the coefficient matrix of the Lagrange basis of the nodes `0,…,N`) such that

`count_f(v) = ∑_{k ≤ N} vanInv N v k · p_k(f)`

for every bounded `f` and every node `v ≤ N`.  Everything else in the file is a consequence
of having the inverse in hand rather than merely knowing it exists.

## Main results

* `vanInv_delta` — the defining identity of the inverse: `∑_{k ≤ N} vanInv N v k · j^k = δ_{jv}`
  for nodes `j, v ≤ N`.  This says `vanInv N` is a left inverse of the transposed Vandermonde
  matrix `(j^k)_{k,j}`.
* `vandermondeT_solve` — **explicit inversion**.  For *any* coefficient vector `c : ℕ → ℚ`
  supported on `{0,…,N}` and any node `v ≤ N`,
  `c v = ∑_{k ≤ N} vanInv N v k · (∑_{j ≤ N} c j · j^k)`.
  The count theorem, the multiset theorem and the stability estimate are all corollaries.
* `count_eq_sum_vanInv_powerSum` — the inversion formula for fibre counts of a bounded
  function on a finite type.
* `count_eq_of_powerSums` — **the mission statement**: two `ℕ`-valued functions on finite
  types, bounded by `N`, with equal power sums for all `k ≤ N`, have equal value
  distributions.  No hypothesis relating the two index types is needed: the equality of
  cardinalities (`card_eq_of_powerSums`) is itself part of the conclusion (the `k = 0`
  component).
* `exists_equiv_of_powerSums` — the strongest form: the two index types are in bijection by
  a bijection *transporting `f` to `g`*.  So "equal power sums up to `N`" is exactly
  "equal up to relabelling of the index set".
* `valueMultiset_eq_of_powerSums` — the value multisets coincide, which recovers the
  multiset rigidity theorem `PowerSumSharpness.powerSums_determine` along an independent
  (constructive, Lagrange-based) route.
* `count_sub_le_of_powerSums_close` — **quantitative stability**.  If the power sums only
  agree up to an error `ε` then the counts agree up to `Λ_N(v) · ε`, where
  `Λ_N(v) = ∑_k |vanInv N v k|` is the `ℓ¹` norm of the inverse row (a Lebesgue-constant).
  Since counts are integers, `count_eq_of_powerSums_close` upgrades this to *exact*
  equality as soon as `Λ_N(v) · ε < 1`: the inversion is robust, not just injective.
* `vandermonde_det_ne_zero`, `isUnit_vandermondeT` — the linear-algebra reading: the
  Vandermonde matrix of the nodes `0,…,N` over `ℚ` and its transpose are invertible.
* `trace_pow_diagonal`, `count_eq_of_traces` — the spectral reading: for diagonalisable
  rational matrices whose eigenvalue lists take values in `{0,…,N}`, the traces
  `tr(A^k)`, `k ≤ N`, determine the eigenvalue multiplicities.
* `vanMat_mul_vanInvMat`, `vanInv_delta_dual` — the Lagrange coefficient matrix is a
  *two-sided* inverse: the columns of `vanInv N` realise every prescribed moment vector, so
  the moment map is onto as well as injective.
* `momentEquiv` — consequently "count vector ↦ moment vector" is a `ℚ`-linear automorphism of
  `ℚ^{N+1}`, with `momentEquiv_symm_apply` the inversion formula.
* `vanInv_unique` — the inversion operator is *canonical*: any row vector recovering the
  count at `v` from the power sums of every rational vector on the nodes is the `v`-th row of
  `vanInv N`.
* `lebesgueConst_pos` — the inverse row is never zero, so the stability estimate is never
  vacuous.
* `countVal_eq_of_powerSums`, `count_eq_of_powerSums_sparse` — the window length is governed
  by the *number* of admissible values, not their size: values in a set `T` of `m` naturals
  (or in any `m`-element node set of a characteristic-zero field) are pinned down by
  `p_0, …, p_{m-1}`.  `Applications/PowerSumInversionSharp.lean` shows this is exactly sharp.
* `powerSums_below_top_insufficient` — sharpness in the function setting: at every level
  `N ≥ 1` there are two bounded functions on finite types whose power sums agree for all
  `k < N` but whose value distributions differ (transported from the binomial parity pair
  `evenPart N` / `oddPart N` of the catalog via `ofMultiset`).

## Lab notes (experiment log)

Nodes `0,…,N`, inverse rows `vanInv N v ·` computed by expanding the Lagrange basis:

| `N` | `v` | row of `vanInv N v ·` (`k = 0 … N`) | `Λ_N(v) = ∑_k |vanInv N v k|` |
|-----|-----|--------------------------------------|-------------------------------|
| 1   | 0   | `1, -1`                              | `2`                           |
| 1   | 1   | `0, 1`                               | `1`                           |
| 2   | 0   | `1, -3/2, 1/2`                       | `3`                           |
| 2   | 1   | `0, 2, -1`                           | `3`                           |
| 2   | 2   | `0, -1/2, 1/2`                       | `1`                           |

Sanity checks performed with `#eval`/`decide` before formalising (see
`ComputationalEvidence.md`): for `N = 2` and `f` the function `Fin 3 → ℕ` with values
`0, 1, 1`, the power sums are `p_0 = 3, p_1 = 2, p_2 = 2`, and the inversion row for `v = 1`
gives `0·3 + 2·2 + (-1)·2 = 2 = count_f(1)`.  Exhaustive search at `N = 2, 3` over all
value distributions with multiplicities `≤ 3` found no pair with equal power sums for
`k ≤ N` and different counts, and found the binomial pairs `{0,2}` vs `{1,1}` (level 2) and
`{0,2,2,2}` vs `{1,1,1,3}` (level 3) as the minimal failures for the window `k < N`.
-/

open Finset Polynomial

namespace PowerSumInversion

variable {α β : Type*}

/-! ### Basic notions: power sums and value distributions of a function -/

/-- `powerSumFun f k = ∑_i (f i)^k`, the `k`-th power sum of a `ℕ`-valued function on a
finite type. -/
def powerSumFun [Fintype α] (f : α → ℕ) (k : ℕ) : ℕ := ∑ i, f i ^ k

/-- `countFun f v = #{i | f i = v}`, the value distribution (fibre count) of `f`. -/
def countFun [Fintype α] (f : α → ℕ) (v : ℕ) : ℕ := (univ.filter fun i => f i = v).card

/-- The multiset of values taken by `f`, with multiplicity. -/
def valueMultiset [Fintype α] (f : α → ℕ) : Multiset ℕ := Multiset.map f univ.val

@[simp] lemma powerSumFun_zero [Fintype α] (f : α → ℕ) :
    powerSumFun f 0 = Fintype.card α := by
  simp [powerSumFun]

lemma countFun_eq_card_fiber [Fintype α] (f : α → ℕ) (v : ℕ) :
    countFun f v = Fintype.card {i // f i = v} := by
  rw [countFun, Fintype.card_subtype]

lemma countFun_eq_sum [Fintype α] (f : α → ℕ) (v : ℕ) :
    (countFun f v : ℚ) = ∑ i, if f i = v then (1 : ℚ) else 0 := by
  rw [countFun, Finset.sum_boole]

lemma countFun_eq_count [Fintype α] (f : α → ℕ) (v : ℕ) :
    countFun f v = (valueMultiset f).count v := by
  rw [valueMultiset, Multiset.count_map, countFun, Finset.card, Finset.filter]
  congr 1
  refine Multiset.filter_congr fun x _ => ?_
  exact ⟨fun h => h.symm, fun h => h.symm⟩

lemma powerSumFun_eq_powerSum [Fintype α] (f : α → ℕ) (k : ℕ) :
    (powerSumFun f k : ℤ) = PowerSumSharpness.powerSum (valueMultiset f) k := by
  rw [← PowerSumSharpness.wsum_pow, PowerSumSharpness.wsum, valueMultiset, Multiset.map_map,
    powerSumFun]
  push_cast
  rfl

lemma countFun_eq_zero_of_lt [Fintype α] {N : ℕ} {f : α → ℕ} (hf : ∀ i, f i ≤ N) {v : ℕ}
    (hv : N < v) : countFun f v = 0 := by
  rw [countFun, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  intro i _
  have := hf i
  omega

/-! ### The inverse of the transposed Vandermonde matrix of the nodes `0, …, N` -/

/-- The Lagrange basis polynomial of the node `v` among the nodes `0, 1, …, N`, over `ℚ`. -/
noncomputable def lagBasis (N v : ℕ) : ℚ[X] :=
  Lagrange.basis (range (N + 1)) (fun j : ℕ => (j : ℚ)) v

/-- `vanInv N v k` is the `k`-th coefficient of the `v`-th Lagrange basis polynomial: the
entry of the inverse of the transposed Vandermonde matrix of the nodes `0, …, N`. -/
noncomputable def vanInv (N v k : ℕ) : ℚ := (lagBasis N v).coeff k

lemma cast_injOn (N : ℕ) :
    Set.InjOn (fun j : ℕ => (j : ℚ)) ↑(range (N + 1)) :=
  fun _ _ _ _ h => Nat.cast_injective h

lemma natDegree_lagBasis {N v : ℕ} (hv : v ≤ N) : (lagBasis N v).natDegree = N := by
  rw [lagBasis, Lagrange.natDegree_basis (cast_injOn N) (mem_range.mpr (by omega))]
  simp

lemma eval_lagBasis {N v j : ℕ} (hv : v ≤ N) (hj : j ≤ N) :
    (lagBasis N v).eval (j : ℚ) = if j = v then 1 else 0 := by
  by_cases h : j = v
  · subst h
    simpa [lagBasis] using
      Lagrange.eval_basis_self (cast_injOn N) (mem_range.mpr (by omega) : j ∈ range (N + 1))
  · rw [if_neg h, lagBasis]
    exact Lagrange.eval_basis_of_ne (fun hc => h hc.symm) (mem_range.mpr (by omega))

/-- **The defining identity of the inverse matrix.**  The rows of `vanInv N` pair with the
columns `k ↦ j^k` of the transposed Vandermonde matrix to give the Kronecker delta. -/
theorem vanInv_delta {N v j : ℕ} (hv : v ≤ N) (hj : j ≤ N) :
    ∑ k ∈ range (N + 1), vanInv N v k * (j : ℚ) ^ k = if j = v then 1 else 0 := by
  rw [← eval_lagBasis hv hj, eval_eq_sum_range' (n := N + 1)]
  · rfl
  · rw [natDegree_lagBasis hv]; omega

/-- **Explicit inversion of the transposed Vandermonde system.**  A rational vector `c`
supported on the nodes `0, …, N` is recovered from its "power moments"
`m_k = ∑_{j ≤ N} c j · j^k`, `k ≤ N`, by the fixed matrix `vanInv N`. -/
theorem vandermondeT_solve (N : ℕ) (c : ℕ → ℚ) {v : ℕ} (hv : v ≤ N) :
    c v = ∑ k ∈ range (N + 1), vanInv N v k * ∑ j ∈ range (N + 1), c j * (j : ℚ) ^ k := by
  have step : ∀ k, vanInv N v k * ∑ j ∈ range (N + 1), c j * (j : ℚ) ^ k
      = ∑ j ∈ range (N + 1), c j * (vanInv N v k * (j : ℚ) ^ k) := by
    intro k
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun j _ => by ring
  rw [Finset.sum_congr rfl fun k _ => step k, Finset.sum_comm]
  rw [Finset.sum_congr rfl fun j hj => by
    rw [← Finset.mul_sum, vanInv_delta hv (Nat.lt_succ_iff.mp (mem_range.mp hj))]]
  simp [Finset.sum_ite_eq', mem_range.mpr (Nat.lt_succ_of_le hv)]

/-- **Uniqueness of the solution**: two vectors supported on the nodes with the same power
moments up to order `N` are equal on the nodes. -/
theorem eq_of_moments_eq {N : ℕ} {c d : ℕ → ℚ}
    (h : ∀ k ≤ N, ∑ j ∈ range (N + 1), c j * (j : ℚ) ^ k
        = ∑ j ∈ range (N + 1), d j * (j : ℚ) ^ k) :
    ∀ v ≤ N, c v = d v := by
  intro v hv
  rw [vandermondeT_solve N c hv, vandermondeT_solve N d hv]
  exact Finset.sum_congr rfl fun k hk =>
    congrArg (vanInv N v k * ·) (h k (Nat.lt_succ_iff.mp (mem_range.mp hk)))

/-! ### Inversion for value distributions of functions on finite types -/

/-- The power sums of a bounded function are the power moments of its value distribution. -/
lemma powerSum_eq_moment [Fintype α] {N : ℕ} {f : α → ℕ} (hf : ∀ i, f i ≤ N) (k : ℕ) :
    (powerSumFun f k : ℚ) = ∑ j ∈ range (N + 1), (countFun f j : ℚ) * (j : ℚ) ^ k := by
  have hfib : ∀ j ∈ range (N + 1),
      (countFun f j : ℚ) * (j : ℚ) ^ k = ∑ i, if f i = j then ((f i : ℚ)) ^ k else 0 := by
    intro j _
    rw [countFun_eq_sum, Finset.sum_mul]
    refine Finset.sum_congr rfl fun i _ => ?_
    by_cases h : f i = j <;> simp [h]
  rw [Finset.sum_congr rfl hfib, Finset.sum_comm]
  have hin : ∀ i : α, ∑ j ∈ range (N + 1), (if f i = j then ((f i : ℚ)) ^ k else 0)
      = ((f i : ℚ)) ^ k := by
    intro i
    simp [Finset.sum_ite_eq, mem_range.mpr (Nat.lt_succ_of_le (hf i))]
  rw [Finset.sum_congr rfl fun i _ => hin i, powerSumFun]
  push_cast
  rfl

/-- **The inversion formula for value distributions.**  For a function bounded by `N`, each
fibre count is a fixed rational linear combination of the power sums `p_0, …, p_N`. -/
theorem count_eq_sum_vanInv_powerSum [Fintype α] {N : ℕ} {f : α → ℕ} (hf : ∀ i, f i ≤ N)
    {v : ℕ} (hv : v ≤ N) :
    (countFun f v : ℚ) = ∑ k ∈ range (N + 1), vanInv N v k * (powerSumFun f k : ℚ) := by
  rw [vandermondeT_solve N (fun j => (countFun f j : ℚ)) hv]
  exact Finset.sum_congr rfl fun k _ => by rw [powerSum_eq_moment hf k]

/-- **Main theorem (`count_eq_of_powerSums`).**  Two `ℕ`-valued functions on finite types,
both bounded by `N`, whose power sums agree for every `k ≤ N`, have the same value
distribution. -/
theorem count_eq_of_powerSums [Fintype α] [Fintype β] {N : ℕ} {f : α → ℕ} {g : β → ℕ}
    (hf : ∀ i, f i ≤ N) (hg : ∀ j, g j ≤ N)
    (h : ∀ k ≤ N, powerSumFun f k = powerSumFun g k) (v : ℕ) :
    countFun f v = countFun g v := by
  by_cases hv : v ≤ N
  · have : (countFun f v : ℚ) = (countFun g v : ℚ) := by
      rw [count_eq_sum_vanInv_powerSum hf hv, count_eq_sum_vanInv_powerSum hg hv]
      exact Finset.sum_congr rfl fun k hk => by
        rw [h k (Nat.lt_succ_iff.mp (mem_range.mp hk))]
    exact_mod_cast this
  · rw [countFun_eq_zero_of_lt hf (by omega), countFun_eq_zero_of_lt hg (by omega)]

/-- The index types then have the same cardinality (this is the `k = 0` component, but it is
a genuine conclusion: no hypothesis relates `α` and `β`). -/
theorem card_eq_of_powerSums [Fintype α] [Fintype β] {N : ℕ} {f : α → ℕ} {g : β → ℕ}
    (h : ∀ k ≤ N, powerSumFun f k = powerSumFun g k) :
    Fintype.card α = Fintype.card β := by
  have := h 0 (Nat.zero_le _)
  simpa using this

/-- The value multisets coincide. -/
theorem valueMultiset_eq_of_powerSums [Fintype α] [Fintype β] {N : ℕ} {f : α → ℕ} {g : β → ℕ}
    (hf : ∀ i, f i ≤ N) (hg : ∀ j, g j ≤ N)
    (h : ∀ k ≤ N, powerSumFun f k = powerSumFun g k) :
    valueMultiset f = valueMultiset g := by
  refine Multiset.ext.mpr fun v => ?_
  rw [← countFun_eq_count, ← countFun_eq_count]
  exact count_eq_of_powerSums hf hg h v

/-- **Rigidity up to relabelling.**  Equal power sums up to `N` produce an explicit bijection
of the index types carrying `f` to `g`. -/
theorem exists_equiv_of_powerSums [Fintype α] [Fintype β] {N : ℕ} {f : α → ℕ} {g : β → ℕ}
    (hf : ∀ i, f i ≤ N) (hg : ∀ j, g j ≤ N)
    (h : ∀ k ≤ N, powerSumFun f k = powerSumFun g k) :
    ∃ e : α ≃ β, ∀ i, g (e i) = f i := by
  have hfib : ∀ v : ℕ, Fintype.card {i // f i = v} = Fintype.card {j // g j = v} := by
    intro v
    rw [← countFun_eq_card_fiber, ← countFun_eq_card_fiber]
    exact count_eq_of_powerSums hf hg h v
  exact ⟨Equiv.ofFiberEquiv fun v => Fintype.equivOfCardEq (hfib v),
    Equiv.ofFiberEquiv_map _⟩

/-! ### Quantitative stability of the inversion -/

/-- The `ℓ¹`-norm of the `v`-th row of the inverse matrix: the Lebesgue constant of the
inversion at the node `v`. -/
noncomputable def lebesgueConst (N v : ℕ) : ℚ := ∑ k ∈ range (N + 1), |vanInv N v k|

lemma lebesgueConst_nonneg (N v : ℕ) : 0 ≤ lebesgueConst N v :=
  Finset.sum_nonneg fun _ _ => abs_nonneg _

/-- **Stability.**  If the power sums of two bounded functions agree up to an error `ε`, the
value distributions agree up to `Λ_N(v) · ε`. -/
theorem count_sub_le_of_powerSums_close [Fintype α] [Fintype β] {N : ℕ} {f : α → ℕ} {g : β → ℕ}
    {eps : ℚ} (hf : ∀ i, f i ≤ N) (hg : ∀ j, g j ≤ N)
    (h : ∀ k ≤ N, |(powerSumFun f k : ℚ) - (powerSumFun g k : ℚ)| ≤ eps)
    {v : ℕ} (hv : v ≤ N) :
    |(countFun f v : ℚ) - (countFun g v : ℚ)| ≤ lebesgueConst N v * eps := by
  have hdiff : (countFun f v : ℚ) - (countFun g v : ℚ)
      = ∑ k ∈ range (N + 1), vanInv N v k *
          ((powerSumFun f k : ℚ) - (powerSumFun g k : ℚ)) := by
    rw [count_eq_sum_vanInv_powerSum hf hv, count_eq_sum_vanInv_powerSum hg hv,
      ← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun k _ => by ring
  rw [hdiff, lebesgueConst, Finset.sum_mul]
  refine (Finset.abs_sum_le_sum_abs _ _).trans (Finset.sum_le_sum fun k hk => ?_)
  rw [abs_mul]
  exact mul_le_mul_of_nonneg_left (h k (Nat.lt_succ_iff.mp (mem_range.mp hk))) (abs_nonneg _)

/-- **Robust exact recovery.**  Counts are integers, so approximate agreement of the power
sums already forces *exact* agreement of the value distribution once the error is below the
reciprocal of the Lebesgue constant. -/
theorem count_eq_of_powerSums_close [Fintype α] [Fintype β] {N : ℕ} {f : α → ℕ} {g : β → ℕ}
    {eps : ℚ} (hf : ∀ i, f i ≤ N) (hg : ∀ j, g j ≤ N)
    (h : ∀ k ≤ N, |(powerSumFun f k : ℚ) - (powerSumFun g k : ℚ)| ≤ eps)
    {v : ℕ} (hv : v ≤ N) (hsmall : lebesgueConst N v * eps < 1) :
    countFun f v = countFun g v := by
  have hb := count_sub_le_of_powerSums_close hf hg h hv
  have hlt : |(countFun f v : ℚ) - (countFun g v : ℚ)| < 1 := lt_of_le_of_lt hb hsmall
  by_contra hne
  have : (1 : ℚ) ≤ |(countFun f v : ℚ) - (countFun g v : ℚ)| := by
    have hz : ((countFun f v : ℤ) : ℚ) - ((countFun g v : ℤ) : ℚ)
        = (((countFun f v : ℤ) - (countFun g v : ℤ) : ℤ) : ℚ) := by push_cast; ring
    have hne' : ((countFun f v : ℤ) - (countFun g v : ℤ)) ≠ 0 := by
      simpa [sub_eq_zero, Nat.cast_inj] using hne
    have : (1 : ℤ) ≤ |(countFun f v : ℤ) - (countFun g v : ℤ)| :=
      Int.one_le_abs (by omega)
    calc (1 : ℚ) = ((1 : ℤ) : ℚ) := by norm_num
      _ ≤ ((|(countFun f v : ℤ) - (countFun g v : ℤ)| : ℤ) : ℚ) := by exact_mod_cast this
      _ = |(countFun f v : ℚ) - (countFun g v : ℚ)| := by
          push_cast [Int.cast_abs]
          norm_num
  linarith

/-! ### Linear-algebra reading: the Vandermonde matrix of the nodes `0, …, N` -/

lemma vandermonde_det_ne_zero (N : ℕ) :
    (Matrix.vandermonde fun j : Fin (N + 1) => (j : ℚ)).det ≠ 0 := by
  rw [Matrix.det_vandermonde]
  refine Finset.prod_ne_zero_iff.mpr fun i _ => Finset.prod_ne_zero_iff.mpr fun j hj => ?_
  have hij : i < j := Finset.mem_Ioi.mp hj
  have hij' : (i : ℕ) < (j : ℕ) := hij
  have : ((i : ℕ) : ℚ) ≠ ((j : ℕ) : ℚ) := by
    exact_mod_cast (Nat.ne_of_lt hij')
  simpa [sub_eq_zero, eq_comm] using this

/-- The *transposed* Vandermonde matrix `(k, j) ↦ j^k` of the nodes `0, …, N` is invertible
over `ℚ`; the inversion formula above is an explicit description of its inverse action on
count vectors. -/
theorem isUnit_vandermondeT (N : ℕ) :
    IsUnit (Matrix.transpose (Matrix.vandermonde fun j : Fin (N + 1) => (j : ℚ))) := by
  rw [Matrix.isUnit_iff_isUnit_det, Matrix.det_transpose]
  exact isUnit_iff_ne_zero.mpr (vandermonde_det_ne_zero N)

/-! ### Spectral reading: traces of powers of a diagonal matrix -/

lemma trace_pow_diagonal [Fintype α] [DecidableEq α] (f : α → ℕ) (k : ℕ) :
    (Matrix.diagonal (fun i => (f i : ℚ)) ^ k).trace = (powerSumFun f k : ℚ) := by
  rw [Matrix.diagonal_pow, Matrix.trace_diagonal, powerSumFun]
  push_cast
  rfl

/-- **Spectral corollary.**  Two diagonal rational matrices whose diagonal entries are
natural numbers `≤ N` and whose power traces `tr(A^k)` agree for `k ≤ N` have the same
eigenvalue multiplicities. -/
theorem count_eq_of_traces [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
    {N : ℕ} {f : α → ℕ} {g : β → ℕ} (hf : ∀ i, f i ≤ N) (hg : ∀ j, g j ≤ N)
    (h : ∀ k ≤ N, (Matrix.diagonal (fun i => (f i : ℚ)) ^ k).trace
        = (Matrix.diagonal (fun j => (g j : ℚ)) ^ k).trace) (v : ℕ) :
    countFun f v = countFun g v := by
  refine count_eq_of_powerSums hf hg (fun k hk => ?_) v
  have := h k hk
  rw [trace_pow_diagonal, trace_pow_diagonal] at this
  exact_mod_cast this

/-! ### Transport from multisets, and sharpness of the window `k ≤ N` -/

/-- Realise a multiset of naturals as a function on a finite type. -/
noncomputable def ofMultiset (s : Multiset ℕ) : Fin s.toList.length → ℕ := fun i => s.toList.get i

@[simp] lemma valueMultiset_ofMultiset (s : Multiset ℕ) :
    valueMultiset (ofMultiset s) = s := by
  have h1 : valueMultiset (ofMultiset s)
      = ↑(List.map s.toList.get (List.finRange s.toList.length)) := rfl
  rw [h1, List.map_get_finRange, Multiset.coe_toList]

lemma ofMultiset_le {N : ℕ} {s : Multiset ℕ} (hs : ∀ x ∈ s, x ≤ N) (i) :
    ofMultiset s i ≤ N := by
  refine hs _ ?_
  rw [← Multiset.mem_toList]
  exact List.get_mem _ _

lemma powerSumFun_ofMultiset (s : Multiset ℕ) (k : ℕ) :
    (powerSumFun (ofMultiset s) k : ℤ) = PowerSumSharpness.powerSum s k := by
  rw [powerSumFun_eq_powerSum, valueMultiset_ofMultiset]

lemma countFun_ofMultiset (s : Multiset ℕ) (v : ℕ) :
    countFun (ofMultiset s) v = s.count v := by
  rw [countFun_eq_count, valueMultiset_ofMultiset]

/-- **Sharpness of the window.**  At every level `N ≥ 1` the shorter window `k < N` fails:
there are bounded functions on finite types with equal power sums for all `k < N` but
different value distributions.  (Transported from the binomial parity pair of the catalog.)
-/
theorem powerSums_below_top_insufficient (N : ℕ) :
    ∃ (m n : ℕ) (f : Fin m → ℕ) (g : Fin n → ℕ),
      (∀ i, f i ≤ N) ∧ (∀ j, g j ≤ N) ∧
      (∀ k < N, powerSumFun f k = powerSumFun g k) ∧
      ∃ v, countFun f v ≠ countFun g v := by
  classical
  refine ⟨_, _, ofMultiset (PowerSumSharpness.evenPart N),
    ofMultiset (PowerSumSharpness.oddPart N),
    ofMultiset_le (PowerSumSharpness.evenPart_bounded N),
    ofMultiset_le (PowerSumSharpness.oddPart_bounded N), fun k hk => ?_, ?_⟩
  · have := PowerSumSharpness.powerSum_evenPart_eq_oddPart N hk
    have h1 := powerSumFun_ofMultiset (PowerSumSharpness.evenPart N) k
    have h2 := powerSumFun_ofMultiset (PowerSumSharpness.oddPart N) k
    omega
  · by_contra hcon
    push_neg at hcon
    refine PowerSumSharpness.evenPart_ne_oddPart N (Multiset.ext.mpr fun v => ?_)
    have := hcon v
    rwa [countFun_ofMultiset, countFun_ofMultiset] at this

/-- The two readings agree: the function-level rigidity theorem re-proves the multiset-level
rigidity theorem of `Shared/PowerSumSharpness.lean` through the Lagrange inversion, with no
appeal to the original argument. -/
theorem powerSums_determine_multiset {N : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N)
    (h : ∀ k ≤ N, PowerSumSharpness.powerSum s k = PowerSumSharpness.powerSum t k) :
    s = t := by
  have key := valueMultiset_eq_of_powerSums (N := N) (f := ofMultiset s) (g := ofMultiset t)
    (ofMultiset_le hs) (ofMultiset_le ht) (fun k hk => by
      have h1 := powerSumFun_ofMultiset s k
      have h2 := powerSumFun_ofMultiset t k
      have := h k hk
      omega)
  rwa [valueMultiset_ofMultiset, valueMultiset_ofMultiset] at key



/-! ### The inverse is two-sided, and it is the unique inversion operator

Everything so far used only that `vanInv N` is a *left* inverse of the transposed Vandermonde
matrix.  Squareness upgrades this to a two-sided inverse, which pins the inversion operator
down uniquely and shows that the moment map is onto. -/

/-- The transposed Vandermonde matrix `(k, j) ↦ j^k` of the nodes `0, …, N`. -/
noncomputable def vanMat (N : ℕ) : Matrix (Fin (N + 1)) (Fin (N + 1)) ℚ :=
  Matrix.of fun k j => (j : ℚ) ^ (k : ℕ)

/-- The candidate inverse matrix, with rows the Lagrange coefficient vectors. -/
noncomputable def vanInvMat (N : ℕ) : Matrix (Fin (N + 1)) (Fin (N + 1)) ℚ :=
  Matrix.of fun v k => vanInv N v k

lemma vanMat_eq_transpose (N : ℕ) :
    vanMat N = Matrix.transpose (Matrix.vandermonde fun j : Fin (N + 1) => (j : ℚ)) := by
  ext k j
  rfl

lemma vanInvMat_mul_vanMat (N : ℕ) : vanInvMat N * vanMat N = 1 := by
  ext v j
  rw [Matrix.mul_apply]
  have hsum : ∑ k : Fin (N + 1), vanInvMat N v k * vanMat N k j
      = ∑ k ∈ range (N + 1), vanInv N v k * (j : ℚ) ^ k := by
    rw [← Fin.sum_univ_eq_sum_range (fun k => vanInv N v k * (j : ℚ) ^ k) (N + 1)]
    rfl
  rw [hsum, vanInv_delta (Nat.lt_succ_iff.mp v.isLt) (Nat.lt_succ_iff.mp j.isLt),
    Matrix.one_apply]
  by_cases h : (j : ℕ) = (v : ℕ)
  · rw [if_pos h, if_pos (Fin.ext h.symm)]
  · rw [if_neg h, if_neg fun hc => h (congrArg Fin.val hc.symm)]

/-- **Two-sidedness.**  The Lagrange coefficient matrix is a genuine inverse of the
transposed Vandermonde matrix, not merely a left inverse. -/
theorem vanMat_mul_vanInvMat (N : ℕ) : vanMat N * vanInvMat N = 1 :=
  mul_eq_one_comm.mp (vanInvMat_mul_vanMat N)

/-- **Dual delta identity.**  The columns of `vanInv N` have prescribed power moments: the
moment vector of the `k'`-th column is the `k'`-th standard basis vector.  Equivalently, the
moment map is *onto* `ℚ^{N+1}`. -/
theorem vanInv_delta_dual {N k k' : ℕ} (hk : k ≤ N) (hk' : k' ≤ N) :
    ∑ j ∈ range (N + 1), vanInv N j k' * (j : ℚ) ^ k = if k = k' then 1 else 0 := by
  have h := congrArg (fun M : Matrix (Fin (N + 1)) (Fin (N + 1)) ℚ =>
    M ⟨k, Nat.lt_succ_of_le hk⟩ ⟨k', Nat.lt_succ_of_le hk'⟩) (vanMat_mul_vanInvMat N)
  simp only [Matrix.mul_apply, Matrix.one_apply] at h
  have hsum : ∑ j ∈ range (N + 1), vanInv N j k' * (j : ℚ) ^ k
      = ∑ j : Fin (N + 1), vanMat N ⟨k, Nat.lt_succ_of_le hk⟩ j
          * vanInvMat N j ⟨k', Nat.lt_succ_of_le hk'⟩ := by
    rw [← Fin.sum_univ_eq_sum_range (fun j => vanInv N j k' * (j : ℚ) ^ k) (N + 1)]
    exact Finset.sum_congr rfl fun j _ => by
      simp only [vanMat, vanInvMat, Matrix.of_apply]
      ring
  rw [hsum, h]
  by_cases hkk : k = k'
  · subst hkk; simp
  · rw [if_neg hkk, if_neg fun hc => hkk (congrArg Fin.val hc)]

/-- **Uniqueness of the inversion operator.**  Any row vector `a` that recovers the `v`-th
coordinate from the power moments of *every* rational vector supported on the nodes is the
`v`-th row of `vanInv N`.  So the inversion formula is canonical. -/
theorem vanInv_unique {N v : ℕ} (a : ℕ → ℚ)
    (ha : ∀ c : ℕ → ℚ,
      c v = ∑ k ∈ range (N + 1), a k * ∑ j ∈ range (N + 1), c j * (j : ℚ) ^ k) :
    ∀ k ≤ N, a k = vanInv N v k := by
  intro k0 hk0
  have h := ha (fun j => vanInv N j k0)
  have hin : ∀ k ∈ range (N + 1),
      a k * ∑ j ∈ range (N + 1), vanInv N j k0 * (j : ℚ) ^ k
        = a k * (if k = k0 then 1 else 0) := fun k hk => by
    rw [vanInv_delta_dual (Nat.lt_succ_iff.mp (mem_range.mp hk)) hk0]
  rw [Finset.sum_congr rfl hin] at h
  have h2 : vanInv N v k0 = a k0 := by
    simpa [Finset.sum_ite_eq', mem_range.mpr (Nat.lt_succ_of_le hk0)] using h
  exact h2.symm

/-- The Lebesgue constant of the inversion is strictly positive: the inverse row is never the
zero vector, so the count really does depend on the power sums. -/
theorem lebesgueConst_pos {N v : ℕ} (hv : v ≤ N) : 0 < lebesgueConst N v := by
  rcases (lebesgueConst_nonneg N v).lt_or_eq with h | h
  · exact h
  · exfalso
    have hzero : ∀ k ∈ range (N + 1), vanInv N v k = 0 := by
      intro k hk
      have := (Finset.sum_eq_zero_iff_of_nonneg
        (fun k _ => abs_nonneg (vanInv N v k))).mp h.symm k hk
      exact abs_eq_zero.mp this
    have hdelta := vanInv_delta (N := N) (v := v) (j := v) hv hv
    rw [Finset.sum_congr rfl fun k hk => by rw [hzero k hk, zero_mul]] at hdelta
    simp at hdelta

/-! ### The moment map as a linear equivalence -/

noncomputable instance vanMatInvertible (N : ℕ) : Invertible (vanMat N) :=
  ⟨vanInvMat N, vanInvMat_mul_vanMat N, vanMat_mul_vanInvMat N⟩

/-- **The moment map is a linear equivalence.**  Sending a count vector on the nodes
`0, …, N` to its vector of power moments of order `0, …, N` is a `ℚ`-linear automorphism of
`ℚ^{N+1}`, with inverse given by the Lagrange coefficient matrix. -/
noncomputable def momentEquiv (N : ℕ) : (Fin (N + 1) → ℚ) ≃ₗ[ℚ] (Fin (N + 1) → ℚ) :=
  Matrix.toLinearEquiv' (vanMat N) (vanMatInvertible N)

theorem momentEquiv_apply (N : ℕ) (c : Fin (N + 1) → ℚ) (k : Fin (N + 1)) :
    momentEquiv N c k = ∑ j : Fin (N + 1), c j * (j : ℚ) ^ (k : ℕ) := by
  show (vanMat N).mulVec c k = _
  rw [Matrix.mulVec, dotProduct]
  exact Finset.sum_congr rfl fun j _ => by simp [vanMat, mul_comm]

theorem momentEquiv_symm_apply (N : ℕ) (m : Fin (N + 1) → ℚ) (v : Fin (N + 1)) :
    (momentEquiv N).symm m v = ∑ k : Fin (N + 1), vanInv N v k * m k := by
  have h : (momentEquiv N).symm m = (vanInvMat N).mulVec m := rfl
  rw [h, Matrix.mulVec, dotProduct]
  exact Finset.sum_congr rfl fun k _ => by simp [vanInvMat]

/-! ### Cycle 2: arbitrary node sets over a field of characteristic zero

The window `k ≤ N` is dictated by the *number of admissible values*, not by their size.  If a
function only takes values in a set `T` of `m` naturals, the shorter window `k < m` already
determines the value distribution.  We prove this over an arbitrary characteristic-zero
field, so it also covers rational-, real- and complex-valued functions. -/

section GeneralNodes

variable {F : Type*} [Field F] [DecidableEq F] [CharZero F]

/-- Lagrange inverse coefficients for an arbitrary finite node set `S ⊆ F`. -/
noncomputable def nodeInv (S : Finset F) (v : F) (k : ℕ) : F :=
  (Lagrange.basis S id v).coeff k

/-- Power sums of an `F`-valued function on a finite type. -/
def powerSumVal [Fintype α] (f : α → F) (k : ℕ) : F := ∑ i, f i ^ k

/-- Value distribution of an `F`-valued function on a finite type. -/
def countVal [Fintype α] (f : α → F) (v : F) : ℕ := (univ.filter fun i => f i = v).card

omit [CharZero F] in
theorem nodeInv_delta {S : Finset F} {v j : F} (hv : v ∈ S) (hj : j ∈ S) :
    ∑ k ∈ range S.card, nodeInv S v k * j ^ k = if j = v then 1 else 0 := by
  have hinj : Set.InjOn (id : F → F) ↑S := fun a _ b _ hab => hab
  have hcard : (Lagrange.basis S id v).natDegree < S.card := by
    rw [Lagrange.natDegree_basis hinj hv]
    have : 0 < S.card := Finset.card_pos.mpr ⟨v, hv⟩
    omega
  have heval : (Lagrange.basis S id v).eval j = if j = v then 1 else 0 := by
    by_cases h : j = v
    · subst h
      simpa using Lagrange.eval_basis_self hinj hj
    · rw [if_neg h]
      simpa using
        Lagrange.eval_basis_of_ne (v := (id : F → F)) (fun hc => h hc.symm) hj
  rw [← heval, eval_eq_sum_range' hcard]
  rfl

omit [CharZero F] in
/-- Inversion over an arbitrary node set: the window has length `#S`, the number of nodes. -/
theorem nodeInv_solve (S : Finset F) (c : F → F) {v : F} (hv : v ∈ S) :
    c v = ∑ k ∈ range S.card, nodeInv S v k * ∑ j ∈ S, c j * j ^ k := by
  have step : ∀ k, nodeInv S v k * ∑ j ∈ S, c j * j ^ k
      = ∑ j ∈ S, c j * (nodeInv S v k * j ^ k) := by
    intro k
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun j _ => by ring
  rw [Finset.sum_congr rfl fun k _ => step k, Finset.sum_comm]
  rw [Finset.sum_congr rfl fun j hj => by rw [← Finset.mul_sum, nodeInv_delta hv hj]]
  simp [mul_ite, Finset.sum_ite_eq', hv]

omit [CharZero F] in
lemma powerSumVal_eq_moment [Fintype α] {S : Finset F} {f : α → F} (hf : ∀ i, f i ∈ S)
    (k : ℕ) : powerSumVal f k = ∑ j ∈ S, (countVal f j : F) * j ^ k := by
  have hcount : ∀ j : F, (countVal f j : F) = ∑ i, if f i = j then (1 : F) else 0 := by
    intro j
    rw [countVal, Finset.sum_boole]
  have hfib : ∀ j ∈ S, (countVal f j : F) * j ^ k = ∑ i, if f i = j then (f i) ^ k else 0 := by
    intro j _
    rw [hcount, Finset.sum_mul]
    refine Finset.sum_congr rfl fun i _ => ?_
    by_cases h : f i = j <;> simp [h]
  rw [Finset.sum_congr rfl hfib, Finset.sum_comm]
  refine Finset.sum_congr rfl fun i _ => ?_
  simp [Finset.sum_ite_eq, hf i]

/-- **Node-set inversion theorem.**  Two `F`-valued functions on finite types taking values
in a common finite node set `S`, whose power sums agree for all `k < #S`, have the same value
distribution.  For `F = ℚ` and `S = {0, …, N}` this is the mission statement; for a sparse
`S` the window is much shorter than the largest value. -/
theorem countVal_eq_of_powerSums [Fintype α] [Fintype β] {S : Finset F} {f : α → F} {g : β → F}
    (hf : ∀ i, f i ∈ S) (hg : ∀ j, g j ∈ S)
    (h : ∀ k < S.card, powerSumVal f k = powerSumVal g k) (v : F) :
    countVal f v = countVal g v := by
  by_cases hv : v ∈ S
  · have key : ((countVal f v : ℕ) : F) = ((countVal g v : ℕ) : F) := by
      rw [nodeInv_solve S (fun j => (countVal f j : F)) hv,
        nodeInv_solve S (fun j => (countVal g j : F)) hv]
      refine Finset.sum_congr rfl fun k hk => ?_
      rw [← powerSumVal_eq_moment hf, ← powerSumVal_eq_moment hg, h k (mem_range.mp hk)]
    exact_mod_cast key
  · have hzf : countVal f v = 0 := by
      rw [countVal, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
      intro i _ hcon
      exact hv (hcon ▸ hf i)
    have hzg : countVal g v = 0 := by
      rw [countVal, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
      intro j _ hcon
      exact hv (hcon ▸ hg j)
    rw [hzf, hzg]

end GeneralNodes

/-! ### Sparse values: the window is governed by the number of values, not their size -/

lemma countFun_eq_countVal [Fintype α] (f : α → ℕ) (v : ℕ) :
    countFun f v = countVal (fun i => (f i : ℚ)) (v : ℚ) := by
  rw [countFun, countVal]
  congr 1
  refine Finset.filter_congr fun i _ => ?_
  simp [Nat.cast_inj]

lemma powerSumVal_cast [Fintype α] (f : α → ℕ) (k : ℕ) :
    powerSumVal (fun i => (f i : ℚ)) k = (powerSumFun f k : ℚ) := by
  rw [powerSumVal, powerSumFun]
  push_cast
  rfl

/-- **Sparse-window rigidity.**  If two functions take values in a common set `T` of `m`
naturals, then the power sums `p_0, …, p_{m-1}` already determine their value distributions —
however large the elements of `T` are.  Taking `T = {0, …, N}` recovers
`count_eq_of_powerSums`; taking `T = {0, 10^6}` shows that two power sums suffice there. -/
theorem count_eq_of_powerSums_sparse [Fintype α] [Fintype β] {T : Finset ℕ} {f : α → ℕ}
    {g : β → ℕ} (hf : ∀ i, f i ∈ T) (hg : ∀ j, g j ∈ T)
    (h : ∀ k < T.card, powerSumFun f k = powerSumFun g k) (v : ℕ) :
    countFun f v = countFun g v := by
  classical
  set S : Finset ℚ := T.image (fun n : ℕ => (n : ℚ)) with hS
  have hcard : S.card = T.card :=
    Finset.card_image_of_injective _ (fun a b hab => Nat.cast_injective hab)
  have hfS : ∀ i, ((f i : ℚ)) ∈ S := fun i => Finset.mem_image_of_mem _ (hf i)
  have hgS : ∀ j, ((g j : ℚ)) ∈ S := fun j => Finset.mem_image_of_mem _ (hg j)
  have hpow : ∀ k < S.card, powerSumVal (fun i => (f i : ℚ)) k
      = powerSumVal (fun j => (g j : ℚ)) k := by
    intro k hk
    rw [powerSumVal_cast, powerSumVal_cast, h k (hcard ▸ hk)]
  rw [countFun_eq_countVal, countFun_eq_countVal]
  exact countVal_eq_of_powerSums hfS hgS hpow _

/-! ### Verified lab data: the small inverse rows quoted in the header table -/

lemma lagBasis_one_zero : lagBasis 1 0 = 1 - X := by
  have h : (range 2).erase 0 = {1} := by decide
  simp [lagBasis, Lagrange.basis, h, Lagrange.basisDivisor]

lemma lagBasis_two_one : lagBasis 2 1 = 2 * X - X ^ 2 := by
  have h : (range 3).erase 1 = {0, 2} := by decide
  have hC : (C ((1 - 2 : ℚ)⁻¹)) = -1 := by norm_num
  simp only [lagBasis, Lagrange.basis, h, Lagrange.basisDivisor]
  norm_num [hC]
  ring

example : vanInv 1 0 0 = 1 ∧ vanInv 1 0 1 = -1 := by
  constructor <;> simp [vanInv, lagBasis_one_zero, Polynomial.coeff_one]

example : lebesgueConst 1 0 = 2 := by
  simp [lebesgueConst, vanInv, lagBasis_one_zero, Finset.sum_range_succ, Polynomial.coeff_one]
  norm_num

example : vanInv 2 1 0 = 0 ∧ vanInv 2 1 1 = 2 ∧ vanInv 2 1 2 = -1 := by
  refine ⟨?_, ?_, ?_⟩ <;>
    simp [vanInv, lagBasis_two_one, Polynomial.coeff_X, Polynomial.coeff_X_pow]

/-- A concrete instance of the inversion formula: for `f = (0, 1, 1) : Fin 3 → ℕ` with nodes
`{0,1,2}` the row `(0, 2, -1)` returns the multiplicity of the value `1`. -/
example : (countFun ![0, 1, 1] 1 : ℚ)
    = ∑ k ∈ range 3, vanInv 2 1 k * (powerSumFun ![0, 1, 1] k : ℚ) :=
  count_eq_sum_vanInv_powerSum (N := 2) (by decide) (by norm_num)

example : countFun ![0, 1, 1] 1 = 2 := by decide

example : powerSumFun ![0, 1, 1] 2 = 2 := by decide

end PowerSumInversion