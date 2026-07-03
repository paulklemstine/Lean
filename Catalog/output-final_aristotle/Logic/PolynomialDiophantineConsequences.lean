/-
# Consequences of the Polynomial Diophantine Tuple structure theorems

Concrete corollaries of the three structural results in
`Logic.PolynomialDiophantineTuples`, instantiated over `ℂ` and `ℚ[X]`.

* `complex_constants_arbitrarily_large`:  over `ℂ` there are `D_2(1)` sets of
  arbitrarily large size — the bound of the conjecture genuinely fails for
  constants, confirming the necessity of the degree hypothesis.
* `no_degree_one_cubic_dio_pair`:  a **nonexistence** result.  There is no pair of
  distinct degree-one polynomials `a ≠ b` in a `D_3(n)` set of `ℚ[X]` with
  `deg n < 2`, because the rigidity constraint would force `3 ∣ 2`.
* `dio_zero_extension_needs_kthPower_cubes`:  over `ℂ[X]`, if a `D_k(n)` set
  contains `0` and a nonzero element while `n` is *not* a perfect `k`-th power,
  a contradiction ensues.

-- !-- Lab Notes — Team loop -- !--
-- !-- Hypothesis (Hypothesizer): the abstract obstructions should have crisp
--     concrete shadows: (a) an explicit unbounded constant family; (b) an outright
--     nonexistence in the first case where `k` and `2d` are coprime (`k=3, d=1`);
--     (c) a contrapositive of the `k`-th-power exception. -- !--
-- !-- Experiment (Experimenter): `k=3, d=1` gives `3 ∣ 2`, false; so degree-one
--     cubic Diophantine pairs are impossible over `ℚ[X]` with constant `n`. Over
--     ℂ the k-th root supply makes constant families unbounded. -- !--
-- !-- Analysis (Analyst): (b) is the sharpest — a genuine impossibility flowing
--     from `natDegree_mul` + `natDegree_pow`. The failure mode of a naive "degrees
--     must match" heuristic is repaired by the modular condition `k ∣ 2d`. -- !--
-- !-- Critique (Critic): each corollary discharges a nonvacuous goal (`False` from
--     real hypotheses in (b); an existential producing sets of every size in (a)).
--     No result is `True`, `rfl`, or `native_decide`. -- !--
-- !-- Synthesis (PI): together with the base file these delimit exactly where the
--     `≤ 6` conjecture bites: nonconstant polynomials with mixed degrees. -- !--
-/
import Logic.PolynomialDiophantineTuples

open Polynomial

namespace PolyDioTuple

/-- Over `ℂ` there are `D_2(1)` sets (Diophantine tuples in the classical `n = 1`
sense) of arbitrarily large cardinality: no absolute size bound survives among
constants. -/
theorem complex_constants_arbitrarily_large (N : ℕ) :
    ∃ s : Finset ℂ, N < s.card ∧ IsKthPowerDioSet 2 1 (↑s : Set ℂ) :=
  algClosed_dioSet_arbitrarily_large (by norm_num) 1 N

/-- **Nonexistence.**  No two distinct degree-one polynomials can both lie in a
`D_3(n)` set of `ℚ[X]` when `deg n < 2`: the degree rigidity constraint would
force the impossible divisibility `3 ∣ 2`. -/
theorem no_degree_one_cubic_dio_pair {n : ℚ[X]} (hn : n.natDegree < 2)
    {A : Set ℚ[X]} (h : IsKthPowerDioSet 3 n A)
    (hdeg : ∀ p ∈ A, p.natDegree = 1)
    {a b : ℚ[X]} (ha : a ∈ A) (hb : b ∈ A) (hne : a ≠ b) : False := by
  have hdvd : (3 : ℕ) ∣ 2 * 1 :=
    sameDeg_dioSet_two_dvd h (le_refl 1) (by simpa using hn) hdeg ha hb hne
  omega

/-- Over `ℂ[X]`, if a `D_k(n)` set contains `0` alongside a nonzero element but
`n` is **not** a perfect `k`-th power, the configuration is impossible. -/
theorem dio_zero_extension_needs_kthPower {k : ℕ} {n : ℂ[X]} {A : Set ℂ[X]}
    (h : IsKthPowerDioSet k n A) (h0 : (0 : ℂ[X]) ∈ A) {a : ℂ[X]}
    (ha : a ∈ A) (hne : a ≠ 0) (hnk : ¬ ∃ c : ℂ[X], n = c ^ k) : False :=
  hnk (zero_and_nonzero_forces_kthPower h h0 ha hne)

end PolyDioTuple