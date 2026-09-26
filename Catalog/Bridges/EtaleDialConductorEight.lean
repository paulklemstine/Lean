/-
# ETALE-DIAL III: the D₄@8 dial, the three quadratic channels, and reducible polynomials

Round 30 explained the "sum-sufficiency" of the D₄@8 dial by the claim that, given
`N = p q mod 8`, the sum `(p + q) mod 8` determines `p mod 8` and `q mod 8`.  This file tests
that claim and replaces it by the exact statement.

* `claim_refuted_by_primes` — the claim is **false**: `17 · 41 ≡ 13 · 29 ≡ 1` and
  `17 + 41 ≡ 13 + 29 ≡ 2 (mod 8)`, yet `17 ≡ 1` while `13 ≡ 29 ≡ 5 (mod 8)`.
* `not_vietaInjective_zmod_eight` — the same, derived structurally from the conductor
  classification of `Bridges.EtaleDialVietaChannel` (`8` is neither `ℓ` nor `2ℓ`).
* `sumSufficient_zmod_eight_iff` — **the exact criterion**: a type map on `(ZMod 8)ˣ` is
  sum-sufficient iff it is invariant under multiplication by `5`, i.e. iff it only depends on
  `p mod 4`.
* `sumSufficient_of_eight_dvd` — for *every* conductor `m` with `8 ∣ m`, any type map that
  factors through `p mod 4` is sum-sufficient (proved from the half-conductor law).
* `chi4_sumSufficient`, `chi8_not_sumSufficient`, `chi8'_not_sumSufficient` — among the three
  quadratic channels of `Q(ζ₈)` — `Q(i)`, `Q(√2)`, `Q(√-2)` — **exactly one**, the `Q(i)`
  channel `χ₄`, is sum-sufficient.
* `etaleType_not_sumSufficient` — the étale type of the *reducible* polynomial
  `(x² + 1)(x² - 2)` (the pair of Legendre symbols `(χ₄(p), χ₈(p))`) is not sum-sufficient,
  although its first factor is: sum-sufficiency is not inherited from factors.
* `splitType_not_sumSufficient` — likewise the complete-splitting indicator of `x⁴ + 1`
  (splitting field `Q(ζ₈)`) is not sum-sufficient.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1, cycle 3): if D₄@8 really is sum-sufficient, its type map can only see
  the `Q(i)` layer of the conductor-8 tower.
Experiment (Stage 2, cycle 3): the Vieta fibres over `(ZMod 8)ˣ` are
  `{1,1}~{5,5}`, `{3,3}~{7,7}`, `{1,3}~{5,7}`, `{1,7}~{3,5}` (four colliding cells out of
  ten); every fibre is a union of orbits of multiplication by `5`.
Analysis (Stage 3, cycle 3): the orbit structure is exactly the kernel of
  `(ZMod 8)ˣ → (ZMod 4)ˣ`; the half-conductor law (`8 = 2³ → 2² = 4`) explains it.
Critique (Stage 4, cycle 3): the finite fibre computation is isolated in one `decide` lemma;
  every other statement is derived from it or from the general theory.
-/
module

public import Mathlib
public import Bridges.EtaleDialVietaChannel
public import Bridges.EtaleDialHalfConductor

@[expose] public section

namespace EtaleDial

/-! ## 1. The round-30 claim is false -/

/-- **Refutation of the round-30 explanation with actual primes.**  The semiprimes
`17 · 41` and `13 · 29` have the same hinted view mod `8` but different residues. -/
theorem claim_refuted_by_primes :
    Nat.Prime 17 ∧ Nat.Prime 41 ∧ Nat.Prime 13 ∧ Nat.Prime 29 ∧
    (17 * 41) % 8 = (13 * 29) % 8 ∧ (17 + 41) % 8 = (13 + 29) % 8 ∧
    17 % 8 ≠ 13 % 8 ∧ 17 % 8 ≠ 29 % 8 := by
  refine ⟨by norm_num, by norm_num, by norm_num, by norm_num, by norm_num, by norm_num,
    by norm_num, by norm_num⟩

/-- Structural refutation: `ZMod 8` is not Vieta-injective, by the conductor
classification (`8 = 2 · 4` with `4` not prime). -/
theorem not_vietaInjective_zmod_eight : ¬ VietaInjective (ZMod 8) := by
  rw [vietaInjective_zmod_iff]
  rintro (h | h | h | ⟨ℓ, hℓ, _, h | h⟩)
  · norm_num at h
  · norm_num at h
  · norm_num at h
  · rw [← h] at hℓ; norm_num at hℓ
  · have : ℓ = 4 := by omega
    rw [this] at hℓ; norm_num at hℓ

/-! ## 2. The exact criterion at conductor 8 -/

