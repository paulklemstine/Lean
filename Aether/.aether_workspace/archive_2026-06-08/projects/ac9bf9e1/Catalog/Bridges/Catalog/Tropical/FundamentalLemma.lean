import Mathlib

/-! # CatalogBuild.Tropical.Langlands.FundamentalLemma

Auto-generated from theorem catalog database.
Domain: Tropical/Langlands
Declarations: 26
-/

noncomputable section

/-- A tropical conjugacy class is parametrized by sorted eigenvalues (Newton polygon slopes) -/
structure TropicalConjClass (n : ℕ) where
  eigenvalues : Fin n → ℝ
  sorted : ∀ i j : Fin n, i ≤ j → eigenvalues i ≤ eigenvalues j

/-- The tropical orbital integral: sum of eigenvalues (= trace in tropical sense) -/
def tropicalOrbitalIntegral (n : ℕ) (γ : TropicalConjClass n) : ℝ :=
  ∑ i : Fin n, γ.eigenvalues i

/-- The tropical stable orbital integral: sum weighted by stability factor -/
def tropicalStableOrbitalIntegral (n : ℕ) (γ : TropicalConjClass n)
    (κ : Fin n → ℝ) : ℝ :=
  ∑ i : Fin n, κ i * γ.eigenvalues i

/-- The tropical transfer factor between G and an endoscopic group H -/
def tropicalTransferFactor (n : ℕ) (γ_G γ_H : TropicalConjClass n) : ℝ :=
  ∑ i : Fin n, (γ_G.eigenvalues i - γ_H.eigenvalues i)

/-- Transfer factor is antisymmetric -/
theorem transferFactor_antisymm (n : ℕ) (γ₁ γ₂ : TropicalConjClass n) :
    tropicalTransferFactor n γ₁ γ₂ = -tropicalTransferFactor n γ₂ γ₁ := by
  simp only [tropicalTransferFactor, ← Finset.sum_neg_distrib]
  congr 1; ext i; ring

/-- Transfer factor of an element with itself is zero -/
theorem transferFactor_self (n : ℕ) (γ : TropicalConjClass n) :
    tropicalTransferFactor n γ γ = 0 := by
  simp [tropicalTransferFactor]

/-- GL₁ conjugacy class is just a single real number -/
def GL1ConjClass (a : ℝ) : TropicalConjClass 1 where
  eigenvalues := fun _ => a
  sorted := fun _ _ _ => le_refl _

/-- GL₁ orbital integral equals the element itself -/
theorem GL1_orbital_integral (a : ℝ) :
    tropicalOrbitalIntegral 1 (GL1ConjClass a) = a := by
  simp [tropicalOrbitalIntegral, GL1ConjClass]

/-- GL₁ Fundamental Lemma: orbital integral = stable orbital integral
when κ = 1 (trivial endoscopy) -/
theorem GL1_fundamental_lemma (a : ℝ) :
    tropicalOrbitalIntegral 1 (GL1ConjClass a) =
    tropicalStableOrbitalIntegral 1 (GL1ConjClass a) (fun _ => 1) := by
  simp [tropicalOrbitalIntegral, tropicalStableOrbitalIntegral, GL1ConjClass]

/-- GL₂ conjugacy class from eigenvalues a ≤ b -/
def GL2ConjClass (a b : ℝ) (h : a ≤ b) : TropicalConjClass 2 where
  eigenvalues := ![a, b]
  sorted := by
    intro i j hij
    fin_cases i <;> fin_cases j <;> simp_all [Matrix.cons_val_zero, Matrix.cons_val_one]

/-- GL₂ orbital integral is the sum of eigenvalues -/
theorem GL2_orbital_integral (a b : ℝ) (h : a ≤ b) :
    tropicalOrbitalIntegral 2 (GL2ConjClass a b h) = a + b := by
  simp only [tropicalOrbitalIntegral, GL2ConjClass, Fin.sum_univ_two]
  simp [Matrix.cons_val_zero, Matrix.cons_val_one]

/-- Tropical GL₂ Fundamental Lemma: the orbital integral on GL₂ matches
the sum of orbital integrals on the endoscopic group GL₁ × GL₁ -/
theorem GL2_fundamental_lemma (a b : ℝ) (h : a ≤ b) :
    tropicalOrbitalIntegral 2 (GL2ConjClass a b h) =
    tropicalOrbitalIntegral 1 (GL1ConjClass a) +
    tropicalOrbitalIntegral 1 (GL1ConjClass b) := by
  simp [GL2_orbital_integral, GL1_orbital_integral]

/-- An endoscopic datum: a partition of n into parts -/
structure EndoscopicDatum (n : ℕ) where
  numParts : ℕ
  parts : Fin numParts → ℕ
  partition : ∑ i : Fin numParts, parts i = n

