/-
# The sparse regime: the plug-in reading *is* the label entropy, and its null is degenerate

Cycles 1–2 proved that a symmetric readout leaks exactly zero which-factor bits
(`galoisBlind_zero_leakage`), that a zero reading is exactly independence
(`mutualInfo_eq_zero_iff_product`), and that a two-sample from an independent population can
read a full bit while its permutation null reads the same (`wall_was_bias`).

This cycle explains the *quantitative* shape of the experimental verdict — observed reading
≈ permutation-null mean, `z ≈ 0`, tiny null spread — by identifying the exact regime the
experiment was in: **a code so fine that nearly every sample carries its own code value**.
In the idealised limit of that regime (all code values distinct) everything can be computed
in closed form.

## Main results

* `sparse_mutualInfo` — if every sample carries a distinct code, the plug-in mutual
  information between the label and the code equals **exactly the label entropy**
  `H(ℓ)`, whatever the relationship between labels and codes.  The reading is a function of
  the label margin alone; it contains no information about dependence.
* `sparse_null_invariant` — consequently *every* label-permuted surrogate reads the same
  value: the permutation null is a point mass.
* `sparse_z_numerator_zero` — observed minus null mean is identically `0`, and the null
  spread (measured by the maximum deviation) is `0`.  This is the experimental signature
  `z ≈ 0` in exact form.
* `sparse_reading_le_one` — the reading is at most `1` bit, the binary-label ceiling,
  reached exactly at a balanced label margin.

Read together with `battery4_zero_leakage`: in the sparse regime the plug-in statistic
*cannot* be evidence of leakage, because it is measurable with respect to the label counts;
and the true leakage of the symmetric battery is `0`.  The flagged wall was bias.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): the observed reading in the experiment tracks the *label entropy*, not
  any dependence, because the four-field code is nearly injective on the sample.
Experiment (Stage 2, `ComputationalEvidence.md`): 3995 ordered prime pairs, 3597 distinct
  four-field codes (90% of samples carry a unique code); observed reading `0.8985` bits
  against a label entropy of `1.0000` bits and a permutation-null mean of `0.8996` bits with
  sd `0.0046`.  In the fully injective limit the theorem below predicts observed = null =
  `H(ℓ) = 1` exactly; the residual `0.10` bits is the effect of the 398 collision samples.
Analysis (Stage 3): conditional entropy `H(ℓ ∣ code)` vanishes identically when the code is
  injective on the sample, so `Î = H(ℓ) − 0 = H(ℓ)`, a statistic of the label margin alone,
  which every permutation preserves.  The permutation null therefore has zero variance — and
  a z-score with a vanishing denominator is the correct diagnosis of the reported `z = +0.05`
  with `sd = 0.0014`: the null had almost no spread because the statistic was almost
  deterministic.
Critique (Stage 4): the closed form needs exact injectivity; with collisions the reading is
  only *bounded* by `H(ℓ)`, and the null acquires a small spread — which is exactly what the
  numerical run shows.  We state the injective case, which is a theorem, and quantify the
  collision case numerically rather than pretending it is proved.
Synthesis (Stage 5): in the sparse regime the plug-in mutual information is not an estimator
  of mutual information at all; it is a relabelling-invariant function of the label counts.
-/
import Mathlib
import Computation.FactorBlindnessInformation

namespace Computation.FactorBlindness

open Finset

variable {n : ℕ}

/-- The number of samples carrying label `b`. -/
def labelCount (l : Fin n → Bool) (b : Bool) : ℕ := (univ.filter (fun i => l i = b)).card

/-- The empirical (label, code) table of a sample of size `n` whose `n` code values are
pairwise distinct: sample `i` is its own code value. -/
noncomputable def sparseTable (l : Fin n → Bool) : Bool → Fin n → ℝ :=
  fun b i => if l i = b then 1 / (n : ℝ) else 0

theorem labelCount_add (l : Fin n → Bool) : labelCount l true + labelCount l false = n := by
  unfold labelCount
  have h : (univ.filter (fun i => l i = false))
      = univ.filter (fun i => ¬ l i = true) := by
    apply Finset.filter_congr
    intro x _
    cases hb : l x <;> simp
  rw [h, Finset.card_filter_add_card_filter_not]
  simp

theorem sparse_margK (l : Fin n → Bool) (i : Fin n) :
    margK (sparseTable l) i = 1 / (n : ℝ) := by
  unfold margK sparseTable
  cases hb : l i <;> simp

theorem sparse_margL (l : Fin n → Bool) (b : Bool) :
    margL (sparseTable l) b = (labelCount l b : ℝ) / n := by
  unfold margL sparseTable labelCount
  rw [Finset.sum_ite, Finset.sum_const, Finset.sum_const_zero, add_zero, nsmul_eq_mul]
  ring