/-- The unit `5 ∈ (ZMod 8)ˣ`, generator of the kernel of reduction mod `4`. -/
def five8 : (ZMod 8)ˣ := ZMod.unitOfCoprime 5 (by norm_num)

/-- The unit `3 ∈ (ZMod 8)ˣ`. -/
def three8 : (ZMod 8)ˣ := ZMod.unitOfCoprime 3 (by norm_num)

theorem units_zmod_eight (u : (ZMod 8)ˣ) : u = 1 ∨ u = three8 ∨ u = five8 ∨ u = -1 := by
  revert u; decide

/-- **The Vieta fibres of `(ZMod 8)ˣ`** (finite computation): equal sums and products force
the pairs to agree up to multiplication by `5` in each slot. -/
theorem vieta_fibre_zmod_eight : ∀ p q p' q' : (ZMod 8)ˣ,
    (p : ZMod 8) + q = p' + q' → (p : ZMod 8) * q = p' * q' →
    ((p' = p ∨ p' = five8 * p) ∧ (q' = q ∨ q' = five8 * q)) ∨
    ((p' = q ∨ p' = five8 * q) ∧ (q' = p ∨ q' = five8 * p)) := by
  decide

/-- **Exact criterion.**  A type map on `(ZMod 8)ˣ` is sum-sufficient iff it is invariant
under multiplication by `5`. -/
theorem sumSufficient_zmod_eight_iff {β : Type*} (f : (ZMod 8)ˣ → β) :
    SumSufficient f ↔ ∀ u, f (five8 * u) = f u := by
  constructor
  · intro hf
    -- the two diagonal collisions `{1,1} ~ {5,5}` and `{3,3} ~ {7,7}`
    have h15 : f five8 = f 1 := by
      have := hf 1 1 five8 five8 (by decide) (by decide)
      rcases this with ⟨h, _⟩ | ⟨h, _⟩ <;> exact h.symm
    have h37 : f (five8 * three8) = f three8 := by
      have := hf three8 three8 (five8 * three8) (five8 * three8) (by decide) (by decide)
      rcases this with ⟨h, _⟩ | ⟨h, _⟩ <;> exact h.symm
    intro u
    rcases units_zmod_eight u with rfl | rfl | rfl | rfl
    · simpa using h15
    · exact h37
    · have e : five8 * five8 = 1 := by decide
      rw [e]
      exact h15.symm
    · have e1 : five8 * -1 = three8 := by decide
      have e2 : (-1 : (ZMod 8)ˣ) = five8 * three8 := by decide
      rw [e1, e2]
      exact h37.symm
  · intro hf
    have inv : ∀ a b, (b = a ∨ b = five8 * a) → f b = f a := by
      rintro a b (rfl | rfl)
      · rfl
      · exact hf a
    intro p q p' q' hs hp
    rcases vieta_fibre_zmod_eight p q p' q' hs hp with ⟨h1, h2⟩ | ⟨h1, h2⟩
    · exact Or.inl ⟨(inv _ _ h1).symm, (inv _ _ h2).symm⟩
    · exact Or.inr ⟨(inv _ _ h2).symm, (inv _ _ h1).symm⟩

/-! ## 3. The mod-4 channel at every conductor divisible by 8 -/

/-- **The `Q(i)` layer is readable at every conductor `8 ∣ m`.**  Any type map that factors
through the reduction `(ZMod m)ˣ → (ZMod 4)ˣ` is sum-sufficient.  This is the half-conductor
law at `ℓ = 2, k = 3`, transported along `ZMod m → ZMod 8`. -/
theorem sumSufficient_of_eight_dvd {m : ℕ} (hm : 8 ∣ m) {β : Type*} (g : (ZMod 4)ˣ → β) :
    SumSufficient (g ∘ unitRed (n := m) 4 ((by norm_num : 4 ∣ 8).trans hm)) := by
  have h8 : SumSufficient (unitRed (n := 2 ^ 3) (2 ^ ((3 + 1) / 2))
      (pow_dvd_pow 2 (by norm_num))) := by
    haveI : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
    exact sumSufficient_reduction 3
  intro p q p' q' hs hp
  let φ : ZMod m →+* ZMod (2 ^ 3) := ZMod.castHom hm (ZMod (2 ^ 3))
  let P : ZMod m →* ZMod (2 ^ 3) := φ.toMonoidHom
  have hs8 : ((Units.map P p : (ZMod (2 ^ 3))ˣ) : ZMod (2 ^ 3)) + (Units.map P q : (ZMod (2 ^ 3))ˣ)
      = (Units.map P p' : (ZMod (2 ^ 3))ˣ) + (Units.map P q' : (ZMod (2 ^ 3))ˣ) := by
    simp only [Units.coe_map, P, RingHom.toMonoidHom_eq_coe, MonoidHom.coe_coe]
    rw [← map_add, ← map_add, hs]
  have hp8 : ((Units.map P p : (ZMod (2 ^ 3))ˣ) : ZMod (2 ^ 3)) * (Units.map P q : (ZMod (2 ^ 3))ˣ)
      = (Units.map P p' : (ZMod (2 ^ 3))ˣ) * (Units.map P q' : (ZMod (2 ^ 3))ˣ) := by
    simp only [Units.coe_map, P, RingHom.toMonoidHom_eq_coe, MonoidHom.coe_coe]
    rw [← map_mul, ← map_mul, hp]
  -- reduction `m → 4` factors as `m → 8 → 4`
  have hfac : ∀ x : (ZMod m)ˣ, unitRed (n := m) 4 ((by norm_num : 4 ∣ 8).trans hm) x
      = unitRed (n := 2 ^ 3) (2 ^ ((3 + 1) / 2)) (pow_dvd_pow 2 (by norm_num)) (Units.map P x) := by
    intro x
    apply Units.ext
    simp only [unitRed, Units.coe_map, RingHom.toMonoidHom_eq_coe, MonoidHom.coe_coe, P, φ]
    exact (RingHom.congr_fun (ZMod.castHom_comp (n := 4) (by norm_num : 4 ∣ 2 ^ 3) hm)
      (x : ZMod m)).symm
  have h := (h8.comp g) _ _ _ _ hs8 hp8
  simp only [Function.comp_apply] at h ⊢
  rw [hfac p, hfac q, hfac p', hfac q']
  exact h

