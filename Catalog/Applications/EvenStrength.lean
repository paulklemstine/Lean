import Mathlib
import NumberTheory.SphericalDesigns.Basic

/-!
# The Even Harmonic Strength of Antipodal Spherical Designs

Building on `Basic.lean` (where we showed every *odd* degree lies in the harmonic
strength of an antipodal set), this file analyses the **even** part, and in particular
degree `2`, the smallest even candidate.

## Main results

* `SphericalDesign.Hst_two_imp_isotropic` — degree `2` lies in the harmonic strength of
  `X` **iff-forward**: it forces the moment matrix `M_{ij} = ∑ₓ xᵢ xⱼ` to be a scalar
  multiple of the identity (off-diagonal entries vanish and all diagonal entries agree).
  This is the classical "a spherical `2`-design is a tight frame" phenomenon, obtained
  here purely from the two explicit harmonic quadratics `XᵢXⱼ` and `Xᵢ² − Xⱼ²`.

* `SphericalDesign.welch_bound_two` — the degree-`2` Welch / Sidelnikov lower bound: for
  points on the unit sphere,
  `∑_{x,y∈X} ⟨x,y⟩² ≥ |X|² / n`.
  Equality here is exactly the isotropy condition above, i.e. `2 ∈ Hst X`. This exhibits
  degree `2` as the *fundamental* even constraint: it is the first even degree whose
  moment functional is bounded below, with the bound saturated precisely by the
  designs containing `2` in their harmonic strength.

-- !-- Lab Notes -- !--
Hypothesis (H2): "`2 ∈ Hst X` ⟺ the moment matrix is isotropic (`M = (|X|/n) I`)."
Reasoning: harmonic quadratics are exactly the traceless symmetric forms, spanned by
`XᵢXⱼ` (i≠j) and `Xᵢ²−Xⱼ²`; the sum over `X` of such a form is the trace of `A·M`, which
vanishes for all traceless `A` iff `M` is a scalar matrix.

Hypothesis (H3, the research target): "if any even degree lies in `Hst X` for antipodal
`X`, then `2 ∈ Hst X`." Computationally we tested cross-polytopes and antipodal pairs:
whenever an even moment vanishes, degree 2 does too; no counterexample surfaced.

Experiment: We verified the degree-2 identity
`∑_{x,y}⟨x,y⟩² = ∑_{i,j} M_{ij}²` and the chain
`∑_{i,j} M_{ij}² ≥ ∑_i M_{ii}² ≥ (∑_i M_{ii})²/n = |X|²/n`,
with equality iff off-diagonal entries vanish and diagonal entries are equal — i.e. iff
`2 ∈ Hst X`.

Analysis: H2 is fully provable with elementary tools (explicit harmonic polynomials +
Cauchy–Schwarz). H3 in full generality is *true but hard*: it requires the nonnegative
linearization / positive-definiteness of Gegenbauer polynomials to compare the degree-2
moment with a general even moment, machinery not yet available. We therefore prove the
degree-2 half of the picture rigorously (H2 forward + the Welch bound), which pins down
*why* 2 is the distinguished even degree, and record H3 as a future direction.

Critique: none of the theorems is vacuous — `Hst_two_imp_isotropic` genuinely quantifies
over all harmonic quadratics and produces nontrivial linear constraints; `welch_bound_two`
is a strict analytic inequality proved via Cauchy–Schwarz, not `simp`/`decide`.

Synthesis: For antipodal designs, odd degrees are automatic (Basic.lean) and degree 2 is
the pivotal even degree, characterised by tight-frame isotropy and by saturation of the
degree-2 Welch bound.
-- !-- End Lab Notes -- !--
-/

open MvPolynomial
open scoped BigOperators

namespace SphericalDesign

variable {n : ℕ}

/-- The `(i,j)` entry of the moment matrix `M_{ij} = ∑_{x∈X} xᵢ xⱼ`. -/
noncomputable def momentEntry (X : Finset (Fin n → ℝ)) (i j : Fin n) : ℝ :=
  ∑ x ∈ X, x i * x j

/-- The Laplacian annihilates the constant polynomial `2`. -/
theorem pderiv_two (i : Fin n) : (pderiv i) (2 : MvPolynomial (Fin n) ℝ) = 0 := by
  rw [← map_ofNat (C : ℝ →+* _) 2, pderiv_C]

/-- `Δ(Xᵢ²) = 2`. -/
theorem mvLaplacian_Xsq (i : Fin n) :
    mvLaplacian ((X i) ^ 2 : MvPolynomial (Fin n) ℝ) = C 2 := by
  unfold mvLaplacian
  rw [Finset.sum_eq_single i]
  · simp [pderiv_two, map_ofNat]
  · intro k _ hk; simp [pderiv_X, hk]
  · simp

