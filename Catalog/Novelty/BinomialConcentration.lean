/-
# Binomial moments and Chebyshev concentration

Elementary, fully explicit development of the first two moments of the binomial
weights

  `binw n t k = C(n,k) * t ^ k * (1 - t) ^ (n - k)`

and of the resulting Chebyshev concentration inequality.  These are the
analytic ingredients used in `UniversalRedundancyBernoulli.lean` to prove a
Rissanen-style `(1/2) log₂ n` lower bound on the minimax redundancy of the class
of memoryless binary sources.

Main results:

* `binw_sum` — the weights sum to one (binomial theorem);
* `binw_mean` — `∑ k * binw n t k = n * t`;
* `binw_sq` — `∑ k ^ 2 * binw n t k = n * t * ((n - 1) * t + 1)`;
* `binw_variance` — `∑ (k - n t) ^ 2 * binw n t k = n * t * (1 - t)`;
* `binw_chebyshev` / `binw_concentration` — Chebyshev's inequality for the
  binomial law.
-/
import Mathlib

namespace PriceOfUniversality

open Finset

/-- The binomial weight `C(n,k) t^k (1-t)^{n-k}`. -/
noncomputable def binw (n : ℕ) (t : ℝ) (k : ℕ) : ℝ :=
  (n.choose k : ℝ) * (t ^ k * (1 - t) ^ (n - k))

lemma binw_nonneg {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t ≤ 1) (n k : ℕ) : 0 ≤ binw n t k := by
  have h1 : 0 ≤ 1 - t := by linarith
  unfold binw
  positivity

/-- The binomial weights sum to one. -/
theorem binw_sum (n : ℕ) (t : ℝ) : ∑ k ∈ range (n + 1), binw n t k = 1 := by
  have h := add_pow t (1 - t) n
  have ht : t + (1 - t) = 1 := by ring
  rw [ht, one_pow] at h
  calc ∑ k ∈ range (n + 1), binw n t k
      = ∑ k ∈ range (n + 1), t ^ k * (1 - t) ^ (n - k) * (n.choose k : ℝ) :=
        Finset.sum_congr rfl fun k _ => by unfold binw; ring
    _ = 1 := h.symm

/-- The key reindexing identity `(j+1) * C(n+1, j+1) = (n+1) * C(n, j)`, in the form
needed for moment computations. -/
lemma binw_mul_succ (m j : ℕ) (t : ℝ) :
    ((j : ℝ) + 1) * binw (m + 1) t (j + 1) = ((m : ℝ) + 1) * t * binw m t j := by
  have hc : (j + 1) * ((m + 1).choose (j + 1)) = (m + 1) * (m.choose j) := by
    rw [Nat.add_one_mul_choose_eq]
    ring
  have hcR : ((j : ℝ) + 1) * (((m + 1).choose (j + 1) : ℕ) : ℝ)
      = ((m : ℝ) + 1) * ((m.choose j : ℕ) : ℝ) := by
    have := congrArg (fun x : ℕ => (x : ℝ)) hc
    push_cast at this
    linarith [this]
  unfold binw
  have hsub : (m + 1) - (j + 1) = m - j := by omega
  rw [hsub]
  calc ((j : ℝ) + 1) * ((((m + 1).choose (j + 1) : ℕ) : ℝ) * (t ^ (j + 1) * (1 - t) ^ (m - j)))
      = (((j : ℝ) + 1) * (((m + 1).choose (j + 1) : ℕ) : ℝ)) * (t ^ (j + 1) * (1 - t) ^ (m - j)) := by
        ring
    _ = (((m : ℝ) + 1) * ((m.choose j : ℕ) : ℝ)) * (t ^ (j + 1) * (1 - t) ^ (m - j)) := by
        rw [hcR]
    _ = ((m : ℝ) + 1) * t * (((m.choose j : ℕ) : ℝ) * (t ^ j * (1 - t) ^ (m - j))) := by
        ring

