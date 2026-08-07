import Applications.AdjacentSumPolytopes.Growth

/-!
# The dominant growth rate of the adjacent-sum model

The bounds of `Applications.AdjacentSumPolytopes.Growth` bracket the counts between two
exponentials but do not say that a growth *rate* exists.  Here we prove that it does,
by a Fekete (subadditivity) argument applied to the diagonal counts

`diagCount s n = (adjMat s ^ n) 0 0 = #{open points of length n+1 with x₀ = xₙ = 0}`,

which are supermultiplicative because concatenation of two loops at the state `0` is a
loop at `0`.  The resulting limit

`λ_s = exp (lim_{n} (log diagCount s n)/n)`

is the reciprocal of the dominant real pole of the shared characteristic denominator,
and we show `⌊s/2⌋ + 1 ≤ λ_s ≤ s + 1` (in logarithmic form).

-- !-- Lab Notes -- !--
* **Hypothesis.** Loops at the state `0` are supermultiplicative, so Fekete's lemma
  applies and the exponential growth rate exists; the block bounds of the previous file
  bracket it.
* **Experiment.** `diagCount 2 n = 1, 1, 3, 6, 14, 31, 70, 157, ...` and the ratios
  `1, 3, 2, 2.33, 2.21, 2.26, 2.24, ...` oscillate towards the dominant root `≈ 2.2470`
  of `x³ − 2x² − x + 1`, comfortably inside `[2, 3]`.  For `s = 3`:
  `1, 1, 4, 10, 30, 85, 246, 707` with ratios approaching `≈ 2.87 ∈ [2, 4]`.
* **Analysis.** The `Subadditive` machinery of Mathlib needs `BddBelow` of `u n / n`
  where `u n = − log (diagCount s n)`; the upper block bound supplies exactly that.
  The lower bound on the limit needs a shifted subsequence, since `diagCount s 0 = 1`
  carries no information.
* **Critique.** The statement is not vacuous: `diagCount s n ≥ 1` is proved (the all-zero
  point is always admissible), so all logarithms are of positive numbers, and for
  `s ≥ 2` the limit is at least `log 2 > 0`, i.e. genuinely exponential growth.
-/

namespace AdjSum

open Finset Matrix Filter Topology

/-! ## A Fekete-type growth lemma -/

theorem tendsto_mul_div_add_one (c : ℝ) :
    Filter.Tendsto (fun n : ℕ => (n : ℝ) * c / (n + 1)) atTop (𝓝 c) := by
  have h : ∀ n : ℕ, (n : ℝ) * c / (n + 1) = c - c * (1 / ((n : ℝ) + 1)) := by
    intro n
    have hn : ((n : ℝ) + 1) ≠ 0 := by positivity
    field_simp
    ring
  simp only [h]
  have h0 : Filter.Tendsto (fun n : ℕ => (1 : ℝ) / ((n : ℝ) + 1)) atTop (𝓝 0) :=
    tendsto_one_div_add_atTop_nhds_zero_nat
  have h2 : Filter.Tendsto (fun n : ℕ => c * (1 / ((n : ℝ) + 1))) atTop (𝓝 0) := by
    simpa using h0.const_mul c
  simpa using (tendsto_const_nhds (x := c) (f := (atTop : Filter ℕ))).sub h2