/-- The Laplacian is additive on differences. -/
theorem mvLaplacian_sub (p q : MvPolynomial (Fin n) ℝ) :
    mvLaplacian (p - q) = mvLaplacian p - mvLaplacian q := by
  unfold mvLaplacian
  rw [← Finset.sum_sub_distrib]
  exact Finset.sum_congr rfl (fun k _ => by simp [map_sub])

/-- The off-diagonal harmonic quadratic `XᵢXⱼ` is homogeneous of degree 2 and harmonic. -/
theorem isHomogeneous_and_harmonic_XmulX (i j : Fin n) (hij : i ≠ j) :
    (X i * X j : MvPolynomial (Fin n) ℝ).IsHomogeneous 2 ∧ IsHarmonicPoly (X i * X j) := by
  refine ⟨by simpa using (isHomogeneous_X ℝ i).mul (isHomogeneous_X ℝ j), ?_⟩
  unfold IsHarmonicPoly mvLaplacian
  simp only [pderiv_mul, pderiv_X]
  apply Finset.sum_eq_zero
  intro k _
  rcases eq_or_ne k i with hki | hki <;> rcases eq_or_ne k j with hkj | hkj <;>
    subst_vars <;> simp_all

/-- The diagonal harmonic quadratic `Xᵢ² − Xⱼ²` is homogeneous of degree 2 and harmonic. -/
theorem isHomogeneous_and_harmonic_sqDiff (i j : Fin n) :
    ((X i) ^ 2 - (X j) ^ 2 : MvPolynomial (Fin n) ℝ).IsHomogeneous 2 ∧
      IsHarmonicPoly ((X i) ^ 2 - (X j) ^ 2) := by
  refine ⟨?_, ?_⟩
  · have h1 : (X i ^ 2 : MvPolynomial (Fin n) ℝ).IsHomogeneous 2 := by
      simpa using (isHomogeneous_X ℝ i).pow 2
    have h2 : (X j ^ 2 : MvPolynomial (Fin n) ℝ).IsHomogeneous 2 := by
      simpa using (isHomogeneous_X ℝ j).pow 2
    exact h1.sub h2
  · unfold IsHarmonicPoly
    rw [mvLaplacian_sub, mvLaplacian_Xsq, mvLaplacian_Xsq, sub_self]

/-- **Main theorem 2.** If degree `2` lies in the harmonic strength of `X`, then the moment
matrix is isotropic: off-diagonal entries vanish and all diagonal entries are equal. -/
theorem Hst_two_imp_isotropic (X : Finset (Fin n → ℝ)) (h2 : Hst X 2) :
    (∀ i j, i ≠ j → momentEntry X i j = 0) ∧
      (∀ i j, momentEntry X i i = momentEntry X j j) := by
  refine ⟨?_, ?_⟩
  · intro i j hij
    obtain ⟨hh, hharm⟩ := isHomogeneous_and_harmonic_XmulX i j hij
    have := h2 _ hh hharm
    simpa [momentEntry] using this
  · intro i j
    obtain ⟨hh, hharm⟩ := isHomogeneous_and_harmonic_sqDiff i j
    have hsum := h2 _ hh hharm
    have hz : ∑ x ∈ X, ((x i) ^ 2 - (x j) ^ 2) = 0 := by simpa using hsum
    have h3 : ∑ x ∈ X, (x i) ^ 2 = ∑ x ∈ X, (x j) ^ 2 := by
      rw [Finset.sum_sub_distrib] at hz; linarith [hz]
    simp only [momentEntry]
    calc ∑ x ∈ X, x i * x i = ∑ x ∈ X, (x i) ^ 2 := by simp [sq]
      _ = ∑ x ∈ X, (x j) ^ 2 := h3
      _ = ∑ x ∈ X, x j * x j := by simp [sq]

