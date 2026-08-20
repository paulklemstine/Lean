/-
# The sharp Hilbert → total-variation bound for aligned policies

Fifth file of the neurosymbolic RLHF thread.  `RLHFHilbertIsometry.lean` proves
the crude comparison `‖p - q‖_TV ≤ e^{d_H(p,q)} - 1`, which is useless once
`d_H > log 2` because it exceeds the trivial bound `1`.  Here we prove the
*sharp* Birkhoff-type comparison

  `‖p - q‖_TV ≤ (e^{d/2} - 1) / (e^{d/2} + 1) = tanh (d_H(p,q) / 4)`,

which is always `< 1`, and combine it with the tilt isometry to obtain the
final reward-model-misspecification bound

  `‖π_β(r₁) - π_β(r₂)‖_TV ≤ tanh (oscil (r₁ - r₂) / (4β))`.

The proof is a genuine optimisation: writing `u = e^{sup log(p/q)}`,
`v = e^{inf log(p/q)}` and splitting the space at `{p ≥ q}`, the total variation
obeys the two linear constraints `a ≤ u x` and `1 - a ≥ v (1 - x)`; eliminating
`x` gives `TV ≤ (u-1)(1-v)/((u-1)+(1-v))`, and the extremal analysis reduces to
the single square `(v w - 1)² ≥ 0` where `w² = u / v`.  That square is the exact
reason the constant is `tanh(d/4)`.

No `sorry`, no `native_decide`.
-/
import MachineLearning.RLHFDriftBudget

open Finset Real BigOperators

noncomputable section

namespace NeuroSymbolicRLHF

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-- The elementary optimisation behind Birkhoff's contraction constant:
maximising `t` under `t ≤ (v w² - 1) x` and `t ≤ (1 - v)(1 - x)` gives
`t ≤ (w - 1)/(w + 1)`.  The entire content is the square `(v w - 1)² ≥ 0`. -/
theorem birkhoff_two_constraint_bound {t x v w : ℝ} (hv1 : v ≤ 1) (hw : 1 ≤ w)
    (hx0 : 0 ≤ x) (h1 : t ≤ (v * w ^ 2 - 1) * x)
    (h2 : t ≤ (1 - v) * (1 - x)) :
    t ≤ (w - 1) / (w + 1) := by
  have hwpos : 0 < w + 1 := by linarith
  rcases le_or_gt (v * w ^ 2) 1 with hcase | hcase
  · have ht : t ≤ 0 := le_trans h1 (mul_nonpos_of_nonpos_of_nonneg (by linarith) hx0)
    have : 0 ≤ (w - 1) / (w + 1) := div_nonneg (by linarith) hwpos.le
    linarith
  · -- the combination `(1-v)·h1 + (v w² - 1)·h2`
    have hA : 0 ≤ 1 - v := by linarith
    have hB : 0 < v * w ^ 2 - 1 := by linarith
    have hcomb : t * ((1 - v) + (v * w ^ 2 - 1)) ≤ (v * w ^ 2 - 1) * (1 - v) := by
      have e1 : t * (1 - v) ≤ (v * w ^ 2 - 1) * x * (1 - v) :=
        mul_le_mul_of_nonneg_right h1 hA
      have e2 : t * (v * w ^ 2 - 1) ≤ (1 - v) * (1 - x) * (v * w ^ 2 - 1) :=
        mul_le_mul_of_nonneg_right h2 hB.le
      nlinarith [e1, e2]
    -- the key square
    have hsq : (v * w - 1) ^ 2 ≥ 0 := sq_nonneg _
    have hkey : (v * w ^ 2 - 1) * (1 - v) ≤ v * (w - 1) ^ 2 := by nlinarith [hsq]
    have hden : 0 < v * (w ^ 2 - 1) ∨ w = 1 := by
      rcases eq_or_lt_of_le hw with h | h
      · exact Or.inr h.symm
      · exact Or.inl (by nlinarith)
    rcases hden with hden | hden
    · have hsum : (1 - v) + (v * w ^ 2 - 1) = v * (w ^ 2 - 1) := by ring
      rw [hsum] at hcomb
      have hle : t * (v * (w ^ 2 - 1)) ≤ v * (w - 1) ^ 2 := le_trans hcomb hkey
      have hfact : v * (w ^ 2 - 1) = v * (w - 1) * (w + 1) := by ring
      have hw1 : 0 < w - 1 := by nlinarith
      rw [le_div_iff₀ hwpos]
      nlinarith [hle]
    · -- `w = 1` forces `v w² ≤ 1`, contradicting the current case
      subst hden
      nlinarith
