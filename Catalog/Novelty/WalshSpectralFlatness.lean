/-
# Walsh spectra of Boolean functions: flatness, the noise floor, and the 1/2 barrier

This file develops, from scratch, the Walsh/Fourier analysis of real-valued functions on the
Boolean cube `Fin n → Bool` that is needed to state and prove the *spectral face* of the
factoring-barrier framework (Paper 53, Experiment 388).  Nothing here is specific to factoring;
the arithmetic input lives in `Novelty.SpectralFlatnessFactoring`, which imports this file.

## Main results

* `SpectralFlatness.sum_walshChar` — the character sum `∑ x, χ_S x` is `2^n` for `S = ∅` and `0`
  otherwise.
* `SpectralFlatness.walshChar_mul` — `χ_S · χ_T = χ_{S Δ T}`: the characters form a group under
  pointwise multiplication, indexed by `(Finset (Fin n), Δ)`.
* `SpectralFlatness.orthogonality` — `∑ x, χ_S x χ_T x = 2^n [S = T]`.
* `SpectralFlatness.dual_orthogonality` — `∑_S χ_S x χ_S y = 2^n [x = y]`.
* `SpectralFlatness.parseval` — `∑_S (Ŵf S)^2 = 2^n ∑_x f x ^ 2`, and
  `SpectralFlatness.parseval_corr` — `∑_S corr(f,S)^2 = 1` for sign-valued `f`.
* `SpectralFlatness.agreement_corr` — the *dictionary*: a parity `χ_S` agrees with `f` on exactly
  `2^{n-1}(1 + corr(f,S))` points.  Correlation and prediction advantage are the same quantity.
* `SpectralFlatness.agreement_le_of_corr_le` — **the 1/2 barrier.**  If every parity in a family
  has correlation at most `ε`, no parity of that family predicts `f` on more than a
  `(1+ε)/2` fraction of the cube.
* `SpectralFlatness.exists_corr_sq_ge` — **the noise floor.**  *Some* parity always achieves
  `|corr| ≥ 2^{-n/2}`: a genuinely flat spectrum is flat exactly at the noise floor, never below.
* `SpectralFlatness.card_large_corr_le` — at most `ε^{-2}` parities can have `|corr| ≥ ε`.
* `SpectralFlatness.card_support_ge_of_flat` — **spectral spreading.**  A spectrum uniformly
  bounded by `ε` must be supported on at least `ε^{-2}` parities.
* `SpectralFlatness.lowDegree_mass_le` — the Fourier mass carried by parities of degree `≤ d` is
  at most `ε²` times the number of such parities, so if that count times `ε²` is `< 1` the
  function provably has most of its mass on high-degree parities.
* `SpectralFlatness.card_lowDegree` — `|{S : |S| ≤ d}| = ∑_{i ≤ d} C(n,i)`, the size of the
  degree-`≤ d` scan performed in the experiment.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the empirical "spectral flatness" of the factoring bit-functions is not
an accident of the sample: any function whose degree-`≤ 3` correlations sit at the random-sign
null level must have its entire Fourier mass on high-degree coefficients, and no function can be
flat *below* the `2^{-n/2}` floor.

Experiment (Experimenter): the reported numbers at `k = 14` (`m = 380628` support points) are
max degree-`≤ 3` correlation `≤ 0.021`, all-parity noise `0.0101 ≈ m^{-1/2}`, degree-`≤ 3`
null max `0.0065`.  Since `m^{-1/2} = 0.00162`, `exists_corr_sq_ge` predicts a floor of that order
and the observed all-parity max is `6.2 m^{-1/2}` — exactly the `√(2 log #parities)` scaling of a
maximum of `2^n` near-independent Gaussians.  The degree-`≤ 3` scan touches
`card_lowDegree` = `1 + 28 + 378 + 3276 = 3683` parities at `n = 28`.

Analysis (Analyst): `parseval_corr` forces `∑ corr² = 1`; `card_large_corr_le` then caps the number
of ε-heavy parities at `ε^{-2}`.  With `ε = 0.021` that cap is `2267 < 3683`, so flatness at the
observed level is *consistent* with — but does not by itself imply — mass escaping to high degree;
`lowDegree_mass_le` supplies the missing quantitative step.

