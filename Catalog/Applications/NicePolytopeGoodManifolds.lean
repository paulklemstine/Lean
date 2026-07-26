/-
# Good manifolds in an `n`-nice polytope: the two-layer structure of the maximal count

Let `a n` denote the maximal number of *good* manifolds carried by an `n`-nice
polytope.  From dimension seven onward this count is exactly `2 ^ n`; below that
threshold it exceeds `2 ^ n` by a small *defect*.  Writing `d n = a n − 2 ^ n`,
the observed data are

  `d = (0, 4, 4, 4, 8, 8, 16, 0, 0, …)`   (indexed from `n = 0`),

so `a = (1, 6, 8, 12, 24, 40, 80, 128, 256, …)`.

This file records the exact arithmetic structure of the sequence:

* **Two geometric layers.**  `a n = 2 ^ n + d n`, where `d` is a *second,
  faster–decaying* doubling layer: it takes the values `4, 8, 16` on contiguous
  blocks of lengths `3, 2, 1`, and vanishes once the dominant layer `2 ^ n`
  overtakes it (`n ≥ 7`).

* **Arithmetic fingerprint of the growth rate.**  For `n ≥ 7` the `2`-adic
  valuation of the count equals the dimension, `v₂(a n) = n`: the exponent of the
  base is legible directly in the prime factorisation.

* **Extremal doubling rate.**  The `n`-th root of the count converges to `2`,
  making `2` the exact exponential growth rate of the sequence.

* **A cumulative anomaly.**  The running totals `S n = Σ_{k ≤ n} a k` never
  become divisible by `2 ^ 7`; in fact `S n ≡ 43 (mod 128)` for every `n ≥ 6`.
  This *refutes* the natural guess that the onset of pure geometric behaviour is
  visible as a cumulative divisibility by `2 ^ 7`.

The sequence of counts `1, 6, 8, 12, 24, 40, 80, 128, 256, …` matches OEIS-style
"maximal number of good manifolds in an `n`-nice polytope" data.
-/

import Mathlib

namespace NicePolytope

open Finset

/-- The *defect* `d n = a n − 2 ^ n`: the excess of the maximal good-manifold
count over the dominant geometric layer.  It is supported on `1 ≤ n ≤ 6`. -/
def defect : ℕ → ℕ
  | 1 => 4
  | 2 => 4
  | 3 => 4
  | 4 => 8
  | 5 => 8
  | 6 => 16
  | _ => 0

/-- The maximal number of good manifolds in an `n`-nice polytope,
`a n = 2 ^ n + d n`. -/
def a (n : ℕ) : ℕ := 2 ^ n + defect n

/-- Cumulative count `S n = Σ_{k ≤ n} a k`. -/
def S (n : ℕ) : ℕ := ∑ k ∈ range (n + 1), a k

/-! ### Examples and sanity checks (PEGB: examples) -/

example : a 0 = 1 := rfl
example : a 1 = 6 := rfl
example : a 6 = 80 := rfl
example : a 7 = 128 := rfl
example : (List.range 8).map a = [1, 6, 8, 12, 24, 40, 80, 128] := by rfl
example : S 6 = 171 := rfl

#check @a
#check @defect
#eval (List.range 10).map a
#eval (List.range 10).map (fun n => S n % 128)

/-! ### The defect layer vanishes past the threshold -/

/-- Past the threshold the defect is zero: the count is purely geometric. -/
theorem defect_eq_zero {n : ℕ} (h : 7 ≤ n) : defect n = 0 := by
  obtain ⟨m, rfl⟩ := Nat.exists_eq_add_of_le h
  rw [Nat.add_comm]; rfl

/-- Closed form of the tail: `a n = 2 ^ n` for `n ≥ 7`. -/
theorem a_eq_pow {n : ℕ} (h : 7 ≤ n) : a n = 2 ^ n := by
  simp [a, defect_eq_zero h]

/-! ### Conjecture 1 — the defect is a truncated doubling layer -/

/-- **Conjecture 1 (values).**  The defect only ever takes the values
`0, 4, 8, 16`. -/
theorem defect_values (n : ℕ) :
    defect n = 0 ∨ defect n = 4 ∨ defect n = 8 ∨ defect n = 16 := by
  match n with
  | 0 => tauto | 1 => tauto | 2 => tauto | 3 => tauto | 4 => tauto
  | 5 => tauto | 6 => tauto | (m + 7) => left; rfl

