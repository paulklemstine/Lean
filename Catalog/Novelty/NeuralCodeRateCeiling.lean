import Mathlib
import Novelty.NeuralCodeCapacityBounds

/-!
# Neural Coding: the Sphere-Packing Rate Ceiling

`Catalog/Novelty/NeuralCodeCapacityBounds.lean` established the *lower* half of
the rate–distance picture for noise-tolerant neural codes: the Gilbert–Varshamov
theorem says the robust capacity `A(N,d)` of `N` neurons has rate at least
`1 - H₂(δ)` bits per neuron, `δ = (d-1)/N`.  The matching *upper* half needs a
**lower** bound on a binomial coefficient, namely the largest-term estimate

`N ^ N ≤ (N + 1) * r ^ r * (N - r) ^ (N - r) * C(N, r)`,

equivalently `log C(N,r) ≥ N · H(r/N) - log (N+1)`.  That is what this file
proves, and then feeds into the sphere-packing (Hamming) bound to obtain the
**rate ceiling**

`log₂ A(N, 2t+1) / N ≤ 1 - H₂(t/N) + log₂(N+1) / N`.

Together with Gilbert–Varshamov this sandwiches the achievable rate of a
population of `N` neurons that must survive `t` misfirings.

## Main results

* `binTerm_le_center` — the binomial term `C(N,k) r^k (N-r)^(N-k)` is maximal at
  `k = r`: the Bernoulli(`r/N`) distribution on `N` neurons peaks at `r` active
  neurons.  (Proved entirely in `ℕ` by a two-sided ratio argument.)
* `pow_self_le_succ_mul_binTerm` — `N^N ≤ (N+1) * binTerm N r r`, the
  largest-term lower bound for the binomial sum.
* `four_pow_le_central_binom` — the classical corollary `4^n ≤ (2n+1) * C(2n,n)`.
* `log_choose_lower` — `N · H(r/N) - log (N+1) ≤ log C(N,r)`, the entropy lower
  bound on binomial coefficients (the converse of `log_ballVolume_le`).
* `ballVolume_entropy_sandwich` — combining with `log_ballVolume_le`, the volume
  of a Hamming ball of relative radius `δ ≤ 1/2` is `exp (N · H(δ))` up to a
  factor `N + 1`.
* `log_maxCodeSize_le` / `sphere_packing_rate_bits` — the **rate ceiling** for
  `t`-error-correcting neural codes.
* `neural_rate_sandwich` — the two-sided rate estimate: with `δ = t/N`,
  `1 - H₂(2δ) ≤ log₂ A(N,2t+1)/N ≤ 1 - H₂(δ) + log₂(N+1)/N`.
-/

namespace NeuralCodeRateCeiling

open Finset NeuralCodeCapacity

/-! ## The largest term of a binomial sum -/

/-- The `k`-th term of the expansion of `N ^ N = (r + (N - r)) ^ N`.  Up to the
factor `N ^ N` this is the probability that exactly `k` of `N` neurons, each
firing independently with probability `r / N`, are active. -/
def binTerm (N r k : ℕ) : ℕ := r ^ k * (N - r) ^ (N - k) * N.choose k

/-- Ratio inequality driving the increasing half: for `k + 1 ≤ r`. -/
private lemma key_up {N r k : ℕ} (hr : r ≤ N) (hk : k + 1 ≤ r) :
    (k + 1) * (N - r) ≤ (N - k) * r := by
  have h1 : k ≤ N := by omega
  have hk' : ((k : ℤ) + 1) ≤ (r : ℤ) := by exact_mod_cast hk
  have hr' : (r : ℤ) ≤ (N : ℤ) := by exact_mod_cast hr
  have hN0 : (0 : ℤ) ≤ (N : ℤ) := Int.natCast_nonneg N
  have hr0 : (0 : ℤ) ≤ (r : ℤ) := Int.natCast_nonneg r
  zify [hr, h1]
  nlinarith

