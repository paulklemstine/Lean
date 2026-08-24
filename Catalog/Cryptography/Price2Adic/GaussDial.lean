import Cryptography.ResidueDial.Core

/-!
# Gauss-sum magnitudes are an information-free residue dial

The experiment behind this file compared numeric quadratic Gauss sums with their closed
forms on `7625` parameter cells `(a, b, M)` and found that every `|G|`-magnitude feature
is a pure function of a residue class — on the standard lab range, literally constant.
Here that observation is proved, in the model of `Cryptography.ResidueDial.Core`.

Fix an odd prime `p`, let `χ` be the quadratic character of `ZMod p` (valued in `ℂ`) and
let `ψ` be a primitive additive character.  Then:

* `gaussSum_sq_eq` — `g² = ± p`, with the sign `+` exactly when `p ≡ 1 (mod 4)`.  The
  *sign* feature is therefore a dial of modulus `4` (`gaussSum_sq_residue_dial`).
* `norm_gaussSum` — `‖g‖ = √p`: the magnitude does not depend on `ψ` at all.
* `norm_gaussSum_mulShift` — twisting `ψ` by any unit `a ∈ (ZMod p)ˣ` leaves `‖g‖`
  unchanged.  So the magnitude, read as a function of the residue class `a`, is
  **constant**: it separates no class from any other.
* `ResidueDial.speedup_of_constant_feature` — a constant feature always induces a dial of
  density `0` or `1`, hence a speedup of exactly `1`: zero bits.
* `gaussMagnitude_dial_speedup_eq_one` — combining the two: the Gauss-magnitude dial buys
  a scan speedup of exactly `1`.  This is the "`I = 0` bits" claim, proved rather than
  measured, and it sits strictly below the universal cap `4/3` of
  `ResidueDial.dialSpeedup_le_four_thirds`.

## Lab notes (round 70, exp 548)

All `7625` cells matched the closed form (`|G| ∈ {0, √M, √(2M)}`), and on the lab range
(`p ≡ q mod 4`) the normalised magnitude was constant to machine precision, giving an
empirical mutual information of `0` bits with a residue entropy of `H = 1.000`.  The
theorems below explain why no sampling could have found anything else.
-/

open Finset

namespace ResidueDial

