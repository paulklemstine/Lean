/-
# The four triple coverings of the torus

`FundamentalGroupCoveringTorus` determined the three connected double coverings of the
torus `K(ℤ²,1)`.  This file settles the degree-three case, the second next-cycle
sub-conjecture of the thread: the torus has **exactly four** connected triple coverings,
they are pairwise non-isomorphic, and all four total spaces are again tori.

The proof runs through the prime-index character theory of
`FundamentalGroupCoveringPrimeIndex`:

* a subgroup of index three of the abelian group `ℤ²` is normal, hence the kernel of a
  surjection `χ : ℤ² ↠ C₃` (`charOfPrimeIndex`);
* an additive character of `ℤ²` with values in `ZMod 3` is determined by its values
  `a, b` on the two standard generators (`chr3Add_eq`), so `χ = χ_{a,b}` for a unique
  nonzero pair `(a,b) ∈ (ZMod 3)²`;
* rescaling `(a,b) ↦ (2a,2b)` does not change the kernel (`ker_chr3_smul`), and the eight
  nonzero pairs fall into four such scaling classes, giving the four subgroups
  `TorusL10, TorusL01, TorusL11, TorusL12` (`torus_index_three_eq`);
* the four are pairwise distinct (`torus_L_distinct`) and — the base being abelian, so that
  conjugation is trivial — the four coverings are pairwise non-isomorphic
  (`torus_triple_coverings_pairwise_non_isomorphic`);
* each of the four subgroups is the image of an injective endomorphism of `ℤ²` of
  determinant `3`, so each total space is a torus (`torus_triple_covers_are_tori`).

Together with the degree-two result this confirms the predicted count `σ(n)` for `n = 2, 3`
(`σ(2) = 3`, `σ(3) = 4`) and gives, in degree three, the sharpest form of the failure of
π₁: four genuinely different coverings of the same space, all with homeomorphic total
spaces.
-/
import Mathlib
import Bridges.FundamentalGroupCoveringGalois
import Bridges.FundamentalGroupCoveringExamples
import Bridges.FundamentalGroupCoveringExactSequence
import Bridges.FundamentalGroupCoveringTwistedPair
import Bridges.FundamentalGroupCoveringTorus
import Bridges.FundamentalGroupCoveringPrimeIndex

open CategoryTheory MulAction

namespace FundamentalGroupCovering

section TorusTriple

/-- The mod-three character of `ℤ²` with coefficients `a, b`. -/
def chr3Add (a b : ZMod 3) : (ℤ × ℤ) →+ ZMod 3 :=
  AddMonoidHom.mk' (fun x => a * (x.1 : ZMod 3) + b * (x.2 : ZMod 3)) (by
    intro x y
    show a * (((x.1 + y.1 : ℤ)) : ZMod 3) + b * (((x.2 + y.2 : ℤ)) : ZMod 3) = _
    push_cast
    ring)

/-- The corresponding multiplicative character `ℤ² →* C₃` of the fundamental group of the
torus. -/
def chr3 (a b : ZMod 3) : Torus →* Cyc 3 :=
  AddMonoidHom.toMultiplicative (chr3Add a b)

theorem chr3_eq_one_iff (a b : ZMod 3) (x : Torus) :
    chr3 a b x = 1 ↔
      a * (((Multiplicative.toAdd x).1 : ZMod 3))
        + b * (((Multiplicative.toAdd x).2 : ZMod 3)) = 0 :=
  Iff.rfl

theorem mem_ker_chr3_iff (a b : ZMod 3) (x : Torus) :
    x ∈ (chr3 a b).ker ↔
      a * (((Multiplicative.toAdd x).1 : ZMod 3))
        + b * (((Multiplicative.toAdd x).2 : ZMod 3)) = 0 :=
  chr3_eq_one_iff a b x

