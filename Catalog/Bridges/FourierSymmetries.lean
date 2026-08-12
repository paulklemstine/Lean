import Bridges.SubgroupExtremals

/-!
# Symmetries of the uncertainty functional, and coset extremals

The naturality theorem of `Catalog/Bridges/FourierFunctorUncertainty.lean` singled out the unit
dilations of `ZMod N` as the arrows for which the Fourier transform is natural. The uncertainty
functional `Φ ↦ (|supp Φ|, |supp 𝓕Φ|)` is invariant under a larger group: translations,
modulations and unit dilations. This file proves that invariance and uses it to extend the
Donoho–Stark extremal family from subgroups to their cosets.

## Main results

* `FourierSymmetries.dft_translate`, `FourierSymmetries.dft_modulate` : the standard
  translation/modulation exchange rules for the discrete Fourier transform.
* `FourierSymmetries.support_pair_translate`, `support_pair_modulate`, `support_pair_dilate` :
  the pair of support sizes is invariant under the three symmetries.
* `FourierSymmetries.donoho_stark_extremal_coset` : every translate of a subgroup indicator is a
  Donoho–Stark extremal, `|supp Φ| * |supp 𝓕Φ| = N`.
-/

open Finset ZMod FourierUncertainty

namespace FourierSymmetries

variable {N : ℕ} [NeZero N]

/-! ## Translation and modulation -/

/-- Translating the input multiplies the transform by a character. -/
theorem dft_translate (Φ : ZMod N → ℂ) (a k : ZMod N) :
    𝓕 (fun j => Φ (j - a)) k = stdAddChar (-(a * k)) * 𝓕 Φ k := by
  rw [ZMod.dft_apply, ZMod.dft_apply, Finset.mul_sum]
  refine Fintype.sum_equiv (Equiv.subRight a) _ _ fun x => ?_
  simp only [Equiv.subRight_apply, smul_eq_mul]
  rw [← mul_assoc, ← AddChar.map_add_eq_mul]
  congr 2
  ring

/-- Modulating the input translates the transform. -/
theorem dft_modulate (Φ : ZMod N → ℂ) (b k : ZMod N) :
    𝓕 (fun j => stdAddChar (b * j) * Φ j) k = 𝓕 Φ (k - b) := by
  rw [ZMod.dft_apply, ZMod.dft_apply]
  refine Finset.sum_congr rfl fun j _ => ?_
  rw [smul_eq_mul, smul_eq_mul, ← mul_assoc, ← AddChar.map_add_eq_mul]
  congr 2
  ring

/-! ## Invariance of the pair of support sizes -/

theorem fsupport_translate (Φ : ZMod N → ℂ) (a : ZMod N) :
    fsupport (fun j => Φ (j - a)) = (fsupport Φ).image (· + a) := by
  classical
  ext j
  simp only [mem_fsupport, Finset.mem_image]
  constructor
  · intro h
    exact ⟨j - a, h, by ring⟩
  · rintro ⟨x, hx, rfl⟩
    simpa using hx

theorem card_fsupport_translate (Φ : ZMod N → ℂ) (a : ZMod N) :
    (fsupport (fun j => Φ (j - a))).card = (fsupport Φ).card := by
  rw [fsupport_translate, Finset.card_image_of_injective _ (add_left_injective a)]

theorem fsupport_dft_translate (Φ : ZMod N → ℂ) (a : ZMod N) :
    fsupport (𝓕 (fun j => Φ (j - a))) = fsupport (𝓕 Φ) := by
  classical
  ext k
  simp only [mem_fsupport, dft_translate]
  have hne : (stdAddChar (-(a * k)) : ℂ) ≠ 0 := by
    intro h
    have h1 : ‖stdAddChar (-(a * k))‖ = 1 := AddChar.norm_apply _ _
    rw [h] at h1
    simp at h1
  exact mul_ne_zero_iff.trans (and_iff_right hne)