Critique (Critic): all of the above is an *unconditional* statement about the cube with the uniform
measure.  The experiment samples the prime-restricted semiprime support, which is neither the full
cube nor uniform, so these theorems bound the *idealised* spectrum only.  The companion file
therefore proves an exact, support-honest vanishing theorem instead of appealing to this one.
-/
import Mathlib

namespace SpectralFlatness

open Finset

variable {n : ℕ}

/-! ### Signs and characters -/

/-- The `±1` encoding of a Boolean value: `false ↦ 1`, `true ↦ -1`. -/
noncomputable def sgn (b : Bool) : ℝ := if b then -1 else 1

theorem sgn_ne_zero (b : Bool) : sgn b ≠ 0 := by cases b <;> norm_num [sgn]

theorem sgn_mul_self (b : Bool) : sgn b * sgn b = 1 := by cases b <;> norm_num [sgn]

theorem sgn_mul_eq_one_iff (a b : Bool) : sgn a * sgn b = 1 ↔ a = b := by
  cases a <;> cases b <;> norm_num [sgn]

theorem abs_sgn (b : Bool) : |sgn b| = 1 := by cases b <;> norm_num [sgn]

/-- The Walsh character (GF(2) parity) indexed by a set `S` of coordinates. -/
noncomputable def walshChar (S : Finset (Fin n)) (x : Fin n → Bool) : ℝ := ∏ i ∈ S, sgn (x i)

theorem prod_sgn_sq (A : Finset (Fin n)) (x : Fin n → Bool) :
    (∏ i ∈ A, sgn (x i)) * (∏ i ∈ A, sgn (x i)) = 1 := by
  rw [← Finset.prod_mul_distrib]
  exact Finset.prod_eq_one fun i _ => sgn_mul_self (x i)

theorem walshChar_mul_self (S : Finset (Fin n)) (x : Fin n → Bool) :
    walshChar S x * walshChar S x = 1 := prod_sgn_sq S x

/-- A Walsh character takes only the values `±1`. -/
theorem walshChar_eq_one_or (S : Finset (Fin n)) (x : Fin n → Bool) :
    walshChar S x = 1 ∨ walshChar S x = -1 := by
  have h := walshChar_mul_self S x
  rcases mul_self_eq_one_iff.mp h with h1 | h1
  · exact Or.inl h1
  · exact Or.inr h1

theorem abs_walshChar (S : Finset (Fin n)) (x : Fin n → Bool) : |walshChar S x| = 1 := by
  rcases walshChar_eq_one_or S x with h | h <;> simp [h]

/-- The characters multiply according to symmetric difference: `χ_S χ_T = χ_{S Δ T}`. -/
theorem walshChar_mul (S T : Finset (Fin n)) (x : Fin n → Bool) :
    walshChar S x * walshChar T x = walshChar (symmDiff S T) x := by
  have hdisj : Disjoint (symmDiff S T) (S ∩ T) := by
    simpa [Finset.inf_eq_inter] using disjoint_symmDiff_inf S T
  have h1 : (∏ i ∈ S ∪ T, sgn (x i)) * (∏ i ∈ S ∩ T, sgn (x i))
      = (∏ i ∈ S, sgn (x i)) * (∏ i ∈ T, sgn (x i)) := Finset.prod_union_inter
  have h2 : (∏ i ∈ symmDiff S T, sgn (x i)) * (∏ i ∈ S ∩ T, sgn (x i))
      = ∏ i ∈ S ∪ T, sgn (x i) := by
    rw [← Finset.prod_union hdisj]
    congr 1
    simpa [Finset.sup_eq_union, Finset.inf_eq_inter] using symmDiff_sup_inf S T
  rw [← h2] at h1
  rw [walshChar, walshChar, walshChar, ← h1, mul_assoc, prod_sgn_sq, mul_one]