/-- **An additive mod-three character of `ℤ²` is determined by its values on the two
standard generators.** -/
theorem chr3Add_eq (f : (ℤ × ℤ) →+ ZMod 3) : f = chr3Add (f (1, 0)) (f (0, 1)) := by
  ext x
  have hx : x = x.1 • ((1, 0) : ℤ × ℤ) + x.2 • ((0, 1) : ℤ × ℤ) := by
    apply Prod.ext <;> simp
  have hfx : f x = x.1 • f (1, 0) + x.2 • f (0, 1) := by
    conv_lhs => rw [hx]
    rw [map_add, map_zsmul, map_zsmul]
  rw [hfx]
  show x.1 • f (1, 0) + x.2 • f (0, 1)
      = f (1, 0) * ((x.1 : ℤ) : ZMod 3) + f (0, 1) * ((x.2 : ℤ) : ZMod 3)
  rw [zsmul_eq_mul, zsmul_eq_mul]
  ring

/-- Every multiplicative character of the torus is one of the `chr3 a b`. -/
theorem chr3_eq (chi : Torus →* Cyc 3) :
    chi = chr3 (Multiplicative.toAdd (chi (Multiplicative.ofAdd ((1, 0) : ℤ × ℤ))))
      (Multiplicative.toAdd (chi (Multiplicative.ofAdd ((0, 1) : ℤ × ℤ)))) := by
  set f : (ℤ × ℤ) →+ ZMod 3 := AddMonoidHom.toMultiplicative.symm chi with hf
  have hchi : chi = AddMonoidHom.toMultiplicative f := by
    rw [hf, Equiv.apply_symm_apply]
  have hfe := chr3Add_eq f
  rw [hchi, chr3]
  exact congrArg AddMonoidHom.toMultiplicative hfe

/-- Rescaling the coefficients by a nonzero element of `ZMod 3` does not change the
kernel. -/
theorem ker_chr3_smul {c : ZMod 3} (a b : ZMod 3) (hc : c ≠ 0) :
    (chr3 (c * a) (c * b)).ker = (chr3 a b).ker := by
  ext x
  rw [mem_ker_chr3_iff, mem_ker_chr3_iff]
  have hfactor : c * a * (((Multiplicative.toAdd x).1 : ZMod 3))
      + c * b * (((Multiplicative.toAdd x).2 : ZMod 3))
      = c * (a * (((Multiplicative.toAdd x).1 : ZMod 3))
        + b * (((Multiplicative.toAdd x).2 : ZMod 3))) := by ring
  rw [hfactor]
  constructor
  · intro h
    rcases mul_eq_zero.mp h with h' | h'
    · exact absurd h' hc
    · exact h'
  · intro h
    rw [h, mul_zero]

/-- The zero character is not surjective, so a surjective character has a nonzero
coefficient pair. -/
theorem chr3_coeffs_ne_zero {a b : ZMod 3} (h : Function.Surjective (chr3 a b)) :
    ¬ (a = 0 ∧ b = 0) := by
  rintro ⟨rfl, rfl⟩
  obtain ⟨x, hx⟩ := h (Multiplicative.ofAdd (1 : ZMod 3))
  have hx' : (0 : ZMod 3) * (((Multiplicative.toAdd x).1 : ZMod 3))
      + 0 * (((Multiplicative.toAdd x).2 : ZMod 3)) = 1 := hx
  rw [zero_mul, zero_mul, add_zero] at hx'
  exact absurd hx' (by decide)

/-! ## The four subgroups of index three -/

/-- First coordinate divisible by three. -/
def TorusL10 : Subgroup Torus := (chr3 1 0).ker

/-- Second coordinate divisible by three. -/
def TorusL01 : Subgroup Torus := (chr3 0 1).ker

/-- Coordinate sum divisible by three. -/
def TorusL11 : Subgroup Torus := (chr3 1 1).ker

/-- Coordinate difference divisible by three. -/
def TorusL12 : Subgroup Torus := (chr3 1 2).ker

