import Mathlib

/-!
# Quantitative convergence of softmax lookup heads to the exact finite selector

The catalog file `Catalog/MachineLearning/TransformerArchitecture.lean` proves an *exact*
finite universality theorem for a linear-attention lookup architecture: with one head per
possible input, `multiHeadLookup f x = f x` on the nose.  The attention there is a bilinear
score with no softmax, so the "selection" is exact by construction.

This file supplies the missing quantitative bridge to genuine softmax attention.  Writing
`β` for the inverse temperature (equivalently, the score scale), we prove:

* `sum_weight_erase_le` — the total softmax mass off a `γ`-separated argmax is at most
  `(n-1) * exp (-(β*γ))`;
* `abs_softmaxRead_sub_le` — hence a softmax read of a bounded value vector differs from
  the hard selection by at most `2*M*(n-1)*exp (-(β*γ))`;
* `softmaxLookup_error_le` — instantiated at one-hot keys, where the score gap is exactly
  `1`, this bounds the error of a *softmax* lookup head against the exact finite selector;
* `softmaxLookup_eps_approximation` — the resulting ε-approximation theorem with an
  **explicit** admissible score scale.

The scope qualification of the original development is preserved and in fact sharpened:
everything below is a statement about a *fixed finite* input set, with an error bound whose
constant grows linearly in the number of heads `n = |X|`.  It is not the continuous uniform
universal-approximation theorem for softmax transformers.
-/

open scoped BigOperators

namespace SoftmaxLookup

section Weights

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- Softmax weights at inverse temperature (score scale) `β` for a score vector `s`. -/
noncomputable def weight (beta : ℝ) (s : ι → ℝ) (j : ι) : ℝ :=
  Real.exp (beta * s j) / ∑ k, Real.exp (beta * s k)

omit [DecidableEq ι] in
/-- The softmax partition function is strictly positive. -/
theorem denom_pos [Nonempty ι] (beta : ℝ) (s : ι → ℝ) :
    0 < ∑ k, Real.exp (beta * s k) :=
  Finset.sum_pos (fun _ _ => Real.exp_pos _) Finset.univ_nonempty

omit [DecidableEq ι] in
/-- Softmax weights are strictly positive. -/
theorem weight_pos [Nonempty ι] (beta : ℝ) (s : ι → ℝ) (j : ι) :
    0 < weight beta s j :=
  div_pos (Real.exp_pos _) (denom_pos beta s)

omit [DecidableEq ι] in
/-- Softmax weights sum to one. -/
theorem sum_weight [Nonempty ι] (beta : ℝ) (s : ι → ℝ) :
    ∑ j, weight beta s j = 1 := by
  simp only [weight]
  rw [← Finset.sum_div, div_self (ne_of_gt (denom_pos beta s))]

omit [DecidableEq ι] in
/-- A single softmax weight is bounded by the exponentiated score deficit. -/
theorem weight_le_exp_gap (beta : ℝ) (s : ι → ℝ) (i₀ j : ι) :
    weight beta s j ≤ Real.exp (beta * s j - beta * s i₀) := by
  have hden : Real.exp (beta * s i₀) ≤ ∑ k, Real.exp (beta * s k) :=
    Finset.single_le_sum (f := fun k => Real.exp (beta * s k))
      (fun k _ => le_of_lt (Real.exp_pos _)) (Finset.mem_univ i₀)
  have hpos : (0:ℝ) < Real.exp (beta * s i₀) := Real.exp_pos _
  rw [weight, Real.exp_sub]
  exact div_le_div_of_nonneg_left (le_of_lt (Real.exp_pos _)) hpos hden

