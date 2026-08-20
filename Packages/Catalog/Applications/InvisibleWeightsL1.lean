/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Mathlib
import Applications.InvisibleWeightsSupport

/-!
# The `ℓ¹` cost of invisibility: refuting the `2^K` conjecture

The catalog records two facts about integral vectors invisible to the power-sum window
`k < K`: the shifted binomial vector `binWeight K i` is invisible with `ℓ¹` norm exactly
`2^K`, and every nonzero invisible vector has `ℓ¹ ≥ K + 1` (`l1_ge_of_invisible_int`).  The
natural conjecture recorded in the lab notes of `Applications/InvisibleWeightsSupport.lean`
was that the binomial vector is `ℓ¹`-optimal, i.e. that `ℓ¹ ≥ 2^K` always.

**This file refutes that conjecture, for every `K ≥ 3`.**

## Main results

* `shiftDiff` — the difference operator `e ↦ (j ↦ e (j-1) - e j)`, which on generating
  polynomials is multiplication by `X - 1`.
* `moment_shiftDiff` — the exact transformation law
  `m_k(shiftDiff e) = ∑_{t < k} C(k, t) · m_t(e)`; in particular the difference operator
  raises the invisibility window by one (`shiftDiff_invisible`) and multiplies the first
  visible moment by `K + 1` (`moment_shiftDiff_top`).
* `l1_shiftDiff_le` — the operator at most doubles the `ℓ¹` norm.
* `pteWitness` — the explicit vector `(-1, 2, 0, -2, 1)` on the nodes `{0,1,2,3,4}`, i.e. the
  coefficient vector of `(X - 1)^3 (X + 1)`.  It is invisible at `K = 3`
  (`pteWitness_invisible`) with `ℓ¹ = 6 < 8 = 2^3` (`pteWitness_l1`).
* `exists_invisible_l1_lt_two_pow` — **the refutation.**  For every `K ≥ 3` there is a
  nonzero integral vector invisible to the window `k < K` with `ℓ¹ ≤ 3 · 2^{K-1} < 2^K`.
  Concretely: iterate the difference operator on the witness above.
* `two_pow_l1_conjecture_false` — the same statement packaged as the negation of the
  conjecture `∀ K, ∀ nonzero invisible e, 2^K ≤ ℓ¹(e)`.

-- !-- Lab Notes -- !--

HYPOTHESIS (Hypothesizer).  Two competing guesses for the minimal `ℓ¹` of a nonzero
invisible integral vector at window `K`: (a) `2^K`, attained by `binWeight`, mirroring the
Prouhet–Thue–Morse solution of the Prouhet–Tarry–Escott problem; (b) `2K`, the "ideal PTE"
value, which would make the classical size bound sharp.  The bold conjecture is that (a) is
badly wrong and the truth is polynomial in `K`.

EXPERIMENT (Experimenter).  Exhaustive box search over the coefficient vectors of the
binomial basis (`#eval` on the catalog definitions, see `ComputationalEvidence.md`) gives
minimal `ℓ¹` values `2, 4, 6, 8, 14` for `K = 1, …, 5`, against `2^K = 2, 4, 8, 16, 32`.  So
(a) already fails at `K = 3`, with the witness `(-1, 2, 0, -2, 1)` of `ℓ¹ = 6`.  Formalised
below, and propagated to every larger `K` by the difference operator, which raises the window
by one while at most doubling the norm: `6 · 2^{K-3} = (3/4) · 2^K < 2^K`.

ANALYSIS (Analyst).  The refutation is *structural*, not numerical: the failure of (a) is
inherited multiplicatively, because invisibility is divisibility by `(X-1)^K` of the
generating polynomial and `ℓ¹` is submultiplicative under polynomial multiplication.  Any
single sub-`2^K` witness therefore breaks the conjecture in all higher degrees.  Conjecture
(b) survives all experiments and is recorded as open in `FUTURE_DIRECTIONS.md`; note the data
`14 > 2 · 5` at `K = 5` reflects the bounded search radius, not a counterexample to (b),
since ideal PTE solutions of degree `4` need nodes well beyond the searched range.

CRITIQUE (Critic).  The refutation is guarded: it is stated for `K ≥ 3`, and at `K = 1, 2`
the conjecture `ℓ¹ ≥ 2^K` is in fact *true* by the proved bound `ℓ¹ ≥ K + 1` combined with
the parity of the norm (`l1_even_of_invisible_int`), so the boundary is exactly located.  The
witness is checked to be nonzero at an explicit node, so the statement is not vacuous.
-/

