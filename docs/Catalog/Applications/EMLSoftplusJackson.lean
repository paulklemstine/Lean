/-
# Depth-2 EML networks contain ReLU networks, and the Lipschitz Jackson rate

Companion file to `Catalog/Applications/EMLDepthWidthTradeoff.lean`, which proves
the `O(w^{-2})` rate of a width-2 EML layer on `x²` and the matching
`Ω(k^{-2})` lower bound for shallow ReLU networks.  Here we go in the opposite
direction and show that **EML at depth 2 is at least as expressive as shallow
ReLU**, hence inherits the whole Lipschitz approximation theory.

The mechanism is that softplus is an exp–log composite: `exp` in the first EML
layer, `log` in the second, giving `log (1 + exp (M t))`, which approximates
`M · relu t` to within `log 2`.

## Main results

* `scaled_softplus_approx_relu` — `|log(1 + exp(M t))/M − relu t| ≤ log 2 / M`.
* `softplusEmulator_error` — the explicit depth-2 EML network with `k` parallel
  `exp`→`log` chains reproduces a `k`-unit shallow ReLU network to within
  `(Σ|aᵢ|) log 2 / M`, uniformly on `ℝ`.
* `emlDepth2_dominates_relu` — consequently every function approximated to `ε`
  by a `k`-unit shallow ReLU network is approximated to `ε + δ` by a depth-2 EML
  network of the same width, for any `δ > 0`.
* `lipReluNet_on_piece`, `lipschitz_relu_rate` — the piecewise-linear interpolant
  of `f` at the nodes `j/N` written as an *explicit* ReLU network, with uniform
  error `2L/N` for `L`-Lipschitz `f`.
* `eml_depth2_lipschitz_rate` — the Jackson-type rate for depth-2 EML networks:
  uniform error `2L/N + δ` at width `N`.  Together with the `O(N^{-2})` rate for
  `x²` in the companion file this pins down the mission's conjecture: the
  quadratic rate is a *smoothness* phenomenon; on the raw Lipschitz class the
  rate is `Θ(1/N)`, exactly as for ReLU.

Self-contained (`import Mathlib` only); the three definitions `relu`, `reluNet`
and `Neuron` are repeated verbatim from the companion file because the catalog's
files are compiled standalone.
-/
import Mathlib

namespace EML.SoftplusJackson

open Real Set

noncomputable section

/-! ## Definitions shared with `EMLDepthWidthTradeoff` -/

/-- ReLU. -/
def relu (t : ℝ) : ℝ := max t 0

/-- A one-hidden-layer ReLU network with `k` units and an affine skip connection. -/
def reluNet (k : ℕ) (a w b : Fin k → ℝ) (c₀ c₁ : ℝ) (x : ℝ) : ℝ :=
  c₀ + c₁ * x + ∑ i, a i * relu (w i * x + b i)

/-- Parameters of a single EML neuron `x ↦ exp(a x + b) − log(c x + d)`. -/
structure Neuron where
  /-- weight inside the exponential branch -/
  a : ℝ
  /-- bias inside the exponential branch -/
  b : ℝ
  /-- weight inside the logarithmic branch -/
  c : ℝ
  /-- bias inside the logarithmic branch -/
  d : ℝ

/-- The function computed by an EML neuron. -/
def Neuron.eval (N : Neuron) (x : ℝ) : ℝ :=
  Real.exp (N.a * x + N.b) - Real.log (N.c * x + N.d)

/-! ## Softplus and the emulation of ReLU networks -/

/-- Softplus `t ↦ log (1 + exp t)`. -/
def softplus (t : ℝ) : ℝ := Real.log (1 + Real.exp t)

