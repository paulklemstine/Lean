/-
# UNIVERSAL-S3-CORRECTED: same channel shape, different conductors

Both `x³ - 2` and `x³ + x + 1` have splitting field with group `S₃`, and in both
cases the splitting type carries exactly one bit about the sign character
(`S3SignChannelUniversal`).  But the *conductor* of the sign character is the
discriminant's, not a universal constant:

* `x³ - 2`   (Δ = -108 = -3·6²):  sign bit  ↔  `p mod 3`   (`PureCubicSignConductor`);
* `x³ + x + 1` (Δ = -31):          sign bit  ↔  `(p / 31)`  (this file).

Main results.

* `legendre_neg31_eq` : quadratic reciprocity for `-31`:
  `(-31 / p) = (p / 31)` for every odd prime `p ≠ 31`.
* `trinomial_one_root_iff_legendre` : `x³ + x + 1` has exactly one root mod `p`
  iff `(p / 31) = -1`.
* `trinomial_conductor_31` : the splitting-type sign bit of `x³ + x + 1` depends
  only on `p mod 31`.
* `channel_trinomial` : on any finite set of primes `∉ {2, 31}`,
  `I((p/31) ; T) = H((p/31))` — the one-bit channel lives at conductor 31.
* `conductor_separation` : on the sample `{5, 11}` the conductor-3 channel of
  `x³ + x + 1` carries `0` bits while the conductor-31 channel carries `1` bit.
-/
import Novelty.CubicStickelbergerFrobenius
import Novelty.PureCubicSignConductor

namespace TrinomialConductor31

open Finset CyclicTypeChannel

/-- `31` is prime. -/
def fact31 : Fact (Nat.Prime 31) := ⟨by norm_num⟩

attribute [local instance] fact31

/-- **Quadratic reciprocity for `-31`.**  `(-31 / p) = (p / 31)` for odd primes `p ≠ 31`. -/
theorem legendre_neg31_eq {p : ℕ} [Fact p.Prime] (hp2 : p ≠ 2) :
    legendreSym p (-31) = legendreSym 31 p := by
  have hodd : p % 2 = 1 := Nat.odd_iff.1 ((Fact.out : p.Prime).odd_of_ne_two hp2)
  have hrec := legendreSym.quadratic_reciprocity' (p := 31) (q := p) (by norm_num) hp2
  rw [show (-31 : ℤ) = -1 * 31 by norm_num, legendreSym.mul, legendreSym.at_neg_one hp2,
    ZMod.χ₄_eq_neg_one_pow hodd]
  push_cast at hrec
  rw [hrec, ← mul_assoc, ← pow_add]
  rw [show p / 2 + 15 * (p / 2) = 2 * (8 * (p / 2)) by ring, pow_mul]
  norm_num

/-- The splitting type of `x³ + x + 1` has exactly one root mod `p` iff `(p/31) = -1`. -/
theorem trinomial_one_root_iff_legendre {p : ℕ} [Fact p.Prime] (hp2 : p ≠ 2) (hp31 : p ≠ 31) :
    (∃ r : ZMod p, r ^ 3 + r + 1 = 0 ∧ ∀ s : ZMod p, s ^ 3 + s + 1 = 0 → s = r) ↔
      legendreSym 31 p = -1 := by
  rw [CubicStickelbergerFrobenius.trinomial_sign_law hp2 hp31, ← legendre_neg31_eq hp2,
    legendreSym.eq_neg_one_iff]
  push_cast
  rfl

/-- `trinomialType p = 1` expressed as unique existence of a root. -/
lemma trinomialType_eq_one_iff (p : ℕ) [Fact p.Prime] :
    PureCubicSignConductor.trinomialType p = 1 ↔
      ∃ r : ZMod p, r ^ 3 + r + 1 = 0 ∧ ∀ s : ZMod p, s ^ 3 + s + 1 = 0 → s = r := by
  rw [PureCubicSignConductor.trinomialType, Nat.card_eq_one_iff_unique]
  constructor
  · rintro ⟨hsub, ⟨r, hr⟩⟩
    exact ⟨r, hr, fun s hs => congrArg Subtype.val (@Subsingleton.elim _ hsub ⟨s, hs⟩ ⟨r, hr⟩)⟩
  · rintro ⟨r, hr, hu⟩
    exact ⟨⟨fun x y => Subtype.ext ((hu x.1 x.2).trans (hu y.1 y.2).symm)⟩, ⟨⟨r, hr⟩⟩⟩

theorem trinomialType_eq_one_iff_legendre {p : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) (hp31 : p ≠ 31) :
    PureCubicSignConductor.trinomialType p = 1 ↔ legendreSym 31 p = -1 := by
  haveI := Fact.mk hp
  rw [trinomialType_eq_one_iff, trinomial_one_root_iff_legendre hp2 hp31]