theorem chr3_surjective {a b : ZMod 3} (h : ¬ (a = 0 ∧ b = 0)) :
    Function.Surjective (chr3 a b) := by
  haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  refine surjective_of_ne_one_of_prime_card (p := 3) (card_Cyc 3) ?_
  intro hone
  apply h
  constructor
  · have h1 : chr3 a b (Multiplicative.ofAdd ((1, 0) : ℤ × ℤ)) = 1 := by rw [hone]; rfl
    have h2 := (chr3_eq_one_iff a b (Multiplicative.ofAdd ((1, 0) : ℤ × ℤ))).mp h1
    simpa using h2
  · have h1 : chr3 a b (Multiplicative.ofAdd ((0, 1) : ℤ × ℤ)) = 1 := by rw [hone]; rfl
    have h2 := (chr3_eq_one_iff a b (Multiplicative.ofAdd ((0, 1) : ℤ × ℤ))).mp h1
    simpa using h2

theorem index_TorusL10 : TorusL10.index = 3 := by
  haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  exact index_ker_of_surjective_cyclic (chr3_surjective (by decide))

theorem index_TorusL01 : TorusL01.index = 3 := by
  haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  exact index_ker_of_surjective_cyclic (chr3_surjective (by decide))

theorem index_TorusL11 : TorusL11.index = 3 := by
  haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  exact index_ker_of_surjective_cyclic (chr3_surjective (by decide))

theorem index_TorusL12 : TorusL12.index = 3 := by
  haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  exact index_ker_of_surjective_cyclic (chr3_surjective (by decide))

/-! ## The eight nonzero coefficient pairs give four kernels -/

theorem zmod3_cases (c : ZMod 3) : c = 0 ∨ c = 1 ∨ c = 2 := by revert c; decide

theorem ker_chr3_20 : (chr3 2 0).ker = TorusL10 := by
  have h := ker_chr3_smul (c := 2) 1 0 (by decide)
  have e1 : (2 : ZMod 3) * 1 = 2 := by decide
  have e2 : (2 : ZMod 3) * 0 = 0 := by decide
  rw [e1, e2] at h
  exact h

theorem ker_chr3_02 : (chr3 0 2).ker = TorusL01 := by
  have h := ker_chr3_smul (c := 2) 0 1 (by decide)
  have e1 : (2 : ZMod 3) * 0 = 0 := by decide
  have e2 : (2 : ZMod 3) * 1 = 2 := by decide
  rw [e1, e2] at h
  exact h

theorem ker_chr3_22 : (chr3 2 2).ker = TorusL11 := by
  have h := ker_chr3_smul (c := 2) 1 1 (by decide)
  have e1 : (2 : ZMod 3) * 1 = 2 := by decide
  rw [e1] at h
  exact h

theorem ker_chr3_21 : (chr3 2 1).ker = TorusL12 := by
  have h := ker_chr3_smul (c := 2) 1 2 (by decide)
  have e1 : (2 : ZMod 3) * 1 = 2 := by decide
  have e2 : (2 : ZMod 3) * 2 = 1 := by decide
  rw [e1, e2] at h
  exact h

/-- **Every subgroup of index three of `ℤ²` is one of the four.** -/
theorem torus_index_three_eq {H : Subgroup Torus} (h : H.index = 3) :
    H = TorusL10 ∨ H = TorusL01 ∨ H = TorusL11 ∨ H = TorusL12 := by
  haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  obtain ⟨chi, hchisurj, hchiker⟩ := exists_surjective_char_of_prime_index (p := 3) h
  obtain ⟨a, b, hchi⟩ : ∃ a b : ZMod 3, chi = chr3 a b := ⟨_, _, chr3_eq chi⟩
  have hker : H = (chr3 a b).ker := by rw [← hchiker, hchi]
  have hsurj : Function.Surjective (chr3 a b) := by rw [← hchi]; exact hchisurj
  have hne := chr3_coeffs_ne_zero hsurj
  rcases zmod3_cases a with rfl | rfl | rfl <;> rcases zmod3_cases b with rfl | rfl | rfl
  · exact absurd ⟨rfl, rfl⟩ hne
  · exact Or.inr (Or.inl hker)
  · exact Or.inr (Or.inl (by rw [hker, ker_chr3_02]))
  · exact Or.inl hker
  · exact Or.inr (Or.inr (Or.inl hker))
  · exact Or.inr (Or.inr (Or.inr hker))
  · exact Or.inl (by rw [hker, ker_chr3_20])
  · exact Or.inr (Or.inr (Or.inr (by rw [hker, ker_chr3_21])))
  · exact Or.inr (Or.inr (Or.inl (by rw [hker, ker_chr3_22])))