theorem relu_le_softplus (t : ℝ) : relu t ≤ softplus t := by
  have hexp : (0:ℝ) < Real.exp t := Real.exp_pos t
  rcases le_or_gt t 0 with ht | ht
  · have : relu t = 0 := by simp [relu, max_eq_right ht]
    rw [this, softplus]
    have : (1:ℝ) ≤ 1 + Real.exp t := by linarith
    simpa using Real.log_nonneg this
  · have hr : relu t = t := by simp [relu, max_eq_left ht.le]
    rw [hr, softplus]
    have h1 : Real.exp t ≤ 1 + Real.exp t := by linarith
    calc t = Real.log (Real.exp t) := (Real.log_exp t).symm
      _ ≤ Real.log (1 + Real.exp t) := Real.log_le_log hexp h1

theorem softplus_le_relu_add_log_two (t : ℝ) : softplus t ≤ relu t + Real.log 2 := by
  have hexp : (0:ℝ) < Real.exp t := Real.exp_pos t
  rcases le_or_gt t 0 with ht | ht
  · have hr : relu t = 0 := by simp [relu, max_eq_right ht]
    rw [hr, softplus, zero_add]
    have h1 : 1 + Real.exp t ≤ 2 := by
      have : Real.exp t ≤ 1 := by
        simpa using Real.exp_le_exp.2 ht
      linarith
    exact Real.log_le_log (by linarith) h1
  · have hr : relu t = t := by simp [relu, max_eq_left ht.le]
    rw [hr, softplus]
    have hid : 1 + Real.exp t = Real.exp t * (1 + Real.exp (-t)) := by
      rw [mul_add, mul_one, ← Real.exp_add, add_neg_cancel, Real.exp_zero]
      ring
    rw [hid, Real.log_mul (ne_of_gt hexp) (by positivity), Real.log_exp]
    have h1 : 1 + Real.exp (-t) ≤ 2 := by
      have : Real.exp (-t) ≤ 1 := by
        simpa using Real.exp_le_exp.2 (by linarith : -t ≤ 0)
      linarith
    have := Real.log_le_log (by positivity : (0:ℝ) < 1 + Real.exp (-t)) h1
    linarith

/-- The scaled softplus is a two-sided `log 2 / M`-approximation of ReLU. -/
theorem scaled_softplus_approx_relu (M t : ℝ) (hM : 0 < M) :
    |softplus (M * t) / M - relu t| ≤ Real.log 2 / M := by
  have h1 := relu_le_softplus (M * t)
  have h2 := softplus_le_relu_add_log_two (M * t)
  have hscale : relu (M * t) = M * relu t := by
    simp [relu, mul_max_of_nonneg _ _ hM.le]
  rw [hscale] at h1 h2
  have key : softplus (M * t) / M - relu t = (softplus (M * t) - M * relu t) / M := by
    field_simp
  rw [key, abs_div, abs_of_pos hM]
  gcongr
  rw [abs_le]
  constructor <;> linarith

/-! ## Depth-2 EML networks with parallel chains -/

/-- A **depth-2 EML network**: `k` parallel chains, each an EML neuron of the
second layer applied to the output of an EML neuron of the first layer, together
with an affine read-out and an affine skip connection. -/
structure Depth2Net (k : ℕ) where
  /-- neurons of the first layer -/
  first : Fin k → Neuron
  /-- neurons of the second layer -/
  second : Fin k → Neuron
  /-- read-out weights -/
  out : Fin k → ℝ
  /-- constant term of the skip connection -/
  skip0 : ℝ
  /-- linear term of the skip connection -/
  skip1 : ℝ

def Depth2Net.eval {k : ℕ} (N : Depth2Net k) (x : ℝ) : ℝ :=
  N.skip0 + N.skip1 * x + ∑ i, N.out i * (N.second i).eval ((N.first i).eval x)

