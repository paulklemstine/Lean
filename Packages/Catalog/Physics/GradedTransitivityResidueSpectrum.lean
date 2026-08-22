import Physics.GradedTransitivityFourier
import Physics.GradedTransitivityResidue

/-!
# The residue spectrum: additivity, and rigidity of the periodic grade germ

Two open directions of the thread are settled here.

* **Additivity (Direction 2).**  The residue at `q = 1` is *additive* in the grade counts:
  if two graded objects have eventually polynomial grade counts `P` and `Q`, then the
  grade-wise sum has residue `−(P+Q)(−1)`, i.e. the zeta-regularised residue
  `P ↦ −P(−1)` is a homomorphism out of the additive monoid of grade germs.  The key
  technical input, proved here, is that a generating function with eventually polynomial
  coefficients is *summable* on the unit disc, so that the two continuations may be added
  before the contour integral is taken.

* **Rigidity of the periodic germ (Direction 5, periodic case).**  For grade counts that are
  eventually periodic mod `m`, the family of residues at the `m`-th roots of unity — the
  *residue spectrum* — is a **complete invariant of the grade germ**: two such graded objects
  have the same residue at every `m`-th root of unity if and only if their grade counts agree
  for all sufficiently large grades.  In particular a nonzero eventually periodic grade count
  can never produce a singularity-free (entire) partition function: some root of unity must
  carry a nonzero residue.

The mechanism in the second part is discrete Fourier inversion
(`Physics.GradedTransitivity.periodic_eq_fourier_sum`) combined with the residue formula
`Physics.GradedTransitivity.circleIntegral_eventually_periodic_mod`: the residue at the pole
`ζ^{-k}` is `−Âₖ/ζᵏ`, so knowing all residues is knowing the full discrete Fourier transform
of one period, and Fourier inversion recovers the period itself.

## Main results

* `Physics.GradedTransitivity.hasSum_of_eventually_polynomial`,
  `summable_of_eventually_polynomial` — summability of the generating series on the disc.
* `Physics.GradedTransitivity.circleIntegral_add_of_eventually_polynomial` — the residue of a
  sum of two continuations.
* `Physics.GradedTransitivity.circleIntegral_of_eventually_polynomial_add` — the residue of a
  continuation of the *summed* grade counts is `−(P+Q)(−1)`: additivity of the residue.
* `Physics.GradedTransitivity.fourierAmp_eq_of_eventuallyEq_period`,
  `eq_of_fourierAmp_eq` — Fourier inversion as a rigidity statement.
* `Physics.GradedTransitivity.eventuallyEq_of_residueSpectrum_eq` — the residue spectrum is a
  complete invariant of the eventually periodic grade germ.
* `Physics.GradedTransitivity.exists_residue_ne_zero_of_not_eventually_zero` — a nonzero
  eventually periodic grade germ always has a nonzero residue somewhere on the unit circle.
-/

namespace Physics.GradedTransitivity

open Finset Polynomial Complex Filter Topology

/-! ### Summability, and additivity of the residue at `q = 1` -/

