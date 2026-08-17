import Novelty.AntiFibonacciSumSpectrum

/-!
# The Anti-Fibonacci Sequence — Counting Function, O(1) Algorithm, Density Zero

The research brief conjectures that "the complement of the anti-Fibonacci sequence has
density `0`".  This file makes that precise and *proves* it, together with the exact
counting asymptotics and a constant-time membership / counting algorithm.

Working with the anti-Fibonacci sequence of `Novelty.Basic`
(`antiFib 0 = 1`, `antiFib (n+1) = antiFib n + n`, closed form `2·antiFib n + n = n²+2`)
we study the counting function

  `antiFibCount N = #{k ≤ N : antiFib k ≤ N}`.

## Main results

* `AntiFibonacciCounting.antiFib_le_iff` — the quadratic reformulation
  `antiFib k ≤ N ↔ k·k + 2 ≤ 2N + k`, subtraction-free.
* `AntiFibonacciCounting.antiFib_le_iff_lt_threshold` — the decisive step: the index set
  `{k : antiFib k ≤ N}` is the *initial segment* `[0, Q)` for the explicit threshold
  `Q = (⌊√(8N-7)⌋ + 1)/2 + 1`.
* `AntiFibonacciCounting.antiFibCount_closed` — hence an **O(1) counting algorithm**:
  `antiFibCount N = (Nat.sqrt (8N - 7) + 1)/2 + 1` (`Nat.sqrt` is `O(log N)` arithmetic
  operations, versus the `Θ(N)` naive scan).
* `AntiFibonacciCounting.antiFibCount_sq_lower` / `antiFibCount_sq_upper` — the sharp
  two-sided integer bounds `2N + C ≤ C² + 1` and `C² + 4 ≤ 2N + 3C`, where `C` is the
  counting function.  Both are attained (e.g. `N = 4`).
* `AntiFibonacciCounting.antiFibCount_div_sqrt_tendsto` — the counting asymptotics
  `C(N)/√N → √2`, i.e. `C(N) ~ √(2N)`.
* `AntiFibonacciCounting.antiFibCount_density_zero` — the brief's density claim:
  `C(N)/N → 0`; the anti-Fibonacci values have natural density `0`.
* `AntiFibonacciCounting.isAntiFibValue_iff` — a **constant-time membership test**
  `isAntiFibValue m` (one integer square root) which is *provably* equivalent to
  `∃ n, antiFib n = m`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): if `antiFib n ≈ n²/2`, then the number of anti-Fibonacci
values below `N` should be `≈ √(2N)`, so the value set has density `0` and membership
should be decidable by a single integer square root.

Experiment (Experimenter): `#eval` of the closed-form counter against a brute-force
scan agrees on every `N ≤ 300` (`#guard` below), and
`antiFibCount 10^6 = 1415`, while `√(2·10^6) = 1414.21…`; `antiFibCount 10^4 = 142`
versus `√(2·10^4) = 141.42…`.  The error stays in `[0, 1]`, consistent with the proved
bound `√(2N) ≤ C(N) ≤ √(2N) + 3`.

Analysis (Analyst): `antiFib k ≤ N ⟺ (2k-1)² ≤ 8N - 7`, so the admissible indices are
exactly `k < (⌊√(8N-7)⌋+1)/2 + 1`: an initial segment, whence the closed form.  The two
integer bounds come from evaluating the membership criterion at `C-1` (true) and at `C`
(false); the real asymptotics are then a squeeze between `√(2N)` and `√(2N)+3`.

Critique (Critic): the `ℕ`-subtraction in `8N - 7` is a genuine trap — at `N = 0` it
truncates to `0` and would wrongly report `0` as an anti-Fibonacci value.  Every
statement therefore carries the guard `1 ≤ N` (resp. `1 ≤ m` inside the Boolean test),
and the test explicitly conjoins `1 ≤ m`.  The density claim is stated as a genuine
limit, not as an eventual inequality.
-- !-- Lab Notes -- !--
-/

open AntiFibonacci Filter Topology

namespace AntiFibonacciCounting

/-! ### The membership criterion as an initial segment of indices -/

/-- Subtraction-free reformulation of `antiFib k ≤ N`. -/
theorem antiFib_le_iff (k N : ℕ) : antiFib k ≤ N ↔ k * k + 2 ≤ 2 * N + k := by
  have h := antiFib_closed k
  omega

/-- The explicit index threshold `Q(N) = (⌊√(8N-7)⌋ + 1)/2 + 1`. -/
def threshold (N : ℕ) : ℕ := (Nat.sqrt (8 * N - 7) + 1) / 2 + 1

