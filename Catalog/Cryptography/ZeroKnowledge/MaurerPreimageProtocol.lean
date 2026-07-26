import Mathlib
import Cryptography.SchnorrIdentification

/-!
# Maurer's unified "preimage of a group homomorphism" Σ-protocol

Schnorr identification, Chaum–Pedersen, Okamoto, Guillou–Quisquater and many other
Σ-protocols are all special cases of a single abstract protocol, identified by Ueli Maurer:
a *proof of knowledge of a preimage of a group homomorphism* `φ`. This file formalizes
that unification in two regimes and connects it back to the catalog's
`SchnorrIdentification`.

Given a homomorphism `φ : A → B` of additive abelian groups and a public value `Y = φ x`,
the protocol is:

* commitment `t = φ r` for random `r`;
* challenge `c`;
* response `s = r + c • x`;
* verifier accepts iff `φ s = t + c • Y`.

## Two regimes

* **Known-order / field regime** (`section FieldRegime`): challenges live in a field `F`
  and `A, B` are `F`-modules with `φ` `F`-linear. Two accepting transcripts with distinct
  challenges recover `x = (c₁ − c₂)⁻¹ • (s₁ − s₂)` directly. This subsumes Schnorr,
  Okamoto and the affine-matrix extractor of `AffineSigmaExtraction`.
* **Hidden-order / integer regime** (`section HiddenOrderRegime`): challenges are integers,
  `A, B` are arbitrary additive abelian groups, and extraction succeeds whenever a *special
  preimage* `φ u = ℓ • Y` is known with `IsCoprime ℓ (c₁ − c₂)`. Via Bézout, the witness is
  `x = a • u + b • (s₁ − s₂)`. This is the regime of groups of unknown order (RSA,
  class groups, Guillou–Quisquater) where no field inverse of the challenge difference
  exists — it cannot be reached by the linear-algebra extractor.

## Main results

* `FieldRegime.completeness`, `FieldRegime.special_soundness`,
  `FieldRegime.honest_eq_sim` (perfect HVZK bijection).
* `HiddenOrder.completeness`, `HiddenOrder.special_soundness_coprime`.
* `schnorr_completeness_via_maurer`, `schnorr_special_soundness_via_maurer` — the catalog's
  Schnorr statements recovered as instances of the field regime.

-- !-- Lab Notes -- !--
Hypothesis (H2): every "linear" Σ-protocol extractor in the catalog is one instance of a
single homomorphism-preimage extractor, and the *field* assumption is not essential — only
an inverse of the challenge difference is. Experiment: replace the field inverse by a
Bézout combination using a known multiple `ℓ • Y` of the statement. Outcome: the integer
regime (`special_soundness_coprime`) proves extraction with **no division at all**, purely
from `IsCoprime ℓ (c₁ − c₂)` and `map_zsmul`. Insight: the catalog's `affineExtract1D`
(needing `(c₁−c₂)⁻¹`) is the *field specialization* `ℓ = 1, u = x` of the integer
extractor where coprimality degenerates to invertibility. Failure analysis: a first attempt
stated the integer extractor with `Nat.gcd ℓ d = 1`; converting to Bézout coefficients was
awkward, so we switched to Mathlib's `IsCoprime` which packages the Bézout identity
`a*ℓ + b*d = 1` directly and made the proof a two-line `map`/`zsmul` computation.
-/

namespace MaurerPreimage

/-! ## Field / known-order regime -/

namespace FieldRegime

variable {F : Type*} [Field F]
variable {A B : Type*} [AddCommGroup A] [Module F A] [AddCommGroup B] [Module F B]
variable (φ : A →ₗ[F] B)

/-- Acceptance predicate: `φ s = t + c • Y`. -/
def Accepts (Y t : B) (c : F) (s : A) : Prop := φ s = t + c • Y

/-- **Completeness.** The honest transcript `(t, c, s) = (φ r, c, r + c • x)` against the
public value `Y = φ x` always verifies. -/
theorem completeness (x r : A) (c : F) :
    Accepts φ (φ x) (φ r) c (r + c • x) := by
  simp only [Accepts, map_add, map_smul]

/-- **Special soundness.** Two accepting transcripts sharing commitment `t` with distinct
challenges recover a genuine preimage: `φ ((c₁ − c₂)⁻¹ • (s₁ − s₂)) = Y`. -/
theorem special_soundness (Y t : B) (c₁ c₂ : F) (s₁ s₂ : A)
    (h₁ : Accepts φ Y t c₁ s₁) (h₂ : Accepts φ Y t c₂ s₂) (hc : c₁ ≠ c₂) :
    φ ((c₁ - c₂)⁻¹ • (s₁ - s₂)) = Y := by
  have hcne : c₁ - c₂ ≠ 0 := sub_ne_zero.mpr hc
  have hdiff : φ (s₁ - s₂) = (c₁ - c₂) • Y := by
    rw [map_sub, h₁, h₂]
    simp only [Accepts] at *
    rw [sub_smul]; abel
  rw [map_smul, hdiff, smul_smul, inv_mul_cancel₀ hcne, one_smul]

/-- The simulator: choose challenge `c` and response `s` freely, back-solve the commitment
`t = φ s − c • Y`. -/
def simCommit (Y : B) (c : F) (s : A) : B := φ s - c • Y

/-- The simulated transcript always verifies, witness-free. -/
theorem sim_accepts (Y : B) (c : F) (s : A) :
    Accepts φ Y (simCommit φ Y c s) c s := by
  simp only [Accepts, simCommit, sub_add_cancel]