/-- A generating series with eventually polynomial coefficients converges on the open unit
disc, to the canonical closed form `tailCorrection + polyZeta`. -/
theorem hasSum_of_eventually_polynomial {a : ℕ → ℂ} {P : Polynomial ℂ} {N : ℕ}
    (hcoef : ∀ n, N ≤ n → a n = P.eval (n : ℂ)) {q : ℂ} (hq : ‖q‖ < 1) :
    HasSum (fun n : ℕ => a n * q ^ n) (tailCorrection a P N q + polyZeta P q) := by
  classical
  have hP : HasSum (fun n : ℕ => P.eval (n : ℂ) * q ^ n) (polyZeta P q) := by
    have hsum : HasSum (fun n : ℕ => ∑ k ∈ range (P.natDegree + 1),
        newtonCoeff P k * ((n.choose k : ℂ) * q ^ n)) (polyZeta P q) :=
      hasSum_sum fun k _ => (hasSum_choose_pow k hq).mul_left (newtonCoeff P k)
    refine hsum.congr_fun fun n => ?_
    rw [newton_eval_natCast P n, Finset.sum_mul]
    exact Finset.sum_congr rfl fun k _ => by ring
  have he0 : ∀ n : ℕ, n ∉ range N → (a n - P.eval (n : ℂ)) * q ^ n = 0 := by
    intro n hn
    have hn' : N ≤ n := by simpa using hn
    simp [hcoef n hn']
  have hE : HasSum (fun n : ℕ => (a n - P.eval (n : ℂ)) * q ^ n) (tailCorrection a P N q) :=
    hasSum_sum_of_ne_finset_zero he0
  exact (hE.add hP).congr_fun fun n => by ring

theorem summable_of_eventually_polynomial {a : ℕ → ℂ} {P : Polynomial ℂ} {N : ℕ}
    (hcoef : ∀ n, N ≤ n → a n = P.eval (n : ℂ)) {q : ℂ} (hq : ‖q‖ < 1) :
    Summable (fun n : ℕ => a n * q ^ n) :=
  (hasSum_of_eventually_polynomial hcoef hq).summable

/-- A function analytic on `ℂ \ {1}` is circle-integrable on any circle centred at `1`. -/
theorem circleIntegrable_of_analyticOnNhd_compl_one {F : ℂ → ℂ}
    (hF : AnalyticOnNhd ℂ F {(1 : ℂ)}ᶜ) {ρ : ℝ} (hρ : 0 < ρ) :
    CircleIntegrable F 1 ρ := by
  refine ContinuousOn.circleIntegrable hρ.le fun z hz => ?_
  have hz' : z ∈ ({(1 : ℂ)}ᶜ : Set ℂ) := by
    simp only [Set.mem_compl_iff, Set.mem_singleton_iff]
    exact sub_ne_zero.mp (sub_one_ne_zero_of_mem_sphere hρ z hz)
  exact ((hF z hz').continuousAt).continuousWithinAt

/-- **Additivity of the residue, function version.**  The contour integral of a sum of two
continuations is the sum of the two residues. -/
theorem circleIntegral_add_of_eventually_polynomial {a b : ℕ → ℂ} {P Q : Polynomial ℂ}
    {N M : ℕ} (ha : ∀ n, N ≤ n → a n = P.eval (n : ℂ)) (hb : ∀ n, M ≤ n → b n = Q.eval (n : ℂ))
    {F G : ℂ → ℂ} (hF : AnalyticOnNhd ℂ F {(1 : ℂ)}ᶜ) (hG : AnalyticOnNhd ℂ G {(1 : ℂ)}ᶜ)
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, a n * q ^ n)
    (hG0 : ∀ᶠ q in 𝓝 (0 : ℂ), G q = ∑' n : ℕ, b n * q ^ n)
    {ρ : ℝ} (hρ : 0 < ρ) :
    (∮ z in C((1 : ℂ), ρ), (F z + G z))
      = -(P.eval (-1) + Q.eval (-1)) * (2 * (Real.pi : ℂ) * I) := by
  rw [circleIntegral.integral_add (circleIntegrable_of_analyticOnNhd_compl_one hF hρ)
      (circleIntegrable_of_analyticOnNhd_compl_one hG hρ),
    circleIntegral_of_eventually_polynomial ha hF hF0 hρ,
    circleIntegral_of_eventually_polynomial hb hG hG0 hρ]
  ring

/-- **Additivity of the residue, grade-count version.**  If the grade counts `a` and `b` are
eventually polynomial with polynomials `P` and `Q`, then any analytic continuation of the
generating function of the grade-wise sum `a + b` has residue `−(P+Q)(−1)` at `q = 1`.  Thus
the zeta-regularised residue is additive under disjoint unions of graded objects. -/
theorem circleIntegral_of_eventually_polynomial_add {a b : ℕ → ℂ} {P Q : Polynomial ℂ}
    {N M : ℕ} (ha : ∀ n, N ≤ n → a n = P.eval (n : ℂ)) (hb : ∀ n, M ≤ n → b n = Q.eval (n : ℂ))
    {H : ℂ → ℂ} (hH : AnalyticOnNhd ℂ H {(1 : ℂ)}ᶜ)
    (hH0 : ∀ᶠ q in 𝓝 (0 : ℂ), H q = ∑' n : ℕ, (a n + b n) * q ^ n)
    {ρ : ℝ} (hρ : 0 < ρ) :
    (∮ z in C((1 : ℂ), ρ), H z)
      = -(P.eval (-1) + Q.eval (-1)) * (2 * (Real.pi : ℂ) * I) := by
  have hcoef : ∀ n, max N M ≤ n → a n + b n = (P + Q).eval (n : ℂ) := by
    intro n hn
    rw [ha n (le_trans (le_max_left _ _) hn), hb n (le_trans (le_max_right _ _) hn), eval_add]
  rw [circleIntegral_of_eventually_polynomial hcoef hH hH0 hρ, eval_add]

/-! ### Rigidity: the residue spectrum of an eventually periodic grade count -/

section Spectrum

variable {m : ℕ} {zeta : ℂ}

theorem fourierAmp_add (zeta : ℂ) (c c' : ℕ → ℂ) (m k : ℕ) :
    fourierAmp zeta (fun j => c j + c' j) m k
      = fourierAmp zeta c m k + fourierAmp zeta c' m k := by
  simp only [fourierAmp, mul_add, Finset.sum_add_distrib]

/-- **Fourier inversion as rigidity.**  Two periods with the same discrete Fourier transform
coincide. -/
theorem eq_of_fourierAmp_eq (hm : 0 < m) (hz : IsPrimitiveRoot zeta m) {c c' : ℕ → ℂ}
    (hamp : ∀ k : Fin m, fourierAmp zeta c m (k : ℕ) = fourierAmp zeta c' m (k : ℕ))
    {j : ℕ} (hj : j < m) : c j = c' j := by
  have hcj : c j = c (j % m) := by rw [Nat.mod_eq_of_lt hj]
  have hcj' : c' j = c' (j % m) := by rw [Nat.mod_eq_of_lt hj]
  rw [hcj, hcj', periodic_eq_fourier_sum hm hz c j, periodic_eq_fourier_sum hm hz c' j]
  exact Finset.sum_congr rfl fun k _ => by rw [hamp k]

/-- If two sequences are eventually periodic mod `m` with the same Fourier data, they agree
for all large indices. -/
theorem eventuallyEq_of_fourierAmp_eq (hm : 0 < m) (hz : IsPrimitiveRoot zeta m)
    {c c' a b : ℕ → ℂ} {N M : ℕ} (ha : ∀ n, N ≤ n → a n = c (n % m))
    (hb : ∀ n, M ≤ n → b n = c' (n % m))
    (hamp : ∀ k : Fin m, fourierAmp zeta c m (k : ℕ) = fourierAmp zeta c' m (k : ℕ))
    {n : ℕ} (hn : max N M ≤ n) : a n = b n := by
  rw [ha n (le_trans (le_max_left _ _) hn), hb n (le_trans (le_max_right _ _) hn)]
  exact eq_of_fourierAmp_eq hm hz hamp (Nat.mod_lt _ hm)

/-- **Reading the Fourier amplitude off the residue.**  The `k`-th Fourier amplitude of the
period of an eventually periodic grade count is recovered from the contour integral of any
analytic continuation around the pole `ζ^{-k}`. -/
theorem fourierAmp_eq_of_circleIntegral (hm : 0 < m) (hz : IsPrimitiveRoot zeta m)
    {c a : ℕ → ℂ} {N : ℕ} (ha : ∀ n, N ≤ n → a n = c (n % m)) {F : ℂ → ℂ}
    (hF : AnalyticOnNhd ℂ F (twistPoles fun k : Fin m => zeta ^ (k : ℕ))ᶜ)
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, a n * q ^ n)
    {ρ : ℝ} (hρ : 0 < ρ) (k : Fin m)
    (hsep : ∀ i : Fin m, i ≠ k → ρ < dist ((zeta ^ (k : ℕ))⁻¹) ((zeta ^ (i : ℕ))⁻¹)) :
    fourierAmp zeta c m (k : ℕ)
      = -(zeta ^ (k : ℕ)) * (∮ z in C((zeta ^ (k : ℕ))⁻¹, ρ), F z) / (2 * (Real.pi : ℂ) * I) := by
  have hFk := circleIntegral_eventually_periodic_mod hm hz ha hF hF0 k hρ hsep
  have hzk : zeta ^ (k : ℕ) ≠ 0 := root_pow_ne_zero hm hz (k : ℕ)
  rw [hFk]
  field_simp

/-- The residues at the `m`-th roots of unity determine the Fourier amplitudes. -/
theorem fourierAmp_eq_of_circleIntegral_eq (hm : 0 < m) (hz : IsPrimitiveRoot zeta m)
    {c c' a b : ℕ → ℂ} {N M : ℕ} (ha : ∀ n, N ≤ n → a n = c (n % m))
    (hb : ∀ n, M ≤ n → b n = c' (n % m))
    {F G : ℂ → ℂ}
    (hF : AnalyticOnNhd ℂ F (twistPoles fun k : Fin m => zeta ^ (k : ℕ))ᶜ)
    (hG : AnalyticOnNhd ℂ G (twistPoles fun k : Fin m => zeta ^ (k : ℕ))ᶜ)
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, a n * q ^ n)
    (hG0 : ∀ᶠ q in 𝓝 (0 : ℂ), G q = ∑' n : ℕ, b n * q ^ n)
    {ρ : ℝ} (hρ : 0 < ρ)
    (hsep : ∀ k i : Fin m, i ≠ k → ρ < dist ((zeta ^ (k : ℕ))⁻¹) ((zeta ^ (i : ℕ))⁻¹))
    (hres : ∀ k : Fin m, (∮ z in C((zeta ^ (k : ℕ))⁻¹, ρ), F z)
      = ∮ z in C((zeta ^ (k : ℕ))⁻¹, ρ), G z) (k : Fin m) :
    fourierAmp zeta c m (k : ℕ) = fourierAmp zeta c' m (k : ℕ) := by
  rw [fourierAmp_eq_of_circleIntegral hm hz ha hF hF0 hρ k (hsep k),
    fourierAmp_eq_of_circleIntegral hm hz hb hG hG0 hρ k (hsep k), hres k]

/-- **The residue spectrum is a complete invariant of the periodic grade germ.**  Two graded
objects whose grade counts are eventually periodic mod `m` and which have the same residue at
every `m`-th root of unity have the same grade counts in all sufficiently large grades.  (The
converse implication is `circleIntegral_eventually_periodic_mod` applied twice.) -/
theorem eventuallyEq_of_residueSpectrum_eq (hm : 0 < m) (hz : IsPrimitiveRoot zeta m)
    {c c' a b : ℕ → ℂ} {N M : ℕ} (ha : ∀ n, N ≤ n → a n = c (n % m))
    (hb : ∀ n, M ≤ n → b n = c' (n % m))
    {F G : ℂ → ℂ}
    (hF : AnalyticOnNhd ℂ F (twistPoles fun k : Fin m => zeta ^ (k : ℕ))ᶜ)
    (hG : AnalyticOnNhd ℂ G (twistPoles fun k : Fin m => zeta ^ (k : ℕ))ᶜ)
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, a n * q ^ n)
    (hG0 : ∀ᶠ q in 𝓝 (0 : ℂ), G q = ∑' n : ℕ, b n * q ^ n)
    {ρ : ℝ} (hρ : 0 < ρ)
    (hsep : ∀ k i : Fin m, i ≠ k → ρ < dist ((zeta ^ (k : ℕ))⁻¹) ((zeta ^ (i : ℕ))⁻¹))
    (hres : ∀ k : Fin m, (∮ z in C((zeta ^ (k : ℕ))⁻¹, ρ), F z)
      = ∮ z in C((zeta ^ (k : ℕ))⁻¹, ρ), G z) :
    ∀ n, max N M ≤ n → a n = b n := fun n hn =>
  eventuallyEq_of_fourierAmp_eq (n := n) hm hz ha hb
    (fourierAmp_eq_of_circleIntegral_eq hm hz ha hb hF hG hF0 hG0 hρ hsep hres) hn

/-- **No phantom periodic grade germs.**  If an eventually periodic grade count does *not*
vanish eventually, then some `m`-th root of unity carries a nonzero residue: the partition
function of a nontrivial eventually periodic graded object is never singularity-free on the
unit circle. -/
theorem exists_residue_ne_zero_of_not_eventually_zero (hm : 0 < m) (hz : IsPrimitiveRoot zeta m)
    {c a : ℕ → ℂ} {N : ℕ} (ha : ∀ n, N ≤ n → a n = c (n % m))
    {F : ℂ → ℂ}
    (hF : AnalyticOnNhd ℂ F (twistPoles fun k : Fin m => zeta ^ (k : ℕ))ᶜ)
    (hF0 : ∀ᶠ q in 𝓝 (0 : ℂ), F q = ∑' n : ℕ, a n * q ^ n)
    {ρ : ℝ} (hρ : 0 < ρ)
    (hsep : ∀ k i : Fin m, i ≠ k → ρ < dist ((zeta ^ (k : ℕ))⁻¹) ((zeta ^ (i : ℕ))⁻¹))
    {n : ℕ} (hn : N ≤ n) (hne : a n ≠ 0) :
    ∃ k : Fin m, (∮ z in C((zeta ^ (k : ℕ))⁻¹, ρ), F z) ≠ 0 := by
  by_contra hall
  push_neg at hall
  refine hne ?_
  have hamp : ∀ k : Fin m, fourierAmp zeta c m (k : ℕ) = 0 := by
    intro k
    rw [fourierAmp_eq_of_circleIntegral hm hz ha hF hF0 hρ k (hsep k), hall k]
    simp
  rw [ha n hn, periodic_eq_fourier_sum hm hz c n]
  refine Finset.sum_eq_zero fun k _ => ?_
  rw [hamp k, zero_mul]

end Spectrum

end Physics.GradedTransitivity