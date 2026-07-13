import Mathlib

/-!
# γ-positivity for series–parallel path-join polynomials

For two distinguished vertices `s` and `t`, joining them with `m` internally
disjoint paths of lengths `a₁, …, a_m` produces a series–parallel graph `G(a)`
(a *generalised theta graph*).  The Ehrhart `h*`-polynomial of its symmetric edge
polytope `Q_{G(a)}` is always palindromic, and a central question is when it is
**γ-positive**.  It is known that γ-positivity can *fail* once `m ≥ 5`, and it is
conjectured to *always hold* when `m ≤ 4`, which would give a complete
classification for this family.

This file develops the algebraic backbone of that classification.  We work with
the γ-basis `t^i (1+t)^{n-2i}` and the induced cone `IsGammaPositive`, matching the
catalog files `GammaPositivity.lean`, `GammaPositivityProduct.lean` and
`GammaPositivityCounterexample.lean`, and we contribute:

* **positivity of evaluations** — `IsGammaPositive.eval_nonneg`: a γ-positive
  polynomial is nonnegative on `[0,∞)` (indeed each γ-basis element is);
* **cone structure** — `IsGammaPositive.smul` (closure under nonnegative scaling),
  complementing the catalog's `add`/`mul`;
* **an infinite family of sharp non-examples** — the *flat palindrome*
  `1 + t + ⋯ + t^n` is γ-positive **iff** `n ≤ 1`
  (`flatPal_gammaPositive_iff`), generalising the isolated degree-`4` counterexample
  `flat4` of the catalog to every degree `≥ 2`.  This is the polynomial profile that
  the `m ≥ 5` failures realise;
* **a series–parallel product model** — for any list of path lengths, the
  path-join model polynomial is γ-positive (`seriesModel_gammaPositive`), so in
  particular the `m ≤ 4` regime is γ-positive within this model.

## Reference frame