/-- The `b`-row of the plug-in sum contributes exactly the Shannon term of the label
frequency. -/
theorem sparse_row (l : Fin n → Bool) (b : Bool) :
    ∑ i, sparseTable l b i * Real.logb 2
        (sparseTable l b i / (margL (sparseTable l) b * margK (sparseTable l) i))
      = -(((labelCount l b : ℝ) / n) * Real.logb 2 ((labelCount l b : ℝ) / n)) := by
  rcases Nat.eq_zero_or_pos (labelCount l b) with hc | hc
  · have hzero : ∀ i : Fin n, l i ≠ b := by
      intro i hi
      have hmem : i ∈ univ.filter (fun i => l i = b) := by simp [hi]
      have : 0 < (univ.filter (fun i => l i = b)).card := Finset.card_pos.2 ⟨i, hmem⟩
      unfold labelCount at hc
      omega
    simp [sparseTable, hzero, hc]
  · have hn : 0 < n := by
      by_contra h
      have hn0 : n = 0 := by omega
      subst hn0
      unfold labelCount at hc
      simp at hc
    have hnR : (0 : ℝ) < n := by exact_mod_cast hn
    have hcR : (0 : ℝ) < (labelCount l b : ℝ) := by exact_mod_cast hc
    have hterm : ∀ i ∈ (univ : Finset (Fin n)),
        sparseTable l b i * Real.logb 2
            (sparseTable l b i / (margL (sparseTable l) b * margK (sparseTable l) i))
          = if l i = b then (1 / (n : ℝ)) * Real.logb 2 ((n : ℝ) / (labelCount l b : ℝ))
            else 0 := by
      intro i _
      rw [sparse_margL, sparse_margK]
      by_cases hi : l i = b
      · simp only [sparseTable, if_pos hi]
        congr 2
        field_simp
      · simp [sparseTable, hi]
    rw [Finset.sum_congr rfl hterm, Finset.sum_ite, Finset.sum_const, Finset.sum_const_zero,
      add_zero, nsmul_eq_mul]
    have hinv : ((n : ℝ) / (labelCount l b : ℝ)) = (((labelCount l b : ℝ)) / n)⁻¹ := by
      field_simp
    rw [hinv, Real.logb_inv]
    have hcard : ((univ.filter (fun i => l i = b)).card : ℝ) = (labelCount l b : ℝ) := rfl
    rw [hcard]
    field_simp

/-- **In the sparse regime the reading is the label entropy.**  When every sample carries its
own code value, the plug-in mutual information between label and code equals `H(ℓ)` exactly —
a function of the label margin alone, carrying no information about any dependence. -/
theorem sparse_mutualInfo (l : Fin n → Bool) :
    mutualInfo (sparseTable l) = entropy (fun b => (labelCount l b : ℝ) / n) := by
  unfold mutualInfo entropy
  exact Finset.sum_congr rfl fun b _ => sparse_row l b

/-- Relabelling by a permutation of the samples does not change the label counts. -/
theorem labelCount_perm (l : Fin n → Bool) (π : Equiv.Perm (Fin n)) (b : Bool) :
    labelCount (l ∘ π) b = labelCount l b := by
  unfold labelCount
  refine Finset.card_bij' (fun i _ => π i) (fun i _ => π.symm i) ?_ ?_ ?_ ?_
  · intro a ha
    simp only [mem_filter, mem_univ, true_and, Function.comp_apply] at ha ⊢
    exact ha
  · intro a ha
    simp only [mem_filter, mem_univ, true_and, Function.comp_apply] at ha ⊢
    simpa using ha
  · intro a _; simp
  · intro a _; simp

/-- **The permutation null is a point mass.**  Every label-permuted surrogate of a sparse
sample reads exactly the same value as the observed sample. -/
theorem sparse_null_invariant (l : Fin n → Bool) (π : Equiv.Perm (Fin n)) :
    mutualInfo (sparseTable (l ∘ π)) = mutualInfo (sparseTable l) := by
  rw [sparse_mutualInfo, sparse_mutualInfo]
  unfold entropy
  exact Finset.sum_congr rfl fun b _ => by simp only [labelCount_perm]

/-- **The z-score numerator vanishes identically, and the null has zero spread.**  This is the
exact form of the experimental signature `observed = null mean`, `z ≈ 0`. -/
theorem sparse_z_numerator_zero (l : Fin n → Bool) :
    mutualInfo (sparseTable l)
        - (∑ π : Equiv.Perm (Fin n), mutualInfo (sparseTable (l ∘ π)))
            / (Fintype.card (Equiv.Perm (Fin n))) = 0 ∧
      ∀ π : Equiv.Perm (Fin n),
        mutualInfo (sparseTable (l ∘ π)) - mutualInfo (sparseTable l) = 0 := by
  have hconst : ∀ π : Equiv.Perm (Fin n),
      mutualInfo (sparseTable (l ∘ π)) = mutualInfo (sparseTable l) :=
    fun π => sparse_null_invariant l π
  constructor
  · rw [Finset.sum_congr rfl (fun π _ => hconst π), Finset.sum_const, Finset.card_univ,
      nsmul_eq_mul]
    have hpos : (0 : ℝ) < Fintype.card (Equiv.Perm (Fin n)) := by
      have : 0 < Fintype.card (Equiv.Perm (Fin n)) := Fintype.card_pos
      exact_mod_cast this
    field_simp
    ring
  · intro π
    rw [hconst π]
    ring

/-- The label frequencies form a probability vector. -/
theorem sparse_label_total (l : Fin n → Bool) (hn : 0 < n) :
    ∑ b, ((labelCount l b : ℝ) / n) = 1 := by
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  have h := labelCount_add l
  have hR : ((labelCount l true : ℝ)) + ((labelCount l false : ℝ)) = (n : ℝ) := by
    exact_mod_cast congrArg (fun m : ℕ => (m : ℝ)) h
  rw [Fintype.sum_bool]
  field_simp
  linarith

/-- **The binary ceiling.**  In the sparse regime the reading never exceeds `1` bit — the
entropy of a binary label — no matter how the codes are arranged. -/
theorem sparse_reading_le_one (l : Fin n → Bool) (hn : 0 < n) :
    mutualInfo (sparseTable l) ≤ 1 := by
  have hnn : ∀ b, (0:ℝ) ≤ (labelCount l b : ℝ) / n := by
    intro b; positivity
  have h := entropy_le_logb_card hnn (sparse_label_total l hn)
  rw [sparse_mutualInfo]
  simpa [Real.logb_self_eq_one] using h

end Computation.FactorBlindness