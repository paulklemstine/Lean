/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Cryptography.ZeroKnowledge.SchnorrGroupProtocol

/-!
# Exact soundness error, unique responses, and a concrete instance of group-model Schnorr

`Cryptography.ZeroKnowledge.SchnorrGroupProtocol` develops the Schnorr Σ-protocol in an
abstract commutative group of exponent `q`.  This file

* sharpens the soundness analysis in a *cyclic group of prime order `q`*: there the
  cheating probability of a pre-committed pair `(a, z)` is **exactly** `1 / q`
  (`soundness_error_eq`), not merely at most `1 / q`;
* proves the *unique response* property (`unique_response`);
* exhibits a concrete group satisfying every standing hypothesis
  (`Multiplicative (ZMod q)` with generator `ofAdd 1`), so the theory is not vacuous, and
  instantiates completeness, extraction and zero knowledge there.

## Main results

* `gexp_bijective`, `gexp_surjective` — in a group of prime order `q`, a nontrivial element
  generates: `e ↦ h ^ e` is a bijection `ZMod q ≃ G`.
* `accepting_challenges_card_eq_one`, `soundness_error_eq` — exactly one challenge is
  accepting for a pre-committed `(a, z)`, so the soundness error is exactly `1 / q`.
* `unique_response` — for a fixed commitment and challenge the accepting response is unique.
* `schnorrGen_orderOf`, `instance_completeness`, `instance_extraction`, `instance_hvzk` —
  the concrete instance and the three protocol properties instantiated in it.
-/

namespace SchnorrGrp

/-! ### Cyclic groups of prime order: the soundness error is exactly `1/q` -/

section Cyclic

variable {G : Type*} [CommGroup G] [Fintype G] {q : ℕ} [Fact q.Prime]

/-- In a group of prime order `q`, exponentiation by `ZMod q` scalars at a nontrivial base is
bijective: every group element is a power of `h`. -/
theorem gexp_bijective (hcard : Fintype.card G = q) {h : G} (hh : h ^ q = 1) (h1 : h ≠ 1) :
    Function.Bijective (gexp h : ZMod q → G) := by
  refine (Fintype.bijective_iff_injective_and_card _).mpr
    ⟨gexp_injective (orderOf_eq_of_prime hh h1), ?_⟩
  rw [hcard, ZMod.card]

theorem gexp_surjective (hcard : Fintype.card G = q) {h : G} (hh : h ^ q = 1) (h1 : h ≠ 1) :
    Function.Surjective (gexp h : ZMod q → G) :=
  (gexp_bijective hcard hh h1).2

open scoped Classical in
/-- **Exactly one accepting challenge.** In a group of prime order with a nontrivial public
key, a commitment/response pair `(a, z)` fixed before the challenge is accepted for exactly
one of the `q` challenges. -/
theorem accepting_challenges_card_eq_one (hcard : Fintype.card G = q) {g pub : G}
    (hpub : pub ^ q = 1) (hpub1 : pub ≠ 1) (a : G) (z : ZMod q) :
    (Finset.univ.filter (fun c : ZMod q => Accepts g pub ⟨a, c, z⟩)).card = 1 := by
  refine le_antisymm (accepting_challenges_card_le_one hpub hpub1 a z) ?_
  obtain ⟨c, hc⟩ := gexp_surjective hcard hpub hpub1 (a⁻¹ * gexp g z)
  refine Finset.card_pos.mpr ⟨c, ?_⟩
  simp only [Finset.mem_filter, Finset.mem_univ, true_and]
  show gexp g z = a * gexp pub c
  rw [hc, mul_inv_cancel_left]

open scoped Classical in
/-- **The soundness error is exactly `1 / q`.** -/
theorem soundness_error_eq (hcard : Fintype.card G = q) {g pub : G} (hpub : pub ^ q = 1)
    (hpub1 : pub ≠ 1) (a : G) (z : ZMod q) :
    ((Finset.univ.filter (fun c : ZMod q => Accepts g pub ⟨a, c, z⟩)).card : ℚ)
        / (Finset.univ : Finset (ZMod q)).card = 1 / q := by
  rw [accepting_challenges_card_eq_one hcard hpub hpub1 a z]
  simp

end Cyclic

/-- **Unique response.** For a fixed commitment and challenge, at most one response is
accepted; hence an accepting transcript is determined by `(a, c)`. -/
theorem unique_response {G : Type*} [CommGroup G] {q : ℕ} [NeZero q] {g pub : G}
    (horder : orderOf g = q) (a : G) (c z₁ z₂ : ZMod q)
    (h₁ : Accepts g pub ⟨a, c, z₁⟩) (h₂ : Accepts g pub ⟨a, c, z₂⟩) : z₁ = z₂ :=
  gexp_injective horder (h₁.trans h₂.symm)

