/-
# The two bracketing degrees of the binomial weights, explicitly

Companion to `Shared.UnimodalArgmaxBracketing`.  There the abstract theory was set
up: a strictly log-concave positive window `a 0, …, a n` is strictly unimodal and
its maximiser set is the interval `[firstArgmax, lastArgmax]` between the two
bracketing degrees, whose gap is `0` or `1`.

Here the abstract machine is run on the **binomial weights**

`binomialWeight n p q k = C(n,k) * p ^ k * q ^ (n - k)`  (`p, q > 0`),

the individual terms of the binomial theorem for `(p + q) ^ n`.  The output is a
completely explicit description of both bracketing degrees in terms of the single
real *mode parameter*

`modeParameter n p q = (n + 1) * p / (p + q)`.

Main results:

* `Nat.choose_mul_choose_lt_choose_sq` — strict log-concavity of a row of Pascal's
  triangle (`C(n,k) * C(n,k+2) < C(n,k+1)^2`), proved from
  `Nat.choose_succ_right_eq` alone.
* `binomialWeight_strictLogConcaveOn` — the weights form a strictly log-concave
  window.
* `binomialWeight_firstArgmax` : `d⁻ = ⌈θ⌉₊ - 1`,
  `binomialWeight_lastArgmax` : `d⁺ = ⌊θ⌋₊`.
* `binomialWeight_bracket_gap` : `d⁺ = d⁻ + 1 ↔ θ ∈ ℕ` — **the explicit comparison
  of the two bracketing degrees**.
* `binomialWeight_nat_bracket_gap` : for natural weights, the plateau occurs iff
  `(p + q) ∣ (n + 1) * p`.
* `choose_firstArgmax`, `choose_lastArgmax`, `choose_bracket_gap` : for `p = q = 1`
  the degrees are `n / 2` and `(n + 1) / 2`, and the plateau occurs iff `n` is odd.
* `binomialWeight_max_term_bracket` : the largest term of the binomial expansion is
  squeezed between `(p+q)^n / (n+1)` and `(p+q)^n`.
-/
import Mathlib
import Shared.UnimodalArgmaxBracketing

namespace Shared
namespace UnimodalArgmaxBracketing

/-! ## Strict log-concavity of a row of Pascal's triangle -/

/-- **Strict log-concavity of the binomial coefficients.**  For `k + 2 ≤ n`,
`C(n,k) * C(n,k+2) < C(n,k+1)^2`. -/
theorem Nat.choose_mul_choose_lt_choose_sq {n k : ℕ} (h : k + 2 ≤ n) :
    n.choose k * n.choose (k + 2) < (n.choose (k + 1)) ^ 2 := by
  obtain ⟨m, rfl⟩ : ∃ m, n = k + 2 + m := ⟨n - k - 2, by omega⟩
  set N := k + 2 + m with hN
  have e1 : N - k = m + 2 := by omega
  have e2 : N - (k + 1) = m + 1 := by omega
  have k1 : N.choose (k + 1) * (k + 1) = N.choose k * (m + 2) := by
    rw [Nat.choose_succ_right_eq, e1]
  have k2 : N.choose (k + 2) * (k + 2) = N.choose (k + 1) * (m + 1) := by
    rw [show k + 2 = (k + 1) + 1 from rfl, Nat.choose_succ_right_eq, e2]
  have hA : 0 < N.choose k := Nat.choose_pos (by omega)
  have hB : 0 < N.choose (k + 1) := Nat.choose_pos (by omega)
  have hC : 0 < N.choose (k + 2) := Nat.choose_pos (by omega)
  -- the crucial identity `B² (k+1)(m+1) = A C (m+2)(k+2)`
  have key : (N.choose (k + 1)) ^ 2 * ((k + 1) * (m + 1))
      = N.choose k * N.choose (k + 2) * ((m + 2) * (k + 2)) :=
    calc (N.choose (k + 1)) ^ 2 * ((k + 1) * (m + 1))
        = (N.choose (k + 1) * (k + 1)) * (N.choose (k + 1) * (m + 1)) := by ring
      _ = (N.choose k * (m + 2)) * (N.choose (k + 2) * (k + 2)) := by rw [k1, ← k2]
      _ = N.choose k * N.choose (k + 2) * ((m + 2) * (k + 2)) := by ring
  by_contra hcon
  push_neg at hcon
  have hpos : 0 < N.choose k * N.choose (k + 2) := Nat.mul_pos hA hC
  nlinarith [key, hcon, hpos]