/-- Character sums: a nontrivial parity is balanced on the cube. -/
theorem sum_walshChar (S : Finset (Fin n)) :
    ∑ x : Fin n → Bool, walshChar S x = if S = ∅ then 2 ^ n else 0 := by
  have key : ∀ x : Fin n → Bool, walshChar S x
      = ∏ i : Fin n, (if i ∈ S then sgn (x i) else 1) := by
    intro x
    rw [walshChar, ← Finset.prod_filter]
    congr 1
    simp
  simp_rw [key]
  rw [← Fintype.piFinset_univ,
    ← Finset.prod_univ_sum (fun _ => (univ : Finset Bool)) (fun i b => if i ∈ S then sgn b else 1)]
  by_cases hS : S = ∅
  · subst hS; simp
  · obtain ⟨i, hi⟩ := Finset.nonempty_iff_ne_empty.mpr hS
    rw [if_neg hS]
    exact Finset.prod_eq_zero (Finset.mem_univ i) (by simp [hi, sgn])

/-- Orthogonality of the Walsh characters over the cube. -/
theorem orthogonality (S T : Finset (Fin n)) :
    ∑ x : Fin n → Bool, walshChar S x * walshChar T x = if S = T then 2 ^ n else 0 := by
  simp_rw [walshChar_mul]
  rw [sum_walshChar]
  by_cases h : S = T
  · simp [h]
  · rw [if_neg h, if_neg]
    simpa [Finset.bot_eq_empty] using fun hc => h (symmDiff_eq_bot.mp hc)

/-- Dual orthogonality: summing a character over *all* index sets separates points. -/
theorem dual_orthogonality (x y : Fin n → Bool) :
    ∑ S ∈ (univ : Finset (Fin n)).powerset, walshChar S x * walshChar S y
      = if x = y then 2 ^ n else 0 := by
  have key : ∀ S : Finset (Fin n), walshChar S x * walshChar S y
      = ∏ i ∈ S, (sgn (x i) * sgn (y i)) := by
    intro S; rw [walshChar, walshChar, ← Finset.prod_mul_distrib]
  simp_rw [key]
  have hpa := Finset.prod_add (fun i => sgn (x i) * sgn (y i)) (fun _ => (1 : ℝ))
      (univ : Finset (Fin n))
  simp only [Finset.prod_const_one, mul_one] at hpa
  rw [← hpa]
  by_cases hxy : x = y
  · subst hxy
    rw [if_pos rfl]
    have h2 : ∀ i : Fin n, sgn (x i) * sgn (x i) + 1 = (2 : ℝ) := by
      intro i; rw [sgn_mul_self]; norm_num
    simp [h2]
  · rw [if_neg hxy]
    obtain ⟨i, hi⟩ : ∃ i, x i ≠ y i := by
      by_contra h
      exact hxy (funext fun i => not_not.mp fun hh => h ⟨i, hh⟩)
    refine Finset.prod_eq_zero (Finset.mem_univ i) ?_
    cases hx : x i <;> cases hy : y i <;> simp [hx, hy, sgn] at hi ⊢

/-! ### Walsh coefficients and Parseval -/

/-- Unnormalised Walsh coefficient `∑_x f(x) χ_S(x)`. -/
noncomputable def walshSum (f : (Fin n → Bool) → ℝ) (S : Finset (Fin n)) : ℝ :=
  ∑ x : Fin n → Bool, f x * walshChar S x

/-- Normalised Walsh coefficient = correlation of `f` with the parity `χ_S`. -/
noncomputable def corr (f : (Fin n → Bool) → ℝ) (S : Finset (Fin n)) : ℝ :=
  ((2 : ℝ) ^ n)⁻¹ * walshSum f S