/-! ## The four subgroups are distinct -/

theorem torus_L_distinct :
    TorusL10 ≠ TorusL01 ∧ TorusL10 ≠ TorusL11 ∧ TorusL10 ≠ TorusL12 ∧
      TorusL01 ≠ TorusL11 ∧ TorusL01 ≠ TorusL12 ∧ TorusL11 ≠ TorusL12 := by
  have h01_10 : Multiplicative.ofAdd ((0, 1) : ℤ × ℤ) ∈ TorusL10 := by
    rw [TorusL10, mem_ker_chr3_iff]; decide
  have h01_01 : Multiplicative.ofAdd ((0, 1) : ℤ × ℤ) ∉ TorusL01 := by
    rw [TorusL01, mem_ker_chr3_iff]; decide
  have h01_11 : Multiplicative.ofAdd ((0, 1) : ℤ × ℤ) ∉ TorusL11 := by
    rw [TorusL11, mem_ker_chr3_iff]; decide
  have h01_12 : Multiplicative.ofAdd ((0, 1) : ℤ × ℤ) ∉ TorusL12 := by
    rw [TorusL12, mem_ker_chr3_iff]; decide
  have h10_01 : Multiplicative.ofAdd ((1, 0) : ℤ × ℤ) ∈ TorusL01 := by
    rw [TorusL01, mem_ker_chr3_iff]; decide
  have h10_11 : Multiplicative.ofAdd ((1, 0) : ℤ × ℤ) ∉ TorusL11 := by
    rw [TorusL11, mem_ker_chr3_iff]; decide
  have h10_12 : Multiplicative.ofAdd ((1, 0) : ℤ × ℤ) ∉ TorusL12 := by
    rw [TorusL12, mem_ker_chr3_iff]; decide
  have h12_11 : Multiplicative.ofAdd ((1, 2) : ℤ × ℤ) ∈ TorusL11 := by
    rw [TorusL11, mem_ker_chr3_iff]; decide
  have h12_12 : Multiplicative.ofAdd ((1, 2) : ℤ × ℤ) ∉ TorusL12 := by
    rw [TorusL12, mem_ker_chr3_iff]; decide
  exact ⟨fun hc => h01_01 (hc ▸ h01_10), fun hc => h01_11 (hc ▸ h01_10),
    fun hc => h01_12 (hc ▸ h01_10), fun hc => h10_11 (hc ▸ h10_01),
    fun hc => h10_12 (hc ▸ h10_01), fun hc => h12_12 (hc ▸ h12_11)⟩

/-! ## The four coverings are pairwise non-isomorphic -/

/-- Over an abelian base, two coverings of quotient type are isomorphic exactly when the
two subgroups are equal: conjugation, the only freedom in the Galois correspondence, acts
trivially. -/
theorem comm_gEquiv_iff_eq {A : Type} [CommGroup A] (H L : Subgroup A) :
    Nonempty (GEquiv A (A ⧸ H) (A ⧸ L)) ↔ L = H := by
  rw [quotient_coverings_iso_iff_conj]
  constructor
  · rintro ⟨g, rfl⟩
    exact map_conj_eq_of_normal H g
  · intro hHL
    exact ⟨1, by rw [hHL, map_conj_eq_of_normal]⟩

