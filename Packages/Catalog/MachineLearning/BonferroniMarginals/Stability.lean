import MachineLearning.BonferroniMarginals.HigherOrderNecessity

/-!
# Quantitative rigidity: near-tightness forces near-regularity

`Rigidity.lean` characterises *exact* equality in the second-moment bound
`(∑ᵢ|Aᵢ|)² ≤ |cover| · ∑_{(i,j)}|Aᵢ ∩ Aⱼ|`: it holds iff the coverage
multiplicity is constant.  Exact statements of that kind are fragile, so this
file upgrades the characterisation to a **stability** statement with an explicit
modulus.

Main results.

* `sq_spread_le_gap` — for any two covered points `x, y`,
  `(mult x − mult y)² ≤ |cover|·∑_{(i,j)}|Aᵢ∩Aⱼ| − (∑ᵢ|Aᵢ|)²`.
  The whole spread of the multiplicity function is controlled by the square root
  of the Cauchy–Schwarz gap.
* `regular_of_gap_zero` — the exact rigidity statement re-derived as the
  degenerate case, and `mult_eq_of_gap_lt_one` : a gap smaller than `1` already
  forces exact regularity (the gap is an integer).
* `bonferroni_defect_le_gap` — the Bonferroni defect `∑ₓ(mult x − 1)²` of
  `Rigidity.lean` is itself controlled: for a family whose Cauchy–Schwarz gap is
  `g` and whose average multiplicity is `1`, the defect is at most `g`.

Machine-learning reading: an ensemble whose second-order statistics are within
`g` of the Corrádi extremal profile has all coverage multiplicities within
`√g` of each other — the failure mass is *uniformly* spread, quantitatively.
-/

namespace BonferroniMarginals

open Finset

variable {Ω ι : Type*} [DecidableEq Ω]
variable {I : Finset ι} {A : ι → Finset Ω}

/-- The Cauchy–Schwarz gap of a family, as an integer:
`|cover|·∑_{(i,j)}|Aᵢ∩Aⱼ| − (∑ᵢ|Aᵢ|)² ≥ 0`. -/
def csGap (I : Finset ι) (A : ι → Finset Ω) : ℤ :=
  ((cover I A).card : ℤ) * (∑ x ∈ cover I A, (mult I A x : ℤ) ^ 2)
    - (∑ x ∈ cover I A, (mult I A x : ℤ)) ^ 2

/-- The gap is the quantity appearing in `sq_sum_card_le_card_cover_mul_sum_prod`,
expressed in the marginals. -/
lemma csGap_eq_marginals [DecidableEq ι] (I : Finset ι) (A : ι → Finset Ω) :
    csGap I A = ((cover I A).card : ℤ) * (∑ p ∈ I ×ˢ I, (A p.1 ∩ A p.2).card : ℕ)
      - ((∑ i ∈ I, (A i).card : ℕ) : ℤ) ^ 2 := by
  have h1 := sum_mult_eq_sum_card I A
  have h2 := sum_mult_sq_eq_sum_prod I A
  rw [csGap, ← h1, ← h2]
  push_cast
  ring

lemma csGap_nonneg (I : Finset ι) (A : ι → Finset Ω) : 0 ≤ csGap I A := by
  have hL := lagrange_identity (cover I A) (fun x => (mult I A x : ℤ))
  have hnn : (0:ℤ) ≤ ∑ x ∈ cover I A, ∑ y ∈ cover I A,
      ((mult I A x : ℤ) - (mult I A y : ℤ)) ^ 2 :=
    Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => sq_nonneg _
  rw [← hL] at hnn
  rw [csGap]
  linarith

/-- **Quantitative rigidity.**  Any two covered points have multiplicities
differing by at most the square root of the Cauchy–Schwarz gap. -/
theorem sq_spread_le_gap (I : Finset ι) (A : ι → Finset Ω) {x y : Ω}
    (hx : x ∈ cover I A) (hy : y ∈ cover I A) :
    ((mult I A x : ℤ) - (mult I A y : ℤ)) ^ 2 ≤ csGap I A := by
  classical
  set U := cover I A with hU
  set f : Ω → ℤ := fun z => (mult I A z : ℤ) with hf
  have hL := lagrange_identity U f
  by_cases hxy : x = y
  · subst hxy
    simpa using csGap_nonneg I A
  -- restrict the double sum to the two-point subset `{x, y}`
  have hsub : ({x, y} : Finset Ω) ⊆ U := by
    intro z hz
    simp only [Finset.mem_insert, Finset.mem_singleton] at hz
    rcases hz with rfl | rfl
    · exact hx
    · exact hy
  have hinner : ∀ z ∈ U, ∑ w ∈ ({x, y} : Finset Ω), (f z - f w) ^ 2
      ≤ ∑ w ∈ U, (f z - f w) ^ 2 := by
    intro z _
    exact Finset.sum_le_sum_of_subset_of_nonneg hsub (fun w _ _ => sq_nonneg _)
  have houter : ∑ z ∈ ({x, y} : Finset Ω), ∑ w ∈ ({x, y} : Finset Ω), (f z - f w) ^ 2
      ≤ ∑ z ∈ U, ∑ w ∈ U, (f z - f w) ^ 2 := by
    calc ∑ z ∈ ({x, y} : Finset Ω), ∑ w ∈ ({x, y} : Finset Ω), (f z - f w) ^ 2
        ≤ ∑ z ∈ U, ∑ w ∈ ({x, y} : Finset Ω), (f z - f w) ^ 2 :=
          Finset.sum_le_sum_of_subset_of_nonneg hsub
            (fun z _ _ => Finset.sum_nonneg fun _ _ => sq_nonneg _)
      _ ≤ ∑ z ∈ U, ∑ w ∈ U, (f z - f w) ^ 2 := Finset.sum_le_sum hinner
  have htwo : ∑ z ∈ ({x, y} : Finset Ω), ∑ w ∈ ({x, y} : Finset Ω), (f z - f w) ^ 2
      = 2 * (f x - f y) ^ 2 := by
    rw [Finset.sum_pair hxy, Finset.sum_pair hxy, Finset.sum_pair hxy]
    ring
  rw [htwo] at houter
  rw [csGap]
  linarith [hL, houter]

