import Catalog.Bridges.BerggrenHarmonicSingularity

/-!
# Chernoff separation of Berggren harmonic measures

`Catalog.Bridges.BerggrenHarmonicSingularity` proved the *qualitative* dichotomy: two Berggren
walks with different weight vectors have mutually singular harmonic measures, the separating
statistic being the asymptotic frequency of a move.  This file makes the separation
*quantitative*, closing the first half of Conjecture 4 of the previous cycle: the two measures
are already exponentially separated at depth `n`, by an explicit large deviation rate.

The technical core is a Chernoff bound for the letter counts of the Bernoulli boundary measure.
Because the coordinates are independent (`iIndepFun_letters`) and each coordinate has the same
law, the moment generating function of a letter statistic factorises exactly
(`mgf_sumLetters`), and optimising the exponential Markov inequality at the classical tilt
`t = log (u(1-s)/(s(1-u)))` produces the binary Kullback–Leibler rate `klBer u s`.

## Main results

* `mgf_sumLetters` : `𝔼[exp (t ∑_{i<n} g(xᵢ))] = (∑ₐ pₐ exp (t g a))ⁿ` — exact factorisation.
* `klBer_pos` : strict positivity of the binary relative entropy off the diagonal (Gibbs).
* `chernoff_count_ge` : `ℙ[ #{i < n : xᵢ = a} ≥ n u ] ≤ exp (-n · klBer u pₐ)` for `pₐ < u < 1`.
* `chernoff_count_le` : the matching lower tail `ℙ[ #{i < n : xᵢ = a} ≤ n u ] ≤ exp (-n · klBer u pₐ)`
  for `0 < u < pₐ`.
* `chernoff_separation` : if `P` and `Q` differ at some move then there is `c > 0` and, for each
  `n`, a set `A n` measurable with respect to the first `n` letters with
  `bernoulli P (A n) ≥ 1 - exp (-c n)` and `bernoulli Q (A n) ≤ exp (-c n)`.
* `tv_separation_tendsto` : consequently the total variation separation of the depth-`n`
  statistics tends to `1`; mutual singularity is the `n → ∞` shadow of an exponential cutoff.
-/

namespace BerggrenHarmonic

open MeasureTheory ProbabilityTheory Filter Finset Real
open scoped Topology

/-! ## Letter statistics and their moment generating function -/

/-- The empirical sum of a letter observable over the first `n` letters of a ray. -/
noncomputable def sumLetters (g : Letter → ℝ) (n : ℕ) (x : Bdry) : ℝ :=
  ∑ i ∈ Finset.range n, g (x i)

lemma measurable_sumLetters (g : Letter → ℝ) (n : ℕ) : Measurable (sumLetters g n) :=
  Finset.measurable_sum _ fun i _ => measurable_letter_coord g i

lemma sumLetters_eq_sum (g : Letter → ℝ) (n : ℕ) :
    sumLetters g n = ∑ i ∈ Finset.range n, (fun x : Bdry => g (x i)) := by
  funext x
  simp [sumLetters]

lemma integrable_exp_letter (P : ProbVec) (g : Letter → ℝ) (i : ℕ) (t : ℝ) :
    Integrable (fun x : Bdry => Real.exp (t * g (x i))) (bernoulli P) :=
  integrable_letter_coord P (fun a => Real.exp (t * g a)) i

lemma mgf_letter (P : ProbVec) (g : Letter → ℝ) (i : ℕ) (t : ℝ) :
    mgf (fun x : Bdry => g (x i)) (bernoulli P) t = ∑ a, P.p a * Real.exp (t * g a) := by
  rw [mgf]
  exact integral_letter_coord P (fun a => Real.exp (t * g a)) i

/-- **Exact factorisation of the moment generating function of a letter statistic.** -/
theorem mgf_sumLetters (P : ProbVec) (g : Letter → ℝ) (n : ℕ) (t : ℝ) :
    mgf (sumLetters g n) (bernoulli P) t = (∑ a, P.p a * Real.exp (t * g a)) ^ n := by
  rw [sumLetters_eq_sum,
    (iIndepFun_letters P g).mgf_sum (fun i => measurable_letter_coord g i) (Finset.range n)]
  rw [Finset.prod_congr rfl fun i _ => mgf_letter P g i t]
  simp

