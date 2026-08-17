/-
# The torus has exactly `p + 1` coverings of prime degree `p`

`FundamentalGroupCoveringTorus` (degree two, three coverings) and
`FundamentalGroupCoveringTorusTriple` (degree three, four coverings) settled the first two
cases of the count `σ(n)` of connected `n`-sheeted coverings of the torus by explicit
enumeration.  This file proves the uniform prime statement, closing the prime part of
sub-conjecture **C2b** of the thread:

> the torus `K(ℤ²,1)` has exactly `p + 1` connected coverings of prime degree `p`, pairwise
> non-isomorphic, and every one of the total spaces is again a torus.

Since `σ(p) = p + 1` for prime `p`, the earlier counts `σ(2) = 3` and `σ(3) = 4` are the
cases `p = 2, 3`, and the answer no longer relies on any case analysis.

The proof is a counting argument that reuses the character theory of
`FundamentalGroupCoveringPrimeIndex`:

* a character `ℤ² →* C_p` is determined by its values `a, b ∈ ZMod p` on the two standard
  generators (`chrP_eq`), so the characters biject with pairs `(a, b)`, and a character is
  surjective exactly when `(a, b) ≠ (0,0)` (`surjective_chrP_iff`); hence there are
  `p² − 1` surjective characters (`card_surjective_chars_torus`);
* taking kernels maps the surjective characters onto the index-`p` subgroups
  (`kerMap_surjective`) with all fibres of size `p − 1` (`card_surjective_chars_with_ker`),
  so `(p² − 1) = (p + 1)(p − 1)` index-`p` subgroups' worth of characters gives exactly
  `p + 1` subgroups (`card_index_p_subgroups_torus`);
* the base is abelian, so conjugacy is equality (`abelian_gEquiv_iff_eq`) and the `p + 1`
  coverings are pairwise non-isomorphic, while each total space is a torus by
  `torus_finite_covering_is_torus` of `FundamentalGroupCoveringTorusFinite`.
-/
import Mathlib
import Bridges.FundamentalGroupCoveringGalois
import Bridges.FundamentalGroupCoveringTwistedPair
import Bridges.FundamentalGroupCoveringTorus
import Bridges.FundamentalGroupCoveringTorusFinite
import Bridges.FundamentalGroupCoveringPrimeIndex

open CategoryTheory MulAction

namespace FundamentalGroupCovering

/-! ## Over an abelian base, coverings are classified by subgroups on the nose -/

section Abelian

universe u

variable {K : Type u} [CommGroup K]

/-- **Over an abelian base, two connected coverings are isomorphic exactly when their
subgroups are equal.**  Conjugacy, the general answer, collapses to equality. -/
theorem abelian_gEquiv_iff_eq (H L : Subgroup K) :
    Nonempty (GEquiv K (K ⧸ H) (K ⧸ L)) ↔ L = H := by
  rw [quotient_coverings_iso_iff_conj]
  constructor
  · rintro ⟨g, rfl⟩
    exact map_conj_eq_of_normal H g
  · intro h
    exact ⟨1, by rw [h, map_conj_eq_of_normal]⟩

end Abelian

/-! ## Mod-`p` characters of the torus lattice -/

section TorusPrime

variable {p : ℕ} [hp : Fact p.Prime]

/-- The mod-`p` character of `ℤ²` with coefficients `a, b`. -/
def chrPAdd (a b : ZMod p) : (ℤ × ℤ) →+ ZMod p :=
  AddMonoidHom.mk' (fun x => a * (x.1 : ZMod p) + b * (x.2 : ZMod p)) (by
    intro x y
    show a * (((x.1 + y.1 : ℤ)) : ZMod p) + b * (((x.2 + y.2 : ℤ)) : ZMod p) = _
    push_cast
    ring)

/-- The corresponding multiplicative character `ℤ² →* C_p` of the fundamental group of the
torus. -/
def chrP (a b : ZMod p) : Torus →* Cyc p :=
  AddMonoidHom.toMultiplicative (chrPAdd a b)

