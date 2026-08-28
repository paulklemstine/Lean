/-
# Consecutive-position dependency in the sieve polynomial `y_v = (s+v)^2 - N`

The j-feature sweep (paper 248) eliminated every *marginal* arithmetic feature
of the position index as a carrier of the mid-window excess, and pre-registered
the next study: the dependency between **consecutive** positions `v`, `v+1`
induced by shared small-prime divisibility of the sieve polynomial

  `y_v = (isqrt N + v)^2 - N`.

This file proves the exact local (mod `q`) law governing that dependency.  Fix an
odd prime `q` and work with `s = isqrt N` and `N` reduced mod `q`.

* `divSet_eq_pair`, `card_divSet` : if `N` is a nonzero square mod `q`, the set
  of residues `v` with `q ∣ y_v` is exactly the two-element set `{r - s, -r - s}`
  — the familiar "two roots per prime" of the quadratic sieve.
* `four_mul_eq_one_of_adjacent` : **the adjacency obstruction.** If `q` divides
  two *consecutive* values `y_v` and `y_{v+1}`, then necessarily `4N = 1` in
  `ZMod q`.  For every prime outside this codimension-one exceptional set,
  consecutive positions can never both be hit.
* `pairSet_eq_empty`, `pairSet_eq_singleton`, `card_pairSet_dichotomy` : the
  number of adjacent double-hits is exactly `0` (generic `N`) or exactly `1`
  (when `4N = 1`) — never the `4/q` that independence would predict.
* `cov_adjacent_eq`, `cov_adjacent_neg`, `cov_adjacent_dichotomy` : the empirical
  covariance of the divisibility indicators at `v` and `v+1`, computed with the
  covariance calculus of `Logic.PhaseRoute`, is exactly

      `cov = (#pairSet)/q - 4/q²`,

  hence exactly `-4/q² < 0` for generic `N`, and `1/q - 4/q² > 0` in the
  exceptional case (for `q > 4`).  Consecutive positions are therefore *never*
  independent, in either direction, while each position taken alone has the
  plain density `2/q`.

This is precisely a carrier of the type that `Logic.JFeatureMarginalBlindness`
shows to be invisible to every marginal-on-`j` test: the marginal density `2/q`
is completely insensitive to `N`, whereas the pair statistic separates the
generic from the exceptional case.
-/
import Logic.PhaseRouteLeastSquares

namespace Logic.JFeature

open Finset Logic.PhaseRoute

section Consecutive

variable {q : ℕ} [Fact (Nat.Prime q)]

/-- The sieve polynomial reduced mod `q`: `y_v = (s+v)^2 - N`. -/
def yv (s N v : ZMod q) : ZMod q := (s + v) ^ 2 - N

/-- The residues `v` at which `q ∣ y_v`. -/
def divSet (s N : ZMod q) : Finset (ZMod q) := univ.filter (fun v => yv s N v = 0)

/-- The residues `v` at which `q` divides **two consecutive** values. -/
def pairSet (s N : ZMod q) : Finset (ZMod q) :=
  univ.filter (fun v => yv s N v = 0 ∧ yv s N (v + 1) = 0)

lemma mem_divSet {s N v : ZMod q} : v ∈ divSet s N ↔ (s + v) ^ 2 = N := by
  simp [divSet, yv, sub_eq_zero]

lemma mem_pairSet {s N v : ZMod q} :
    v ∈ pairSet s N ↔ (s + v) ^ 2 = N ∧ (s + (v + 1)) ^ 2 = N := by
  simp [pairSet, yv, sub_eq_zero]

/-- In an odd prime field `2 ≠ 0`. -/
lemma two_ne_zero_of_ne_two (hq : q ≠ 2) : (2 : ZMod q) ≠ 0 := by
  intro h
  have h2 : ((2 : ℕ) : ZMod q) = 0 := by exact_mod_cast h
  rw [ZMod.natCast_eq_zero_iff] at h2
  exact hq ((Nat.prime_dvd_prime_iff_eq Fact.out Nat.prime_two).1 h2)