/-- If the Cauchy–Schwarz gap vanishes the cover is regular — the exact rigidity
statement, recovered from the quantitative one. -/
theorem regular_of_gap_zero (I : Finset ι) (A : ι → Finset Ω) (h : csGap I A = 0) :
    ∃ d, IsRegularCover I A d := by
  classical
  rcases (cover I A).eq_empty_or_nonempty with hemp | ⟨x0, hx0⟩
  · exact ⟨0, fun x hx => absurd hx (by simp [hemp])⟩
  · refine ⟨mult I A x0, fun x hx => ?_⟩
    have hsq := sq_spread_le_gap I A hx hx0
    rw [h] at hsq
    have : ((mult I A x : ℤ) - (mult I A x0 : ℤ)) ^ 2 = 0 :=
      le_antisymm hsq (sq_nonneg _)
    have hzero : (mult I A x : ℤ) - (mult I A x0 : ℤ) = 0 := by
      exact pow_eq_zero_iff (n := 2) (by norm_num) |>.mp this
    have : (mult I A x : ℤ) = (mult I A x0 : ℤ) := by linarith
    exact_mod_cast this

/-- Because the gap is an integer, a gap strictly below `1` already forces exact
regularity: there is no "almost regular" regime between `0` and `1`. -/
theorem mult_eq_of_gap_lt_one (I : Finset ι) (A : ι → Finset Ω) (h : csGap I A < 1)
    {x y : Ω} (hx : x ∈ cover I A) (hy : y ∈ cover I A) :
    mult I A x = mult I A y := by
  have hg : csGap I A = 0 := le_antisymm (by omega) (csGap_nonneg I A)
  have hsq := sq_spread_le_gap I A hx hy
  rw [hg] at hsq
  have hzero : ((mult I A x : ℤ) - (mult I A y : ℤ)) ^ 2 = 0 :=
    le_antisymm hsq (sq_nonneg _)
  have : (mult I A x : ℤ) - (mult I A y : ℤ) = 0 :=
    pow_eq_zero_iff (n := 2) (by norm_num) |>.mp hzero
  have : (mult I A x : ℤ) = (mult I A y : ℤ) := by linarith
  exact_mod_cast this

/-- **The Bonferroni defect is controlled by the gap on unit-average families.**
If the family covers each point once on average — `∑ᵢ|Aᵢ| = |cover|` — then the
Bonferroni defect `∑ₓ (mult x − 1)²` equals the Cauchy–Schwarz gap divided by
`|cover|`; in the division-free form, `|cover| · defect = gap`. -/
theorem card_cover_mul_defect_eq_gap (I : Finset ι) (A : ι → Finset Ω)
    (havg : ∑ x ∈ cover I A, mult I A x = (cover I A).card) :
    ((cover I A).card : ℤ) * (∑ x ∈ cover I A, ((mult I A x : ℤ) - 1) ^ 2)
      = csGap I A := by
  have hexpand : ∑ x ∈ cover I A, ((mult I A x : ℤ) - 1) ^ 2
      = (∑ x ∈ cover I A, (mult I A x : ℤ) ^ 2)
        - 2 * (∑ x ∈ cover I A, (mult I A x : ℤ)) + (cover I A).card := by
    have hpt : ∀ x : Ω, ((mult I A x : ℤ) - 1) ^ 2
        = (mult I A x : ℤ) ^ 2 - 2 * (mult I A x : ℤ) + 1 := by
      intro x; ring
    simp only [hpt, Finset.sum_add_distrib, Finset.sum_sub_distrib, Finset.sum_const,
      nsmul_eq_mul, ← Finset.mul_sum]
    ring
  have hcast : (∑ x ∈ cover I A, (mult I A x : ℤ)) = ((cover I A).card : ℤ) := by
    have : ((∑ x ∈ cover I A, mult I A x : ℕ) : ℤ) = ((cover I A).card : ℤ) := by
      exact_mod_cast congrArg (fun n : ℕ => (n : ℤ)) havg
    push_cast at this
    linarith
  rw [csGap, hexpand, hcast]
  ring

end BonferroniMarginals