theorem chrP_eq_one_iff (a b : ZMod p) (x : Torus) :
    chrP a b x = 1 ↔
      a * (((Multiplicative.toAdd x).1 : ZMod p))
        + b * (((Multiplicative.toAdd x).2 : ZMod p)) = 0 :=
  Iff.rfl

/-- **An additive mod-`p` character of `ℤ²` is determined by its values on the two standard
generators.** -/
theorem chrPAdd_eq (f : (ℤ × ℤ) →+ ZMod p) : f = chrPAdd (f (1, 0)) (f (0, 1)) := by
  ext x
  have hx : x = x.1 • ((1, 0) : ℤ × ℤ) + x.2 • ((0, 1) : ℤ × ℤ) := by
    apply Prod.ext <;> simp
  have hfx : f x = x.1 • f (1, 0) + x.2 • f (0, 1) := by
    conv_lhs => rw [hx]
    rw [map_add, map_zsmul, map_zsmul]
  rw [hfx]
  show x.1 • f (1, 0) + x.2 • f (0, 1)
      = f (1, 0) * ((x.1 : ℤ) : ZMod p) + f (0, 1) * ((x.2 : ℤ) : ZMod p)
  rw [zsmul_eq_mul, zsmul_eq_mul]
  ring

/-- The coefficient pair of a character: its values on the two standard generators. -/
def chrCoeffs (chi : Torus →* Cyc p) : ZMod p × ZMod p :=
  (Multiplicative.toAdd (chi (Multiplicative.ofAdd ((1, 0) : ℤ × ℤ))),
    Multiplicative.toAdd (chi (Multiplicative.ofAdd ((0, 1) : ℤ × ℤ))))

/-- Every multiplicative character of the torus is one of the `chrP a b`. -/
theorem chrP_eq (chi : Torus →* Cyc p) :
    chi = chrP (chrCoeffs chi).1 (chrCoeffs chi).2 := by
  set f : (ℤ × ℤ) →+ ZMod p := AddMonoidHom.toMultiplicative.symm chi with hf
  have hchi : chi = AddMonoidHom.toMultiplicative f := by
    rw [hf, Equiv.apply_symm_apply]
  have hfe := chrPAdd_eq f
  rw [hchi, chrP]
  exact congrArg AddMonoidHom.toMultiplicative hfe

theorem chrCoeffs_chrP (a b : ZMod p) : chrCoeffs (chrP a b) = (a, b) := by
  have h1 : (chrCoeffs (chrP a b)).1 = a := by
    show a * ((1 : ℤ) : ZMod p) + b * ((0 : ℤ) : ZMod p) = a
    push_cast
    ring
  have h2 : (chrCoeffs (chrP a b)).2 = b := by
    show a * ((0 : ℤ) : ZMod p) + b * ((1 : ℤ) : ZMod p) = b
    push_cast
    ring
  exact Prod.ext h1 h2

/-- **A mod-`p` character of the torus is surjective exactly when it is nonzero.** -/
theorem surjective_chrP_iff (a b : ZMod p) :
    Function.Surjective (chrP a b) ↔ (a, b) ≠ (0, 0) := by
  constructor
  · intro hsurj hab
    have ha : a = 0 := congrArg Prod.fst hab
    have hb : b = 0 := congrArg Prod.snd hab
    obtain ⟨x, hx⟩ := hsurj (Multiplicative.ofAdd (1 : ZMod p))
    have hx' : a * (((Multiplicative.toAdd x).1 : ZMod p))
        + b * (((Multiplicative.toAdd x).2 : ZMod p)) = 1 := hx
    rw [ha, hb, zero_mul, zero_mul, add_zero] at hx'
    haveI : NeZero p := ⟨hp.out.ne_zero⟩
    exact one_ne_zero hx'.symm
  · intro hab
    refine surjective_of_ne_one_of_prime_card (p := p) (card_Cyc p) ?_
    intro hone
    apply hab
    have h1 : chrP a b (Multiplicative.ofAdd ((1, 0) : ℤ × ℤ)) = 1 := by rw [hone]; rfl
    have h2 : chrP a b (Multiplicative.ofAdd ((0, 1) : ℤ × ℤ)) = 1 := by rw [hone]; rfl
    have ha : a = 0 := by
      have := (chrP_eq_one_iff a b (Multiplicative.ofAdd ((1, 0) : ℤ × ℤ))).mp h1
      simpa using this
    have hb : b = 0 := by
      have := (chrP_eq_one_iff a b (Multiplicative.ofAdd ((0, 1) : ℤ × ℤ))).mp h2
      simpa using this
    rw [ha, hb]