/-- **Exponential concentration of softmax on a separated argmax.**
If every competing index is below `s i₀` by at least `γ`, the total off-argmax softmax mass
is at most `(n-1) * exp (-(β*γ))`. -/
theorem sum_weight_erase_le (beta gamma : ℝ) (s : ι → ℝ) (i₀ : ι)
    (hbeta : 0 ≤ beta) (hgap : ∀ j, j ≠ i₀ → s j + gamma ≤ s i₀) :
    ∑ j ∈ Finset.univ.erase i₀, weight beta s j
      ≤ (Fintype.card ι - 1 : ℝ) * Real.exp (-(beta * gamma)) := by
  have hterm : ∀ j ∈ Finset.univ.erase i₀,
      weight beta s j ≤ Real.exp (-(beta * gamma)) := by
    intro j hj
    have hne : j ≠ i₀ := Finset.ne_of_mem_erase hj
    refine (weight_le_exp_gap beta s i₀ j).trans ?_
    apply Real.exp_le_exp.mpr
    have h := hgap j hne
    nlinarith [h]
  refine (Finset.sum_le_card_nsmul _ _ _ hterm).trans ?_
  have hcard : (Finset.univ.erase i₀).card = Fintype.card ι - 1 := by
    rw [Finset.card_erase_of_mem (Finset.mem_univ i₀), Finset.card_univ]
  rw [nsmul_eq_mul, hcard]
  have h1 : 1 ≤ Fintype.card ι := Fintype.card_pos_iff.mpr ⟨i₀⟩
  have hcast : ((Fintype.card ι - 1 : ℕ) : ℝ) = (Fintype.card ι : ℝ) - 1 := by
    have := Nat.cast_sub (R := ℝ) h1
    simpa using this
  rw [hcast]

/-- The softmax weight at a `γ`-separated argmax is exponentially close to one. -/
theorem one_sub_weight_le [Nonempty ι] (beta gamma : ℝ) (s : ι → ℝ) (i₀ : ι)
    (hbeta : 0 ≤ beta) (hgap : ∀ j, j ≠ i₀ → s j + gamma ≤ s i₀) :
    1 - weight beta s i₀ ≤ (Fintype.card ι - 1 : ℝ) * Real.exp (-(beta * gamma)) := by
  have hsplit : ∑ j ∈ Finset.univ.erase i₀, weight beta s j
      = 1 - weight beta s i₀ := by
    have h := Finset.add_sum_erase Finset.univ (fun j => weight beta s j) (Finset.mem_univ i₀)
    rw [sum_weight beta s] at h
    linarith [h]
  rw [← hsplit]
  exact sum_weight_erase_le beta gamma s i₀ hbeta hgap

end Weights

section Read

variable {ι : Type*} [Fintype ι] [DecidableEq ι] [Nonempty ι]

/-- A softmax attention read: the convex combination of values with softmax weights. -/
noncomputable def softmaxRead (beta : ℝ) (s : ι → ℝ) (v : ι → ℝ) : ℝ :=
  ∑ j, weight beta s j * v j

/-- **Quantitative selection.**  A softmax read of a bounded value vector approximates the
hard selection `v i₀` with error at most `2*M*(n-1)*exp (-(β*γ))`. -/
theorem abs_softmaxRead_sub_le (beta gamma M : ℝ) (s v : ι → ℝ) (i₀ : ι)
    (hbeta : 0 ≤ beta) (hgap : ∀ j, j ≠ i₀ → s j + gamma ≤ s i₀)
    (hv : ∀ j, |v j| ≤ M) :
    |softmaxRead beta s v - v i₀|
      ≤ 2 * M * (Fintype.card ι - 1 : ℝ) * Real.exp (-(beta * gamma)) := by
  have hM : 0 ≤ M := le_trans (abs_nonneg (v i₀)) (hv i₀)
  have hkey : softmaxRead beta s v - v i₀
      = ∑ j ∈ Finset.univ.erase i₀, weight beta s j * (v j - v i₀) := by
    have hsum : ∑ j, weight beta s j * (v j - v i₀)
        = softmaxRead beta s v - v i₀ := by
      simp only [mul_sub, Finset.sum_sub_distrib, softmaxRead, ← Finset.sum_mul,
        sum_weight beta s, one_mul]
    rw [← hsum, ← Finset.add_sum_erase Finset.univ
      (fun j => weight beta s j * (v j - v i₀)) (Finset.mem_univ i₀)]
    simp
  rw [hkey]
  refine (Finset.abs_sum_le_sum_abs _ _).trans ?_
  have hbound : ∀ j ∈ Finset.univ.erase i₀,
      |weight beta s j * (v j - v i₀)| ≤ (2 * M) * weight beta s j := by
    intro j _
    rw [abs_mul, abs_of_pos (weight_pos beta s j), mul_comm]
    have hdiff : |v j - v i₀| ≤ 2 * M := by
      have h1 := hv j
      have h2 := hv i₀
      calc |v j - v i₀| ≤ |v j| + |v i₀| := abs_sub _ _
        _ ≤ 2 * M := by linarith
    exact mul_le_mul_of_nonneg_right hdiff (le_of_lt (weight_pos beta s j))
  refine (Finset.sum_le_sum hbound).trans ?_
  rw [← Finset.mul_sum]
  have hmass := sum_weight_erase_le beta gamma s i₀ hbeta hgap
  calc (2 * M) * ∑ j ∈ Finset.univ.erase i₀, weight beta s j
      ≤ (2 * M) * ((Fintype.card ι - 1 : ℝ) * Real.exp (-(beta * gamma))) :=
        mul_le_mul_of_nonneg_left hmass (by linarith)
    _ = 2 * M * (Fintype.card ι - 1 : ℝ) * Real.exp (-(beta * gamma)) := by ring

