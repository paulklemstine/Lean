import Mathlib

/-!
# Normality and equidistribution

This file does **not** assert that any currently inaccessible constant (such as `π`, `e`,
or `√2`) is normal.  Instead it proves the structural bridge used by such a result:
equidistribution of the multiplicative orbit modulo one forces every finite base-`b`
digit block to have its expected frequency.
-/

namespace NormalityConnector

open Filter Set
open scoped Topology

/-- The empirical frequency of a predicate along the first `N` terms of a sequence. -/
noncomputable def empiricalFrequency (P : ℕ → Prop) [DecidablePred P] (N : ℕ) : ℝ :=
  ((Finset.filter P (Finset.range N)).card : ℝ) / N

/-- A sequence is interval-equidistributed in `[0,1)` when every half-open interval
has its length as asymptotic empirical frequency. -/
def IntervalEquidistributed (u : ℕ → ℝ) : Prop :=
  ∀ a c : ℝ, 0 ≤ a → a < c → c ≤ 1 →
    Tendsto (empiricalFrequency (fun n => u n ∈ Ico a c)) atTop (𝓝 (c - a))

/-- The length-`k` base-`b` block seen at position `n` in the expansion of `x`.
It is encoded as an integer from `0` through `b^k-1`. -/
noncomputable def digitBlock (b k : ℕ) (x : ℝ) (n : ℕ) : ℤ :=
  ⌊Int.fract ((b : ℝ) ^ n * x) * (b : ℝ) ^ k⌋

/-- Base-`b` normality, phrased as uniform limiting frequency of every finite digit
block in the fractional expansion. -/
def BaseNormal (b : ℕ) (x : ℝ) : Prop :=
  2 ≤ b ∧ ∀ k : ℕ, 0 < k → ∀ A : ℕ, A < b ^ k →
    Tendsto (empiricalFrequency (fun n => digitBlock b k x n = (A : ℤ)))
      atTop (𝓝 (1 / (b : ℝ) ^ k))

/-- Multiplication by `b^k` converts membership in the `A`th equal subinterval of
`[0,1)` exactly into the corresponding floor-valued digit block. -/
lemma digitBlock_eq_iff_mem_interval
    {b k A n : ℕ} (hb : 2 ≤ b) (x : ℝ) :
    digitBlock b k x n = (A : ℤ) ↔
      Int.fract ((b : ℝ) ^ n * x) ∈
        Ico ((A : ℝ) / (b : ℝ) ^ k) (((A : ℝ) + 1) / (b : ℝ) ^ k) := by
  unfold digitBlock
  have hbkk : (0 : ℝ) < (b : ℝ) ^ k := by positivity
  rw [Int.floor_eq_iff]
  rw [Set.mem_Ico]
  constructor
  · intro ⟨h1, h2⟩
    exact ⟨by rw [div_le_iff₀ hbkk]; exact h1, by rw [lt_div_iff₀ hbkk]; exact h2⟩
  · intro ⟨h1, h2⟩
    have h1' : (A : ℝ) ≤ Int.fract ((b : ℝ) ^ n * x) * (b : ℝ) ^ k := by
      rw [← div_le_iff₀ hbkk]; exact h1
    have h2' : Int.fract ((b : ℝ) ^ n * x) * (b : ℝ) ^ k < (A : ℝ) + 1 := by
      rw [← lt_div_iff₀ hbkk]; exact h2
    exact ⟨h1', h2'⟩

/-- **Normality–equidistribution connector.**  If the orbit
`{b^n x}` modulo one is interval-equidistributed, then `x` is normal in base `b`.
This connects a dynamical/analytic property of an orbit to the combinatorics and
probability law of finite digit blocks. -/
theorem baseNormal_of_intervalEquidistributed
    {b : ℕ} (hb : 2 ≤ b) (x : ℝ)
    (hEq : IntervalEquidistributed (fun n => Int.fract ((b : ℝ) ^ n * x))) :
    BaseNormal b x := by
  refine ⟨hb, fun k hk A hA => ?_⟩
  have h1 : (0 : ℝ) ≤ A / b ^ k := by positivity
  have h2 : (A : ℝ) / b ^ k < ((A : ℝ) + 1) / b ^ k := by gcongr; norm_num
  have h3 : ((A : ℝ) + 1) / b ^ k ≤ 1 := by
    rw [div_le_one (by positivity : (0 : ℝ) < b ^ k)]
    norm_cast
  have hInterval := hEq ((A : ℝ) / b ^ k) (((A : ℝ) + 1) / b ^ k) h1 h2 h3
  simp +decide +zetaDelta (disch := grind) at hInterval ⊢
  convert hInterval using 2
  · ext n; exact digitBlock_eq_iff_mem_interval hb x
  · ring

end NormalityConnector