/-- Ratio inequality driving the decreasing half: for `r ≤ k < N`. -/
private lemma key_down {N r k : ℕ} (hr : r ≤ N) (hk : r ≤ k) (hkN : k < N) :
    (N - k) * r ≤ (k + 1) * (N - r) := by
  have h1 : k ≤ N := by omega
  have hk' : (r : ℤ) ≤ (k : ℤ) := by exact_mod_cast hk
  have hr' : (r : ℤ) ≤ (N : ℤ) := by exact_mod_cast hr
  have hN0 : (0 : ℤ) ≤ (N : ℤ) := Int.natCast_nonneg N
  zify [hr, h1]
  nlinarith

/-- Below the peak the binomial terms increase. -/
lemma binTerm_step_up {N r k : ℕ} (hr : r ≤ N) (hk : k + 1 ≤ r) :
    binTerm N r k ≤ binTerm N r (k + 1) := by
  have hchoose : N.choose (k + 1) * (k + 1) = N.choose k * (N - k) :=
    Nat.choose_succ_right_eq N k
  have hb : (N - r) ^ (N - k) = (N - r) ^ (N - (k + 1)) * (N - r) := by
    have h : N - k = (N - (k + 1)) + 1 := by omega
    rw [h, pow_succ]
  have e1 : (k + 1) * binTerm N r k
      = (r ^ k * (N - r) ^ (N - (k + 1)) * N.choose k) * ((k + 1) * (N - r)) := by
    unfold binTerm; rw [hb]; ring
  have e2 : (k + 1) * binTerm N r (k + 1)
      = (r ^ k * (N - r) ^ (N - (k + 1)) * N.choose k) * ((N - k) * r) := by
    unfold binTerm
    calc (k + 1) * (r ^ (k + 1) * (N - r) ^ (N - (k + 1)) * N.choose (k + 1))
        = (r ^ k * (N - r) ^ (N - (k + 1))) * (N.choose (k + 1) * (k + 1)) * r := by ring
      _ = (r ^ k * (N - r) ^ (N - (k + 1))) * (N.choose k * (N - k)) * r := by rw [hchoose]
      _ = _ := by ring
  refine Nat.le_of_mul_le_mul_left ?_ (Nat.succ_pos k)
  rw [e1, e2]
  exact Nat.mul_le_mul_left _ (key_up hr hk)

/-- Above the peak the binomial terms decrease. -/
lemma binTerm_step_down {N r k : ℕ} (hr : r ≤ N) (hk : r ≤ k) (hkN : k < N) :
    binTerm N r (k + 1) ≤ binTerm N r k := by
  have hchoose : N.choose (k + 1) * (k + 1) = N.choose k * (N - k) :=
    Nat.choose_succ_right_eq N k
  have hb : (N - r) ^ (N - k) = (N - r) ^ (N - (k + 1)) * (N - r) := by
    have h : N - k = (N - (k + 1)) + 1 := by omega
    rw [h, pow_succ]
  have e1 : (k + 1) * binTerm N r k
      = (r ^ k * (N - r) ^ (N - (k + 1)) * N.choose k) * ((k + 1) * (N - r)) := by
    unfold binTerm; rw [hb]; ring
  have e2 : (k + 1) * binTerm N r (k + 1)
      = (r ^ k * (N - r) ^ (N - (k + 1)) * N.choose k) * ((N - k) * r) := by
    unfold binTerm
    calc (k + 1) * (r ^ (k + 1) * (N - r) ^ (N - (k + 1)) * N.choose (k + 1))
        = (r ^ k * (N - r) ^ (N - (k + 1))) * (N.choose (k + 1) * (k + 1)) * r := by ring
      _ = (r ^ k * (N - r) ^ (N - (k + 1))) * (N.choose k * (N - k)) * r := by rw [hchoose]
      _ = _ := by ring
  refine Nat.le_of_mul_le_mul_left ?_ (Nat.succ_pos k)
  rw [e2, e1]
  exact Nat.mul_le_mul_left _ (key_down hr hk hkN)