end Read

section OneHotLookup

variable {X : Type*} [Fintype X] [DecidableEq X] [Nonempty X]

/-- One-hot embedding, as in the catalog transformer file. -/
def oneHot (x : X) : X → ℝ := fun y => if y = x then 1 else 0

omit [Nonempty X] in
/-- Dot-product attention between one-hot vectors is exact equality testing. -/
theorem oneHot_score (x a : X) :
    (∑ i, oneHot x i * oneHot a i) = if a = x then 1 else 0 := by
  by_cases h : a = x
  · subst h; simp [oneHot]
  · rw [if_neg h, Finset.sum_eq_zero]
    intro i _
    by_cases hi : i = x
    · subst hi
      simp [oneHot, Ne.symm h]
    · simp [oneHot, hi]

/-- A **softmax** lookup head: soft attention at score scale `β` over one head per possible
input, reading the value table `f`. -/
noncomputable def softmaxLookup (beta : ℝ) (f : X → ℝ) (x : X) : ℝ :=
  softmaxRead beta (fun a => ∑ i, oneHot x i * oneHot a i) f

omit [Nonempty X] in
/-- The one-hot score has an exact unit gap at the matching key. -/
theorem oneHot_gap (x : X) :
    ∀ a, a ≠ x → (∑ i, oneHot x i * oneHot a i) + 1
      ≤ (∑ i, oneHot x i * oneHot x i) := by
  intro a ha
  rw [oneHot_score, oneHot_score, if_neg ha, if_pos rfl]
  norm_num

/-- **Softmax lookup converges to the exact finite selector, quantitatively.**
With one head per possible input and one-hot keys, the softmax read at score scale `β`
reproduces the exact lookup value `f x` up to `2*M*(|X|-1)*exp (-β)`. -/
theorem softmaxLookup_error_le (beta M : ℝ) (f : X → ℝ) (x : X)
    (hbeta : 0 ≤ beta) (hf : ∀ a, |f a| ≤ M) :
    |softmaxLookup beta f x - f x|
      ≤ 2 * M * (Fintype.card X - 1 : ℝ) * Real.exp (-beta) := by
  have h := abs_softmaxRead_sub_le (ι := X) beta 1 M
    (fun a => ∑ i, oneHot x i * oneHot a i) f x hbeta (oneHot_gap x) hf
  simpa using h

