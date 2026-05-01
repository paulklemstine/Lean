/-! # CatalogBuild.Cryptography.SPBQuantumCrypto

Auto-generated from theorem catalog database.
Domain: Cryptography
Declarations: 22
-/

import Mathlib

noncomputable section

/-- SPB has identity element 0 -/
theorem spb_zero_right (s : ℝ) : spb s 0 = s := by
  unfold spb; simp


/-- SPB has identity element 0 (left) -/
theorem spb_zero_left (s : ℝ) : spb 0 s = s := by
  unfold spb; simp


/-- SPB inverse: the inverse of s is -s -/
theorem spb_inv (s : ℝ) : spb s (-s) = 0 := by
  unfold spb; simp


/-- Iterated SPB: apply the SPB operation n times with base g -/
noncomputable def iteratedSPB (g : ℝ) : ℕ → ℝ
  | 0 => 0
  | n + 1 => spb (iteratedSPB g n) g


/-- Iterated SPB of 1 step is just g -/
theorem iteratedSPB_one (g : ℝ) : iteratedSPB g 1 = g := by
  simp [iteratedSPB, spb_zero_left]


/-- Iterated SPB of 2 steps gives the double-angle tangent formula -/
theorem iteratedSPB_two (g : ℝ) : iteratedSPB g 2 = spb g g := by
  simp [iteratedSPB, spb_zero_left]


/-- The SPB of g with itself gives the double-angle formula 2g/(1-g²) -/
theorem spb_double (g : ℝ) : spb g g = 2 * g / (1 - g^2) := by
  unfold spb; ring


/-- Key generation: public key from private key -/
noncomputable def publicKey (g : ℝ) (secret : ℕ) : ℝ :=
  iteratedSPB g secret


/-- Shared secret computation by Alice -/
noncomputable def sharedSecretA (bobPublic : ℝ) (aliceSecret : ℕ) : ℝ :=
  iteratedSPB bobPublic aliceSecret


/-- Shared secret computation by Bob -/
noncomputable def sharedSecretB (alicePublic : ℝ) (bobSecret : ℕ) : ℝ :=
  iteratedSPB alicePublic bobSecret


/-- Both parties start from the same base value -/
theorem publicKey_zero (g : ℝ) : publicKey g 0 = 0 := by
  simp [publicKey, iteratedSPB]


/-- Public key of 1 is the generator -/
theorem publicKey_one (g : ℝ) : publicKey g 1 = g := by
  exact iteratedSPB_one g


/-- Multi-party SPB composition -/
noncomputable def multiSPB : List ℝ → ℝ
  | [] => 0
  | s :: rest => spb s (multiSPB rest)


/-- Multi-party composition with empty list is identity -/
theorem multiSPB_nil : multiSPB [] = 0 := by rfl


/-- Multi-party composition with single element -/
theorem multiSPB_singleton (s : ℝ) : multiSPB [s] = s := by
  simp [multiSPB, spb_zero_right]


/-- Multi-party composition of two elements -/
theorem multiSPB_pair (s t : ℝ) : multiSPB [s, t] = spb s t := by
  simp [multiSPB, spb_zero_right]


/-- Encode an SPB value as a quantum phase -/
noncomputable def phaseEncode (s hbar : ℝ) : ℂ :=
  Complex.exp (Complex.I * (Real.arctan s / hbar))


/-- Phase encoding of identity is 1 -/
theorem phase_encode_zero (hbar : ℝ) (hℏ : hbar ≠ 0) :
    phaseEncode 0 hbar = 1 := by
  simp [phaseEncode, Real.arctan_zero]


/-- Phase addition: exp(iθ₁) · exp(iθ₂) = exp(i(θ₁+θ₂)) -/
theorem phase_mul_exp (θ₁ θ₂ hbar : ℝ) :
    Complex.exp (Complex.I * (θ₁ / hbar)) *
    Complex.exp (Complex.I * (θ₂ / hbar)) =
    Complex.exp (Complex.I * ((θ₁ + θ₂) / hbar)) := by
  rw [← Complex.exp_add]; ring_nf


/-- [Section: ## Section 5: Quantum Phase Encoding
Encoding SPB values as quantum phases enables quantum key distribution.] -/
theorem spb_is_tan_add (s t : ℝ) (hst : s * t ≠ 1) :
    Real.tan (Real.arctan s + Real.arctan t) = spb s t := by
  rw [ Real.tan_add, Real.tan_arctan, Real.tan_arctan, spb ];
  exact Or.inl ⟨ fun k => by cases k <;> norm_num <;> rw [ eq_div_iff ] <;> nlinarith [ Real.neg_pi_div_two_lt_arctan s, Real.arctan_lt_pi_div_two s ], fun k => by cases k <;> norm_num <;> rw [ eq_div_iff ] <;> nlinarith [ Real.neg_pi_div_two_lt_arctan t, Real.arctan_lt_pi_div_two t ] ⟩


/-- SPB one-way property: composing is easy, decomposing is hard.
We formalize the easy direction: SPB is efficiently computable. -/
theorem spb_computable (s t : ℝ) (hst : 1 - s * t ≠ 0) :
    spb s t * (1 - s * t) = s + t := by
  unfold spb; field_simp


/-- SPB preserves non-degeneracy under certain conditions -/
theorem spb_nonzero (s t : ℝ) (hs : s ≠ 0) (ht : t ≠ 0) (hst : 1 - s * t ≠ 0)
    (hsum : s + t ≠ 0) :
    spb s t ≠ 0 := by
  unfold spb; exact div_ne_zero hsum hst


end