theorem torus_triple_coverings_pairwise_non_isomorphic :
    ¬ Nonempty (GEquiv Torus (Torus ⧸ TorusL10) (Torus ⧸ TorusL01)) ∧
      ¬ Nonempty (GEquiv Torus (Torus ⧸ TorusL10) (Torus ⧸ TorusL11)) ∧
      ¬ Nonempty (GEquiv Torus (Torus ⧸ TorusL10) (Torus ⧸ TorusL12)) ∧
      ¬ Nonempty (GEquiv Torus (Torus ⧸ TorusL01) (Torus ⧸ TorusL11)) ∧
      ¬ Nonempty (GEquiv Torus (Torus ⧸ TorusL01) (Torus ⧸ TorusL12)) ∧
      ¬ Nonempty (GEquiv Torus (Torus ⧸ TorusL11) (Torus ⧸ TorusL12)) := by
  obtain ⟨h1, h2, h3, h4, h5, h6⟩ := torus_L_distinct
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;> rw [comm_gEquiv_iff_eq]
  · exact fun hc => h1 hc.symm
  · exact fun hc => h2 hc.symm
  · exact fun hc => h3 hc.symm
  · exact fun hc => h4 hc.symm
  · exact fun hc => h5 hc.symm
  · exact fun hc => h6 hc.symm

/-! ## All four total spaces are tori -/

/-- Multiples of three vanish mod three. -/
theorem cast_three_mul (z : ℤ) : ((3 * z : ℤ) : ZMod 3) = 0 := by
  push_cast
  simp [show ((3 : ZMod 3)) = 0 from by decide]

theorem range_torusHom_L10 : (torusHom 3 0 0 1).range = TorusL10 := by
  ext x
  rw [TorusL10, mem_ker_chr3_iff]
  constructor
  · rintro ⟨y, rfl⟩
    show (1 : ZMod 3) * (((3 * (Multiplicative.toAdd y).1
          + 0 * (Multiplicative.toAdd y).2 : ℤ) : ZMod 3))
        + (0 : ZMod 3) * (((0 * (Multiplicative.toAdd y).1
          + 1 * (Multiplicative.toAdd y).2 : ℤ) : ZMod 3)) = 0
    calc (1 : ZMod 3) * (((3 * (Multiplicative.toAdd y).1
            + 0 * (Multiplicative.toAdd y).2 : ℤ) : ZMod 3))
          + (0 : ZMod 3) * (((0 * (Multiplicative.toAdd y).1
            + 1 * (Multiplicative.toAdd y).2 : ℤ) : ZMod 3))
        = ((3 * (Multiplicative.toAdd y).1 : ℤ) : ZMod 3) := by push_cast; ring
      _ = 0 := cast_three_mul _
  · intro hx
    have h0 : (((Multiplicative.toAdd x).1 : ℤ) : ZMod 3) = 0 := by
      linear_combination hx
    obtain ⟨k, hk⟩ := (ZMod.intCast_zmod_eq_zero_iff_dvd _ 3).mp h0
    refine ⟨Multiplicative.ofAdd ((k, (Multiplicative.toAdd x).2) : ℤ × ℤ), ?_⟩
    apply Multiplicative.toAdd.injective
    apply Prod.ext
    · show 3 * k + 0 * (Multiplicative.toAdd x).2 = (Multiplicative.toAdd x).1
      rw [hk]; ring
    · show 0 * k + 1 * (Multiplicative.toAdd x).2 = (Multiplicative.toAdd x).2
      ring

theorem range_torusHom_L01 : (torusHom 1 0 0 3).range = TorusL01 := by
  ext x
  rw [TorusL01, mem_ker_chr3_iff]
  constructor
  · rintro ⟨y, rfl⟩
    show (0 : ZMod 3) * (((1 * (Multiplicative.toAdd y).1
          + 0 * (Multiplicative.toAdd y).2 : ℤ) : ZMod 3))
        + (1 : ZMod 3) * (((0 * (Multiplicative.toAdd y).1
          + 3 * (Multiplicative.toAdd y).2 : ℤ) : ZMod 3)) = 0
    calc (0 : ZMod 3) * (((1 * (Multiplicative.toAdd y).1
            + 0 * (Multiplicative.toAdd y).2 : ℤ) : ZMod 3))
          + (1 : ZMod 3) * (((0 * (Multiplicative.toAdd y).1
            + 3 * (Multiplicative.toAdd y).2 : ℤ) : ZMod 3))
        = ((3 * (Multiplicative.toAdd y).2 : ℤ) : ZMod 3) := by push_cast; ring
      _ = 0 := cast_three_mul _
  · intro hx
    have h0 : (((Multiplicative.toAdd x).2 : ℤ) : ZMod 3) = 0 := by
      linear_combination hx
    obtain ⟨k, hk⟩ := (ZMod.intCast_zmod_eq_zero_iff_dvd _ 3).mp h0
    refine ⟨Multiplicative.ofAdd (((Multiplicative.toAdd x).1, k) : ℤ × ℤ), ?_⟩
    apply Multiplicative.toAdd.injective
    apply Prod.ext
    · show 1 * (Multiplicative.toAdd x).1 + 0 * k = (Multiplicative.toAdd x).1
      ring
    · show 0 * (Multiplicative.toAdd x).1 + 3 * k = (Multiplicative.toAdd x).2
      rw [hk]; ring

