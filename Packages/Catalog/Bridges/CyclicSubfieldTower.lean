/-
# The subfield tower is an information filtration

At conductor `13` the Galois group is `C₁₂`, so `Q(ζ₁₃)` has one subfield for each
divisor of `12`:

```
Q ⊂ Q(√13) ⊂ Q(ζ₁₃)⁺₄ ⊂ Q(ζ₁₃)        (degrees 1, 2, 4, 12)
Q ⊂ K₃     ⊂ K₆       ⊂ Q(ζ₁₃)        (degrees 1, 3, 6, 12)
```

`K₃` is the cyclic cubic field of the previous files.  The theorems here compare the
splitting-type channels of the different floors of this tower.

The key structural observation is that for `m ∣ m'` the splitting type in the
degree-`m` subfield is a *deterministic function* of the splitting type in the
degree-`m'` subfield:

`ordType m a = m / gcd (m' / ordType m' a, m)`,

which is the arithmetic shadow of the surjection of Galois groups `C m' ↠ C m`.
Combined with the data-processing inequality this gives

* `coarsen_ordType` — the explicit coarsening map;
* `typeEntropy_mono_of_dvd` — **entropy increases up the subfield tower**;
* `conductor13_tower_pinned` — every floor of the conductor-13 tower is fully
  pinned by the residue `p mod 13`;
* `conductor13_tower_gaps` — the exact rational gaps `H(T₆) - H(T₃) = 1`,
  `H(T₁₂) - H(T₆) = 1/2`, `H(T₁₂) - H(T₃) = 3/2`: all the `log₂ 3` content of the
  cubic floor is already present in every floor above it;
* `conductor13_crt_split` — `H(T₆) = H(T₂) + H(T₃)`, the CRT factorisation of the
  sextic floor into its quadratic and cubic parts;
* `cubic_information_share` — the cubic subfield carries between `37%` and `39%`
  of the information of the full cyclotomic channel.
-/
import Bridges.CyclicSubfieldUniformCover
import Shared.CyclicTypeChannelValues

namespace CyclicSubfield

open Finset hiding box
open CyclicTypeChannel

/-! ## 1. Coarsening along the tower -/