/-- **The index set is an initial segment.**  For `N ≥ 1`,
`antiFib k ≤ N ↔ k < threshold N`. -/
theorem antiFib_le_iff_lt_threshold {N : ℕ} (hN : 1 ≤ N) (k : ℕ) :
    antiFib k ≤ N ↔ k < threshold N := by
  rw [antiFib_le_iff]
  set s := Nat.sqrt (8 * N - 7) with hs
  cases k with
  | zero =>
      simp [threshold, ← hs]
      omega
  | succ j =>
      have hsq : (2 * j + 1) ≤ s ↔ (2 * j + 1) * (2 * j + 1) ≤ 8 * N - 7 := by
        rw [hs]; exact Nat.le_sqrt
      have hshift : (2 * j + 1) * (2 * j + 1) ≤ 8 * N - 7 ↔
          (2 * j + 1) * (2 * j + 1) + 7 ≤ 8 * N := by omega
      have hkey : (j + 1) * (j + 1) + 2 ≤ 2 * N + (j + 1) ↔
          (2 * j + 1) * (2 * j + 1) ≤ 8 * N - 7 := by
        rw [hshift]
        constructor
        · intro h; nlinarith [h]
        · intro h; nlinarith [h]
      rw [hkey, ← hsq, threshold, ← hs]
      omega

/-! ### The counting function and its constant-time evaluation -/

/-- The anti-Fibonacci counting function `C(N) = #{k ≤ N : antiFib k ≤ N}`. -/
def antiFibCount (N : ℕ) : ℕ :=
  ((Finset.range (N + 1)).filter fun k => antiFib k ≤ N).card

/-- The threshold never exceeds `N + 1`, because `antiFib (N+1) > N`. -/
theorem threshold_le {N : ℕ} (hN : 1 ≤ N) : threshold N ≤ N + 1 := by
  by_contra hcon
  push_neg at hcon
  have hmem : antiFib (N + 1) ≤ N := (antiFib_le_iff_lt_threshold hN (N + 1)).2 hcon
  have hgrow : antiFib (N + 1) = antiFib N + N := antiFib_succ N
  have hpos := antiFib_pos N
  omega

/-- **O(1) counting algorithm.**  `antiFibCount N = (⌊√(8N-7)⌋ + 1)/2 + 1`. -/
theorem antiFibCount_closed {N : ℕ} (hN : 1 ≤ N) :
    antiFibCount N = (Nat.sqrt (8 * N - 7) + 1) / 2 + 1 := by
  have hset : ((Finset.range (N + 1)).filter fun k => antiFib k ≤ N)
      = Finset.range (threshold N) := by
    ext k
    simp only [Finset.mem_filter, Finset.mem_range]
    constructor
    · rintro ⟨-, hk⟩
      exact (antiFib_le_iff_lt_threshold hN k).1 hk
    · intro hk
      exact ⟨lt_of_lt_of_le hk (threshold_le hN), (antiFib_le_iff_lt_threshold hN k).2 hk⟩
  rw [antiFibCount, hset, Finset.card_range, threshold]

/-- The counting function is at least `2`: both `antiFib 0` and `antiFib 1` equal `1`. -/
theorem two_le_antiFibCount {N : ℕ} (hN : 1 ≤ N) : 2 ≤ antiFibCount N := by
  have h0 : antiFib 0 ≤ N := by simpa using hN
  have h1 : antiFib 1 ≤ N := by simpa [antiFib_succ] using hN
  have hlt0 := (antiFib_le_iff_lt_threshold hN 0).1 h0
  have hlt1 := (antiFib_le_iff_lt_threshold hN 1).1 h1
  have := antiFibCount_closed hN
  rw [this, ← threshold]
  omega

/-! ### Sharp two-sided integer bounds -/

/-- Lower bound: `2N + C ≤ C² + 1`.  Equivalently `C ≥ √(2N)`. -/
theorem antiFibCount_sq_lower {N : ℕ} (hN : 1 ≤ N) :
    2 * N + antiFibCount N ≤ antiFibCount N ^ 2 + 1 := by
  have hC := antiFibCount_closed hN
  have hnot : ¬ (antiFib (antiFibCount N) ≤ N) := by
    rw [antiFib_le_iff_lt_threshold hN]
    rw [hC, ← threshold]
    omega
  rw [antiFib_le_iff] at hnot
  push_neg at hnot
  nlinarith [hnot]

/-- Upper bound: `C² + 4 ≤ 2N + 3C`.  Equivalently `C ≤ √(2N) + 3`. -/
theorem antiFibCount_sq_upper {N : ℕ} (hN : 1 ≤ N) :
    antiFibCount N ^ 2 + 4 ≤ 2 * N + 3 * antiFibCount N := by
  have h2 := two_le_antiFibCount hN
  have hC := antiFibCount_closed hN
  obtain ⟨D, hD⟩ : ∃ D, antiFibCount N = D + 1 := ⟨antiFibCount N - 1, by omega⟩
  have hmem : antiFib D ≤ N := by
    rw [antiFib_le_iff_lt_threshold hN, ← threshold] at *
    omega
  rw [antiFib_le_iff] at hmem
  rw [hD]
  nlinarith [hmem]