/-! ## The binomial weights -/

/-- The `k`-th term of the binomial expansion of `(p + q) ^ n`. -/
noncomputable def binomialWeight (n : ℕ) (p q : ℝ) (k : ℕ) : ℝ :=
  (n.choose k : ℝ) * p ^ k * q ^ (n - k)

/-- The *mode parameter* `θ = (n+1) p / (p+q)`: the real number that brackets the
argmax of the binomial weights. -/
noncomputable def modeParameter (n : ℕ) (p q : ℝ) : ℝ := ((n : ℝ) + 1) * p / (p + q)

variable {n : ℕ} {p q : ℝ}

theorem binomialWeight_pos (hp : 0 < p) (hq : 0 < q) {k : ℕ} (hk : k ≤ n) :
    0 < binomialWeight n p q k := by
  have : 0 < (n.choose k : ℝ) := by exact_mod_cast Nat.choose_pos hk
  unfold binomialWeight
  positivity

theorem modeParameter_pos (hp : 0 < p) (hq : 0 < q) : 0 < modeParameter n p q := by
  unfold modeParameter
  have : (0 : ℝ) < p + q := by linarith
  positivity

theorem modeParameter_lt (hp : 0 < p) (hq : 0 < q) : modeParameter n p q < (n : ℝ) + 1 := by
  unfold modeParameter
  have hpq : (0 : ℝ) < p + q := by linarith
  rw [div_lt_iff₀ hpq]
  nlinarith [Nat.cast_nonneg (α := ℝ) n]

/-- The binomial weights form a strictly log-concave window. -/
theorem binomialWeight_strictLogConcaveOn (hp : 0 < p) (hq : 0 < q) :
    StrictLogConcaveOn n (binomialWeight n p q) := by
  refine ⟨fun k hk => binomialWeight_pos hp hq hk, fun k hk => ?_⟩
  obtain ⟨m, hm⟩ : ∃ m, n = k + 2 + m := ⟨n - k - 2, by omega⟩
  have e1 : n - k = m + 2 := by omega
  have e2 : n - (k + 1) = m + 1 := by omega
  have e3 : n - (k + 2) = m := by omega
  have hchoose : (n.choose k : ℝ) * n.choose (k + 2) < (n.choose (k + 1) : ℝ) ^ 2 := by
    exact_mod_cast Nat.choose_mul_choose_lt_choose_sq hk
  have hX : (0 : ℝ) < p ^ (k + k + 2) * q ^ (m + m + 2) := by positivity
  unfold binomialWeight
  rw [e1, e2, e3]
  calc ((n.choose k : ℝ) * p ^ k * q ^ (m + 2)) * ((n.choose (k + 2) : ℝ) * p ^ (k + 2) * q ^ m)
      = ((n.choose k : ℝ) * n.choose (k + 2)) * (p ^ (k + k + 2) * q ^ (m + m + 2)) := by
        ring
    _ < ((n.choose (k + 1) : ℝ) ^ 2) * (p ^ (k + k + 2) * q ^ (m + m + 2)) :=
        mul_lt_mul_of_pos_right hchoose hX
    _ = ((n.choose (k + 1) : ℝ) * p ^ (k + 1) * q ^ (m + 1)) ^ 2 := by ring

/-! ## The rise criterion -/

