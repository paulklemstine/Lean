import Shared.GradedTransitivity.Structure

/-!
# Newton's forward-difference classification

This file closes the circle around the rationality criterion by proving the
missing *converse*: a sequence whose `k`-th forward difference vanishes
eventually is, from that point on, a `ℚ`-linear combination of the `k`
binomial functions `n ↦ C(n-N, j)`, `j < k` (Newton's forward difference
formula).  Together with `FiniteDifference` this yields the classification

`(1-q)^k` clears `∑ a n qⁿ`
  ⟺ `Δ^k a` vanishes eventually
  ⟺ `a` is eventually a combination of `C(·-N, j)`, `j < k`.

For a graded `G`-set this says: eventual `r`-transitivity is only the simplest
member of a hierarchy, and the exponent `k` in the denominator measures exactly
the binomial degree of the orbit-counting sequence.

## Main results

* `newton_forward` : Newton's forward difference formula.
* `sdiff_iter_binom_eq_zero` : the binomial functions are annihilated.
* `rationality_tfae_newton` : the three-way classification.
-/

namespace GradedTransitivity

open Polynomial

/-! ### Linearity of the difference operator -/

theorem sdiff_iter_sum {ι : Type*} (s : Finset ι) (F : ι → ℕ → ℚ) :
    ∀ k : ℕ, sdiff^[k] (fun n => ∑ j ∈ s, F j n) = fun n => ∑ j ∈ s, sdiff^[k] (F j) n := by
  intro k
  induction k generalizing F with
  | zero => simp
  | succ k ih =>
      rw [Function.iterate_succ_apply]
      have hs : sdiff (fun n => ∑ j ∈ s, F j n) = fun n => ∑ j ∈ s, sdiff (F j) n := by
        funext n
        simp [sdiff, Finset.sum_sub_distrib]
      rw [hs, ih (fun j => sdiff (F j))]
      funext n
      simp [Function.iterate_succ_apply]

theorem sdiff_iter_const_mul (c : ℚ) (f : ℕ → ℚ) :
    ∀ k : ℕ, sdiff^[k] (fun n => c * f n) = fun n => c * sdiff^[k] f n := by
  intro k
  induction k generalizing f with
  | zero => simp
  | succ k ih =>
      rw [Function.iterate_succ_apply]
      have hs : sdiff (fun n => c * f n) = fun n => c * sdiff f n := by
        funext n; simp [sdiff]; ring
      rw [hs, ih (sdiff f)]
      funext n
      simp [Function.iterate_succ_apply]

/-- Iterated differences of a sequence that vanishes from `N` on still vanish
from `N` on. -/
theorem sdiff_iter_eq_zero_of_eq_zero {f : ℕ → ℚ} {N : ℕ} (h : ∀ n ≥ N, f n = 0) (k : ℕ) :
    ∀ n ≥ N, sdiff^[k] f n = 0 := by
  intro n hn
  have := sdiff_iter_congr k f (fun _ => 0) N (fun m hm => h m hm) n hn
  rw [this]
  clear this
  induction k with
  | zero => simp
  | succ k ih =>
      rw [Function.iterate_succ_apply]
      have : sdiff (fun _ : ℕ => (0 : ℚ)) = fun _ => 0 := by funext m; simp [sdiff]
      rw [this]
      exact ih

/-! ### The shifted binomial functions -/

/-- The `j`-th shifted binomial function `n ↦ C(n-N, j)`. -/
def binomShift (N j : ℕ) : ℕ → ℚ := fun n => ((n - N).choose j : ℚ)

/-- Past the shift, differencing lowers the binomial index. -/
theorem sdiff_binomShift (N j : ℕ) :
    ∀ n ≥ N, sdiff (binomShift N (j + 1)) n = binomShift N j n := by
  intro n hn
  have h1 : n + 1 - N = (n - N) + 1 := by omega
  simp only [sdiff, binomShift, h1]
  rw [Nat.choose_succ_succ (n - N) j]
  push_cast
  ring