/-! ## Counting the surjective characters -/

/-- **The surjective mod-`p` characters of `ℤ²` biject with the nonzero pairs in
`(ZMod p)²`.** -/
def surjCharTorusEquiv :
    {chi : Torus →* Cyc p // Function.Surjective chi} ≃
      {ab : ZMod p × ZMod p // ab ≠ 0} where
  toFun chi := ⟨chrCoeffs chi.1, by
    intro h
    have hsurj : Function.Surjective (chrP (chrCoeffs chi.1).1 (chrCoeffs chi.1).2) := by
      rw [← chrP_eq chi.1]; exact chi.2
    exact (surjective_chrP_iff _ _).mp hsurj
      (Prod.ext (congrArg Prod.fst h) (congrArg Prod.snd h))⟩
  invFun ab := ⟨chrP ab.1.1 ab.1.2, (surjective_chrP_iff _ _).mpr (fun h =>
    ab.2 (Prod.ext (congrArg Prod.fst h) (congrArg Prod.snd h)))⟩
  left_inv chi := by
    apply Subtype.ext
    exact (chrP_eq chi.1).symm
  right_inv ab := by
    apply Subtype.ext
    show chrCoeffs (chrP (ab : ZMod p × ZMod p).1 (ab : ZMod p × ZMod p).2)
      = (ab : ZMod p × ZMod p)
    rw [chrCoeffs_chrP]

theorem card_surjective_chars_torus :
    Nat.card {chi : Torus →* Cyc p // Function.Surjective chi} = p * p - 1 := by
  haveI : NeZero p := ⟨hp.out.ne_zero⟩
  haveI : Fintype (ZMod p) := ZMod.fintype p
  rw [Nat.card_congr surjCharTorusEquiv]
  simp [Nat.card_eq_fintype_card, Fintype.card_subtype_compl, ZMod.card]

/-! ## Counting the subgroups of index `p` -/

/-- Taking kernels: from surjective characters to subgroups of index `p`. -/
def kerMap (chi : {chi : Torus →* Cyc p // Function.Surjective chi}) :
    {H : Subgroup Torus // H.index = p} :=
  ⟨chi.1.ker, index_ker_of_surjective_cyclic chi.2⟩

theorem kerMap_surjective : Function.Surjective (kerMap (p := p)) := by
  rintro ⟨H, hH⟩
  obtain ⟨chi, hchi, hker⟩ := exists_surjective_char_of_prime_index (K := Torus) (p := p) hH
  exact ⟨⟨chi, hchi⟩, Subtype.ext hker⟩

/-- The fibre of the kernel map over a subgroup `H` is the set of surjective characters
with kernel `H`, of size `p − 1`. -/
theorem card_fiber_kerMap (H : {H : Subgroup Torus // H.index = p}) :
    Nat.card {chi : {chi : Torus →* Cyc p // Function.Surjective chi} // kerMap chi = H}
      = p - 1 := by
  have hequiv :
      {chi : {chi : Torus →* Cyc p // Function.Surjective chi} // kerMap chi = H} ≃
        {chi : Torus →* Cyc p // Function.Surjective chi ∧ chi.ker = H.1} :=
    { toFun := fun c => ⟨c.1.1, c.1.2, congrArg Subtype.val c.2⟩
      invFun := fun c => ⟨⟨c.1, c.2.1⟩, Subtype.ext c.2.2⟩
      left_inv := fun _ => rfl
      right_inv := fun _ => rfl }
  rw [Nat.card_congr hequiv]
  exact card_surjective_chars_with_ker (K := Torus) (p := p) H.2

/-- **The torus has exactly `p + 1` subgroups of index `p`.** -/
theorem card_index_p_subgroups_torus :
    Nat.card {H : Subgroup Torus // H.index = p} = p + 1 := by
  classical
  haveI hfin : Finite {chi : Torus →* Cyc p // Function.Surjective chi} := by
    haveI : NeZero p := ⟨hp.out.ne_zero⟩
    haveI : Fintype (ZMod p) := ZMod.fintype p
    exact Finite.of_equiv _ surjCharTorusEquiv.symm
  haveI hfinH : Finite {H : Subgroup Torus // H.index = p} :=
    Finite.of_surjective _ kerMap_surjective
  haveI : Fintype {H : Subgroup Torus // H.index = p} := Fintype.ofFinite _
  -- the surjective characters fibre over the index-`p` subgroups with fibres of size `p-1`
  have hsum : Nat.card {chi : Torus →* Cyc p // Function.Surjective chi}
      = Nat.card {H : Subgroup Torus // H.index = p} * (p - 1) := by
    have h0 := Nat.card_congr (Equiv.sigmaFiberEquiv (kerMap (p := p))).symm
    rw [h0, Nat.card_sigma]
    simp [card_fiber_kerMap, Nat.card_eq_fintype_card, mul_comm]
  rw [card_surjective_chars_torus] at hsum
  have hp2 : 2 ≤ p := hp.out.two_le
  have hfact : (p + 1) * (p - 1) = p * p - 1 := by
    obtain ⟨q, rfl⟩ : ∃ q, p = q + 1 := ⟨p - 1, by omega⟩
    simp only [Nat.add_sub_cancel]
    ring_nf
    omega
  have hpos : 0 < p - 1 := by omega
  exact Nat.eq_of_mul_eq_mul_right hpos (by rw [hfact, ← hsum])

/-- Sanity check against the degree-two enumeration of `FundamentalGroupCoveringTorus`:
`σ(2) = 3`. -/
theorem card_index_two_subgroups_torus :
    Nat.card {H : Subgroup Torus // H.index = 2} = 3 := by
  haveI : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
  have h := card_index_p_subgroups_torus (p := 2)
  norm_num at h
  exact h

/-- Sanity check against the degree-three enumeration of
`FundamentalGroupCoveringTorusTriple`: `σ(3) = 4`. -/
theorem card_index_three_subgroups_torus :
    Nat.card {H : Subgroup Torus // H.index = 3} = 4 := by
  haveI : Fact (Nat.Prime 3) := ⟨Nat.prime_three⟩
  have h := card_index_p_subgroups_torus (p := 3)
  norm_num at h
  exact h

/-! ## The coverings -/

/-- **The complete degree-`p` classification for the torus.**  For every prime `p` the
torus has exactly `p + 1` connected `p`-sheeted coverings; they are pairwise
non-isomorphic (the base is abelian, so different subgroups give different coverings), and
the total space of each one is again a torus.  For `p = 2, 3` this recovers the counts
`σ(2) = 3` and `σ(3) = 4` proved earlier by enumeration. -/
theorem torus_prime_degree_classification :
    Nat.card {H : Subgroup Torus // H.index = p} = p + 1 ∧
      (∀ H L : {H : Subgroup Torus // H.index = p},
        Nonempty (GEquiv Torus (Torus ⧸ H.1) (Torus ⧸ L.1)) ↔ H = L) ∧
      (∀ H : {H : Subgroup Torus // H.index = p}, Nonempty (H.1 ≃* Torus)) := by
  refine ⟨card_index_p_subgroups_torus, ?_, ?_⟩
  · intro H L
    rw [abelian_gEquiv_iff_eq]
    constructor
    · intro h
      exact (Subtype.ext h.symm)
    · intro h
      rw [h]
  · intro H
    refine torus_finite_index_subgroup_mulEquiv ?_
    rw [H.2]
    exact hp.out.ne_zero

end TorusPrime

end FundamentalGroupCovering