private theorem cross_lt {A B x y u v : ℝ} (hA : 0 < A) (hx : 0 < x) (key : B * x = A * y) :
    (A * u < B * v ↔ u * x < y * v) := by
  have h1 : A * (u * x) = (A * u) * x := by ring
  have h2 : A * (y * v) = (B * v) * x := by
    rw [show (B * v) * x = (B * x) * v from by ring, key]; ring
  constructor
  · intro h
    have h3 : A * (u * x) < A * (y * v) := by
      rw [h1, h2]; exact mul_lt_mul_of_pos_right h hx
    exact lt_of_mul_lt_mul_left h3 hA.le
  · intro h
    have h3 : A * (u * x) < A * (y * v) := mul_lt_mul_of_pos_left h hA
    rw [h1, h2] at h3
    exact lt_of_mul_lt_mul_right h3 hx.le

/-- The basic rise criterion: the weights rise strictly at `k` iff `k + 1 < θ`. -/
theorem binomialWeight_lt_succ_iff (hp : 0 < p) (hq : 0 < q) {k : ℕ} (hk : k < n) :
    binomialWeight n p q k < binomialWeight n p q (k + 1) ↔
      ((k : ℝ) + 1) < modeParameter n p q := by
  obtain ⟨m, hm⟩ : ∃ m, n = k + 1 + m := ⟨n - k - 1, by omega⟩
  have e1 : n - k = m + 1 := by omega
  have e2 : n - (k + 1) = m := by omega
  have hA : (0 : ℝ) < n.choose k := by exact_mod_cast Nat.choose_pos (by omega)
  have key : ((n.choose (k + 1) : ℝ)) * ((k : ℝ) + 1) = (n.choose k : ℝ) * ((m : ℝ) + 1) := by
    have : n.choose (k + 1) * (k + 1) = n.choose k * (m + 1) := by
      rw [Nat.choose_succ_right_eq, e1]
    exact_mod_cast this
  have hpow : (0 : ℝ) < p ^ k * q ^ m := by positivity
  have hpq : (0 : ℝ) < p + q := by linarith
  have hstep : binomialWeight n p q k < binomialWeight n p q (k + 1) ↔
      (n.choose k : ℝ) * q < (n.choose (k + 1) : ℝ) * p := by
    unfold binomialWeight
    rw [e1, e2, show ((n.choose k : ℝ) * p ^ k * q ^ (m + 1))
          = ((n.choose k : ℝ) * q) * (p ^ k * q ^ m) from by ring,
        show ((n.choose (k + 1) : ℝ) * p ^ (k + 1) * q ^ m)
          = ((n.choose (k + 1) : ℝ) * p) * (p ^ k * q ^ m) from by ring,
        mul_lt_mul_iff_of_pos_right hpow]
  rw [hstep, cross_lt hA (by positivity : (0:ℝ) < (k : ℝ) + 1) key]
  rw [modeParameter, lt_div_iff₀ hpq]
  have hn : (n : ℝ) = (k : ℝ) + 1 + (m : ℝ) := by exact_mod_cast congrArg (Nat.cast : ℕ → ℝ) hm
  constructor
  · intro h; rw [hn]; nlinarith
  · intro h; rw [hn] at h; nlinarith