open Finset

namespace InvisibleWeights

/-! ### The difference operator -/

/-- `shiftDiff e` is the vector whose generating polynomial is `(X - 1)` times that of `e`:
`(shiftDiff e) j = e (j - 1) - e j`, with the convention `e (-1) = 0`. -/
def shiftDiff (e : ℕ → ℤ) : ℕ → ℤ := fun j => (if j = 0 then 0 else e (j - 1)) - e j

lemma shiftDiff_of_gt {N : ℕ} {e : ℕ → ℤ} (hsupp : ∀ j, N < j → e j = 0) :
    ∀ j, N + 1 < j → shiftDiff e j = 0 := by
  intro j hj
  have hj0 : j ≠ 0 := by omega
  simp only [shiftDiff, if_neg hj0]
  rw [hsupp (j - 1) (by omega), hsupp j (by omega), sub_zero]

/-- **Transformation law of the moments under the difference operator.** -/
lemma moment_shiftDiff {N : ℕ} {e : ℕ → ℤ} (hsupp : ∀ j, N < j → e j = 0) (k : ℕ) :
    moment (N + 1) (shiftDiff e) k = ∑ t ∈ range k, (k.choose t : ℤ) * moment N e t := by
  have hsplit : moment (N + 1) (shiftDiff e) k
      = (∑ j ∈ range (N + 2), (if j = 0 then 0 else e (j - 1)) * (j : ℤ) ^ k)
        - ∑ j ∈ range (N + 2), e j * (j : ℤ) ^ k := by
    rw [moment, ← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun j _ => by simp [shiftDiff, sub_mul]
  have hshift : (∑ j ∈ range (N + 2), (if j = 0 then 0 else e (j - 1)) * (j : ℤ) ^ k)
      = ∑ i ∈ range (N + 1), e i * ((i : ℤ) + 1) ^ k := by
    rw [Finset.sum_range_succ' (fun j => (if j = 0 then 0 else e (j - 1)) * (j : ℤ) ^ k) (N + 1)]
    have hz : (if (0 : ℕ) = 0 then (0 : ℤ) else e (0 - 1)) * ((0 : ℕ) : ℤ) ^ k = 0 := by simp
    rw [hz, add_zero]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [if_neg (Nat.succ_ne_zero i), Nat.add_sub_cancel]
    push_cast
    ring
  have hsecond : ∑ j ∈ range (N + 2), e j * (j : ℤ) ^ k
      = ∑ i ∈ range (N + 1), e i * (i : ℤ) ^ k := by
    rw [Finset.sum_range_succ, hsupp (N + 1) (by omega), zero_mul, add_zero]
  rw [hsplit, hshift, hsecond, ← Finset.sum_sub_distrib]
  have hbin : ∀ i : ℕ, e i * ((i : ℤ) + 1) ^ k - e i * (i : ℤ) ^ k
      = ∑ t ∈ range k, (k.choose t : ℤ) * (e i * (i : ℤ) ^ t) := by
    intro i
    have hexp : ((i : ℤ) + 1) ^ k = ∑ t ∈ range (k + 1), (i : ℤ) ^ t * (k.choose t : ℤ) := by
      rw [add_pow]
      exact Finset.sum_congr rfl fun t _ => by rw [one_pow, mul_one]
    rw [hexp, Finset.sum_range_succ, Nat.choose_self, Nat.cast_one, mul_one, mul_add,
      add_sub_cancel_right, Finset.mul_sum]
    exact Finset.sum_congr rfl fun t _ => by ring
  rw [Finset.sum_congr rfl fun i _ => hbin i, Finset.sum_comm]
  refine Finset.sum_congr rfl fun t _ => ?_
  rw [moment, Finset.mul_sum]

/-- The difference operator raises the invisibility window by one. -/
theorem shiftDiff_invisible {N K : ℕ} {e : ℕ → ℤ} (hsupp : ∀ j, N < j → e j = 0)
    (he : Invisible N K e) : Invisible (N + 1) (K + 1) (shiftDiff e) := by
  intro k hk
  rw [moment_shiftDiff hsupp]
  refine Finset.sum_eq_zero fun t ht => ?_
  have htK : t < K := lt_of_lt_of_le (mem_range.mp ht) (by omega)
  rw [he t htK, mul_zero]

/-- The first visible moment is multiplied by `K + 1`. -/
theorem moment_shiftDiff_top {N K : ℕ} {e : ℕ → ℤ} (hsupp : ∀ j, N < j → e j = 0)
    (he : Invisible N K e) :
    moment (N + 1) (shiftDiff e) (K + 1) = (K + 1 : ℤ) * moment N e K := by
  rw [moment_shiftDiff hsupp, Finset.sum_range_succ]
  have hlow : ∀ t ∈ range K, ((K + 1).choose t : ℤ) * moment N e t = 0 := by
    intro t ht
    rw [he t (mem_range.mp ht), mul_zero]
  rw [Finset.sum_congr rfl hlow, Finset.sum_const_zero, zero_add, Nat.choose_succ_self_right]
  push_cast
  ring

/-- The difference operator at most doubles the `ℓ¹` norm. -/
theorem l1_shiftDiff_le {N : ℕ} {e : ℕ → ℤ} (hsupp : ∀ j, N < j → e j = 0) :
    ∑ j ∈ range (N + 2), |shiftDiff e j| ≤ 2 * ∑ j ∈ range (N + 1), |e j| := by
  have hstep : ∀ j ∈ range (N + 2),
      |shiftDiff e j| ≤ |if j = 0 then 0 else e (j - 1)| + |e j| := by
    intro j _
    exact abs_sub _ _
  refine (Finset.sum_le_sum hstep).trans ?_
  rw [Finset.sum_add_distrib]
  have h1 : ∑ j ∈ range (N + 2), |if j = 0 then (0 : ℤ) else e (j - 1)|
      = ∑ i ∈ range (N + 1), |e i| := by
    rw [Finset.sum_range_succ' (fun j => |if j = 0 then (0 : ℤ) else e (j - 1)|) (N + 1)]
    simp
  have h2 : ∑ j ∈ range (N + 2), |e j| = ∑ j ∈ range (N + 1), |e j| := by
    rw [Finset.sum_range_succ, hsupp (N + 1) (by omega), abs_zero, add_zero]
  rw [h1, h2]
  ring_nf
  omega

/-! ### The sub-`2^K` witness at `K = 3` -/

/-- The coefficient vector of `(X - 1)^3 (X + 1) = X^4 - 2X^3 + 2X - 1`, read on the nodes
`{0,1,2,3,4}`. -/
def pteWitness : ℕ → ℤ := fun j =>
  if j = 0 then -1 else if j = 1 then 2 else if j = 3 then -2 else if j = 4 then 1 else 0

lemma pteWitness_of_gt : ∀ j, 4 < j → pteWitness j = 0 := by
  intro j hj
  simp only [pteWitness]
  rw [if_neg (by omega), if_neg (by omega), if_neg (by omega), if_neg (by omega)]

/-- The witness is invisible to the window `k < 3`. -/
theorem pteWitness_invisible : Invisible 4 3 pteWitness := by
  intro k hk
  interval_cases k <;>
    simp [moment, Finset.sum_range_succ, pteWitness]

/-- Its first visible moment is `12 ≠ 0`; in particular the witness is nonzero. -/
theorem pteWitness_moment_top : moment 4 pteWitness 3 = 12 := by
  simp [moment, Finset.sum_range_succ, pteWitness]

/-- Its `ℓ¹` norm is `6`, strictly below `2^3 = 8`. -/
theorem pteWitness_l1 : ∑ j ∈ range 5, |pteWitness j| = 6 := by
  simp [Finset.sum_range_succ, pteWitness]

/-! ### Propagation to all higher windows -/

/-- The induction step packaged: at every window `K ≥ 3` there is an integral vector,
supported on `{0, …, N}`, invisible to `k < K`, with nonzero top moment and
`ℓ¹ ≤ 6 · 2^{K-3}`. -/
theorem exists_invisible_l1_le (m : ℕ) :
    ∃ (N : ℕ) (e : ℕ → ℤ), (∀ j, N < j → e j = 0) ∧ Invisible N (3 + m) e ∧
      moment N e (3 + m) ≠ 0 ∧ ∑ j ∈ range (N + 1), |e j| ≤ 6 * 2 ^ m := by
  induction m with
  | zero =>
      refine ⟨4, pteWitness, pteWitness_of_gt, pteWitness_invisible, ?_, ?_⟩
      · rw [pteWitness_moment_top]; norm_num
      · rw [pteWitness_l1]; norm_num
  | succ m ih =>
      obtain ⟨N, e, hsupp, hinv, htop, hl1⟩ := ih
      refine ⟨N + 1, shiftDiff e, shiftDiff_of_gt hsupp, ?_, ?_, ?_⟩
      · have := shiftDiff_invisible hsupp hinv
        rwa [show 3 + m + 1 = 3 + (m + 1) by ring] at this
      · have hstep := moment_shiftDiff_top hsupp hinv
        rw [show 3 + (m + 1) = (3 + m) + 1 by ring]
        rw [hstep]
        exact mul_ne_zero (by positivity) htop
      · have hd := l1_shiftDiff_le hsupp
        calc ∑ j ∈ range (N + 1 + 1), |shiftDiff e j| ≤ 2 * ∑ j ∈ range (N + 1), |e j| := hd
          _ ≤ 2 * (6 * 2 ^ m) := by omega
          _ = 6 * 2 ^ (m + 1) := by ring

/-- **Refutation of the `2^K` conjecture.**  For every `K ≥ 3` there is an integral vector
invisible to the power-sum window `k < K`, nonzero at some node `≤ N`, whose `ℓ¹` norm is
strictly smaller than `2^K`. -/
theorem exists_invisible_l1_lt_two_pow {K : ℕ} (hK : 3 ≤ K) :
    ∃ (N : ℕ) (e : ℕ → ℤ), Invisible N K e ∧ (∃ j ≤ N, e j ≠ 0) ∧
      ∑ j ∈ range (N + 1), |e j| < 2 ^ K := by
  obtain ⟨m, rfl⟩ : ∃ m, K = 3 + m := ⟨K - 3, by omega⟩
  obtain ⟨N, e, hsupp, hinv, htop, hl1⟩ := exists_invisible_l1_le m
  refine ⟨N, e, hinv, ?_, ?_⟩
  · by_contra hcon
    push_neg at hcon
    apply htop
    refine Finset.sum_eq_zero fun j hj => ?_
    rw [hcon j (Nat.lt_succ_iff.mp (mem_range.mp hj)), zero_mul]
  · have hpow : (6 : ℤ) * 2 ^ m < 2 ^ (3 + m) := by
      rw [pow_add]
      have h2 : (0 : ℤ) < 2 ^ m := by positivity
      norm_num
    exact lt_of_le_of_lt hl1 hpow

/-- **The boundary of the refutation is exact.**  For `K = 1` and `K = 2` the bound `ℓ¹ ≥ 2^K`
*is* true: it follows from the sharp support bound `ℓ¹ ≥ K + 1` together with the parity of
the norm.  Hence `K = 3` is the first window where the `2^K` conjecture fails. -/
theorem l1_ge_two_pow_of_window_le_two {N K : ℕ} (hK : 1 ≤ K) (hK2 : K ≤ 2) {e : ℕ → ℤ}
    (he : Invisible N K e) {j₀ : ℕ} (hj₀ : j₀ ≤ N) (hne : e j₀ ≠ 0) :
    (2 : ℤ) ^ K ≤ ∑ j ∈ range (N + 1), |e j| := by
  interval_cases K
  · have h := l1_ge_of_invisible_int he hj₀ hne
    push_cast at h
    norm_num
    linarith
  · have h := l1_ge_of_invisible_int_even (by omega) (by decide) he hj₀ hne
    push_cast at h
    norm_num
    linarith

/-- The conjecture "every nonzero integral vector invisible to the window `k < K` has
`ℓ¹ ≥ 2^K`" is **false**. -/
theorem two_pow_l1_conjecture_false :
    ¬ (∀ (N K : ℕ) (e : ℕ → ℤ), Invisible N K e → (∃ j ≤ N, e j ≠ 0) →
        (2 : ℤ) ^ K ≤ ∑ j ∈ range (N + 1), |e j|) := by
  intro hconj
  obtain ⟨N, e, hinv, hne, hlt⟩ := exists_invisible_l1_lt_two_pow (K := 3) le_rfl
  exact absurd (hconj N 3 e hinv hne) (not_le.mpr hlt)

end InvisibleWeights