/-- `Δ^{j+1}` annihilates `n ↦ C(n-N, j)` past the shift. -/
theorem sdiff_iter_binomShift_eq_zero (N : ℕ) :
    ∀ j : ℕ, ∀ n ≥ N, sdiff^[j + 1] (binomShift N j) n = 0 := by
  intro j
  induction j with
  | zero =>
      intro n _
      show sdiff (binomShift N 0) n = 0
      simp [sdiff, binomShift]
  | succ j ih =>
      intro n hn
      rw [Function.iterate_succ_apply]
      have hcongr := sdiff_iter_congr (j + 1) (sdiff (binomShift N (j + 1))) (binomShift N j) N
        (fun m hm => sdiff_binomShift N j m hm) n hn
      rw [hcongr]
      exact ih n hn

/-- More generally `Δ^k` annihilates `n ↦ C(n-N, j)` past the shift whenever
`j < k`. -/
theorem sdiff_iter_binom_eq_zero {N j k : ℕ} (hjk : j < k) :
    ∀ n ≥ N, sdiff^[k] (binomShift N j) n = 0 := by
  intro n hn
  obtain ⟨m, hm⟩ : ∃ m, k = m + (j + 1) := ⟨k - (j + 1), by omega⟩
  rw [hm, Function.iterate_add_apply]
  exact sdiff_iter_eq_zero_of_eq_zero (sdiff_iter_binomShift_eq_zero N j) m n hn

/-! ### Newton's forward difference formula -/

/-- Shifting the index commutes with differencing. -/
theorem sdiff_iter_shift (N : ℕ) :
    ∀ (k : ℕ) (a : ℕ → ℚ), sdiff^[k] (fun m => a (N + m)) = fun m => sdiff^[k] a (N + m) := by
  intro k
  induction k with
  | zero => intro a; simp
  | succ k ih =>
      intro a
      rw [Function.iterate_succ_apply]
      have hs : sdiff (fun m => a (N + m)) = fun m => sdiff a (N + m) := by
        funext m
        rfl
      rw [hs, ih (sdiff a)]
      funext m
      rw [Function.iterate_succ_apply]

