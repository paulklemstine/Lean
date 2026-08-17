/-
# Coverings of prime degree and cyclic characters

`FundamentalGroupCoveringCharacters` identified the connected *double* coverings of a
`K(G,1)` with the nonzero mod-two characters of `G`.  This file settles the odd-prime
analogue that was posed as the first next-cycle sub-conjecture of the thread:

* every **normal** subgroup of prime index `p` is the kernel of a surjection onto the
  cyclic group `C_p` (`charOfPrimeIndex`, `ker_charOfPrimeIndex`,
  `exists_surjective_char_of_prime_index`);
* conversely the kernel of any surjection onto `C_p` is a subgroup of index `p`
  (`index_ker_of_surjective_cyclic`);
* the character is unique only up to an automorphism of `C_p`
  (`char_eq_comp_of_ker_eq`), and the automorphism group of `C_p` has order `p - 1`
  (`card_mulAut_cyclic`), so exactly `p - 1` surjective characters share each kernel
  (`card_surjective_chars_with_ker`).

The `p = 2` case recovers the earlier results: `Aut(C₂)` is trivial (`2 - 1 = 1`), so a
mod-two character is determined by its kernel, which is why for double coverings "kernel"
and "character" are interchangeable, while for `p ≥ 3` they are not.

Covering-theoretically: connected degree-`p` coverings of a `K(G,1)` whose classifying
subgroup is normal — equivalently, the regular ones, with deck group `C_p` — correspond to
the `(p-1)`-element orbits of surjections `G ↠ C_p` under `Aut(C_p)`.
-/
import Mathlib
import Bridges.FundamentalGroupCoveringGalois
import Bridges.FundamentalGroupCoveringExamples
import Bridges.FundamentalGroupCoveringExactSequence

open CategoryTheory MulAction

namespace FundamentalGroupCovering

universe u

section PrimeIndex

variable {K : Type u} [Group K]

/-- The cyclic group of order `p`, written multiplicatively. -/
abbrev Cyc (p : ℕ) : Type := Multiplicative (ZMod p)

theorem card_Cyc (p : ℕ) [NeZero p] : Nat.card (Cyc p) = p := by
  show Nat.card (ZMod p) = p
  rw [Nat.card_eq_fintype_card, ZMod.card]

variable {p : ℕ} [hp : Fact p.Prime]