/-- **Sharp Hilbert → total variation comparison.**  For positive probability
vectors, `‖p - q‖_TV ≤ (e^{d/2} - 1)/(e^{d/2} + 1) = tanh (d/4)`, where
`d = d_H(p, q)`.  Unlike `tvDist_le_expm1_hilbertDist`, this bound is always
smaller than `1`. -/
theorem tvDist_le_tanh_hilbertDist {p q : ι → ℝ} (hp : IsPosProb p) (hq : IsPosProb q) :
    tvDist p q
      ≤ (Real.exp (hilbertDist p q / 2) - 1) / (Real.exp (hilbertDist p q / 2) + 1) := by
  classical
  set L : ι → ℝ := fun i => Real.log (p i / q i) with hL
  set S := univ.sup' univ_nonempty L with hS
  set I := univ.inf' univ_nonempty L with hI
  have hdist : hilbertDist p q = S - I := rfl
  set u := Real.exp S with hu
  set v := Real.exp I with hv
  set w := Real.exp (hilbertDist p q / 2) with hw
  have hwpos : 0 < w := Real.exp_pos _
  have hw1 : 1 ≤ w := Real.one_le_exp (by
    have := hilbertDist_nonneg p q
    linarith)
  have hvpos : 0 < v := Real.exp_pos _
  -- `sup ≥ 0` and `inf ≤ 0` for a pair of probability vectors
  obtain ⟨j, -, hj⟩ : ∃ j ∈ univ, p j ≤ q j := by
    by_contra hcon
    push_neg at hcon
    have : ∑ i, q i < ∑ i, p i :=
      Finset.sum_lt_sum_of_nonempty univ_nonempty fun i _ => hcon i (mem_univ i)
    rw [hp.sum_one, hq.sum_one] at this
    exact lt_irrefl _ this
  have hI0 : I ≤ 0 := by
    refine le_trans (inf'_univ_le L j) ?_
    have : p j / q j ≤ 1 := (div_le_one (hq.pos j)).mpr hj
    exact Real.log_nonpos (div_pos (hp.pos j) (hq.pos j)).le this
  have hv1 : v ≤ 1 := by
    rw [hv, ← Real.exp_zero]
    exact Real.exp_le_exp.mpr hI0
  -- `u = v * w²`
  have hw2 : w ^ 2 = Real.exp (S - I) := by
    rw [hw, sq, ← Real.exp_add, hdist]
    congr 1
    ring
  have huvw : u = v * w ^ 2 := by
    rw [hw2, hv, hu, ← Real.exp_add]
    congr 1
    ring
  -- pointwise ratio bounds
  have hup : ∀ i, p i ≤ u * q i := by
    intro i
    have hLi : L i ≤ S := le_sup'_univ L i
    have : p i / q i ≤ u := by
      have := Real.exp_le_exp.mpr hLi
      rwa [Real.exp_log (div_pos (hp.pos i) (hq.pos i))] at this
    calc p i = (p i / q i) * q i := by rw [div_mul_cancel₀ _ (hq.pos i).ne']
      _ ≤ u * q i := mul_le_mul_of_nonneg_right this (hq.pos i).le
  have hlow : ∀ i, v * q i ≤ p i := by
    intro i
    have hLi : I ≤ L i := inf'_univ_le L i
    have : v ≤ p i / q i := by
      have := Real.exp_le_exp.mpr hLi
      rwa [Real.exp_log (div_pos (hp.pos i) (hq.pos i))] at this
    calc v * q i ≤ (p i / q i) * q i := mul_le_mul_of_nonneg_right this (hq.pos i).le
      _ = p i := by rw [div_mul_cancel₀ _ (hq.pos i).ne']
  -- split at the set where `p` dominates
  set A := univ.filter (fun i => q i ≤ p i) with hA
  set a := ∑ i ∈ A, p i with ha
  set x := ∑ i ∈ A, q i with hx
  have hsumsplitp : ∑ i ∈ A, p i + ∑ i ∈ univ.filter (fun i => ¬ q i ≤ p i), p i = 1 := by
    rw [Finset.sum_filter_add_sum_filter_not, hp.sum_one]
  have hsumsplitq : ∑ i ∈ A, q i + ∑ i ∈ univ.filter (fun i => ¬ q i ≤ p i), q i = 1 := by
    rw [Finset.sum_filter_add_sum_filter_not, hq.sum_one]
  have htv : tvDist p q = a - x := by
    have hzero : ∑ i, (p i - q i) = 0 := by
      rw [Finset.sum_sub_distrib, hp.sum_one, hq.sum_one, sub_self]
    have hsplit : ∑ i ∈ A, (p i - q i) + ∑ i ∈ univ.filter (fun i => ¬ q i ≤ p i), (p i - q i)
        = 0 := by
      rw [Finset.sum_filter_add_sum_filter_not]
      exact hzero
    have habs : ∑ i, |p i - q i| = 2 * ∑ i ∈ A, (p i - q i) := by
      have h1 : ∑ i ∈ A, |p i - q i| = ∑ i ∈ A, (p i - q i) := by
        refine Finset.sum_congr rfl fun i hi => ?_
        rw [hA, Finset.mem_filter] at hi
        exact abs_of_nonneg (by linarith [hi.2])
      have h2 : ∑ i ∈ univ.filter (fun i => ¬ q i ≤ p i), |p i - q i|
          = -∑ i ∈ univ.filter (fun i => ¬ q i ≤ p i), (p i - q i) := by
        rw [← Finset.sum_neg_distrib]
        refine Finset.sum_congr rfl fun i hi => ?_
        rw [Finset.mem_filter] at hi
        push_neg at hi
        rw [abs_of_nonpos (by linarith [hi.2])]
      calc ∑ i, |p i - q i|
          = ∑ i ∈ A, |p i - q i| + ∑ i ∈ univ.filter (fun i => ¬ q i ≤ p i), |p i - q i| := by
            rw [hA, Finset.sum_filter_add_sum_filter_not]
        _ = ∑ i ∈ A, (p i - q i) - ∑ i ∈ univ.filter (fun i => ¬ q i ≤ p i), (p i - q i) := by
            rw [h1, h2]; ring
        _ = 2 * ∑ i ∈ A, (p i - q i) := by linarith [hsplit]
    simp only [tvDist, habs]
    rw [Finset.sum_sub_distrib]
    ring
  -- the two linear constraints
  have hc1 : a ≤ u * x := by
    calc a ≤ ∑ i ∈ A, u * q i := Finset.sum_le_sum fun i _ => hup i
      _ = u * x := by rw [hx, Finset.mul_sum]
  have hc2 : 1 - a ≥ v * (1 - x) := by
    have hrest : v * (∑ i ∈ univ.filter (fun i => ¬ q i ≤ p i), q i)
        ≤ ∑ i ∈ univ.filter (fun i => ¬ q i ≤ p i), p i := by
      rw [Finset.mul_sum]
      exact Finset.sum_le_sum fun i _ => hlow i
    have h1a : ∑ i ∈ univ.filter (fun i => ¬ q i ≤ p i), p i = 1 - a := by linarith [hsumsplitp]
    have h1x : ∑ i ∈ univ.filter (fun i => ¬ q i ≤ p i), q i = 1 - x := by linarith [hsumsplitq]
    rw [h1a, h1x] at hrest
    linarith
  have hx0 : 0 ≤ x := Finset.sum_nonneg fun i _ => (hq.pos i).le
  have hrestq : 0 ≤ ∑ i ∈ univ.filter (fun i => ¬ q i ≤ p i), q i :=
    Finset.sum_nonneg fun i _ => (hq.pos i).le
  have hx1 : x ≤ 1 := by linarith [hsumsplitq]
  -- apply the elementary optimisation
  have hfin := birkhoff_two_constraint_bound (t := a - x) (x := x) (v := v) (w := w)
    hv1 hw1 hx0 (by nlinarith [hc1, huvw]) (by nlinarith [hc2])
  rw [htv]
  exact hfin

/-- **Sharp reward-model-misspecification bound.**  Two reward models whose
difference has oscillation `ε` produce aligned policies within total variation
`tanh (ε / (4β))`; in particular the aligned policies never separate
completely, however large the reward discrepancy. -/
theorem tvDist_gibbs_le_tanh {β : ℝ} (hβ : 0 < β) {ref r₁ r₂ : ι → ℝ} (href : IsPosProb ref) :
    tvDist (gibbs β ref r₁) (gibbs β ref r₂)
      ≤ (Real.exp (oscil (fun i => r₁ i - r₂ i) / (2 * β)) - 1)
        / (Real.exp (oscil (fun i => r₁ i - r₂ i) / (2 * β)) + 1) := by
  have h := tvDist_le_tanh_hilbertDist (gibbs_isPosProb (β := β) (r := r₁) href)
    (gibbs_isPosProb (β := β) (r := r₂) href)
  rw [hilbertDist_gibbs hβ href] at h
  have hrw : oscil (fun i => r₁ i - r₂ i) / β / 2
      = oscil (fun i => r₁ i - r₂ i) / (2 * β) := by
    field_simp
  rwa [hrw] at h

/-- The sharp bound is always below `1`: aligned policies stay at total
variation distance strictly less than `1` no matter how far the reward models
disagree. -/
theorem tvDist_gibbs_lt_one {β : ℝ} (hβ : 0 < β) {ref r₁ r₂ : ι → ℝ} (href : IsPosProb ref) :
    tvDist (gibbs β ref r₁) (gibbs β ref r₂) < 1 := by
  set E := Real.exp (oscil (fun i => r₁ i - r₂ i) / (2 * β)) with hE
  have hEpos : 0 < E := Real.exp_pos _
  have h := tvDist_gibbs_le_tanh (r₁ := r₁) (r₂ := r₂) hβ href
  have hlt : (E - 1) / (E + 1) < 1 := by
    rw [div_lt_one (by linarith)]
    linarith
  linarith [h, hlt]

end NeuroSymbolicRLHF