/-! ## 4. The three quadratic channels of `Q(ζ₈)` -/

/-- The `Q(i)` channel: `p ↦ χ₄(p mod 4)`. -/
def chanI (u : (ZMod 8)ˣ) : ℤ := ZMod.χ₄ ((ZMod.castHom (by norm_num : 4 ∣ 8) (ZMod 4)) u)

/-- The `Q(√2)` channel: `p ↦ χ₈(p)`. -/
def chanSqrt2 (u : (ZMod 8)ˣ) : ℤ := ZMod.χ₈ u

/-- The `Q(√-2)` channel: `p ↦ χ₈'(p)`. -/
def chanSqrtNeg2 (u : (ZMod 8)ˣ) : ℤ := ZMod.χ₈' u

theorem chi4_sumSufficient : SumSufficient chanI := by
  rw [sumSufficient_zmod_eight_iff]
  intro u
  revert u
  decide

theorem chi8_not_sumSufficient : ¬ SumSufficient chanSqrt2 := by
  rw [sumSufficient_zmod_eight_iff]
  intro h
  have := h 1
  revert this
  decide

theorem chi8'_not_sumSufficient : ¬ SumSufficient chanSqrtNeg2 := by
  rw [sumSufficient_zmod_eight_iff]
  intro h
  have := h 1
  revert this
  decide

/-- **Exactly one quadratic channel is sum-sufficient.** -/
theorem exactly_one_quadratic_channel :
    SumSufficient chanI ∧ ¬ SumSufficient chanSqrt2 ∧ ¬ SumSufficient chanSqrtNeg2 :=
  ⟨chi4_sumSufficient, chi8_not_sumSufficient, chi8'_not_sumSufficient⟩

/-! ## 5. Reducible polynomials: the étale type channel -/

/-- The étale type of `p` for the reducible polynomial `(x² + 1)(x² - 2)`: the pair of
Legendre symbols of its two quadratic factors. -/
def etaleType (u : (ZMod 8)ˣ) : ℤ × ℤ := (chanI u, chanSqrt2 u)

/-- **Sum-sufficiency is not inherited from factors.**  The étale type channel of
`(x² + 1)(x² - 2)` is not sum-sufficient (its second coordinate is not), even though its
first factor's channel is. -/
theorem etaleType_not_sumSufficient : ¬ SumSufficient etaleType ∧ SumSufficient chanI := by
  refine ⟨fun h => chi8_not_sumSufficient ?_, chi4_sumSufficient⟩
  exact h.comp Prod.snd

/-- The factorisation (partition) type of `(x² + 1)(x² - 2)` records only the *number* of
split quadratic factors. -/
def partitionType (u : (ZMod 8)ˣ) : ℕ :=
  (if chanI u = 1 then 1 else 0) + (if chanSqrt2 u = 1 then 1 else 0)

theorem partitionType_not_sumSufficient : ¬ SumSufficient partitionType := by
  rw [sumSufficient_zmod_eight_iff]
  intro h
  have := h 1
  revert this
  decide

/-- Complete splitting of `x⁴ + 1` (splitting field `Q(ζ₈)`) happens iff `p ≡ 1 mod 8`. -/
def splitType (u : (ZMod 8)ˣ) : Bool := decide (u = 1)

theorem splitType_not_sumSufficient : ¬ SumSufficient splitType := by
  rw [sumSufficient_zmod_eight_iff]
  intro h
  have := h 1
  revert this
  decide

end EtaleDial