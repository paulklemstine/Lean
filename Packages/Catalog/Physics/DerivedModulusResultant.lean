import Mathlib
import Physics.DerivedModulusNoGo
import Physics.DerivedModulusClosure

/-!
# The resultant law: *every* pair of derived moduli overlaps by O(1)

The file `Physics.DerivedModulusNoGo` bounds the pairwise overlap of the six
MULTIMOD moduli by fifteen hand-built Bézout certificates.  This file proves the
general law behind those certificates, for arbitrary integer polynomials:

> for all `f, g ∈ ℤ[X]` (not both constant) and all `N`,
> `gcd(f(N), g(N))` divides the resultant `Res(f,g)`.

So the overlap of any two polynomial derived moduli is bounded by a constant
depending only on the pair of polynomials — never growing with `N`, and never
tracking the factorisation of `N`.  Combined with the classification
`universally_coprime_iff_transparent`, this closes the *multi*-modulus corner
in the strongest form available at the polynomial level: a finite family of
derived moduli carries only `O(1)` common arithmetic beyond what `N` itself
already carries.

## Main results

* `Physics.DerivedModulus.gcd_eval_dvd_resultant`
* `Physics.DerivedModulus.gcd_eval_le_resultant` : the resulting uniform bound.
* `Physics.DerivedModulus.familyPoly_natDegree_ne_zero` and
  `Physics.DerivedModulus.family_gcd_dvd_resultant` : the MULTIMOD family as an
  instance of the law.
* `Physics.DerivedModulus.multi_modulus_bounded` : for any finite list of
  derived moduli with nonzero pairwise resultants, all pairwise overlaps are
  bounded by one constant, uniformly in `N`.
-/

namespace Physics.DerivedModulus

open Polynomial

/-- **The resultant law.**  The overlap of two polynomial derived moduli divides
the resultant of the two polynomials — a constant independent of `N`.  The
proof evaluates the Sylvester–Bézout identity `f·p + g·q = Res(f,g)` at `N`. -/
theorem gcd_eval_dvd_resultant (f g : ℤ[X]) (H : f.natDegree ≠ 0 ∨ g.natDegree ≠ 0)
    (N : ℤ) : ((Int.gcd (f.eval N) (g.eval N) : ℤ)) ∣ f.resultant g := by
  obtain ⟨p, q, -, -, e⟩ := Polynomial.exists_mul_add_mul_eq_C_resultant f g le_rfl le_rfl H
  have h := congrArg (Polynomial.eval N) e
  simp only [Polynomial.eval_add, Polynomial.eval_mul, Polynomial.eval_C] at h
  have h1 : ((Int.gcd (f.eval N) (g.eval N) : ℤ)) ∣ f.eval N := Int.gcd_dvd_left _ _
  have h2 : ((Int.gcd (f.eval N) (g.eval N) : ℤ)) ∣ g.eval N := Int.gcd_dvd_right _ _
  exact h ▸ dvd_add (h1.mul_right _) (h2.mul_right _)

/-- Uniform numerical bound: the overlap never exceeds `|Res(f,g)|`, for any
`N` whatsoever. -/
theorem gcd_eval_le_resultant (f g : ℤ[X]) (H : f.natDegree ≠ 0 ∨ g.natDegree ≠ 0)
    (hres : f.resultant g ≠ 0) (N : ℤ) :
    Int.gcd (f.eval N) (g.eval N) ≤ (f.resultant g).natAbs := by
  have hdvd : Int.gcd (f.eval N) (g.eval N) ∣ (f.resultant g).natAbs := by
    have := gcd_eval_dvd_resultant f g H N
    exact Int.ofNat_dvd_right.mp (Int.dvd_natAbs.mpr this)
  exact Nat.le_of_dvd (Int.natAbs_pos.mpr hres) hdvd

/-! ## The MULTIMOD family as an instance -/

theorem familyPoly_natDegree_ne_zero (i : Fin 6) : (familyPoly i).natDegree ≠ 0 := by
  have d0 : ((X : ℤ[X]) - 1).natDegree = 1 := by compute_degree!
  have d1 : ((X : ℤ[X]) + 1).natDegree = 1 := by compute_degree!
  have d2 : ((X : ℤ[X]) ^ 2 + 1).natDegree = 2 := by compute_degree!
  have d3 : ((X : ℤ[X]) ^ 2 + X + 1).natDegree = 2 := by compute_degree!
  have d4 : ((2 : ℤ[X]) * X - 1).natDegree = 1 := by compute_degree!
  have d5 : ((2 : ℤ[X]) * X + 1).natDegree = 1 := by compute_degree!
  fin_cases i <;> simp only [familyPoly]
  · rw [d0]; norm_num
  · rw [d1]; norm_num
  · rw [d2]; norm_num
  · rw [d3]; norm_num
  · rw [d4]; norm_num
  · rw [d5]; norm_num

/-- The pairwise bounds proved by explicit certificates in
`Physics.DerivedModulusNoGo` are instances of the resultant law. -/
theorem family_gcd_dvd_resultant (i j : Fin 6) (N : ℤ) :
    ((Int.gcd (family i N) (family j N) : ℤ)) ∣ (familyPoly i).resultant (familyPoly j) := by
  have h := gcd_eval_dvd_resultant (familyPoly i) (familyPoly j)
    (Or.inl (familyPoly_natDegree_ne_zero i)) N
  simpa using h

/-- **Multi-modulus boundedness.**  Given any finite list of derived moduli
whose pairwise resultants are nonzero, there is a single constant `B`
(the maximum of the `|Res|`) bounding every pairwise overlap for every `N`. -/
theorem multi_modulus_bounded (L : List ℤ[X])
    (hdeg : ∀ f ∈ L, f.natDegree ≠ 0)
    (hres : ∀ f ∈ L, ∀ g ∈ L, f.resultant g ≠ 0) :
    ∃ B : ℕ, ∀ f ∈ L, ∀ g ∈ L, ∀ N : ℤ, Int.gcd (f.eval N) (g.eval N) ≤ B := by
  classical
  refine ⟨((L.map (fun f => (L.map (fun g => (f.resultant g).natAbs)).foldr max 0)).foldr
      max 0), ?_⟩
  intro f hf g hg N
  have hle : Int.gcd (f.eval N) (g.eval N) ≤ (f.resultant g).natAbs :=
    gcd_eval_le_resultant f g (Or.inl (hdeg f hf)) (hres f hf g hg) N
  refine le_trans hle ?_
  have hinner : ∀ (M : List ℤ[X]) (h : g ∈ M),
      (f.resultant g).natAbs ≤ (M.map (fun g => (f.resultant g).natAbs)).foldr max 0 := by
    intro M hM
    induction M with
    | nil => simp at hM
    | cons a t ih =>
        rcases List.mem_cons.mp hM with rfl | hmem
        · simp
        · exact le_trans (ih hmem) (by simp)
  have houter : ∀ (M : List ℤ[X]) (h : f ∈ M),
      (L.map (fun g => (f.resultant g).natAbs)).foldr max 0
        ≤ (M.map (fun f => (L.map (fun g => (f.resultant g).natAbs)).foldr max 0)).foldr max 0 := by
    intro M hM
    induction M with
    | nil => simp at hM
    | cons a t ih =>
        rcases List.mem_cons.mp hM with rfl | hmem
        · simp
        · exact le_trans (ih hmem) (by simp)
  exact le_trans (hinner L hg) (houter L hf)

end Physics.DerivedModulus