/-- The weak rise criterion: the weights do not fall at `k` iff `k + 1 ≤ θ`. -/
theorem binomialWeight_le_succ_iff (hp : 0 < p) (hq : 0 < q) {k : ℕ} (hk : k < n) :
    binomialWeight n p q k ≤ binomialWeight n p q (k + 1) ↔
      ((k : ℝ) + 1) ≤ modeParameter n p q := by
  obtain ⟨m, hm⟩ : ∃ m, n = k + 1 + m := ⟨n - k - 1, by omega⟩
  have e1 : n - k = m + 1 := by omega
  have e2 : n - (k + 1) = m := by omega
  have hA : (0 : ℝ) < n.choose k := by exact_mod_cast Nat.choose_pos (by omega)
  have key : ((n.choose (k + 1) : ℝ)) * ((k : ℝ) + 1) = (n.choose k : ℝ) * ((m : ℝ) + 1) := by
    have : n.choose (k + 1) * (k + 1) = n.choose k * (m + 1) := by
      rw [Nat.choose_succ_right_eq, e1]
    exact_mod_cast this
  have hpow : (0 : ℝ) < p ^ k * q ^ m := by positivity
  have hpq : (0 : ℝ) < p + q := by linarith
  have hstep : binomialWeight n p q k ≤ binomialWeight n p q (k + 1) ↔
      (n.choose k : ℝ) * q ≤ (n.choose (k + 1) : ℝ) * p := by
    unfold binomialWeight
    rw [e1, e2, show ((n.choose k : ℝ) * p ^ k * q ^ (m + 1))
          = ((n.choose k : ℝ) * q) * (p ^ k * q ^ m) from by ring,
        show ((n.choose (k + 1) : ℝ) * p ^ (k + 1) * q ^ m)
          = ((n.choose (k + 1) : ℝ) * p) * (p ^ k * q ^ m) from by ring,
        mul_le_mul_iff_of_pos_right hpow]
  have hcross : ((n.choose k : ℝ) * q ≤ (n.choose (k + 1) : ℝ) * p) ↔
      q * ((k : ℝ) + 1) ≤ ((m : ℝ) + 1) * p := by
    constructor
    · intro h
      have h3 : (n.choose k : ℝ) * (q * ((k : ℝ) + 1)) ≤ (n.choose k : ℝ) * (((m : ℝ) + 1) * p) := by
        have := mul_le_mul_of_nonneg_right h (by positivity : (0:ℝ) ≤ (k : ℝ) + 1)
        nlinarith [key]
      exact le_of_mul_le_mul_left h3 hA
    · intro h
      have h3 := mul_le_mul_of_nonneg_left h hA.le
      nlinarith [key, hpow]
  rw [hstep, hcross, modeParameter, le_div_iff₀ hpq]
  have hn : (n : ℝ) = (k : ℝ) + 1 + (m : ℝ) := by exact_mod_cast congrArg (Nat.cast : ℕ → ℝ) hm
  constructor
  · intro h; rw [hn]; nlinarith
  · intro h; rw [hn] at h; nlinarith

/-! ## The two bracketing degrees, explicitly -/

/-- The binomial weights form a *threshold window* with threshold
`θ = (n+1) p / (p+q)`.  This single statement feeds the whole abstract machine. -/
theorem binomialWeight_thresholdWindow (hp : 0 < p) (hq : 0 < q) :
    ThresholdWindow n (binomialWeight n p q) (modeParameter n p q) :=
  ⟨modeParameter_pos hp hq, modeParameter_lt hp hq,
    fun _ hk => binomialWeight_lt_succ_iff hp hq hk,
    fun _ hk => binomialWeight_le_succ_iff hp hq hk⟩

/-- **The lower bracketing degree of the binomial weights is `⌈θ⌉₊ - 1`.** -/
theorem binomialWeight_firstArgmax (hp : 0 < p) (hq : 0 < q) :
    firstArgmax n (binomialWeight n p q) = ⌈modeParameter n p q⌉₊ - 1 :=
  (binomialWeight_thresholdWindow hp hq).firstArgmax_eq

/-- **The upper bracketing degree of the binomial weights is `⌊θ⌋₊`.** -/
theorem binomialWeight_lastArgmax (hp : 0 < p) (hq : 0 < q) :
    lastArgmax n (binomialWeight n p q) = ⌊modeParameter n p q⌋₊ :=
  (binomialWeight_thresholdWindow hp hq).lastArgmax_eq

/-! ## The explicit comparison of the two bracketing degrees -/

/-- **The explicit comparison of the two bracketing degrees.**  For the binomial
weights the gap between the lower and the upper bracketing degree is `1` exactly
when the mode parameter `θ = (n+1)p/(p+q)` is an integer, and `0` otherwise. -/
theorem binomialWeight_bracket_gap (hp : 0 < p) (hq : 0 < q) :
    lastArgmax n (binomialWeight n p q) = firstArgmax n (binomialWeight n p q) + 1 ↔
      ∃ m : ℕ, (m : ℝ) = modeParameter n p q :=
  (binomialWeight_thresholdWindow hp hq).bracket_gap