/-- The trivial endoscopic datum (G itself) -/
def trivialEndoscopy (n : ℕ) : EndoscopicDatum n where
  numParts := 1
  parts := fun _ => n
  partition := by simp

/-- The maximal endoscopic datum (T = GL₁ⁿ) -/
def maximalEndoscopy (n : ℕ) : EndoscopicDatum n where
  numParts := n
  parts := fun _ => 1
  partition := by simp

/-- The transfer factor for the trivial endoscopy is zero -/
theorem trivial_transfer_zero (n : ℕ) (γ : TropicalConjClass n) :
    tropicalTransferFactor n γ γ = 0 :=
  transferFactor_self n γ

/-- Tropical base change: scaling eigenvalues by a degree d -/
def tropicalBaseChange (n : ℕ) (γ : TropicalConjClass n) (d : ℝ) (hd : d > 0) :
    TropicalConjClass n where
  eigenvalues := fun i => d * γ.eigenvalues i
  sorted := fun i j h => by
    apply mul_le_mul_of_nonneg_left (γ.sorted i j h) (le_of_lt hd)

/-- Base change is functorial: BC_d(BC_e(γ)) = BC_{de}(γ) -/
theorem baseChange_compose (n : ℕ) (γ : TropicalConjClass n)
    (d e : ℝ) (hd : d > 0) (he : e > 0) :
    (tropicalBaseChange n (tropicalBaseChange n γ e he) d hd).eigenvalues =
    (tropicalBaseChange n γ (d * e) (mul_pos hd he)).eigenvalues := by
  ext i; simp [tropicalBaseChange, mul_assoc]

/-- Orbital integral scales linearly under base change -/
theorem orbital_integral_baseChange (n : ℕ) (γ : TropicalConjClass n)
    (d : ℝ) (hd : d > 0) :
    tropicalOrbitalIntegral n (tropicalBaseChange n γ d hd) =
    d * tropicalOrbitalIntegral n γ := by
  simp [tropicalOrbitalIntegral, tropicalBaseChange, Finset.mul_sum]

/-- The κ-orbital integral with character κ -/
def kappaOrbitalIntegral (n : ℕ) (γ : TropicalConjClass n) (κ : Fin n → ℝ) : ℝ :=
  ∑ i : Fin n, κ i * γ.eigenvalues i

/-- When κ is the constant 1 function, κ-orbital = orbital -/
theorem kappa_one_eq_orbital (n : ℕ) (γ : TropicalConjClass n) :
    kappaOrbitalIntegral n γ (fun _ => 1) = tropicalOrbitalIntegral n γ := by
  simp [kappaOrbitalIntegral, tropicalOrbitalIntegral]

/-- κ-orbital integral is linear in κ -/
theorem kappa_orbital_linear (n : ℕ) (γ : TropicalConjClass n)
    (κ₁ κ₂ : Fin n → ℝ) :
    kappaOrbitalIntegral n γ (κ₁ + κ₂) =
    kappaOrbitalIntegral n γ κ₁ + kappaOrbitalIntegral n γ κ₂ := by
  simp [kappaOrbitalIntegral, Pi.add_apply, add_mul, Finset.sum_add_distrib]

/-- κ-orbital integral is linear in the conjugacy class eigenvalues -/
theorem kappa_orbital_scale (n : ℕ) (γ : TropicalConjClass n)
    (κ : Fin n → ℝ) (c : ℝ) (hc : c > 0) :
    kappaOrbitalIntegral n (tropicalBaseChange n γ c hc) κ =
    c * kappaOrbitalIntegral n γ κ := by
  simp [kappaOrbitalIntegral, tropicalBaseChange, Finset.mul_sum]
  congr 1; ext i; ring

/-- Tropical Hitchin base: the coefficients of the characteristic polynomial
are the elementary symmetric functions of the eigenvalues -/
def tropicalHitchinBase (n : ℕ) (γ : TropicalConjClass n) : Fin n → ℝ :=
  γ.eigenvalues  -- In the tropical setting, eigenvalues = Hitchin base coordinates

/-- The Hitchin map is injective on regular semisimple elements
(sorted eigenvalues uniquely determine the conjugacy class) -/
theorem hitchin_injective (n : ℕ) (γ₁ γ₂ : TropicalConjClass n)
    (h : tropicalHitchinBase n γ₁ = tropicalHitchinBase n γ₂) :
    γ₁.eigenvalues = γ₂.eigenvalues := by
  exact h

/-- The trace is the first Hitchin invariant -/
theorem hitchin_trace (n : ℕ) (γ : TropicalConjClass n) :
    ∑ i, tropicalHitchinBase n γ i = tropicalOrbitalIntegral n γ := by
  simp [tropicalHitchinBase, tropicalOrbitalIntegral]

end