lemma integrable_exp_sumLetters (P : ProbVec) (g : Letter → ℝ) (n : ℕ) (t : ℝ) :
    Integrable (fun x : Bdry => Real.exp (t * sumLetters g n x)) (bernoulli P) := by
  classical
  set C : ℝ := ∑ a, |g a| with hC
  have hCnn : 0 ≤ C := Finset.sum_nonneg fun a _ => abs_nonneg _
  refine Integrable.mono' (integrable_const (Real.exp (|t| * (n * C))))
    ((measurable_exp.comp ((measurable_sumLetters g n).const_mul t)).aestronglyMeasurable)
    (Filter.Eventually.of_forall fun x => ?_)
  rw [Real.norm_eq_abs, abs_of_nonneg (Real.exp_nonneg _)]
  refine Real.exp_le_exp.2 ?_
  calc t * sumLetters g n x ≤ |t * sumLetters g n x| := le_abs_self _
    _ = |t| * |sumLetters g n x| := abs_mul _ _
    _ ≤ |t| * (n * C) := by
        refine mul_le_mul_of_nonneg_left ?_ (abs_nonneg t)
        calc |sumLetters g n x| ≤ ∑ i ∈ Finset.range n, |g (x i)| :=
              Finset.abs_sum_le_sum_abs _ _
          _ ≤ ∑ _i ∈ Finset.range n, C := by
              refine Finset.sum_le_sum fun i _ => ?_
              exact Finset.single_le_sum (fun a _ => abs_nonneg (g a)) (Finset.mem_univ (x i))
          _ = n * C := by simp

/-! ## Binary relative entropy -/

/-- The binary Kullback–Leibler divergence `KL(u ‖ s)`. -/
noncomputable def klBer (u s : ℝ) : ℝ :=
  u * Real.log (u / s) + (1 - u) * Real.log ((1 - u) / (1 - s))

/-- **Gibbs' inequality for two-point distributions**: the binary relative entropy is strictly
positive off the diagonal. -/
theorem klBer_pos {u s : ℝ} (hu0 : 0 < u) (hu1 : u < 1) (hs0 : 0 < s) (hs1 : s < 1)
    (hne : u ≠ s) : 0 < klBer u s := by
  have h1u : 0 < 1 - u := by linarith
  have h1s : 0 < 1 - s := by linarith
  have key : Real.log (s / u) < s / u - 1 :=
    Real.log_lt_sub_one_of_pos (div_pos hs0 hu0) (by
      intro h
      exact hne (by field_simp at h; linarith))
  have key2 : Real.log ((1 - s) / (1 - u)) ≤ (1 - s) / (1 - u) - 1 :=
    Real.log_le_sub_one_of_pos (div_pos h1s h1u)
  have e1 : Real.log (u / s) = -Real.log (s / u) := by
    rw [← Real.log_inv]; congr 1; field_simp
  have e2 : Real.log ((1 - u) / (1 - s)) = -Real.log ((1 - s) / (1 - u)) := by
    rw [← Real.log_inv]; congr 1; field_simp
  have hsum : u * (s / u - 1) + (1 - u) * ((1 - s) / (1 - u) - 1) = 0 := by
    field_simp
    ring
  rw [klBer, e1, e2]
  have hlt : u * Real.log (s / u) + (1 - u) * Real.log ((1 - s) / (1 - u)) < 0 := by
    have h1 : u * Real.log (s / u) < u * (s / u - 1) :=
      mul_lt_mul_of_pos_left key hu0
    have h2 : (1 - u) * Real.log ((1 - s) / (1 - u)) ≤ (1 - u) * ((1 - s) / (1 - u) - 1) :=
      mul_le_mul_of_nonneg_left key2 h1u.le
    linarith
  linarith

/-! ## The Chernoff bound for letter counts -/