/-- Complement: when `θ` is not an integer the two bracketing degrees coincide, so
the maximiser is unique. -/
theorem binomialWeight_bracket_tight (hp : 0 < p) (hq : 0 < q)
    (h : ¬ ∃ m : ℕ, (m : ℝ) = modeParameter n p q) :
    firstArgmax n (binomialWeight n p q) = lastArgmax n (binomialWeight n p q) :=
  (binomialWeight_thresholdWindow hp hq).bracket_tight h

/-! ## Dependence of the brackets on the parameters -/

/-- The mode parameter is monotone in the success weight `p`. -/
theorem modeParameter_mono {p₁ p₂ : ℝ} (hq : 0 < q) (hp₁ : 0 < p₁) (hp : p₁ ≤ p₂) :
    modeParameter n p₁ q ≤ modeParameter n p₂ q := by
  have h1 : (0 : ℝ) < p₁ + q := by linarith
  have h2 : (0 : ℝ) < p₂ + q := by linarith
  rw [modeParameter, modeParameter, div_le_div_iff₀ h1 h2]
  nlinarith [mul_nonneg (mul_nonneg (by positivity : (0:ℝ) ≤ (n : ℝ) + 1) hq.le)
    (sub_nonneg.2 hp)]

/-- **Monotonicity of both bracketing degrees in the weight `p`.**  Increasing the
success weight can only move the peak to the right. -/
theorem binomialWeight_brackets_mono {p₁ p₂ : ℝ} (hq : 0 < q) (hp₁ : 0 < p₁) (hp : p₁ ≤ p₂) :
    firstArgmax n (binomialWeight n p₁ q) ≤ firstArgmax n (binomialWeight n p₂ q) ∧
      lastArgmax n (binomialWeight n p₁ q) ≤ lastArgmax n (binomialWeight n p₂ q) :=
  ThresholdWindow.brackets_mono (binomialWeight_thresholdWindow hp₁ hq)
    (binomialWeight_thresholdWindow (lt_of_lt_of_le hp₁ hp) hq) (modeParameter_mono hq hp₁ hp)

/-- Increasing the number of trials by one increases the threshold by `p/(p+q) < 1`. -/
theorem modeParameter_succ (hp : 0 < p) (hq : 0 < q) :
    modeParameter n p q ≤ modeParameter (n + 1) p q ∧
      modeParameter (n + 1) p q < modeParameter n p q + 1 := by
  have hpq : (0 : ℝ) < p + q := by linarith
  have hstep : modeParameter (n + 1) p q = modeParameter n p q + p / (p + q) := by
    rw [modeParameter, modeParameter]
    push_cast
    field_simp
  have hlt : p / (p + q) < 1 := by
    rw [div_lt_one hpq]; linarith
  have hpos : 0 < p / (p + q) := by positivity
  constructor
  · rw [hstep]; linarith
  · rw [hstep]; linarith

/-- **The peak moves by at most one trial at a time.**  Both bracketing degrees of
the `(n+1)`-st row are sandwiched between those of the `n`-th row and their
successors: the argmax of the binomial weights is a unit staircase in `n`. -/
theorem binomialWeight_brackets_succ (hp : 0 < p) (hq : 0 < q) :
    lastArgmax n (binomialWeight n p q) ≤ lastArgmax (n + 1) (binomialWeight (n + 1) p q) ∧
      lastArgmax (n + 1) (binomialWeight (n + 1) p q)
        ≤ lastArgmax n (binomialWeight n p q) + 1 := by
  obtain ⟨hmono, hstep⟩ := modeParameter_succ (n := n) hp hq
  refine ⟨(ThresholdWindow.brackets_mono (binomialWeight_thresholdWindow (n := n) hp hq)
      (binomialWeight_thresholdWindow (n := n + 1) hp hq) hmono).2,
    (ThresholdWindow.brackets_step (binomialWeight_thresholdWindow (n := n) hp hq)
      (binomialWeight_thresholdWindow (n := n + 1) hp hq) hstep).2⟩