/-- **Fekete growth lemma.**  A supermultiplicative sequence of positive integers
squeezed between the exponentials `Aⁿ` and `Bⁿ` has a well-defined exponential growth
rate, lying between `log A` and `log B`. -/
theorem fekete_growth (g : ℕ → ℕ) (hpos : ∀ n, 1 ≤ g n) (hsuper : ∀ m n, g m * g n ≤ g (m + n))
    (A B : ℕ) (hA : 1 ≤ A) (hB : 1 ≤ B) (hlb : ∀ n, A ^ n ≤ g (n + 1)) (hub : ∀ n, g n ≤ B ^ n) :
    ∃ L : ℝ, Filter.Tendsto (fun n : ℕ => Real.log (g n) / n) atTop (𝓝 L) ∧
      Real.log A ≤ L ∧ L ≤ Real.log B := by
  have hgpos : ∀ n, (0:ℝ) < (g n : ℝ) := fun n => by
    exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one (hpos n)
  set u : ℕ → ℝ := fun n => -Real.log (g n) with hu
  have hsub : Subadditive u := by
    intro m n
    have h1 : Real.log (g m) + Real.log (g n) ≤ Real.log (g (m + n)) := by
      rw [← Real.log_mul (ne_of_gt (hgpos m)) (ne_of_gt (hgpos n))]
      apply Real.log_le_log (mul_pos (hgpos m) (hgpos n))
      exact_mod_cast hsuper m n
    simp only [hu]
    linarith
  have hlogB : 0 ≤ Real.log B := Real.log_nonneg (by exact_mod_cast hB)
  have hle : ∀ n : ℕ, Real.log (g n) / n ≤ Real.log B := by
    intro n
    match n with
    | 0 => simpa using hlogB
    | (k + 1) =>
      have hn : (0:ℝ) < ((k + 1 : ℕ) : ℝ) := by positivity
      have h1 : Real.log (g (k + 1)) ≤ ((k + 1 : ℕ) : ℝ) * Real.log B := by
        calc Real.log (g (k + 1)) ≤ Real.log ((B:ℝ) ^ (k + 1)) := by
              apply Real.log_le_log (hgpos _)
              exact_mod_cast hub (k + 1)
          _ = ((k + 1 : ℕ) : ℝ) * Real.log B := by rw [Real.log_pow]
      rw [div_le_iff₀ hn]
      linarith
  have hbdd : BddBelow (Set.range fun n => u n / n) := by
    refine ⟨-Real.log B, ?_⟩
    rintro x ⟨n, rfl⟩
    have h := hle n
    simp only [hu, neg_div]
    linarith
  have htend : Filter.Tendsto (fun n : ℕ => Real.log (g n) / n) atTop (𝓝 (-hsub.lim)) := by
    have h := hsub.tendsto_lim hbdd
    have h2 : (fun n : ℕ => Real.log (g n) / n) = fun n : ℕ => -(u n / n) := by
      funext n; simp only [hu]; ring
    rw [h2]; exact h.neg
  refine ⟨-hsub.lim, htend, ?_, le_of_tendsto htend (Filter.Eventually.of_forall hle)⟩
  -- lower bound via the shifted subsequence
  have hshift : Filter.Tendsto (fun n : ℕ => Real.log (g (n + 1)) / ((n : ℝ) + 1)) atTop
      (𝓝 (-hsub.lim)) := by
    have h := htend.comp (Filter.tendsto_add_atTop_nat 1)
    refine h.congr (fun n => ?_)
    simp only [Function.comp_apply]
    push_cast
    ring
  have hcomp : ∀ n : ℕ, (n : ℝ) * Real.log A / ((n : ℝ) + 1)
      ≤ Real.log (g (n + 1)) / ((n : ℝ) + 1) := by
    intro n
    have hn : (0:ℝ) < (n : ℝ) + 1 := by positivity
    have h1 : (n : ℝ) * Real.log A ≤ Real.log (g (n + 1)) := by
      calc (n : ℝ) * Real.log A = Real.log ((A : ℝ) ^ n) := by rw [Real.log_pow]
        _ ≤ Real.log (g (n + 1)) := by
            apply Real.log_le_log (by positivity)
            · exact_mod_cast hlb n
    gcongr
  exact le_of_tendsto_of_tendsto' (tendsto_mul_div_add_one (Real.log A)) hshift hcomp

/-! ## The diagonal loop counts -/

/-- `diagCount s n` is the number of open adjacent-sum points of length `n + 1` whose
first and last coordinates are `0`; equivalently the `(0,0)` entry of the `n`-th power
of the transfer matrix. -/
def diagCount (s n : ℕ) : ℕ := (adjMat s ^ n) 0 0

theorem diagCount_eq_card (s n : ℕ) : diagCount s n = (pathSet s n 0 0).card :=
  (card_pathSet s n 0 0).symm

theorem zero_mem_coreStates (s : ℕ) : (0 : Fin (s + 1)) ∈ coreStates s := by
  simp [coreStates]