/-- **Parseval's identity** on the Boolean cube. -/
theorem parseval (f : (Fin n → Bool) → ℝ) :
    ∑ S ∈ (univ : Finset (Fin n)).powerset, (walshSum f S) ^ 2
      = 2 ^ n * ∑ x : Fin n → Bool, (f x) ^ 2 := by
  have step1 : ∀ S : Finset (Fin n), (walshSum f S) ^ 2
      = ∑ x : Fin n → Bool, ∑ y : Fin n → Bool,
          (f x * f y) * (walshChar S x * walshChar S y) := by
    intro S
    rw [walshSum, sq, Finset.sum_mul_sum]
    exact Finset.sum_congr rfl fun x _ => Finset.sum_congr rfl fun y _ => by ring
  simp_rw [step1]
  rw [Finset.sum_comm]
  have step2 : ∀ x : Fin n → Bool,
      ∑ S ∈ (univ : Finset (Fin n)).powerset, ∑ y : Fin n → Bool,
        (f x * f y) * (walshChar S x * walshChar S y) = f x * f x * 2 ^ n := by
    intro x
    rw [Finset.sum_comm]
    have h : ∀ y : Fin n → Bool,
        ∑ S ∈ (univ : Finset (Fin n)).powerset, (f x * f y) * (walshChar S x * walshChar S y)
        = (f x * f y) * (if x = y then (2 : ℝ) ^ n else 0) := by
      intro y; rw [← Finset.mul_sum, dual_orthogonality]
    simp_rw [h]
    simp
  simp_rw [step2]
  rw [Finset.mul_sum]
  exact Finset.sum_congr rfl fun x _ => by ring

/-- A `±1`-valued ("sign") function on the cube. -/
def IsSignFn (f : (Fin n → Bool) → ℝ) : Prop := ∀ x, f x = 1 ∨ f x = -1

theorem IsSignFn.sq {f : (Fin n → Bool) → ℝ} (hf : IsSignFn f) (x : Fin n → Bool) :
    (f x) ^ 2 = 1 := by rcases hf x with h | h <;> simp [h]

/-- **Parseval, normalised:** the spectrum of a sign function is a probability distribution. -/
theorem parseval_corr {f : (Fin n → Bool) → ℝ} (hf : IsSignFn f) :
    ∑ S ∈ (univ : Finset (Fin n)).powerset, (corr f S) ^ 2 = 1 := by
  have hp := parseval f
  simp_rw [hf.sq] at hp
  rw [Finset.sum_const, Finset.card_univ] at hp
  have hcard : (Fintype.card (Fin n → Bool) : ℝ) = 2 ^ n := by
    simp [Fintype.card_fun]
  rw [nsmul_eq_mul, hcard] at hp
  have h2 : ((2 : ℝ) ^ n) ≠ 0 := by positivity
  have : ∑ S ∈ (univ : Finset (Fin n)).powerset, (corr f S) ^ 2
      = (((2 : ℝ) ^ n)⁻¹) ^ 2 * ∑ S ∈ (univ : Finset (Fin n)).powerset, (walshSum f S) ^ 2 := by
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun S _ => by rw [corr]; ring
  rw [this, hp]
  field_simp

/-! ### Correlation is prediction advantage: the 1/2 barrier -/

/-- Number of points of the cube at which the parity `χ_S` agrees with the sign function `f`. -/
noncomputable def agree (f : (Fin n → Bool) → ℝ) (S : Finset (Fin n)) : ℕ :=
  ((univ : Finset (Fin n → Bool)).filter fun x => f x = walshChar S x).card

