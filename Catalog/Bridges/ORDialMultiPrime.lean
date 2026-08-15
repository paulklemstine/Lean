import Mathlib
import Bridges.ORDialCap
import Bridges.ORDialMaximum

/-!
# The multi-prime OR dial: the cap `g(2)` survives every number of factors

`Bridges.ORDialMaximum` proves the OR-DIAL-MAXIMUM principle for *semiprimes*
`N = p q`: for every class-rate profile the OR channel carries at most
`orCap = H(3/4) - ½H(1/2) = 0.3113` bits.  This file settles the multi-prime
version (Conjecture 1 of the previous cycle): for a `k`-almost prime
`N = p₁ ⋯ p_k` with independent uniform classes, the OR channel obeys the *same*
cap, for every `k ≥ 2`, every profile and every finite abelian class group.

## Main definitions

* `ORDial.conv t s` — the class-group convolution `(t ⋆ s)(c) = avg_a t(a) s(c a⁻¹)`;
  `noFork s = conv s s`.
* `ORDial.forkPow s n` — the no-fork profile of an `(n+1)`-prime product,
  i.e. the `(n+1)`-fold convolution power of `s`.
* `ORDial.multiInfo s n` — the mutual information
  `I(N mod m ; [E(p₁) OR ⋯ OR E(p_{n+1})])` in nats.

## Main results

* `ORDial.avg_forkPow`, `ORDial.forkPow_le_pow` — the multi-prime mean and window laws:
  `avg f_k = μ^k` and `f_k(c) ≤ μ^{k-1}`.
* `ORDial.prodEnt_le_orCap` — the analytic core: `H(μ x) - μ H(x) ≤ orCap` whenever
  `0 ≤ x ≤ μ²`, `0 ≤ μ ≤ 1`.  (For `x = μ` this is the semiprime left branch; the new
  content is the region `μ > 1/2`, handled through the chain-rule identity
  `binEntropy_mul_identity` and three tangent lines of the binary entropy.)
* `ORDial.multiInfo_le_orCap` — **the multi-prime cap**: `Φ_k ≤ orCap` for all `k ≥ 2`.
* `ORDial.multiInfo_subgroupProfile` — the exact multi-prime subgroup law
  `Φ_k = H(n^{-k}) - (1/n) H(n^{-(k-1)})` for the kernel profile of an index-`n` subgroup,
  and `ORDial.multiInfo_index_two` for the quadratic-character kernels.
-/

open Real Finset

namespace ORDial

variable {G : Type*} [Fintype G] [CommGroup G]

/-! ## Convolution on the class group -/

/-- Convolution of two profiles: `(t ⋆ s)(c) = avg_a t(a) s(c a⁻¹)`. -/
noncomputable def conv (t s : G → ℝ) (c : G) : ℝ := avg (fun a => t a * s (c * a⁻¹))

lemma noFork_eq_conv (s : G → ℝ) : noFork s = conv s s := rfl

/-- Convolution is homogeneous in its first argument. -/
lemma conv_const_mul (k : ℝ) (t s : G → ℝ) (c : G) :
    conv (fun a => k * t a) s c = k * conv t s c := by
  have h : ∀ a : G, k * t a * s (c * a⁻¹) = k * (t a * s (c * a⁻¹)) := fun a => by ring
  simp only [conv, avg, h, ← Finset.mul_sum]
  ring

/-- **Mean law for a convolution**: the average of `t ⋆ s` is `avg t · avg s`. -/
lemma avg_conv (t s : G → ℝ) : avg (conv t s) = avg t * avg s := by
  have hn : (0:ℝ) < Fintype.card G := card_pos' (G := G)
  have key : ∑ c : G, ∑ a : G, t a * s (c * a⁻¹) = (∑ a : G, t a) * (∑ b : G, s b) := by
    rw [Finset.sum_comm, Finset.sum_mul]
    refine Finset.sum_congr rfl fun a _ => ?_
    rw [← Finset.mul_sum]
    congr 1
    exact Equiv.sum_comp (Equiv.mulRight a⁻¹) s
  unfold avg conv avg
  rw [← Finset.sum_div, key]
  field_simp

lemma conv_nonneg {t s : G → ℝ} (ht : ∀ a, 0 ≤ t a) (hs : ∀ a, 0 ≤ s a) (c : G) :
    0 ≤ conv t s c := by
  have : avg (fun _ : G => (0:ℝ)) ≤ avg (fun a => t a * s (c * a⁻¹)) :=
    avg_mono (fun a => mul_nonneg (ht a) (hs _))
  rwa [avg_const] at this

/-- **Upper window for a convolution**: `t ⋆ s ≤ avg t` when `0 ≤ t` and `s ≤ 1`. -/
lemma conv_le {t s : G → ℝ} (ht : ∀ a, 0 ≤ t a) (hs1 : ∀ a, s a ≤ 1) (c : G) :
    conv t s c ≤ avg t :=
  avg_mono (fun a => by nlinarith [ht a, hs1 (c * a⁻¹)])

/-! ## Multi-prime no-fork profiles -/

/-- `forkPow s n` is the no-fork profile of an `(n + 1)`-prime product: the
`(n+1)`-fold convolution power of the one-prime profile `s`. -/
noncomputable def forkPow (s : G → ℝ) : ℕ → G → ℝ
  | 0 => s
  | (n + 1) => conv (forkPow s n) s