/-- The maximiser set of the binomial weights is exactly `[⌈θ⌉₊ - 1, ⌊θ⌋₊]`. -/
theorem binomialWeight_argmax_eq_Icc (hp : 0 < p) (hq : 0 < q) {k : ℕ} (hk : k ≤ n) :
    binomialWeight n p q k = binomialWeight n p q (⌈modeParameter n p q⌉₊ - 1) ↔
      (⌈modeParameter n p q⌉₊ - 1 ≤ k ∧ k ≤ ⌊modeParameter n p q⌋₊) := by
  have h := argmax_eq_Icc (binomialWeight_strictLogConcaveOn hp hq) hk
  rw [binomialWeight_firstArgmax hp hq, binomialWeight_lastArgmax hp hq] at h
  exact h

/-- Every binomial weight is dominated by the weight at the lower bracketing degree. -/
theorem binomialWeight_le_max (hp : 0 < p) (hq : 0 < q) {k : ℕ} (hk : k ≤ n) :
    binomialWeight n p q k ≤ binomialWeight n p q (⌈modeParameter n p q⌉₊ - 1) := by
  have h := le_value_firstArgmax (binomialWeight_strictLogConcaveOn hp hq) hk
  rwa [binomialWeight_firstArgmax hp hq] at h

/-! ## Arithmetic form of the comparison, and the classical case `p = q = 1` -/