/-- **The dictionary between correlation and prediction.**  A parity agrees with `f` at
`2^{n-1}(1 + corr)` points; correlation `ε` means advantage `ε/2` over a coin flip. -/
theorem agreement_walshSum {f : (Fin n → Bool) → ℝ} (hf : IsSignFn f) (S : Finset (Fin n)) :
    walshSum f S = 2 * (agree f S : ℝ) - 2 ^ n := by
  classical
  have hsplit : ∑ x : Fin n → Bool, f x * walshChar S x
      = (∑ x ∈ (univ : Finset (Fin n → Bool)).filter (fun x => f x = walshChar S x),
            f x * walshChar S x)
        + ∑ x ∈ (univ : Finset (Fin n → Bool)).filter (fun x => ¬ f x = walshChar S x),
            f x * walshChar S x :=
    (Finset.sum_filter_add_sum_filter_not _ _ _).symm
  have hpos : ∀ x ∈ (univ : Finset (Fin n → Bool)).filter (fun x => f x = walshChar S x),
      f x * walshChar S x = 1 := by
    intro x hx
    rw [Finset.mem_filter] at hx
    rw [hx.2]
    exact walshChar_mul_self S x
  have hneg : ∀ x ∈ (univ : Finset (Fin n → Bool)).filter (fun x => ¬ f x = walshChar S x),
      f x * walshChar S x = -1 := by
    intro x hx
    rw [Finset.mem_filter] at hx
    rcases hf x with h1 | h1 <;> rcases walshChar_eq_one_or S x with h2 | h2 <;>
      simp [h1, h2] at hx ⊢
  rw [walshSum, hsplit, Finset.sum_congr rfl hpos, Finset.sum_congr rfl hneg]
  have hcard : ((univ : Finset (Fin n → Bool)).filter (fun x => f x = walshChar S x)).card
      + ((univ : Finset (Fin n → Bool)).filter (fun x => ¬ f x = walshChar S x)).card
      = 2 ^ n := by
    rw [Finset.card_filter_add_card_filter_not]
    simp [Finset.card_univ]
  simp only [Finset.sum_const, nsmul_eq_mul, mul_one, mul_neg_one, agree]
  have : (((univ : Finset (Fin n → Bool)).filter (fun x => ¬ f x = walshChar S x)).card : ℝ)
      = 2 ^ n - (agree f S : ℝ) := by
    have := congrArg (fun m : ℕ => (m : ℝ)) hcard
    push_cast at this
    simp only [agree]
    linarith
  rw [this]
  simp only [agree]
  ring

/-- Correlation form of the dictionary. -/
theorem agreement_corr {f : (Fin n → Bool) → ℝ} (hf : IsSignFn f) (S : Finset (Fin n)) :
    (agree f S : ℝ) = 2 ^ n * (1 + corr f S) / 2 := by
  have h := agreement_walshSum hf S
  have h2 : ((2 : ℝ) ^ n) ≠ 0 := by positivity
  rw [corr]
  field_simp
  linarith [h]

/-- **The 1/2 barrier.**  A parity whose correlation with `f` is at most `ε` predicts `f`
correctly on at most a `(1+ε)/2` fraction of the cube. -/
theorem agreement_le_of_corr_le {f : (Fin n → Bool) → ℝ} (hf : IsSignFn f) {S : Finset (Fin n)}
    {eps : ℝ} (h : corr f S ≤ eps) : (agree f S : ℝ) ≤ 2 ^ n * (1 + eps) / 2 := by
  rw [agreement_corr hf S]
  have h2 : (0 : ℝ) < 2 ^ n := by positivity
  have := mul_le_mul_of_nonneg_left (add_le_add_left h 1) (le_of_lt h2)
  linarith

/-- Exactly balanced prediction: correlation `0` means the parity is right on exactly half
of the cube. -/
theorem agree_eq_half_of_corr_zero {f : (Fin n → Bool) → ℝ} (hf : IsSignFn f)
    {S : Finset (Fin n)} (h : corr f S = 0) : (agree f S : ℝ) = 2 ^ n / 2 := by
  rw [agreement_corr hf S, h]; ring

/-! ### Flatness: the noise floor, few heavy coefficients, spectral spreading -/

theorem card_powerset_univ : ((univ : Finset (Fin n)).powerset).card = 2 ^ n := by
  rw [Finset.card_powerset, Finset.card_univ, Fintype.card_fin]

/-- **The noise floor.**  Every sign function has a parity correlating at least `2^{-n/2}`
with it: no spectrum is flatter than the random-function floor. -/
theorem exists_corr_sq_ge {f : (Fin n → Bool) → ℝ} (hf : IsSignFn f) :
    ∃ S ∈ (univ : Finset (Fin n)).powerset, (1 : ℝ) ≤ 2 ^ n * (corr f S) ^ 2 := by
  by_contra hcon
  push_neg at hcon
  have h2 : (0 : ℝ) < 2 ^ n := by positivity
  have hlt : ∀ S ∈ (univ : Finset (Fin n)).powerset, (corr f S) ^ 2 < ((2 : ℝ) ^ n)⁻¹ := by
    intro S hS
    have hS' := hcon S hS
    have hinv : (0 : ℝ) < ((2 : ℝ) ^ n)⁻¹ := by positivity
    calc (corr f S) ^ 2 = ((2 : ℝ) ^ n)⁻¹ * (2 ^ n * (corr f S) ^ 2) := by
          field_simp
      _ < ((2 : ℝ) ^ n)⁻¹ * 1 := mul_lt_mul_of_pos_left hS' hinv
      _ = ((2 : ℝ) ^ n)⁻¹ := by ring
  have hsum : ∑ S ∈ (univ : Finset (Fin n)).powerset, (corr f S) ^ 2
      < ∑ _S ∈ (univ : Finset (Fin n)).powerset, ((2 : ℝ) ^ n)⁻¹ := by
    refine Finset.sum_lt_sum_of_nonempty ?_ hlt
    exact ⟨∅, by simp⟩
  rw [Finset.sum_const, card_powerset_univ, nsmul_eq_mul, parseval_corr hf] at hsum
  push_cast at hsum
  rw [mul_inv_cancel₀ (ne_of_gt h2)] at hsum
  exact lt_irrefl 1 hsum

