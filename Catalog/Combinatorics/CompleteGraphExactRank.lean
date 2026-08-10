/-
# The exact Baker–Norine rank of a uniform divisor on a complete graph

Let `K_n` be the complete graph on `n` vertices and let `m • 1` denote the *uniform*
(constant) divisor with `m` chips at every vertex.  This file proves

* `rankGE_const_top`  — `r(m • 1) ≥ m(m+3)/2` whenever `n ≥ m + 1`;
* `not_rankGE_const_top` — `r(m • 1) < m(m+3)/2 + 1`, witnessed by the explicit
  *staircase* divisor `stairE`;
* `rank_const_top` — hence **`r(m • 1) = m(m+3)/2`**, a value independent of `n`.

The mechanism is the one-parameter winnability criterion `winnable_top_iff` of
`Combinatorics.CompleteGraphWinnable`: on `K_n` a divisor `D` is winnable iff some
integer shift `S` satisfies `S ≤ ∑_v ⌊(D v + S)/n⌋`.  For the lower bound we run the
criterion at the `m + 1` shifts `S = i - m`, `0 ≤ i ≤ m`, and *average*: the
per-vertex floor estimate `sum_window_ediv_ge` shows that if all `m + 1` shifts fail
then `deg E ≥ (m+1)(m+2)/2`, so every test divisor of smaller degree is beaten.  For
the upper bound the staircase `stairE i = max 0 (m + 1 - i)` makes all shifts fail
simultaneously.
-/
import Combinatorics.CompleteGraphWinnable

namespace TropicalRR

open Finset

/-! ### Elementary facts about integer (floor) division -/

section Aux

lemma ediv_le_neg_one_of_neg {x n : ℤ} (hn : 0 < n) (hx : x < 0) : x / n ≤ -1 := by
  by_contra h
  push_neg at h
  have h0 : 0 ≤ x / n := by omega
  have hd : n * (x / n) + x % n = x := Int.mul_ediv_add_emod x n
  have h1 : 0 ≤ n * (x / n) := mul_nonneg (le_of_lt hn) h0
  have h2 : 0 ≤ x % n := Int.emod_nonneg _ (by omega)
  omega

lemma ediv_nonpos_of_lt {x n : ℤ} (hn : 0 < n) (hx : x < n) : x / n ≤ 0 := by
  by_contra h
  push_neg at h
  have h1 : 1 ≤ x / n := h
  have hd : n * (x / n) + x % n = x := Int.mul_ediv_add_emod x n
  have h2 : 0 ≤ x % n := Int.emod_nonneg _ (by omega)
  nlinarith

/-- Gauss' summation formula, in `ℤ`. -/
lemma two_mul_sum_range_cast (K : ℕ) :
    2 * ∑ i ∈ Finset.range K, (i : ℤ) = (K : ℤ) * ((K : ℤ) - 1) := by
  induction K with
  | zero => simp
  | succ k ih =>
      rw [Finset.sum_range_succ, mul_add, ih]
      push_cast
      ring

end Aux

/-! ### The uniform divisor and the staircase test divisor -/

section ConstK

variable {n m : ℕ} [NeZero n]

/-- The uniform divisor with `m` chips at every vertex of `K_n`. -/
def constDiv (n : ℕ) (m : ℤ) : Divisor (Fin n) := fun _ => m

/-- The **staircase** test divisor `(m+1, m, …, 1, 0, …, 0)` on `K_n`. -/
def stairE (n m : ℕ) : Divisor (Fin n) := fun i => max 0 ((m : ℤ) + 1 - (i : ℕ))

omit [NeZero n] in
lemma effective_stairE : Effective (stairE n m) := fun _ => le_max_left _ _

omit [NeZero n] in
lemma card_fin_int : ((Fintype.card (Fin n) : ℕ) : ℤ) = (n : ℤ) := by simp