/-- **Conductor 31.**  For primes `p, q ∉ {2, 31}` with `p ≡ q (mod 31)`, `x³ + x + 1`
has the same sign bit (one root / not one root) at `p` and at `q`. -/
theorem trinomial_conductor_31 {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hp2 : p ≠ 2)
    (hq2 : q ≠ 2) (hp31 : p ≠ 31) (hq31 : q ≠ 31) (hpq : p % 31 = q % 31) :
    PureCubicSignConductor.trinomialType p = 1 ↔ PureCubicSignConductor.trinomialType q = 1 := by
  rw [trinomialType_eq_one_iff_legendre hp hp2 hp31, trinomialType_eq_one_iff_legendre hq hq2 hq31,
    legendreSym.mod 31 (p : ℤ), legendreSym.mod 31 (q : ℤ)]
  rw [← Int.natCast_mod, ← Int.natCast_mod, hpq]

lemma legendre31_ne_zero {p : ℕ} (hp : p.Prime) (hp31 : p ≠ 31) :
    (((p : ℤ)) : ZMod 31) ≠ 0 := by
  intro h
  have : ((p : ℕ) : ZMod 31) = 0 := by exact_mod_cast h
  rw [ZMod.natCast_eq_zero_iff] at this
  exact hp31 ((Nat.prime_dvd_prime_iff_eq (by norm_num) hp).1 this).symm

/-- **The trinomial channel lives at conductor 31.**  On any finite set of primes
`∉ {2, 31}`, the splitting type of `x³ + x + 1` reveals the Legendre symbol
`(p/31)` completely. -/
theorem channel_trinomial (S : Finset ℕ) (hS : ∀ p ∈ S, p.Prime ∧ p ≠ 2 ∧ p ≠ 31) :
    mutInfo S (fun p => legendreSym 31 p) PureCubicSignConductor.trinomialType
      = uEnt S (fun p => legendreSym 31 p) := by
  refine S3SignChannelUniversal.mutInfo_eq_uEnt_of_factor S _ _ fun x hx y hy h => ?_
  obtain ⟨hx1, hx2, hx3⟩ := hS x hx
  obtain ⟨hy1, hy2, hy3⟩ := hS y hy
  have ex := trinomialType_eq_one_iff_legendre hx1 hx2 hx3
  have ey := trinomialType_eq_one_iff_legendre hy1 hy2 hy3
  have vx := legendreSym.eq_one_or_neg_one 31 (legendre31_ne_zero hx1 hx3)
  have vy := legendreSym.eq_one_or_neg_one 31 (legendre31_ne_zero hy1 hy3)
  rcases vx with vx | vx <;> rcases vy with vy | vy
  · rw [vx, vy]
  · exfalso; have := ex.1 (h.trans (ey.2 vy)); rw [vx] at this; norm_num at this
  · exfalso; have := ey.1 (h.symm.trans (ex.2 vx)); rw [vy] at this; norm_num at this
  · rw [vx, vy]

/-- **Conductor separation on `{5, 11}`.**  For `x³ + x + 1`, the `p mod 3` channel
carries `0` bits while the `(p/31)` channel carries exactly `1` bit.  (For `x³ - 2`
the `p mod 3` channel is the full one-bit channel.) -/
theorem conductor_separation :
    mutInfo ({5, 11} : Finset ℕ) (· % 3) PureCubicSignConductor.trinomialType = 0 ∧
    mutInfo ({5, 11} : Finset ℕ) (fun p => legendreSym 31 p)
      PureCubicSignConductor.trinomialType = 1 := by
  constructor
  · rw [mutInfo, S3SignChannelUniversal.uEnt_eq_zero_of_const _ _ (by decide),
      S3SignChannelUniversal.condEnt_eq_zero_of_factor _ _ _ (fun x hx y hy _ => by
        simp only [mem_insert, mem_singleton] at hx hy
        rcases hx with rfl | rfl <;> rcases hy with rfl | rfl <;> rfl), sub_zero]
  · rw [channel_trinomial _ (by
      intro p hp; simp only [mem_insert, mem_singleton] at hp
      rcases hp with rfl | rfl <;> norm_num)]
    have h5 : legendreSym 31 (5 : ℕ) = 1 := by
      rw [legendreSym.eq_one_iff 31 (by decide)]; exact ⟨6, by decide⟩
    have h11 : legendreSym 31 (11 : ℕ) = -1 := by
      rw [legendreSym.eq_neg_one_iff]; push_cast; decide
    rw [S3SignChannelUniversal.uEnt_const_fiber _ _ 1 ?_ (by simp)]
    · rw [show (#({5, 11} : Finset ℕ) : ℝ) = 2 by rfl]
      simp
    · intro a ha
      simp only [mem_insert, mem_singleton] at ha
      rw [card_eq_one]
      rcases ha with rfl | rfl
      · refine ⟨5, ?_⟩
        ext x; simp only [mem_filter, mem_insert, mem_singleton]
        constructor
        · rintro ⟨rfl | rfl, h⟩
          · rfl
          · push_cast at h h5 h11; rw [h5, h11] at h; norm_num at h
        · rintro rfl; exact ⟨Or.inl rfl, rfl⟩
      · refine ⟨11, ?_⟩
        ext x; simp only [mem_filter, mem_insert, mem_singleton]
        constructor
        · rintro ⟨rfl | rfl, h⟩
          · push_cast at h h5 h11; rw [h5, h11] at h; norm_num at h
          · rfl
        · rintro rfl; exact ⟨Or.inr rfl, rfl⟩

end TrinomialConductor31