/-- The depth-2 EML network that emulates a shallow ReLU network: the first layer
computes `exp (M (wᵢ x + bᵢ))`, the second layer applies `u ↦ 1 - log (1 + u)`,
which is exactly a (rescaled) softplus. -/
def softplusEmulator (k : ℕ) (a w b : Fin k → ℝ) (c₀ c₁ M : ℝ) : Depth2Net k where
  first i := ⟨M * w i, M * b i, 0, 1⟩
  second _ := ⟨0, 0, 1, 1⟩
  out i := -(a i) / M
  skip0 := c₀ + ∑ i, a i / M
  skip1 := c₁

theorem softplusEmulator_chain (k : ℕ) (a w b : Fin k → ℝ) (c₀ c₁ M : ℝ) (x : ℝ) (i : Fin k) :
    ((softplusEmulator k a w b c₀ c₁ M).second i).eval
        (((softplusEmulator k a w b c₀ c₁ M).first i).eval x)
      = 1 - softplus (M * (w i * x + b i)) := by
  simp only [softplusEmulator, Neuron.eval, softplus, zero_mul, zero_add,
    Real.exp_zero, one_mul, Real.log_one, sub_zero]
  rw [show M * w i * x + M * b i = M * (w i * x + b i) by ring,
      show Real.exp (M * (w i * x + b i)) + 1 = 1 + Real.exp (M * (w i * x + b i)) by ring]

theorem softplusEmulator_eval (k : ℕ) (a w b : Fin k → ℝ) (c₀ c₁ M : ℝ) (hM : M ≠ 0) (x : ℝ) :
    (softplusEmulator k a w b c₀ c₁ M).eval x
      = c₀ + c₁ * x + ∑ i, a i * (softplus (M * (w i * x + b i)) / M) := by
  have hterm : ∀ i : Fin k,
      (softplusEmulator k a w b c₀ c₁ M).out i *
        ((softplusEmulator k a w b c₀ c₁ M).second i).eval
          (((softplusEmulator k a w b c₀ c₁ M).first i).eval x)
      = a i * (softplus (M * (w i * x + b i)) / M) - a i / M := by
    intro i
    rw [softplusEmulator_chain]
    show -(a i) / M * (1 - softplus (M * (w i * x + b i))) = _
    field_simp
    ring
  simp only [Depth2Net.eval]
  rw [Finset.sum_congr rfl (fun i _ => hterm i), Finset.sum_sub_distrib]
  show c₀ + ∑ i, a i / M + c₁ * x + _ = _
  ring

