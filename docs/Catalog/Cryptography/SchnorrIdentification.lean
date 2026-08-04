/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# The Schnorr identification Σ-protocol

An additive model of the Schnorr identification scheme over a prime field.  The
"group" is `ZMod p` with a fixed nonzero generator `g`; "scalar times group
element" is field multiplication, and the public key of the secret `x` is
`pk x = x * g`.

A transcript is a triple `(t, c, s)` (commitment, challenge, response) and the
verifier accepts iff `s * g = t + c * Y`.

## Main results

* `completeness` — the honest prover is always accepted;
* `special_soundness` — two accepting transcripts with a common commitment and
  distinct challenges determine the secret;
* `sim_accepts` — the witness-free simulator produces accepting transcripts;
* `honestSimEquiv`, `hvzk_bijection` — honest and simulated transcripts are
  matched by an explicit bijection of the randomness, which is perfect
  honest-verifier zero knowledge in its combinatorial form.
-/

/-- Public parameters of the Schnorr identification protocol: a prime `p` and a
nonzero generator `g` of the additive model `ZMod p`. -/
structure SchnorrParams where
  /-- The prime modulus. -/
  p : ℕ
  /-- `p` is prime, so `ZMod p` is a field. -/
  hp : Fact (Nat.Prime p)
  /-- The generator. -/
  g : ZMod p
  /-- The generator is nonzero. -/
  hg : g ≠ 0

attribute [instance] SchnorrParams.hp

namespace SchnorrParams

/-- The public key associated with the secret `x`. -/
def pk (P : SchnorrParams) (x : ZMod P.p) : ZMod P.p := x * P.g

end SchnorrParams

variable (P : SchnorrParams)

/-- A protocol transcript: commitment, challenge, response. -/
@[ext]
structure Transcript (P : SchnorrParams) where
  /-- The commitment. -/
  t : ZMod P.p
  /-- The challenge. -/
  c : ZMod P.p
  /-- The response. -/
  s : ZMod P.p

/-- The verifier: the transcript `(t, c, s)` is accepted for the public key `Y`
iff `s * g = t + c * Y`. -/
def accepts (P : SchnorrParams) (Y : ZMod P.p)
    (T : ZMod P.p × ZMod P.p × ZMod P.p) : Prop :=
  T.2.2 * P.g = T.1 + T.2.1 * Y

/-- The honest transcript produced with randomness `r` on challenge `c`. -/
def honestTranscript (x r c : ZMod P.p) : Transcript P :=
  ⟨r * P.g, c, r + c * x⟩

/-- The simulated transcript: pick the challenge `c` and the response `s`, then
back-solve the commitment. -/
def simTranscript (x c s : ZMod P.p) : Transcript P :=
  ⟨s * P.g - c * P.pk x, c, s⟩

/-- **Completeness.**  The honest prover with randomness `r` is always accepted. -/
theorem completeness (x r c : ZMod P.p) :
    accepts P (P.pk x) (r * P.g, c, r + c * x) := by
  simp only [accepts, SchnorrParams.pk]
  ring

/-- The honest transcript is an accepting one. -/
theorem honestTranscript_accepts (x r c : ZMod P.p) :
    accepts P (P.pk x) ((honestTranscript P x r c).t, (honestTranscript P x r c).c,
      (honestTranscript P x r c).s) :=
  completeness P x r c

/-- **Simulator soundness.**  The witness-free simulator always produces
accepting transcripts. -/
theorem sim_accepts (x c s : ZMod P.p) :
    accepts P (P.pk x) ((simTranscript P x c s).t, (simTranscript P x c s).c,
      (simTranscript P x c s).s) := by
  simp only [accepts, simTranscript]
  ring

/-- **Special soundness.**  Two accepting transcripts sharing the commitment `t`
with distinct challenges determine the secret. -/
theorem special_soundness (x t c₁ s₁ c₂ s₂ : ZMod P.p)
    (h₁ : accepts P (P.pk x) (t, c₁, s₁))
    (h₂ : accepts P (P.pk x) (t, c₂, s₂))
    (hc : c₁ ≠ c₂) :
    x = (c₁ - c₂)⁻¹ * (s₁ - s₂) := by
  haveI := P.hp
  simp only [accepts, SchnorrParams.pk] at h₁ h₂
  have hcne : c₁ - c₂ ≠ 0 := sub_ne_zero.mpr hc
  have hdiff : (s₁ - s₂) * P.g = (c₁ - c₂) * (x * P.g) := by
    rw [sub_mul, h₁, h₂]; ring
  have hx : (s₁ - s₂) = (c₁ - c₂) * x := by
    have := mul_right_cancel₀ P.hg (by rw [hdiff]; ring :
      (s₁ - s₂) * P.g = ((c₁ - c₂) * x) * P.g)
    exact this
  rw [hx, ← mul_assoc, inv_mul_cancel₀ hcne, one_mul]

/-- The randomness ↔ response bijection `(r, c) ↦ (r + c * x, c)` underlying
perfect honest-verifier zero knowledge. -/
def honestSimEquiv (x : ZMod P.p) : (ZMod P.p × ZMod P.p) ≃ (ZMod P.p × ZMod P.p) where
  toFun rc := (rc.1 + rc.2 * x, rc.2)
  invFun sc := (sc.1 - sc.2 * x, sc.2)
  left_inv := by intro rc; simp
  right_inv := by intro sc; simp

/-- **Perfect HVZK.**  Under the bijection `honestSimEquiv` the honest transcript
and the simulated transcript coincide. -/
theorem hvzk_bijection (x : ZMod P.p) (rc : ZMod P.p × ZMod P.p) :
    honestTranscript P x rc.1 rc.2 =
      simTranscript P x (honestSimEquiv P x rc).2 (honestSimEquiv P x rc).1 := by
  simp only [honestTranscript, simTranscript, honestSimEquiv, SchnorrParams.pk,
    Equiv.coe_fn_mk, Transcript.mk.injEq]
  refine ⟨by ring, ?_⟩
  trivial