/-- At most `ε^{-2}` parities can carry correlation `≥ ε`. -/
theorem card_large_corr_le {f : (Fin n → Bool) → ℝ} (hf : IsSignFn f) {eps : ℝ}
    (heps : 0 < eps) :
    ((((univ : Finset (Fin n)).powerset).filter fun S => eps ≤ |corr f S|).card : ℝ)
      * eps ^ 2 ≤ 1 := by
  classical
  set P := ((univ : Finset (Fin n)).powerset).filter fun S => eps ≤ |corr f S| with hP
  have hle : ∑ S ∈ P, eps ^ 2 ≤ ∑ S ∈ P, (corr f S) ^ 2 := by
    refine Finset.sum_le_sum fun S hS => ?_
    rw [hP, Finset.mem_filter] at hS
    have := hS.2
    nlinarith [abs_nonneg (corr f S), sq_abs (corr f S)]
  have hsub : ∑ S ∈ P, (corr f S) ^ 2
      ≤ ∑ S ∈ (univ : Finset (Fin n)).powerset, (corr f S) ^ 2 := by
    refine Finset.sum_le_sum_of_subset_of_nonneg (by rw [hP]; exact Finset.filter_subset _ _) ?_
    intro S _ _; positivity
  rw [parseval_corr hf] at hsub
  rw [Finset.sum_const, nsmul_eq_mul] at hle
  linarith

/-- **Spectral spreading.**  If the whole spectrum is bounded by `ε`, the Fourier support must
contain at least `ε^{-2}` parities.  Flatness is not emptiness: the mass has to go somewhere. -/
theorem card_support_ge_of_flat {f : (Fin n → Bool) → ℝ} (hf : IsSignFn f) {eps : ℝ}
    (heps : 0 < eps) (hbdd : ∀ S ∈ (univ : Finset (Fin n)).powerset, |corr f S| ≤ eps) :
    (1 : ℝ) ≤ ((((univ : Finset (Fin n)).powerset).filter fun S => corr f S ≠ 0).card : ℝ)
      * eps ^ 2 := by
  classical
  set Q := ((univ : Finset (Fin n)).powerset).filter fun S => corr f S ≠ 0 with hQ
  have hzero : ∑ S ∈ (univ : Finset (Fin n)).powerset, (corr f S) ^ 2 = ∑ S ∈ Q, (corr f S) ^ 2 := by
    have h1 : ∑ S ∈ ((univ : Finset (Fin n)).powerset).filter (fun S => (corr f S) ^ 2 ≠ 0),
          (corr f S) ^ 2
        = ∑ S ∈ (univ : Finset (Fin n)).powerset, (corr f S) ^ 2 := Finset.sum_filter_ne_zero _
    rw [← h1, hQ]
    refine Finset.sum_congr ?_ fun _ _ => rfl
    ext S
    simp [pow_eq_zero_iff]
  have hle : ∑ S ∈ Q, (corr f S) ^ 2 ≤ ∑ _S ∈ Q, eps ^ 2 := by
    refine Finset.sum_le_sum fun S hS => ?_
    have hmem : S ∈ (univ : Finset (Fin n)).powerset := by
      rw [hQ, Finset.mem_filter] at hS; exact hS.1
    have := hbdd S hmem
    nlinarith [abs_nonneg (corr f S), sq_abs (corr f S)]
  rw [Finset.sum_const, nsmul_eq_mul] at hle
  rw [parseval_corr hf] at hzero
  linarith