/-! ### Two roots per prime -/

/-- **The two roots.** For a nonzero square `N = r²` the hit set mod `q` is the
explicit two-element set `{r - s, -r - s}`. -/
theorem divSet_eq_pair (s r : ZMod q) :
    divSet s (r ^ 2) = {r - s, -r - s} := by
  ext v
  rw [mem_divSet]
  simp only [Finset.mem_insert, Finset.mem_singleton]
  constructor
  · intro h
    have hfac : (s + v - r) * (s + v + r) = 0 := by linear_combination h
    rcases mul_eq_zero.1 hfac with h1 | h1
    · exact Or.inl (by linear_combination h1)
    · exact Or.inr (by linear_combination h1)
  · rintro (rfl | rfl) <;> ring

/-- The two roots are distinct, so a nonzero square has exactly two positions
per prime. -/
theorem card_divSet (hq : q ≠ 2) (s r : ZMod q) (hr : r ≠ 0) :
    (divSet s (r ^ 2)).card = 2 := by
  rw [divSet_eq_pair s r]
  refine Finset.card_pair ?_
  intro h
  have h2 : (2 : ZMod q) * r = 0 := by linear_combination h
  rcases mul_eq_zero.1 h2 with h3 | h3
  · exact two_ne_zero_of_ne_two hq h3
  · exact hr h3

/-! ### The adjacency obstruction -/

/-- **Adjacency obstruction.** Two *consecutive* positions can both be divisible
by `q` only if `4N = 1` in `ZMod q`. -/
theorem four_mul_eq_one_of_adjacent {s N v : ZMod q} (hv : v ∈ pairSet s N) :
    4 * N = 1 := by
  rw [mem_pairSet] at hv
  obtain ⟨h1, h2⟩ := hv
  have h3 : 2 * (s + v) + 1 = 0 := by linear_combination h2 - h1
  linear_combination (-4 : ZMod q) * h1 + (2 * (s + v) - 1) * h3

/-- For generic `N` there is **no** adjacent double-hit at any odd prime. -/
theorem pairSet_eq_empty {s N : ZMod q} (hN : 4 * N ≠ 1) : pairSet s N = ∅ := by
  rw [Finset.eq_empty_iff_forall_notMem]
  intro v hv
  exact hN (four_mul_eq_one_of_adjacent hv)

/-- In the exceptional case `4N = 1` there is **exactly one** adjacent
double-hit, at `v = -2⁻¹ - s`. -/
theorem pairSet_eq_singleton (hq : q ≠ 2) {s N : ZMod q} (hN : 4 * N = 1) :
    pairSet s N = {-(2 : ZMod q)⁻¹ - s} := by
  have h2 : (2 : ZMod q) ≠ 0 := two_ne_zero_of_ne_two hq
  have hinv : (2 : ZMod q) * (2 : ZMod q)⁻¹ = 1 := mul_inv_cancel₀ h2
  have h4ne : (4 : ZMod q) ≠ 0 := by
    have h44 : (4 : ZMod q) = 2 * 2 := by norm_num
    rw [h44]; exact mul_ne_zero h2 h2
  have hsq : ((2 : ZMod q)⁻¹) ^ 2 = N := by
    have hA : (4 : ZMod q) * (((2 : ZMod q)⁻¹) ^ 2) = 1 := by
      linear_combination (2 * (2 : ZMod q)⁻¹ + 1) * hinv
    have hB : (4 : ZMod q) * ((((2 : ZMod q)⁻¹) ^ 2) - N) = 0 := by
      linear_combination hA - hN
    exact sub_eq_zero.1 ((mul_eq_zero.1 hB).resolve_left h4ne)
  ext v
  rw [mem_pairSet, Finset.mem_singleton]
  constructor
  · rintro ⟨h1, h2'⟩
    have h3 : 2 * (s + v) + 1 = 0 := by linear_combination h2' - h1
    -- `s + v = -2⁻¹`
    have h4 : (2 : ZMod q) * (s + v) = (2 : ZMod q) * (-(2 : ZMod q)⁻¹) := by
      linear_combination h3 + hinv
    have h5 : s + v = -(2 : ZMod q)⁻¹ := mul_left_cancel₀ h2 h4
    linear_combination h5
  · rintro rfl
    exact ⟨by linear_combination hsq, by linear_combination hsq - hinv⟩