omit [NeZero n] in
/-- The degree of the staircase is the triangular number `(m+1)(m+2)/2`. -/
lemma two_mul_degD_stairE (hmn : m + 1 ≤ n) :
    2 * degD (stairE n m) = ((m : ℤ) + 1) * ((m : ℤ) + 2) := by
  have hsub : ∀ i ∈ Finset.range n, i ∉ Finset.range (m + 1) →
      max 0 ((m : ℤ) + 1 - (i : ℕ)) = 0 := by
    intro i _ hi
    rw [Finset.mem_range] at hi
    have h : (m : ℤ) + 1 - (i : ℕ) ≤ 0 := by
      have : (m : ℤ) + 1 ≤ (i : ℤ) := by exact_mod_cast Nat.le_of_not_lt hi
      omega
    exact max_eq_left h
  have h0 : degD (stairE n m) = ∑ i ∈ Finset.range n, max 0 ((m : ℤ) + 1 - (i : ℕ)) := by
    rw [degD]
    exact Fin.sum_univ_eq_sum_range (fun i => max 0 ((m : ℤ) + 1 - (i : ℕ))) n
  have hstep : degD (stairE n m) = ∑ i ∈ Finset.range (m + 1), ((m : ℤ) + 1 - (i : ℕ)) := by
    rw [h0, ← Finset.sum_subset (Finset.range_subset_range.2 hmn) hsub]
    refine Finset.sum_congr rfl fun i hi => ?_
    rw [Finset.mem_range] at hi
    have h : (0 : ℤ) ≤ (m : ℤ) + 1 - (i : ℕ) := by
      have : (i : ℤ) ≤ (m : ℤ) := by exact_mod_cast Nat.lt_succ_iff.1 hi
      omega
    exact max_eq_right h
  have hsplit : ∑ i ∈ Finset.range (m + 1), ((m : ℤ) + 1 - (i : ℕ))
      = ((m : ℤ) + 1) * ((m : ℤ) + 1) - ∑ i ∈ Finset.range (m + 1), (i : ℤ) := by
    rw [Finset.sum_sub_distrib, Finset.sum_const, Finset.card_range, nsmul_eq_mul]
    push_cast
    ring
  rw [hstep, hsplit]
  have hg := two_mul_sum_range_cast (m + 1)
  push_cast at hg ⊢
  linarith

/-! ### The lower bound -/

omit [NeZero n] in
/-- **Key averaging step.**  If every one of the `m+1` shifts `S = i - m` fails the
winnability criterion for `m • 1 - E`, then `E` has degree at least `(m+1)(m+2)/2`. -/
lemma two_mul_degD_ge_of_all_shifts_fail (hmn : m + 1 ≤ n) {E : Divisor (Fin n)}
    (hE : Effective E)
    (h : ∀ i ∈ Finset.range (m + 1),
      ∑ v, ((i : ℤ) - E v) / (n : ℤ) ≤ (i : ℤ) - (m : ℤ) - 1) :
    ((m : ℤ) + 1) * ((m : ℤ) + 2) ≤ 2 * degD E := by
  have hn : (0 : ℤ) < (n : ℤ) := by
    have : 0 < n := Nat.lt_of_lt_of_le (Nat.succ_pos m) hmn
    exact_mod_cast this
  have hupper : ∑ i ∈ Finset.range (m + 1), ∑ v, ((i : ℤ) - E v) / (n : ℤ)
      ≤ ∑ i ∈ Finset.range (m + 1), ((i : ℤ) - (m : ℤ) - 1) := Finset.sum_le_sum h
  have hlower : ∑ v : Fin n, (-(E v)) ≤
      ∑ v : Fin n, ∑ i ∈ Finset.range (m + 1), ((i : ℤ) - E v) / (n : ℤ) := by
    refine Finset.sum_le_sum fun v _ => ?_
    exact sum_window_ediv_ge hn (by exact_mod_cast hmn) (hE v)
  rw [Finset.sum_comm] at hlower
  have hsplit : ∑ i ∈ Finset.range (m + 1), ((i : ℤ) - (m : ℤ) - 1)
      = (∑ i ∈ Finset.range (m + 1), (i : ℤ)) - ((m : ℤ) + 1) * ((m : ℤ) + 1) := by
    rw [Finset.sum_sub_distrib, Finset.sum_sub_distrib, Finset.sum_const, Finset.sum_const,
      Finset.card_range, nsmul_eq_mul, nsmul_eq_mul]
    push_cast
    ring
  have hg := two_mul_sum_range_cast (m + 1)
  have hdeg : ∑ v : Fin n, (-(E v)) = -degD E := by
    rw [degD, ← Finset.sum_neg_distrib]
  rw [hsplit] at hupper
  rw [hdeg] at hlower
  push_cast at hg
  linarith