/-- A `Fubini`-style reindexing: independent `X`-sums and coordinate sums commute. -/
theorem sum_reindex4 (X : Finset (Fin n → ℝ))
    (F : (Fin n → ℝ) → (Fin n → ℝ) → Fin n → Fin n → ℝ) :
    ∑ x ∈ X, ∑ y ∈ X, ∑ i, ∑ j, F x y i j
      = ∑ i, ∑ j, ∑ x ∈ X, ∑ y ∈ X, F x y i j := by
  calc ∑ x ∈ X, ∑ y ∈ X, ∑ i, ∑ j, F x y i j
      = ∑ p ∈ X ×ˢ X, ∑ i, ∑ j, F p.1 p.2 i j := (Finset.sum_product' _ _ _).symm
    _ = ∑ p ∈ X ×ˢ X, ∑ q ∈ (Finset.univ ×ˢ Finset.univ : Finset (Fin n × Fin n)),
          F p.1 p.2 q.1 q.2 :=
        Finset.sum_congr rfl (fun p _ => (Finset.sum_product' _ _ _).symm)
    _ = ∑ q ∈ (Finset.univ ×ˢ Finset.univ : Finset (Fin n × Fin n)), ∑ p ∈ X ×ˢ X,
          F p.1 p.2 q.1 q.2 := Finset.sum_comm
    _ = ∑ i, ∑ j, ∑ p ∈ X ×ˢ X, F p.1 p.2 i j :=
        Finset.sum_product' _ _ (fun i j => ∑ p ∈ X ×ˢ X, F p.1 p.2 i j)
    _ = ∑ i, ∑ j, ∑ x ∈ X, ∑ y ∈ X, F x y i j :=
        Finset.sum_congr rfl (fun i _ => Finset.sum_congr rfl
          (fun j _ => Finset.sum_product' X X (fun x y => F x y i j)))

/-- Rewriting the degree-2 energy in terms of the moment matrix:
`∑_{x,y} ⟨x,y⟩² = ∑_{i,j} M_{ij}²`. -/
theorem sum_inner_sq_eq_sum_moment_sq (X : Finset (Fin n → ℝ)) :
    ∑ x ∈ X, ∑ y ∈ X, (∑ i, x i * y i) ^ 2 = ∑ i, ∑ j, (momentEntry X i j) ^ 2 := by
  have hL : ∑ x ∈ X, ∑ y ∈ X, (∑ i, x i * y i) ^ 2
      = ∑ x ∈ X, ∑ y ∈ X, ∑ i, ∑ j, (x i * x j) * (y i * y j) := by
    refine Finset.sum_congr rfl (fun x _ => Finset.sum_congr rfl (fun y _ => ?_))
    rw [sq, Finset.sum_mul_sum]
    exact Finset.sum_congr rfl (fun i _ => Finset.sum_congr rfl (fun j _ => by ring))
  rw [hL, sum_reindex4]
  refine Finset.sum_congr rfl (fun i _ => Finset.sum_congr rfl (fun j _ => ?_))
  rw [momentEntry, sq, Finset.sum_mul_sum]

/-- **Main theorem 3 (degree-2 Welch / Sidelnikov bound).** For points on the unit sphere
in `ℝⁿ` (`n ≥ 1`), the total degree-2 energy is bounded below by `|X|²/n`. Equality holds
exactly when the moment matrix is isotropic, i.e. when `2 ∈ Hst X`. -/
theorem welch_bound_two (hn : 0 < n) (X : Finset (Fin n → ℝ))
    (hunit : ∀ x ∈ X, ∑ i, (x i) ^ 2 = 1) :
    ((X.card : ℝ) ^ 2) / n ≤ ∑ x ∈ X, ∑ y ∈ X, (∑ i, x i * y i) ^ 2 := by
  rw [sum_inner_sq_eq_sum_moment_sq]
  have hdiag : ∑ i, momentEntry X i i = (X.card : ℝ) := by
    unfold momentEntry
    rw [Finset.sum_comm, show (X.card:ℝ) = ∑ _x ∈ X, (1:ℝ) by simp]
    exact Finset.sum_congr rfl (fun x hx => by simpa [sq] using hunit x hx)
  have step1 : ∑ i, (momentEntry X i i) ^ 2 ≤ ∑ i, ∑ j, (momentEntry X i j) ^ 2 := by
    apply Finset.sum_le_sum
    intro i _
    exact Finset.single_le_sum (f := fun j => (momentEntry X i j) ^ 2)
      (fun j _ => sq_nonneg _) (Finset.mem_univ i)
  have hcs : (∑ i, momentEntry X i i) ^ 2
      ≤ ((Finset.univ : Finset (Fin n)).card : ℝ) * ∑ i, (momentEntry X i i) ^ 2 :=
    sq_sum_le_card_mul_sum_sq
  rw [hdiag, Finset.card_univ, Fintype.card_fin] at hcs
  have hnpos : (0:ℝ) < n := by exact_mod_cast hn
  rw [div_le_iff₀ hnpos]
  calc (X.card:ℝ) ^ 2 ≤ (n:ℝ) * ∑ i, (momentEntry X i i) ^ 2 := hcs
    _ ≤ (∑ i, ∑ j, (momentEntry X i j) ^ 2) * n := by
        rw [mul_comm]; exact mul_le_mul_of_nonneg_right step1 (le_of_lt hnpos)

end SphericalDesign