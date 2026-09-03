import Mathlib
import Bridges.ORDialCap
import Bridges.ORDialMaximum
import Bridges.ORDialMultiPrime
import Bridges.ORDialWashoutInvariance

/-!
# The multi-prime dial: uniform in bit-length, positive in `k`, and washed out by
multiplier randomisation

`Bridges.ORDialMultiPrime` develops the OR dial for `k`-almost primes
(`multiInfo s n` is the channel information for `k = n+1` prime factors) and proves the
uniform cap `Φ_k ≤ orCap`.  This file adds the three laws of the round-48 experiment on
that axis.

* **Uniformity in the ambient class group.**  `multiInfo_comp_surjective`: the multi-prime
  dial, like the semiprime one, only depends on the character quotient the profile factors
  through, so it is unchanged when the class group is inflated (`multiInfo_prod_fst`).
  Proof: convolution commutes with pull-back (`conv_comp_surjective`), hence so does every
  convolution power (`forkPow_comp_surjective`, by induction on the number of factors).

* **Uniformity in the number of prime factors.**  `multiInfo_index_two_pos`: for a
  quadratic-character kernel the dial is *strictly positive for every* `k ≥ 2`, even though
  it decays; combined with `multiInfo_index_two_lt_orCap` this pins the value in
  `(0, orCap]`.  The proof sharpens the entropy tangent bounds to
  `-x log x + x(1-x) ≤ H(x) ≤ -x log x + x`, whose gap `x²` is small enough to leave the
  positive term `2^{-(k+1)} log 2`.

* **Total washout at every `k`.**  `multiInfo_mix_top`: a multiplier-randomised sampler
  reads exactly `0` for every profile and every number of prime factors, while the mean
  rate is unchanged.  `multi_dial_survives_and_washes` puts the two sides together.
-/

open Real Finset

namespace ORDial

/-! ## Part I. Inflation invariance of the multi-prime dial -/

section Inflation

variable {G Q : Type*} [Fintype G] [CommGroup G] [Fintype Q] [CommGroup Q]

/-- Convolution commutes with pull-back along a surjection of class groups. -/
lemma conv_comp_surjective (f : G →* Q) (hf : Function.Surjective f) (t s : Q → ℝ) (c : G) :
    conv (fun a : G => t (f a)) (fun a : G => s (f a)) c = conv t s (f c) := by
  unfold conv
  have hfun : (fun a : G => t (f a) * s (f (c * a⁻¹)))
      = fun a : G => (fun b : Q => t b * s (f c * b⁻¹)) (f a) := by
    funext a
    simp [map_mul, map_inv]
  rw [hfun]
  exact avg_comp_surjective f hf (fun b : Q => t b * s (f c * b⁻¹))

/-- Every convolution power of a pulled-back profile is the pull-back of the corresponding
convolution power. -/
lemma forkPow_comp_surjective (f : G →* Q) (hf : Function.Surjective f) (s : Q → ℝ) :
    ∀ n : ℕ, forkPow (fun a : G => s (f a)) n = fun c : G => forkPow s n (f c) := by
  intro n
  induction n with
  | zero => rfl
  | succ n ih =>
      funext c
      rw [forkPow_succ, ih]
      exact conv_comp_surjective f hf (forkPow s n) s c

/-- **The multi-prime dial is inflation invariant**: for every number of prime factors it
only sees the character quotient. -/
theorem multiInfo_comp_surjective (f : G →* Q) (hf : Function.Surjective f) (s : Q → ℝ)
    (n : ℕ) : multiInfo (fun a : G => s (f a)) n = multiInfo s n := by
  unfold multiInfo
  rw [avg_comp_surjective f hf s]
  congr 1
  have hfun : (fun c : G => Real.binEntropy (forkPow (fun a : G => s (f a)) n c))
      = fun c : G => (fun b : Q => Real.binEntropy (forkPow s n b)) (f c) := by
    funext c
    rw [forkPow_comp_surjective f hf s n]
  rw [hfun]
  exact avg_comp_surjective f hf (fun b : Q => Real.binEntropy (forkPow s n b))

/-- **Bit-length invariance for `k`-almost primes.** -/
theorem multiInfo_prod_fst (s : G → ℝ) (n : ℕ) :
    multiInfo (fun p : G × Q => s p.1) n = multiInfo s n :=
  multiInfo_comp_surjective (MonoidHom.fst G Q) (fun a => ⟨(a, 1), rfl⟩) s n

end Inflation

/-! ## Part II. Washout and strict positivity -/

section Washout

variable {G : Type*} [Fintype G] [CommGroup G]

/-- The convolution powers of a constant profile are constant. -/
lemma forkPow_const (t : ℝ) : ∀ n : ℕ, forkPow (fun _ : G => t) n = fun _ : G => t ^ (n + 1) := by
  intro n
  induction n with
  | zero => funext c; simp
  | succ n ih =>
      funext c
      rw [forkPow_succ, ih]
      unfold conv
      have : (fun a : G => t ^ (n + 1) * t) = fun _ : G => t ^ (n + 2) := by
        funext a; ring
      rw [this, avg_const]