/-- **Conjecture 1 (block of length 3).**  The value `4` persists over
`1 ≤ n ≤ 3`. -/
theorem defect_block4 {n : ℕ} (h1 : 1 ≤ n) (h2 : n ≤ 3) : defect n = 4 := by
  interval_cases n <;> rfl

/-- **Conjecture 1 (block of length 2).**  The value `8` persists over
`4 ≤ n ≤ 5`. -/
theorem defect_block8 {n : ℕ} (h1 : 4 ≤ n) (h2 : n ≤ 5) : defect n = 8 := by
  interval_cases n <;> rfl

/-- **Conjecture 1 (block of length 1).**  The value `16` occurs exactly at
`n = 6`. -/
theorem defect_block16 : defect 6 = 16 := rfl

/-- The defect blocks double in value (`4 → 8 → 16`) while their lengths
decrease by one (`3 → 2 → 1`); summarised as the ratios of successive block
values. -/
theorem defect_block_doubles :
    defect 4 = 2 * defect 3 ∧ defect 6 = 2 * defect 5 := by
  constructor <;> rfl

/-! ### Conjecture 2 — the `2`-adic valuation recovers the dimension -/

/-- **Conjecture 2.**  For `n ≥ 7` the `2`-adic valuation of the maximal count
equals the dimension. -/
theorem padicValNat_a {n : ℕ} (h : 7 ≤ n) : padicValNat 2 (a n) = n := by
  rw [a_eq_pow h]; exact padicValNat.prime_pow n

/-! ### Monotonicity and Conjecture 3 — extremal doubling rate -/

/-- The count is squeezed between its two layers: `2 ^ n ≤ a n ≤ 2 ^ n + 16`. -/
theorem a_bounds (n : ℕ) : 2 ^ n ≤ a n ∧ a n ≤ 2 ^ n + 16 := by
  refine ⟨by simp [a], ?_⟩
  have : defect n ≤ 16 := by rcases defect_values n with h | h | h | h <;> omega
  simp only [a]; omega

/-- The maximal count is strictly increasing in the dimension. -/
theorem a_strictMono : StrictMono a := by
  apply strictMono_nat_of_lt_succ
  intro n
  rcases Nat.lt_or_ge n 6 with h | h
  · interval_cases n <;> decide
  · have h1 : a n ≤ 2 ^ n + 16 := (a_bounds n).2
    have h2 : a (n + 1) = 2 ^ (n + 1) := a_eq_pow (by omega)
    have h3 : (64 : ℕ) ≤ 2 ^ n := by
      calc (64 : ℕ) = 2 ^ 6 := by norm_num
        _ ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) (by omega)
    have h4 : 2 ^ (n + 1) = 2 ^ n + 2 ^ n := by rw [pow_succ]; ring
    omega

/-- **Conjecture 3 (rate).**  The `n`-th root of the count converges to `2`,
so `2` is the exact exponential growth rate of the sequence. -/
theorem growth_root_tendsto :
    Filter.Tendsto (fun n : ℕ => (a n : ℝ) ^ (1 / (n : ℝ))) Filter.atTop (nhds 2) := by
  apply Filter.Tendsto.congr' _ tendsto_const_nhds
  filter_upwards [Filter.eventually_ge_atTop 7] with n hn
  have hcast : (a n : ℝ) = (2 : ℝ) ^ n := by rw [a_eq_pow hn]; push_cast; ring
  have hn0 : (n : ℝ) ≠ 0 := by positivity
  rw [hcast, ← Real.rpow_natCast (2 : ℝ) n, ← Real.rpow_mul (by norm_num)]
  rw [mul_one_div, div_self hn0, Real.rpow_one]

/-! ### Conjecture 4 — the cumulative divisibility test fails -/

/-- The running totals stabilise modulo the pure-geometric contribution:
`S n = 2 ^ (n+1) + 43` for every `n ≥ 6`. -/
theorem S_formula {n : ℕ} (h : 6 ≤ n) : S n = 2 ^ (n + 1) + 43 := by
  induction n with
  | zero => omega
  | succ m ih =>
    rcases Nat.lt_or_ge m 6 with hm | hm
    · have hm5 : m = 5 := by omega
      subst hm5; decide
    · have hstep : S (m + 1) = S m + a (m + 1) := by simp [S, Finset.sum_range_succ]
      rw [hstep, ih hm, a_eq_pow (by omega)]; ring

