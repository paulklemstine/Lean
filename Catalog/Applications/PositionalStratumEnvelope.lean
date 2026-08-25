/-
# The booked envelope : the sharp replacement for the failed value law

`Applications.PositionalStratumMeasure.value_universality_fails` shows that the booked
(uniform-within-cell) *value* law is not an upper bound once the weight is allowed to be
non-uniform inside the strata.  This file supplies the guarded version that survives:
a **two-sided envelope** determined by the bookings `(m, M, P)` alone, which is

* valid for *every* weight honouring the bookings (`EC_envelope`),
* **sharp** at both ends (`headWitness_attains_lower`, `tailWitness_attains_upper`), and
* contains the booked value (`bookedEC_mem_envelope`), which is therefore admissible as a
  *reporting* convention but not as a guarantee.

The file also records the F1 reporting convention itself: the positional-stratum law stated
with bookings, `EC = P·Θ_R·centre(R) + (1-P)·Θ_C·centre(C)` (`booked_law_theta_form`) — an
exact identity, never a bare `(μ,P)` closed form.
-/
import Applications.PositionalStratumMeasure

namespace PositionalStratum

open Finset

noncomputable section

/-! ## Bounding a stratum's cost contribution by its mass -/

lemma sum_cost_lower {S : Finset ℕ} {w : ℕ → ℝ} (hw : ∀ i, 0 ≤ w i) {lo : ℝ}
    (hlo : ∀ i ∈ S, lo ≤ (i : ℝ)) :
    lo * mass S w ≤ ∑ i ∈ S, scanCost i * w i := by
  rw [mass, Finset.mul_sum]
  exact Finset.sum_le_sum fun i hi => mul_le_mul_of_nonneg_right (hlo i hi) (hw i)

lemma sum_cost_upper {S : Finset ℕ} {w : ℕ → ℝ} (hw : ∀ i, 0 ≤ w i) {hi : ℝ}
    (hhi : ∀ i ∈ S, (i : ℝ) ≤ hi) :
    ∑ i ∈ S, scanCost i * w i ≤ hi * mass S w := by
  rw [mass, Finset.mul_sum]
  exact Finset.sum_le_sum fun i h => mul_le_mul_of_nonneg_right (hhi i h) (hw i)

lemma positions_subset {m M : ℕ} (h : m ≤ M) : positions m ⊆ positions M := by
  intro i hi
  rw [mem_positions] at hi ⊢
  omega

/-! ## The booked envelope -/

/-- **The booked envelope.**  Every weight honouring the bookings — head stratum of size
`m` inside `M` slots carrying capture mass `P` — has expected scan cost between
`P·1 + (1-P)·(m+1)` and `P·m + (1-P)·M`.  These bounds use *only* the bookings, no
uniformity assumption. -/
theorem EC_envelope {M m : ℕ} {w : ℕ → ℝ} {P : ℝ} (hmM : m ≤ M)
    (hw : ∀ i, 0 ≤ w i) (hhead : mass (positions m) w = P)
    (htot : mass (positions M) w = 1) :
    P * 1 + (1 - P) * ((m : ℝ) + 1) ≤ EC M scanCost w ∧
      EC M scanCost w ≤ P * m + (1 - P) * M := by
  have hsub := positions_subset hmM
  have hsplit : (∑ i ∈ positions M \ positions m, scanCost i * w i)
      + ∑ i ∈ positions m, scanCost i * w i = EC M scanCost w := Finset.sum_sdiff hsub
  have htail : mass (positions M \ positions m) w = 1 - P := by
    rw [mass_compl hsub htot, hhead]
  -- head bounds
  have hh1 : (1 : ℝ) * mass (positions m) w ≤ ∑ i ∈ positions m, scanCost i * w i :=
    sum_cost_lower hw (fun i hi => by
      have := (mem_positions.mp hi).1
      exact_mod_cast this)
  have hh2 : ∑ i ∈ positions m, scanCost i * w i ≤ (m : ℝ) * mass (positions m) w :=
    sum_cost_upper hw (fun i hi => by
      have := (mem_positions.mp hi).2
      exact_mod_cast this)
  -- tail bounds
  have htmem : ∀ i ∈ positions M \ positions m, m + 1 ≤ i ∧ i ≤ M := by
    intro i hi
    rw [Finset.mem_sdiff, mem_positions, mem_positions] at hi
    omega
  have ht1 : ((m : ℝ) + 1) * mass (positions M \ positions m) w
      ≤ ∑ i ∈ positions M \ positions m, scanCost i * w i :=
    sum_cost_lower hw (fun i hi => by
      have := (htmem i hi).1
      have : ((m : ℕ) + 1 : ℝ) ≤ (i : ℝ) := by exact_mod_cast this
      linarith)
  have ht2 : ∑ i ∈ positions M \ positions m, scanCost i * w i
      ≤ (M : ℝ) * mass (positions M \ positions m) w :=
    sum_cost_upper hw (fun i hi => by
      have := (htmem i hi).2
      exact_mod_cast this)
  rw [hhead] at hh1 hh2
  rw [htail] at ht1 ht2
  constructor
  · linarith [hsplit, hh1, ht1]
  · linarith [hsplit, hh2, ht2]