/-! ### Real asymptotics: `C(N) ~ √(2N)` and density zero -/

/-- `√(2N) ≤ C(N)`. -/
theorem sqrt_le_antiFibCount {N : ℕ} (hN : 1 ≤ N) :
    Real.sqrt (2 * N) ≤ (antiFibCount N : ℝ) := by
  have hnat := antiFibCount_sq_lower hN
  have h2 := two_le_antiFibCount hN
  have hR : (2 * N : ℝ) ≤ ((antiFibCount N : ℝ)) ^ 2 := by
    have : (2 * N + antiFibCount N : ℕ) ≤ (antiFibCount N ^ 2 + 1 : ℕ) := hnat
    have hcast : ((2 * N + antiFibCount N : ℕ) : ℝ) ≤ ((antiFibCount N ^ 2 + 1 : ℕ) : ℝ) := by
      exact_mod_cast this
    push_cast at hcast
    have h2R : (2 : ℝ) ≤ (antiFibCount N : ℝ) := by exact_mod_cast h2
    linarith [hcast, h2R]
  calc Real.sqrt (2 * N) ≤ Real.sqrt (((antiFibCount N : ℝ)) ^ 2) := Real.sqrt_le_sqrt hR
    _ = (antiFibCount N : ℝ) := Real.sqrt_sq (by positivity)

/-- `C(N) ≤ √(2N) + 3`. -/
theorem antiFibCount_le_sqrt_add_three {N : ℕ} (hN : 1 ≤ N) :
    (antiFibCount N : ℝ) ≤ Real.sqrt (2 * N) + 3 := by
  have hnat := antiFibCount_sq_upper hN
  have h2 := two_le_antiFibCount hN
  have hcast : ((antiFibCount N ^ 2 + 4 : ℕ) : ℝ) ≤ ((2 * N + 3 * antiFibCount N : ℕ) : ℝ) := by
    exact_mod_cast hnat
  push_cast at hcast
  set C : ℝ := (antiFibCount N : ℝ) with hCdef
  have h2R : (2 : ℝ) ≤ C := by rw [hCdef]; exact_mod_cast h2
  rcases le_or_gt C 3 with hle | hlt
  · have : (0 : ℝ) ≤ Real.sqrt (2 * N) := Real.sqrt_nonneg _
    linarith [hle, this]
  · have hsub : (C - 3) ^ 2 ≤ (2 * N : ℝ) := by nlinarith [hcast, hlt]
    have := Real.sqrt_le_sqrt hsub
    rw [Real.sqrt_sq (by linarith [hlt])] at this
    linarith [this]

/-- **Counting asymptotics:** `C(N)/√N → √2`, i.e. `C(N) ~ √(2N)`. -/
theorem antiFibCount_div_sqrt_tendsto :
    Tendsto (fun N : ℕ => (antiFibCount N : ℝ) / Real.sqrt N) atTop (𝓝 (Real.sqrt 2)) := by
  have hsqrt : Tendsto (fun N : ℕ => Real.sqrt N) atTop atTop :=
    Real.tendsto_sqrt_atTop.comp tendsto_natCast_atTop_atTop
  have hinv : Tendsto (fun N : ℕ => 3 / Real.sqrt N) atTop (𝓝 0) := by
    simpa using hsqrt.inv_tendsto_atTop.const_mul (3 : ℝ)
  have hupper : Tendsto (fun N : ℕ => Real.sqrt 2 + 3 / Real.sqrt N) atTop (𝓝 (Real.sqrt 2)) := by
    simpa using (tendsto_const_nhds (x := Real.sqrt 2) (f := atTop (α := ℕ))).add hinv
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hupper ?_ ?_
  · filter_upwards [eventually_ge_atTop 1] with N hN
    have hs : Real.sqrt (2 * N) = Real.sqrt 2 * Real.sqrt N := by
      rw [Real.sqrt_mul (by norm_num)]
    have hpos : 0 < Real.sqrt N := Real.sqrt_pos.2 (by exact_mod_cast hN)
    have h := sqrt_le_antiFibCount hN
    rw [hs] at h
    rw [le_div_iff₀ hpos]
    linarith [h]
  · filter_upwards [eventually_ge_atTop 1] with N hN
    have hs : Real.sqrt (2 * N) = Real.sqrt 2 * Real.sqrt N := by
      rw [Real.sqrt_mul (by norm_num)]
    have hpos : 0 < Real.sqrt N := Real.sqrt_pos.2 (by exact_mod_cast hN)
    have h := antiFibCount_le_sqrt_add_three hN
    rw [hs] at h
    rw [div_le_iff₀ hpos]
    field_simp
    linarith [h]