/-- **Lower bound.**  On `K_n` with `n ≥ m + 1`, subtracting any effective divisor of
degree less than `(m+1)(m+2)/2` from the uniform divisor `m • 1` leaves a winnable
divisor. -/
theorem winnable_const_sub (hmn : m + 1 ≤ n) {E : Divisor (Fin n)} (hE : Effective E)
    (hdeg : 2 * degD E < ((m : ℤ) + 1) * ((m : ℤ) + 2)) :
    Winnable (⊤ : SimpleGraph (Fin n)) (constDiv n (m : ℤ) - E) := by
  by_contra hw
  have hkey := two_mul_degD_ge_of_all_shifts_fail (n := n) hmn hE ?_
  · linarith
  · intro i _
    by_contra hcon
    push_neg at hcon
    refine hw (winnable_top_of_shift (constDiv n (m : ℤ) - E) ((i : ℤ) - (m : ℤ)) ?_)
    have hterm : ∀ v : Fin n,
        ((constDiv n (m : ℤ) - E) v + ((i : ℤ) - (m : ℤ)))
          / ((Fintype.card (Fin n) : ℕ) : ℤ) = ((i : ℤ) - E v) / (n : ℤ) := by
      intro v
      rw [card_fin_int]
      congr 1
      simp only [constDiv, Pi.sub_apply]
      ring
    rw [Finset.sum_congr rfl (fun v _ => hterm v)]
    linarith

/-! ### The upper bound: the staircase obstruction -/

/-- The **staircase floor** of a divisor `D` on `K_n`: the pointwise minimum of `D`
with the linear staircase `i ↦ i - 1`. -/
def stairFloor (D : Divisor (Fin n)) : Divisor (Fin n) := fun i => min (D i) (((i : ℕ) : ℤ) - 1)