/-! ### Low-degree scans -/

/-- The parities of degree at most `d` — the family scanned in the experiment. -/
def lowDegree (n d : ℕ) : Finset (Finset (Fin n)) :=
  ((univ : Finset (Fin n)).powerset).filter fun S => S.card ≤ d

/-- The size of a degree-`≤ d` scan. -/
theorem card_lowDegree (n d : ℕ) :
    (lowDegree n d).card = ∑ i ∈ range (d + 1), n.choose i := by
  classical
  have hbi : lowDegree n d = (range (d + 1)).biUnion fun i => Finset.powersetCard i univ := by
    ext S
    simp only [lowDegree, Finset.mem_filter, Finset.mem_powerset, Finset.mem_biUnion,
      Finset.mem_range, Finset.mem_powersetCard]
    constructor
    · rintro ⟨_, hcard⟩
      exact ⟨S.card, by omega, Finset.subset_univ S, rfl⟩
    · rintro ⟨i, hi, hsub, rfl⟩
      exact ⟨Finset.subset_univ S, by omega⟩
  rw [hbi, Finset.card_biUnion]
  · exact Finset.sum_congr rfl fun i _ => by
      rw [Finset.card_powersetCard, Finset.card_univ, Fintype.card_fin]
  · intro i _ j _ hij
    refine Finset.disjoint_left.mpr fun S hi hj => ?_
    rw [Finset.mem_powersetCard] at hi hj
    exact hij (hi.2 ▸ hj.2 ▸ rfl)

/-- **Low-degree mass bound.**  If no parity of degree `≤ d` correlates better than `ε`, the
Fourier mass on degree `≤ d` is at most `ε²·|{S : |S| ≤ d}|`; when that is `< 1`, most of the
mass provably lives on parities of degree `> d`. -/
theorem lowDegree_mass_le {f : (Fin n → Bool) → ℝ} {eps : ℝ} (heps : 0 ≤ eps)
    (hbdd : ∀ S ∈ lowDegree n d, |corr f S| ≤ eps) :
    ∑ S ∈ lowDegree n d, (corr f S) ^ 2 ≤ ((lowDegree n d).card : ℝ) * eps ^ 2 := by
  have hle : ∑ S ∈ lowDegree n d, (corr f S) ^ 2 ≤ ∑ _S ∈ lowDegree n d, eps ^ 2 := by
    refine Finset.sum_le_sum fun S hS => ?_
    have := hbdd S hS
    nlinarith [abs_nonneg (corr f S), sq_abs (corr f S)]
  rwa [Finset.sum_const, nsmul_eq_mul] at hle

/-- The complementary statement: high-degree mass is at least `1 - ε²·|{S : |S| ≤ d}|`. -/
theorem highDegree_mass_ge {f : (Fin n → Bool) → ℝ} (hf : IsSignFn f) {eps : ℝ} (heps : 0 ≤ eps)
    (hbdd : ∀ S ∈ lowDegree n d, |corr f S| ≤ eps) :
    1 - ((lowDegree n d).card : ℝ) * eps ^ 2
      ≤ ∑ S ∈ ((univ : Finset (Fin n)).powerset).filter (fun S => ¬ S.card ≤ d),
          (corr f S) ^ 2 := by
  classical
  have hsplit : ∑ S ∈ (univ : Finset (Fin n)).powerset, (corr f S) ^ 2
      = ∑ S ∈ lowDegree n d, (corr f S) ^ 2
        + ∑ S ∈ ((univ : Finset (Fin n)).powerset).filter (fun S => ¬ S.card ≤ d),
            (corr f S) ^ 2 := by
    rw [lowDegree]
    exact (Finset.sum_filter_add_sum_filter_not _ _ _).symm
  rw [parseval_corr hf] at hsplit
  have := lowDegree_mass_le (n := n) (d := d) heps hbdd
  linarith

end SpectralFlatness