/-- For natural weights `p, q ≥ 1` the plateau (gap `1`) occurs exactly when
`(p + q) ∣ (n + 1) * p`. -/
theorem binomialWeight_nat_bracket_gap {P Q : ℕ} (hP : 0 < P) (hQ : 0 < Q) :
    lastArgmax n (binomialWeight n (P : ℝ) (Q : ℝ))
        = firstArgmax n (binomialWeight n (P : ℝ) (Q : ℝ)) + 1 ↔
      (P + Q) ∣ (n + 1) * P := by
  have hp : (0 : ℝ) < P := by exact_mod_cast hP
  have hq : (0 : ℝ) < Q := by exact_mod_cast hQ
  have hpq : (0 : ℝ) < (P : ℝ) + Q := by linarith
  rw [binomialWeight_bracket_gap hp hq]
  constructor
  · rintro ⟨m, hm⟩
    have : (m : ℝ) * ((P : ℝ) + Q) = ((n : ℝ) + 1) * P := by
      rw [hm, modeParameter, div_mul_cancel₀ _ hpq.ne']
    have hnat : m * (P + Q) = (n + 1) * P := by exact_mod_cast this
    exact ⟨m, by rw [← hnat]; ring⟩
  · rintro ⟨c, hc⟩
    refine ⟨c, ?_⟩
    have hcr : ((n : ℝ) + 1) * P = c * ((P : ℝ) + Q) := by
      have : ((n + 1) * P : ℕ) = ((P + Q) * c : ℕ) := hc
      have := congrArg (Nat.cast : ℕ → ℝ) this
      push_cast at this
      linarith
    rw [modeParameter, hcr, mul_div_assoc, div_self hpq.ne', mul_one]

private theorem floor_half_succ (n : ℕ) : ⌊((n : ℝ) + 1) / 2⌋₊ = (n + 1) / 2 := by
  rw [Nat.floor_eq_iff (by positivity)]
  rcases Nat.even_or_odd n with ⟨t, rfl⟩ | ⟨t, rfl⟩
  · have h : (t + t + 1) / 2 = t := by omega
    rw [h]; push_cast; constructor <;> linarith
  · have h : (2 * t + 1 + 1) / 2 = t + 1 := by omega
    rw [h]; push_cast; constructor <;> linarith

private theorem ceil_half_succ (n : ℕ) : ⌈((n : ℝ) + 1) / 2⌉₊ = n / 2 + 1 := by
  rw [Nat.ceil_eq_iff (by omega)]
  simp only [Nat.add_sub_cancel]
  rcases Nat.even_or_odd n with ⟨t, rfl⟩ | ⟨t, rfl⟩
  · have h : (t + t) / 2 = t := by omega
    rw [h]; push_cast; constructor <;> linarith
  · have h : (2 * t + 1) / 2 = t := by omega
    rw [h]; push_cast; constructor <;> linarith

/-- For `p = q = 1` the binomial weights are the binomial coefficients themselves. -/
theorem binomialWeight_one_one (k : ℕ) :
    binomialWeight n (1 : ℝ) (1 : ℝ) k = (n.choose k : ℝ) := by
  simp [binomialWeight]

/-- Classical case: the lower bracketing degree of `k ↦ C(n,k)` is `n / 2`. -/
theorem choose_firstArgmax : firstArgmax n (binomialWeight n (1 : ℝ) (1 : ℝ)) = n / 2 := by
  rw [binomialWeight_firstArgmax one_pos one_pos]
  have hθ : modeParameter n (1 : ℝ) (1 : ℝ) = ((n : ℝ) + 1) / 2 := by
    rw [modeParameter]; norm_num
  rw [hθ, ceil_half_succ]
  omega

/-- Classical case: the upper bracketing degree of `k ↦ C(n,k)` is `(n + 1) / 2`. -/
theorem choose_lastArgmax : lastArgmax n (binomialWeight n (1 : ℝ) (1 : ℝ)) = (n + 1) / 2 := by
  rw [binomialWeight_lastArgmax one_pos one_pos]
  have hθ : modeParameter n (1 : ℝ) (1 : ℝ) = ((n : ℝ) + 1) / 2 := by
    rw [modeParameter]; norm_num
  rw [hθ, floor_half_succ]

/-- **Classical corollary.**  The binomial coefficients `C(n, ·)` have a two-point
plateau at the top exactly when `n` is odd. -/
theorem choose_bracket_gap :
    lastArgmax n (binomialWeight n (1 : ℝ) (1 : ℝ))
        = firstArgmax n (binomialWeight n (1 : ℝ) (1 : ℝ)) + 1 ↔ Odd n := by
  rw [choose_firstArgmax, choose_lastArgmax, Nat.odd_iff]
  omega

/-! ## The largest term of the binomial expansion -/

/-- The maximal term of the binomial expansion is squeezed between `(p+q)^n / (n+1)`
and `(p+q)^n`: an explicit two-sided bracket for the peak *value*. -/
theorem binomialWeight_max_term_bracket (hp : 0 < p) (hq : 0 < q) :
    (p + q) ^ n / ((n : ℝ) + 1) ≤ binomialWeight n p q (⌈modeParameter n p q⌉₊ - 1) ∧
      binomialWeight n p q (⌈modeParameter n p q⌉₊ - 1) ≤ (p + q) ^ n := by
  set d := ⌈modeParameter n p q⌉₊ - 1 with hd
  have hexp : (p + q) ^ n = ∑ k ∈ Finset.range (n + 1), binomialWeight n p q k := by
    rw [add_pow]
    refine Finset.sum_congr rfl (fun k _ => ?_)
    unfold binomialWeight
    ring
  have hle : ∀ k ∈ Finset.range (n + 1), binomialWeight n p q k ≤ binomialWeight n p q d := by
    intro k hk
    exact binomialWeight_le_max hp hq (by simpa [Nat.lt_succ_iff] using Finset.mem_range.1 hk)
  have hsum : (p + q) ^ n ≤ ((n : ℝ) + 1) * binomialWeight n p q d := by
    rw [hexp]
    calc ∑ k ∈ Finset.range (n + 1), binomialWeight n p q k
        ≤ ∑ _k ∈ Finset.range (n + 1), binomialWeight n p q d := Finset.sum_le_sum hle
      _ = ((n : ℝ) + 1) * binomialWeight n p q d := by
          rw [Finset.sum_const, Finset.card_range]
          simp [nsmul_eq_mul]
  have hn1 : (0 : ℝ) < (n : ℝ) + 1 := by positivity
  constructor
  · rw [div_le_iff₀ hn1]; linarith
  · have hdn : d ≤ n := by
      have hceille : ⌈modeParameter n p q⌉₊ ≤ n + 1 := by
        apply Nat.ceil_le.2
        push_cast
        linarith [modeParameter_lt (n := n) hp hq]
      omega
    have hmem : d ∈ Finset.range (n + 1) := Finset.mem_range.2 (by omega)
    rw [hexp]
    refine Finset.single_le_sum (fun k hk => ?_) hmem
    exact (binomialWeight_pos hp hq (by simpa [Nat.lt_succ_iff] using Finset.mem_range.1 hk)).le

/-! ## Every degree is a Newton-polygon vertex

Strict log-concavity says that the points `(k, log C(n,k))` are in *strictly convex
position*.  Equivalently: after tilting by a suitable weight `p^k` every single
degree `d ≤ n` becomes the **unique** maximiser.  This is the sweep of the argmax as
the threshold `θ` runs through `(0, n+1)`. -/

/-- **Vertex sweep.**  For every degree `d ≤ n` there is a weight `p > 0` making `d`
the *unique* maximiser of the binomial weights `C(n,k) p^k`. -/
theorem binomialWeight_every_degree_is_unique_peak (n d : ℕ) (hd : d ≤ n) :
    ∃ p : ℝ, 0 < p ∧ ∀ k ≤ n, k ≠ d →
      binomialWeight n p 1 k < binomialWeight n p 1 d := by
  set θ : ℝ := (d : ℝ) + 1 / 2 with hθdef
  have hθpos : 0 < θ := by positivity
  have hdn : (d : ℝ) ≤ (n : ℝ) := by exact_mod_cast hd
  have hθlt : θ < (n : ℝ) + 1 := by rw [hθdef]; linarith
  have hden : (0 : ℝ) < ((n : ℝ) + 1) - θ := by linarith
  refine ⟨θ / (((n : ℝ) + 1) - θ), by positivity, ?_⟩
  set p : ℝ := θ / (((n : ℝ) + 1) - θ) with hpdef
  have hp : 0 < p := by rw [hpdef]; positivity
  have hmode : modeParameter n p 1 = θ := by
    have hsum : p + 1 = ((n : ℝ) + 1) / (((n : ℝ) + 1) - θ) := by
      rw [hpdef]; field_simp; ring
    rw [modeParameter, hsum, hpdef]
    field_simp
  have hceil : ⌈θ⌉₊ = d + 1 := by
    rw [Nat.ceil_eq_iff (by omega)]
    simp only [Nat.add_sub_cancel]
    rw [hθdef]
    push_cast
    constructor <;> linarith
  have hfloor : ⌊θ⌋₊ = d := by
    rw [Nat.floor_eq_iff (by positivity), hθdef]
    constructor <;> linarith
  have hfirst : firstArgmax n (binomialWeight n p 1) = d := by
    rw [binomialWeight_firstArgmax hp one_pos, hmode, hceil]
    omega
  have hlast : lastArgmax n (binomialWeight n p 1) = d := by
    rw [binomialWeight_lastArgmax hp one_pos, hmode, hfloor]
  intro k hk hkd
  have hout : k < firstArgmax n (binomialWeight n p 1) ∨
      lastArgmax n (binomialWeight n p 1) < k := by
    rw [hfirst, hlast]
    omega
  have := lt_value_firstArgmax_of_outside (binomialWeight_strictLogConcaveOn hp one_pos) hk hout
  rwa [hfirst] at this

end UnimodalArgmaxBracketing
end Shared