/-- **The general staircase obstruction.**  On `K_n`, if every value of `D` is smaller
than `n`, then the staircase floor of `D` is *not* winnable.  This is
the mechanism behind every rank upper bound in this development. -/
theorem not_winnable_stairFloor {D : Divisor (Fin n)}
    (hlt : ∀ i, D i < (n : ℤ)) :
    ¬ Winnable (⊤ : SimpleGraph (Fin n)) (stairFloor D) := by
  have hn0 : 0 < n := Nat.pos_of_ne_zero (NeZero.ne n)
  have hn : (0 : ℤ) < (n : ℤ) := by exact_mod_cast hn0
  refine not_winnable_top_of_window _ fun u hu0 hun => ?_
  rw [card_fin_int] at hun ⊢
  set U : ℕ := u.toNat with hU
  have hUu : (U : ℤ) = u := Int.toNat_of_nonneg hu0
  have hUn : U + 1 ≤ n := by omega
  have hbound : ∀ i : Fin n,
      (stairFloor D i - u) / (n : ℤ) ≤ (if (i : ℕ) ≤ U then (-1 : ℤ) else 0) := by
    intro i
    simp only [stairFloor]
    by_cases hi : (i : ℕ) ≤ U
    · simp only [hi, if_true]
      refine ediv_le_neg_one_of_neg hn ?_
      have h1 : ((i : ℕ) : ℤ) ≤ (U : ℤ) := by exact_mod_cast hi
      have h2 : min (D i) (((i : ℕ) : ℤ) - 1) ≤ ((i : ℕ) : ℤ) - 1 := min_le_right _ _
      omega
    · simp only [hi, if_false]
      refine ediv_nonpos_of_lt hn ?_
      have h2 : min (D i) (((i : ℕ) : ℤ) - 1) ≤ D i := min_le_left _ _
      have h3 := hlt i
      omega
  have hsum := Finset.sum_le_sum (fun i (_ : i ∈ (univ : Finset (Fin n))) => hbound i)
  have heval : ∑ i : Fin n, (if (i : ℕ) ≤ U then (-1 : ℤ) else 0) = -((U : ℤ) + 1) := by
    have h1 : ∑ i : Fin n, (if (i : ℕ) ≤ U then (-1 : ℤ) else 0)
        = ∑ i ∈ Finset.range n, (if i ≤ U then (-1 : ℤ) else 0) :=
      Fin.sum_univ_eq_sum_range (fun i => if i ≤ U then (-1 : ℤ) else 0) n
    have hsubU : Finset.range (U + 1) ⊆ Finset.range n := Finset.range_subset_range.2 hUn
    have h2 : ∑ i ∈ Finset.range n, (if i ≤ U then (-1 : ℤ) else 0)
        = ∑ i ∈ Finset.range (U + 1), (if i ≤ U then (-1 : ℤ) else 0) := by
      refine (Finset.sum_subset hsubU ?_).symm
      intro i _ hi
      rw [Finset.mem_range] at hi
      rw [if_neg (by omega)]
    have h3 : ∑ i ∈ Finset.range (U + 1), (if i ≤ U then (-1 : ℤ) else 0)
        = -((U : ℤ) + 1) := by
      have hall : ∀ i ∈ Finset.range (U + 1), (if i ≤ U then (-1 : ℤ) else 0) = -1 := by
        intro i hi
        rw [Finset.mem_range] at hi
        exact if_pos (by omega)
      have hc := Finset.sum_congr rfl hall
      rw [hc, Finset.sum_const, Finset.card_range, nsmul_eq_mul]
      push_cast
      ring
    rw [h1, h2, h3]
  rw [heval] at hsum
  omega

omit [NeZero n] in
/-- The uniform divisor minus the staircase is exactly the staircase floor of `m • 1`. -/
lemma const_sub_stairE_eq_stairFloor :
    constDiv n (m : ℤ) - stairE n m = stairFloor (constDiv n (m : ℤ)) := by
  funext i
  simp only [constDiv, stairE, stairFloor, Pi.sub_apply]
  rcases le_or_gt ((m : ℤ) + 1 - ((i : ℕ) : ℤ)) 0 with h | h
  · rw [max_eq_left h]
    have h2 : (m : ℤ) ≤ ((i : ℕ) : ℤ) - 1 := by omega
    rw [min_eq_left h2]; ring
  · rw [max_eq_right (le_of_lt h)]
    have h2 : ((i : ℕ) : ℤ) - 1 ≤ (m : ℤ) := by omega
    rw [min_eq_right h2]; ring

/-- The uniform divisor minus the staircase is **not** winnable. -/
theorem not_winnable_const_sub_stairE (hmn : m + 1 ≤ n) :
    ¬ Winnable (⊤ : SimpleGraph (Fin n)) (constDiv n (m : ℤ) - stairE n m) := by
  rw [const_sub_stairE_eq_stairFloor]
  refine not_winnable_stairFloor (fun i => ?_)
  show (m : ℤ) < (n : ℤ)
  exact_mod_cast (by omega : m < n)

/-! ### The exact rank -/