/-- **Translation invariance of the uncertainty functional.** -/
theorem support_pair_translate (Φ : ZMod N → ℂ) (a : ZMod N) :
    (fsupport (fun j => Φ (j - a))).card * (fsupport (𝓕 (fun j => Φ (j - a)))).card
      = (fsupport Φ).card * (fsupport (𝓕 Φ)).card := by
  rw [card_fsupport_translate, fsupport_dft_translate]

theorem fsupport_modulate (Φ : ZMod N → ℂ) (b : ZMod N) :
    fsupport (fun j => stdAddChar (b * j) * Φ j) = fsupport Φ := by
  classical
  ext j
  simp only [mem_fsupport]
  have hne : (stdAddChar (b * j) : ℂ) ≠ 0 := by
    intro h
    have h1 : ‖stdAddChar (b * j)‖ = 1 := AddChar.norm_apply _ _
    rw [h] at h1
    simp at h1
  exact mul_ne_zero_iff.trans (and_iff_right hne)

theorem fsupport_dft_modulate (Φ : ZMod N → ℂ) (b : ZMod N) :
    fsupport (𝓕 (fun j => stdAddChar (b * j) * Φ j)) = (fsupport (𝓕 Φ)).image (· + b) := by
  classical
  ext k
  simp only [mem_fsupport, dft_modulate, Finset.mem_image]
  constructor
  · intro h
    exact ⟨k - b, h, by ring⟩
  · rintro ⟨x, hx, rfl⟩
    simpa using hx

/-- **Modulation invariance of the uncertainty functional.** -/
theorem support_pair_modulate (Φ : ZMod N → ℂ) (b : ZMod N) :
    (fsupport (fun j => stdAddChar (b * j) * Φ j)).card
        * (fsupport (𝓕 (fun j => stdAddChar (b * j) * Φ j))).card
      = (fsupport Φ).card * (fsupport (𝓕 Φ)).card := by
  rw [fsupport_modulate, fsupport_dft_modulate,
    Finset.card_image_of_injective _ (add_left_injective b)]

theorem fsupport_dilate (Φ : ZMod N → ℂ) (u : (ZMod N)ˣ) :
    fsupport (unitPullback u Φ) = (fsupport Φ).image (fun j => u⁻¹.val * j) := by
  classical
  ext j
  simp only [mem_fsupport, unitPullback_apply, Finset.mem_image]
  constructor
  · intro h
    refine ⟨u.val * j, h, ?_⟩
    rw [← mul_assoc]
    simp
  · rintro ⟨x, hx, rfl⟩
    rw [← mul_assoc]
    simpa using hx

theorem card_fsupport_dilate (Φ : ZMod N → ℂ) (u : (ZMod N)ˣ) :
    (fsupport (unitPullback u Φ)).card = (fsupport Φ).card := by
  rw [fsupport_dilate, Finset.card_image_of_injective]
  intro x y hxy
  have := congrArg (fun z => u.val * z) hxy
  simpa [← mul_assoc] using this

/-- **Dilation invariance of the uncertainty functional**, along the arrows for which the
Fourier transform was shown to be natural. -/
theorem support_pair_dilate (Φ : ZMod N → ℂ) (u : (ZMod N)ˣ) :
    (fsupport (unitPullback u Φ)).card * (fsupport (𝓕 (unitPullback u Φ))).card
      = (fsupport Φ).card * (fsupport (𝓕 Φ)).card := by
  rw [card_fsupport_dilate, dft_unitPullback, card_fsupport_dilate]

/-! ## Coset indicators are Donoho–Stark extremals -/

section Cosets

variable {d m : ℕ} [NeZero d] [NeZero m]

/-- **Every coset of a subgroup gives a Donoho–Stark extremal.** Translating the indicator of the
multiples of `d` in `ZMod (d * m)` by any `a` keeps the support product equal to `N = d * m`.
This extends the extremal family beyond deltas and subgroups. -/
theorem donoho_stark_extremal_coset (a : ZMod (d * m)) :
    (fsupport (fun j => SubgroupExtremals.indicator d m (j - a))).card
        * (fsupport (𝓕 (fun j => SubgroupExtremals.indicator d m (j - a)))).card
      = d * m := by
  rw [support_pair_translate]
  exact SubgroupExtremals.donoho_stark_extremal