/-- **Perfect HVZK.** For the public value `Y = φ x`, the honest commitment on randomness
`r` equals the simulated commitment on response `s = r + c • x`. Mapping `r ↦ r + c • x` is
a bijection (`honestRespEquiv`), so honest and simulated transcripts are equidistributed. -/
theorem honest_eq_sim (x r : A) (c : F) :
    φ r = simCommit φ (φ x) c (r + c • x) := by
  simp only [simCommit, map_add, map_smul]
  abel

/-- The randomness↔response bijection `r ↦ r + c • x` underlying HVZK. -/
def honestRespEquiv (x : A) (c : F) : A ≃ A where
  toFun := fun r => r + c • x
  invFun := fun s => s - c • x
  left_inv := by intro r; simp
  right_inv := by intro s; simp

end FieldRegime

/-! ## Hidden-order / integer-challenge regime -/

namespace HiddenOrder

variable {A B : Type*} [AddCommGroup A] [AddCommGroup B]
variable (φ : A →+ B)

/-- Acceptance predicate with integer challenges: `φ s = t + c • Y`. -/
def ZAccepts (Y t : B) (c : ℤ) (s : A) : Prop := φ s = t + c • Y

/-- **Completeness (integer regime).** Honest transcript verifies in any abelian group. -/
theorem completeness (x r : A) (c : ℤ) :
    ZAccepts φ (φ x) (φ r) c (r + c • x) := by
  simp only [ZAccepts, map_add, map_zsmul]

/-- **Special soundness via a coprime special preimage.** Suppose two accepting transcripts
share commitment `t` with challenges `c₁, c₂`, and we know a *special preimage*
`φ u = ℓ • Y` with `ℓ` coprime to `c₁ − c₂`. Then a genuine preimage of `Y` is extracted as
`a • u + b • (s₁ − s₂)`, where `a, b` are Bézout coefficients of `a·ℓ + b·(c₁−c₂) = 1`.
No inverse of the challenge difference is needed, so this works in groups of unknown order. -/
theorem special_soundness_coprime (Y t : B) (c₁ c₂ : ℤ) (s₁ s₂ : A)
    (u : A) (ℓ : ℤ)
    (h₁ : ZAccepts φ Y t c₁ s₁) (h₂ : ZAccepts φ Y t c₂ s₂)
    (hu : φ u = ℓ • Y) (hcop : IsCoprime ℓ (c₁ - c₂)) :
    ∃ x : A, φ x = Y := by
  -- difference of the two acceptance equations
  have hdiff : φ (s₁ - s₂) = (c₁ - c₂) • Y := by
    rw [map_sub, h₁, h₂]
    simp only [ZAccepts] at *
    rw [sub_zsmul]; abel
  obtain ⟨a, b, hab⟩ := hcop
  refine ⟨a • u + b • (s₁ - s₂), ?_⟩
  rw [map_add, map_zsmul, map_zsmul, hu, hdiff, smul_smul, smul_smul,
    ← add_zsmul, hab, one_zsmul]

end HiddenOrder

/-! ## Schnorr as an instance of the field regime

We recover the catalog's Schnorr completeness and special-soundness statements
(`SchnorrParams`, `accepts`) from `FieldRegime`, with `φ` the `ZMod p`-linear map
`x ↦ x * g`. -/

/-- The Schnorr homomorphism `x ↦ x * g` as a `ZMod p`-linear map. -/
def schnorrHom (P : SchnorrParams) : ZMod P.p →ₗ[ZMod P.p] ZMod P.p where
  toFun := fun x => x * P.g
  map_add' := by intro a b; ring
  map_smul' := by intro a b; simp [smul_eq_mul]; ring

@[simp] theorem schnorrHom_apply (P : SchnorrParams) (x : ZMod P.p) :
    schnorrHom P x = x * P.g := rfl

/-- Schnorr completeness recovered from `FieldRegime.completeness`. -/
theorem schnorr_completeness_via_maurer (P : SchnorrParams) (x r c : ZMod P.p) :
    FieldRegime.Accepts (schnorrHom P) (P.pk x) (r * P.g) c (r + c * x) := by
  have := FieldRegime.completeness (schnorrHom P) x r c
  simpa [FieldRegime.Accepts, SchnorrParams.pk, smul_eq_mul] using this

/-- Schnorr special soundness recovered from `FieldRegime.special_soundness`: distinct
challenges with a shared commitment recover the discrete-log witness. -/
theorem schnorr_special_soundness_via_maurer (P : SchnorrParams)
    (Y t c₁ c₂ s₁ s₂ : ZMod P.p)
    (h₁ : s₁ * P.g = t + c₁ * Y) (h₂ : s₂ * P.g = t + c₂ * Y) (hc : c₁ ≠ c₂) :
    (c₁ - c₂)⁻¹ * (s₁ - s₂) * P.g = Y := by
  have hA₁ : FieldRegime.Accepts (schnorrHom P) Y t c₁ s₁ := by
    simpa [FieldRegime.Accepts, smul_eq_mul] using h₁
  have hA₂ : FieldRegime.Accepts (schnorrHom P) Y t c₂ s₂ := by
    simpa [FieldRegime.Accepts, smul_eq_mul] using h₂
  have := FieldRegime.special_soundness (schnorrHom P) Y t c₁ c₂ s₁ s₂ hA₁ hA₂ hc
  simpa [schnorrHom, smul_eq_mul, mul_assoc, sub_mul] using this

end MaurerPreimage