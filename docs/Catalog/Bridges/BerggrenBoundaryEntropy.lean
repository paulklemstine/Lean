import Bridges.BerggrenHarmonicMeasure

/-!
# Entropy and dimension of the harmonic measure on the Berggren boundary

Building on `Catalog.Bridges.BerggrenHarmonicMeasure`, where the harmonic measure of the
Berggren random walk was identified with the Bernoulli product measure `bernoulli P` on the
3-adic boundary `Bdry = ℕ → Fin 3`, this file computes its **entropy** and its **pointwise
(Billingsley) dimension**.

## Main results

* `shannon` : the Shannon entropy `H(p₁,p₂,p₃) = -∑ pₐ log pₐ` of the step distribution.
* `expected_surprisal` : the *exact* level-`n` identity
  `∑_{w ∈ {1,2,3}ⁿ} μ[w] · (-log μ[w]) = n · H(p)`.  The mean surprisal of a depth-`n`
  cylinder is exactly `n H(p)` — no error term.
* `shannon_le_log_three`, `shannon_eq_log_three_iff` : `H(p) ≤ log 3` with equality exactly
  for the fair walk, so the harmonic measure has full dimension iff the three Berggren moves
  are equally likely.
* `strongLaw_surprisal`, `smb_ae` : the Shannon–McMillan–Breiman theorem for the Berggren
  boundary: `μ`-almost every boundary point `x` satisfies `-(1/n) log μ(cyl n x) → H(p)`.
* `pointwise_dimension_ae` : consequently the pointwise dimension of the harmonic measure
  with respect to the natural 3-adic metric (`diam (cyl n x) = 3⁻ⁿ`) is almost surely the
  constant `dimH P = H(p)/log 3 ∈ (0, 1]`.
* `dim_le_one`, `dim_uniform_eq_one`, `dim_eq_one_iff` : the dimension is at most `1`, the
  dimension of the whole 3-adic Cantor boundary, with equality iff the walk is fair.
-/

namespace BerggrenHarmonic

open MeasureTheory ProbabilityTheory Filter Finset
open scoped Topology ENNReal

/-! ## Surprisal and Shannon entropy -/

/-- The surprisal (information content) of a Berggren move. -/
noncomputable def surp (P : ProbVec) (a : Letter) : ℝ := -Real.log (P.p a)

/-- The Shannon entropy of the step distribution of the Berggren walk. -/
noncomputable def shannon (P : ProbVec) : ℝ := -∑ a, P.p a * Real.log (P.p a)

lemma shannon_eq_sum_surp (P : ProbVec) : shannon P = ∑ a, P.p a * surp P a := by
  unfold shannon surp
  rw [← Finset.sum_neg_distrib]
  exact Finset.sum_congr rfl fun a _ => by ring

lemma surp_nonneg (P : ProbVec) (a : Letter) : 0 ≤ surp P a := by
  have h1 : Real.log (P.p a) ≤ 0 := Real.log_nonpos (P.pos a).le (P.le_one a)
  simpa [surp] using h1

theorem shannon_nonneg (P : ProbVec) : 0 ≤ shannon P := by
  rw [shannon_eq_sum_surp]
  exact Finset.sum_nonneg fun a _ => mul_nonneg (P.pos a).le (surp_nonneg P a)

/-- One term of Gibbs' inequality, via `log t ≤ t - 1`. -/
lemma gibbs_term_le (P : ProbVec) (a : Letter) :
    P.p a * Real.log (1 / (3 * P.p a)) ≤ 1 / 3 - P.p a := by
  have hpa := P.pos a
  have hx : (0:ℝ) < 1 / (3 * P.p a) := by positivity
  have h := Real.log_le_sub_one_of_pos hx
  have hid : P.p a * (1 / (3 * P.p a) - 1) = 1 / 3 - P.p a := by field_simp
  nlinarith [hpa]

