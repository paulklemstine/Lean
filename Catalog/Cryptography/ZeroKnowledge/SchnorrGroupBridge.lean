/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Cryptography.SchnorrIdentification
import Cryptography.ZeroKnowledge.SchnorrGroupProtocol

/-!
# Bridge: the catalog's additive Schnorr model is the group model at `Multiplicative (ZMod p)`

The catalog models Schnorr additively (`Cryptography.SchnorrIdentification`): the "group" is
`ZMod p`, the public key of `x` is `P.pk x = x * P.g`, and the verifier checks
`s * g = t + c * Y`.  `Cryptography.ZeroKnowledge.SchnorrGroupProtocol` models it
multiplicatively in an arbitrary commutative group of exponent `q`.

This file identifies the two: taking `G := Multiplicative (ZMod p)` and generator
`Multiplicative.ofAdd P.g`, the group-model exponentiation `gexp` *is* the additive model's
scalar multiplication, and the two verification predicates agree.  Consequently every
theorem proved in the group model specialises to the catalog's model, and conversely the
group-model machinery yields new results there — in particular the **distributional** form
of perfect honest-verifier zero knowledge (`hvzk_pmf_additive`), which strengthens the
catalog's counting form `SchnorrZK.hvzk_event_card_eq` to an equality of probability
distributions on transcripts.

## Main results

* `gexp_ofAdd` — `gexp (ofAdd a) e = ofAdd (e * a)`: the two scalar actions coincide.
* `orderOf_ofAdd_g` — the additive generator has multiplicative order `p`.
* `accepts_iff_Accepts` — the additive and group verification predicates agree.
* `completeness_of_group`, `special_soundness_of_group` — the catalog's completeness and
  extraction statements re-derived from the group model.
* `hvzk_pmf_additive` — new: perfect HVZK for the catalog's model as an equality of `PMF`s.
-/

namespace SchnorrGrp

open Multiplicative

variable (P : SchnorrParams)

instance : NeZero P.p := ⟨P.hp.out.ne_zero⟩

/-- Group-model exponentiation in `Multiplicative (ZMod p)` is additive-model scalar
multiplication. -/
theorem gexp_ofAdd (a e : ZMod P.p) :
    gexp (Multiplicative.ofAdd a) e = Multiplicative.ofAdd (e * a) := by
  rw [gexp, ← ofAdd_nsmul, nsmul_eq_mul]
  congr 1
  rw [ZMod.natCast_val, ZMod.cast_id]

/-- The `q`-torsion hypothesis holds for the additive generator. -/
theorem ofAdd_pow_p (a : ZMod P.p) : (Multiplicative.ofAdd a) ^ P.p = 1 := by
  rw [← ofAdd_nsmul, nsmul_eq_mul]
  simp

/-- The additive generator has multiplicative order exactly `p`. -/
theorem orderOf_ofAdd_g : orderOf (Multiplicative.ofAdd P.g) = P.p := by
  haveI := P.hp
  refine ((Nat.Prime.eq_one_or_self_of_dvd P.hp.out _
    (orderOf_dvd_iff_pow_eq_one.mpr (ofAdd_pow_p P P.g))).resolve_left ?_)
  intro h
  exact P.hg (by simpa using orderOf_eq_one_iff.mp h)

/-- The additive verifier and the group verifier are the same predicate. -/
theorem accepts_iff_Accepts (Y t c s : ZMod P.p) :
    accepts P Y (t, c, s)
      ↔ Accepts (Multiplicative.ofAdd P.g) (Multiplicative.ofAdd Y)
          ⟨Multiplicative.ofAdd t, c, s⟩ := by
  show _ ↔ gexp (Multiplicative.ofAdd P.g) s
      = Multiplicative.ofAdd t * gexp (Multiplicative.ofAdd Y) c
  rw [gexp_ofAdd, gexp_ofAdd, ← ofAdd_add]
  exact ⟨fun h => by rw [accepts] at h; rw [h], fun h => Multiplicative.ofAdd.injective h⟩

/-- The catalog's completeness re-derived from the group model. -/
theorem completeness_of_group (x r c : ZMod P.p) :
    accepts P (P.pk x) (r * P.g, c, r + c * x) := by
  have h := completeness (G := Multiplicative (ZMod P.p)) (ofAdd_pow_p P P.g) x r c
  rw [accepts_iff_Accepts]
  simpa [honest, gexp_ofAdd, SchnorrParams.pk, mul_comm] using h

/-- The catalog's special soundness re-derived from the group model's knowledge extractor. -/
theorem special_soundness_of_group (x t c₁ s₁ c₂ s₂ : ZMod P.p)
    (h₁ : accepts P (P.pk x) (t, c₁, s₁)) (h₂ : accepts P (P.pk x) (t, c₂, s₂))
    (hc : c₁ ≠ c₂) :
    (s₁ - s₂) * (c₁ - c₂)⁻¹ = x := by
  haveI := P.hp
  rw [accepts_iff_Accepts] at h₁ h₂
  have hpk : Multiplicative.ofAdd (P.pk x) = gexp (Multiplicative.ofAdd P.g) x := by
    rw [gexp_ofAdd]; rfl
  rw [hpk] at h₁ h₂
  exact special_soundness_eq_witness (ofAdd_pow_p P P.g) (orderOf_ofAdd_g P) x _ c₁ s₁ c₂ s₂
    h₁ h₂ hc

/-- **Perfect HVZK for the catalog's additive model, distributional form.**  For each fixed
challenge, the honest transcript over uniform randomness and the witness-free simulated
transcript over a uniform response have *equal* distributions.  This strengthens the
catalog's counting statement to an equality of `PMF`s. -/
theorem hvzk_pmf_additive (x c : ZMod P.p) :
    (PMF.uniformOfFintype (ZMod P.p)).map (fun r => honestTranscript P x r c)
      = (PMF.uniformOfFintype (ZMod P.p)).map (fun s => simTranscript P x c s) := by
  have h : (fun r => honestTranscript P x r c)
      = (fun s => simTranscript P x c s) ∘ (hvzkEquiv x c) := by
    funext r
    have : (r + c * x) * P.g - c * P.pk x = r * P.g := by
      simp [SchnorrParams.pk]; ring
    simp [honestTranscript, simTranscript, hvzkEquiv, this]
  rw [h, ← PMF.map_comp, map_uniformOfFintype_equiv]

end SchnorrGrp