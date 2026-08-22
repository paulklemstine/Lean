/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Mathlib
import Applications.InvisibleWeightsPolynomial
import Applications.PTEIdealCharacterisation

/-!
# The polynomial form: the `ℓ¹` norm of an integer polynomial with a `K`-fold root at `1`

`Applications/InvisibleWeightsPolynomial.lean` identifies invisibility with divisibility:
a weight vector on `{0,…,N}` is invisible to the window `k < K` exactly when its generating
polynomial is divisible by `(X - 1)^K`.  Combining that bridge with the mass law of
`Applications/PTESizeNewton.lean` turns the catalog's invariant into a statement about
integer polynomials that needs no reference to weight vectors at all:

> **If `P ∈ ℤ[X]` is nonzero and `(X - 1)^K ∣ P`, then the sum of the absolute values of the
> coefficients of `P` is at least `2K`; and `2K` is attained for every `K ≤ 10` and `K = 12`.**

## Main results

* `polyMass` — the `ℓ¹` norm `∑_j |P.coeff j|` of an integer polynomial.
* `massAchievable_iff_poly` — the dictionary `MassAchievable K L ↔ ∃ P ≠ 0, (X-1)^K ∣ P ∧
  polyMass P = L`.
* `minMass_eq_poly_sInf` — hence `minMass K` *is* the minimal `ℓ¹` norm of a nonzero integer
  polynomial with a `K`-fold root at `1`.
* `polyMass_ge_two_mul` — **the polynomial form of the Newton bound.**
* `polyMass_sharp` — sharpness for `K ≤ 10` and `K = 12`.
* `exists_poly_of_small_mass` — the converse reading used as a certificate: a polynomial of
  `ℓ¹` norm `2K` with a `K`-fold root at `1` yields an ideal Prouhet–Tarry–Escott pair.

-- !-- Lab Notes -- !--

HYPOTHESIS (Hypothesizer).  The catalog invariant `minMass` should coincide with a quantity
studied independently of power sums, namely the least coefficient-`ℓ¹` norm of an integer
polynomial divisible by `(X-1)^K`.  If so, all the bounds proved for one transfer to the
other for free.

EXPERIMENT (Experimenter).  Proved: the two extremal problems have *identical* value sets
(`massAchievable_iff_poly`), not merely equal minima.  The proof needs a small amount of
care at the boundary `K > N`, where invisibility already forces the vector to vanish.

ANALYSIS (Analyst).  The dictionary explains the exponential witnesses structurally:
`(X-1)^K` itself has `ℓ¹` norm `2^K`, and products of sparse factors such as
`∏ (X^{a_i} - 1)` are what convolution produces.  Minimising `ℓ¹` over the ideal
`((X-1)^K)` is therefore a question about how much cancellation is available in such
products — the same question the ideal PTE problem asks in arithmetic language.

CRITIQUE (Critic).  `polyMass` is defined by a sum over `range (natDegree P + 1)`, which for
`P = 0` gives `0`; every statement therefore carries `P ≠ 0`, and none is vacuous.  The
dictionary is an honest equivalence of *sets of achievable values*, so nothing is smuggled
in by taking infima of different sets.
-/

open Finset Polynomial

namespace PTEPoly

open PowerSumSharpness InvisibleWeights PTESize PTEWitness PTERigid PTEIdeal

/-- The `ℓ¹` norm of an integer polynomial: the sum of the absolute values of its
coefficients. -/
def polyMass (P : ℤ[X]) : ℕ := ∑ j ∈ range (P.natDegree + 1), (P.coeff j).natAbs

lemma polyMass_eq_sum_range {P : ℤ[X]} {N : ℕ} (hN : P.natDegree ≤ N) :
    ((polyMass P : ℕ) : ℤ) = ∑ j ∈ range (N + 1), |P.coeff j| := by
  have hsub : range (P.natDegree + 1) ⊆ range (N + 1) := by
    intro x hx
    simp only [Finset.mem_range] at hx ⊢
    omega
  have hzero : ∀ j ∈ range (N + 1), j ∉ range (P.natDegree + 1) → |P.coeff j| = 0 := by
    intro j _ hj
    have hjd : P.natDegree < j := by
      simp only [Finset.mem_range, not_lt] at hj
      omega
    rw [Polynomial.coeff_eq_zero_of_natDegree_lt hjd, abs_zero]
  rw [← Finset.sum_subset hsub hzero, polyMass, Nat.cast_sum]
  exact Finset.sum_congr rfl fun j _ => (Int.abs_eq_natAbs _).symm

lemma weightPoly_coeff_self {P : ℤ[X]} {N : ℕ} (hN : P.natDegree ≤ N) :
    weightPoly N (fun j => P.coeff j) = P := by
  ext j
  rcases le_or_gt j N with hj | hj
  · rw [coeff_weightPoly N _ hj]
  · rw [Polynomial.coeff_eq_zero_of_natDegree_lt
      (lt_of_le_of_lt (natDegree_weightPoly_le N _) hj),
      Polynomial.coeff_eq_zero_of_natDegree_lt (by omega)]

/-- If a nonzero vector is invisible to the window `k < K` on the nodes `{0,…,N}`, then
necessarily `K ≤ N + 1`: the Lagrange engine leaves no room for a longer window. -/
lemma window_le_of_nonzero {N K : ℕ} {e : ℕ → ℤ} (he : Invisible N K e)
    {j₀ : ℕ} (hj₀ : j₀ ≤ N) (hne : e j₀ ≠ 0) : K ≤ N + 1 := by
  by_contra hcon
  push_neg at hcon
  exact hne (eq_zero_of_moments_zero_int (fun k hk => he k (by omega)) j₀ hj₀)