/-- **The character attached to a normal subgroup of prime index.**  The quotient by a
normal subgroup of index `p` is a group of order `p`, hence — `p` being prime — a copy of
`C_p`. -/
noncomputable def charOfPrimeIndex {H : Subgroup K} [H.Normal] (h : H.index = p) :
    K →* Cyc p :=
  haveI : NeZero p := ⟨hp.out.ne_zero⟩
  (mulEquivOfPrimeCardEq (G := K ⧸ H) (G' := Cyc p) (p := p)
      (by rw [← Subgroup.index_eq_card]; exact h) (card_Cyc p)).toMonoidHom.comp
    (QuotientGroup.mk' H)

theorem ker_charOfPrimeIndex {H : Subgroup K} [H.Normal] (h : H.index = p) :
    (charOfPrimeIndex h).ker = H := by
  haveI : NeZero p := ⟨hp.out.ne_zero⟩
  set e := mulEquivOfPrimeCardEq (G := K ⧸ H) (G' := Cyc p) (p := p)
      (by rw [← Subgroup.index_eq_card]; exact h) (card_Cyc p) with he
  ext g
  constructor
  · intro hg
    have hg' : e (QuotientGroup.mk' H g) = 1 := hg
    exact (QuotientGroup.eq_one_iff g).mp ((MulEquiv.map_eq_one_iff e).mp hg')
  · intro hg
    show e (QuotientGroup.mk' H g) = 1
    have hmk : (QuotientGroup.mk' H) g = 1 := (QuotientGroup.eq_one_iff g).mpr hg
    rw [hmk, map_one]

/-- Membership in a normal subgroup of prime index, read off from its character. -/
theorem charOfPrimeIndex_eq_one_iff {H : Subgroup K} [H.Normal] (h : H.index = p) (g : K) :
    charOfPrimeIndex h g = 1 ↔ g ∈ H :=
  SetLike.ext_iff.mp (ker_charOfPrimeIndex h) g

theorem charOfPrimeIndex_surjective {H : Subgroup K} [H.Normal] (h : H.index = p) :
    Function.Surjective (charOfPrimeIndex h) := by
  haveI : NeZero p := ⟨hp.out.ne_zero⟩
  exact (mulEquivOfPrimeCardEq (G := K ⧸ H) (G' := Cyc p) (p := p)
      (by rw [← Subgroup.index_eq_card]; exact h) (card_Cyc p)).surjective.comp
    (QuotientGroup.mk'_surjective H)

/-- **Every normal subgroup of prime index is the kernel of a surjection onto `C_p`.** -/
theorem exists_surjective_char_of_prime_index {H : Subgroup K} [H.Normal] (h : H.index = p) :
    ∃ chi : K →* Cyc p, Function.Surjective chi ∧ chi.ker = H :=
  ⟨charOfPrimeIndex h, charOfPrimeIndex_surjective h, ker_charOfPrimeIndex h⟩

/-- Conversely, the kernel of a surjection onto `C_p` has index `p`. -/
theorem index_ker_of_surjective_cyclic {chi : K →* Cyc p} (h : Function.Surjective chi) :
    chi.ker.index = p := by
  haveI : NeZero p := ⟨hp.out.ne_zero⟩
  rw [Subgroup.index_ker, MonoidHom.range_eq_top.mpr h, Subgroup.card_top, card_Cyc]

/-- A homomorphism into a group of prime order is either trivial or surjective. -/
theorem surjective_of_ne_one_of_prime_card {P : Type u} [Group P] (hcard : Nat.card P = p)
    {f : K →* P} (hf : f ≠ 1) : Function.Surjective f := by
  haveI : Fact (Nat.Prime (Nat.card P)) := ⟨by rw [hcard]; exact hp.out⟩
  have hne : f.range ≠ ⊥ := by
    intro hbot
    apply hf
    ext g
    have hmem : f g ∈ f.range := ⟨g, rfl⟩
    rw [hbot] at hmem
    simpa using hmem
  rw [← MonoidHom.range_eq_top]
  exact (Subgroup.eq_bot_or_eq_top_of_prime_card f.range).resolve_left hne

/-- **A surjective character is determined by its kernel up to an automorphism of `C_p`.**
This is the precise sense in which, for `p ≥ 3`, a covering of prime degree remembers less
than the character defining it. -/
theorem char_eq_comp_of_ker_eq {chi psi : K →* Cyc p} (hchi : Function.Surjective chi)
    (hpsi : Function.Surjective psi) (hker : chi.ker = psi.ker) :
    ∃ sigma : Cyc p ≃* Cyc p, psi = sigma.toMonoidHom.comp chi := by
  refine ⟨(QuotientGroup.quotientKerEquivOfSurjective chi hchi).symm.trans
    ((QuotientGroup.quotientMulEquivOfEq hker).trans
      (QuotientGroup.quotientKerEquivOfSurjective psi hpsi)), ?_⟩
  ext g
  show psi g = _
  have h1 : (QuotientGroup.quotientKerEquivOfSurjective chi hchi).symm (chi g)
      = (QuotientGroup.mk g : K ⧸ chi.ker) := by
    apply (QuotientGroup.quotientKerEquivOfSurjective chi hchi).symm_apply_eq.mpr
    simp [QuotientGroup.quotientKerEquivOfSurjective]
  simp only [MulEquiv.coe_toMonoidHom, MonoidHom.coe_comp, Function.comp_apply,
    MulEquiv.trans_apply, h1]
  rfl

/-! ## How many characters share a kernel -/

/-- The automorphism group of `C_p` has order `p - 1`. -/
theorem card_mulAut_cyclic : Nat.card (Cyc p ≃* Cyc p) = p - 1 := by
  haveI : NeZero p := ⟨hp.out.ne_zero⟩
  have h1 : Nat.card (Cyc p ≃* Cyc p) = Nat.card (AddAut (ZMod p)) :=
    Nat.card_congr (AddEquiv.toMultiplicative (G := ZMod p) (H := ZMod p)).symm
  have h2 : Nat.card (AddAut (ZMod p)) = Nat.card ((ZMod p)ˣ) :=
    Nat.card_congr (ZMod.AddAutEquivUnits p).toEquiv
  rw [h1, h2, Nat.card_eq_fintype_card, ZMod.card_units_eq_totient,
    Nat.totient_prime hp.out]

/-- **Exactly `p - 1` surjective characters have a given normal subgroup of index `p` as
their kernel.**  For `p = 2` this is the uniqueness statement `char_eq_of_ker_eq` of the
double-covering file (`2 - 1 = 1`); for odd `p` the fibre is genuinely larger, so the
passage from characters to coverings loses information. -/
theorem card_surjective_chars_with_ker {H : Subgroup K} [H.Normal] (h : H.index = p) :
    Nat.card {chi : K →* Cyc p // Function.Surjective chi ∧ chi.ker = H} = p - 1 := by
  classical
  set chi0 := charOfPrimeIndex h with hchi0
  have hchi0surj : Function.Surjective chi0 := charOfPrimeIndex_surjective h
  have hchi0ker : chi0.ker = H := ker_charOfPrimeIndex h
  -- the automorphisms of `C_p` act simply transitively on the characters with kernel `H`
  have hcomp : ∀ s : Cyc p ≃* Cyc p,
      Function.Surjective (s.toMonoidHom.comp chi0) ∧
        (s.toMonoidHom.comp chi0).ker = H := by
    intro s
    refine ⟨s.surjective.comp hchi0surj, ?_⟩
    ext g
    constructor
    · intro hg
      have hg' : s (chi0 g) = 1 := hg
      have : chi0 g = 1 := (MulEquiv.map_eq_one_iff s).mp hg'
      exact (charOfPrimeIndex_eq_one_iff h g).mp this
    · intro hg
      show s (chi0 g) = 1
      rw [(charOfPrimeIndex_eq_one_iff h g).mpr hg, map_one]
  set F : (Cyc p ≃* Cyc p) → {chi : K →* Cyc p // Function.Surjective chi ∧ chi.ker = H} :=
    fun s => ⟨s.toMonoidHom.comp chi0, hcomp s⟩ with hF
  have hinj : Function.Injective F := by
    intro s t hst
    have hst' : s.toMonoidHom.comp chi0 = t.toMonoidHom.comp chi0 :=
      congrArg Subtype.val hst
    apply MulEquiv.ext
    intro x
    obtain ⟨g, rfl⟩ := hchi0surj x
    exact congrArg (fun f => f g) hst'
  have hsurj : Function.Surjective F := by
    intro c
    obtain ⟨sigma, hsigma⟩ := char_eq_comp_of_ker_eq hchi0surj c.2.1
      (by rw [hchi0ker, c.2.2])
    exact ⟨sigma, Subtype.ext hsigma.symm⟩
  rw [← Nat.card_congr (Equiv.ofBijective F ⟨hinj, hsurj⟩), card_mulAut_cyclic]

/-! ## Coverings of minimal prime degree are regular -/

/-- **A covering of minimal prime degree is regular, and is classified by a character.**
If the degree of a connected covering of a `K(G,1)` equals the smallest prime factor of
`|G|`, then the classifying subgroup is automatically normal — so the covering is regular —
and it is the kernel of a surjection `G ↠ C_p`.  This is the exact extent to which the
mod-two picture (where `p = 2` is always minimal) generalises without extra hypotheses. -/
theorem normal_and_exists_char_of_index_eq_minFac {H : Subgroup K}
    (hprime : Nat.Prime (Nat.card K).minFac) (h : H.index = (Nat.card K).minFac) :
    H.Normal ∧ ∃ chi : K →* Cyc ((Nat.card K).minFac),
      Function.Surjective chi ∧ chi.ker = H := by
  haveI : Fact (Nat.Prime (Nat.card K).minFac) := ⟨hprime⟩
  haveI hnormal : H.Normal := Subgroup.normal_of_index_eq_minFac_card h
  exact ⟨hnormal, exists_surjective_char_of_prime_index h⟩

end PrimeIndex

end FundamentalGroupCovering