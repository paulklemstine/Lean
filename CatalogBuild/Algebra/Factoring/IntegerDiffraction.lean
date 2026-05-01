/-! # CatalogBuild.Algebra.Factoring.IntegerDiffraction

Auto-generated from theorem catalog database.
Domain: Algebra/Factoring
Declarations: 32
-/

import Mathlib

noncomputable section

/-- The diffraction amplitude of a finite set S ⊂ ℤ at frequency θ ∈ ℝ.
This is the fundamental "wave function" — each integer in S emits a
unit-amplitude wave e^{2πisθ}, and they superpose. -/
def diffractionAmplitude (S : Finset ℤ) (θ : ℝ) : ℂ :=
  ∑ s ∈ S, Complex.exp (2 * Real.pi * s * θ * Complex.I)


/-- The diffraction intensity — the physically observable quantity.
This is the squared modulus of the amplitude. -/
def diffractionIntensity (S : Finset ℤ) (θ : ℝ) : ℝ :=
  Complex.normSq (diffractionAmplitude S θ)


/-- The autocorrelation function: counts the number of pairs (s, t) ∈ S × S
with s - t = d. This is the "difference multiset" of S. -/
def autocorrelation (S : Finset ℤ) (d : ℤ) : ℕ :=
  ((S ×ˢ S).filter (fun p => p.1 - p.2 = d)).card


/-- A set is a Sidon set (B₂ set) if all pairwise differences are distinct,
i.e., the autocorrelation is at most 1 for d ≠ 0. -/
def IsSidonSet (S : Finset ℤ) : Prop :=
  ∀ d : ℤ, d ≠ 0 → autocorrelation S d ≤ 1


/-- Two sets are "homometric" if they have the same diffraction pattern,
equivalently the same autocorrelation function. -/
def IsHomometric (S T : Finset ℤ) : Prop :=
  ∀ d : ℤ, autocorrelation S d = autocorrelation T d


/-- The diffraction amplitude of a singleton set. -/
theorem amplitude_singleton (a : ℤ) (θ : ℝ) :
    diffractionAmplitude {a} θ = Complex.exp (2 * Real.pi * a * θ * Complex.I) := by
  simp [diffractionAmplitude]


/-- [Section: # CatalogBuild.Computation.Factoring.IntegerDiffraction
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 32] -/
theorem intensity_singleton (a : ℤ) (θ : ℝ) :
    diffractionIntensity {a} θ = 1 := by
  unfold diffractionIntensity; norm_num [ Complex.normSq_eq_norm_sq, Complex.norm_exp ] ;
  exact Or.inl ( by rw [ diffractionAmplitude ] ; norm_num [ Complex.norm_exp ] )


/-- [Section: # CatalogBuild.Computation.Factoring.IntegerDiffraction
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 32] -/
theorem amplitude_pair (a b : ℤ) (hab : a ≠ b) (θ : ℝ) :
    diffractionAmplitude {a, b} θ =
    Complex.exp (2 * Real.pi * a * θ * Complex.I) +
    Complex.exp (2 * Real.pi * b * θ * Complex.I) := by
  exact Finset.sum_pair hab


/-- [Section: # CatalogBuild.Computation.Factoring.IntegerDiffraction
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 32] -/
theorem intensity_nonneg (S : Finset ℤ) (θ : ℝ) :
    0 ≤ diffractionIntensity S θ := by
  exact Complex.normSq_nonneg _


theorem intensity_at_zero (S : Finset ℤ) :
    diffractionIntensity S 0 = (S.card : ℝ) ^ 2 := by
  unfold diffractionIntensity;
  unfold diffractionAmplitude; norm_num [ Complex.normSq ] ; ring;


theorem intensity_empty (θ : ℝ) :
    diffractionIntensity ∅ θ = 0 := by
  unfold diffractionIntensity diffractionAmplitude ; norm_num


theorem amplitude_empty (θ : ℝ) :
    diffractionAmplitude (∅ : Finset ℤ) θ = 0 := by
  exact Finset.sum_empty


/-- Translate a set by an integer offset. -/
def translateSet (S : Finset ℤ) (k : ℤ) : Finset ℤ :=
  S.map ⟨(· + k), add_left_injective k⟩


theorem amplitude_translate (S : Finset ℤ) (k : ℤ) (θ : ℝ) :
    diffractionAmplitude (translateSet S k) θ =
    Complex.exp (2 * Real.pi * k * θ * Complex.I) * diffractionAmplitude S θ := by
  unfold diffractionAmplitude translateSet; simp +decide [ mul_assoc, mul_left_comm, Finset.mul_sum _ _ _ ] ; ring;
  exact Finset.sum_congr rfl fun _ _ => by rw [ ← Complex.exp_add ] ; ring;


theorem intensity_translate (S : Finset ℤ) (k : ℤ) (θ : ℝ) :
    diffractionIntensity (translateSet S k) θ = diffractionIntensity S θ := by
  unfold diffractionIntensity;
  rw [ amplitude_translate ];
  norm_num [ Complex.normSq_eq_norm_sq, Complex.norm_exp ]


theorem autocorrelation_zero (S : Finset ℤ) :
    autocorrelation S 0 = S.card := by
  unfold autocorrelation;
  rw [ Finset.card_filter ];
  erw [ Finset.sum_product ];
  simp +decide [ sub_eq_zero ]


theorem autocorrelation_singleton_zero (a : ℤ) :
    autocorrelation {a} 0 = 1 := by
  exact autocorrelation_zero _


theorem autocorrelation_singleton_ne (a : ℤ) (d : ℤ) (hd : d ≠ 0) :
    autocorrelation {a} d = 0 := by
  unfold autocorrelation; aesop;