/-! ## The dictionary -/

theorem massAchievable_iff_poly (K L : ℕ) :
    MassAchievable K L ↔ ∃ P : ℤ[X], P ≠ 0 ∧ (X - 1 : ℤ[X]) ^ K ∣ P ∧ polyMass P = L := by
  constructor
  · rintro ⟨N, e, hinv, ⟨j₀, hj₀, hne⟩, hmass⟩
    set f := trunc N e with hf
    have hfinv : Invisible N K f := invisible_trunc hinv
    have hfne : f j₀ ≠ 0 := by rwa [hf, trunc, if_pos hj₀]
    have hKN : K ≤ N + 1 := window_le_of_nonzero hfinv hj₀ hfne
    refine ⟨weightPoly N f, ?_, (invisible_iff_dvd_int hKN f).mp hfinv, ?_⟩
    · intro hzero
      exact hfne (by rw [← coeff_weightPoly N f hj₀, hzero, Polynomial.coeff_zero])
    · have hdeg : (weightPoly N f).natDegree ≤ N := natDegree_weightPoly_le N f
      have hsum : ∑ j ∈ range (N + 1), |(weightPoly N f).coeff j| = (L : ℤ) := by
        rw [← hmass]
        refine Finset.sum_congr rfl fun j hj => ?_
        have hjN : j ≤ N := Nat.lt_succ_iff.mp (mem_range.mp hj)
        rw [coeff_weightPoly N f hjN, hf, trunc, if_pos hjN]
      have := polyMass_eq_sum_range hdeg
      rw [hsum] at this
      exact_mod_cast this
  · rintro ⟨P, hP, hdvd, hmass⟩
    set N := max P.natDegree K with hN
    have hdeg : P.natDegree ≤ N := le_max_left _ _
    have hKN : K ≤ N + 1 := by
      have hKmax : K ≤ N := le_max_right _ _
      omega
    set e : ℕ → ℤ := fun j => P.coeff j with he
    have hwp : weightPoly N e = P := weightPoly_coeff_self hdeg
    have hinv : Invisible N K e := invisible_of_dvd hKN (by rw [hwp]; exact hdvd)
    refine ⟨N, e, hinv, ⟨P.natDegree, hdeg, ?_⟩, ?_⟩
    · exact Polynomial.leadingCoeff_ne_zero.mpr hP
    · rw [← hmass]
      exact (polyMass_eq_sum_range hdeg).symm

/-- **`minMass` is the minimal coefficient-`ℓ¹` norm of a nonzero integer polynomial with a
`K`-fold root at `1`.** -/
theorem minMass_eq_poly_sInf (K : ℕ) :
    minMass K = sInf {L | ∃ P : ℤ[X], P ≠ 0 ∧ (X - 1 : ℤ[X]) ^ K ∣ P ∧ polyMass P = L} := by
  have hset : {L | MassAchievable K L}
      = {L : ℕ | ∃ P : ℤ[X], P ≠ 0 ∧ (X - 1 : ℤ[X]) ^ K ∣ P ∧ polyMass P = L} :=
    Set.ext fun L => massAchievable_iff_poly K L
  rw [show minMass K = sInf {L | MassAchievable K L} from rfl, hset]

/-! ## The polynomial form of the two main results -/

/-- **The Newton bound for polynomials.**  A nonzero integer polynomial divisible by
`(X - 1)^K` has coefficient-`ℓ¹` norm at least `2K`. -/
theorem polyMass_ge_two_mul {K : ℕ} {P : ℤ[X]} (hP : P ≠ 0) (hdvd : (X - 1 : ℤ[X]) ^ K ∣ P) :
    2 * K ≤ polyMass P := by
  have hach : MassAchievable K (polyMass P) :=
    (massAchievable_iff_poly K (polyMass P)).mpr ⟨P, hP, hdvd, rfl⟩
  have h1 : minMass K ≤ polyMass P := minMass_le hach
  have h2 : 2 * K ≤ minMass K := two_mul_le_minMass K
  omega

/-- **Sharpness.**  For every `K ≤ 10` and for `K = 12` there is a nonzero integer polynomial
divisible by `(X - 1)^K` whose coefficient-`ℓ¹` norm is exactly `2K`. -/
theorem polyMass_sharp {K : ℕ} (hK : 1 ≤ K) (hK' : K ≤ 10 ∨ K = 12) :
    ∃ P : ℤ[X], P ≠ 0 ∧ (X - 1 : ℤ[X]) ^ K ∣ P ∧ polyMass P = 2 * K := by
  have h : MassAchievable K (2 * K) := by
    have := minMass_eq_two_mul hK hK'
    rw [← this]
    exact minMass_mem K
  exact (massAchievable_iff_poly K (2 * K)).mp h

/-- A polynomial certificate for an ideal Prouhet–Tarry–Escott pair: `ℓ¹` norm `2K` with a
`K`-fold root at `1` produces the configuration. -/
theorem exists_poly_of_small_mass {K : ℕ} {P : ℤ[X]} (hP : P ≠ 0)
    (hdvd : (X - 1 : ℤ[X]) ^ K ∣ P) (hmass : polyMass P = 2 * K) : IdealPair K := by
  have hach : MassAchievable K (2 * K) :=
    (massAchievable_iff_poly K (2 * K)).mpr ⟨P, hP, hdvd, hmass⟩
  exact (minMass_eq_two_mul_iff K).mp (le_antisymm (minMass_le hach) (two_mul_le_minMass K))

end PTEPoly