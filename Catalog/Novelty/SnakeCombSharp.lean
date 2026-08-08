/-
# The sharp comb bound and an improved snake growth constant

`Novelty/SnakeGridComb.lean` builds, out of a snake of `Q m` with an *even*
number `2q` of edges and a snake of `Q n` with `M` edges, a snake of `Q (m+n)`
with `q * (M + 2) + M` edges, and then records the consequence in the rounded
form

> `maxLen_mul_le : maxLen m * maxLen n ≤ 2 * maxLen (m + n)`.

That rounding throws away the two additive terms `2 * maxLen m` and
`maxLen n`, which is exactly the loss the previous cycle listed as
"sub-conjecture 3".  This file keeps them:

> `maxLen_mul_le_sharp :
>    maxLen m * maxLen n + 2 * maxLen m + maxLen n ≤ 2 * maxLen (m + n) + 2`.

The gain is not cosmetic.  Feeding the kernel-verified seeds of
`Novelty/SnakeSeedSeven.lean` into the sharp bound and iterating gives a
strictly larger exponential base than `maxLen_exponential`, and — through a
general "one verified snake bounds the constant" lemma
(`snakeGrowth_ge_of_maxLen`) — a strictly better lower bracket for the growth
constant `snakeGrowth` of `Novelty/SnakeGrowthConstant.lean`.
-/
import Mathlib
import Computation.SnakeInTheBox
import Computation.SnakeMax
import Novelty.SnakeGridComb
import Novelty.SnakeGrowthConstant

namespace SnakeInTheBox

open Filter Topology

variable {m n : ℕ}

/-! ## Step 1: the comb bound without rounding -/

/-- **The sharp comb bound.**  Combing a maximal snake of `Q m` (truncated to an even
length) through a maximal snake of `Q n` produces a snake of `Q (m + n)` with
`⌊maxLen m / 2⌋ · (maxLen n + 2) + maxLen n` edges. -/
theorem maxLen_comb_sharp (m n : ℕ) :
    maxLen m / 2 * (maxLen n + 2) + maxLen n ≤ maxLen (m + n) := by
  obtain ⟨s⟩ := exists_snake_maxLen m
  obtain ⟨t⟩ := exists_snake_maxLen n
  have hq : 2 * (maxLen m / 2) ≤ maxLen m := by omega
  exact le_maxLen ((s.truncate hq).comb t)

/-- **The product theorem, sharpened.**  The rounded form
`maxLen m · maxLen n ≤ 2 · maxLen (m + n)` of `Novelty/SnakeGridComb.lean` gains the two
linear terms `2 · maxLen m + maxLen n` on the left. -/
theorem maxLen_mul_le_sharp (m n : ℕ) :
    maxLen m * maxLen n + 2 * maxLen m + maxLen n ≤ 2 * maxLen (m + n) + 2 := by
  have h := maxLen_comb_sharp m n
  have h2 : 2 * (maxLen m / 2) ≤ maxLen m := by omega
  have h3 : maxLen m ≤ 2 * (maxLen m / 2) + 1 := by omega
  nlinarith [h, h2, h3, Nat.zero_le (maxLen n)]

/-- The sharp bound is at least as strong as the rounded one. -/
theorem maxLen_mul_le_of_sharp (m n : ℕ) : maxLen m * maxLen n ≤ 2 * maxLen (m + n) := by
  have h := maxLen_mul_le_sharp m n
  rcases Nat.eq_zero_or_pos (maxLen m) with hm | hm
  · simp [hm]
  · omega

/-- Doubling the dimension: a verified snake of `Q k` with `N` edges yields a snake of
`Q (k + k)` with `⌊N/2⌋ · (N + 2) + N` edges. -/
theorem maxLen_double_ge {k N : ℕ} (h : N ≤ maxLen k) :
    N / 2 * (N + 2) + N ≤ maxLen (k + k) := by
  have hdiv : N / 2 ≤ maxLen k / 2 := Nat.div_le_div_right h
  have hmul : N / 2 * (N + 2) ≤ maxLen k / 2 * (maxLen k + 2) :=
    Nat.mul_le_mul hdiv (by omega)
  have := maxLen_comb_sharp k k
  omega

/-! ## Step 2: one verified snake gives an exponential lower bound -/

/-- **One verified snake is a growth step.**  A snake of `Q k` with an even number
`N ≥ 2` of edges multiplies the maximal length by `N/2 + 1` every `k` dimensions.
Compare `Snake.lift2`, which only *adds* two edges per dimension. -/
theorem maxLen_step_of_seed {k N : ℕ} (hN : 2 ≤ N) (hNe : N % 2 = 0) (h : N ≤ maxLen k)
    (p : ℕ) : (N / 2 + 1) * maxLen p ≤ maxLen (p + k) := by
  have hcomb := maxLen_comb_sharp p k
  set F := maxLen p with hF
  set a := F / 2 with ha
  have ha2 : F ≤ 2 * a + 1 := by omega
  -- the seed only enters through `N`
  have hkey : (N / 2 + 1) * F ≤ a * (N + 2) + N := by
    have hNN : N = 2 * (N / 2) := by omega
    nlinarith [ha2, Nat.zero_le a, Nat.zero_le (N / 2)]
  have hstep : a * (N + 2) + N ≤ a * (maxLen k + 2) + maxLen k := by
    have := Nat.mul_le_mul_left a (by omega : N + 2 ≤ maxLen k + 2)
    omega
  calc (N / 2 + 1) * F ≤ a * (N + 2) + N := hkey
    _ ≤ a * (maxLen k + 2) + maxLen k := hstep
    _ ≤ maxLen (p + k) := hcomb

