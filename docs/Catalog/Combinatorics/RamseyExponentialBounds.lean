import Mathlib

/-!
# Exponential bounds for diagonal Ramsey numbers: the analytic interface

This file isolates the final quantitative step used by sub-four diagonal Ramsey
bounds.  The combinatorial part of such an argument typically produces a fixed
multiplicative saving `q < 1` per clique size, giving a bound `(4q)^k`.  The
results below convert that estimate, without asymptotic notation, into the
standard form `(4 - ε)^k` with one fixed `ε > 0`.

The development is deliberately parameterized by the catalog's Ramsey-number
sequence: it makes no new graph or Ramsey-number definition.  Consequently the
lemmas can be applied directly to any existing encoding of diagonal Ramsey
numbers.
-/

namespace RamseyBounds

/-- A sequence has an eventual diagonal-Ramsey-style upper bound with base
strictly below four. -/
def HasSubFourUpperBound (r : ℕ → ℕ) : Prop :=
  ∃ ε : ℝ, 0 < ε ∧ ε < 4 ∧ ∃ k₀ : ℕ, ∀ k ≥ k₀, (r k : ℝ) ≤ (4 - ε) ^ k

/-- A fixed proportional saving over the classical base four. -/
def HasProportionalSaving (r : ℕ → ℕ) : Prop :=
  ∃ q : ℝ, 0 < q ∧ q < 1 ∧ ∃ k₀ : ℕ, ∀ k ≥ k₀, (r k : ℝ) ≤ (4 * q) ^ k

/-- The exact change of variables between a proportional saving `q` and an
additive saving `ε`. -/
theorem four_mul_eq_four_sub_saving {q : ℝ} :
    4 * q = 4 - 4 * (1 - q) := by
  ring

/-- A positive proportional saving produces a positive additive gap below four.
This is the final algebraic passage from a bound of the shape `(4q)^k` to the
usual `(4-ε)^k` formulation. -/
theorem hasSubFourUpperBound_of_proportionalSaving {r : ℕ → ℕ}
    (h : HasProportionalSaving r) : HasSubFourUpperBound r := by
  obtain ⟨q, hq_pos, hq_lt_one, k₀, hk₀⟩ := h
  use 4 * (1 - q)
  refine ⟨by linarith, by linarith, k₀, ?_⟩
  intro k hk
  have := hk₀ k hk
  rwa [four_mul_eq_four_sub_saving] at this

/-- Conversely, every eventual `(4-ε)^k` bound with `0 < ε < 4` can be
normalized as `(4q)^k` for a fixed `q ∈ (0,1)`. -/
theorem hasProportionalSaving_of_hasSubFourUpperBound {r : ℕ → ℕ}
    (h : HasSubFourUpperBound r) : HasProportionalSaving r := by
  obtain ⟨ε, hε_pos, hε_lt_4, k₀, hr⟩ := h
  use (4 - ε) / 4
  refine ⟨by linarith, by linarith, k₀, ?_⟩
  intro k hk
  have heq : (4 - ε : ℝ) = 4 * ((4 - ε) / 4) := by ring
  rw [heq] at hr
  exact hr k hk

/-- The additive-gap and proportional-saving formulations are equivalent. -/
theorem subFour_iff_proportionalSaving (r : ℕ → ℕ) :
    HasSubFourUpperBound r ↔ HasProportionalSaving r :=
  ⟨hasProportionalSaving_of_hasSubFourUpperBound,
    hasSubFourUpperBound_of_proportionalSaving⟩

/-- An exponentially decaying correction to the base four gives an explicit
sub-four gap `ε = 4(1-exp(-δ))`. -/
theorem hasSubFourUpperBound_of_expSaving {r : ℕ → ℕ} {δ : ℝ} (hδ : 0 < δ)
    (h : ∃ k₀ : ℕ, ∀ k ≥ k₀,
      (r k : ℝ) ≤ (4 * Real.exp (-δ)) ^ k) :
    HasSubFourUpperBound r := by
  -- Set ε = 4 * (1 - exp(-δ))
  use 4 * (1 - Real.exp (-δ))
  -- Show ε > 0: since δ > 0, exp(-δ) < 1, so 1 - exp(-δ) > 0
  have hexp_lt_one : Real.exp (-δ) < 1 := by
    rw [Real.exp_lt_one_iff]
    exact neg_neg_of_pos hδ
  have hε_pos : 0 < 4 * (1 - Real.exp (-δ)) := by linarith
  refine ⟨hε_pos, ?_, ?_⟩
  -- Show ε < 4: since exp(-δ) > 0, we have 1 - exp(-δ) < 1, so 4*(1 - exp(-δ)) < 4
  have hexp_pos : 0 < Real.exp (-δ) := Real.exp_pos _
  linarith
  -- Need to convert (4 * exp(-δ))^k to (4 - 4*(1 - exp(-δ)))^k
  obtain ⟨k₀, hk₀⟩ := h
  exact ⟨k₀, fun k hk => by
    have : (4 : ℝ) * Real.exp (-δ) = 4 - 4 * (1 - Real.exp (-δ)) := by ring
    rw [← this]
    exact hk₀ k hk⟩