/-- The rank value `m(m+3)/2`, as a natural number. -/
def uniformRank (m : ℕ) : ℕ := m * (m + 3) / 2

lemma two_mul_uniformRank (m : ℕ) : 2 * uniformRank m = m * (m + 3) := by
  have hdvd : 2 ∣ m * (m + 3) := by
    rcases Nat.even_or_odd m with h | h
    · obtain ⟨t, ht⟩ := h
      exact ⟨t * (m + 3), by subst ht; ring⟩
    · obtain ⟨t, ht⟩ := h
      exact ⟨(2 * t + 1) * (t + 2), by subst ht; ring⟩
  obtain ⟨k, hk⟩ := hdvd
  simp only [uniformRank, hk]
  omega

lemma two_mul_uniformRank_succ (m : ℕ) :
    2 * ((uniformRank m : ℤ) + 1) = ((m : ℤ) + 1) * ((m : ℤ) + 2) := by
  have h : ((2 * uniformRank m : ℕ) : ℤ) = ((m * (m + 3) : ℕ) : ℤ) := by
    exact_mod_cast two_mul_uniformRank m
  push_cast at h
  linarith

/-- **`r(m • 1) ≥ m(m+3)/2`.** -/
theorem rankGE_const_top (hmn : m + 1 ≤ n) :
    RankGE (⊤ : SimpleGraph (Fin n)) (constDiv n (m : ℤ)) (uniformRank m) := by
  intro E hE hdeg
  refine winnable_const_sub hmn hE ?_
  rw [hdeg]
  have := two_mul_uniformRank_succ m
  linarith

/-- **`r(m • 1) < m(m+3)/2 + 1`**, witnessed by the staircase. -/
theorem not_rankGE_const_top (hmn : m + 1 ≤ n) :
    ¬ RankGE (⊤ : SimpleGraph (Fin n)) (constDiv n (m : ℤ)) (uniformRank m + 1) := by
  intro h
  refine not_winnable_const_sub_stairE hmn (h (stairE n m) effective_stairE ?_)
  have h1 := two_mul_degD_stairE (n := n) (m := m) hmn
  have h2 := two_mul_uniformRank_succ m
  push_cast
  linarith

/-- **The exact rank of a uniform divisor on a complete graph.**
On `K_n` with `n ≥ m + 1`, the constant divisor `m • 1` has Baker–Norine rank exactly
`m(m+3)/2`, independently of `n`. -/
theorem rank_const_top (hmn : m + 1 ≤ n) :
    rank (⊤ : SimpleGraph (Fin n)) (constDiv n (m : ℤ)) = (uniformRank m : ℤ) := by
  have hge := (rank_ge_iff (⊤ : SimpleGraph (Fin n)) (constDiv n (m : ℤ))
    (uniformRank m)).2 (rankGE_const_top hmn)
  have hlt : ¬ (((uniformRank m + 1 : ℕ) : ℤ)
      ≤ rank (⊤ : SimpleGraph (Fin n)) (constDiv n (m : ℤ))) := by
    intro hcon
    exact not_rankGE_const_top hmn
      ((rank_ge_iff (⊤ : SimpleGraph (Fin n)) (constDiv n (m : ℤ)) (uniformRank m + 1)).1 hcon)
  push_cast at hge hlt
  omega

/-- Restatement without natural-number division: `2 r(m • 1) = m(m+3)`. -/
theorem two_mul_rank_const_top (hmn : m + 1 ≤ n) :
    2 * rank (⊤ : SimpleGraph (Fin n)) (constDiv n (m : ℤ)) = (m : ℤ) * ((m : ℤ) + 3) := by
  rw [rank_const_top hmn]
  have h : ((2 * uniformRank m : ℕ) : ℤ) = ((m * (m + 3) : ℕ) : ℤ) := by
    exact_mod_cast two_mul_uniformRank m
  push_cast at h
  linarith

end ConstK

end TropicalRR