/-! ### A concrete instance: the cyclic group `Multiplicative (ZMod q)` -/

section Instance

variable (q : ℕ) [NeZero q]

/-- The concrete prime-order group used to instantiate the protocol. -/
abbrev SchnorrGroup : Type := Multiplicative (ZMod q)

/-- The canonical generator of `SchnorrGroup q`. -/
def schnorrGen : SchnorrGroup q := Multiplicative.ofAdd 1

omit [NeZero q] in
@[simp] theorem schnorrGen_orderOf : orderOf (schnorrGen q) = q := by
  simp [schnorrGen, ZMod.addOrderOf_one]

omit [NeZero q] in
theorem schnorrGen_pow_q : (schnorrGen q) ^ q = 1 := by
  have h := pow_orderOf_eq_one (schnorrGen q)
  rwa [schnorrGen_orderOf] at h

theorem schnorrGroup_card : Fintype.card (SchnorrGroup q) = q := by simp

omit [NeZero q] in
theorem schnorrGen_ne_one [Fact (1 < q)] : schnorrGen q ≠ 1 := by
  intro h
  have : orderOf (schnorrGen q) = 1 := by rw [h]; exact orderOf_one
  rw [schnorrGen_orderOf] at this
  exact absurd this (by have := (Fact.out : 1 < q); omega)

/-- **Completeness in the concrete instance.** -/
theorem instance_completeness (x r c : ZMod q) :
    Accepts (schnorrGen q) (gexp (schnorrGen q) x)
      (honest (schnorrGen q) x r c) :=
  completeness (schnorrGen_pow_q q) x r c

omit [NeZero q] in
/-- **Extraction in the concrete instance:** forking recovers the secret key. -/
theorem instance_extraction [Fact q.Prime] (x : ZMod q) (a : SchnorrGroup q)
    (c₁ z₁ c₂ z₂ : ZMod q)
    (h₁ : Accepts (schnorrGen q) (gexp (schnorrGen q) x) ⟨a, c₁, z₁⟩)
    (h₂ : Accepts (schnorrGen q) (gexp (schnorrGen q) x) ⟨a, c₂, z₂⟩)
    (hc : c₁ ≠ c₂) :
    extract c₁ z₁ c₂ z₂ = x :=
  special_soundness_eq_witness (schnorrGen_pow_q q) (schnorrGen_orderOf q) x a c₁ z₁ c₂ z₂
    h₁ h₂ hc

/-- **Perfect HVZK in the concrete instance.** -/
theorem instance_hvzk (x c : ZMod q) :
    (PMF.uniformOfFintype (ZMod q)).map (fun r => honest (schnorrGen q) x r c)
      = (PMF.uniformOfFintype (ZMod q)).map
          (fun z => simulate (schnorrGen q) (gexp (schnorrGen q) x) c z) :=
  hvzk_pmf (schnorrGen_pow_q q) x c

open scoped Classical in
/-- **The soundness error is exactly `1/q` in the concrete instance.** -/
theorem instance_soundness_error_eq [Fact q.Prime] (pub : SchnorrGroup q) (hpub1 : pub ≠ 1)
    (a : SchnorrGroup q) (z : ZMod q) :
    ((Finset.univ.filter (fun c : ZMod q =>
        Accepts (schnorrGen q) pub ⟨a, c, z⟩)).card : ℚ)
        / (Finset.univ : Finset (ZMod q)).card = 1 / q := by
  classical
  have hpub : pub ^ q = 1 := by
    have : orderOf pub ∣ Fintype.card (SchnorrGroup q) := orderOf_dvd_card
    rw [schnorrGroup_card] at this
    exact orderOf_dvd_iff_pow_eq_one.mp this
  exact soundness_error_eq (schnorrGroup_card q) hpub hpub1 a z

end Instance

/-- A fully concrete accepting transcript in the group of order `5`, checked by decision
procedure: secret `x = 3`, randomness `r = 2`, challenge `c = 4`. -/
example : Accepts (schnorrGen 5) (gexp (schnorrGen 5) (3 : ZMod 5))
    (⟨gexp (schnorrGen 5) (2 : ZMod 5), 4, 2 + 4 * 3⟩ : Transcript (SchnorrGroup 5) 5) := by
  unfold Accepts gexp
  decide

end SchnorrGrp