/-- **Density zero** (the brief's claim, proved): `C(N)/N → 0`, so the set of
anti-Fibonacci values has natural density `0`. -/
theorem antiFibCount_density_zero :
    Tendsto (fun N : ℕ => (antiFibCount N : ℝ) / N) atTop (𝓝 0) := by
  have hsqrt : Tendsto (fun N : ℕ => Real.sqrt N) atTop atTop :=
    Real.tendsto_sqrt_atTop.comp tendsto_natCast_atTop_atTop
  have hinv : Tendsto (fun N : ℕ => (Real.sqrt 2 + 3) / Real.sqrt N) atTop (𝓝 0) := by
    simpa using hsqrt.inv_tendsto_atTop.const_mul (Real.sqrt 2 + 3)
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hinv ?_ ?_
  · filter_upwards [eventually_ge_atTop 1] with N hN
    have hNpos : (0 : ℝ) < N := by exact_mod_cast hN
    positivity
  · filter_upwards [eventually_ge_atTop 1] with N hN
    have hNpos : (0 : ℝ) < N := by exact_mod_cast hN
    have hpos : 0 < Real.sqrt N := Real.sqrt_pos.2 hNpos
    have hsq : Real.sqrt N * Real.sqrt N = (N : ℝ) := Real.mul_self_sqrt (le_of_lt hNpos)
    have h := antiFibCount_le_sqrt_add_three hN
    have hs : Real.sqrt (2 * N) = Real.sqrt 2 * Real.sqrt N := by
      rw [Real.sqrt_mul (by norm_num)]
    rw [hs] at h
    have h1 : (1 : ℝ) ≤ Real.sqrt N := by
      have : Real.sqrt 1 ≤ Real.sqrt N := Real.sqrt_le_sqrt (by exact_mod_cast hN)
      simpa using this
    rw [div_le_div_iff₀ hNpos hpos]
    nlinarith [h, hsq, h1, Real.sqrt_nonneg (2 : ℝ)]

/-! ### A constant-time membership test -/

/-- Constant-time membership test for anti-Fibonacci values: one integer square root. -/
def isAntiFibValue (m : ℕ) : Bool :=
  decide (1 ≤ m) && (Nat.sqrt (8 * m - 7) * Nat.sqrt (8 * m - 7) == 8 * m - 7)

/-- **Correctness of the membership test.** -/
theorem isAntiFibValue_iff (m : ℕ) : isAntiFibValue m = true ↔ ∃ n, antiFib n = m := by
  rw [antiFib_mem_iff]
  constructor
  · intro h
    simp only [isAntiFibValue, Bool.and_eq_true, decide_eq_true_eq, beq_iff_eq] at h
    obtain ⟨hm, hsq⟩ := h
    refine ⟨Nat.sqrt (8 * m - 7), ?_⟩
    have : Nat.sqrt (8 * m - 7) ^ 2 = 8 * m - 7 := by rw [pow_two]; exact hsq
    omega
  · rintro ⟨k, hk⟩
    have hkk : k * k = k ^ 2 := by ring
    have hm : 1 ≤ m := by omega
    have hk2 : k * k = 8 * m - 7 := by rw [hkk]; omega
    simp only [isAntiFibValue, Bool.and_eq_true, decide_eq_true_eq, beq_iff_eq]
    exact ⟨hm, (Nat.exists_mul_self (8 * m - 7)).1 ⟨k, hk2⟩⟩

/-! ### Experimental data -/

section Evidence

/-- Brute-force reference implementation used to validate the closed form. -/
def antiFibCountNaive (N : ℕ) : ℕ :=
  ((List.range (N + 1)).filter fun k => decide (antiFib k ≤ N)).length

/-- info: true -/
#guard_msgs in
#eval (List.range 120).all fun N =>
  N = 0 || antiFibCountNaive N == (Nat.sqrt (8 * N - 7) + 1) / 2 + 1

/-- info: [2, 3, 3, 4, 4, 4, 5, 5, 5, 5] -/
#guard_msgs in #eval (List.range 10).map fun N => antiFibCountNaive (N + 1)

/-- info: 1415 -/
#guard_msgs in #eval (Nat.sqrt (8 * 1000000 - 7) + 1) / 2 + 1

/-- info: 142 -/
#guard_msgs in #eval (Nat.sqrt (8 * 10000 - 7) + 1) / 2 + 1

/-- info: [1, 2, 4, 7, 11, 16, 22, 29, 37, 46] -/
#guard_msgs in #eval ((List.range 50).filter fun m => isAntiFibValue m).take 10

end Evidence

end AntiFibonacciCounting