end Cosets


/-! ## Rigidity at the endpoints of the Donoho–Stark inequality

The equality case of Donoho–Stark is expected to force the support to be a coset of a subgroup.
Here we prove the two extreme instances of that statement: a function concentrated at a single
point has a full spectrum, and conversely. -/

section Rigidity

variable {N : ℕ} [NeZero N]

theorem dft_of_single_support {Φ : ZMod N → ℂ} {a : ZMod N}
    (hsub : ∀ j, j ≠ a → Φ j = 0) (k : ZMod N) :
    𝓕 Φ k = stdAddChar (-(a * k)) * Φ a := by
  rw [ZMod.dft_apply, Finset.sum_eq_single a]
  · rw [smul_eq_mul]
  · intro b _ hb
    simp [hsub b hb]
  · intro h
    exact absurd (Finset.mem_univ a) h

/-- **A one-point function has a full spectrum.** This is the equality case of Donoho–Stark at
the extreme `|supp Φ| = 1`. -/
theorem full_spectrum_of_card_support_eq_one {Φ : ZMod N → ℂ}
    (h : (fsupport Φ).card = 1) : (fsupport (𝓕 Φ)).card = N := by
  classical
  obtain ⟨a, ha⟩ := Finset.card_eq_one.1 h
  have hsub : ∀ j, j ≠ a → Φ j = 0 := by
    intro j hj
    by_contra hjne
    have : j ∈ fsupport Φ := mem_fsupport.2 hjne
    rw [ha, Finset.mem_singleton] at this
    exact hj this
  have hane : Φ a ≠ 0 := by
    have : a ∈ fsupport Φ := by rw [ha]; exact Finset.mem_singleton_self a
    exact mem_fsupport.1 this
  have huniv : fsupport (𝓕 Φ) = Finset.univ := by
    ext k
    simp only [mem_fsupport, Finset.mem_univ, iff_true, dft_of_single_support hsub]
    refine mul_ne_zero ?_ hane
    intro hzero
    have h1 : ‖stdAddChar (-(a * k))‖ = 1 := AddChar.norm_apply _ _
    rw [hzero] at h1
    simp at h1
  rw [huniv, Finset.card_univ, ZMod.card]

theorem card_fsupport_dft_dft (Φ : ZMod N → ℂ) :
    (fsupport (𝓕 (𝓕 Φ))).card = (fsupport Φ).card := by
  classical
  have himg : fsupport (𝓕 (𝓕 Φ)) = (fsupport Φ).image (fun j => -j) := by
    ext j
    have hval : 𝓕 (𝓕 Φ) j = (N : ℂ) • Φ (-j) := congrFun (ZMod.dft_dft Φ) j
    simp only [mem_fsupport, hval, Finset.mem_image, smul_eq_mul, ne_eq, mul_eq_zero, not_or]
    have hN : (N : ℂ) ≠ 0 := Nat.cast_ne_zero.2 (NeZero.ne N)
    constructor
    · rintro ⟨-, h⟩
      exact ⟨-j, h, neg_neg j⟩
    · rintro ⟨x, hx, rfl⟩
      exact ⟨hN, by simpa using hx⟩
  rw [himg, Finset.card_image_of_injective _ neg_injective]

/-- **Dual rigidity.** A function whose spectrum is concentrated at a single point has full
support. -/
theorem full_support_of_card_spectrum_eq_one {Φ : ZMod N → ℂ}
    (h : (fsupport (𝓕 Φ)).card = 1) : (fsupport Φ).card = N := by
  have := full_spectrum_of_card_support_eq_one (Φ := 𝓕 Φ) h
  rwa [card_fsupport_dft_dft] at this

end Rigidity


end FourierSymmetries