/-- The head witness (all captured mass at slot `1`, all escaping mass at slot `m+1`)
attains the lower end of the envelope exactly. -/
theorem headWitness_attains_lower {m : ℕ} (hm : 1 ≤ m) :
    EC (2 * m) scanCost (headWitness m)
      = (1 - 1 / (m : ℝ)) * 1 + (1 - (1 - 1 / (m : ℝ))) * ((m : ℝ) + 1) := by
  have hmR : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
  have hmpos : (0 : ℝ) < (m : ℝ) := by linarith
  rw [headWitness_EC hm]
  field_simp
  ring

/-- The extremal tail witness: all captured mass at the *last* slot of the stratum and all
escaping mass at the last slot overall. -/
def tailWitness (m M : ℕ) (P : ℝ) : ℕ → ℝ :=
  fun i => if i = m then P else if i = M then 1 - P else 0

lemma tailWitness_eq (m M : ℕ) (P : ℝ) :
    tailWitness m M P = fun i => if i = m then P else if i = M then 1 - P else 0 := rfl

lemma tailWitness_nonneg {m M : ℕ} {P : ℝ} (hP : 0 ≤ P) (hP1 : P ≤ 1) (i : ℕ) :
    0 ≤ tailWitness m M P i := by
  rw [tailWitness_eq]
  dsimp only
  split_ifs
  · exact hP
  · linarith
  · exact le_rfl

lemma tailWitness_mass_head {m M : ℕ} {P : ℝ} (hm : 1 ≤ m) (hmM : m < M) :
    mass (positions m) (tailWitness m M P) = P := by
  have hmem : m ∈ positions m := by rw [mem_positions]; omega
  have hnot : M ∉ positions m := by rw [mem_positions]; omega
  rw [tailWitness_eq]
  exact mass_two_point_left hmem hnot _ _

lemma tailWitness_mass_total {m M : ℕ} {P : ℝ} (hm : 1 ≤ m) (hmM : m < M) :
    mass (positions M) (tailWitness m M P) = 1 := by
  have h1 : m ∈ positions M := by rw [mem_positions]; omega
  have h2 : M ∈ positions M := by rw [mem_positions]; omega
  have hne : m ≠ M := by omega
  rw [tailWitness_eq, mass_two_point_both hne h1 h2]
  ring

/-- The tail witness attains the upper end of the envelope exactly, so the envelope cannot
be tightened using the bookings alone. -/
theorem tailWitness_attains_upper {m M : ℕ} {P : ℝ} (hm : 1 ≤ m) (hmM : m < M) :
    EC M scanCost (tailWitness m M P) = P * m + (1 - P) * M := by
  have h1 : m ∈ positions M := by rw [mem_positions]; omega
  have h2 : M ∈ positions M := by rw [mem_positions]; omega
  have hne : m ≠ M := by omega
  rw [tailWitness_eq, EC_two_point (c := scanCost) hne h1 h2]
  simp only [scanCost]
  ring

/-- **The booked value is admissible but not a guarantee.**  The uniform-within-cell
prediction always lies inside the envelope; combined with `value_universality_fails` this
locates it exactly: a legitimate *reporting* number, never an upper bound. -/
theorem bookedEC_mem_envelope {M m : ℕ} {P : ℝ} (hm : 1 ≤ m) (hmM : m + 1 ≤ M)
    (hP : 0 ≤ P) (hP1 : P ≤ 1) :
    P * 1 + (1 - P) * ((m : ℝ) + 1) ≤ bookedEC M m P ∧
      bookedEC M m P ≤ P * m + (1 - P) * M := by
  have hmR : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
  have hMR : (m : ℝ) + 1 ≤ (M : ℝ) := by exact_mod_cast hmM
  rw [bookedEC]
  constructor
  · nlinarith [hP, hP1, hmR, hMR]
  · nlinarith [hP, hP1, hmR, hMR]

/-! ## Exactness at uniform cells : where the booked law is the truth -/