/-- A constant profile carries no multi-prime information either. -/
theorem multiInfo_const (t : ℝ) (n : ℕ) : multiInfo (fun _ : G => t) n = 0 := by
  unfold multiInfo
  rw [forkPow_const t n, avg_const, avg_const]
  ring

/-- **Total washout at every number of prime factors.**  Full multiplier randomisation
sends the `k`-almost-prime dial to exactly `0`, for every `k`. -/
theorem multiInfo_mix_top (s : G → ℝ) (n : ℕ) : multiInfo (mix (⊤ : Subgroup G) s) n = 0 := by
  rw [mix_top s]
  exact multiInfo_const (avg s) n

/-- Sharpened lower tangent bound: `H(x) ≥ -x log x + x(1-x)`. -/
lemma binEntropy_ge_negMulLog_add_mul {x : ℝ} (h1 : x < 1) :
    -(x * Real.log x) + x * (1 - x) ≤ Real.binEntropy x := by
  have hx1 : (0:ℝ) < 1 - x := by linarith
  have hlog : Real.log (1 - x) ≤ -x := by
    have := Real.log_le_sub_one_of_pos hx1
    linarith
  have hb : Real.binEntropy x = -(x * Real.log x) - (1 - x) * Real.log (1 - x) := by
    unfold Real.binEntropy
    rw [Real.log_inv, Real.log_inv]
    ring
  rw [hb]
  nlinarith

/-- **The index-two kernel value stays strictly positive for every number of prime
factors**: `H(2^{-(k)}) - ½ H(2^{-(k-1)}) > 0` for all `k ≥ 2`. -/
lemma kernel_value_pos {n : ℕ} (hn : 1 ≤ n) :
    0 < Real.binEntropy (((1:ℝ)/2)^(n+1)) - (1/2) * Real.binEntropy (((1:ℝ)/2)^n) := by
  set a : ℝ := ((1:ℝ)/2)^n with ha
  have hapos : (0:ℝ) < a := by rw [ha]; positivity
  have hahalf : a ≤ 1/2 := by
    rw [ha]
    calc ((1:ℝ)/2)^n ≤ ((1:ℝ)/2)^1 := pow_le_pow_of_le_one (by norm_num) (by norm_num) hn
      _ = 1/2 := by norm_num
  have hx : ((1:ℝ)/2)^(n+1) = a / 2 := by rw [ha, pow_succ]; ring
  have hxpos : (0:ℝ) < a / 2 := by linarith
  have hxlt : a / 2 < 1 := by linarith
  have hlogx : Real.log (a / 2) = -((n:ℝ) + 1) * Real.log 2 := by
    rw [← hx, Real.log_pow, show ((1:ℝ)/2) = 2⁻¹ by norm_num, Real.log_inv]
    push_cast; ring
  have hloga : Real.log a = -(n:ℝ) * Real.log 2 := by
    rw [ha, Real.log_pow, show ((1:ℝ)/2) = 2⁻¹ by norm_num, Real.log_inv]
    ring
  have hlow := binEntropy_ge_negMulLog_add_mul (x := a / 2) hxlt
  have hup := binEntropy_le_negMulLog_add_self hapos (by linarith : a < 1)
  rw [hlogx] at hlow
  rw [hloga] at hup
  have h2gt : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  rw [hx]
  nlinarith [hlow, hup, hapos, hahalf, h2gt]

/-- **Strict positivity of the multi-prime dial at a quadratic character.**  For every
number `k = n+1 ≥ 2` of prime factors the index-two kernel profile carries strictly
positive information: the dial never dies on the `k` axis, it only decays. -/
theorem multiInfo_index_two_pos (K : Subgroup G) (hK : K.index = 2) {n : ℕ} (hn : 1 ≤ n) :
    0 < multiInfo (subgroupProfile K) n := by
  rw [multiInfo_index_two K hK n]
  exact kernel_value_pos hn

/-- **The multi-prime contrast.**  At every number of prime factors `k ≥ 2` the
quadratic-character channel carries a strictly positive amount of information, its
multiplier-randomised version carries exactly none, and the two profiles have the same
mean rate: the count statistic cannot tell them apart at any `k`. -/
theorem multi_dial_survives_and_washes (K : Subgroup G) (hK : K.index = 2) {n : ℕ}
    (hn : 1 ≤ n) :
    0 < multiInfo (subgroupProfile K) n ∧
      multiInfo (mix (⊤ : Subgroup G) (subgroupProfile K)) n = 0 ∧
      avg (mix (⊤ : Subgroup G) (subgroupProfile K)) = avg (subgroupProfile K) :=
  ⟨multiInfo_index_two_pos K hK hn, multiInfo_mix_top _ n, avg_mix ⊤ (subgroupProfile K)⟩

end Washout

end ORDial