private lemma binTerm_le_center_of_le {N r : ℕ} (hr : r ≤ N) :
    ∀ j k : ℕ, k + j = r → binTerm N r k ≤ binTerm N r r := by
  intro j
  induction j with
  | zero => intro k hk; simp only [Nat.add_zero] at hk; subst hk; exact le_rfl
  | succ j ih => intro k hk; exact le_trans (binTerm_step_up hr (by omega)) (ih (k + 1) (by omega))

private lemma binTerm_le_center_of_ge {N r : ℕ} (hr : r ≤ N) :
    ∀ j k : ℕ, k = r + j → k ≤ N → binTerm N r k ≤ binTerm N r r := by
  intro j
  induction j with
  | zero => intro k hk _; simp only [Nat.add_zero] at hk; subst hk; exact le_rfl
  | succ j ih =>
      intro k hk hkN
      have h1 : k = (r + j) + 1 := by omega
      subst h1
      exact le_trans (binTerm_step_down hr (by omega) (by omega)) (ih (r + j) rfl (by omega))

/-- **The binomial distribution with parameter `r/N` peaks at `r`.**  Among all
activity levels `k`, the weight `C(N,k) r^k (N-r)^(N-k)` is largest at `k = r`. -/
theorem binTerm_le_center {N r k : ℕ} (hr : r ≤ N) (hk : k ≤ N) :
    binTerm N r k ≤ binTerm N r r := by
  rcases le_total k r with h | h
  · exact binTerm_le_center_of_le hr (r - k) k (by omega)
  · exact binTerm_le_center_of_ge hr (k - r) k (by omega) hk