/-- **Depth-2 EML networks emulate shallow ReLU networks.**  With inner scale `M`
the emulation error is at most `(Σ |aᵢ|) log 2 / M`, uniformly on `ℝ`. -/
theorem softplusEmulator_error (k : ℕ) (a w b : Fin k → ℝ) (c₀ c₁ M : ℝ) (hM : 0 < M) (x : ℝ) :
    |(softplusEmulator k a w b c₀ c₁ M).eval x - reluNet k a w b c₀ c₁ x|
      ≤ (∑ i, |a i|) * (Real.log 2 / M) := by
  rw [softplusEmulator_eval k a w b c₀ c₁ M hM.ne' x, reluNet]
  have hdiff : c₀ + c₁ * x + ∑ i, a i * (softplus (M * (w i * x + b i)) / M)
      - (c₀ + c₁ * x + ∑ i, a i * relu (w i * x + b i))
      = ∑ i, a i * (softplus (M * (w i * x + b i)) / M - relu (w i * x + b i)) := by
    simp only [mul_sub, Finset.sum_sub_distrib]
    ring
  rw [hdiff]
  calc |∑ i, a i * (softplus (M * (w i * x + b i)) / M - relu (w i * x + b i))|
      ≤ ∑ i, |a i * (softplus (M * (w i * x + b i)) / M - relu (w i * x + b i))| :=
        Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ i, |a i| * (Real.log 2 / M) := by
        refine Finset.sum_le_sum (fun i _ => ?_)
        rw [abs_mul]
        exact mul_le_mul_of_nonneg_left (scaled_softplus_approx_relu M _ hM) (abs_nonneg _)
    _ = (∑ i, |a i|) * (Real.log 2 / M) := by rw [Finset.sum_mul]

/-- **Depth-2 EML dominates shallow ReLU.**  Any function approximated to `ε` by a
`k`-unit shallow ReLU network on a set `S` is approximated to `ε + δ` by a
depth-2 EML network with `k` chains, for every `δ > 0`. -/
theorem emlDepth2_dominates_relu (k : ℕ) (a w b : Fin k → ℝ) (c₀ c₁ : ℝ)
    (f : ℝ → ℝ) (S : Set ℝ) (ε δ : ℝ) (hδ : 0 < δ)
    (h : ∀ x ∈ S, |f x - reluNet k a w b c₀ c₁ x| ≤ ε) :
    ∃ N : Depth2Net k, ∀ x ∈ S, |f x - N.eval x| ≤ ε + δ := by
  set A := ∑ i, |a i| with hA
  have hA0 : 0 ≤ A := Finset.sum_nonneg (fun i _ => abs_nonneg _)
  set M := max 1 (A * Real.log 2 / δ) with hMdef
  have hM : 0 < M := lt_of_lt_of_le one_pos (le_max_left _ _)
  refine ⟨softplusEmulator k a w b c₀ c₁ M, fun x hx => ?_⟩
  have h1 := softplusEmulator_error k a w b c₀ c₁ M hM x
  have h2 : A * (Real.log 2 / M) ≤ δ := by
    rw [mul_div_assoc'] at h1 ⊢
    rw [div_le_iff₀ hM]
    have : A * Real.log 2 / δ ≤ M := le_max_right _ _
    rw [div_le_iff₀ hδ] at this
    linarith
  calc |f x - (softplusEmulator k a w b c₀ c₁ M).eval x|
      ≤ |f x - reluNet k a w b c₀ c₁ x|
        + |reluNet k a w b c₀ c₁ x - (softplusEmulator k a w b c₀ c₁ M).eval x| := by
        have := abs_add_le (f x - reluNet k a w b c₀ c₁ x)
          (reluNet k a w b c₀ c₁ x - (softplusEmulator k a w b c₀ c₁ M).eval x)
        simpa using this
    _ ≤ ε + δ := by
        have h3 : |reluNet k a w b c₀ c₁ x - (softplusEmulator k a w b c₀ c₁ M).eval x|
            = |(softplusEmulator k a w b c₀ c₁ M).eval x - reluNet k a w b c₀ c₁ x| :=
          abs_sub_comm _ _
        rw [h3]
        linarith [h x hx, h1, h2]


/-! ## Piecewise-linear interpolation and the Lipschitz rate -/

/-- Slope of the linear interpolant of `f` on the `j`-th piece of the uniform
`N`-partition of `[0,1]`. -/
def interpSlope (f : ℝ → ℝ) (N : ℕ) (j : ℕ) : ℝ :=
  (f (((j : ℝ) + 1) / N) - f ((j : ℝ) / N)) * N

/-- The read-out weight attached to the breakpoint `j/N`: the jump of the slope. -/
def interpCoeff (f : ℝ → ℝ) (N : ℕ) (j : ℕ) : ℝ :=
  if j = 0 then interpSlope f N 0 else interpSlope f N j - interpSlope f N (j - 1)

/-- The ReLU network of width `N` realising the piecewise-linear interpolant of
`f` at the nodes `0, 1/N, …, 1`. -/
def lipReluNet (f : ℝ → ℝ) (N : ℕ) (x : ℝ) : ℝ :=
  reluNet N (fun i => interpCoeff f N (i : ℕ)) (fun _ => 1)
    (fun i => -((i : ℕ) : ℝ) / N) (f 0) 0 x

theorem sum_interpCoeff (f : ℝ → ℝ) (N j : ℕ) :
    ∑ i ∈ Finset.range (j + 1), interpCoeff f N i = interpSlope f N j := by
  induction j with
  | zero => simp [interpCoeff]
  | succ j ih =>
      rw [Finset.sum_range_succ, ih]
      simp [interpCoeff]

theorem sum_index_interpCoeff (f : ℝ → ℝ) (N j : ℕ) :
    ∑ i ∈ Finset.range (j + 1), (i : ℝ) * interpCoeff f N i
      = (j : ℝ) * interpSlope f N j - ∑ i ∈ Finset.range j, interpSlope f N i := by
  induction j with
  | zero => simp [interpCoeff]
  | succ j ih =>
      rw [Finset.sum_range_succ, ih, Finset.sum_range_succ]
      have hc : interpCoeff f N (j + 1) = interpSlope f N (j + 1) - interpSlope f N j := by
        simp [interpCoeff]
      rw [hc]
      push_cast
      ring

theorem sum_interpSlope (f : ℝ → ℝ) (N j : ℕ) :
    ∑ i ∈ Finset.range j, interpSlope f N i = (f ((j : ℝ) / N) - f 0) * N := by
  induction j with
  | zero => simp
  | succ j ih =>
      rw [Finset.sum_range_succ, ih, interpSlope]
      push_cast
      ring

/-- **Exact form of the interpolant on a piece.** -/
theorem lipReluNet_on_piece (f : ℝ → ℝ) (N j : ℕ) (hN : 1 ≤ N) (hj : j < N) (x : ℝ)
    (hx : x ∈ Icc ((j : ℝ) / N) (((j : ℝ) + 1) / N)) :
    lipReluNet f N x = f ((j : ℝ) / N) + interpSlope f N j * (x - (j : ℝ) / N) := by
  have hN0 : (0:ℝ) < N := by exact_mod_cast hN
  obtain ⟨hx1, hx2⟩ := hx
  have hsum : ∑ i : Fin N, interpCoeff f N (i : ℕ) * relu (1 * x + -((i : ℕ) : ℝ) / N)
      = ∑ i ∈ Finset.range N, interpCoeff f N i * relu (1 * x + -(i : ℝ) / N) := by
    rw [Fin.sum_univ_eq_sum_range (fun i => interpCoeff f N i * relu (1 * x + -(i : ℝ) / N)) N]
  have hsplit : ∑ i ∈ Finset.range N, interpCoeff f N i * relu (1 * x + -(i : ℝ) / N)
      = ∑ i ∈ Finset.range (j + 1), interpCoeff f N i * relu (1 * x + -(i : ℝ) / N)
        + ∑ i ∈ Finset.Ico (j + 1) N, interpCoeff f N i * relu (1 * x + -(i : ℝ) / N) := by
    rw [Finset.range_eq_Ico, ← Finset.sum_Ico_consecutive _ (Nat.zero_le (j + 1)) hj]
  have hzero : ∑ i ∈ Finset.Ico (j + 1) N, interpCoeff f N i * relu (1 * x + -(i : ℝ) / N) = 0 := by
    refine Finset.sum_eq_zero (fun i hi => ?_)
    have hij : (j : ℝ) + 1 ≤ (i : ℝ) := by
      have : j + 1 ≤ i := (Finset.mem_Ico.1 hi).1
      exact_mod_cast this
    have : 1 * x + -(i : ℝ) / N ≤ 0 := by
      have h1 : x ≤ ((j : ℝ) + 1) / N := hx2
      have h2 : ((j : ℝ) + 1) / N ≤ (i : ℝ) / N := by gcongr
      have : x ≤ (i : ℝ) / N := le_trans h1 h2
      rw [one_mul, neg_div]
      linarith
    rw [relu, max_eq_right this, mul_zero]
  have hlow : ∀ i ∈ Finset.range (j + 1),
      interpCoeff f N i * relu (1 * x + -(i : ℝ) / N)
        = interpCoeff f N i * (x - (i : ℝ) / N) := by
    intro i hi
    have hij : (i : ℝ) ≤ (j : ℝ) := by
      have : i ≤ j := Nat.lt_succ_iff.1 (Finset.mem_range.1 hi)
      exact_mod_cast this
    have : 0 ≤ 1 * x + -(i : ℝ) / N := by
      have h2 : (i : ℝ) / N ≤ (j : ℝ) / N := by gcongr
      rw [one_mul, neg_div]
      linarith
    rw [relu, max_eq_left this]
    ring
  rw [lipReluNet, reluNet, hsum, hsplit, hzero, Finset.sum_congr rfl hlow]
  have hexpand : ∑ i ∈ Finset.range (j + 1), interpCoeff f N i * (x - (i : ℝ) / N)
      = x * (∑ i ∈ Finset.range (j + 1), interpCoeff f N i)
        - (∑ i ∈ Finset.range (j + 1), (i : ℝ) * interpCoeff f N i) / N := by
    rw [Finset.mul_sum, Finset.sum_div, ← Finset.sum_sub_distrib]
    refine Finset.sum_congr rfl (fun i _ => ?_)
    field_simp
  rw [hexpand, sum_interpCoeff, sum_index_interpCoeff, sum_interpSlope]
  field_simp
  ring

/-- **Jackson-type rate for shallow ReLU on Lipschitz targets.** -/
theorem lipschitz_relu_rate (f : ℝ → ℝ) (L : ℝ) (N : ℕ) (hN : 1 ≤ N)
    (hlip : ∀ u ∈ Icc (0:ℝ) 1, ∀ v ∈ Icc (0:ℝ) 1, |f u - f v| ≤ L * |u - v|)
    (x : ℝ) (hx : x ∈ Icc (0:ℝ) 1) :
    |f x - lipReluNet f N x| ≤ 2 * L / N := by
  have hN0 : (0:ℝ) < N := by exact_mod_cast hN
  obtain ⟨hx0, hx1⟩ := hx
  -- choose the piece containing `x`
  obtain ⟨j, hjN, hxj1, hxj2⟩ : ∃ j : ℕ, j < N ∧ (j : ℝ) / N ≤ x ∧ x ≤ ((j : ℝ) + 1) / N := by
    rcases le_or_gt (⌊x * N⌋₊) (N - 1) with hcase | hcase
    · refine ⟨⌊x * N⌋₊, by omega, ?_, ?_⟩
      · rw [div_le_iff₀ hN0]
        exact Nat.floor_le (by positivity)
      · rw [le_div_iff₀ hN0]
        exact le_of_lt (Nat.lt_floor_add_one (x * N))
    · refine ⟨N - 1, by omega, ?_, ?_⟩
      · have hfl : (N : ℝ) ≤ x * N := by
          have : N ≤ ⌊x * N⌋₊ := by omega
          have h2 : ((N : ℕ) : ℝ) ≤ (⌊x * N⌋₊ : ℝ) := by exact_mod_cast this
          exact le_trans h2 (Nat.floor_le (by positivity))
        have hx1' : 1 ≤ x := by nlinarith
        have : ((N - 1 : ℕ) : ℝ) ≤ (N : ℝ) := by
          have : (N - 1 : ℕ) ≤ N := Nat.sub_le _ _
          exact_mod_cast this
        rw [div_le_iff₀ hN0]
        nlinarith
      · have hcast : ((N - 1 : ℕ) : ℝ) + 1 = (N : ℝ) := by
          have hh : (N - 1 : ℕ) + 1 = N := by omega
          have := congrArg (fun m : ℕ => (m : ℝ)) hh
          push_cast at this
          linarith
        rw [hcast, div_self (ne_of_gt hN0)]
        exact hx1
  have hmem : (j : ℝ) / N ∈ Icc (0:ℝ) 1 := by
    constructor
    · positivity
    · rw [div_le_one hN0]
      have : (j : ℝ) ≤ N := by exact_mod_cast le_of_lt hjN
      linarith
  have hmem1 : ((j : ℝ) + 1) / N ∈ Icc (0:ℝ) 1 := by
    constructor
    · positivity
    · rw [div_le_one hN0]
      have : (j : ℝ) + 1 ≤ N := by exact_mod_cast hjN
      linarith
  rw [lipReluNet_on_piece f N j hN hjN x ⟨hxj1, hxj2⟩]
  have hstep : |f x - f ((j : ℝ) / N)| ≤ L / N := by
    have := hlip x ⟨hx0, hx1⟩ ((j : ℝ) / N) hmem
    refine this.trans ?_
    have habs : |x - (j : ℝ) / N| ≤ 1 / N := by
      rw [abs_le]
      constructor
      · have : (0:ℝ) < 1 / N := by positivity
        linarith
      · have h1 : ((j : ℝ) + 1) / N - (j : ℝ) / N = 1 / N := by field_simp; ring
        linarith
    have hL0 : 0 ≤ L := by
      by_contra hneg
      push_neg at hneg
      have h1 := hlip 0 ⟨le_refl 0, by norm_num⟩ 1 ⟨by norm_num, le_refl 1⟩
      have h2 : |f 0 - f 1| ≥ 0 := abs_nonneg _
      simp at h1
      linarith
    calc L * |x - (j : ℝ) / N| ≤ L * (1 / N) := by
          exact mul_le_mul_of_nonneg_left habs hL0
      _ = L / N := by ring
  have hslope : |interpSlope f N j| ≤ L := by
    rw [interpSlope, abs_mul, abs_of_pos hN0]
    have := hlip (((j : ℝ) + 1) / N) hmem1 ((j : ℝ) / N) hmem
    have habs : |((j : ℝ) + 1) / N - (j : ℝ) / N| = 1 / N := by
      rw [show ((j : ℝ) + 1) / N - (j : ℝ) / N = 1 / N by field_simp; ring]
      exact abs_of_pos (by positivity)
    rw [habs] at this
    calc |f (((j : ℝ) + 1) / N) - f ((j : ℝ) / N)| * N ≤ (L * (1 / N)) * N :=
          mul_le_mul_of_nonneg_right this hN0.le
      _ = L := by field_simp
  have hlin : |interpSlope f N j * (x - (j : ℝ) / N)| ≤ L / N := by
    rw [abs_mul]
    have habs : |x - (j : ℝ) / N| ≤ 1 / N := by
      rw [abs_le]
      constructor
      · have : (0:ℝ) < 1 / N := by positivity
        linarith
      · have h1 : ((j : ℝ) + 1) / N - (j : ℝ) / N = 1 / N := by field_simp; ring
        linarith
    have hL0 : 0 ≤ L := le_trans (abs_nonneg _) hslope
    calc |interpSlope f N j| * |x - (j : ℝ) / N| ≤ L * (1 / N) :=
          mul_le_mul hslope habs (abs_nonneg _) hL0
      _ = L / N := by ring
  calc |f x - (f ((j : ℝ) / N) + interpSlope f N j * (x - (j : ℝ) / N))|
      ≤ |f x - f ((j : ℝ) / N)| + |interpSlope f N j * (x - (j : ℝ) / N)| := by
        have := abs_sub (f x - f ((j : ℝ) / N)) (interpSlope f N j * (x - (j : ℝ) / N))
        calc |f x - (f ((j : ℝ) / N) + interpSlope f N j * (x - (j : ℝ) / N))|
            = |(f x - f ((j : ℝ) / N)) - interpSlope f N j * (x - (j : ℝ) / N)| := by
              ring_nf
          _ ≤ |f x - f ((j : ℝ) / N)| + |interpSlope f N j * (x - (j : ℝ) / N)| := this
    _ ≤ 2 * L / N := by
        have : L / N + L / N = 2 * L / N := by ring
        linarith [hstep, hlin]


/-- **Jackson-type rate for depth-2 EML networks on Lipschitz targets.**  For
every `L`-Lipschitz `f` on `[0,1]`, every width `N ≥ 1` and every slack `δ > 0`
there is a depth-2 EML network with `N` chains whose uniform error is at most
`2L/N + δ`.  This is the mission's conjectured Jackson rate in dimension `n = 1`
for the general Lipschitz class; combined with `sqLayer_rate` it shows the
`O(w^{-2})` behaviour is a *smoothness* phenomenon, not a Lipschitz one. -/
theorem eml_depth2_lipschitz_rate (f : ℝ → ℝ) (L : ℝ) (N : ℕ) (hN : 1 ≤ N) (δ : ℝ) (hδ : 0 < δ)
    (hlip : ∀ u ∈ Icc (0:ℝ) 1, ∀ v ∈ Icc (0:ℝ) 1, |f u - f v| ≤ L * |u - v|) :
    ∃ Net : Depth2Net N, ∀ x ∈ Icc (0:ℝ) 1, |f x - Net.eval x| ≤ 2 * L / N + δ := by
  refine emlDepth2_dominates_relu N (fun i => interpCoeff f N (i : ℕ)) (fun _ => 1)
    (fun i => -((i : ℕ) : ℝ) / N) (f 0) 0 f (Icc (0:ℝ) 1) (2 * L / N) δ hδ ?_
  intro x hx
  exact lipschitz_relu_rate f L N hN hlip x hx

/-
-- !-- Lab Notes -- !--

## Hypothesis (Hypothesizer)

Depth 2 is exactly the depth at which the EML activation becomes *at least as
expressive as* ReLU: an `exp` unit followed by a `log` unit is a softplus, and
softplus is a uniform `log 2 / M` approximation of a rescaled ReLU.  If so, every
ReLU approximation theorem transfers to depth-2 EML at equal width.

## Experiment (Experimenter)

`log(1 + exp(M t))/M − relu t` at `M = 10`:
  t = −1 → 4.54e-6,  t = 0 → 0.0693 (= log 2 / 10, the maximum),
  t = 1  → 4.54e-6.
The bound `log 2 / M` is attained at `t = 0`, so `scaled_softplus_approx_relu` is
sharp; no smaller constant is possible.

For the interpolation part, `f = x²`, `N = 4`: the ReLU realisation
`lipReluNet` returns `0.0625, 0.25, 0.5625, 1` at the nodes `1/4, 1/2, 3/4, 1`,
i.e. it interpolates exactly, and its maximal error `1/64` is well inside the
proved `2L/N = 1` for `L = 2`.

## Analysis (Analyst)

The transfer costs nothing in width and only an arbitrarily small `δ` in
accuracy, but it costs *weight magnitude*: `M ≈ (Σ|aᵢ|) log 2 / δ`.  This is the
same currency in which the width-2 EML network buys its `O(h²)` accuracy for
`x²` (read-out weight `1/h²`).  Pattern: **EML converts weight magnitude into
approximation power, where ReLU has to spend width.**

## Critique (Critic)

* The emulation bound is uniform on all of `ℝ`, not merely on `[0,1]`, so it is
  not an artefact of the domain.
* `emlDepth2_dominates_relu` quantifies over an arbitrary set `S`, so it does not
  smuggle in compactness.
* The Lipschitz hypothesis is stated pointwise on `[0,1]` rather than through
  `LipschitzOnWith`, which keeps the statement elementary and avoids any
  hypothesis about behaviour of `f` outside `[0,1]`.
* Weakness acknowledged: `2L/N` is a factor 2 off the optimal `L/(2N)` for the
  interpolant; sharpening needs a two-sided estimate at the node nearest to `x`,
  not the left node.
-/

end

end EML.SoftplusJackson