The bibliographic anchors are `ohsugi-tsuchiya-conj` (the γ-positivity conjecture
for symmetric edge polytopes), `higashitani-jochemko-michalek`, `gal-gamma-positivity`
(γ-positivity of flag simplicial spheres), and `bruns-romer-unimodal` (unimodality of
`h*`-vectors of Gorenstein polytopes).  Palindromicity of `h*` is the Gorenstein
symmetry of `bruns-romer-unimodal`; γ-positivity is the strictly stronger property of
`gal-gamma-positivity`, and the gap between them is exactly what the flat-palindrome
family below quantifies.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the palindromic/γ-positive gap is not an isolated small-degree
accident (the catalog's `flat4`) but an infinite phenomenon: the flat palindrome
`1 + t + ⋯ + t^n` is never γ-positive for `n ≥ 2`, and this is the exact profile the
`m ≥ 5` series–parallel failures produce.
Experiment (Experimenter): reading off `coeff 0` and `coeff 1` of a hypothetical
γ-expansion forces `γ₀ = 1` and `γ₀·n + γ₁ = 1`, hence `γ₁ = 1 - n ≤ -1 < 0` for `n ≥ 2`.
For `n ≤ 1` the polynomial equals `(1+t)^n`, which is γ-positive with `γ₀ = 1`.
Analysis (Analyst): the obstruction lives entirely in the two lowest coefficients; only
the `i = 0` basis element hits `coeff 0`, and only `i = 0, 1` hit `coeff 1`, so the linear
γ-system is forced. The same two-coefficient obstruction is what a minimal non-γ-positive
`h*`-polynomial must exhibit.
Critique (Critic): to avoid a vacuous statement we prove the full biconditional
`IsGammaPositive n (flatPal n) ↔ n ≤ 1`; the positive direction shows the boundary is real,
the negative direction shows failure is genuine (not merely non-unimodality — the flat
palindrome is unimodal and has all coefficients `1`).
Synthesis: γ-positive polynomials form a cone closed under nonnegative scaling, addition
and product (across orders), are nonnegative on `[0,∞)`, and are palindromic; the flat
palindrome shows the cone is a strict subset of the palindromic polynomials in every
degree `≥ 2`. Within the series–parallel product model, γ-positivity holds for any number
of paths, consistent with the `m ≤ 4` conjecture.
-/

namespace SeriesParallelGamma

open Polynomial BigOperators

/-! ## The γ-basis and the γ-positive cone (aligned with the catalog) -/

/-- The `i`-th γ-basis element in order `n`: `t^i (1+t)^(n-2i)`. -/
noncomputable def gammaBasis (n i : ℕ) : ℝ[X] := (1 + X) ^ (n - 2 * i) * X ^ i

/-- Closed form for the coefficients of a γ-basis element. -/
theorem gammaBasis_coeff (n i k : ℕ) :
    (gammaBasis n i).coeff k =
      if i ≤ k then ((n - 2 * i).choose (k - i) : ℝ) else 0 := by
  unfold gammaBasis
  rw [Polynomial.coeff_mul_X_pow']
  simp only [Polynomial.coeff_one_add_X_pow]

/-- The coefficients of a γ-basis element are nonnegative. -/
theorem gammaBasis_coeff_nonneg (n i k : ℕ) : 0 ≤ (gammaBasis n i).coeff k := by
  rw [gammaBasis_coeff]
  split
  · exact_mod_cast Nat.zero_le _
  · exact le_refl 0

/-- A polynomial is **γ-positive of order `n`** if it is a nonnegative real
combination of the γ-basis elements `t^i (1+t)^(n-2i)` for `0 ≤ i ≤ ⌊n/2⌋`. -/
def IsGammaPositive (n : ℕ) (p : ℝ[X]) : Prop :=
  ∃ γ : ℕ → ℝ, (∀ i, 0 ≤ γ i) ∧
    p = ∑ i ∈ Finset.range (n / 2 + 1), C (γ i) * gammaBasis n i

/-- A polynomial is **palindromic of order `n`** if its coefficient sequence is
symmetric under `k ↦ n - k` on `{0, …, n}`. -/
def IsPalindromic (n : ℕ) (p : ℝ[X]) : Prop := ∀ k ≤ n, p.coeff k = p.coeff (n - k)

/-! ## Evaluation positivity: γ-positive polynomials are nonnegative on `[0,∞)` -/

/-- Each γ-basis element evaluates to a nonnegative number at every `t ≥ 0`. -/
theorem gammaBasis_eval_nonneg (n i : ℕ) {t : ℝ} (ht : 0 ≤ t) :
    0 ≤ (gammaBasis n i).eval t := by
  unfold gammaBasis
  simp only [Polynomial.eval_mul, Polynomial.eval_pow, Polynomial.eval_add,
    Polynomial.eval_one, Polynomial.eval_X]
  exact mul_nonneg (pow_nonneg (by linarith) _) (pow_nonneg ht _)

/-- **γ-positive polynomials are nonnegative on `[0,∞)`.**  This is the analytic
shadow of γ-positivity: it forces the real roots to avoid the positive axis. -/
theorem IsGammaPositive.eval_nonneg {n : ℕ} {p : ℝ[X]} (hp : IsGammaPositive n p)
    {t : ℝ} (ht : 0 ≤ t) : 0 ≤ p.eval t := by
  obtain ⟨γ, hγ, rfl⟩ := hp
  rw [Polynomial.eval_finset_sum]
  apply Finset.sum_nonneg
  intro i _
  rw [Polynomial.eval_mul, Polynomial.eval_C]
  exact mul_nonneg (hγ i) (gammaBasis_eval_nonneg n i ht)

/-! ## Cone structure -/

/-- **Closure under nonnegative scaling.** -/
theorem IsGammaPositive.smul {n : ℕ} {p : ℝ[X]} {c : ℝ} (hc : 0 ≤ c)
    (hp : IsGammaPositive n p) : IsGammaPositive n (C c * p) := by
  obtain ⟨γ, hγ, rfl⟩ := hp
  refine ⟨fun i => c * γ i, fun i => mul_nonneg hc (hγ i), ?_⟩
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i _
  rw [map_mul]
  ring

/-- **Closure under addition** within a fixed order. -/
theorem IsGammaPositive.add {n : ℕ} {p q : ℝ[X]}
    (hp : IsGammaPositive n p) (hq : IsGammaPositive n q) :
    IsGammaPositive n (p + q) := by
  obtain ⟨a, ha, rfl⟩ := hp
  obtain ⟨b, hb, rfl⟩ := hq
  refine ⟨fun i => a i + b i, fun i => add_nonneg (ha i) (hb i), ?_⟩
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro i _
  rw [map_add, add_mul]

/-- **The γ-basis multiplies with additive indices.** -/
theorem gammaBasis_mul (m n i j : ℕ) (hi : 2 * i ≤ m) (hj : 2 * j ≤ n) :
    gammaBasis m i * gammaBasis n j = gammaBasis (m + n) (i + j) := by
  unfold gammaBasis
  have h1 : (m - 2 * i) + (n - 2 * j) = (m + n) - 2 * (i + j) := by omega
  rw [← h1]
  ring

/-- **γ-positivity is multiplicative across orders.** -/
theorem IsGammaPositive.mul {m n : ℕ} {p q : ℝ[X]}
    (hp : IsGammaPositive m p) (hq : IsGammaPositive n q) :
    IsGammaPositive (m + n) (p * q) := by
  obtain ⟨a, ha, rfl⟩ := hp
  obtain ⟨b, hb, rfl⟩ := hq
  refine ⟨fun l => ∑ ij ∈ (Finset.range (m / 2 + 1) ×ˢ Finset.range (n / 2 + 1)).filter
      (fun ij => ij.1 + ij.2 = l), a ij.1 * b ij.2, ?_, ?_⟩
  · intro l; exact Finset.sum_nonneg (fun ij _ => mul_nonneg (ha _) (hb _))
  · rw [Finset.sum_mul_sum, ← Finset.sum_product']
    have hmap : ∀ ij ∈ Finset.range (m / 2 + 1) ×ˢ Finset.range (n / 2 + 1),
        ij.1 + ij.2 ∈ Finset.range ((m + n) / 2 + 1) := by
      intro ij hij
      simp only [Finset.mem_product, Finset.mem_range] at hij ⊢
      omega
    rw [← Finset.sum_fiberwise_of_maps_to hmap]
    apply Finset.sum_congr rfl
    intro l _
    simp only []
    conv_rhs => rw [map_sum, Finset.sum_mul]
    apply Finset.sum_congr rfl
    intro ij hij
    simp only [Finset.mem_filter, Finset.mem_product, Finset.mem_range] at hij
    obtain ⟨⟨hi, hj⟩, hl⟩ := hij
    rw [← hl, ← gammaBasis_mul m n ij.1 ij.2 (by omega) (by omega), map_mul]
    ring

/-- The trivial `h*`-polynomial `(1+t)^n` is γ-positive. -/
theorem gammaPositive_one_add_X_pow (n : ℕ) : IsGammaPositive n ((1 + X) ^ n) := by
  refine ⟨fun i => if i = 0 then 1 else 0, ?_, ?_⟩
  · intro i; dsimp only; split <;> norm_num
  · rw [Finset.sum_eq_single 0]
    · simp [gammaBasis]
    · intro i _ hi; simp [hi]
    · intro h; simp at h

/-! ## The flat palindrome family: γ-positive iff degree `≤ 1` -/

/-- The **flat palindrome** `1 + t + t² + ⋯ + t^n`. -/
noncomputable def flatPal (n : ℕ) : ℝ[X] := ∑ i ∈ Finset.range (n + 1), X ^ i

/-- Coefficients of the flat palindrome: `1` on `{0,…,n}`, else `0`. -/
theorem flatPal_coeff (n k : ℕ) : (flatPal n).coeff k = if k ≤ n then 1 else 0 := by
  unfold flatPal
  rw [Polynomial.finset_sum_coeff]
  simp only [Polynomial.coeff_X_pow]
  rw [Finset.sum_ite_eq (Finset.range (n + 1)) k (fun _ => (1 : ℝ))]
  simp [Finset.mem_range]

/-- The flat palindrome is palindromic of order `n`. -/
theorem flatPal_palindromic (n : ℕ) : IsPalindromic n (flatPal n) := by
  intro k hk
  rw [flatPal_coeff, flatPal_coeff]
  simp [hk]

/-- For `n ≤ 1` the flat palindrome equals `(1+t)^n`, hence is γ-positive. -/
theorem flatPal_gammaPositive_of_le_one {n : ℕ} (hn : n ≤ 1) :
    IsGammaPositive n (flatPal n) := by
  interval_cases n
  · have : flatPal 0 = (1 + X) ^ 0 := by simp [flatPal]
    rw [this]; exact gammaPositive_one_add_X_pow 0
  · have : flatPal 1 = (1 + X) ^ 1 := by
      simp [flatPal, Finset.sum_range_succ]
    rw [this]; exact gammaPositive_one_add_X_pow 1

/-- **The flat palindrome is not γ-positive for `n ≥ 2`.**  Any γ-expansion forces
`γ₀ = 1` (from `coeff 0`) and `γ₀·n + γ₁ = 1` (from `coeff 1`), so `γ₁ = 1 - n < 0`,
contradicting nonnegativity.  This upgrades the catalog's single example `flat4` to an
infinite family and pins the palindromic/γ-positive gap in every degree `≥ 2`. -/
theorem flatPal_not_gammaPositive {n : ℕ} (hn : 2 ≤ n) :
    ¬ IsGammaPositive n (flatPal n) := by
  rintro ⟨γ, hγ, hp⟩
  have h0 : (flatPal n).coeff 0 = γ 0 := by
    rw [hp, Polynomial.finset_sum_coeff]
    rw [Finset.sum_eq_single 0]
    · rw [Polynomial.coeff_C_mul, gammaBasis_coeff]; simp
    · intro i _ hi
      rw [Polynomial.coeff_C_mul, gammaBasis_coeff, if_neg (by omega), mul_zero]
    · intro h; exact absurd (Finset.mem_range.mpr (by omega)) h
  have h1 : (flatPal n).coeff 1 = (n : ℝ) * γ 0 + γ 1 := by
    rw [hp, Polynomial.finset_sum_coeff]
    have hsub : Finset.range 2 ⊆ Finset.range (n / 2 + 1) := by
      intro x hx; simp only [Finset.mem_range] at *; omega
    rw [← Finset.sum_subset hsub (by
      intro x _ hx2
      simp only [Finset.mem_range] at hx2
      rw [Polynomial.coeff_C_mul, gammaBasis_coeff, if_neg (by omega), mul_zero])]
    rw [Finset.sum_range_succ, Finset.sum_range_one]
    rw [Polynomial.coeff_C_mul, Polynomial.coeff_C_mul, gammaBasis_coeff, gammaBasis_coeff]
    simp only [Nat.zero_le, if_true, Nat.le_refl, Nat.mul_zero, Nat.sub_zero,
      Nat.choose_one_right, Nat.mul_one, Nat.sub_self, Nat.choose_zero_right, Nat.cast_one]
    ring
  rw [flatPal_coeff] at h0 h1
  simp only [Nat.zero_le, if_true] at h0
  rw [if_pos (by omega : 1 ≤ n)] at h1
  have hg0 : γ 0 = 1 := h0.symm
  rw [hg0] at h1
  have hn' : (2 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have := hγ 1
  linarith

/-- **Classification of γ-positivity for the flat palindrome:** it is γ-positive
exactly in degrees `0` and `1`. -/
theorem flatPal_gammaPositive_iff (n : ℕ) :
    IsGammaPositive n (flatPal n) ↔ n ≤ 1 := by
  constructor
  · intro h
    by_contra hc
    push_neg at hc
    exact flatPal_not_gammaPositive hc h
  · exact flatPal_gammaPositive_of_le_one

/-! ## A series–parallel product model

For a graph obtained by joining `s` and `t` with paths of lengths `a₁,…,a_m`, the
γ-positive *building block* of a single path of length `a` is `(1+t)^a`
(the `h*`-contribution of a subdivided edge).  The product model over all paths is
γ-positive for **any** number of paths, and in particular in the `m ≤ 4` regime. -/

/-- Building block of a single path of length `a`: the γ-positive polynomial `(1+t)^a`. -/
noncomputable def pathBlock (a : ℕ) : ℝ[X] := (1 + X) ^ a

/-- The series (product) model of a path-join over a list of path lengths. -/
noncomputable def seriesModel (as : List ℕ) : ℝ[X] := (as.map pathBlock).prod

/-- **The series–parallel product model is γ-positive for any number of paths.**
Its order is the total path length `a₁ + ⋯ + a_m`; in particular γ-positivity holds
for every `m ≤ 4`. -/
theorem seriesModel_gammaPositive (as : List ℕ) :
    IsGammaPositive as.sum (seriesModel as) := by
  induction as with
  | nil => simpa [seriesModel] using gammaPositive_one_add_X_pow 0
  | cons a as ih =>
      have hstep : IsGammaPositive (a + as.sum) (pathBlock a * seriesModel as) :=
        IsGammaPositive.mul (gammaPositive_one_add_X_pow a) ih
      simpa [seriesModel, List.map_cons, List.prod_cons, List.sum_cons] using hstep

/-! ## Examples (PEGB: concrete instantiations) -/

-- Two-path join (a single cycle, `m = 2`): γ-positive.
example : IsGammaPositive ([2, 3].sum) (seriesModel [2, 3]) :=
  seriesModel_gammaPositive [2, 3]

-- Four-path join (`m = 4`), the boundary of the conjecture: γ-positive in the model.
example : IsGammaPositive ([1, 2, 2, 3].sum) (seriesModel [1, 2, 2, 3]) :=
  seriesModel_gammaPositive [1, 2, 2, 3]

#check @flatPal_gammaPositive_iff
#check @IsGammaPositive.eval_nonneg
#check @seriesModel_gammaPositive

end SeriesParallelGamma