/-- **Explicit ε-approximation theorem.**  For every tolerance `ε > 0` there is an explicit
score scale beyond which the softmax lookup head is uniformly `ε`-accurate on the whole
finite domain; it is `log ((2*M*(|X|-1) + 1)/ε)`, i.e. logarithmic in the head count and in
`1/ε`. -/
theorem softmaxLookup_eps_approximation (M eps : ℝ) (f : X → ℝ)
    (heps : 0 < eps) (hf : ∀ a, |f a| ≤ M) :
    ∀ beta, Real.log ((2 * M * (Fintype.card X - 1 : ℝ) + 1) / eps) ≤ beta → 0 ≤ beta →
      ∀ x, |softmaxLookup beta f x - f x| < eps := by
  intro beta hbeta hbeta0 x
  have hM : 0 ≤ M := le_trans (abs_nonneg (f x)) (hf x)
  set C : ℝ := 2 * M * (Fintype.card X - 1 : ℝ) with hC
  have hcard : (1:ℝ) ≤ (Fintype.card X : ℝ) := by
    have h : 1 ≤ Fintype.card X := Fintype.card_pos_iff.mpr inferInstance
    exact_mod_cast h
  have hCnonneg : 0 ≤ C := by rw [hC]; nlinarith
  have hpos : (0:ℝ) < C + 1 := by linarith
  have hquot : 0 < (C + 1) / eps := by positivity
  have hexp : Real.exp (-beta) ≤ eps / (C + 1) := by
    have h1 : Real.exp (-beta) ≤ Real.exp (-Real.log ((C + 1) / eps)) :=
      Real.exp_le_exp.mpr (by linarith)
    have h2 : Real.exp (-Real.log ((C + 1) / eps)) = eps / (C + 1) := by
      rw [Real.exp_neg, Real.exp_log hquot, inv_div]
    rw [h2] at h1
    exact h1
  have hmain := softmaxLookup_error_le beta M f x hbeta0 hf
  calc |softmaxLookup beta f x - f x| ≤ C * Real.exp (-beta) := hmain
    _ ≤ C * (eps / (C + 1)) := mul_le_mul_of_nonneg_left hexp hCnonneg
    _ < eps := by
        rw [mul_div_assoc', div_lt_iff₀ hpos]
        nlinarith

/-- **No exactness at finite temperature.**  If the target value at the matching key is
strictly smaller than all competing values, the softmax lookup head strictly overshoots for
every finite score scale.  Hence the convergence in `tendsto_softmaxLookup` is genuinely
asymptotic: soft attention never reproduces the exact finite selector of the catalog
architecture. -/
theorem lt_softmaxLookup_of_strict_min (hcard : 2 ≤ Fintype.card X) (beta : ℝ)
    (f : X → ℝ) (x : X) (hmin : ∀ a, a ≠ x → f x < f a) :
    f x < softmaxLookup beta f x := by
  classical
  have hsum : softmaxLookup beta f x - f x
      = ∑ a ∈ Finset.univ.erase x,
          weight beta (fun a => ∑ i, oneHot x i * oneHot a i) a * (f a - f x) := by
    have hw : ∑ a, weight beta (fun a => ∑ i, oneHot x i * oneHot a i) a = 1 :=
      sum_weight _ _
    have hsplit : ∑ a, weight beta (fun a => ∑ i, oneHot x i * oneHot a i) a * (f a - f x)
        = softmaxLookup beta f x - f x := by
      simp only [mul_sub, Finset.sum_sub_distrib, softmaxLookup, softmaxRead,
        ← Finset.sum_mul, hw, one_mul]
    rw [← hsplit, ← Finset.add_sum_erase Finset.univ
      (fun a => weight beta (fun a => ∑ i, oneHot x i * oneHot a i) a * (f a - f x))
      (Finset.mem_univ x)]
    simp
  have hpos : 0 < ∑ a ∈ Finset.univ.erase x,
      weight beta (fun a => ∑ i, oneHot x i * oneHot a i) a * (f a - f x) := by
    apply Finset.sum_pos
    · intro a ha
      have hne : a ≠ x := Finset.ne_of_mem_erase ha
      exact mul_pos (weight_pos _ _ a) (by linarith [hmin a hne])
    · obtain ⟨a, b, hab⟩ := Fintype.exists_pair_of_one_lt_card hcard
      by_cases h : a = x
      · exact ⟨b, Finset.mem_erase.mpr ⟨fun hb => hab (by rw [h, hb]), Finset.mem_univ b⟩⟩
      · exact ⟨a, Finset.mem_erase.mpr ⟨h, Finset.mem_univ a⟩⟩
  linarith [hsum, hpos]

/-- The softmax lookup head converges to the exact finite selector as the score scale
tends to infinity. -/
theorem tendsto_softmaxLookup (f : X → ℝ) (x : X) :
    Filter.Tendsto (fun beta : ℝ => softmaxLookup beta f x) Filter.atTop (nhds (f x)) := by
  rw [Metric.tendsto_atTop]
  intro eps heps
  obtain ⟨M, hM⟩ : ∃ M, ∀ a, |f a| ≤ M := by
    refine ⟨(Finset.univ.sup' Finset.univ_nonempty (fun a => |f a|)), fun a => ?_⟩
    exact Finset.le_sup' (fun a => |f a|) (Finset.mem_univ a)
  refine ⟨max 0 (Real.log ((2 * M * (Fintype.card X - 1 : ℝ) + 1) / eps)), fun beta hb => ?_⟩
  have hb0 : 0 ≤ beta := le_trans (le_max_left _ _) hb
  have hb1 : Real.log ((2 * M * (Fintype.card X - 1 : ℝ) + 1) / eps) ≤ beta :=
    le_trans (le_max_right _ _) hb
  have := softmaxLookup_eps_approximation M eps f heps hM beta hb1 hb0 x
  rwa [Real.dist_eq]

end OneHotLookup

end SoftmaxLookup