/-- **From one snake to an exponential bound.**  A snake of `Q k` with an even number
`N ≥ 2` of edges forces `maxLen n ≥ (N/2 + 1) ^ ⌊n/k⌋` for every `n ≥ k`: the base of the
exponential is `((N+2)/2) ^ (1/k)`, whereas the rounded product theorem only gives
`(N/2) ^ (1/k)`. -/
theorem maxLen_exp_of_seed {k N : ℕ} (hk : 1 ≤ k) (hN : 2 ≤ N) (hNe : N % 2 = 0)
    (h : N ≤ maxLen k) {n : ℕ} (hn : k ≤ n) : (N / 2 + 1) ^ (n / k) ≤ maxLen n := by
  set c := N / 2 + 1 with hc
  have hcN : c ≤ N := by omega
  have hblock : ∀ a : ℕ, 1 ≤ a → N * c ^ (a - 1) ≤ maxLen (k * a) := by
    intro a
    induction a with
    | zero => intro h0; omega
    | succ q ih =>
        intro _
        rcases Nat.eq_zero_or_pos q with hq | hq
        · subst hq; simpa using h
        · have ihq := ih hq
          have hstep := maxLen_step_of_seed hN hNe h (k * q)
          have hdim : k * q + k = k * (q + 1) := by ring
          rw [hdim] at hstep
          have hmul : c * (N * c ^ (q - 1)) ≤ c * maxLen (k * q) := Nat.mul_le_mul_left c ihq
          have hpow : N * c ^ (q + 1 - 1) = c * (N * c ^ (q - 1)) := by
            have hq1 : q + 1 - 1 = (q - 1) + 1 := by omega
            rw [hq1, pow_succ]
            ring
          rw [hpow]
          exact hmul.trans hstep
  have ha : 1 ≤ n / k := Nat.one_le_div_iff (by omega) |>.mpr hn
  have hb := hblock (n / k) ha
  have hmono : maxLen (k * (n / k)) ≤ maxLen n := by
    refine maxLen_mono ?_
    rw [Nat.mul_comm]
    exact Nat.div_mul_le_self n k
  have hcc : c ^ (n / k) ≤ N * c ^ (n / k - 1) := by
    have h1 : c ^ (n / k) = c * c ^ (n / k - 1) := by
      have : n / k = (n / k - 1) + 1 := by omega
      rw [this, pow_succ]
      have : n / k - 1 + 1 - 1 = n / k - 1 := by omega
      rw [this]
      ring
    have h2 : c * c ^ (n / k - 1) ≤ N * c ^ (n / k - 1) :=
      Nat.mul_le_mul_right _ hcN
    omega
  exact hcc.trans (hb.trans hmono)

/-! ## Step 3: one verified snake bounds the growth constant -/

/-- **A verified snake bounds the constant.**  If some `Q k` contains a snake with `N`
edges then `snakeGrowth ≥ (N/2) ^ (1/k)`.  This is the general form of
`snakeGrowth_ge`, which is the case `k = 7`, `N = 47`. -/
theorem snakeGrowth_ge_of_maxLen {k N : ℕ} (hk : 1 ≤ k) (hN : 2 ≤ N) (h : N ≤ maxLen k) :
    ((N : ℝ) / 2) ^ ((k : ℝ)⁻¹) ≤ snakeGrowth := by
  have hNR : (2 : ℝ) ≤ (N : ℝ) := by exact_mod_cast hN
  have hpos : (0 : ℝ) < (N : ℝ) / 2 := by linarith
  have hhalf : (N : ℝ) / 2 ≤ halfLen k := by
    have : (N : ℝ) ≤ (maxLen k : ℝ) := by exact_mod_cast h
    simp only [halfLen]
    linarith
  have hlog : Real.log ((N : ℝ) / 2) ≤ Real.log (halfLen k) := Real.log_le_log hpos hhalf
  have hU : snakeU k ≤ -Real.log ((N : ℝ) / 2) := by
    simp only [snakeU]; linarith
  have hkR : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk
  have hlim : Subadditive.lim snakeU_subadditive ≤ snakeU k / (k : ℕ) :=
    snakeU_subadditive.lim_le_div snakeU_bddBelow (by omega)
  have hstep : snakeU k / (k : ℝ) ≤ -Real.log ((N : ℝ) / 2) / (k : ℝ) := by
    gcongr
  have hlim' : Subadditive.lim snakeU_subadditive ≤ -Real.log ((N : ℝ) / 2) / k := by
    refine hlim.trans ?_
    simpa using hstep
  rw [neg_div] at hlim'
  have hexp : Real.exp (Real.log ((N : ℝ) / 2) / k) ≤ snakeGrowth := by
    simp only [snakeGrowth]
    exact Real.exp_le_exp.2 (by linarith)
  have hrpow : ((N : ℝ) / 2) ^ ((k : ℝ)⁻¹) = Real.exp (Real.log ((N : ℝ) / 2) / k) := by
    rw [Real.rpow_def_of_pos hpos]
    ring_nf
  rw [hrpow]
  exact hexp

end SnakeInTheBox