/-- **Pair-count dichotomy.** The number of adjacent double-hits is `0` or `1`;
never the `4/q` predicted by independence of the two positions. -/
theorem card_pairSet_dichotomy (hq : q ≠ 2) (s N : ZMod q) :
    (pairSet s N).card = 0 ∨ (pairSet s N).card = 1 := by
  by_cases hN : 4 * N = 1
  · exact Or.inr (by rw [pairSet_eq_singleton hq hN, Finset.card_singleton])
  · exact Or.inl (by rw [pairSet_eq_empty hN, Finset.card_empty])

/-- **The exceptional locus is a divisor condition.**  For an integer target
`N`, the primes at which consecutive positions can both be hit are exactly the
prime divisors of `4N - 1`; in particular there are only finitely many of them,
and they are enumerable for any concrete `N`. -/
theorem four_mul_eq_one_iff_dvd (Nn : ℕ) :
    (4 : ZMod q) * (Nn : ZMod q) = 1 ↔ (q : ℤ) ∣ (4 * (Nn : ℤ) - 1) := by
  constructor
  · intro h
    have h0 : ((4 * (Nn : ℤ) - 1 : ℤ) : ZMod q) = 0 := by
      push_cast
      rw [h, sub_self]
    exact (ZMod.intCast_zmod_eq_zero_iff_dvd _ q).1 h0
  · intro h
    have h0 : ((4 * (Nn : ℤ) - 1 : ℤ) : ZMod q) = 0 := (ZMod.intCast_zmod_eq_zero_iff_dvd _ q).2 h
    push_cast at h0
    linear_combination h0

/-- Away from the divisors of `4N - 1`, consecutive positions are mutually
exclusive at every odd prime. -/
theorem pairSet_eq_empty_of_not_dvd (s : ZMod q) (Nn : ℕ)
    (h : ¬ ((q : ℤ) ∣ (4 * (Nn : ℤ) - 1))) :
    pairSet s (Nn : ZMod q) = ∅ :=
  pairSet_eq_empty (fun hcon => h ((four_mul_eq_one_iff_dvd Nn).1 hcon))

/-! ### The exact adjacent covariance -/

section Covariance

variable (s N : ZMod q)

/-- Indicator of the event `q ∣ y_v`, as a real-valued statistic on positions. -/
noncomputable def hitInd : ZMod q → ℝ := fun v => if yv s N v = 0 then 1 else 0

/-- The same statistic read at the **next** position. -/
noncomputable def hitIndShift : ZMod q → ℝ := fun v => hitInd s N (v + 1)

lemma avg_hitInd : avg (hitInd s N) = ((divSet s N).card : ℝ) / (q : ℝ) := by
  have hcard : Fintype.card (ZMod q) = q := ZMod.card q
  simp only [avg, hitInd, hcard]
  congr 1
  simp [divSet]

lemma avg_hitIndShift : avg (hitIndShift s N) = ((divSet s N).card : ℝ) / (q : ℝ) := by
  have hshift : ∑ v : ZMod q, hitInd s N (v + 1) = ∑ v : ZMod q, hitInd s N v :=
    Fintype.sum_equiv (Equiv.addRight (1 : ZMod q)) _ _ (fun v => rfl)
  have hcard : Fintype.card (ZMod q) = q := ZMod.card q
  simp only [avg, hitIndShift, hshift]
  rw [← avg, avg_hitInd]