/-- **A constant feature is an information-free dial.**  If the observable `f` takes the
same value on every residue class, then the filter it induces is empty or everything, so
the scan speedup it buys is exactly `1` — no bits. -/
theorem speedup_of_constant_feature {M : ℕ} [NeZero M] {β : Type*} (f : (ZMod M)ˣ → β)
    (S : Set β) [DecidablePred (· ∈ S)] (hf : ∀ u v, f u = f v) :
    speedup (density M (univ.filter fun u => f u ∈ S)) = 1 := by
  refine speedup_of_trivial ?_
  by_cases h : ∃ u : (ZMod M)ˣ, f u ∈ S
  · obtain ⟨u₀, hu₀⟩ := h
    right
    have huniv : (univ.filter fun u : (ZMod M)ˣ => f u ∈ S) = univ := by
      apply Finset.filter_true_of_mem
      intro v _
      rw [hf v u₀]
      exact hu₀
    rw [density, huniv, Finset.card_univ, ZMod.card_units_eq_totient M,
      div_self (by exact_mod_cast (totient_pos_of_neZero M).ne')]
  · left
    have hempty : (univ.filter fun u : (ZMod M)ˣ => f u ∈ S) = ∅ := by
      apply Finset.filter_false_of_mem
      intro v _ hv
      exact h ⟨v, hv⟩
    rw [density, hempty]
    simp

end ResidueDial

namespace Price2Adic

open ResidueDial

variable (p : ℕ) [Fact p.Prime]

/-- The quadratic character of `ZMod p`, valued in `ℂ`. -/
noncomputable def quadCharC : MulChar (ZMod p) ℂ :=
  (quadraticChar (ZMod p)).ringHomComp (Int.castRingHom ℂ)

theorem ringChar_zmod_ne_two (hp : p % 2 = 1) : ringChar (ZMod p) ≠ 2 := by
  rw [ZMod.ringChar_zmod_n]
  omega

theorem quadCharC_ne_one (hp : p % 2 = 1) : quadCharC p ≠ 1 :=
  (MulChar.ringHomComp_ne_one_iff (Int.cast_injective)).mpr
    (quadraticChar_ne_one (ringChar_zmod_ne_two p hp))

theorem quadCharC_isQuadratic : (quadCharC p).IsQuadratic :=
  (quadraticChar_isQuadratic (ZMod p)).comp _

/-- The square of the quadratic Gauss sum is `± p`, with the sign given by `p mod 4`:
Gauss's closed form. -/
theorem gaussSum_sq_eq (hp : p % 2 = 1) {ψ : AddChar (ZMod p) ℂ} (hψ : ψ.IsPrimitive) :
    gaussSum (quadCharC p) ψ ^ 2 = if p % 4 = 1 then (p : ℂ) else -(p : ℂ) := by
  have hcard : Fintype.card (ZMod p) = p := ZMod.card p
  have hg : gaussSum (quadCharC p) ψ ^ 2 = (quadCharC p) (-1) * (Fintype.card (ZMod p) : ℂ) :=
    gaussSum_sq (quadCharC_ne_one p hp) (quadCharC_isQuadratic p) hψ
  have hneg : (quadCharC p) (-1) = ((ZMod.χ₄ (Fintype.card (ZMod p)) : ℤ) : ℂ) := by
    simp only [quadCharC, MulChar.ringHomComp_apply, eq_intCast]
    rw [quadraticChar_neg_one (ringChar_zmod_ne_two p hp)]
  rw [hg, hneg, hcard, ZMod.χ₄_nat_eq_if_mod_four]
  split_ifs with h1 h2 h3
  · simp at h1; omega
  · simp at h1; omega
  · simp
  · simp

/-- **The sign feature is a residue dial of modulus `4`.**  Two odd primes in the same
class mod `4` have Gauss sums with the same normalised square. -/
theorem gaussSum_sq_residue_dial (q : ℕ) [Fact q.Prime] (hp : p % 2 = 1) (hq : q % 2 = 1)
    (hpq : p % 4 = q % 4) {ψ : AddChar (ZMod p) ℂ} (hψ : ψ.IsPrimitive)
    {φ : AddChar (ZMod q) ℂ} (hφ : φ.IsPrimitive) :
    gaussSum (quadCharC p) ψ ^ 2 / (p : ℂ) = gaussSum (quadCharC q) φ ^ 2 / (q : ℂ) := by
  have hp0 : (p : ℂ) ≠ 0 := by
    have : p ≠ 0 := (Fact.out : p.Prime).ne_zero
    exact_mod_cast this
  have hq0 : (q : ℂ) ≠ 0 := by
    have : q ≠ 0 := (Fact.out : q.Prime).ne_zero
    exact_mod_cast this
  rw [gaussSum_sq_eq p hp hψ, gaussSum_sq_eq q hq hφ, hpq]
  split_ifs <;> field_simp

/-- **The magnitude is `√p`**, for every primitive `ψ`: a pure function of the modulus. -/
theorem norm_gaussSum (hp : p % 2 = 1) {ψ : AddChar (ZMod p) ℂ} (hψ : ψ.IsPrimitive) :
    ‖gaussSum (quadCharC p) ψ‖ = Real.sqrt p := by
  have hsq : ‖gaussSum (quadCharC p) ψ‖ ^ 2 = (p : ℝ) := by
    have h : ‖gaussSum (quadCharC p) ψ ^ 2‖ = (p : ℝ) := by
      rw [gaussSum_sq_eq p hp hψ]
      split_ifs <;> simp
    rwa [norm_pow] at h
  rw [← hsq, Real.sqrt_sq (norm_nonneg _)]

theorem norm_quadCharC_unit (a : (ZMod p)ˣ) : ‖(quadCharC p) (a : ZMod p)‖ = 1 := by
  have hne : (quadCharC p) (a : ZMod p) ≠ 0 := by
    have := IsUnit.map (quadCharC p) a.isUnit
    exact this.ne_zero
  rcases quadCharC_isQuadratic p (a : ZMod p) with h | h | h
  · exact absurd h hne
  · rw [h]; simp
  · rw [h]; simp

/-- **The magnitude is blind to the residue class.**  Twisting the additive character by
a unit `a` — i.e. moving to the class `a` of the dial — does not change `‖G‖`. -/
theorem norm_gaussSum_mulShift (ψ : AddChar (ZMod p) ℂ) (a : (ZMod p)ˣ) :
    ‖gaussSum (quadCharC p) (ψ.mulShift (a : ZMod p))‖ = ‖gaussSum (quadCharC p) ψ‖ := by
  have h := gaussSum_mulShift (quadCharC p) ψ a
  have := congrArg (‖·‖) h
  simp only [norm_mul, norm_quadCharC_unit p a, one_mul] at this
  exact this

/-- **`I = 0` bits.**  The Gauss-magnitude observable, read across the residue classes
mod `p`, is constant; therefore the dial it defines has density `0` or `1` and buys a
scan speedup of exactly `1` — strictly below the universal cap `4/3`. -/
theorem gaussMagnitude_dial_speedup_eq_one [NeZero p] (ψ : AddChar (ZMod p) ℂ) (S : Set ℝ)
    [DecidablePred (· ∈ S)] :
    speedup (density p (univ.filter fun a : (ZMod p)ˣ =>
      ‖gaussSum (quadCharC p) (ψ.mulShift (a : ZMod p))‖ ∈ S)) = 1 := by
  refine speedup_of_constant_feature _ S ?_
  intro u v
  rw [norm_gaussSum_mulShift p ψ u, norm_gaussSum_mulShift p ψ v]

/-- The magnitude dial is strictly weaker than the best possible residue dial: it buys
`1`, while the cap is `4/3`. -/
theorem gaussMagnitude_dial_lt_cap [NeZero p] (ψ : AddChar (ZMod p) ℂ) (S : Set ℝ)
    [DecidablePred (· ∈ S)] :
    speedup (density p (univ.filter fun a : (ZMod p)ˣ =>
      ‖gaussSum (quadCharC p) (ψ.mulShift (a : ZMod p))‖ ∈ S)) < 4 / 3 := by
  rw [gaussMagnitude_dial_speedup_eq_one p ψ S]
  norm_num

end Price2Adic