/-- The strict form of the previous inequality away from the uniform weight. -/
lemma gibbs_term_lt (P : ProbVec) (a : Letter) (h : P.p a ≠ 1 / 3) :
    P.p a * Real.log (1 / (3 * P.p a)) < 1 / 3 - P.p a := by
  have hpa := P.pos a
  have hx : (0:ℝ) < 1 / (3 * P.p a) := by positivity
  have hxne : 1 / (3 * P.p a) ≠ 1 := by
    intro hcon
    apply h
    field_simp at hcon
    linarith
  have hlt := Real.log_lt_sub_one_of_pos hx hxne
  have hid : P.p a * (1 / (3 * P.p a) - 1) = 1 / 3 - P.p a := by field_simp
  nlinarith [hpa]

lemma sum_gibbs_lhs (P : ProbVec) :
    ∑ a, P.p a * Real.log (1 / (3 * P.p a)) = -Real.log 3 + shannon P := by
  have hL : ∀ a : Letter, P.p a * Real.log (1 / (3 * P.p a))
      = P.p a * (-Real.log 3) - P.p a * Real.log (P.p a) := by
    intro a
    have hpa := P.pos a
    rw [one_div, Real.log_inv, Real.log_mul (by norm_num) (ne_of_gt hpa)]
    ring
  rw [Finset.sum_congr rfl (fun a _ => hL a), Finset.sum_sub_distrib, ← Finset.sum_mul,
    P.sum_eq, shannon]
  ring

lemma sum_gibbs_rhs (P : ProbVec) : ∑ a : Letter, (1 / 3 - P.p a) = 0 := by
  rw [Finset.sum_sub_distrib, P.sum_eq]
  norm_num

/-- **Gibbs' inequality on the three Berggren moves.**  The entropy of the walk never exceeds
the entropy `log 3` of the fair walk. -/
theorem shannon_le_log_three (P : ProbVec) : shannon P ≤ Real.log 3 := by
  have h := Finset.sum_le_sum (fun a (_ : a ∈ Finset.univ) => gibbs_term_le P a)
  rw [sum_gibbs_lhs, sum_gibbs_rhs] at h
  linarith

/-- **Rigidity in Gibbs' inequality.**  The Berggren walk has maximal entropy `log 3` exactly
when the three moves are equally likely. -/
theorem shannon_eq_log_three_iff (P : ProbVec) :
    shannon P = Real.log 3 ↔ ∀ a, P.p a = 1 / 3 := by
  constructor
  · intro heq
    by_contra hne
    push_neg at hne
    obtain ⟨b, hb⟩ := hne
    have h := Finset.sum_lt_sum (fun a (_ : a ∈ Finset.univ) => gibbs_term_le P a)
      ⟨b, Finset.mem_univ b, gibbs_term_lt P b hb⟩
    rw [sum_gibbs_lhs, sum_gibbs_rhs] at h
    linarith
  · intro h
    unfold shannon
    have hval : ∀ a : Letter, P.p a * Real.log (P.p a) = (1 / 3) * Real.log (1 / 3) := by
      intro a; rw [h a]
    rw [Finset.sum_congr rfl (fun a _ => hval a)]
    simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    rw [one_div, Real.log_inv]
    ring

@[simp] lemma shannon_uniform : shannon uniformVec = Real.log 3 :=
  (shannon_eq_log_three_iff uniformVec).2 (fun _ => rfl)

/-! ## Cylinder masses in the reals -/

/-- The real-valued mass of the depth-`n` cylinder through `v`. -/
noncomputable def massR (P : ProbVec) (n : ℕ) (v : Bdry) : ℝ :=
  ∏ i ∈ Finset.range n, P.p (v i)

lemma massR_pos (P : ProbVec) (n : ℕ) (v : Bdry) : 0 < massR P n v :=
  Finset.prod_pos fun i _ => P.pos (v i)

/-- The harmonic measure of a cylinder, as a real number. -/
lemma bernoulli_cyl_toReal (P : ProbVec) (n : ℕ) (v : Bdry) :
    (bernoulli P (cyl n v)).toReal = massR P n v := by
  rw [bernoulli_cyl, wmass, ENNReal.toReal_prod, massR]
  exact Finset.prod_congr rfl fun i _ => ENNReal.toReal_ofReal (P.pos (v i)).le

