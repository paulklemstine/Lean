import Mathlib

/-!
# Diophantine approximation of irrational numbers

This file develops the classical theory of best rational approximations to
irrational numbers, building on Mathlib's
`Real.infinite_rat_abs_sub_lt_one_div_den_sq_of_irrational`
(infinitely many rationals `q` with `|x - q| < 1 / q.den ^ 2`).

The new content here is the *unboundedness of denominators*: not only are there
infinitely many good rational approximations, but their denominators are
arbitrarily large.  This is the form needed to feed `atTop`-style limits (used in
`LagrangeConstantBridge.lean` to bound the Lagrange constant).

-- !-- Lab Notes -- !--
* **Hypothesis.** For an irrational `x`, the *denominators* of the Dirichlet-good
  rationals (`|x - q| < 1/q.den²`) are unbounded; equivalently there are
  infinitely many distinct denominators.
* **Experiment.** Mathlib gives an infinite *set* of good rationals.  We turn
  set-infiniteness into denominator-unboundedness by showing that, in any bounded
  interval, only finitely many rationals have bounded denominator
  (`finite_den_le_in_interval`).
* **Analysis.** The crucial finiteness fact reduces to the injectivity of
  `q ↦ (q.num, q.den)` together with explicit integer bounds on the numerator.
* **Critique.** Care is required at `N = 0` (vacuous) and with `ℕ`/`ℤ`/`ℝ`
  coercions of `q.den`.  The coprime reformulation uses `q.reduced`.
* **Synthesis.** `irrational_den_unbounded` and the coprime form
  `irrational_infinitely_many_coprime_approx` are the exported results.
-/

namespace ContinuedFractions

open Set

/-
In a bounded open interval there are only finitely many rationals whose
denominator is bounded by a fixed `N`.
-/
lemma finite_den_le_in_interval (N : ℕ) (a b : ℝ) :
    {q : ℚ | q.den ≤ N ∧ (q : ℝ) ∈ Set.Ioo a b}.Finite := by
  -- Let $C = \lceil |a| \rceil + \lceil |b| \rceil + 1$.
  set C := Nat.ceil (|a|) + Nat.ceil (|b|) + 1;
  -- For any $q$ in the set, we have $|q.num| \leq C * q.den$.
  have h_num_bound : ∀ q : ℚ, q.den ≤ N → (q : ℝ) ∈ Set.Ioo a b → |q.num| ≤ C * q.den := by
    intros q hq hq'
    have h_num_bound : |(q.num : ℝ)| ≤ C * q.den := by
      have h_num_bound : |(q.num : ℝ)| ≤ (max |a| |b|) * q.den := by
        have h_num_bound : |(q.num : ℝ)| ≤ |(q : ℝ)| * q.den := by
          rw [ Rat.cast_def ];
          rw [ abs_div, abs_of_nonneg ( by positivity : ( 0 : ℝ ) ≤ q.den ), div_mul_cancel₀ _ ( by positivity ) ];
        exact h_num_bound.trans ( mul_le_mul_of_nonneg_right ( by cases max_cases |a| |b| <;> cases abs_cases ( q : ℝ ) <;> cases abs_cases a <;> cases abs_cases b <;> linarith [ hq'.1, hq'.2 ] ) ( Nat.cast_nonneg _ ) );
      simp +zetaDelta at *;
      exact h_num_bound.trans ( mul_le_mul_of_nonneg_right ( by cases max_cases |a| |b| <;> linarith [ Nat.le_ceil |a|, Nat.le_ceil |b| ] ) ( Nat.cast_nonneg _ ) );
    exact_mod_cast h_num_bound;
  -- Therefore, the set of such $q$ is finite since there are only finitely many pairs $(num, den)$ with $|num| \leq C * den$ and $den \leq N$.
  have h_finite_pairs : Set.Finite {p : ℤ × ℕ | |p.1| ≤ C * p.2 ∧ 1 ≤ p.2 ∧ p.2 ≤ N} := by
    exact Set.Finite.subset ( Set.Finite.prod ( Set.finite_Icc ( - ( C * N : ℤ ) ) ( C * N : ℤ ) ) ( Set.finite_Icc 1 N ) ) fun p hp => ⟨ abs_le.mp hp.1 |> fun h => ⟨ by nlinarith [ hp.2.1, hp.2.2 ], by nlinarith [ hp.2.1, hp.2.2 ] ⟩, hp.2.1, hp.2.2 ⟩;
  refine Set.Finite.subset ( h_finite_pairs.image fun p : ℤ × ℕ => ( p.1 : ℚ ) / p.2 ) ?_;
  intro q hq; use ( q.num, q.den ) ; simp_all +decide [ Rat.num_div_den ] ;
  exact q.pos

/-
**Unbounded denominators.** For an irrational number `x` and any bound `N`,
there is a rational `q` with denominator at least `N` satisfying the Dirichlet
approximation bound `|x - q| < 1 / q.den²`.
-/
theorem irrational_den_unbounded {x : ℝ} (hx : Irrational x) (N : ℕ) :
    ∃ q : ℚ, |x - (q : ℝ)| < 1 / (q.den : ℝ) ^ 2 ∧ N ≤ q.den := by
  by_contra h_contra;
  -- Then every `q ∈ S` has `q.den < N`, hence `q.den ≤ N`.
  have h_den_le_N : ∀ q : ℚ, |x - q| < 1 / q.den ^ 2 → q.den ≤ N := by
    exact fun q hq => not_lt.1 fun contra => h_contra ⟨ q, hq, contra.le ⟩;
  -- Therefore `S ⊆ {q | q.den ≤ N ∧ (q:ℝ) ∈ Set.Ioo (x-1) (x+1)}`, which is finite by `finite_den_le_in_interval N (x-1) (x+1)`.
  have h_subset : {q : ℚ | |x - q| < 1 / q.den ^ 2} ⊆ {q : ℚ | q.den ≤ N ∧ (q : ℝ) ∈ Set.Ioo (x - 1) (x + 1)} := by
    intro q hq;
    exact ⟨ h_den_le_N q hq, ⟨ by linarith [ abs_lt.mp hq.out, show ( 1 : ℝ ) / q.den ^ 2 ≤ 1 by exact div_le_self zero_le_one ( mod_cast Nat.one_le_pow _ _ q.pos ) ], by linarith [ abs_lt.mp hq.out, show ( 1 : ℝ ) / q.den ^ 2 ≤ 1 by exact div_le_self zero_le_one ( mod_cast Nat.one_le_pow _ _ q.pos ) ] ⟩ ⟩;
  exact absurd ( Set.Finite.subset ( finite_den_le_in_interval N ( x - 1 ) ( x + 1 ) ) h_subset ) ( by exact_mod_cast Real.infinite_rat_abs_sub_lt_one_div_den_sq_of_irrational hx )

/-
**Coprime / integer form.** For an irrational `x` there are arbitrarily large
denominators `b` together with a coprime numerator `a` such that
`|x - a / b| < 1 / b²`.
-/
theorem irrational_infinitely_many_coprime_approx {x : ℝ} (hx : Irrational x)
    (N : ℕ) :
    ∃ a : ℤ, ∃ b : ℕ, (N : ℤ) ≤ b ∧ Int.gcd a b = 1 ∧
      |x - (a : ℝ) / (b : ℝ)| < 1 / (b : ℝ) ^ 2 := by
  obtain ⟨ q, h₁, h₂ ⟩ := irrational_den_unbounded hx N;
  exact ⟨ q.num, q.den, mod_cast h₂, q.reduced, by simpa [ Rat.cast_def ] using h₁ ⟩

end ContinuedFractions