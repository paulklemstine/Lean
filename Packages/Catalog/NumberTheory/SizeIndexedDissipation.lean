import Catalog.Novelty.ThermodynamicsOfProof

/-!
# Size-indexed dissipation bounds

This file lifts the catalog's finite-state Landauer theory to families of decision
procedures indexed by input length.  The main theorem allows an arbitrary real-valued
lower-bound function `b`; linear and unbounded consequences are then obtained without
assuming that the input or output state spaces are uniform in the index.
-/

open Function

namespace SizeIndexedDissipation

open ThermoProof

variable {α β : ℕ → Type*}
variable [∀ n, Fintype (α n)] [∀ n, DecidableEq (β n)]

/-- A family discards at least `b n` bits at size `n` when its finite-state entropy drop
is bounded below by `b n`. -/
def DiscardsAtLeast (f : ∀ n, α n → β n) (b : ℕ → ℝ) : Prop :=
  ∀ n, b n ≤ erasedBits (f n)

/-- A cardinality inequality stated directly in logarithmic units implies the abstract
`DiscardsAtLeast` condition.  This is useful when the bound comes from counting possible
inputs and distinguishable outputs. -/
theorem discardsAtLeast_of_log_image_bound
    (f : ∀ n, α n → β n) (b : ℕ → ℝ)
    (hcount : ∀ n,
      b n + Real.logb 2 (imageCard (f n)) ≤
        Real.logb 2 (Fintype.card (α n))) :
    DiscardsAtLeast f b := by
  intro n
  unfold erasedBits
  linarith [hcount n]

/-- **Size-indexed Landauer lower bound.** If the size-`n` procedure discards at least
`b n` unbiased logical bits, then at nonnegative Boltzmann constant and temperature its
Landauer cost is at least `b n · kB · T · log 2`. -/
theorem landauerCost_family_lower_bound
    (f : ∀ n, α n → β n) (b : ℕ → ℝ)
    (hdiscard : DiscardsAtLeast f b)
    {kB T : ℝ} (hkB : 0 ≤ kB) (hT : 0 ≤ T) (n : ℕ) :
    b n * (kB * T * Real.log 2) ≤
      landauerCost (erasedBits (f n)) kB T := by
  unfold landauerCost
  apply mul_le_mul_of_nonneg_right (hdiscard n)
  positivity

/-- The lower bound is strict whenever the claimed bit loss is strict and the physical
parameters are positive. -/
theorem landauerCost_family_strict_lower_bound
    (f : ∀ n, α n → β n) (b : ℕ → ℝ)
    (hdiscard : ∀ n, b n < erasedBits (f n))
    {kB T : ℝ} (hkB : 0 < kB) (hT : 0 < T) (n : ℕ) :
    b n * (kB * T * Real.log 2) <
      landauerCost (erasedBits (f n)) kB T := by
  unfold landauerCost
  apply mul_lt_mul_of_pos_right (hdiscard n)
  positivity

/-- A linear logical-erasure lower bound yields a linear thermodynamic lower bound with
exactly the same rate, scaled by the Landauer energy per bit. -/
theorem linear_dissipation_lower_bound
    (f : ∀ n, α n → β n) (c : ℝ)
    (hlinear : ∀ n, c * n ≤ erasedBits (f n))
    {kB T : ℝ} (hkB : 0 ≤ kB) (hT : 0 ≤ T) (n : ℕ) :
    c * n * (kB * T * Real.log 2) ≤
      landauerCost (erasedBits (f n)) kB T := by
  exact landauerCost_family_lower_bound f (fun n => c * n) hlinear hkB hT n

/-- The size-indexed bound also amortizes over every finite workload: total dissipated
cost is bounded below by the total guaranteed bit loss times the cost per bit. -/
theorem finite_workload_dissipation_lower_bound
    (f : ∀ n, α n → β n) (b : ℕ → ℝ)
    (hdiscard : DiscardsAtLeast f b)
    {kB T : ℝ} (hkB : 0 ≤ kB) (hT : 0 ≤ T) (sizes : Finset ℕ) :
    (∑ n ∈ sizes, b n) * (kB * T * Real.log 2) ≤
      ∑ n ∈ sizes, landauerCost (erasedBits (f n)) kB T := by
  rw [Finset.sum_mul]
  apply Finset.sum_le_sum
  intro n hn
  exact landauerCost_family_lower_bound f b hdiscard hkB hT n

/-- If the guaranteed number of discarded bits is unbounded, then at fixed positive
physical parameters the family's Landauer costs are unbounded as well. -/
theorem unbounded_landauerCost_of_unbounded_discard
    (f : ∀ n, α n → β n) (b : ℕ → ℝ)
    (hdiscard : DiscardsAtLeast f b)
    (hunbounded : ∀ C : ℝ, ∃ n, C < b n)
    {kB T : ℝ} (hkB : 0 < kB) (hT : 0 < T) :
    ∀ E : ℝ, ∃ n,
      E < landauerCost (erasedBits (f n)) kB T := by
  intro E
  let L : ℝ := kB * T * Real.log 2
  have hL : 0 < L := by
    dsimp [L]
    positivity
  obtain ⟨n, hn⟩ := hunbounded (E / L)
  refine ⟨n, lt_of_lt_of_le ((div_lt_iff₀ hL).mp hn) ?_⟩
  exact landauerCost_family_lower_bound f b hdiscard hkB.le hT.le n

end SizeIndexedDissipation