lemma avg_hitInd_mul : avg (fun v => hitInd s N v * hitIndShift s N v)
    = ((pairSet s N).card : ℝ) / (q : ℝ) := by
  have hcard : Fintype.card (ZMod q) = q := ZMod.card q
  have hprod : ∀ v : ZMod q, hitInd s N v * hitIndShift s N v
      = if (yv s N v = 0 ∧ yv s N (v + 1) = 0) then (1 : ℝ) else 0 := by
    intro v
    by_cases h1 : yv s N v = 0 <;> by_cases h2 : yv s N (v + 1) = 0 <;>
      simp [hitInd, hitIndShift, h1, h2]
  simp only [avg, hprod, hcard]
  congr 1
  simp [pairSet]

/-- **The exact adjacent covariance.**  The empirical covariance of the
divisibility indicators at `v` and `v+1` is the adjacent double-hit density
minus the square of the single-hit density. -/
theorem cov_adjacent_eq :
    cov (hitInd s N) (hitIndShift s N)
      = ((pairSet s N).card : ℝ) / (q : ℝ)
        - (((divSet s N).card : ℝ) / (q : ℝ)) ^ 2 := by
  rw [cov, avg_hitInd_mul, avg_hitInd, avg_hitIndShift]
  ring

/-- **Generic case: strictly negative adjacent covariance.**  For an odd prime
`q` and a nonzero square `N = r²` with `4N ≠ 1`, the two positions `v`, `v+1`
are *negatively* dependent, with covariance exactly `-4/q²`. -/
theorem cov_adjacent_neg (hq : q ≠ 2) (r : ZMod q) (hr : r ≠ 0) (hN : 4 * r ^ 2 ≠ 1) :
    cov (hitInd s (r ^ 2)) (hitIndShift s (r ^ 2)) = -(4 / (q : ℝ) ^ 2) := by
  rw [cov_adjacent_eq, pairSet_eq_empty hN, card_divSet hq s r hr]
  norm_num
  ring

/-- **Exceptional case.**  When `4N = 1` the single adjacent double-hit makes the
covariance `1/q - 4/q²`, which is strictly positive for `q > 4`. -/
theorem cov_adjacent_exceptional (hq : q ≠ 2) (r : ZMod q) (hr : r ≠ 0)
    (hN : 4 * r ^ 2 = 1) :
    cov (hitInd s (r ^ 2)) (hitIndShift s (r ^ 2))
      = 1 / (q : ℝ) - 4 / (q : ℝ) ^ 2 := by
  rw [cov_adjacent_eq, pairSet_eq_singleton hq hN, card_divSet hq s r hr]
  norm_num
  ring

/-- **Consecutive positions are never independent.**  For every prime `q ≥ 5`
and every nonzero square `N` mod `q`, the adjacent covariance is nonzero: it is
`-4/q² < 0` generically, and `1/q - 4/q² > 0` on the exceptional locus `4N = 1`.
This is the pair-level carrier that no marginal feature of the position index
can see (cf. `Logic.JFeature.enrich_marginal_feature_eq_one`). -/
theorem adjacent_dependency (hq5 : 5 ≤ q) (r : ZMod q) (hr : r ≠ 0) :
    cov (hitInd s (r ^ 2)) (hitIndShift s (r ^ 2)) ≠ 0 := by
  have hq : q ≠ 2 := by omega
  have hqR : (5 : ℝ) ≤ (q : ℝ) := by exact_mod_cast hq5
  have hqpos : (0 : ℝ) < (q : ℝ) := by linarith
  by_cases hN : 4 * r ^ 2 = 1
  · rw [cov_adjacent_exceptional s hq r hr hN]
    have : 0 < 1 / (q : ℝ) - 4 / (q : ℝ) ^ 2 := by
      rw [sub_pos, div_lt_div_iff₀ (by positivity) hqpos]
      nlinarith
    linarith
  · rw [cov_adjacent_neg s hq r hr hN]
    have : 0 < 4 / (q : ℝ) ^ 2 := by positivity
    linarith

end Covariance

end Consecutive

end Logic.JFeature