/-- Weighted reindexing: a sum of `k * g k * binw (m+1) t k` reduces to a sum against
`binw m t`. -/
lemma binw_weighted (m : ℕ) (t : ℝ) (g : ℕ → ℝ) :
    ∑ k ∈ range (m + 2), (k : ℝ) * g k * binw (m + 1) t k
      = ((m : ℝ) + 1) * t * ∑ j ∈ range (m + 1), g (j + 1) * binw m t j := by
  rw [Finset.sum_range_succ' (fun k => (k : ℝ) * g k * binw (m + 1) t k) (m + 1)]
  simp only [Nat.cast_zero, zero_mul, add_zero]
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl fun j _ => ?_
  have := binw_mul_succ m j t
  push_cast
  calc ((j : ℝ) + 1) * g (j + 1) * binw (m + 1) t (j + 1)
      = g (j + 1) * (((j : ℝ) + 1) * binw (m + 1) t (j + 1)) := by ring
    _ = g (j + 1) * (((m : ℝ) + 1) * t * binw m t j) := by rw [this]
    _ = ((m : ℝ) + 1) * t * (g (j + 1) * binw m t j) := by ring

/-- The mean of the binomial law. -/
theorem binw_mean (n : ℕ) (t : ℝ) :
    ∑ k ∈ range (n + 1), (k : ℝ) * binw n t k = (n : ℝ) * t := by
  cases n with
  | zero => simp [binw]
  | succ m =>
      have h := binw_weighted m t (fun _ => 1)
      simp only [mul_one, one_mul] at h
      rw [show m + 1 + 1 = m + 2 from rfl, h, binw_sum m t, mul_one]
      push_cast
      ring

/-- The second moment of the binomial law. -/
theorem binw_sq (n : ℕ) (t : ℝ) :
    ∑ k ∈ range (n + 1), (k : ℝ) ^ 2 * binw n t k = (n : ℝ) * t * (((n : ℝ) - 1) * t + 1) := by
  cases n with
  | zero => simp [binw]
  | succ m =>
      have h := binw_weighted m t (fun k => (k : ℝ))
      have hleft : ∑ k ∈ range (m + 2), (k : ℝ) * (k : ℝ) * binw (m + 1) t k
          = ∑ k ∈ range (m + 2), (k : ℝ) ^ 2 * binw (m + 1) t k :=
        Finset.sum_congr rfl fun k _ => by ring
      rw [hleft] at h
      have hright : ∑ j ∈ range (m + 1), ((j : ℝ) + 1) * binw m t j
          = (m : ℝ) * t + 1 := by
        have : ∑ j ∈ range (m + 1), ((j : ℝ) + 1) * binw m t j
            = (∑ j ∈ range (m + 1), (j : ℝ) * binw m t j)
              + ∑ j ∈ range (m + 1), binw m t j := by
          rw [← Finset.sum_add_distrib]
          exact Finset.sum_congr rfl fun j _ => by ring
        rw [this, binw_mean m t, binw_sum m t]
      have hcast : ∑ j ∈ range (m + 1), ((j + 1 : ℕ) : ℝ) * binw m t j
          = ∑ j ∈ range (m + 1), ((j : ℝ) + 1) * binw m t j :=
        Finset.sum_congr rfl fun j _ => by push_cast; ring
      rw [show m + 1 + 1 = m + 2 from rfl, h, hcast, hright]
      push_cast
      ring

/-- The variance of the binomial law. -/
theorem binw_variance (n : ℕ) (t : ℝ) :
    ∑ k ∈ range (n + 1), ((k : ℝ) - (n : ℝ) * t) ^ 2 * binw n t k
      = (n : ℝ) * t * (1 - t) := by
  have hexpand : ∀ k ∈ range (n + 1),
      ((k : ℝ) - (n : ℝ) * t) ^ 2 * binw n t k
        = (k : ℝ) ^ 2 * binw n t k
          + (-(2 * (n : ℝ) * t)) * ((k : ℝ) * binw n t k)
          + ((n : ℝ) * t) ^ 2 * binw n t k := by
    intro k _; ring
  rw [Finset.sum_congr rfl hexpand]
  rw [Finset.sum_add_distrib, Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum,
    binw_sq n t, binw_mean n t, binw_sum n t]
  ring

/-- **Chebyshev's inequality for the binomial law.** -/
theorem binw_chebyshev {n : ℕ} {t d : ℝ} (ht0 : 0 ≤ t) (ht1 : t ≤ 1) (hd : 0 < d)
    {K : Finset ℕ} (hK : K ⊆ range (n + 1))
    (hfar : ∀ k ∈ K, d ^ 2 ≤ ((k : ℝ) - (n : ℝ) * t) ^ 2) :
    ∑ k ∈ K, binw n t k ≤ (n : ℝ) * t * (1 - t) / d ^ 2 := by
  have hd2 : (0:ℝ) < d ^ 2 := by positivity
  have h1 : ∑ k ∈ K, d ^ 2 * binw n t k
      ≤ ∑ k ∈ K, ((k : ℝ) - (n : ℝ) * t) ^ 2 * binw n t k := by
    refine Finset.sum_le_sum fun k hk => ?_
    exact mul_le_mul_of_nonneg_right (hfar k hk) (binw_nonneg ht0 ht1 n k)
  have h2 : ∑ k ∈ K, ((k : ℝ) - (n : ℝ) * t) ^ 2 * binw n t k
      ≤ ∑ k ∈ range (n + 1), ((k : ℝ) - (n : ℝ) * t) ^ 2 * binw n t k := by
    refine Finset.sum_le_sum_of_subset_of_nonneg hK fun k _ _ => ?_
    have := binw_nonneg ht0 ht1 n k
    positivity
  rw [binw_variance n t] at h2
  rw [← Finset.mul_sum] at h1
  rw [le_div_iff₀ hd2]
  calc (∑ k ∈ K, binw n t k) * d ^ 2 = d ^ 2 * ∑ k ∈ K, binw n t k := by ring
    _ ≤ (n : ℝ) * t * (1 - t) := le_trans h1 h2

/-- Concentration form of Chebyshev's inequality: the binomial law puts most of its
mass on the indices close to `n t`. -/
theorem binw_concentration {n : ℕ} {t d : ℝ} (ht0 : 0 ≤ t) (ht1 : t ≤ 1) (hd : 0 < d)
    {K : Finset ℕ} (hK : K ⊆ range (n + 1))
    (hnear : ∀ k ∈ range (n + 1), k ∉ K → d ^ 2 ≤ ((k : ℝ) - (n : ℝ) * t) ^ 2) :
    1 - (n : ℝ) * t * (1 - t) / d ^ 2 ≤ ∑ k ∈ K, binw n t k := by
  have hsplit : ∑ k ∈ (range (n + 1)) \ K, binw n t k + ∑ k ∈ K, binw n t k = 1 := by
    rw [Finset.sum_sdiff hK]
    exact binw_sum n t
  have hcomp : ∑ k ∈ (range (n + 1)) \ K, binw n t k ≤ (n : ℝ) * t * (1 - t) / d ^ 2 := by
    refine binw_chebyshev ht0 ht1 hd (Finset.sdiff_subset) ?_
    intro k hk
    rw [Finset.mem_sdiff] at hk
    exact hnear k hk.1 hk.2
  linarith

end PriceOfUniversality