/-- The binomial expansion of `N ^ N` in terms of `r` and `N - r`. -/
lemma sum_binTerm {N r : ℕ} (hr : r ≤ N) :
    ∑ k ∈ Finset.range (N + 1), binTerm N r k = N ^ N := by
  have h := add_pow (r : ℕ) (N - r) N
  rw [Nat.add_sub_cancel' hr] at h
  rw [h]
  exact Finset.sum_congr rfl (fun k _ => by simp [binTerm])

/-- **Largest-term bound.**  The single largest term of the binomial expansion of
`N ^ N` already accounts for at least a `1/(N+1)` fraction of it. -/
theorem pow_self_le_succ_mul_binTerm {N r : ℕ} (hr : r ≤ N) :
    N ^ N ≤ (N + 1) * binTerm N r r := by
  calc N ^ N = ∑ k ∈ Finset.range (N + 1), binTerm N r k := (sum_binTerm hr).symm
    _ ≤ ∑ _k ∈ Finset.range (N + 1), binTerm N r r :=
        Finset.sum_le_sum fun k hk =>
          binTerm_le_center hr (Nat.lt_succ_iff.mp (Finset.mem_range.mp hk))
    _ = (N + 1) * binTerm N r r := by
        rw [Finset.sum_const, Finset.card_range, smul_eq_mul]

/-- **Central binomial corollary.**  `4 ^ n ≤ (2n + 1) * C(2n, n)`: the middle
binomial coefficient carries at least a `1/(2n+1)` share of all `4 ^ n` patterns
of a `2n`-neuron population. -/
theorem four_pow_le_central_binom (n : ℕ) : 4 ^ n ≤ (2 * n + 1) * (2 * n).choose n := by
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · simp
  have h := pow_self_le_succ_mul_binTerm (N := 2 * n) (r := n) (by omega)
  have hsub : 2 * n - n = n := by omega
  have hb : binTerm (2 * n) n n = n ^ (2 * n) * (2 * n).choose n := by
    unfold binTerm
    rw [hsub, ← pow_add]
    ring_nf
  have hlhs : (2 * n) ^ (2 * n) = 4 ^ n * n ^ (2 * n) := by
    rw [mul_pow]
    congr 1
    rw [pow_mul]
    norm_num
  rw [hb, hlhs] at h
  have hpos : 0 < n ^ (2 * n) := Nat.pow_pos hn
  refine Nat.le_of_mul_le_mul_right ?_ hpos
  calc 4 ^ n * n ^ (2 * n) ≤ (2 * n + 1) * (n ^ (2 * n) * (2 * n).choose n) := h
    _ = (2 * n + 1) * (2 * n).choose n * n ^ (2 * n) := by ring

/-! ## The entropy lower bound on binomial coefficients -/

private lemma mul_log_div_eq {a b : ℝ} (ha : 0 ≤ a) (hb : 0 < b) :
    a * Real.log (a / b) = a * Real.log a - a * Real.log b := by
  rcases eq_or_lt_of_le ha with h | h
  · rw [← h]; ring
  · rw [Real.log_div (ne_of_gt h) (ne_of_gt hb)]; ring

/-- `N · H(r/N)` written out in nats, with `H` the binary entropy. -/
lemma mul_binEntropy_eq (N r : ℕ) (hN : 0 < N) (hr : r ≤ N) :
    (N : ℝ) * Real.binEntropy ((r : ℝ) / N)
      = N * Real.log N - r * Real.log r - ((N : ℝ) - r) * Real.log ((N : ℝ) - r) := by
  have hN0 : (0 : ℝ) < N := by exact_mod_cast hN
  have hr0 : (0 : ℝ) ≤ r := Nat.cast_nonneg r
  have hrN : (r : ℝ) ≤ N := by exact_mod_cast hr
  set p : ℝ := (r : ℝ) / N with hp
  have hNp : (N : ℝ) * p = r := by rw [hp]; field_simp
  have h1p : 1 - p = ((N : ℝ) - r) / N := by rw [hp]; field_simp
  have hN1p : (N : ℝ) * (1 - p) = (N : ℝ) - r := by rw [h1p]; field_simp
  have e1 : (r : ℝ) * Real.log p = r * Real.log r - r * Real.log N := mul_log_div_eq hr0 hN0
  have e2 : ((N : ℝ) - r) * Real.log (1 - p)
      = ((N : ℝ) - r) * Real.log ((N : ℝ) - r) - ((N : ℝ) - r) * Real.log N := by
    rw [h1p]; exact mul_log_div_eq (by linarith) hN0
  rw [Real.binEntropy, Real.log_inv, Real.log_inv]
  have expand : (N : ℝ) * (p * -Real.log p + (1 - p) * -Real.log (1 - p))
      = -(((N : ℝ) * p) * Real.log p) - (((N : ℝ) * (1 - p)) * Real.log (1 - p)) := by ring
  rw [expand, hNp, hN1p, e1, e2]
  ring

/-- **Entropy lower bound for binomial coefficients.**  `log C(N,r) ≥ N·H(r/N) -
log(N+1)`.  This is the converse of the ball-volume upper bound
`log (ballVolume N r) ≤ N·H(r/N)`, so the number of activity patterns of a fixed
sparsity `r/N` is `exp(N·H(r/N))` up to a polynomial factor. -/
theorem log_choose_lower (N r : ℕ) (hN : 0 < N) (hr : r ≤ N) :
    (N : ℝ) * Real.binEntropy ((r : ℝ) / N) - Real.log (N + 1) ≤ Real.log (N.choose r) := by
  have hN0 : (0 : ℝ) < N := by exact_mod_cast hN
  have hnat := pow_self_le_succ_mul_binTerm hr
  have hb : ((binTerm N r r : ℕ) : ℝ)
      = (r : ℝ) ^ r * (((N : ℝ) - r) ^ (N - r) * (N.choose r : ℝ)) := by
    simp only [binTerm]; push_cast [hr]; ring
  have hcast : (N : ℝ) ^ N
      ≤ ((N : ℝ) + 1) * ((r : ℝ) ^ r * (((N : ℝ) - r) ^ (N - r) * (N.choose r : ℝ))) := by
    have h := (Nat.cast_le (α := ℝ)).mpr hnat
    push_cast at h
    rw [hb] at h
    exact h
  have hrr : (0 : ℝ) < (r : ℝ) ^ r := by
    rcases Nat.eq_zero_or_pos r with h | h
    · subst h; simp
    · have : (0 : ℝ) < r := by exact_mod_cast h
      positivity
  have hnr : (0 : ℝ) < ((N : ℝ) - r) ^ (N - r) := by
    rcases Nat.eq_zero_or_pos (N - r) with h | h
    · rw [h]; simp
    · have h1 : (0 : ℝ) < (N : ℝ) - r := by
        have h2 : r < N := by omega
        have : (r : ℝ) < N := by exact_mod_cast h2
        linarith
      positivity
  have hC : (0 : ℝ) < (N.choose r : ℝ) := by
    have := Nat.choose_pos hr
    exact_mod_cast this
  have hsub : ((N - r : ℕ) : ℝ) = (N : ℝ) - r := by push_cast [hr]; ring
  have hlog := Real.log_le_log (by positivity) hcast
  rw [Real.log_pow, Real.log_mul (by positivity) (by positivity),
      Real.log_mul (ne_of_gt hrr) (by positivity),
      Real.log_mul (ne_of_gt hnr) (ne_of_gt hC), Real.log_pow, Real.log_pow, hsub] at hlog
  rw [mul_binEntropy_eq N r hN hr]
  linarith

/-! ## The rate ceiling for error-correcting neural codes -/

/-- A Hamming ball of radius `t` contains at least the `C(N,t)` patterns at
distance exactly `t`. -/
lemma choose_le_ballVolume (N t : ℕ) : N.choose t ≤ ballVolume N t := by
  rw [ballVolume]
  exact Finset.single_le_sum (f := fun k => N.choose k) (fun k _ => Nat.zero_le _)
    (Finset.self_mem_range_succ t)

/-- **Entropy lower bound for ball volume**, complementing `log_ballVolume_le`. -/
theorem log_ballVolume_ge (N r : ℕ) (hN : 0 < N) (hr : r ≤ N) :
    (N : ℝ) * Real.binEntropy ((r : ℝ) / N) - Real.log (N + 1)
      ≤ Real.log (ballVolume N r) := by
  refine le_trans (log_choose_lower N r hN hr) (Real.log_le_log ?_ ?_)
  · exact_mod_cast Nat.choose_pos hr
  · exact_mod_cast choose_le_ballVolume N r

/-- **Ball volumes are entropy-exact up to a polynomial factor.**  For relative
radius `δ = r/N ≤ 1/2`, `log (ballVolume N r)` differs from `N · H(δ)` by at most
`log (N+1)`; so the fraction of the `2 ^ N` patterns within `δ N` misfirings of a
given one is `exp(-N (log 2 - H(δ)))` up to a polynomial factor. -/
theorem ballVolume_entropy_sandwich (N r : ℕ) (hr0 : 0 < r) (hr : 2 * r ≤ N) :
    |Real.log (ballVolume N r) - N * Real.binEntropy ((r : ℝ) / N)| ≤ Real.log (N + 1) := by
  have hN : 0 < N := by omega
  have hle := log_ballVolume_le N r hr0 hr
  have hge := log_ballVolume_ge N r hN (by omega)
  have hpos : (0 : ℝ) ≤ Real.log (N + 1) :=
    Real.log_nonneg (by have := Nat.cast_nonneg (α := ℝ) N; linarith)
  rw [abs_le]
  constructor <;> linarith

/-- The sphere-packing bound with the ball volume replaced by its largest layer:
`A(N, 2t+1) * C(N,t) ≤ 2 ^ N`. -/
theorem maxCodeSize_mul_choose_le (N t : ℕ) :
    maxCodeSize N (2 * t + 1) * N.choose t ≤ 2 ^ N :=
  le_trans (Nat.mul_le_mul_left _ (choose_le_ballVolume N t)) (hamming_bound_maxCodeSize N t)

/-- **Sphere-packing bound in entropy form.**  A population of `N` neurons that
corrects `t` misfirings encodes at most `exp (N (log 2 - H(t/N))) * (N+1)`
concepts. -/
theorem log_maxCodeSize_le (N t : ℕ) (hN : 0 < N) (ht : t ≤ N) :
    Real.log (maxCodeSize N (2 * t + 1))
      ≤ N * Real.log 2 - N * Real.binEntropy ((t : ℝ) / N) + Real.log (N + 1) := by
  have hpack : maxCodeSize N (2 * t + 1) * N.choose t ≤ 2 ^ N := maxCodeSize_mul_choose_le N t
  have hApos : (0 : ℝ) < (maxCodeSize N (2 * t + 1) : ℝ) := by
    exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one (one_le_maxCodeSize N (2 * t + 1))
  have hCpos : (0 : ℝ) < (N.choose t : ℝ) := by exact_mod_cast Nat.choose_pos ht
  have hcast : ((maxCodeSize N (2 * t + 1) : ℝ)) * (N.choose t : ℝ) ≤ (2 : ℝ) ^ N := by
    exact_mod_cast hpack
  have hlog := Real.log_le_log (by positivity) hcast
  rw [Real.log_mul (ne_of_gt hApos) (ne_of_gt hCpos), Real.log_pow] at hlog
  have hlow := log_choose_lower N t hN ht
  linarith

/-- **The rate ceiling, in bits per neuron.**  With relative noise tolerance
`δ = t/N`, no `t`-error-correcting neural code beats the rate
`1 - H₂(δ) + log₂(N+1)/N`. -/
theorem sphere_packing_rate_bits (N t : ℕ) (hN : 0 < N) (ht : t ≤ N) :
    Real.logb 2 (maxCodeSize N (2 * t + 1)) / N
      ≤ 1 - Real.binEntropy ((t : ℝ) / N) / Real.log 2 + Real.logb 2 (N + 1) / N := by
  have hN0 : (0 : ℝ) < N := by exact_mod_cast hN
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have h := log_maxCodeSize_le N t hN ht
  rw [Real.logb, Real.logb, div_div, div_div, div_le_iff₀ (by positivity)]
  have hexp : (1 - Real.binEntropy ((t : ℝ) / N) / Real.log 2
        + Real.log (N + 1) / (Real.log 2 * N)) * (Real.log 2 * N)
      = (N : ℝ) * Real.log 2 - N * Real.binEntropy ((t : ℝ) / N) + Real.log (N + 1) := by
    field_simp
  rw [hexp]
  exact h

/-- **Rate sandwich for noise-tolerant neural populations.**  For `δ = t/N` with
`4t ≤ N`, the optimal `t`-error-correcting code on `N` neurons has rate between
`1 - H₂(2δ)` (Gilbert–Varshamov) and `1 - H₂(δ) + log₂(N+1)/N` (sphere packing),
both measured in bits per neuron. -/
theorem neural_rate_sandwich (N t : ℕ) (ht : 1 ≤ t) (htN : 4 * t ≤ N) :
    1 - Real.binEntropy ((2 * t : ℝ) / N) / Real.log 2
        ≤ Real.logb 2 (maxCodeSize N (2 * t + 1)) / N
      ∧ Real.logb 2 (maxCodeSize N (2 * t + 1)) / N
        ≤ 1 - Real.binEntropy ((t : ℝ) / N) / Real.log 2 + Real.logb 2 (N + 1) / N := by
  have hN : 0 < N := by omega
  refine ⟨?_, sphere_packing_rate_bits N t hN (by omega)⟩
  have hgv := gilbert_varshamov_rate_bits N (2 * t + 1) (by omega) (by omega)
  have hcast : ((2 * t + 1 - 1 : ℕ) : ℝ) = (2 * t : ℝ) := by
    have h : 2 * t + 1 - 1 = 2 * t := by omega
    rw [h]; push_cast; ring
  rw [hcast] at hgv
  exact hgv

end NeuralCodeRateCeiling