@[simp] lemma forkPow_zero (s : G → ℝ) : forkPow s 0 = s := rfl

lemma forkPow_succ (s : G → ℝ) (n : ℕ) : forkPow s (n + 1) = conv (forkPow s n) s := rfl

@[simp] lemma forkPow_one (s : G → ℝ) : forkPow s 1 = noFork s := rfl

variable {s : G → ℝ}

lemma forkPow_nonneg (hs0 : ∀ a, 0 ≤ s a) : ∀ (n : ℕ) (c : G), 0 ≤ forkPow s n c := by
  intro n
  induction n with
  | zero => exact hs0
  | succ n ih => exact fun c => conv_nonneg ih hs0 c

/-- **Multi-prime mean law**: `avg f_k = μ^k`. -/
lemma avg_forkPow (s : G → ℝ) : ∀ n : ℕ, avg (forkPow s n) = (avg s) ^ (n + 1) := by
  intro n
  induction n with
  | zero => simp
  | succ n ih => rw [forkPow_succ, avg_conv, ih]; ring

/-- **Multi-prime window law**: a `k`-prime conditional no-fork probability never exceeds
`μ^{k-1}`. -/
lemma forkPow_le_pow (hs0 : ∀ a, 0 ≤ s a) (hs1 : ∀ a, s a ≤ 1) (n : ℕ) (c : G) :
    forkPow s (n + 1) c ≤ (avg s) ^ (n + 1) := by
  rw [forkPow_succ]
  calc conv (forkPow s n) s c ≤ avg (forkPow s n) := conv_le (forkPow_nonneg hs0 n) hs1 c
    _ = (avg s) ^ (n + 1) := avg_forkPow s n

lemma forkPow_le_one (hs0 : ∀ a, 0 ≤ s a) (hs1 : ∀ a, s a ≤ 1) :
    ∀ (n : ℕ) (c : G), forkPow s n c ≤ 1 := by
  intro n
  cases n with
  | zero => exact hs1
  | succ n =>
      intro c
      refine (forkPow_le_pow hs0 hs1 n c).trans ?_
      exact pow_le_one₀ (avg_nonneg hs0) (avg_le_one hs1)

/-- The multi-prime OR-channel information `I(N mod m ; OR_i E(p_i))` for `n + 1` prime
factors, in nats. -/
noncomputable def multiInfo (s : G → ℝ) (n : ℕ) : ℝ :=
  Real.binEntropy ((avg s) ^ (n + 1)) - avg (fun c => Real.binEntropy (forkPow s n c))

/-- For two prime factors the multi-prime channel is the semiprime OR channel. -/
lemma multiInfo_one (s : G → ℝ) : multiInfo s 1 = orInfo s := by
  unfold multiInfo orInfo
  norm_num

/-! ## The analytic core: `H(μ x) - μ H(x) ≤ orCap` for `x ≤ μ²`

The chord bound turns the multi-prime window law into the one-parameter family of
estimates `Φ_k ≤ H(μ^k) - μ H(μ^{k-1})`.  Writing `x = μ^{k-1}` (so `x ≤ μ²` as soon as
`k ≥ 3`), the whole multi-prime problem collapses to the two-variable inequality
`H(μ x) - μ H(x) ≤ orCap`, proved here. -/