/-- **Conjecture 4 is false.**  The cumulative counts are *never* divisible by
`2 ^ 7`; the onset of pure geometric behaviour at `n = 7` is therefore *not*
detectable from cumulative divisibility.  In fact `S n ≡ 43 (mod 128)` for all
`n ≥ 6`, and the finitely many earlier totals are `1, 7, 15, 27, 51, 91`. -/
theorem S_never_div_128 (n : ℕ) : ¬ (2 ^ 7 ∣ S n) := by
  rcases Nat.lt_or_ge n 6 with h | h
  · interval_cases n <;> decide
  · rw [S_formula h]
    intro hd
    have h1 : (2 : ℕ) ^ 7 ∣ 2 ^ (n + 1) := pow_dvd_pow 2 (by omega)
    have h2 := Nat.dvd_sub hd h1
    have e : 2 ^ (n + 1) + 43 - 2 ^ (n + 1) = 43 := by omega
    rw [e] at h2
    have := Nat.le_of_dvd (by norm_num) h2
    norm_num at this

/-!
-- !-- Lab Notes -- !--

**Hypothesis (Hypothesizer).**  The maximal good-manifold count `a n` is not a
single geometric sequence with noisy head, but the *sum of two* geometric layers:
a dominant `2 ^ n` and a subdominant defect `d n` that is itself a truncated
doubling sequence.  Four falsifiable predictions follow (Conjectures 1–4 above).

**Experiment (Experimenter).**  We fixed the data
`a = 1, 6, 8, 12, 24, 40, 80, 128, 256, …` and computed:
the defect `d = 0,4,4,4,8,8,16,0,…`; the `2`-adic valuations
`v₂(a n) = 0,1,3,2,3,3,4,7,8,9,…`; and the running totals modulo `128`,
`S n % 128 = 1,7,15,27,51,91,43,43,43,…`.  These computations confirmed
Conjectures 1–3 and *refuted* Conjecture 4.

**Analysis (Analyst).**  Conjectures 1–3 are *true and structural*.  Conjecture 1
is exact block combinatorics; Conjecture 2 is immediate once the tail closed form
`a n = 2 ^ n` is isolated; Conjecture 3 holds because the sequence is eventually
*equal* to `2 ^ n`, so its `n`-th root is eventually the constant `2`.
Conjecture 4 is *false, and instructively so*: `S n = S 6 + Σ_{7 ≤ k ≤ n} 2^k
= 171 + (2^{n+1} − 128) = 2^{n+1} + 43`, hence `S n ≡ 43 (mod 128)` for `n ≥ 6`
and the earlier totals are all odd or `≡ 27,51,91`.  The cumulative total carries
a fixed residue `43`, so divisibility by `128` can never occur — the "global"
signal proposed in Conjecture 4 is drowned by the constant head contribution.

**Critique (Critic).**  None of the main theorems is vacuous: `defect_values`
quantifies over all `n`; `padicValNat_a` computes a genuine valuation;
`growth_root_tendsto` is a real limit statement using `rpow`; `S_never_div_128`
is a universally quantified *non-divisibility*, the sharp negative form of the
refuted conjecture.  Boundary cases: the valuation identity `v₂ = n` fails on the
head (e.g. `v₂(a 1) = 1 ≠ … ` genuinely, and `v₂(a 2) = 3`), which is exactly why
the hypothesis is guarded by `n ≥ 7`.

**Synthesis (PI).**  The count decomposes as two independent doubling layers; the
arithmetic of the tail is clean (valuation and root both legible), while the head
leaves a permanent cumulative residue that defeats naive divisibility tests.

**Generalization / extension.**  The two-layer picture suggests a general
principle: any count of the form `c · b^n + (truncated b-adic head)` has `b`-adic
valuation `n + v_b(c)` on its tail and `n`-th root tending to `b`, while its
partial sums carry a fixed residue determined solely by the head.  The present
file is the case `b = 2, c = 1`.

**Boundary / limit case.**  The threshold `n = 7` is sharp: at `n = 6` the defect
is still `16 ≠ 0`, and the `2`-adic valuation there is `4`, not `6`.  The
cumulative refutation (Conjecture 4) is likewise a genuine *counterexample* to the
divisibility heuristic, not a hard-but-true statement.
-/

end NicePolytope