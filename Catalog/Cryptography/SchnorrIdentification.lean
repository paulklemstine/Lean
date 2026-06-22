import Mathlib

/-!
# The Schnorr Identification Protocol

This file formalizes the **Schnorr identification protocol**, a classic Σ-protocol, over
the additive group of a prime field `ZMod p`. We model the underlying cyclic group
additively: a fixed nonzero generator `g : ZMod p` plays the role of the group generator,
and "scalar multiplication" of a scalar by a group element is field multiplication. The
public key for a secret `x` is `pk x = x * g`.

A transcript is a triple `(t, c, s)` of commitment, challenge and response. The verifier
accepts (against public key `Y`) iff `s * g = t + c * Y`.

## Main results

* `completeness` — honest transcripts always verify.
* `special_soundness` — two accepting transcripts sharing a commitment but with distinct
  challenges allow extraction of the secret key `x = (c₁ - c₂)⁻¹ * (s₁ - s₂)`.
* `honestSimEquiv` / `hvzk_bijection` — honest-verifier zero knowledge: the simulator
  reproduces honest transcripts exactly, witnessed by an explicit bijection on the
  randomness/challenge space.
-/

/-- Public parameters of the Schnorr protocol: a prime modulus `p` together with a
nonzero generator `g` of the additive group `ZMod p`. -/
structure SchnorrParams where
  p : ℕ
  hp : Fact (Nat.Prime p)
  g : ZMod p
  hg : g ≠ 0

attribute [instance] SchnorrParams.hp

/-- Public key for secret `x`: the group element `x * g`. -/
def SchnorrParams.pk (P : SchnorrParams) (x : ZMod P.p) : ZMod P.p := x * P.g

/-- A transcript `(t, c, s)`: commitment, challenge and response. -/
abbrev Transcript (P : SchnorrParams) := ZMod P.p × ZMod P.p × ZMod P.p

/-- Verifier acceptance condition against public key `Y`: `s * g = t + c * Y`. -/
def accepts (P : SchnorrParams) (Y : ZMod P.p) (tr : Transcript P) : Prop :=
  tr.2.2 * P.g = tr.1 + tr.2.1 * Y

/-- Honest prover transcript with commitment randomness `r` and challenge `c`. -/
def honestTranscript (P : SchnorrParams) (x r c : ZMod P.p) : Transcript P :=
  (r * P.g, c, r + c * x)

/-- **Completeness.** An honest transcript always satisfies the verifier. -/
theorem completeness (P : SchnorrParams) (x r c : ZMod P.p) :
    accepts P (P.pk x) (honestTranscript P x r c) := by
  simp only [accepts, honestTranscript, SchnorrParams.pk]
  ring

/-- **Special soundness.** Given two accepting transcripts `(t, c₁, s₁)` and `(t, c₂, s₂)`
sharing the same commitment `t` but with distinct challenges `c₁ ≠ c₂`, the secret key is
extracted as `x = (c₁ - c₂)⁻¹ * (s₁ - s₂)`. -/
theorem special_soundness (P : SchnorrParams) (x : ZMod P.p)
    (t c₁ s₁ c₂ s₂ : ZMod P.p)
    (h₁ : accepts P (P.pk x) (t, c₁, s₁))
    (h₂ : accepts P (P.pk x) (t, c₂, s₂))
    (hc : c₁ ≠ c₂) :
    x = (c₁ - c₂)⁻¹ * (s₁ - s₂) := by
  simp only [accepts, SchnorrParams.pk] at h₁ h₂
  -- Subtract the two acceptance equations and group the generator on the right.
  have hcancel : (s₁ - s₂) * P.g = ((c₁ - c₂) * x) * P.g := by
    have hsub : (s₁ - s₂) * P.g = (c₁ - c₂) * (x * P.g) := by
      rw [sub_mul, h₁, h₂]; ring
    rw [hsub]; ring
  -- Cancel the nonzero generator `g`.
  have hg : s₁ - s₂ = (c₁ - c₂) * x := mul_right_cancel₀ P.hg hcancel
  -- Distinct challenges make `c₁ - c₂` invertible.
  have hcne : c₁ - c₂ ≠ 0 := sub_ne_zero.mpr hc
  field_simp
  rw [hg]
  ring

/-- Simulator transcript: pick the challenge `c` and response `s` freely, then back out a
commitment that makes the verification equation hold. -/
def simTranscript (P : SchnorrParams) (x c s : ZMod P.p) : Transcript P :=
  (s * P.g - c * P.pk x, c, s)

/-- Map from honest randomness/challenge `(r, c)` to simulator response/challenge
`(r + x * c, c)`. -/
def honestToSim (P : SchnorrParams) (x : ZMod P.p) :
    ZMod P.p × ZMod P.p → ZMod P.p × ZMod P.p := fun rc => (rc.1 + x * rc.2, rc.2)

/-- Inverse of `honestToSim`: `(s, c) ↦ (s - x * c, c)`. -/
def simToHonest (P : SchnorrParams) (x : ZMod P.p) :
    ZMod P.p × ZMod P.p → ZMod P.p × ZMod P.p := fun sc => (sc.1 - x * sc.2, sc.2)

/-- The bijection between honest randomness/challenge pairs and simulator
response/challenge pairs underlying honest-verifier zero knowledge. -/
def honestSimEquiv (P : SchnorrParams) (x : ZMod P.p) :
    (ZMod P.p × ZMod P.p) ≃ (ZMod P.p × ZMod P.p) where
  toFun := honestToSim P x
  invFun := simToHonest P x
  left_inv := by rintro ⟨r, c⟩; simp [honestToSim, simToHonest]
  right_inv := by rintro ⟨s, c⟩; simp [honestToSim, simToHonest]

/-- **Honest-verifier zero knowledge.** The honest transcript on randomness/challenge
`(r, c)` coincides with the simulated transcript on its image under `honestSimEquiv`.
Since `honestSimEquiv` is a bijection, the honest and simulated transcript distributions
are identical. -/
theorem hvzk_bijection (P : SchnorrParams) (x r c : ZMod P.p) :
    honestTranscript P x r c =
      simTranscript P x (honestSimEquiv P x (r, c)).2 (honestSimEquiv P x (r, c)).1 := by
  simp only [honestTranscript, simTranscript, honestSimEquiv, Equiv.coe_fn_mk,
    honestToSim, SchnorrParams.pk]
  refine Prod.ext ?_ (Prod.ext rfl ?_)
  · simp only; ring
  · simp only; ring