theorem range_torusHom_L11 : (torusHom 1 0 (-1) 3).range = TorusL11 := by
  ext x
  rw [TorusL11, mem_ker_chr3_iff]
  constructor
  · rintro ⟨y, rfl⟩
    show (1 : ZMod 3) * (((1 * (Multiplicative.toAdd y).1
          + 0 * (Multiplicative.toAdd y).2 : ℤ) : ZMod 3))
        + (1 : ZMod 3) * ((((-1) * (Multiplicative.toAdd y).1
          + 3 * (Multiplicative.toAdd y).2 : ℤ) : ZMod 3)) = 0
    calc (1 : ZMod 3) * (((1 * (Multiplicative.toAdd y).1
            + 0 * (Multiplicative.toAdd y).2 : ℤ) : ZMod 3))
          + (1 : ZMod 3) * ((((-1) * (Multiplicative.toAdd y).1
            + 3 * (Multiplicative.toAdd y).2 : ℤ) : ZMod 3))
        = ((3 * (Multiplicative.toAdd y).2 : ℤ) : ZMod 3) := by push_cast; ring
      _ = 0 := cast_three_mul _
  · intro hx
    have h0 : ((((Multiplicative.toAdd x).1 + (Multiplicative.toAdd x).2 : ℤ)) : ZMod 3) = 0 := by
      push_cast; linear_combination hx
    obtain ⟨k, hk⟩ := (ZMod.intCast_zmod_eq_zero_iff_dvd _ 3).mp h0
    refine ⟨Multiplicative.ofAdd (((Multiplicative.toAdd x).1, k) : ℤ × ℤ), ?_⟩
    apply Multiplicative.toAdd.injective
    apply Prod.ext
    · show 1 * (Multiplicative.toAdd x).1 + 0 * k = (Multiplicative.toAdd x).1
      ring
    · show (-1) * (Multiplicative.toAdd x).1 + 3 * k = (Multiplicative.toAdd x).2
      push_cast at hk
      linarith

theorem range_torusHom_L12 : (torusHom 1 0 1 3).range = TorusL12 := by
  ext x
  rw [TorusL12, mem_ker_chr3_iff]
  constructor
  · rintro ⟨y, rfl⟩
    show (1 : ZMod 3) * (((1 * (Multiplicative.toAdd y).1
          + 0 * (Multiplicative.toAdd y).2 : ℤ) : ZMod 3))
        + (2 : ZMod 3) * (((1 * (Multiplicative.toAdd y).1
          + 3 * (Multiplicative.toAdd y).2 : ℤ) : ZMod 3)) = 0
    calc (1 : ZMod 3) * (((1 * (Multiplicative.toAdd y).1
            + 0 * (Multiplicative.toAdd y).2 : ℤ) : ZMod 3))
          + (2 : ZMod 3) * (((1 * (Multiplicative.toAdd y).1
            + 3 * (Multiplicative.toAdd y).2 : ℤ) : ZMod 3))
        = ((3 * ((Multiplicative.toAdd y).1 + 2 * (Multiplicative.toAdd y).2) : ℤ) : ZMod 3) := by
          push_cast; ring
      _ = 0 := cast_three_mul _
  · intro hx
    have h0 : ((((Multiplicative.toAdd x).1 + 2 * (Multiplicative.toAdd x).2 : ℤ)) : ZMod 3)
        = 0 := by push_cast; linear_combination hx
    obtain ⟨t, ht⟩ := (ZMod.intCast_zmod_eq_zero_iff_dvd _ 3).mp h0
    refine ⟨Multiplicative.ofAdd (((Multiplicative.toAdd x).1,
      (Multiplicative.toAdd x).2 - t) : ℤ × ℤ), ?_⟩
    apply Multiplicative.toAdd.injective
    apply Prod.ext
    · show 1 * (Multiplicative.toAdd x).1 + 0 * ((Multiplicative.toAdd x).2 - t)
        = (Multiplicative.toAdd x).1
      ring
    · show 1 * (Multiplicative.toAdd x).1 + 3 * ((Multiplicative.toAdd x).2 - t)
        = (Multiplicative.toAdd x).2
      push_cast at ht
      linarith