/-- A pointwise multiplicative saving is stable under replacing the saving
factor by a larger one.  This permits estimates to be rounded up to a simpler
constant without losing the exponential improvement. -/
theorem proportionalSaving_mono {r : ℕ → ℕ} {q q' : ℝ}
    (hq : 0 < q) (hqq' : q ≤ q')
    (h : ∃ k₀ : ℕ, ∀ k ≥ k₀, (r k : ℝ) ≤ (4 * q) ^ k) :
    ∃ k₀ : ℕ, ∀ k ≥ k₀, (r k : ℝ) ≤ (4 * q') ^ k := by
  obtain ⟨k₀, hk⟩ := h
  use k₀
  intro k hk'
  exact le_trans (hk k hk') (by gcongr)

/-- A fixed polynomial loss does not destroy a strict exponential saving.

More precisely, if `r k` is eventually at most `k^d (4q)^k` for one fixed
`q ∈ (0,1)`, then it is eventually bounded by `(4-ε)^k` for a fixed positive
`ε`.  The proof absorbs the polynomial into the larger saving factor
`q' = (q+1)/2`, which is still strictly below one. -/
theorem hasSubFourUpperBound_of_polynomialLoss {r : ℕ → ℕ} (d : ℕ)
    {q : ℝ} (hq : 0 < q) (hq_lt_one : q < 1)
    (h : ∃ k₀ : ℕ, ∀ k ≥ k₀,
      (r k : ℝ) ≤ (k : ℝ) ^ d * (4 * q) ^ k) :
    HasSubFourUpperBound r := by
  let q' : ℝ := (q + 1) / 2
  have hq'_pos : 0 < q' := by
    dsimp [q']
    linarith
  have hq'_lt_one : q' < 1 := by
    dsimp [q']
    linarith
  have hbase : ‖(4 * q : ℝ)‖ < 4 * q' := by
    rw [Real.norm_eq_abs, abs_of_pos (mul_pos (by norm_num) hq)]
    dsimp [q']
    linarith
  have hasym :=
    isLittleO_pow_const_mul_const_pow_const_pow_of_norm_lt d hbase
  have hev : ∀ᶠ k : ℕ in Filter.atTop,
      ‖(k : ℝ) ^ d * (4 * q) ^ k‖ ≤ 1 * ‖(4 * q') ^ k‖ :=
    hasym.bound zero_lt_one
  rw [Filter.eventually_atTop] at hev
  obtain ⟨N, hN⟩ := hev
  obtain ⟨k₀, hk₀⟩ := h
  use 4 * (1 - q')
  refine ⟨by nlinarith, by nlinarith, max N k₀, ?_⟩
  intro k hk
  have hkN : N ≤ k := le_trans (le_max_left _ _) hk
  have hkk₀ : k₀ ≤ k := le_trans (le_max_right _ _) hk
  calc
    (r k : ℝ) ≤ (k : ℝ) ^ d * (4 * q) ^ k := hk₀ k hkk₀
    _ ≤ (4 * q') ^ k := by
      have hb := hN k hkN
      rw [Real.norm_eq_abs, Real.norm_eq_abs, one_mul,
        abs_of_nonneg (mul_nonneg (pow_nonneg (Nat.cast_nonneg _) _)
          (pow_nonneg (le_of_lt (mul_pos (by norm_num) hq)) _)),
        abs_of_nonneg
          (pow_nonneg (le_of_lt (mul_pos (by norm_num) hq'_pos)) _)] at hb
      exact hb
    _ = (4 - 4 * (1 - q')) ^ k := by ring_nf

/-!
## Part II: structure theory of sub-four bounds

The remainder of the file develops four further directions on top of the two
predicates above.

* `not_hasSubFourUpperBound_of_pow_le`, `not_hasSubFourUpperBound_centralBinom` —
  a *negative* result: the classical Erdős–Szekeres estimate `R(k,k) ≤ C(2k,k)`
  can never yield a proportional saving, because the central binomial
  coefficient itself has no eventual bound of the shape `(4-ε)^k`.  Any
  catalog-level sub-four bound must therefore use strictly more than the
  binomial recursion.
* `hasSubFourUpperBound_of_subexponentialLoss` — closure of the sub-four
  property under arbitrary *subexponential* multiplicative losses, generalizing
  `hasSubFourUpperBound_of_polynomialLoss`.
* `exponentialLoss_not_absorbable`, `not_subexponentialLoss_two_pow` —
  sharpness of the subexponentiality hypothesis.
* `subFour_threshold_elimination` — elimination of the ineffective threshold
  `k₀`: an eventual sub-four bound together with the strict small-case
  inequalities `r k < 4^k` produces one explicit `ε > 0` valid for all `k ≥ 2`.
* `proportionalSaving₂_iff_additiveGap₂`, `asymmetric_normalization` — the
  two-parameter (off-diagonal) normalization: on a compact ratio window
  `s/(s+t) ∈ [a,b] ⊂ (0,1)` a uniform proportional saving against the entropy
  base is equivalent to a uniform additive gap below it.
* `entropyBase_le_two`, `asymmetric_normalization_global` — the sharp bound
  `entropyBase ≤ 2` (the binary-entropy inequality `H₂ ≤ log 2`) shows that
  compactness of the ratio window is in fact not needed for the equivalence.
* `hasSubFourUpperBound_diagonal_of_proportionalSaving₂` — the off-diagonal
  normalization specializes back to the diagonal one, the entropy base at ratio
  `1/2` being `2`, with `2^(2k) = 4^k`.
-/

open Filter

/-! ## 1. Obstructions: sequences with no sub-four bound -/

/-- Eventual domination by a base `c ≥ 4` rules out every sub-four bound. -/
theorem not_hasSubFourUpperBound_of_pow_le {r : ℕ → ℕ} {c : ℝ} (hc : 4 ≤ c) {N : ℕ}
    (h : ∀ k ≥ N, c ^ k ≤ (r k : ℝ)) : ¬ HasSubFourUpperBound r := by
  intro ⟨ε, hε_pos, hε_lt_4, k₀, hk₀⟩
  have hc_pos : 0 < c := by linarith
  have hc4_sub_pos : 0 < 4 - ε := by linarith
  have hc_gt : c > 4 - ε := by linarith
  -- Consider k = max N k₀ 1
  let k := max (max N k₀) 1
  have hk_N : N ≤ k := le_trans (le_max_left _ _) (le_max_left _ _)
  have hk_k₀ : k₀ ≤ k := le_trans (le_max_right _ _) (le_max_left _ _)
  have hk_pos : 1 ≤ k := le_max_right _ _
  have h1 : c ^ k ≤ (r k : ℝ) := h k hk_N
  have h2 : (r k : ℝ) ≤ (4 - ε) ^ k := hk₀ k hk_k₀
  have h3 : c ^ k ≤ (4 - ε) ^ k := le_trans h1 h2
  have hk_ne_zero : k ≠ 0 := ne_of_gt (by linarith)
  have h4 : (4 - ε) ^ k < c ^ k := pow_lt_pow_left₀ hc_gt (by linarith) hk_ne_zero
  linarith

/-- The pure exponential `4^k` has no sub-four upper bound. -/
theorem not_hasSubFourUpperBound_four_pow :
    ¬ HasSubFourUpperBound (fun k => 4 ^ k) := by
  apply not_hasSubFourUpperBound_of_pow_le (c := 4) (by norm_num : (4 : ℝ) ≤ 4) (N := 0)
  intro k hk
  exact_mod_cast le_rfl

/-- Auxiliary growth fact: an exponential with base `> 1` eventually dominates
the identity. -/
theorem eventually_lt_pow_of_one_lt {c : ℝ} (hc : 1 < c) :
    ∃ N : ℕ, ∀ k ≥ N, (k : ℝ) < c ^ k := by
  -- Use the binomial theorem: c^n = (1 + (c-1))^n ≥ C(n,2) * (c-1)^2
  -- For n ≥ 2, C(n,2) = n(n-1)/2 ≥ n/2, so c^n ≥ n * (c-1)^2 / 2
  -- For large n, this exceeds n
  have hc1 : 0 < c - 1 := by linarith
  have hc2 : 0 < (c - 1)^2 := sq_pos_of_pos hc1
  -- Pick N such that (N-1) * (c-1)^2 > 2, i.e., N > 2/(c-1)^2 + 1
  use ⌈2 / (c - 1)^2⌉₊ + 2
  intro k hk
  -- We have k ≥ ⌈2/(c-1)^2⌉₊ + 2 ≥ 2, so k(k-1)/2 ≥ 1
  have hk2 : 2 ≤ k := by omega
  -- Use binomial: (1+r)^k ≥ C(k,2) * r^2 for r > 0
  let r := c - 1
  have hr : 0 < r := hc1
  -- c^k = (1+r)^k ≥ C(k,2) * r^2 = k*(k-1)/2 * r^2
  have hbinom : c ^ k = (1 + r) ^ k := by simp [r]
  -- Lower bound using just the k=2 term of binomial (and positivity of other terms)
  -- (1+r)^k ≥ C(k,2) * r^2 = k*(k-1)/2 * r^2
  have hlo : (1 + r) ^ k ≥ (k : ℝ) * (k - 1) / 2 * r ^ 2 := by
    rw [add_pow]
    -- The sum includes the term for m = k-2 which equals r^2 * C(k, k-2) = r^2 * k(k-1)/2
    have hk2' : k - 2 < k + 1 := by omega
    have hk2mem : k - 2 ∈ Finset.range (k + 1) := Finset.mem_range.mpr hk2'
    have hsub : k - (k - 2) = 2 := by omega
    have hchoose : k.choose (k - 2) = k.choose 2 := Nat.choose_symm hk2
    have hterm : (1 : ℝ) ^ (k - 2) * r ^ (k - (k - 2)) * k.choose (k - 2) = r ^ 2 * (k.choose 2 : ℝ) := by
      simp [hsub, hchoose]
    have hall : ∀ j ∈ Finset.range (k + 1), 0 ≤ (1 : ℝ) ^ j * r ^ (k - j) * k.choose j := by
      intro j _; positivity
    calc ∑ m ∈ Finset.range (k + 1), (1 : ℝ) ^ m * r ^ (k - m) * k.choose m
        ≥ (1 : ℝ) ^ (k - 2) * r ^ (k - (k - 2)) * k.choose (k - 2) :=
          Finset.single_le_sum hall hk2mem
      _ = r ^ 2 * (k.choose 2 : ℝ) := hterm
      _ = r ^ 2 * ((k : ℝ) * (k - 1) / 2) := by
          rw [Nat.choose_two_right]
          congr 1
          have h2 : 2 ∣ k * (k - 1) := by
            rcases Nat.even_or_odd' k with ⟨m, rfl | rfl⟩
            · use m * (2 * m - 1)
              cases m with
              | zero => simp
              | succ n => simp [Nat.mul_succ]; ring
            · use (2 * m + 1) * m
              simp; ring
          rw [Nat.cast_div h2]
          · cases k with
            | zero => simp
            | succ n => simp
          · norm_num
      _ = (k : ℝ) * (k - 1) / 2 * r ^ 2 := by ring
  -- Now show k < (1+r)^k using hlo
  -- Since k ≥ ⌈2/r²⌉₊ + 2, we have k-1 > 2/r², so r²(k-1) > 2
  -- Thus k(k-1)/2 * r² = k * (r²(k-1)/2) > k * 1 = k
  rw [hbinom]
  have hr2_pos : 0 < r ^ 2 := sq_pos_of_pos hr
  have hk_real : (k : ℝ) ≥ 2 := by exact_mod_cast hk2
  have hN : (k : ℝ) > 2 / r ^ 2 := by
    have hk'_real : (k : ℝ) ≥ ⌈2 / r ^ 2⌉₊ + 2 := by exact_mod_cast hk
    have h_pos : 0 < 2 / r ^ 2 := div_pos (by norm_num) hr2_pos
    linarith [Nat.le_ceil (2 / r ^ 2)]
  have hk1_pos : 0 < (k : ℝ) - 1 := by linarith
  have hkey : r ^ 2 * ((k : ℝ) - 1) > 2 := by
    -- From k ≥ ⌈2/r^2⌉₊ + 2, we have (k : ℝ) ≥ ⌈2/r^2⌉₊ + 2
    have hk' : (k : ℝ) ≥ ⌈2 / r ^ 2⌉₊ + 2 := by exact_mod_cast hk
    -- Since ⌈2/r^2⌉₊ ≥ 2/r^2, we have k ≥ 2/r^2 + 2, so k - 1 ≥ 2/r^2 + 1 > 2/r^2
    have h_ceil : (2 : ℝ) / r ^ 2 ≤ ⌈2 / r ^ 2⌉₊ := Nat.le_ceil _
    have h2 : (k : ℝ) - 1 > 2 / r ^ 2 := by linarith
    calc r ^ 2 * ((k : ℝ) - 1) > r ^ 2 * (2 / r ^ 2) := by nlinarith
      _ = 2 := by field_simp
  have hfinal : ((k : ℝ) * ((k : ℝ) - 1) / 2) * r ^ 2 > (k : ℝ) := by
    have eq1 : ((k : ℝ) * ((k : ℝ) - 1) / 2) * r ^ 2 = (k : ℝ) * (r ^ 2 * ((k : ℝ) - 1) / 2) := by ring
    rw [eq1]
    have h2 : r ^ 2 * ((k : ℝ) - 1) / 2 > 1 := by linarith
    nlinarith
  linarith

/-- A clean real-valued form of `Nat.four_pow_lt_mul_centralBinom`. -/
theorem four_pow_div_le_centralBinom {k : ℕ} (hk : 4 ≤ k) :
    (4 : ℝ) ^ k / k ≤ (Nat.centralBinom k : ℝ) := by
  rw [div_le_iff₀]
  · have h := Nat.four_pow_lt_mul_centralBinom k hk
    have h' : (4 : ℝ) ^ k < (k : ℝ) * Nat.centralBinom k := by
      exact_mod_cast h
    rw [mul_comm] at h'
    linarith
  · positivity

/-- **The classical binomial bound is not sub-four.**  The central binomial
coefficient `C(2k,k)`, which is exactly the Erdős–Szekeres upper bound for the
diagonal Ramsey number `R(k+1,k+1)`, admits no eventual bound `(4-ε)^k`.
Consequently no catalog-level proportional saving can be extracted from the
binomial estimate alone. -/
theorem not_hasSubFourUpperBound_centralBinom :
    ¬ HasSubFourUpperBound Nat.centralBinom := by
  intro ⟨ε, hε_pos, _, k₀, hk₀⟩
  -- Pick c = 4 - ε/2, so 4 - ε < c < 4
  set c : ℝ := 4 - ε / 2 with hc_def
  have hc_gt : 4 - ε < c := by linarith
  have hc_lt : c < 4 := by linarith
  have hc_pos : 0 < c := by linarith
  -- Since 4/c > 1, eventually N < (4/c)^N
  have h4pc : 1 < 4 / c := by rw [lt_div_iff₀ hc_pos]; linarith
  obtain ⟨N₁, hN₁⟩ := eventually_lt_pow_of_one_lt h4pc
  -- Take N large enough
  set N := max N₁ (max k₀ 4) with hN_def
  have hN_N₁ : N₁ ≤ N := by simp only [hN_def]; omega
  have hN_k₀ : k₀ ≤ N := by simp only [hN_def]; omega
  have hN_4 : 4 ≤ N := by simp only [hN_def]; omega
  have hN_pos : 0 < N := by omega
  -- Key bounds
  have h1 : (4 : ℝ) ^ N / N ≤ Nat.centralBinom N := four_pow_div_le_centralBinom hN_4
  have h2 : (N : ℝ) < (4 / c) ^ N := hN₁ N hN_N₁
  -- Derive contradiction
  have h3 : c ^ N ≤ 4 ^ N / N := by
    have h2' : (N : ℝ) < 4 ^ N / c ^ N := by rwa [div_pow] at h2
    rw [lt_div_iff₀ (pow_pos hc_pos _)] at h2'
    rw [le_div_iff₀ (by positivity : (0 : ℝ) < N)]
    linarith
  have h4 : (4 - ε) ^ N < c ^ N := pow_lt_pow_left₀ hc_gt (by linarith) (by omega : N ≠ 0)
  have h5 : (Nat.centralBinom N : ℝ) ≤ (4 - ε) ^ N := hk₀ N hN_k₀
  have h6 : (Nat.centralBinom N : ℝ) < Nat.centralBinom N := by
    calc (Nat.centralBinom N : ℝ) ≤ (4 - ε) ^ N := h5
      _ < c ^ N := h4
      _ ≤ 4 ^ N / N := h3
      _ ≤ Nat.centralBinom N := h1
  linarith

/-! ## 2. Closure under subexponential losses -/

/-- A nonnegative sequence of *subexponential* multiplicative losses: it is
eventually dominated by `exp (δ k)` for every `δ > 0`. -/
def SubexponentialLoss (L : ℕ → ℝ) : Prop :=
  (∀ k, 0 ≤ L k) ∧ ∀ δ : ℝ, 0 < δ → ∃ k₀ : ℕ, ∀ k ≥ k₀, L k ≤ Real.exp (δ * k)

/-- Powers `k ↦ k^d` are subexponential losses. -/
theorem subexponentialLoss_pow (d : ℕ) : SubexponentialLoss (fun k => (k : ℝ) ^ d) := by
  constructor
  · intro k
    positivity
  · intro δ hδ
    -- We need: ∃ k₀, ∀ k ≥ k₀, (k : ℝ) ^ d ≤ Real.exp (δ * k)
    -- Use the fact that k^d / exp(δ * k) → 0 as k → ∞
    -- First, we have the basic fact: x^d * exp(-x) → 0 as x → ∞
    have hbase : Filter.Tendsto (fun x : ℝ => x ^ d * Real.exp (-x)) Filter.atTop (nhds 0) :=
      Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero d
    -- Compose with u = δ * k to get (δ*k)^d * exp(-δ*k) → 0
    have hδk : Filter.Tendsto (fun k : ℝ => δ * k) Filter.atTop Filter.atTop :=
      Filter.tendsto_id.const_mul_atTop hδ
    have hcomp := hbase.comp hδk
    -- This gives: (δ*k)^d * exp(-δ*k) → 0
    -- So k^d * exp(-δ*k) = δ^(-d) * (δ*k)^d * exp(-δ*k) → 0
    have hscaled : Filter.Tendsto (fun k : ℝ => k ^ d * Real.exp (-δ * k)) Filter.atTop (nhds 0) := by
      have hdelta_pos : 0 < δ := hδ
      have heq : ∀ k : ℝ, k ^ d * Real.exp (-δ * k) = δ⁻¹ ^ d * ((δ * k) ^ d * Real.exp (-δ * k)) := by
        intro k
        rw [mul_pow δ k, inv_pow]
        field_simp
      simp_rw [heq]
      convert hcomp.const_mul (δ ^ (-d : ℤ)) using 1 <;> simp
    -- Since limit is 0, eventually the function is ≤ 1
    have hev : ∀ᶠ k : ℝ in Filter.atTop, k ^ d * Real.exp (-δ * k) ≤ 1 :=
      hscaled.eventually (ge_mem_nhds zero_lt_one)
    rw [Filter.eventually_atTop] at hev
    obtain ⟨N, hN⟩ := hev
    refine ⟨Nat.ceil N, fun k hk => ?_⟩
    have hkN : (k : ℝ) ≥ N := le_trans (Nat.le_ceil N) (mod_cast hk)
    have h := hN k hkN
    rw [show (-δ * k : ℝ) = -(δ * k) by ring, Real.exp_neg] at h
    have hexp_pos : Real.exp (δ * k) > 0 := Real.exp_pos _
    have := mul_le_mul_of_nonneg_left h (le_of_lt hexp_pos)
    simp at this
    convert this using 1
    field_simp

/-- Constant losses are subexponential. -/
theorem subexponentialLoss_const {C : ℝ} (hC : 0 ≤ C) :
    SubexponentialLoss (fun _ => C) := by
  constructor
  · intro k; exact hC
  · intro δ hδ_pos
    obtain ⟨k₀, hk₀⟩ := exists_nat_gt ((Real.log (max C 1)) / δ)
    use k₀
    intro k hk
    simp only
    have h1 : (k : ℝ) ≥ k₀ := Nat.cast_le.mpr hk
    have h2 : δ * k ≥ δ * k₀ := by nlinarith
    have h3 : δ * k₀ > Real.log (max C 1) := by
      have := hk₀
      rwa [div_lt_iff₀ hδ_pos, mul_comm] at this
    have h4 : δ * k > Real.log (max C 1) := by linarith
    have h5 : Real.exp (δ * k) ≥ Real.exp (Real.log (max C 1)) := by
      apply Real.exp_le_exp.mpr
      linarith
    have hmax_pos : 0 < max C 1 := by positivity
    have h6 : Real.exp (Real.log (max C 1)) = max C 1 := Real.exp_log hmax_pos
    calc C ≤ max C 1 := le_max_left _ _
      _ = Real.exp (Real.log (max C 1)) := h6.symm
      _ ≤ Real.exp (δ * k) := h5

/-- **Closure under subexponential losses.**  If `r k ≤ L k · (4q)^k` eventually,
for a fixed `q ∈ (0,1)` and a subexponential loss `L`, then `r` still has a
sub-four upper bound.  The loss is absorbed into the slightly larger saving
`q' = (q+1)/2`. -/
theorem hasSubFourUpperBound_of_subexponentialLoss {r : ℕ → ℕ} {L : ℕ → ℝ} {q : ℝ}
    (hL : SubexponentialLoss L) (hq : 0 < q) (hq_lt_one : q < 1)
    (h : ∃ k₀ : ℕ, ∀ k ≥ k₀, (r k : ℝ) ≤ L k * (4 * q) ^ k) :
    HasSubFourUpperBound r := by
  -- Define q' = (q + 1) / 2, which is strictly between q and 1
  let q' : ℝ := (q + 1) / 2
  have hq'_pos : 0 < q' := by
    dsimp [q']
    linarith
  have hq'_lt_one : q' < 1 := by
    dsimp [q']
    linarith
  have hq_lt_q' : q < q' := by
    dsimp [q']
    linarith
  -- Use subexponentiality with δ = log(q'/q)
  have hq'_gt_q : q' > q := hq_lt_q'
  have hq'_div_q_gt_one : q' / q > 1 := by
    rw [gt_iff_lt, one_lt_div hq]
    exact hq'_gt_q
  have hδ_pos : 0 < Real.log (q' / q) := Real.log_pos hq'_div_q_gt_one
  obtain ⟨k₁, hk₁⟩ := hL.2 (Real.log (q' / q)) hδ_pos
  -- Combine with the hypothesis h to get the threshold
  obtain ⟨k₀, hk₀⟩ := h
  use 4 * (1 - q')
  refine ⟨by nlinarith, by nlinarith, max k₀ k₁, ?_⟩
  intro k hk
  have hk₀' : k₀ ≤ k := le_trans (le_max_left _ _) hk
  have hk₁' : k₁ ≤ k := le_trans (le_max_right _ _) hk
  calc
    (r k : ℝ) ≤ L k * (4 * q) ^ k := hk₀ k hk₀'
    _ ≤ Real.exp (Real.log (q' / q) * k) * (4 * q) ^ k := by
        gcongr
        exact hk₁ k hk₁'
    _ = (q' / q) ^ k * (4 * q) ^ k := by
        have h1 : Real.exp (Real.log (q' / q) * k) = (q' / q) ^ k := by
          rw [mul_comm, Real.exp_nat_mul, Real.exp_log (div_pos hq'_pos hq)]
        rw [h1]
    _ = (4 * q') ^ k := by
        rw [← mul_pow]
        congr 1
        field_simp
    _ = (4 - 4 * (1 - q')) ^ k := by ring_nf

/-- The polynomial-loss theorem of the previous file is the special case
`L k = k^d`. -/
theorem hasSubFourUpperBound_of_polynomialLoss' {r : ℕ → ℕ} (d : ℕ) {q : ℝ}
    (hq : 0 < q) (hq_lt_one : q < 1)
    (h : ∃ k₀ : ℕ, ∀ k ≥ k₀, (r k : ℝ) ≤ (k : ℝ) ^ d * (4 * q) ^ k) :
    HasSubFourUpperBound r :=
  hasSubFourUpperBound_of_subexponentialLoss (subexponentialLoss_pow d) hq hq_lt_one h

/-- Genuinely exponential losses are not subexponential. -/
theorem not_subexponentialLoss_two_pow :
    ¬ SubexponentialLoss (fun k => (2 : ℝ) ^ k) := by
  intro ⟨h_nonneg, h_exp⟩
  -- Use δ = (log 2) / 2, which is positive and less than log 2
  have hlog2_pos : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have δ_pos : 0 < Real.log 2 / 2 := by linarith
  obtain ⟨k₀, hk₀⟩ := h_exp (Real.log 2 / 2) δ_pos
  -- At k = max k₀ 1, we get 2^k ≤ exp((log 2)/2 * k), but 2^k = exp(k * log 2) > exp(k * (log 2)/2)
  let k := max k₀ 1
  have hk_k₀ : k₀ ≤ k := le_max_left _ _
  have hk_pos : 1 ≤ k := le_max_right _ _
  have hbound : (2 : ℝ) ^ k ≤ Real.exp (Real.log 2 / 2 * (k : ℝ)) := hk₀ k hk_k₀
  -- 2^k = exp(k * log 2)
  have h2_eq : (2 : ℝ) ^ k = Real.exp ((k : ℝ) * Real.log 2) := by
    rw [← Real.rpow_natCast]
    rw [Real.rpow_def_of_pos (by norm_num : (0 : ℝ) < 2)]
    ring_nf
  rw [h2_eq] at hbound
  -- exp(k * log 2) ≤ exp((log 2)/2 * k) means k * log 2 ≤ (log 2)/2 * k
  have hexp_ineq := Real.exp_le_exp.mp hbound
  -- But k ≥ 1 and log 2 > 0, so k * log 2 ≥ log 2 > (log 2)/2 * k
  have hk_real_pos : (0 : ℝ) < k := by norm_cast
  nlinarith

/-- **Sharpness of the subexponentiality hypothesis.**  There is an exponential
loss `L`, a saving `q ∈ (0,1)` and a sequence `r` with `r k ≤ L k (4q)^k` for all
`k`, yet `r` has no sub-four upper bound. -/
theorem exponentialLoss_not_absorbable :
    ∃ (L : ℕ → ℝ) (q : ℝ) (r : ℕ → ℕ), (∀ k, 0 ≤ L k) ∧ 0 < q ∧ q < 1 ∧
      (∀ k, (r k : ℝ) ≤ L k * (4 * q) ^ k) ∧ ¬ HasSubFourUpperBound r := by
  use fun k => (2 : ℝ) ^ k
  use 1 / 2
  use fun k => 4 ^ k
  refine ⟨?_, by norm_num, by norm_num, ?_, not_hasSubFourUpperBound_four_pow⟩
  · intro k
    positivity
  · intro k
    norm_num
    rw [← pow_add]
    have : (4 : ℝ) ^ k = 2 ^ (2 * k) := by norm_num [pow_mul]
    rw [this, two_mul]

/-! ## 3. Threshold elimination -/

/-- Enlarging the additive gap weakens the bound. -/
theorem pow_gap_mono {x ε ε' : ℝ} {k : ℕ} (hε : ε < 4) (hεε' : ε' ≤ ε)
    (h : x ≤ (4 - ε) ^ k) : x ≤ (4 - ε') ^ k := by
  have h1 : 4 - ε ≤ 4 - ε' := by linarith
  have h2 : 0 ≤ 4 - ε := by linarith
  have h3 : 0 ≤ 4 - ε' := by linarith
  exact h.trans (pow_le_pow_left₀ h2 h1 k)

/-- A strict inequality `x < 4^k` (for `k ≥ 1`) already produces some positive
additive gap at the single index `k`. -/
theorem exists_gap_of_lt_four_pow {x : ℝ} {k : ℕ} (hk : 1 ≤ k) (hx : x < 4 ^ k) :
    ∃ ε : ℝ, 0 < ε ∧ ε < 4 ∧ x ≤ (4 - ε) ^ k := by
  by_cases hx_nonpos : x ≤ 0
  · use 2
    refine ⟨by norm_num, by norm_num, ?_⟩
    have : (4 - 2 : ℝ) ^ k = 2 ^ k := by norm_num
    rw [this]
    exact le_of_lt (lt_of_le_of_lt hx_nonpos (by positivity))
  · -- x > 0
    push_neg at hx_nonpos
    use 4 - x ^ (1 / (k : ℝ))
    have hk_pos : (0 : ℝ) < k := Nat.cast_pos.mpr (lt_of_lt_of_le (by norm_num : 0 < 1) hk)
    have hx_root_pos : 0 < x ^ (1 / (k : ℝ)) := Real.rpow_pos_of_pos hx_nonpos _
    have hx_root_lt_four : x ^ (1 / (k : ℝ)) < 4 := by
      have : x < (4 : ℝ) ^ k := hx
      calc x ^ (1 / (k : ℝ)) < ((4 : ℝ) ^ k) ^ (1 / (k : ℝ)) := by
            gcongr
        _ = 4 := by rw [← Real.rpow_natCast, ← Real.rpow_mul (by norm_num : (0 : ℝ) ≤ 4), mul_comm]; simp [hk_pos.ne']
    refine ⟨by linarith, by linarith, ?_⟩
    have : (4 - (4 - x ^ (1 / (k : ℝ)))) ^ k = x := by
      simp only [sub_sub_cancel]
      rw [← Real.rpow_natCast, ← Real.rpow_mul (le_of_lt hx_nonpos)]
      simp [hk_pos.ne']
    rw [this]

/-- Finitely many individual gaps can be merged into one uniform gap. -/
theorem exists_uniform_gap_finset {r : ℕ → ℕ} (s : Finset ℕ)
    (h : ∀ k ∈ s, ∃ ε : ℝ, 0 < ε ∧ ε < 4 ∧ (r k : ℝ) ≤ (4 - ε) ^ k) :
    ∃ ε : ℝ, 0 < ε ∧ ε < 4 ∧ ∀ k ∈ s, (r k : ℝ) ≤ (4 - ε) ^ k := by
  induction s using Finset.induction_on with
  | empty =>
    use 1
    refine ⟨by norm_num, by norm_num, ?_⟩
    simp
  | insert a s' ha ih =>
    obtain ⟨ε₁, hε₁_pos, hε₁_lt_4, hε₁_bound⟩ := h _ (Finset.mem_insert_self _ _)
    have h' : ∀ k ∈ s', ∃ ε : ℝ, 0 < ε ∧ ε < 4 ∧ (r k : ℝ) ≤ (4 - ε) ^ k :=
      fun k hk => h k (Finset.mem_insert_of_mem hk)
    obtain ⟨ε₂, hε₂_pos, hε₂_lt_4, hε₂_bound⟩ := ih h'
    use min ε₁ ε₂
    refine ⟨lt_min hε₁_pos hε₂_pos, ?_, ?_⟩
    · exact lt_of_le_of_lt (min_le_right _ _) hε₂_lt_4
    · intro k hk
      rw [Finset.mem_insert] at hk
      rcases hk with rfl | hk
      · have h1 : min ε₁ ε₂ ≤ ε₁ := min_le_left _ _
        have hε₁_nonneg : 0 ≤ 4 - ε₁ := by linarith
        calc (r _ : ℝ) ≤ (4 - ε₁) ^ _ := hε₁_bound
          _ ≤ (4 - min ε₁ ε₂) ^ _ := by gcongr
      · have h2 : min ε₁ ε₂ ≤ ε₂ := min_le_right _ _
        have hε₂_nonneg : 0 ≤ 4 - ε₂ := by linarith
        calc (r k : ℝ) ≤ (4 - ε₂) ^ k := hε₂_bound k hk
          _ ≤ (4 - min ε₁ ε₂) ^ k := by gcongr

/-- **Threshold elimination.**  An eventual sub-four bound plus the strict
small-case inequalities `r k < 4^k` yields a single `ε > 0` working for every
`k ≥ 2`.  The strict small-case hypothesis is necessary: it is exactly what a
computed value `r k ≥ 4^k` would falsify. -/
theorem subFour_threshold_elimination {r : ℕ → ℕ} (h : HasSubFourUpperBound r)
    (hsmall : ∀ k, 2 ≤ k → (r k : ℝ) < 4 ^ k) :
    ∃ ε : ℝ, 0 < ε ∧ ε < 4 ∧ ∀ k ≥ 2, (r k : ℝ) ≤ (4 - ε) ^ k := by
  obtain ⟨ε₁, hε₁_pos, hε₁_lt_4, k₀, hk₀⟩ := h
  by_cases hk₀_le_2 : k₀ ≤ 2
  · use ε₁
    refine ⟨hε₁_pos, hε₁_lt_4, fun k hk => ?_⟩
    exact hk₀ k (Nat.le_trans hk₀_le_2 hk)
  · -- k₀ > 2 (i.e., k₀ ≥ 3), so we need to handle the finite range [2, k₀)
    -- Consider the finite set {2, ..., k₀ - 1} and find max of r k
    let S : Finset ℕ := Finset.Ico 2 k₀
    -- Find the maximum value of r over S
    have hS_nonempty : S.Nonempty := by
      use 2
      simp [S]
      omega
    -- For each k in S, since r k < 4^k, there's a slack we can exploit
    -- Define for each k: the fraction r k / 4^k < 1
    -- We need ε small enough that (4 - ε)^k ≥ r k for all k ∈ S
    -- Equivalently, 4 - ε ≥ (r k)^(1/k), i.e., ε ≤ 4 - (r k)^(1/k)
    -- Since (r k)^(1/k) < 4, this bound is positive. Take min over S.
    have key : ∀ k ∈ S, (r k : ℝ) < 4 ^ k := fun k hk => hsmall k (Finset.mem_Ico.mp hk).1
    -- Use that for finite set, we can find minimum gap
    let f : ℕ → ℝ := fun k => 4 - (r k : ℝ) ^ (1 / (k : ℝ))
    have hf_pos : ∀ k ∈ S, 0 < f k := by
      intro k hk
      have hk2 : 2 ≤ k := (Finset.mem_Ico.mp hk).1
      have hfork : (0 : ℝ) < k := by positivity
      have hrk_lt : (r k : ℝ) < 4 ^ k := key k hk
      have hrk_nonneg : 0 ≤ (r k : ℝ) := by positivity
      have hrk_lt_4k_root : (r k : ℝ) ^ (1 / (k : ℝ)) < 4 := by
        have h1 : (r k : ℝ) < (4 : ℝ) ^ k := hrk_lt
        have h2 : (4 : ℝ) ^ k > 0 := by positivity
        have h3 : (r k : ℝ) ^ (1 / (k : ℝ)) < (4 ^ k) ^ (1 / (k : ℝ)) := by
          apply Real.rpow_lt_rpow hrk_nonneg h1
          exact one_div_pos.mpr hfork
        have h4 : (4 ^ k : ℝ) ^ (1 / (k : ℝ)) = 4 := by
          rw [← Real.rpow_natCast (4 : ℝ) k, ← Real.rpow_mul (by norm_num : (0 : ℝ) ≤ 4)]
          simp [hfork.ne']
        linarith
      exact sub_pos.mpr hrk_lt_4k_root
    -- Take the minimum of f k over S, and also consider ε₁
    let g : ℕ → ℝ := fun k => min ε₁ (f k)
    have hg_pos : ∀ k ∈ S, 0 < g k := by
      intro k hk
      exact lt_min hε₁_pos (hf_pos k hk)
    -- S is finite and nonempty, so we can take the minimum
    let ε₂ := S.inf' hS_nonempty g
    have hε₂_pos : 0 < ε₂ := by
      obtain ⟨k, hk_mem, hk_min⟩ := Finset.exists_min_image S g hS_nonempty
      have h_inf_le : ε₂ ≤ g k := Finset.inf'_le _ hk_mem
      have h_gk_le : g k ≤ ε₂ := Finset.le_inf' hS_nonempty g (fun m hm => hk_min m hm)
      have hε₂_eq : ε₂ = g k := le_antisymm h_inf_le h_gk_le
      rw [hε₂_eq]
      exact hg_pos k hk_mem
    -- Use ε = ε₂
    use ε₂
    refine ⟨hε₂_pos, ?_, ?_⟩
    -- Show ε₂ < 4
    · have hε₂_le_ε₁ : ε₂ ≤ ε₁ := by
        have h2_mem : (2 : ℕ) ∈ S := by simp only [S, Finset.mem_Ico]; omega
        have h_inf_2 : ε₂ ≤ g 2 := Finset.inf'_le (f := g) h2_mem
        calc ε₂ ≤ g 2 := h_inf_2
          _ = min ε₁ (f 2) := rfl
          _ ≤ ε₁ := min_le_left _ _
      linarith
    -- Show ∀ k ≥ 2, (r k : ℝ) ≤ (4 - ε₂) ^ k
    · intro k hk
      by_cases hk_k₀ : k ≥ k₀
      · -- Case k ≥ k₀: use the original bound with ε₁
        have h1 : (r k : ℝ) ≤ (4 - ε₁) ^ k := hk₀ k hk_k₀
        have hε₂_le_ε₁ : ε₂ ≤ ε₁ := by
          have h2_mem : (2 : ℕ) ∈ S := by simp only [S, Finset.mem_Ico]; omega
          have h_inf_2 : ε₂ ≤ g 2 := Finset.inf'_le (f := g) h2_mem
          calc ε₂ ≤ g 2 := h_inf_2
            _ = min ε₁ (f 2) := rfl
            _ ≤ ε₁ := min_le_left _ _
        have h4_ε₂_ge : 4 - ε₂ ≥ 4 - ε₁ := by linarith
        have h4_ε₁_pos : 0 < 4 - ε₁ := by linarith
        have h4_ε₂_pos : 0 < 4 - ε₂ := by linarith
        calc (r k : ℝ) ≤ (4 - ε₁) ^ k := h1
          _ ≤ (4 - ε₂) ^ k := by gcongr
      · -- Case 2 ≤ k < k₀: k ∈ S
        push_neg at hk_k₀
        have hk_S : k ∈ S := Finset.mem_Ico.mpr ⟨hk, hk_k₀⟩
        -- ε₂ ≤ ε₁ < 4
        have hε₂_le_ε₁ : ε₂ ≤ ε₁ := by
          have h2_mem : (2 : ℕ) ∈ S := by simp only [S, Finset.mem_Ico]; omega
          have h_inf_2 : ε₂ ≤ g 2 := Finset.inf'_le (f := g) h2_mem
          calc ε₂ ≤ g 2 := h_inf_2
            _ = min ε₁ (f 2) := rfl
            _ ≤ ε₁ := min_le_left _ _
        -- Since k ∈ S, we have ε₂ ≤ g k ≤ f k
        have hε₂_le_fk : ε₂ ≤ f k := by
          have := Finset.inf'_le (f := g) hk_S
          calc ε₂ ≤ g k := this
            _ = min ε₁ (f k) := rfl
            _ ≤ f k := min_le_right _ _
        -- So 4 - ε₂ ≥ (r k)^(1/k)
        have hf_def : f k = 4 - (r k : ℝ) ^ (1 / (k : ℝ)) := rfl
        have h4_sub_ε₂ : 4 - ε₂ ≥ (r k : ℝ) ^ (1 / (k : ℝ)) := by linarith
        -- And (4 - ε₂)^k ≥ r k
        by_cases hrk_zero : r k = 0
        · -- If r k = 0, then 0 ≤ (4 - ε₂)^k trivially
          simp [hrk_zero]
          exact pow_nonneg (by linarith : 0 ≤ 4 - ε₂) _
        have hrk_pos : 0 < (r k : ℝ) := by
          have h := key k hk_S
          have hgt : (r k : ℝ) > 0 := Nat.cast_pos.mpr (Nat.pos_of_ne_zero hrk_zero)
          exact hgt
        have h4_sub_ε₂_pos : 0 < 4 - ε₂ := by
          have hf_eq : f k = 4 - (r k : ℝ) ^ (1 / (k : ℝ)) := rfl
          have hε₂_le_4_sub : ε₂ ≤ 4 - (r k : ℝ) ^ (1 / (k : ℝ)) := by rw [← hf_eq]; exact hε₂_le_fk
          have hf_pos_k : 0 < f k := hf_pos k hk_S
          rw [hf_eq] at hf_pos_k
          linarith
        calc (r k : ℝ) = ((r k : ℝ) ^ (1 / (k : ℝ))) ^ (k : ℝ) := by
              rw [← Real.rpow_mul hrk_pos.le]
              simp [(by positivity : (k : ℝ) ≠ 0)]
          _ ≤ (4 - ε₂) ^ (k : ℝ) := by
              apply Real.rpow_le_rpow (by positivity) h4_sub_ε₂ (by positivity)
          _ = (4 - ε₂) ^ k := by rw [Real.rpow_natCast]

/-! ## 4. Asymmetric (two-parameter) normalization -/

/-- A uniform proportional saving `q < 1` against a base function `β`, over a set
`S` of parameter pairs. -/
def HasProportionalSaving₂ (R : ℕ → ℕ → ℕ) (β : ℕ → ℕ → ℝ) (S : Set (ℕ × ℕ)) : Prop :=
  ∃ q : ℝ, 0 < q ∧ q < 1 ∧
    ∀ p ∈ S, (R p.1 p.2 : ℝ) ≤ (q * β p.1 p.2) ^ (p.1 + p.2)

/-- A uniform additive gap `ε > 0` below a base function `β`, over a set `S` of
parameter pairs. -/
def HasAdditiveGap₂ (R : ℕ → ℕ → ℕ) (β : ℕ → ℕ → ℝ) (S : Set (ℕ × ℕ)) : Prop :=
  ∃ ε : ℝ, 0 < ε ∧ (∀ p ∈ S, ε < β p.1 p.2) ∧
    ∀ p ∈ S, (R p.1 p.2 : ℝ) ≤ (β p.1 p.2 - ε) ^ (p.1 + p.2)

/-- **Equivalence of the two normalizations.**  Whenever the base function is
bounded between `m > 0` and `M` on the parameter set, a uniform proportional
saving is the same thing as a uniform additive gap. -/
theorem proportionalSaving₂_iff_additiveGap₂ {R : ℕ → ℕ → ℕ} {β : ℕ → ℕ → ℝ}
    {S : Set (ℕ × ℕ)} {m M : ℝ} (hm : 0 < m)
    (hlb : ∀ p ∈ S, m ≤ β p.1 p.2) (hub : ∀ p ∈ S, β p.1 p.2 ≤ M) :
    HasProportionalSaving₂ R β S ↔ HasAdditiveGap₂ R β S := by
  constructor
  · -- Forward: HasProportionalSaving₂ → HasAdditiveGap₂
    intro ⟨q, hq_pos, hq_lt_1, hq_bound⟩
    use (1 - q) * m
    refine ⟨by nlinarith, ?_, ?_⟩
    · intro p hp
      have := hlb p hp
      nlinarith
    · intro p hp
      have hbound := hq_bound p hp
      have hβ_ge_m := hlb p hp
      have hqβ_nonneg : 0 ≤ q * β p.1 p.2 := by nlinarith
      have hkey : q * β p.1 p.2 ≤ β p.1 p.2 - (1 - q) * m := by nlinarith
      exact le_trans hbound (pow_le_pow_left₀ hqβ_nonneg hkey _)
  · -- Backward: HasAdditiveGap₂ → HasProportionalSaving₂
    intro ⟨ε, hε_pos, hε_lt, hε_bound⟩
    by_cases hS : S.Nonempty
    · -- S is nonempty: use q = 1 - ε/M
      obtain ⟨p₀, hp₀⟩ := hS
      have hM_pos : 0 < M := by linarith [hε_lt p₀ hp₀, hub p₀ hp₀]
      use 1 - ε / M
      refine ⟨?_, ?_, ?_⟩
      · have hε_lt_M : ε < M := by linarith [hε_lt p₀ hp₀, hub p₀ hp₀]
        nlinarith [div_pos hε_pos hM_pos, div_lt_one hM_pos |>.mpr hε_lt_M]
      · rw [sub_lt_self_iff]; exact div_pos hε_pos hM_pos
      · intro p hp
        have hbound := hε_bound p hp
        have hβ_le_M := hub p hp
        have hε_lt_β := hε_lt p hp
        have hβ_pos : 0 < β p.1 p.2 := by linarith
        have hqβ_ge : β p.1 p.2 - ε ≤ (1 - ε / M) * β p.1 p.2 := by
          have h1 : ε / M * β p.1 p.2 ≤ ε := by
            rw [div_mul_eq_mul_div, div_le_iff₀ hM_pos]
            exact mul_le_mul_of_nonneg_left hβ_le_M hε_pos.le
          linarith
        exact le_trans hbound (pow_le_pow_left₀ (by linarith : 0 ≤ β p.1 p.2 - ε) hqβ_ge _)
    · -- S is empty: use q = 1/2
      simp only [Set.not_nonempty_iff_eq_empty] at hS
      use 1 / 2
      refine ⟨by norm_num, by norm_num, ?_⟩
      intro p hp
      simp [hS] at hp

/-! ### The entropy base -/

/-- The classical entropy-derived base `x^{-x} (1-x)^{-(1-x)}`, i.e.
`2^{H(x)}` for the binary entropy `H`.  For `s/(s+t) = x` the binomial bound
`R(s,t) ≤ C(s+t,s)` is `entropyBase x ^ (s+t)` up to subexponential factors. -/
noncomputable def entropyBase (x : ℝ) : ℝ := x ^ (-x) * (1 - x) ^ (-(1 - x))

/-- At the diagonal ratio the entropy base is `2`. -/
theorem entropyBase_half : entropyBase (1 / 2) = 2 := by
  unfold entropyBase
  norm_num
  -- Goal: (1 / 2) ^ (-(1 / 2)) * (1 / 2) ^ (-(1 / 2)) = 2
  rw [← Real.rpow_add (by norm_num : (0 : ℝ) < 1 / 2)]
  norm_num

/-- The entropy base exceeds one strictly inside `(0,1)`. -/
theorem one_lt_entropyBase {x : ℝ} (h0 : 0 < x) (h1 : x < 1) : 1 < entropyBase x := by
  unfold entropyBase
  have h1mx : 0 < 1 - x := by linarith
  have hx_pow : x ^ x < 1 := Real.rpow_lt_one (le_of_lt h0) h1 (by linarith)
  have h1mx_pow : (1 - x) ^ (1 - x) < 1 := Real.rpow_lt_one (le_of_lt h1mx) (by linarith) (by linarith)
  have hx_pow_pos : 0 < x ^ x := Real.rpow_pos_of_pos h0 x
  have h1mx_pow_pos : 0 < (1 - x) ^ (1 - x) := Real.rpow_pos_of_pos h1mx (1 - x)
  have hx_neg : x ^ (-x) = (x ^ x)⁻¹ := by rw [Real.rpow_neg (le_of_lt h0)]
  have h1mx_neg : (1 - x) ^ (-(1 - x)) = ((1 - x) ^ (1 - x))⁻¹ := by
    rw [Real.rpow_neg (le_of_lt h1mx)]
  rw [hx_neg, h1mx_neg]
  have prod_pos : 0 < x ^ x * (1 - x) ^ (1 - x) := mul_pos hx_pow_pos h1mx_pow_pos
  have prod_lt_one : x ^ x * (1 - x) ^ (1 - x) < 1 := by
    calc x ^ x * (1 - x) ^ (1 - x)
        < 1 * (1 - x) ^ (1 - x) := by gcongr
      _ < 1 * 1 := by gcongr
      _ = 1 := by ring
  rw [show (x ^ x)⁻¹ * ((1 - x) ^ (1 - x))⁻¹ = (x ^ x * (1 - x) ^ (1 - x))⁻¹ by ring]
  have : x ^ x * (1 - x) ^ (1 - x) ≠ 0 := ne_of_gt prod_pos
  nlinarith [inv_pos.mpr prod_pos, mul_inv_cancel₀ this]

/-- A monotone window bound for `negMulLog x = -x log x`: on `[a,b] ⊂ (0,1)` it is
at most `b · (-log a)`. -/
theorem negMulLog_le_of_mem_Icc {a b x : ℝ} (ha : 0 < a) (hb : b < 1)
    (hx : x ∈ Set.Icc a b) : Real.negMulLog x ≤ b * (-Real.log a) := by
  have hab : a ≤ b := hx.1.trans hx.2
  have hx_pos : 0 < x := lt_of_lt_of_le ha hx.1
  have hx_lt_one : x < 1 := lt_of_le_of_lt hx.2 hb
  have hxlog_neg : Real.log x < 0 := Real.log_neg hx_pos hx_lt_one
  have hneglogx_pos : 0 ≤ -Real.log x := by linarith
  have hlog_le : Real.log a ≤ Real.log x := Real.log_le_log ha hx.1
  have hneglog_le : -Real.log x ≤ -Real.log a := by linarith
  have hb_pos : 0 < b := lt_of_lt_of_le ha hab
  have h1 : Real.negMulLog x = x * (-Real.log x) := by simp [Real.negMulLog]
  have h2 : x * (-Real.log x) ≤ b * (-Real.log x) := mul_le_mul_of_nonneg_right hx.2 hneglogx_pos
  have h3 : b * (-Real.log x) ≤ b * (-Real.log a) := mul_le_mul_of_nonneg_left hneglog_le (le_of_lt hb_pos)
  linarith

/-- An explicit upper bound for the entropy base on a compact window
`[a,b] ⊂ (0,1)`. -/
theorem entropyBase_le_of_mem_Icc {a b x : ℝ} (ha : 0 < a) (hb : b < 1)
    (hx : x ∈ Set.Icc a b) :
    entropyBase x ≤ Real.exp (b * (-Real.log a) + (1 - a) * (-Real.log (1 - b))) := by
  have hx_mem : x ∈ Set.Icc a b := hx
  have hx0 : 0 < x := lt_of_lt_of_le ha hx_mem.1
  have hx1 : x < 1 := lt_of_le_of_lt hx_mem.2 hb
  have h1mx0 : 0 < 1 - x := by linarith
  -- entropyBase x = x ^ (-x) * (1 - x) ^ (-(1 - x))
  unfold entropyBase
  -- Rewrite using exp: x ^ (-x) = exp(-x * log x) = exp(negMulLog x)
  have hx_rpow : x ^ (-x) = Real.exp (Real.negMulLog x) := by
    rw [Real.rpow_def_of_pos hx0, Real.negMulLog]
    ring_nf
  have h1mx_rpow : (1 - x) ^ (-(1 - x)) = Real.exp (Real.negMulLog (1 - x)) := by
    rw [Real.rpow_def_of_pos h1mx0, Real.negMulLog]
    ring_nf
  rw [hx_rpow, h1mx_rpow, ← Real.exp_add]
  -- We need to bound negMulLog x + negMulLog (1 - x)
  -- Inline negMulLog_le_of_mem_Icc for x
  have hx0 : 0 < x := lt_of_lt_of_le ha hx_mem.1
  have hx1 : x < 1 := lt_of_le_of_lt hx_mem.2 hb
  have ha1 : a < 1 := lt_of_le_of_lt (hx_mem.1.trans hx_mem.2) hb
  have hx_lb : a ≤ x := hx_mem.1
  have hx_ub : x ≤ b := hx_mem.2
  have hlog_a_lt : Real.log a < 0 := Real.log_neg ha ha1
  have hneglog_a : 0 ≤ -Real.log a := by linarith
  have h1 : Real.negMulLog x ≤ b * (-Real.log a) := by
    simp [Real.negMulLog]
    have hlog_x_lt : Real.log x < 0 := Real.log_neg hx0 hx1
    have hlog_mono : Real.log a ≤ Real.log x := Real.log_le_log ha hx_lb
    nlinarith
  -- Inline negMulLog_le_of_mem_Icc for 1 - x
  have hx_1_mem : 1 - x ∈ Set.Icc (1 - b) (1 - a) := by
    constructor <;> linarith [hx_mem.1, hx_mem.2]
  have hlb : 0 < 1 - b := by linarith
  have hua : 1 - a < 1 := by linarith
  have h1mx_lb : 1 - b ≤ 1 - x := hx_1_mem.1
  have h1mx_ub : 1 - x ≤ 1 - a := hx_1_mem.2
  have h1mx1 : 1 - x < 1 := by linarith
  have h1mb : 1 - b < 1 := by linarith
  have h1ma : 1 - a < 1 := by linarith
  have h1mx_lb_pos : 0 < 1 - b := by linarith
  have hlog_1mb_lt : Real.log (1 - b) < 0 := Real.log_neg h1mx_lb_pos h1mb
  have hneglog_1mb : 0 ≤ -Real.log (1 - b) := by linarith
  have h2 : Real.negMulLog (1 - x) ≤ (1 - a) * (-Real.log (1 - b)) := by
    simp [Real.negMulLog]
    have hlog_1mx_lt : Real.log (1 - x) < 0 := Real.log_neg (by linarith : 0 < 1 - x) (by linarith : 1 - x < 1)
    have hlog_mono : Real.log (1 - b) ≤ Real.log (1 - x) := Real.log_le_log h1mx_lb_pos h1mx_lb
    nlinarith
  exact Real.exp_le_exp.mpr (by linarith)

/-! ### The sharp bound `entropyBase ≤ 2` and the unrestricted ratio window -/

/-- The entropy base is the exponential of Mathlib's binary entropy (in nats). -/
theorem entropyBase_eq_exp_binEntropy {x : ℝ} (h0 : 0 ≤ x) (h1 : x ≤ 1) :
    entropyBase x = Real.exp (Real.binEntropy x) := by
  simp [entropyBase, Real.binEntropy]
  rw [show x - 1 = -(1 - x) by ring]
  by_cases hx : x = 0
  · simp [hx]
  · by_cases hx1 : x = 1
    · simp [hx1]
    · have hx_pos : 0 < x := lt_of_le_of_ne h0 (Ne.symm hx)
      have h1x_pos : 0 < 1 - x := lt_of_le_of_ne (sub_nonneg.2 h1) (by intro h; exact hx1 (by linarith))
      rw [Real.rpow_def_of_pos hx_pos, Real.rpow_def_of_pos h1x_pos]
      rw [← Real.exp_add]
      ring_nf

/-- The entropy base is at least one on `[0,1]`. -/
theorem one_le_entropyBase {x : ℝ} (h0 : 0 ≤ x) (h1 : x ≤ 1) : 1 ≤ entropyBase x := by
  by_cases hx : x = 0 ∨ x = 1
  · rcases hx with rfl | rfl <;> unfold entropyBase <;> norm_num
  · push_neg at hx
    exact le_of_lt (one_lt_entropyBase (lt_of_le_of_ne h0 hx.1.symm) (lt_of_le_of_ne h1 hx.2))

/-- **The sharp global bound.**  The entropy base never exceeds `2`, its value at
the diagonal ratio; this is the binary-entropy inequality `H₂ ≤ log 2`. -/
theorem entropyBase_le_two {x : ℝ} (h0 : 0 ≤ x) (h1 : x ≤ 1) : entropyBase x ≤ 2 := by
  rw [entropyBase_eq_exp_binEntropy h0 h1]
  have hbin : Real.binEntropy x ≤ Real.log 2 := Real.binEntropy_le_log_two
  calc Real.exp (Real.binEntropy x) ≤ Real.exp (Real.log 2) := Real.exp_le_exp.mpr hbin
    _ = 2 := Real.exp_log two_pos

/-- The base attached to a parameter pair `(s,t)`: the entropy base at the ratio
`s/(s+t)`. -/
noncomputable def ramseyEntropyBase (s t : ℕ) : ℝ := entropyBase ((s : ℝ) / (s + t))

/-- The window of parameter pairs whose ratio lies in `[a,b]`. -/
def ratioWindow (a b : ℝ) : Set (ℕ × ℕ) :=
  {p : ℕ × ℕ | 0 < p.1 + p.2 ∧ (p.1 : ℝ) / (p.1 + p.2) ∈ Set.Icc a b}

/-- **Asymmetric normalization.**  On any compact ratio window
`s/(s+t) ∈ [a,b] ⊂ (0,1)`, a uniform proportional saving against the entropy
base is equivalent to a uniform additive gap below it. -/
theorem asymmetric_normalization {a b : ℝ} (ha : 0 < a) (hb : b < 1)
    (R : ℕ → ℕ → ℕ) :
    HasProportionalSaving₂ R ramseyEntropyBase (ratioWindow a b) ↔
      HasAdditiveGap₂ R ramseyEntropyBase (ratioWindow a b) := by
  -- Helper: entropyBase is bounded [1, 2] on ratioWindow a b
  have hβ_lb : ∀ s t : ℕ, (s, t) ∈ ratioWindow a b → 1 ≤ ramseyEntropyBase s t := by
    intro s t hp
    simp [ramseyEntropyBase]
    exact one_le_entropyBase (le_trans ha.le hp.2.1) (le_trans hp.2.2 hb.le)
  have hβ_ub : ∀ s t : ℕ, (s, t) ∈ ratioWindow a b → ramseyEntropyBase s t ≤ 2 := by
    intro s t hp
    simp [ramseyEntropyBase]
    set x := (s : ℝ) / (s + t) with hx_def
    have hx0 : 0 ≤ x := le_trans (le_of_lt ha) (hp.2.1)
    have hx1 : x ≤ 1 := le_trans (hp.2.2) hb.le
    exact entropyBase_le_two hx0 hx1
  exact proportionalSaving₂_iff_additiveGap₂ (m := 1) (M := 2) one_pos
    (fun p hp => hβ_lb p.1 p.2 hp) (fun p hp => hβ_ub p.1 p.2 hp)

/-- The diagonal pairs `(k,k)` with `k ≥ 1` lie in every ratio window containing
`1/2`. -/
theorem diagonal_mem_ratioWindow {a b : ℝ} (ha : a ≤ 1 / 2) (hb : 1 / 2 ≤ b)
    {k : ℕ} (hk : 1 ≤ k) : (k, k) ∈ ratioWindow a b := by
  rw [ratioWindow]
  constructor
  · simp; linarith
  · have hratio : (k : ℝ) / (k + k) = 1 / 2 := by
      rw [show (k : ℝ) + k = 2 * k by ring]
      rw [mul_comm]
      field_simp
    rw [Set.mem_Icc, hratio]
    exact ⟨ha, hb⟩

/-- **Off-diagonal implies diagonal.**  A two-parameter proportional saving over
a window containing the diagonal ratio `1/2` gives the one-parameter
proportional saving of the previous file for `k ↦ R k k`, since the entropy base
at `1/2` is `2` and `2^(2k) = 4^k`. -/
theorem hasProportionalSaving_diagonal_of_proportionalSaving₂ {a b : ℝ}
    (ha : a ≤ 1 / 2) (hb : 1 / 2 ≤ b) {R : ℕ → ℕ → ℕ}
    (h : HasProportionalSaving₂ R ramseyEntropyBase (ratioWindow a b)) :
    HasProportionalSaving (fun k => R k k) := by
  obtain ⟨q, hq_pos, hq_lt_one, hq⟩ := h
  use q ^ 2
  refine ⟨sq_pos_of_pos hq_pos, pow_lt_one₀ (le_of_lt hq_pos) hq_lt_one two_ne_zero, 1, ?_⟩
  intro k hk
  have hdiag_ratio : (k : ℝ) / (k + k) = 1 / 2 := by
    rw [show (k : ℝ) + k = 2 * k by ring]
    rw [mul_comm]
    field_simp
  have hp : (k, k) ∈ ratioWindow a b := by
    rw [ratioWindow]
    constructor
    · linarith
    · rw [hdiag_ratio]
      exact ⟨ha, hb⟩
  have hbase : ramseyEntropyBase k k = 2 := by
    rw [ramseyEntropyBase]
    rw [hdiag_ratio]
    exact entropyBase_half
  calc (R k k : ℝ) ≤ (q * ramseyEntropyBase k k) ^ (k + k) := hq (k, k) hp
    _ = (q * 2) ^ (2 * k) := by rw [hbase]; congr 1; ring
    _ = (4 * q ^ 2) ^ k := by rw [pow_mul, show (q * 2) ^ 2 = 4 * q ^ 2 by ring]

/-- Combining with the previous file: an off-diagonal proportional saving yields
a diagonal sub-four bound. -/
theorem hasSubFourUpperBound_diagonal_of_proportionalSaving₂ {a b : ℝ}
    (ha : a ≤ 1 / 2) (hb : 1 / 2 ≤ b) {R : ℕ → ℕ → ℕ}
    (h : HasProportionalSaving₂ R ramseyEntropyBase (ratioWindow a b)) :
    HasSubFourUpperBound (fun k => R k k) :=
  hasSubFourUpperBound_of_proportionalSaving
    (hasProportionalSaving_diagonal_of_proportionalSaving₂ ha hb h)

/-- **Compactness is not needed.**  Using the sharp bounds `1 ≤ entropyBase ≤ 2`
the equivalence of the two normalizations holds on the *full* set of parameter
pairs, i.e. on the ratio window `[0,1]`. -/
theorem asymmetric_normalization_global (R : ℕ → ℕ → ℕ) :
    HasProportionalSaving₂ R ramseyEntropyBase (ratioWindow 0 1) ↔
      HasAdditiveGap₂ R ramseyEntropyBase (ratioWindow 0 1) := by
  -- Helper: entropyBase is bounded [1, 2] on ratioWindow 0 1
  have hβ_lb : ∀ s t : ℕ, (s, t) ∈ ratioWindow 0 1 → 1 ≤ ramseyEntropyBase s t := by
    intro s t hp
    simp [ramseyEntropyBase]
    apply one_le_entropyBase
    · exact hp.2.1
    · exact hp.2.2
  have hβ_ub : ∀ s t : ℕ, (s, t) ∈ ratioWindow 0 1 → ramseyEntropyBase s t ≤ 2 := by
    intro s t hp
    simp [ramseyEntropyBase]
    apply entropyBase_le_two
    · exact hp.2.1
    · exact hp.2.2
  exact proportionalSaving₂_iff_additiveGap₂ (m := 1) (M := 2) one_pos
    (fun p hp => hβ_lb p.1 p.2 hp) (fun p hp => hβ_ub p.1 p.2 hp)

end RamseyBounds