theorem sidon_singleton (a : ℤ) : IsSidonSet {a} := by
  -- For any d ≠ 0, the autocorrelation is zero, which is ≤ 1.
  intros d hd
  simp [IsSidonSet, autocorrelation_singleton_ne a d hd]


theorem sidon_pair (a b : ℤ) (hab : a ≠ b) : IsSidonSet {a, b} := by
  -- Assume a ≠ b. Let d ∈ ℤ be non-zero.
  by_contra h;
  unfold IsSidonSet at h;
  simp_all +decide [ Finset.filter_insert, Finset.filter_singleton, autocorrelation ];
  obtain ⟨ x, hx₁, hx₂ ⟩ := h; rw [ Finset.card_filter ] at hx₂; simp_all +decide [ Finset.sum ] ;
  grind +ring


/-- The cross-amplitude between two sets. -/
def crossAmplitude (S T : Finset ℤ) (θ : ℝ) : ℂ :=
  ∑ s ∈ S, ∑ t ∈ T, Complex.exp (2 * Real.pi * (↑(s - t) : ℝ) * θ * Complex.I)


theorem amplitude_disjoint_union (S T : Finset ℤ) (h : Disjoint S T) (θ : ℝ) :
    diffractionAmplitude (S ∪ T) θ =
    diffractionAmplitude S θ + diffractionAmplitude T θ := by
  exact Finset.sum_union h


/-- Reflect a set through the origin. -/
def reflectSet (S : Finset ℤ) : Finset ℤ :=
  S.map ⟨fun x => -x, neg_injective⟩


theorem intensity_reflect (S : Finset ℤ) (θ : ℝ) :
    diffractionIntensity (reflectSet S) θ = diffractionIntensity S θ := by
  unfold diffractionIntensity diffractionAmplitude reflectSet;
  norm_num [ Complex.normSq, Complex.ext_iff, Finset.sum_neg_distrib ];
  norm_num [ Complex.exp_re, Complex.exp_im ]


/-- A prime is "light" if it is ≡ 1 (mod 4). -/
def IsLightPrime (p : ℕ) : Prop := Nat.Prime p ∧ p % 4 = 1


/-- A prime is "dark" if it is ≡ 3 (mod 4). -/
def IsDarkPrime (p : ℕ) : Prop := Nat.Prime p ∧ p % 4 = 3


/-- A set has "spiked diffraction" if its autocorrelation is concentrated
on a few values. Formalized: the support of the autocorrelation
(restricted to nonzero d) has size at most k. -/
def HasSpikedDiffraction (S : Finset ℤ) (k : ℕ) : Prop :=
  ((S ×ˢ S).image (fun p => p.1 - p.2) |>.filter (· ≠ 0)).card ≤ k


/-- Compute the autocorrelation of a finite set at a given difference. -/
def autocorrelationCompute (S : List ℤ) (d : ℤ) : ℕ :=
  (S.product S).countP (fun p => p.1 - p.2 = d)

-- Two-photon experiment: {0, 1}
#eval autocorrelationCompute [0, 1] 0     -- Expected: 2
#eval autocorrelationCompute [0, 1] 1     -- Expected: 1
#eval autocorrelationCompute [0, 1] (-1)  -- Expected: 1
#eval autocorrelationCompute [0, 1] 2     -- Expected: 0

-- Three-photon experiment: {0, 1, 3} — a Sidon set
#eval autocorrelationCompute [0, 1, 3] 0    -- Expected: 3
#eval autocorrelationCompute [0, 1, 3] 1    -- Expected: 1
#eval autocorrelationCompute [0, 1, 3] 2    -- Expected: 1
#eval autocorrelationCompute [0, 1, 3] 3    -- Expected: 1

-- Non-Sidon set: {0, 1, 2, 3}
#eval autocorrelationCompute [0, 1, 2, 3] 1  -- Expected: 3 (repeated difference!)

-- Light primes up to 30: {5, 13, 17, 29}
#eval autocorrelationCompute [5, 13, 17, 29] 0   -- 4
#eval autocorrelationCompute [5, 13, 17, 29] 8   -- 1 (13-5)
#eval autocorrelationCompute [5, 13, 17, 29] 12  -- 2 (17-5 and 29-17)
#eval autocorrelationCompute [5, 13, 17, 29] 4   -- 1 (17-13)
#eval autocorrelationCompute [5, 13, 17, 29] 16  -- 1 (29-13)
#eval autocorrelationCompute [5, 13, 17, 29] 24  -- 1 (29-5)

-- Dark primes up to 20: {3, 7, 11, 19}
#eval autocorrelationCompute [3, 7, 11, 19] 4  -- 2 (7-3 and 11-7)
-- Dark primes have repeated differences — they cohere.


/-- Homometricity is reflexive. -/
theorem homometric_refl (S : Finset ℤ) : IsHomometric S S := fun _ => rfl


/-- Homometricity is symmetric. -/
theorem homometric_symm {S T : Finset ℤ} (h : IsHomometric S T) :
    IsHomometric T S := fun d => (h d).symm


/-- Homometricity is transitive. -/
theorem homometric_trans {S T U : Finset ℤ} (h1 : IsHomometric S T)
    (h2 : IsHomometric T U) : IsHomometric S U :=
  fun d => (h1 d).trans (h2 d)


theorem homometric_card {S T : Finset ℤ} (h : IsHomometric S T) :
    S.card = T.card := by
  -- By definition of homometricity, the autocorrelations at 0 are equal.
  have h_autocorrelation_zero : autocorrelation S 0 = autocorrelation T 0 := by
    exact h 0;
  rw [ ← autocorrelation_zero S, ← autocorrelation_zero T, h_autocorrelation_zero ]


end