/-- A `{0,1}`-valued observable of a letter, together with its success probability. -/
lemma sum_p_exp_of_boolean (P : ProbVec) (g : Letter → ℝ) (hg : ∀ a, g a = 0 ∨ g a = 1)
    (t : ℝ) :
    ∑ a, P.p a * Real.exp (t * g a) = 1 + (∑ a, P.p a * g a) * (Real.exp t - 1) := by
  have hterm : ∀ a : Letter,
      P.p a * Real.exp (t * g a) = P.p a + P.p a * g a * (Real.exp t - 1) := by
    intro a
    rcases hg a with h | h
    · rw [h]; simp
    · rw [h]; simp; ring
  rw [Finset.sum_congr rfl fun a _ => hterm a, Finset.sum_add_distrib, P.sum_eq,
    ← Finset.sum_mul]

/-- **Chernoff's bound for a boolean letter statistic.**  If the success probability is `s` and
`s < u < 1`, the probability that the empirical count exceeds `n u` decays at the exact binary
relative entropy rate. -/
theorem chernoff_boolean (P : ProbVec) (g : Letter → ℝ) (hg : ∀ a, g a = 0 ∨ g a = 1)
    (n : ℕ) {u : ℝ} (hu1 : u < 1) (hs0 : 0 < ∑ a, P.p a * g a)
    (hlt : (∑ a, P.p a * g a) < u) :
    (bernoulli P).real {x | (n : ℝ) * u ≤ sumLetters g n x}
      ≤ Real.exp (-((n : ℝ) * klBer u (∑ a, P.p a * g a))) := by
  set s : ℝ := ∑ a, P.p a * g a with hs
  have hu0 : 0 < u := lt_trans hs0 hlt
  have h1u : 0 < 1 - u := by linarith
  have h1s : 0 < 1 - s := by linarith
  -- the optimal exponential tilt
  set t : ℝ := Real.log (u * (1 - s) / (s * (1 - u))) with ht
  have hratio : 1 < u * (1 - s) / (s * (1 - u)) := by
    rw [lt_div_iff₀ (by positivity)]
    nlinarith
  have ht0 : 0 < t := Real.log_pos hratio
  have hexp_t : Real.exp t = u * (1 - s) / (s * (1 - u)) :=
    Real.exp_log (by positivity)
  -- Chernoff / exponential Markov inequality
  have hmarkov := measure_ge_le_exp_mul_mgf (μ := bernoulli P) (X := sumLetters g n)
    (t := t) ((n : ℝ) * u) ht0.le (integrable_exp_sumLetters P g n t)
  -- the moment generating function factorises
  have hmgf : mgf (sumLetters g n) (bernoulli P) t = ((1 - s) / (1 - u)) ^ n := by
    rw [mgf_sumLetters, sum_p_exp_of_boolean P g hg t, hexp_t, ← hs]
    congr 1
    field_simp
    ring
  rw [hmgf] at hmarkov
  refine hmarkov.trans (le_of_eq ?_)
  -- identify the resulting exponent with the binary relative entropy
  have hpow : ((1 - s) / (1 - u)) ^ n
      = Real.exp ((n : ℝ) * Real.log ((1 - s) / (1 - u))) := by
    rw [Real.exp_nat_mul, Real.exp_log (by positivity)]
  rw [hpow, ← Real.exp_add]
  congr 1
  have hL2 : Real.log ((1 - s) / (1 - u)) = Real.log (1 - s) - Real.log (1 - u) :=
    Real.log_div h1s.ne' h1u.ne'
  have hL2' : Real.log ((1 - u) / (1 - s)) = Real.log (1 - u) - Real.log (1 - s) :=
    Real.log_div h1u.ne' h1s.ne'
  have hL1 : Real.log (u / s) = Real.log u - Real.log s := Real.log_div hu0.ne' hs0.ne'
  have htlog : t = (Real.log u - Real.log s) + (Real.log (1 - s) - Real.log (1 - u)) := by
    rw [ht, Real.log_div (by positivity) (by positivity), Real.log_mul hu0.ne' h1s.ne',
      Real.log_mul hs0.ne' h1u.ne']
    ring
  rw [klBer, hL1, hL2', hL2, htlog]
  ring

/-- The count of occurrences of the move `a` among the first `n` letters of a ray. -/
noncomputable def countLetter (a : Letter) (n : ℕ) (x : Bdry) : ℝ := sumLetters (ind a) n x

lemma ind_boolean (a : Letter) : ∀ b : Letter, ind a b = 0 ∨ ind a b = 1 := by
  intro b; by_cases h : b = a <;> simp [ind, h]

lemma one_sub_ind_boolean (a : Letter) : ∀ b : Letter, (1 - ind a b) = 0 ∨ (1 - ind a b) = 1 := by
  intro b; by_cases h : b = a <;> simp [ind, h]

lemma measurableSet_countLetter_ge (a : Letter) (n : ℕ) (r : ℝ) :
    MeasurableSet {x : Bdry | r ≤ countLetter a n x} :=
  measurableSet_le measurable_const (measurable_sumLetters (ind a) n)

lemma measurableSet_countLetter_le (a : Letter) (n : ℕ) (r : ℝ) :
    MeasurableSet {x : Bdry | countLetter a n x ≤ r} :=
  measurableSet_le (measurable_sumLetters (ind a) n) measurable_const

/-- Every Berggren move has probability strictly less than one: the other two moves have
positive probability. -/
lemma ProbVec.lt_one (P : ProbVec) (a : Letter) : P.p a < 1 := by
  classical
  have hmem : a ∈ (Finset.univ : Finset Letter) := Finset.mem_univ a
  have hsplit : P.p a + ∑ b ∈ Finset.univ.erase a, P.p b = 1 := by
    rw [Finset.add_sum_erase _ _ hmem]; exact P.sum_eq
  have hcard : (Finset.univ.erase a).card = 2 := by
    rw [Finset.card_erase_of_mem hmem]; simp
  have hne : (Finset.univ.erase a).Nonempty := Finset.card_pos.1 (by rw [hcard]; norm_num)
  have hpos : 0 < ∑ b ∈ Finset.univ.erase a, P.p b :=
    Finset.sum_pos (fun b _ => P.pos b) hne
  linarith

/-- **Upper tail.** -/
theorem chernoff_count_ge (P : ProbVec) (a : Letter) (n : ℕ) {u : ℝ}
    (hu1 : u < 1) (hlt : P.p a < u) :
    (bernoulli P).real {x | (n : ℝ) * u ≤ countLetter a n x}
      ≤ Real.exp (-((n : ℝ) * klBer u (P.p a))) := by
  have hsum : (∑ b, P.p b * ind a b) = P.p a := sum_p_mul_ind P a
  have h := chernoff_boolean P (ind a) (ind_boolean a) n hu1 (by rw [hsum]; exact P.pos a)
    (by rw [hsum]; exact hlt)
  rw [hsum] at h
  exact h

lemma sumLetters_one_sub_ind (a : Letter) (n : ℕ) (x : Bdry) :
    sumLetters (fun b => 1 - ind a b) n x = (n : ℝ) - countLetter a n x := by
  simp [sumLetters, countLetter, Finset.sum_sub_distrib]

lemma klBer_one_sub (u s : ℝ) : klBer (1 - u) (1 - s) = klBer u s := by
  simp only [klBer, sub_sub_cancel]
  ring

/-- **Lower tail.** -/
theorem chernoff_count_le (P : ProbVec) (a : Letter) (n : ℕ) {u : ℝ}
    (hu0 : 0 < u) (hlt : u < P.p a) :
    (bernoulli P).real {x | countLetter a n x ≤ (n : ℝ) * u}
      ≤ Real.exp (-((n : ℝ) * klBer u (P.p a))) := by
  have hsum : (∑ b, P.p b * (1 - ind a b)) = 1 - P.p a := by
    have : ∀ b : Letter, P.p b * (1 - ind a b) = P.p b - P.p b * ind a b := fun b => by ring
    rw [Finset.sum_congr rfl fun b _ => this b, Finset.sum_sub_distrib, P.sum_eq,
      sum_p_mul_ind]
  have h := chernoff_boolean P (fun b => 1 - ind a b) (one_sub_ind_boolean a) n
    (u := 1 - u) (by linarith) (by rw [hsum]; linarith [P.lt_one a])
    (by rw [hsum]; linarith)
  rw [hsum, klBer_one_sub] at h
  refine le_trans (measureReal_mono (μ := bernoulli P) ?_ (measure_ne_top _ _)) h
  intro x hx
  simp only [Set.mem_setOf_eq] at hx ⊢
  rw [sumLetters_one_sub_ind]
  nlinarith [hx]

/-! ## Exponential separation of two Berggren walks -/

/-- The separation statement, in the case where the move `a` is more likely under `P`. -/
lemma chernoff_separation_of_lt (P Q : ProbVec) (a : Letter) (hqp : Q.p a < P.p a) :
    ∃ c > 0, ∃ A : ℕ → Set Bdry, (∀ n, MeasurableSet (A n)) ∧
      (∀ n : ℕ, (bernoulli Q).real (A n) ≤ Real.exp (-(c * (n : ℝ)))) ∧
      (∀ n : ℕ, 1 - Real.exp (-(c * (n : ℝ))) ≤ (bernoulli P).real (A n)) := by
  set u : ℝ := (Q.p a + P.p a) / 2 with hu
  have hqu : Q.p a < u := by rw [hu]; linarith
  have hup : u < P.p a := by rw [hu]; linarith
  have hu0 : 0 < u := lt_trans (Q.pos a) hqu
  have hu1 : u < 1 := lt_trans hup (P.lt_one a)
  set cQ : ℝ := klBer u (Q.p a) with hcQ
  set cP : ℝ := klBer u (P.p a) with hcP
  have hcQ0 : 0 < cQ :=
    klBer_pos hu0 hu1 (Q.pos a) (Q.lt_one a) (ne_of_gt hqu)
  have hcP0 : 0 < cP :=
    klBer_pos hu0 hu1 (P.pos a) (P.lt_one a) (ne_of_lt hup)
  refine ⟨min cQ cP, lt_min hcQ0 hcP0, fun n => {x | (n : ℝ) * u ≤ countLetter a n x},
    fun n => measurableSet_countLetter_ge a n _, fun n => ?_, fun n => ?_⟩
  · refine (chernoff_count_ge Q a n hu1 hqu).trans ?_
    refine Real.exp_le_exp.2 ?_
    have : min cQ cP * (n : ℝ) ≤ cQ * (n : ℝ) :=
      mul_le_mul_of_nonneg_right (min_le_left _ _) (Nat.cast_nonneg n)
    rw [← hcQ]
    linarith [this, (by ring : (n : ℝ) * cQ = cQ * (n : ℝ))]
  · have hcompl : {x : Bdry | (n : ℝ) * u ≤ countLetter a n x}ᶜ
        ⊆ {x : Bdry | countLetter a n x ≤ (n : ℝ) * u} := by
      intro x hx
      simp only [Set.mem_compl_iff, Set.mem_setOf_eq, not_le] at hx
      exact le_of_lt hx
    have hsmall : (bernoulli P).real {x : Bdry | (n : ℝ) * u ≤ countLetter a n x}ᶜ
        ≤ Real.exp (-(min cQ cP * (n : ℝ))) := by
      refine le_trans (measureReal_mono (μ := bernoulli P) hcompl (measure_ne_top _ _)) ?_
      refine (chernoff_count_le P a n hu0 hup).trans (Real.exp_le_exp.2 ?_)
      have : min cQ cP * (n : ℝ) ≤ cP * (n : ℝ) :=
        mul_le_mul_of_nonneg_right (min_le_right _ _) (Nat.cast_nonneg n)
      rw [← hcP]
      linarith [this, (by ring : (n : ℝ) * cP = cP * (n : ℝ))]
    have htot : (bernoulli P).real {x : Bdry | (n : ℝ) * u ≤ countLetter a n x}
        + (bernoulli P).real {x : Bdry | (n : ℝ) * u ≤ countLetter a n x}ᶜ = 1 := by
      rw [measureReal_add_measureReal_compl (measurableSet_countLetter_ge a n _)]
      simp [measureReal_def]
    linarith

/-- **Exponential separation.**  Two Berggren walks with different weight vectors are already
separated at depth `n` by an event of the first `n` letters, up to an error decaying
exponentially in `n`. -/
theorem chernoff_separation (P Q : ProbVec) (h : ∃ a, P.p a ≠ Q.p a) :
    ∃ c > 0, ∃ A : ℕ → Set Bdry, (∀ n, MeasurableSet (A n)) ∧
      (∀ n : ℕ, (bernoulli Q).real (A n) ≤ Real.exp (-(c * (n : ℝ)))) ∧
      (∀ n : ℕ, 1 - Real.exp (-(c * (n : ℝ))) ≤ (bernoulli P).real (A n)) := by
  obtain ⟨a, ha⟩ := h
  rcases lt_or_gt_of_ne ha with hlt | hgt
  · -- `a` is more likely under `Q`; complement the separating event
    obtain ⟨c, hc, A, hAmeas, hQ, hP⟩ := chernoff_separation_of_lt Q P a hlt
    refine ⟨c, hc, fun n => (A n)ᶜ, fun n => (hAmeas n).compl, fun n => ?_, fun n => ?_⟩
    · have htot : (bernoulli Q).real (A n) + (bernoulli Q).real (A n)ᶜ = 1 := by
        rw [measureReal_add_measureReal_compl (hAmeas n)]
        simp [measureReal_def]
      linarith [hP n]
    · have htot : (bernoulli P).real (A n) + (bernoulli P).real (A n)ᶜ = 1 := by
        rw [measureReal_add_measureReal_compl (hAmeas n)]
        simp [measureReal_def]
      linarith [hQ n]
  · exact chernoff_separation_of_lt P Q a hgt

/-- **The depth-`n` cutoff.**  The separation of the two harmonic measures by events of the
first `n` letters tends to `1`: mutual singularity is the limit of an exponential cutoff. -/
theorem tv_separation_tendsto (P Q : ProbVec) (h : ∃ a, P.p a ≠ Q.p a) :
    ∃ A : ℕ → Set Bdry, (∀ n, MeasurableSet (A n)) ∧
      Tendsto (fun n => (bernoulli P).real (A n) - (bernoulli Q).real (A n)) atTop (𝓝 1) := by
  obtain ⟨c, hc, A, hAmeas, hQ, hP⟩ := chernoff_separation P Q h
  refine ⟨A, hAmeas, ?_⟩
  have hexp0 : Tendsto (fun n : ℕ => Real.exp (-(c * (n : ℝ)))) atTop (𝓝 0) := by
    refine Real.tendsto_exp_atBot.comp ?_
    exact tendsto_neg_atTop_atBot.comp
      ((tendsto_natCast_atTop_atTop (R := ℝ)).const_mul_atTop hc)
  have hlow : Tendsto (fun n : ℕ => 1 - 2 * Real.exp (-(c * (n : ℝ)))) atTop (𝓝 1) := by
    have := (hexp0.const_mul (2 : ℝ)).const_sub (1 : ℝ)
    simpa using this
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le hlow tendsto_const_nhds
    (fun n => ?_) (fun n => ?_)
  · linarith [hP n, hQ n]
  · have h1 : (bernoulli P).real (A n) ≤ 1 := by
      simpa [measureReal_def] using
        (measureReal_mono (μ := bernoulli P) (Set.subset_univ (A n)) (measure_ne_top _ _))
    have h2 : 0 ≤ (bernoulli Q).real (A n) := measureReal_nonneg
    linarith

/-- Sanity check on the rate function: testing the frequency `1/2` against the fair walk's
letter probability `1/3` has a strictly positive exponential rate. -/
example : 0 < klBer (1 / 2) (1 / 3) :=
  klBer_pos (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)

end BerggrenHarmonic