/-- **The booked law is exact on uniform cells.**  If the weight is flat inside the head
stratum and flat inside its complement, the expected scan cost is *exactly* the booked
value.  Together with `value_universality_fails` this delimits the booked law precisely:
an identity on uniform cells, and nothing more off them. -/
theorem bookedEC_of_uniform_cells {M m : ℕ} {P : ℝ} {w : ℕ → ℝ} (hm : 0 < m) (hmM : m < M)
    (hR : ∀ i ∈ positions m, w i = P / m)
    (hC : ∀ i ∈ positions M \ positions m, w i = (1 - P) / ((M : ℝ) - m)) :
    EC M scanCost w = bookedEC M m P := by
  have hsub := positions_subset hmM.le
  have hmR : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hMm : (0 : ℝ) < (M : ℝ) - m := by
    have : (m : ℝ) < (M : ℝ) := by exact_mod_cast hmM
    linarith
  have hsplit : (∑ i ∈ positions M \ positions m, scanCost i * w i)
      + ∑ i ∈ positions m, scanCost i * w i = EC M scanCost w := Finset.sum_sdiff hsub
  have hcostsplit : (∑ i ∈ positions M \ positions m, scanCost i)
      + ∑ i ∈ positions m, scanCost i = ∑ i ∈ positions M, scanCost i := Finset.sum_sdiff hsub
  have hsumR : ∑ i ∈ positions m, scanCost i = (m : ℝ) * ((m : ℝ) + 1) / 2 := by
    simpa [scanCost] using sum_positions m
  have hsumM : ∑ i ∈ positions M, scanCost i = (M : ℝ) * ((M : ℝ) + 1) / 2 := by
    simpa [scanCost] using sum_positions M
  have hheadsum : ∑ i ∈ positions m, scanCost i * w i = P * ((m : ℝ) + 1) / 2 := by
    have : ∑ i ∈ positions m, scanCost i * w i
        = (∑ i ∈ positions m, scanCost i) * (P / m) := by
      rw [Finset.sum_mul]
      exact Finset.sum_congr rfl fun i hi => by rw [hR i hi]
    rw [this, hsumR]
    field_simp
  have htailsum : ∑ i ∈ positions M \ positions m, scanCost i * w i
      = (1 - P) * ((M : ℝ) + m + 1) / 2 := by
    have hval : ∑ i ∈ positions M \ positions m, scanCost i * w i
        = (∑ i ∈ positions M \ positions m, scanCost i) * ((1 - P) / ((M : ℝ) - m)) := by
      rw [Finset.sum_mul]
      exact Finset.sum_congr rfl fun i hi => by rw [hC i hi]
    have hcost : ∑ i ∈ positions M \ positions m, scanCost i
        = (M : ℝ) * ((M : ℝ) + 1) / 2 - (m : ℝ) * ((m : ℝ) + 1) / 2 := by
      have := hcostsplit
      rw [hsumR, hsumM] at this
      linarith
    rw [hval, hcost]
    field_simp
    ring
  rw [← hsplit, hheadsum, htailsum, bookedEC]
  ring

/-! ## The F1 reporting convention : the law with bookings -/

/-- **The positional-stratum law in booked form.**  Writing each stratum's conditional mean
as `Θ × (cell centre)`, the exact law reads
`EC = P·Θ_R·centre(R) + (1-P)·Θ_C·centre(C)`.  The booking factors `Θ` carry all the
within-cell shape information that a bare `(μ,P)` closed form discards. -/
theorem booked_law_theta_form {M : ℕ} {w : ℕ → ℝ} {R : Finset ℕ} (hR : R ⊆ positions M)
    (htot : mass (positions M) w = 1) (hP : mass R w ≠ 0)
    (hQ : mass (positions M \ R) w ≠ 0)
    (hcR : cellCentre R scanCost ≠ 0) (hcC : cellCentre (positions M \ R) scanCost ≠ 0) :
    EC M scanCost w
      = mass R w * (Theta R scanCost w * cellCentre R scanCost)
        + (1 - mass R w)
            * (Theta (positions M \ R) scanCost w
                * cellCentre (positions M \ R) scanCost) := by
  have hR' : Theta R scanCost w * cellCentre R scanCost = rbar R scanCost w := by
    rw [Theta, div_mul_cancel₀ _ hcR]
  have hC' : Theta (positions M \ R) scanCost w * cellCentre (positions M \ R) scanCost
      = rbar (positions M \ R) scanCost w := by
    rw [Theta, div_mul_cancel₀ _ hcC]
  rw [hR', hC']
  exact rbar_identity hR htot hP hQ

end

end PositionalStratum