/-- Tangent line of `binEntropy` at `2/3`, in cleared form. -/
lemma binEntropy_tangent_two_thirds {m : ℝ} (h0 : 0 < m) (h1 : m < 1) :
    Real.binEntropy m ≤ Real.log 3 - m * Real.log 2 := by
  have hA := log_tangent (2/3) m (by norm_num) h0
  have hB := log_tangent (1/3) (1 - m) (by norm_num) (by linarith)
  have h23 : Real.log (2/3) = Real.log 2 - Real.log 3 := by
    rw [Real.log_div (by norm_num) (by norm_num)]
  have h13 : Real.log (1/3) = -Real.log 3 := by
    rw [Real.log_div (by norm_num) (by norm_num), Real.log_one]; ring
  rw [h23] at hA
  rw [h13] at hB
  rw [binEntropy_eq']
  nlinarith [hA, hB]

/-- Tangent line of `binEntropy` at `3/4`. -/
lemma binEntropy_tangent_three_quarters {m : ℝ} (h0 : 0 < m) (h1 : m < 1) :
    Real.binEntropy m ≤ 2 * Real.log 2 - m * Real.log 3 := by
  have hA := log_tangent (3/4) m (by norm_num) h0
  have hB := log_tangent (1/4) (1 - m) (by norm_num) (by linarith)
  have h34 : Real.log (3/4) = Real.log 3 - 2 * Real.log 2 := by
    rw [Real.log_div (by norm_num) (by norm_num), show (4:ℝ) = 2^2 by norm_num, Real.log_pow]
    push_cast; ring
  have h14 : Real.log (1/4) = -(2 * Real.log 2) := by
    rw [Real.log_div (by norm_num) (by norm_num), Real.log_one,
      show (4:ℝ) = 2^2 by norm_num, Real.log_pow]
    push_cast; ring
  rw [h34] at hA
  rw [h14] at hB
  rw [binEntropy_eq']
  nlinarith [hA, hB]

/-- Tangent line of `binEntropy` at `8/9`. -/
lemma binEntropy_tangent_eight_ninths {m : ℝ} (h0 : 0 < m) (h1 : m < 1) :
    Real.binEntropy m ≤ 2 * Real.log 3 - 3 * m * Real.log 2 := by
  have hA := log_tangent (8/9) m (by norm_num) h0
  have hB := log_tangent (1/9) (1 - m) (by norm_num) (by linarith)
  have h89 : Real.log (8/9) = 3 * Real.log 2 - 2 * Real.log 3 := by
    rw [Real.log_div (by norm_num) (by norm_num), show (8:ℝ) = 2^3 by norm_num,
      show (9:ℝ) = 3^2 by norm_num, Real.log_pow, Real.log_pow]
    push_cast; ring
  have h19 : Real.log (1/9) = -(2 * Real.log 3) := by
    rw [Real.log_div (by norm_num) (by norm_num), Real.log_one,
      show (9:ℝ) = 3^2 by norm_num, Real.log_pow]
    push_cast; ring
  rw [h89] at hA
  rw [h19] at hB
  rw [binEntropy_eq']
  nlinarith [hA, hB]

/-- `log 3 > 1.098572`, from `2^84 < 3^53`. -/
lemma log_three_gt_num : (1.098572 : ℝ) < Real.log 3 := by
  have h : ((2:ℝ))^(84:ℕ) < ((3:ℝ))^(53:ℕ) := by norm_num
  have hlt := Real.log_lt_log (by positivity) h
  rw [Real.log_pow, Real.log_pow] at hlt
  have h2 := Real.log_two_gt_d9
  push_cast at hlt
  linarith

/-- `log 3 < 1.098892`, from `3^41 < 2^65`. -/
lemma log_three_lt_num : Real.log 3 < (1.098892 : ℝ) := by
  have h : ((3:ℝ))^(41:ℕ) < ((2:ℝ))^(65:ℕ) := by norm_num
  have hlt := Real.log_lt_log (by positivity) h
  rw [Real.log_pow, Real.log_pow] at hlt
  have h2 := Real.log_two_lt_d9
  push_cast at hlt
  linarith

lemma binEntropy_two_thirds : Real.binEntropy ((2:ℝ)/3) = Real.log 3 - (2/3) * Real.log 2 := by
  have h23 : Real.log (2/3) = Real.log 2 - Real.log 3 := by
    rw [Real.log_div (by norm_num) (by norm_num)]
  have h13 : Real.log (1 - (2:ℝ)/3) = -Real.log 3 := by
    rw [show (1:ℝ) - 2/3 = 3⁻¹ by norm_num, Real.log_inv]
  rw [binEntropy_eq', h13, h23]
  ring

/-- On `[1/3, 2/3]` the binary entropy is at least its (common) endpoint value. -/
lemma binEntropy_ge_of_mem_third {y : ℝ} (h1 : 1/3 ≤ y) (h2 : y ≤ 2/3) :
    Real.log 3 - (2/3) * Real.log 2 ≤ Real.binEntropy y := by
  rcases le_total y (1/2) with h | h
  · have hmono := Real.binEntropy_strictMonoOn.monotoneOn
      (a := (1:ℝ)/3) (b := y) (by constructor <;> norm_num)
      (by constructor <;> [linarith; simpa using h]) h1
    have h13 : Real.binEntropy ((1:ℝ)/3) = Real.binEntropy ((2:ℝ)/3) := by
      rw [show ((1:ℝ)/3) = 1 - 2/3 by norm_num, Real.binEntropy_one_sub]
    rw [h13, binEntropy_two_thirds] at hmono
    exact hmono
  · have hanti := Real.binEntropy_strictAntiOn.antitoneOn
      (a := y) (b := (2:ℝ)/3) (by constructor <;> [simpa using h; linarith])
      (by constructor <;> norm_num) h2
    rw [binEntropy_two_thirds] at hanti
    exact hanti

/-- **Chain rule for the binary entropy of a product.**  If `X, Y` are independent
Bernoulli variables with parameters `p, q`, then `H(XY) = H(X) + H(Y|X) - H(X|XY)`; the
last term is the correction computed here. -/
lemma binEntropy_mul_identity {p q : ℝ} (hp0 : 0 < p) (hp1 : p < 1) (hq0 : 0 < q) (hq1 : q < 1) :
    Real.binEntropy (p * q) = Real.binEntropy p + p * Real.binEntropy q
      - (1 - p * q) * Real.binEntropy (p * (1 - q) / (1 - p * q)) := by
  have hpq : 0 < 1 - p * q := by nlinarith
  have h1q : 0 < 1 - q := by linarith
  have h1p : 0 < 1 - p := by linarith
  have hy1 : 1 - p * (1 - q) / (1 - p * q) = (1 - p) / (1 - p * q) := by
    field_simp; ring
  have hlogy : Real.log (p * (1 - q) / (1 - p * q))
      = Real.log p + Real.log (1 - q) - Real.log (1 - p * q) := by
    rw [Real.log_div (by positivity) (ne_of_gt hpq), Real.log_mul (ne_of_gt hp0) (ne_of_gt h1q)]
  have hlog1y : Real.log ((1 - p) / (1 - p * q))
      = Real.log (1 - p) - Real.log (1 - p * q) := by
    rw [Real.log_div (ne_of_gt h1p) (ne_of_gt hpq)]
  rw [binEntropy_eq' (p * q), binEntropy_eq' p, binEntropy_eq' q,
    binEntropy_eq' (p * (1 - q) / (1 - p * q)), hy1, hlogy, hlog1y,
    Real.log_mul (ne_of_gt hp0) (ne_of_gt hq0)]
  field_simp
  ring

/-- The numeric heart of the multi-prime cap: on `[1/2, 1]` the binary entropy stays below
the cap plus the entropy deficit `(1 - m³)·H(2/3)`.  Proved from three tangent lines of
`binEntropy` (at `2/3`, `3/4`, `8/9`), the chord bound for the cubic, and explicit numeric
bounds for `log 2` and `log 3`. -/
lemma entropy_le_cap_add {m : ℝ} (h0 : 1/2 ≤ m) (h1 : m ≤ 1) :
    Real.binEntropy m ≤ orCap - 1/500 + (1 - m^3) * (Real.log 3 - (2/3) * Real.log 2) := by
  rcases eq_or_lt_of_le h1 with he | hlt
  · rw [he]
    simp only [Real.binEntropy_one, one_pow, sub_self, zero_mul, add_zero]
    linarith [orCap_gt]
  have hm0 : 0 < m := by linarith
  have h2gt := Real.log_two_gt_d9
  have h2lt := Real.log_two_lt_d9
  have h3gt := log_three_gt_num
  have h3lt := log_three_lt_num
  rw [orCap_eq]
  rcases le_total m (7/10) with hc1 | hc1
  · have tangent23 := binEntropy_tangent_two_thirds hm0 hlt
    have hcube : m^3 ≤ (1/2)^3 + (m - 1/2) * ((1/2)^2 + (1/2)*(7/10) + (7/10)^2) := by
      nlinarith [mul_nonneg (mul_nonneg (by linarith : (0:ℝ) ≤ m - 1/2)
        (by linarith : (0:ℝ) ≤ 7/10 - m)) (by linarith : (0:ℝ) ≤ m + 1/2 + 7/10)]
    nlinarith [tangent23, hcube, h2gt, h3lt, h2lt, h3gt]
  · rcases le_total m (17/20) with hc2 | hc2
    · have tangent34 := binEntropy_tangent_three_quarters hm0 hlt
      have hcube : m^3 ≤ (7/10)^3 + (m - 7/10) * ((7/10)^2 + (7/10)*(17/20) + (17/20)^2) := by
        nlinarith [mul_nonneg (mul_nonneg (by linarith : (0:ℝ) ≤ m - 7/10)
          (by linarith : (0:ℝ) ≤ 17/20 - m)) (by linarith : (0:ℝ) ≤ m + 7/10 + 17/20)]
      nlinarith [tangent34, hcube, h2gt, h3lt, h2lt, h3gt]
    · have tangent89 := binEntropy_tangent_eight_ninths hm0 hlt
      have hcube : m^3 ≤ (17/20)^3 + (m - 17/20) * ((17/20)^2 + (17/20)*1 + 1) := by
        nlinarith [mul_nonneg (mul_nonneg (by linarith : (0:ℝ) ≤ m - 17/20)
          (by linarith : (0:ℝ) ≤ 1 - m)) (by linarith : (0:ℝ) ≤ m + 17/20 + 1)]
      nlinarith [tangent89, hcube, h2gt, h3lt, h2lt, h3gt]

/-- `H(x) ≤ x log(1/x) + x`: the second entropy term is at most `x`. -/
lemma binEntropy_le_negMulLog_add_self {x : ℝ} (h0 : 0 < x) (h1 : x < 1) :
    Real.binEntropy x ≤ -(x * Real.log x) + x := by
  have hne : (1:ℝ) - x ≠ 0 := by linarith
  have hlog : -Real.log (1 - x) ≤ x / (1 - x) := by
    have h := Real.log_le_sub_one_of_pos (inv_pos.mpr (show (0:ℝ) < 1 - x by linarith))
    rw [Real.log_inv] at h
    have he : (1 - x)⁻¹ - 1 = x / (1 - x) := by field_simp; ring
    linarith [he ▸ h]
  have hx : (1 - x) * (-Real.log (1 - x)) ≤ x := by
    have hm := mul_le_mul_of_nonneg_left hlog (by linarith : (0:ℝ) ≤ 1 - x)
    calc (1 - x) * (-Real.log (1 - x)) ≤ (1 - x) * (x / (1 - x)) := hm
      _ = x := by field_simp
  rw [binEntropy_eq']
  linarith

/-- `x log(1/x) ≤ H(x)`: the second entropy term is nonnegative. -/
lemma negMulLog_le_binEntropy {x : ℝ} (h0 : 0 ≤ x) (h1 : x ≤ 1) :
    -(x * Real.log x) ≤ Real.binEntropy x := by
  rcases eq_or_lt_of_le h1 with he | hlt
  · rw [he]; simp
  have hnn : 0 ≤ -((1 - x) * Real.log (1 - x)) := by
    rcases eq_or_lt_of_le h0 with hz | hpos
    · rw [← hz]; simp
    have hle : Real.log (1 - x) ≤ 0 := Real.log_nonpos (by linarith) (by linarith)
    nlinarith
  rw [binEntropy_eq']
  linarith

/-- Derivative of `x ↦ H(μ x) - μ H(x)`. -/
lemma hasDerivAt_prodEnt {mu x : ℝ} (hmu0 : 0 < mu) (hmu1 : mu < 1)
    (hx0 : 0 < x) (hx1 : x < 1) :
    HasDerivAt (fun t => Real.binEntropy (mu * t) - mu * Real.binEntropy t)
      (mu * (Real.log (1 - mu*x) - Real.log (mu*x)) - mu * (Real.log (1-x) - Real.log x)) x := by
  have h1 : HasDerivAt (fun t : ℝ => mu * t) mu x := by
    simpa using (hasDerivAt_id x).const_mul mu
  have h2 : HasDerivAt Real.binEntropy (Real.log (1 - mu*x) - Real.log (mu*x)) (mu * x) :=
    Real.hasDerivAt_binEntropy (by positivity) (by nlinarith)
  have h3 := h2.comp x h1
  have h4 : HasDerivAt (fun t => mu * Real.binEntropy t) (mu * (Real.log (1-x) - Real.log x)) x :=
    (Real.hasDerivAt_binEntropy (ne_of_gt hx0) (by linarith)).const_mul mu
  have h5 := h3.sub h4
  convert h5 using 1
  ring

/-- `x ↦ H(μ x) - μ H(x)` is nondecreasing on `[0,1]`: the derivative is
`μ log((1-μx)/(μ(1-x))) ≥ 0` precisely because `μ ≤ 1`. -/
lemma prodEnt_monotoneOn {mu : ℝ} (hmu0 : 0 ≤ mu) (hmu1 : mu ≤ 1) :
    MonotoneOn (fun x => Real.binEntropy (mu * x) - mu * Real.binEntropy x) (Set.Icc 0 1) := by
  rcases eq_or_lt_of_le hmu0 with h | hpos
  · intro a _ b _ _
    simp [← h]
  rcases eq_or_lt_of_le hmu1 with h | hlt
  · intro a _ b _ _
    simp [h]
  apply monotoneOn_of_deriv_nonneg (convex_Icc 0 1)
  · fun_prop
  · rw [interior_Icc]
    intro x hx
    obtain ⟨hx0, hx1⟩ := hx
    exact ((Real.differentiableAt_binEntropy (ne_of_gt (mul_pos hpos hx0))
      (by nlinarith)).comp x (by fun_prop)).sub
      ((Real.differentiableAt_binEntropy (ne_of_gt hx0)
        (by linarith)).const_mul mu) |>.differentiableWithinAt
  · rw [interior_Icc]
    intro x hx
    obtain ⟨hx0, hx1⟩ := hx
    rw [(hasDerivAt_prodEnt hpos hlt hx0 hx1).deriv]
    have hkey : Real.log (mu * (1 - x)) ≤ Real.log (1 - mu * x) := by
      apply Real.log_le_log (mul_pos hpos (by linarith))
      nlinarith
    rw [Real.log_mul (ne_of_gt hpos) (by linarith)] at hkey
    nlinarith [hkey, Real.log_mul (ne_of_gt hpos) (ne_of_gt hx0)]

/-- The three-prime instance of the analytic core: `H(μ³) - μ H(μ²) ≤ orCap` on `[1/2,1]`.
This is where the chain-rule identity and the tangent estimates are combined. -/
lemma prodEnt_cube_le_orCap {mu : ℝ} (h0 : 1/2 ≤ mu) (h1 : mu ≤ 1) :
    Real.binEntropy (mu * mu^2) - mu * Real.binEntropy (mu^2) ≤ orCap - 1/500 := by
  rcases eq_or_lt_of_le h1 with he | hlt
  · rw [he]
    norm_num
    linarith [orCap_gt]
  have hmu0 : 0 < mu := by linarith
  have hq0 : 0 < mu^2 := by positivity
  have hq1 : mu^2 < 1 := by nlinarith
  have hden : 0 < 1 - mu * mu^2 := by nlinarith
  have hid := binEntropy_mul_identity hmu0 hlt hq0 hq1
  have hy1 : 1/3 ≤ mu * (1 - mu^2) / (1 - mu * mu^2) := by
    rw [le_div_iff₀ hden]; nlinarith
  have hy2 : mu * (1 - mu^2) / (1 - mu * mu^2) ≤ 2/3 := by
    rw [div_le_iff₀ hden]; nlinarith
  have hHy := binEntropy_ge_of_mem_third hy1 hy2
  have hcap : Real.binEntropy mu
      ≤ orCap - 1/500 + (1 - mu * mu^2) * (Real.log 3 - (2/3) * Real.log 2) := by
    rw [show (1:ℝ) - mu * mu^2 = 1 - mu^3 by ring]
    exact entropy_le_cap_add h0 h1
  have hmul : (1 - mu * mu^2) * (Real.log 3 - (2/3) * Real.log 2)
      ≤ (1 - mu * mu^2) * Real.binEntropy (mu * (1 - mu^2) / (1 - mu * mu^2)) :=
    mul_le_mul_of_nonneg_left hHy hden.le
  rw [hid]
  linarith

/-- Small-mean branch of the analytic core, with an explicit gap: for `μ ≤ 1/2` and
`x ≤ μ²` one has `H(μx) - μH(x) ≤ μ³(1 - log μ) ≤ (1 + log 2)/8 < orCap`. -/
lemma prodEnt_small_mean_le {mu x : ℝ} (hmu0 : 0 ≤ mu) (hmu : mu ≤ 1/2) (hx0 : 0 ≤ x)
    (hx : x ≤ mu^2) : Real.binEntropy (mu * x) - mu * Real.binEntropy x ≤ orCap - 1/500 := by
  have h2gt := Real.log_two_gt_d9
  have h2lt := Real.log_two_lt_d9
  have h3lt := log_three_lt_num
  have hcapval : orCap = 3/2 * Real.log 2 - 3/4 * Real.log 3 := orCap_eq
  rcases eq_or_lt_of_le hx0 with hxz | hxpos
  · rw [← hxz]
    simp only [mul_zero, Real.binEntropy_zero, mul_zero, sub_zero]
    rw [hcapval]; linarith
  rcases eq_or_lt_of_le hmu0 with hmz | hmpos
  · rw [← hmz]
    simp only [zero_mul, Real.binEntropy_zero, zero_mul, sub_zero]
    rw [hcapval]; linarith
  have hxlt1 : x ≤ 1 := by nlinarith
  have hprod0 : 0 < mu * x := mul_pos hmpos hxpos
  have hprod1 : mu * x < 1 := by nlinarith
  have hupper := binEntropy_le_negMulLog_add_self hprod0 hprod1
  have hlower := negMulLog_le_binEntropy hx0 hxlt1
  rw [Real.log_mul (ne_of_gt hmpos) (ne_of_gt hxpos)] at hupper
  -- `H(μx) - μH(x) ≤ μ x (1 - log μ)`
  have hstep : Real.binEntropy (mu * x) - mu * Real.binEntropy x
      ≤ mu * x * (1 - Real.log mu) := by nlinarith [hupper, hlower]
  -- bound `-log μ ≤ log 2 + 1/(2μ) - 1`
  have hlogmu : -Real.log mu ≤ Real.log 2 + 1/(2*mu) - 1 := by
    have h := Real.log_le_sub_one_of_pos (show (0:ℝ) < 1/(2*mu) by positivity)
    rw [show (1:ℝ)/(2*mu) = (2*mu)⁻¹ by ring, Real.log_inv,
      Real.log_mul (by norm_num) (ne_of_gt hmpos)] at h
    have he : (2*mu)⁻¹ = 1/(2*mu) := by ring
    rw [he] at h
    linarith
  have hxmu : mu * x * (1 - Real.log mu) ≤ mu^3 * Real.log 2 + mu^2 / 2 := by
    have hcoef : 0 < 1 - Real.log mu := by
      have : Real.log mu < 0 := Real.log_neg hmpos (by linarith)
      linarith
    have h1 : mu * x * (1 - Real.log mu) ≤ mu * mu^2 * (1 - Real.log mu) := by
      apply mul_le_mul_of_nonneg_right _ hcoef.le
      nlinarith
    have h2 : mu * mu^2 * (1 - Real.log mu) ≤ mu^3 * Real.log 2 + mu^2 / 2 := by
      have hmu3 : (0:ℝ) ≤ mu^3 := by positivity
      have := mul_le_mul_of_nonneg_left hlogmu hmu3
      have hfield : mu^3 * (1/(2*mu)) = mu^2/2 := by field_simp
      nlinarith [this, hfield]
    linarith
  have hsmall3 : mu^3 ≤ 1/8 := by nlinarith
  have hsmall2 : mu^2 ≤ 1/4 := by nlinarith
  rw [hcapval]
  nlinarith [hstep, hxmu, hsmall3, hsmall2]

/-- **The analytic core of the multi-prime cap, with a gap.**  For `0 ≤ x ≤ μ²` and
`0 ≤ μ ≤ 1`, `H(μ x) - μ H(x) ≤ orCap - 1/500`: three or more prime factors always leave a
uniform deficit below the semiprime cap. -/
theorem prodEnt_le_orCap_sub {mu x : ℝ} (hmu0 : 0 ≤ mu) (hmu1 : mu ≤ 1) (hx0 : 0 ≤ x)
    (hx : x ≤ mu^2) : Real.binEntropy (mu * x) - mu * Real.binEntropy x ≤ orCap - 1/500 := by
  rcases le_total mu (1/2) with hcase | hcase
  · exact prodEnt_small_mean_le hmu0 hcase hx0 hx
  · have hx1 : x ≤ 1 := by nlinarith
    have hstep : Real.binEntropy (mu * x) - mu * Real.binEntropy x
        ≤ Real.binEntropy (mu * mu^2) - mu * Real.binEntropy (mu^2) :=
      prodEnt_monotoneOn hmu0 hmu1 (Set.mem_Icc.mpr ⟨hx0, hx1⟩)
        (Set.mem_Icc.mpr ⟨by positivity, by nlinarith⟩) hx
    exact le_trans hstep (prodEnt_cube_le_orCap hcase hmu1)

/-- The analytic core in its plain form. -/
theorem prodEnt_le_orCap {mu x : ℝ} (hmu0 : 0 ≤ mu) (hmu1 : mu ≤ 1) (hx0 : 0 ≤ x)
    (hx : x ≤ mu^2) : Real.binEntropy (mu * x) - mu * Real.binEntropy x ≤ orCap := by
  linarith [prodEnt_le_orCap_sub hmu0 hmu1 hx0 hx]

/-! ## The multi-prime cap -/

/-- The chord bound applied to the multi-prime window law: with `μ = avg s`, the `(k+2)`-prime
channel is bounded by the one-dimensional quantity `H(μ·μ^{k+1}) - μ H(μ^{k+1})`. -/
lemma multiInfo_le_prodEnt (hs0 : ∀ a, 0 ≤ s a) (hs1 : ∀ a, s a ≤ 1) (k : ℕ) :
    multiInfo s (k+1)
      ≤ Real.binEntropy (avg s * (avg s)^(k+1)) - avg s * Real.binEntropy ((avg s)^(k+1)) := by
  have hm0 : 0 ≤ avg s := avg_nonneg hs0
  have hm1 : avg s ≤ 1 := avg_le_one hs1
  rcases eq_or_lt_of_le hm0 with hzero | hpos
  · have hf : ∀ c : G, forkPow s (k+1) c = 0 := by
      intro c
      refine le_antisymm ?_ (forkPow_nonneg hs0 _ c)
      have hle := forkPow_le_pow hs0 hs1 k c
      rw [← hzero] at hle
      simpa using hle
    have hpow : (avg s) ^ (k + 1 + 1) = 0 := by rw [← hzero]; simp
    have hpow' : (avg s) ^ (k + 1) = 0 := by rw [← hzero]; simp
    unfold multiInfo
    rw [hpow, hpow']
    simp only [hf, Real.binEntropy_zero, avg_const, sub_zero, mul_zero, ← hzero]
    norm_num
  · set m : ℝ := avg s with hm
    have hU0 : 0 < m ^ (k+1) := by positivity
    have hU1 : m ^ (k+1) ≤ 1 := pow_le_one₀ hm0 hm1
    have hchord : ∀ c : G, 0 + (Real.binEntropy (m^(k+1)) / m^(k+1)) * forkPow s (k+1) c
        ≤ Real.binEntropy (forkPow s (k+1) c) := by
      intro c
      have h := binEntropy_chord (L := 0) (U := m^(k+1)) (x := forkPow s (k+1) c) le_rfl hU1 hU0
        (forkPow_nonneg hs0 _ c) (forkPow_le_pow hs0 hs1 k c)
      simp only [Real.binEntropy_zero, sub_zero, mul_zero, zero_add] at h
      calc 0 + Real.binEntropy (m^(k+1)) / m^(k+1) * forkPow s (k+1) c
          = (forkPow s (k+1) c * Real.binEntropy (m^(k+1))) / m^(k+1) := by field_simp; ring
        _ ≤ Real.binEntropy (forkPow s (k+1) c) := h
    have havg : m * Real.binEntropy (m^(k+1))
        ≤ avg (fun c => Real.binEntropy (forkPow s (k+1) c)) := by
      have h1 : avg (fun c => 0 + (Real.binEntropy (m^(k+1)) / m^(k+1)) * forkPow s (k+1) c)
          ≤ avg (fun c => Real.binEntropy (forkPow s (k+1) c)) := avg_mono hchord
      rw [avg_affine, avg_forkPow, ← hm] at h1
      have hid : (Real.binEntropy (m^(k+1)) / m^(k+1)) * m ^ (k + 1 + 1)
          = m * Real.binEntropy (m^(k+1)) := by field_simp; ring
      rwa [hid, zero_add] at h1
    have hmul : m * m ^ (k+1) = m ^ (k + 1 + 1) := by ring
    unfold multiInfo
    rw [hmul]
    linarith

/-- **Quantitative strictness for three or more prime factors.**  Beyond semiprimes the
dial cannot even approach the cap: it is bounded by `orCap - 1/500` uniformly in the
profile, the class group and the number of factors. -/
theorem multiInfo_le_orCap_sub (hs0 : ∀ a, 0 ≤ s a) (hs1 : ∀ a, s a ≤ 1) {n : ℕ}
    (hn : 2 ≤ n) : multiInfo s n ≤ orCap - 1/500 := by
  have hm0 : 0 ≤ avg s := avg_nonneg hs0
  have hm1 : avg s ≤ 1 := avg_le_one hs1
  obtain ⟨k, hk⟩ : ∃ k, n = k + 1 := ⟨n - 1, by omega⟩
  subst hk
  have hbound := multiInfo_le_prodEnt hs0 hs1 k
  have hxle : (avg s) ^ (k+1) ≤ (avg s) ^ 2 := pow_le_pow_of_le_one hm0 hm1 (by omega)
  have hkey := prodEnt_le_orCap_sub (mu := avg s) (x := (avg s)^(k+1)) hm0 hm1
    (by positivity) hxle
  linarith

/-- **MULTI-PRIME OR-DIAL MAXIMUM.**  For every finite abelian class group, every profile
and every number `k = n + 1 ≥ 2` of prime factors, the OR channel of a `k`-almost prime
carries at most `orCap = H(3/4) - ½H(1/2) = 0.3113` bits: the semiprime cap is a cap for
all `k`. -/
theorem multiInfo_le_orCap (hs0 : ∀ a, 0 ≤ s a) (hs1 : ∀ a, s a ≤ 1) {n : ℕ} (hn : 1 ≤ n) :
    multiInfo s n ≤ orCap := by
  rcases Nat.lt_or_ge n 2 with hn2 | hn2
  · have hn1 : n = 1 := by omega
    subst hn1
    rw [multiInfo_one]
    exact orInfo_le_orCap hs0 hs1
  · linarith [multiInfo_le_orCap_sub hs0 hs1 hn2]

/-- The dial of a `k`-almost prime with `k ≥ 3` is strictly below the semiprime cap. -/
theorem multiInfo_lt_orCap (hs0 : ∀ a, 0 ≤ s a) (hs1 : ∀ a, s a ≤ 1) {n : ℕ} (hn : 2 ≤ n) :
    multiInfo s n < orCap := by
  have := multiInfo_le_orCap_sub hs0 hs1 hn
  linarith

/-! ## The multi-prime subgroup law -/

/-- Convolution powers of a subgroup-kernel profile stay proportional to the kernel. -/
lemma forkPow_subgroupProfile (K : Subgroup G) (n : ℕ) :
    forkPow (subgroupProfile K) n = fun c => (1 / (K.index:ℝ))^n * subgroupProfile K c := by
  induction n with
  | zero => funext c; simp
  | succ n ih =>
      funext c
      rw [forkPow_succ, ih, conv_const_mul, ← noFork_eq_conv, noFork_subgroupProfile,
        avg_subgroupProfile]
      ring

/-- **The multi-prime subgroup law.**  For the kernel profile of a subgroup of index `d`
and `k = n+1` prime factors, `Φ_k = H(d^{-k}) - (1/d) H(d^{-(k-1)})` exactly. -/
theorem multiInfo_subgroupProfile (K : Subgroup G) (n : ℕ) :
    multiInfo (subgroupProfile K) n
      = Real.binEntropy ((1 / (K.index:ℝ))^(n+1))
        - (1 / (K.index:ℝ)) * Real.binEntropy ((1 / (K.index:ℝ))^n) := by
  classical
  have hmean := avg_subgroupProfile K
  have hpt : ∀ c : G, Real.binEntropy (forkPow (subgroupProfile K) n c)
      = 0 + (Real.binEntropy ((1 / (K.index:ℝ))^n)) * subgroupProfile K c := by
    intro c
    rw [forkPow_subgroupProfile]
    unfold subgroupProfile
    by_cases hc : c ∈ K <;> simp [hc]
  unfold multiInfo
  rw [hmean]
  have hsum : avg (fun c => Real.binEntropy (forkPow (subgroupProfile K) n c))
      = (1 / (K.index:ℝ)) * Real.binEntropy ((1 / (K.index:ℝ))^n) := by
    simp only [hpt]
    rw [avg_affine, hmean]
    ring
  rw [hsum]

/-- The quadratic-character (index two) kernels: with `k = n+1` prime factors the dial
reads `H(2^{-k}) - ½ H(2^{-(k-1)})`, which is `orCap` when `k = 2` and strictly smaller
afterwards. -/
theorem multiInfo_index_two (K : Subgroup G) (h : K.index = 2) (n : ℕ) :
    multiInfo (subgroupProfile K) n
      = Real.binEntropy (((1:ℝ)/2)^(n+1)) - (1/2) * Real.binEntropy (((1:ℝ)/2)^n) := by
  rw [multiInfo_subgroupProfile, h]
  norm_num

/-- With `k = n+1 ≥ 3` prime factors the index-two kernel value
`H(2^{-k}) - ½H(2^{-(k-1)}) ≤ (1 + log 2) 2^{-k}` is strictly below the cap. -/
lemma kernel_value_lt_orCap {n : ℕ} (hn : 2 ≤ n) :
    Real.binEntropy (((1:ℝ)/2)^(n+1)) - (1/2) * Real.binEntropy (((1:ℝ)/2)^n)
      < orCap := by
  set a : ℝ := ((1:ℝ)/2)^n with ha
  have hapos : (0:ℝ) < a := by rw [ha]; positivity
  have halt : a ≤ 1/4 := by
    rw [ha]
    calc ((1:ℝ)/2)^n ≤ ((1:ℝ)/2)^2 := pow_le_pow_of_le_one (by norm_num) (by norm_num) hn
      _ = 1/4 := by norm_num
  have hx : ((1:ℝ)/2)^(n+1) = a / 2 := by rw [ha, pow_succ]; ring
  have hxpos : (0:ℝ) < a / 2 := by linarith
  have hxlt : a / 2 < 1 := by linarith
  have hlogx : Real.log (a / 2) = -((n:ℝ) + 1) * Real.log 2 := by
    rw [← hx, Real.log_pow, show ((1:ℝ)/2) = 2⁻¹ by norm_num, Real.log_inv]
    push_cast; ring
  have hloga : Real.log a = -(n:ℝ) * Real.log 2 := by
    rw [ha, Real.log_pow, show ((1:ℝ)/2) = 2⁻¹ by norm_num, Real.log_inv]
    ring
  have hupper := binEntropy_le_negMulLog_add_self hxpos hxlt
  have hlower := negMulLog_le_binEntropy hapos.le (by linarith)
  rw [hlogx] at hupper
  rw [hloga] at hlower
  have h2pos : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hkey : Real.binEntropy (a/2) - (1/2) * Real.binEntropy a
      ≤ (a * Real.log 2) / 2 + a / 2 := by nlinarith [hupper, hlower]
  have hbound : a * Real.log 2 ≤ (1/4) * Real.log 2 :=
    mul_le_mul_of_nonneg_right halt h2pos.le
  have h2gt := Real.log_two_gt_d9
  have h2lt := Real.log_two_lt_d9
  have h3lt := log_three_lt_num
  rw [hx, orCap_eq]
  linarith

/-- **Strict decay for three or more factors.**  A quadratic-character kernel attains the
cap only for semiprimes: with `k = n+1 ≥ 3` prime factors it lies strictly below `orCap`. -/
theorem multiInfo_index_two_lt_orCap (K : Subgroup G) (h : K.index = 2) {n : ℕ} (hn : 2 ≤ n) :
    multiInfo (subgroupProfile K) n < orCap := by
  rw [multiInfo_index_two K h n]
  exact kernel_value_lt_orCap hn

end ORDial