/-- Hockey-stick identity, in the form needed here. -/
theorem sum_range_choose_hockey (j : ℕ) :
    ∀ m : ℕ, ∑ i ∈ Finset.range m, ((i.choose j : ℚ)) = (m.choose (j + 1) : ℚ) := by
  intro m
  induction m with
  | zero => simp
  | succ m ih =>
      rw [Finset.sum_range_succ, ih, Nat.choose_succ_succ' m j]
      push_cast
      ring

/-- **Newton's forward difference formula at the origin.** -/
theorem newton_zero :
    ∀ (k : ℕ) (b : ℕ → ℚ), (∀ m, sdiff^[k] b m = 0) →
      ∀ m, b m = ∑ j ∈ Finset.range k, (sdiff^[j] b 0) * (m.choose j : ℚ) := by
  intro k
  induction k with
  | zero => intro b hb m; simpa using hb m
  | succ k ih =>
      intro b hb m
      have hc : ∀ i, sdiff^[k] (sdiff b) i = 0 := by
        intro i
        rw [← Function.iterate_succ_apply]
        exact hb i
      have hcform := ih (sdiff b) hc
      have htel : ∑ i ∈ Finset.range m, sdiff b i = b m - b 0 :=
        Finset.sum_range_sub (fun i => b i) m
      have hexp : ∑ i ∈ Finset.range m, sdiff b i
          = ∑ j ∈ Finset.range k, (sdiff^[j] (sdiff b) 0) * ((m.choose (j + 1) : ℚ)) := by
        calc ∑ i ∈ Finset.range m, sdiff b i
            = ∑ i ∈ Finset.range m, ∑ j ∈ Finset.range k,
                (sdiff^[j] (sdiff b) 0) * ((i.choose j : ℚ)) := by
              exact Finset.sum_congr rfl (fun i _ => hcform i)
          _ = ∑ j ∈ Finset.range k, ∑ i ∈ Finset.range m,
                (sdiff^[j] (sdiff b) 0) * ((i.choose j : ℚ)) := Finset.sum_comm
          _ = ∑ j ∈ Finset.range k, (sdiff^[j] (sdiff b) 0) * ((m.choose (j + 1) : ℚ)) := by
              refine Finset.sum_congr rfl (fun j _ => ?_)
              rw [← Finset.mul_sum, sum_range_choose_hockey j m]
      rw [Finset.sum_range_succ']
      have hb0 : ∀ j, sdiff^[j + 1] b 0 = sdiff^[j] (sdiff b) 0 := by
        intro j; rw [Function.iterate_succ_apply]
      have : b m = b 0 + ∑ i ∈ Finset.range m, sdiff b i := by rw [htel]; ring
      rw [this, hexp]
      simp only [hb0, Function.iterate_zero, id_eq, Nat.choose_zero_right, Nat.cast_one, mul_one]
      ring

/-- **Newton's forward difference formula.**  If `Δ^k a` vanishes from `N` on,
then from `N` on, `a` is the explicit binomial combination
`a n = ∑_{j<k} (Δ^j a)(N) · C(n-N, j)`. -/
theorem newton_forward {k N : ℕ} {a : ℕ → ℚ} (h : ∀ n ≥ N, sdiff^[k] a n = 0) :
    ∀ n ≥ N, a n = ∑ j ∈ Finset.range k, (sdiff^[j] a N) * (((n - N).choose j : ℚ)) := by
  intro n hn
  have hb : ∀ m, sdiff^[k] (fun m => a (N + m)) m = 0 := by
    intro m
    rw [sdiff_iter_shift N k a]
    exact h (N + m) (by omega)
  have hnew := newton_zero k (fun m => a (N + m)) hb (n - N)
  have hNn : N + (n - N) = n := by omega
  simp only [hNn] at hnew
  rw [hnew]
  refine Finset.sum_congr rfl (fun j _ => ?_)
  rw [sdiff_iter_shift N j a]
  simp

/-! ### The classification -/

/-- **Three-way classification.**  For a sequence `a : ℕ → ℚ` and `k : ℕ` the
following are equivalent: the denominator `(1-q)^k` clears the generating
function; the `k`-th forward difference vanishes eventually; and `a` is
eventually a `ℚ`-combination of the `k` shifted binomials `C(·-N, j)`. -/
theorem rationality_tfae_newton (k : ℕ) (a : ℕ → ℚ) :
    ((∃ P : ℚ[X], (1 - PowerSeries.X) ^ k * gen a = (P : PowerSeries ℚ)) ↔
        EventuallyZero (sdiff^[k] a)) ∧
      (EventuallyZero (sdiff^[k] a) ↔
        ∃ (N : ℕ) (d : ℕ → ℚ), ∀ n ≥ N, a n = ∑ j ∈ Finset.range k, d j * binomShift N j n) := by
  refine ⟨sdiff_iter_eventuallyZero_iff k a, ?_, ?_⟩
  · rintro ⟨N, hN⟩
    exact ⟨N, fun j => sdiff^[j] a N, fun n hn => newton_forward hN n hn⟩
  · rintro ⟨N, d, hd⟩
    refine ⟨N, fun n hn => ?_⟩
    have hsum : ∀ m ≥ N, sdiff^[k] (fun n => ∑ j ∈ Finset.range k, d j * binomShift N j n) m
        = 0 := by
      intro m hm
      rw [sdiff_iter_sum (Finset.range k) (fun j n => d j * binomShift N j n) k]
      refine Finset.sum_eq_zero (fun j hj => ?_)
      rw [sdiff_iter_const_mul (d j) (binomShift N j) k]
      show d j * sdiff^[k] (binomShift N j) m = 0
      rw [sdiff_iter_binom_eq_zero (Finset.mem_range.1 hj) m hm]
      ring
    have hcongr := sdiff_iter_congr k a
      (fun n => ∑ j ∈ Finset.range k, d j * binomShift N j n) N hd n hn
    rw [hcongr]
    exact hsum n hn

end GradedTransitivity