/-- Two-step gcd: for `m ∣ m'` the gcd with `m` factors through the gcd with `m'`. -/
theorem gcd_gcd_of_dvd {m m' : ℕ} (h : m ∣ m') (a : ℕ) :
    Nat.gcd (Nat.gcd a m') m = Nat.gcd a m := by
  refine Nat.dvd_antisymm ?_ ?_
  · exact Nat.dvd_gcd ((Nat.gcd_dvd_left _ _).trans (Nat.gcd_dvd_left a m'))
      (Nat.gcd_dvd_right _ _)
  · exact Nat.dvd_gcd (Nat.dvd_gcd (Nat.gcd_dvd_left a m) ((Nat.gcd_dvd_right a m).trans h))
      (Nat.gcd_dvd_right a m)

/-- The map that reads the degree-`m` splitting type off the degree-`m'` one. -/
def coarsen (m m' t : ℕ) : ℕ := m / Nat.gcd (m' / t) m

/-- **The splitting type of a subfield is a function of the splitting type of any
field above it.**  This is the arithmetic form of the Galois surjection
`C m' ↠ C m`. -/
theorem coarsen_ordType {m m' : ℕ} (hm' : 0 < m') (h : m ∣ m') (a : ℕ) :
    coarsen m m' (ordType m' a) = ordType m a := by
  have hg : Nat.gcd a m' ∣ m' := Nat.gcd_dvd_right a m'
  have hback : m' / ordType m' a = Nat.gcd a m' := by
    rw [ordType, Nat.div_div_self hg hm'.ne']
  rw [coarsen, hback, gcd_gcd_of_dvd h a, ordType]

/-- The pointwise identity as a factorisation of functions. -/
theorem ordType_eq_comp {m m' : ℕ} (hm' : 0 < m') (h : m ∣ m') :
    ordType m = coarsen m m' ∘ ordType m' := by
  funext a
  exact (coarsen_ordType hm' h a).symm

/-! ## 2. Monotonicity of the channel along the tower -/

/-- **Entropy increases up the subfield tower.**  If `K_m ⊆ K_{m'}` (that is
`m ∣ m'`), then the splitting-type channel of the smaller field carries no more
information than that of the bigger one.  The proof is data processing applied to
the explicit coarsening `coarsen m m'`. -/
theorem typeEntropy_mono_of_dvd {m m' : ℕ} (hm : 0 < m) (hm' : 0 < m') (h : m ∣ m') :
    typeEntropy m ≤ typeEntropy m' := by
  have h1 : uEnt (range m') (ordType m) = typeEntropy m :=
    subfield_typeEntropy_of_dvd hm hm' h
  have h2 : uEnt (range m') (coarsen m m' ∘ ordType m') ≤ uEnt (range m') (ordType m') :=
    uEnt_comp_le _ _ _
  rw [← ordType_eq_comp hm' h, h1] at h2
  exact h2

/-! ## 3. The conductor-13 tower -/

/-- **Every floor of the conductor-13 tower is fully pinned.**  For each divisor `m`
of `12` the residue `p mod 13` determines the splitting type of `p` in the
degree-`m` subfield, and the channel carries the full entropy `typeEntropy m`. -/
theorem conductor13_tower_pinned {m : ℕ} (hm : 0 < m) (hmd : m ∣ 12) :
    mutInfo (range 12) (ordType m) id = typeEntropy m :=
  subfield_full_pinning hm (by norm_num) hmd

/-- The conductor-13 tower is monotone: `H(T₁) ≤ H(T₃) ≤ H(T₆) ≤ H(T₁₂)`. -/
theorem conductor13_tower_monotone :
    typeEntropy 1 ≤ typeEntropy 3 ∧ typeEntropy 3 ≤ typeEntropy 6 ∧
      typeEntropy 6 ≤ typeEntropy 12 := by
  refine ⟨?_, ?_, ?_⟩
  · exact typeEntropy_mono_of_dvd (by norm_num) (by norm_num) (by norm_num)
  · exact typeEntropy_mono_of_dvd (by norm_num) (by norm_num) (by norm_num)
  · exact typeEntropy_mono_of_dvd (by norm_num) (by norm_num) (by norm_num)

/-- **The gaps of the conductor-13 tower are rational.**  Although `H(T₃)`, `H(T₆)`
and `H(T₁₂)` all contain `log₂ 3`, their successive differences are the rational
numbers `1`, `1/2` and `3/2`: passing from the cubic field to the sextic field adds
exactly one bit, and to the full cyclotomic field exactly `3/2` bits. -/
theorem conductor13_tower_gaps :
    typeEntropy 6 - typeEntropy 3 = 1 ∧
      typeEntropy 12 - typeEntropy 6 = 1 / 2 ∧
      typeEntropy 12 - typeEntropy 3 = 3 / 2 := by
  have h3 := typeEntropy_three
  have h6 := typeEntropy_val_6
  have h12 := typeEntropy_val_12
  refine ⟨by rw [h6, h3]; ring, by rw [h12, h6]; ring, by rw [h12, h3]; ring⟩

/-- Strictness: the sextic floor is strictly more informative than the cubic one. -/
theorem conductor13_cubic_lt_sextic : typeEntropy 3 < typeEntropy 6 := by
  have h := conductor13_tower_gaps.1
  linarith

/-- **CRT factorisation of the sextic floor.**  `H(T₆) = H(T₂) + H(T₃)`: the
quadratic subfield `Q(√13)` and the cubic subfield `K₃` contribute independently,
their entropies adding to that of their compositum. -/
theorem conductor13_crt_split : typeEntropy 6 = typeEntropy 2 + typeEntropy 3 := by
  rw [typeEntropy_val_6, typeEntropy_val_2, typeEntropy_three]
  ring

/-- The full cyclotomic channel at conductor `13` is worth strictly more than two
bits, while the cubic floor is worth less than one. -/
theorem conductor13_full_gt_two_bits : 2 < typeEntropy 12 := by
  rw [typeEntropy_val_12]
  have := CyclicCubic13.logb_three_gt_84_53
  linarith

/-- **The information share of the cubic subfield.**  The cubic floor carries
between `37%` and `39%` of the entropy of the full conductor-13 channel. -/
theorem cubic_information_share :
    (0.37 : ℝ) < typeEntropy 3 / typeEntropy 12 ∧
      typeEntropy 3 / typeEntropy 12 < 0.39 := by
  have hlo := CyclicCubic13.logb_three_gt_84_53
  have hhi := CyclicCubic13.logb_three_lt_65_41
  have h3 := typeEntropy_three
  have h12 := typeEntropy_val_12
  have hden : (0 : ℝ) < typeEntropy 12 := by rw [h12]; linarith
  constructor
  · rw [lt_div_iff₀ hden, h3, h12]
    nlinarith
  · rw [div_lt_iff₀ hden, h3, h12]
    nlinarith

end CyclicSubfield