/-- **All four triple coverings of the torus are tori.** -/
theorem torus_triple_covers_are_tori :
    Nonempty (Torus ≃* TorusL10) ∧ Nonempty (Torus ≃* TorusL01) ∧
      Nonempty (Torus ≃* TorusL11) ∧ Nonempty (Torus ≃* TorusL12) := by
  refine ⟨⟨?_⟩, ⟨?_⟩, ⟨?_⟩, ⟨?_⟩⟩
  · exact (MonoidHom.ofInjective (torusHom_injective (a := 3) (b := 0) (c := 0) (d := 1)
      (by norm_num))).trans (MulEquiv.subgroupCongr range_torusHom_L10)
  · exact (MonoidHom.ofInjective (torusHom_injective (a := 1) (b := 0) (c := 0) (d := 3)
      (by norm_num))).trans (MulEquiv.subgroupCongr range_torusHom_L01)
  · exact (MonoidHom.ofInjective (torusHom_injective (a := 1) (b := 0) (c := -1) (d := 3)
      (by norm_num))).trans (MulEquiv.subgroupCongr range_torusHom_L11)
  · exact (MonoidHom.ofInjective (torusHom_injective (a := 1) (b := 0) (c := 1) (d := 3)
      (by norm_num))).trans (MulEquiv.subgroupCongr range_torusHom_L12)

/-- **The torus has exactly four connected triple coverings, they are pairwise
non-isomorphic, and all four total spaces are tori.** -/
theorem torus_four_triple_coverings :
    (TorusL10.index = 3 ∧ TorusL01.index = 3 ∧ TorusL11.index = 3 ∧ TorusL12.index = 3) ∧
      (∀ H : Subgroup Torus, H.index = 3 →
        H = TorusL10 ∨ H = TorusL01 ∨ H = TorusL11 ∨ H = TorusL12) ∧
      (¬ Nonempty (GEquiv Torus (Torus ⧸ TorusL10) (Torus ⧸ TorusL01)) ∧
        ¬ Nonempty (GEquiv Torus (Torus ⧸ TorusL10) (Torus ⧸ TorusL11)) ∧
        ¬ Nonempty (GEquiv Torus (Torus ⧸ TorusL10) (Torus ⧸ TorusL12)) ∧
        ¬ Nonempty (GEquiv Torus (Torus ⧸ TorusL01) (Torus ⧸ TorusL11)) ∧
        ¬ Nonempty (GEquiv Torus (Torus ⧸ TorusL01) (Torus ⧸ TorusL12)) ∧
        ¬ Nonempty (GEquiv Torus (Torus ⧸ TorusL11) (Torus ⧸ TorusL12))) ∧
      (Nonempty (Torus ≃* TorusL10) ∧ Nonempty (Torus ≃* TorusL01) ∧
        Nonempty (Torus ≃* TorusL11) ∧ Nonempty (Torus ≃* TorusL12)) :=
  ⟨⟨index_TorusL10, index_TorusL01, index_TorusL11, index_TorusL12⟩,
    fun _ h => torus_index_three_eq h, torus_triple_coverings_pairwise_non_isomorphic,
    torus_triple_covers_are_tori⟩

end TorusTriple

end FundamentalGroupCovering