/-- The surprisal of a cylinder is the sum of the surprisals of its letters. -/
lemma neg_log_massR (P : ProbVec) (n : ℕ) (v : Bdry) :
    -Real.log (massR P n v) = ∑ i ∈ Finset.range n, surp P (v i) := by
  rw [massR, Real.log_prod (fun i _ => (P.pos (v i)).ne'), ← Finset.sum_neg_distrib]
  rfl

/-! ## The exact level-`n` entropy identity -/

/-- An auxiliary product identity: singling out one factor. -/
lemma prod_ite_mul_single {n : ℕ} (i : Fin n) (f g : Fin n → ℝ) :
    ∏ j, (if j = i then f j * g j else f j) = (∏ j, f j) * g i := by
  classical
  rw [← Finset.mul_prod_erase Finset.univ _ (Finset.mem_univ i),
    ← Finset.mul_prod_erase Finset.univ f (Finset.mem_univ i), if_pos rfl,
    Finset.prod_congr rfl (fun j hj => if_neg (Finset.ne_of_mem_erase hj))]
  ring

/-- **The mean surprisal of a depth-`n` cylinder is exactly `n · H(p)`.**  Summing over all
`3ⁿ` words of length `n`, weighted by their harmonic measure, the information content of a
depth-`n` node of the Berggren tree is exactly `n` times the Shannon entropy of the step
distribution.  This is an identity, not an asymptotic. -/
theorem expected_surprisal (P : ProbVec) (n : ℕ) :
    ∑ w : Fin n → Letter, (∏ i, P.p (w i)) * (-Real.log (∏ i, P.p (w i)))
      = n * shannon P := by
  classical
  have hlog : ∀ w : Fin n → Letter,
      -Real.log (∏ i, P.p (w i)) = ∑ i, surp P (w i) := by
    intro w
    rw [Real.log_prod (fun i _ => (P.pos (w i)).ne'), ← Finset.sum_neg_distrib]
    rfl
  have hexp : ∀ w : Fin n → Letter,
      (∏ i, P.p (w i)) * (-Real.log (∏ i, P.p (w i)))
        = ∑ i, (∏ j, P.p (w j)) * surp P (w i) := by
    intro w
    rw [hlog w, Finset.mul_sum]
  rw [Finset.sum_congr rfl (fun w _ => hexp w), Finset.sum_comm]
  have hone : ∀ i : Fin n,
      ∑ w : Fin n → Letter, (∏ j, P.p (w j)) * surp P (w i) = shannon P := by
    intro i
    have hfac : ∀ w : Fin n → Letter,
        (∏ j, P.p (w j)) * surp P (w i)
          = ∏ j, (if j = i then P.p (w j) * surp P (w j) else P.p (w j)) := by
      intro w
      exact (prod_ite_mul_single i (fun j => P.p (w j)) (fun j => surp P (w j))).symm
    rw [Finset.sum_congr rfl (fun w _ => hfac w)]
    have := Finset.prod_univ_sum (fun _ : Fin n => (Finset.univ : Finset Letter))
      (fun (j : Fin n) (a : Letter) => if j = i then P.p a * surp P a else P.p a)
    rw [Fintype.piFinset_univ] at this
    rw [← this]
    have hprod : ∀ j : Fin n,
        (∑ a : Letter, if j = i then P.p a * surp P a else P.p a)
          = if j = i then shannon P else 1 := by
      intro j
      by_cases hj : j = i
      · subst hj
        have hall : ∀ a : Letter,
            (if j = j then P.p a * surp P a else P.p a) = P.p a * surp P a :=
          fun a => if_pos rfl
        rw [Finset.sum_congr rfl (fun a _ => hall a), if_pos rfl, shannon_eq_sum_surp]
      · have hall : ∀ a : Letter, (if j = i then P.p a * surp P a else P.p a) = P.p a :=
          fun a => if_neg hj
        rw [Finset.sum_congr rfl (fun a _ => hall a), if_neg hj]
        exact P.sum_eq
    rw [Finset.prod_congr rfl (fun j _ => hprod j)]
    simp
  rw [Finset.sum_congr rfl (fun i _ => hone i)]
  simp [mul_comm]

/-! ## Shannon–McMillan–Breiman on the Berggren boundary -/

lemma measurable_letter_coord (g : Letter → ℝ) (i : ℕ) :
    Measurable (fun x : Bdry => g (x i)) :=
  (Measurable.of_discrete (f := g)).comp (measurable_pi_apply i)

lemma integrable_letter_coord (P : ProbVec) (g : Letter → ℝ) (i : ℕ) :
    Integrable (fun x : Bdry => g (x i)) (bernoulli P) := by
  refine Integrable.mono' (integrable_const (∑ a, |g a|))
    (measurable_letter_coord g i).aestronglyMeasurable (Filter.Eventually.of_forall fun x => ?_)
  rw [Real.norm_eq_abs]
  exact Finset.single_le_sum (fun a _ => abs_nonneg (g a)) (Finset.mem_univ (x i))

lemma integral_letter_coord (P : ProbVec) (g : Letter → ℝ) (i : ℕ) :
    ∫ x, g (x i) ∂(bernoulli P) = ∑ a, P.p a * g a := by
  have hmap : (bernoulli P).map (Function.eval i) = P.stepMeasure :=
    (measurePreserving_eval_infinitePi (fun _ : ℕ => P.stepMeasure) i).map_eq
  have h1 : ∫ a, g a ∂(P.stepMeasure) = ∫ x, g (x i) ∂(bernoulli P) := by
    rw [← hmap, integral_map (measurable_pi_apply i).aemeasurable
      (Measurable.of_discrete (f := g)).aestronglyMeasurable]
  rw [← h1, ProbVec.stepMeasure, PMF.integral_eq_sum]
  refine Finset.sum_congr rfl fun a _ => ?_
  rw [ProbVec.pmf_apply, ENNReal.toReal_ofReal (P.pos a).le, smul_eq_mul]

lemma iIndepFun_letters (P : ProbVec) (g : Letter → ℝ) :
    iIndepFun (fun (i : ℕ) (x : Bdry) => g (x i)) (bernoulli P) :=
  iIndepFun_infinitePi (X := fun _ : ℕ => g) (fun _ => Measurable.of_discrete)

lemma map_letter_coord (P : ProbVec) (g : Letter → ℝ) (i : ℕ) :
    (bernoulli P).map (fun x : Bdry => g (x i)) = P.stepMeasure.map g := by
  have hi : (bernoulli P).map (fun x : Bdry => x i) = P.stepMeasure :=
    (measurePreserving_eval_infinitePi (fun _ : ℕ => P.stepMeasure) i).map_eq
  have hcomp : (fun x : Bdry => g (x i)) = g ∘ (fun x : Bdry => x i) := rfl
  rw [hcomp, ← Measure.map_map (Measurable.of_discrete (f := g)) (measurable_pi_apply i), hi]

lemma identDistrib_letters (P : ProbVec) (g : Letter → ℝ) (i : ℕ) :
    IdentDistrib (fun x : Bdry => g (x i)) (fun x : Bdry => g (x 0))
      (bernoulli P) (bernoulli P) where
  aemeasurable_fst := (measurable_letter_coord g i).aemeasurable
  aemeasurable_snd := (measurable_letter_coord g 0).aemeasurable
  map_eq := by rw [map_letter_coord, map_letter_coord]

/-- **The strong law of large numbers for the letters of a random Berggren word.**  For every
observable `g` of a single Berggren move, the empirical average of `g` along almost every
infinite word converges to its mean `∑ₐ pₐ g(a)`. -/
theorem strongLaw_letters (P : ProbVec) (g : Letter → ℝ) :
    ∀ᵐ x ∂(bernoulli P),
      Tendsto (fun n : ℕ => (∑ i ∈ Finset.range n, g (x i)) / n) atTop
        (𝓝 (∑ a, P.p a * g a)) := by
  have h := ProbabilityTheory.strong_law_ae_real
    (fun (i : ℕ) (x : Bdry) => g (x i)) (integrable_letter_coord P g 0)
    (fun i j hij => (iIndepFun_letters P g).indepFun hij) (identDistrib_letters P g)
  rw [integral_letter_coord P g 0] at h
  exact h

/-- **The strong law for the surprisal.**  Almost every infinite Berggren word has average
surprisal converging to the Shannon entropy of the step distribution. -/
theorem strongLaw_surprisal (P : ProbVec) :
    ∀ᵐ x ∂(bernoulli P),
      Tendsto (fun n : ℕ => (∑ i ∈ Finset.range n, surp P (x i)) / n) atTop
        (𝓝 (shannon P)) := by
  have h := strongLaw_letters P (surp P)
  rwa [← shannon_eq_sum_surp] at h

/-- **Shannon–McMillan–Breiman for the harmonic measure of the Berggren walk.**  For almost
every boundary point, the harmonic measure of the depth-`n` cylinder through it decays like
`e^{-n H(p)}`. -/
theorem smb_ae (P : ProbVec) :
    ∀ᵐ x ∂(bernoulli P),
      Tendsto (fun n : ℕ => -Real.log ((bernoulli P (cyl n x)).toReal) / n) atTop
        (𝓝 (shannon P)) := by
  filter_upwards [strongLaw_surprisal P] with x hx
  have hfun : ∀ n : ℕ, -Real.log ((bernoulli P (cyl n x)).toReal) / n
      = (∑ i ∈ Finset.range n, surp P (x i)) / n := by
    intro n
    rw [bernoulli_cyl_toReal, neg_log_massR]
  simpa only [hfun] using hx

/-! ## Dimension -/

/-- The dimension of the harmonic measure: entropy divided by the logarithm of the branching
number.  With the natural 3-adic metric on the boundary (`diam (cyl n x) = 3⁻ⁿ`) this is the
pointwise dimension of the measure. -/
noncomputable def dimH (P : ProbVec) : ℝ := shannon P / Real.log 3

theorem dim_nonneg (P : ProbVec) : 0 ≤ dimH P :=
  div_nonneg (shannon_nonneg P) (Real.log_nonneg (by norm_num))

theorem dim_le_one (P : ProbVec) : dimH P ≤ 1 := by
  rw [dimH, div_le_one (Real.log_pos (by norm_num))]
  exact shannon_le_log_three P

@[simp] theorem dim_uniform_eq_one : dimH uniformVec = 1 := by
  rw [dimH, shannon_uniform, div_self (ne_of_gt (Real.log_pos (by norm_num)))]

theorem dim_eq_one_iff (P : ProbVec) : dimH P = 1 ↔ ∀ a, P.p a = 1 / 3 := by
  rw [dimH, div_eq_one_iff_eq (ne_of_gt (Real.log_pos (by norm_num)))]
  exact shannon_eq_log_three_iff P

/-- **Dimension drop for unfair walks.**  As soon as the three Berggren moves are not equally
likely, the harmonic measure has dimension strictly smaller than the dimension `1` of the
whole 3-adic boundary: it concentrates on a fractal subset of the Cantor set. -/
theorem dim_lt_one_of_ne_uniform (P : ProbVec) (h : ∃ a, P.p a ≠ 1 / 3) : dimH P < 1 := by
  rcases lt_or_eq_of_le (dim_le_one P) with hlt | heq
  · exact hlt
  · obtain ⟨a, ha⟩ := h
    exact absurd ((dim_eq_one_iff P).1 heq a) ha

/-- **The pointwise dimension of the harmonic measure.**  Measuring cylinders by their 3-adic
diameter `3⁻ⁿ`, almost every boundary point has local dimension exactly `H(p)/log 3`. -/
theorem pointwise_dimension_ae (P : ProbVec) :
    ∀ᵐ x ∂(bernoulli P),
      Tendsto (fun n : ℕ =>
          Real.log ((bernoulli P (cyl n x)).toReal) / Real.log ((3 : ℝ) ^ (-(n : ℝ)))) atTop
        (𝓝 (dimH P)) := by
  filter_upwards [smb_ae P] with x hx
  have hlog3 : Real.log 3 ≠ 0 := ne_of_gt (Real.log_pos (by norm_num))
  have hfun : ∀ n : ℕ, n ≠ 0 →
      Real.log ((bernoulli P (cyl n x)).toReal) / Real.log ((3 : ℝ) ^ (-(n : ℝ)))
        = (-Real.log ((bernoulli P (cyl n x)).toReal) / n) / Real.log 3 := by
    intro n hn
    have hn' : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.2 hn
    rw [Real.log_rpow (by norm_num)]
    field_simp
  have := hx.div_const (Real.log 3)
  rw [dimH]
  refine Tendsto.congr' ?_ this
  filter_upwards [eventually_gt_atTop 0] with n hn
  exact (hfun n hn.ne').symm

end BerggrenHarmonic