/-- Concatenating two loops at the state `0` gives a loop at `0`. -/
theorem diagCount_supermul (s m n : ℕ) :
    diagCount s m * diagCount s n ≤ diagCount s (m + n) := by
  rw [diagCount, diagCount, diagCount, pow_add, Matrix.mul_apply]
  exact Finset.single_le_sum (f := fun c => (adjMat s ^ m) 0 c * (adjMat s ^ n) c 0)
    (fun c _ => Nat.zero_le _) (Finset.mem_univ 0)

theorem blockCore_le_diagCount (s n : ℕ) : (s / 2 + 1) ^ n ≤ diagCount s (n + 1) := by
  have h1 : (blockMat (coreStates s) ^ (n + 1)) 0 0 = (s / 2 + 1) ^ n := by
    rw [blockMat_pow, card_coreStates]
    simp [blockMat, zero_mem_coreStates s]
  rw [diagCount, ← h1]
  exact pow_entry_le_pow_entry _ _ (blockMat_coreStates_le s) (n + 1) 0 0

theorem one_le_diagCount (s n : ℕ) : 1 ≤ diagCount s n := by
  match n with
  | 0 => simp [diagCount]
  | (k + 1) =>
      refine le_trans ?_ (blockCore_le_diagCount s k)
      exact Nat.one_le_pow _ _ (by omega)

theorem diagCount_le_pow (s n : ℕ) : diagCount s n ≤ (s + 1) ^ n := by
  match n with
  | 0 => simp [diagCount]
  | (k + 1) =>
      have h1 : (blockMat (Finset.univ : Finset (Fin (s + 1))) ^ (k + 1)) 0 0 = (s + 1) ^ k := by
        rw [blockMat_pow, Finset.card_univ, Fintype.card_fin]
        simp [blockMat]
      have h2 : diagCount s (k + 1) ≤ (s + 1) ^ k := by
        rw [diagCount, ← h1]
        exact pow_entry_le_pow_entry _ _ (adjMat_le_blockMat_univ s) (k + 1) 0 0
      exact le_trans h2 (Nat.pow_le_pow_right (by omega) (by omega))

/-! ## Existence of the dominant growth rate -/

/-- **Dominant growth rate.**  The adjacent-sum loop counts have a well-defined
exponential growth rate `L = log λ_s`, and `log (⌊s/2⌋+1) ≤ L ≤ log (s+1)`.  Equivalently
the dominant real pole of the shared characteristic denominator is `1/λ_s ∈
[1/(s+1), 1/(⌊s/2⌋+1)]`. -/
theorem exists_dominant_growth_rate (s : ℕ) :
    ∃ L : ℝ, Filter.Tendsto (fun n : ℕ => Real.log (diagCount s n) / n) atTop (𝓝 L) ∧
      Real.log ((s / 2 + 1 : ℕ) : ℝ) ≤ L ∧ L ≤ Real.log ((s + 1 : ℕ) : ℝ) :=
  fekete_growth (diagCount s) (one_le_diagCount s) (diagCount_supermul s)
    (s / 2 + 1) (s + 1) (by omega) (by omega) (blockCore_le_diagCount s) (diagCount_le_pow s)

/-- For `s ≥ 2` the growth is genuinely exponential: the growth rate is at least
`log 2 > 0`. -/
theorem dominant_growth_rate_pos (s : ℕ) (hs : 2 ≤ s) :
    ∃ L : ℝ, Filter.Tendsto (fun n : ℕ => Real.log (diagCount s n) / n) atTop (𝓝 L) ∧
      0 < L := by
  obtain ⟨L, hL, hlb, -⟩ := exists_dominant_growth_rate s
  refine ⟨L, hL, lt_of_lt_of_le ?_ hlb⟩
  have h2 : (2 : ℝ) ≤ ((s / 2 + 1 : ℕ) : ℝ) := by
    have h : 2 ≤ s / 2 + 1 := by omega
    exact_mod_cast h
  calc (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
    _ ≤ Real.log ((s / 2 + 1 : ℕ) : ℝ) := Real.log_le_log (by norm_num) h2

end AdjSum