import Computation.FourierFunctor.Convolution

/-!
# Exactness of Pontryagin duality, and the character extension theorem

Third research cycle.  Having built the equivalence `pontryagin : FinAb ≌ FinAbᵒᵖ`
we now *use* it: an equivalence of categories preserves epimorphisms and
monomorphisms, so — once we identify monos with injections and epis with
surjections in `FinAb` — duality automatically converts injections into
surjections and surjections into injections.

* `FinAb.mono_iff_injective`, `FinAb.epi_iff_surjective` — the concrete
  description of monos and epis in `FinAb`.  Both directions are proved inside
  `FinAb` (the witnesses are the kernel subgroup and the quotient group, which
  are again finite abelian), so no ambient category is needed.
* `dual_surjective_of_injective`, `dual_injective_of_surjective` — **duality is
  exact**.
* `addChar_extend` — **the character extension theorem**: every character of a
  subgroup of a finite abelian group extends to the whole group.  This classical
  statement is here a *corollary of category theory*: it is the surjectivity of
  the dual of an inclusion.

-- !-- Lab Notes -- !--

* Hypothesizer (cycle 3): if `pontryagin` is a genuine equivalence, then all
  exactness properties of duality must be formal consequences, and the character
  extension theorem — usually proved by an explicit divisibility/Zorn argument —
  should fall out with no arithmetic at all.
* Experimenter: confirmed.  The only non-formal inputs are the two concrete
  characterisations of monos/epis in `FinAb`; their proofs use the kernel and
  the quotient as test objects.  After that, `Functor.PreservesEpimorphisms` for
  an equivalence does all the work.
* Analyst: this isolates *why* the extension theorem is true: not because `ℂˣ`
  is divisible (the usual proof), but because duality is an equivalence, which
  in turn holds because finite abelian groups have enough characters.  The two
  explanations meet at mathlib's `AddChar.doubleDualEmb_bijective`.
* Critic: `epi_iff_surjective` genuinely needs the quotient `H ⧸ range f` to be
  an object of `FinAb`; this is where finiteness is used, and it is why the
  argument does not transfer verbatim to arbitrary locally compact groups.
-/

open CategoryTheory AddChar

namespace FourierFunctor

namespace FinAb

/-- Monomorphisms in `FinAb` are exactly the injective homomorphisms. -/
theorem mono_iff_injective {G H : FinAb} (f : G ⟶ H) :
    Mono f ↔ Function.Injective (FinAb.hom f) := by
  constructor
  · intro hmono
    rw [injective_iff_map_eq_zero]
    intro x hx
    let K : AddSubgroup (FinAb.carrier G) := (FinAb.hom f).ker
    let Kobj : FinAb := FinAb.of (↥K)
    have hcomp : (FinAb.ofHom (K.subtype) : Kobj ⟶ G) ≫ f = (FinAb.ofHom 0 : Kobj ⟶ G) ≫ f := by
      ext k
      simp only [FinAb.hom_comp, AddMonoidHom.coe_comp, Function.comp_apply,
        ConcreteCategory.hom_ofHom, AddMonoidHom.zero_apply, map_zero]
      exact AddMonoidHom.mem_ker.1 k.2
    have hsub := hmono.right_cancellation _ _ hcomp
    have hzero : ((⟨x, hx⟩ : ↥K) : FinAb.carrier G) = 0 :=
      congrArg (fun (u : Kobj ⟶ G) => FinAb.hom u (show FinAb.carrier Kobj from
        (⟨x, hx⟩ : ↥K))) hsub
    exact hzero
  · intro hinj
    constructor
    intro Z u v huv
    ext z
    exact hinj (congrArg (fun (w : Z ⟶ H) => FinAb.hom w z) huv)

/-- Epimorphisms in `FinAb` are exactly the surjective homomorphisms. -/
theorem epi_iff_surjective {G H : FinAb} (f : G ⟶ H) :
    Epi f ↔ Function.Surjective (FinAb.hom f) := by
  constructor
  · intro hepi
    let K : AddSubgroup (FinAb.carrier H) := (FinAb.hom f).range
    let Q : FinAb := FinAb.of (FinAb.carrier H ⧸ K)
    have hcomp : f ≫ (FinAb.ofHom (QuotientAddGroup.mk' K) : H ⟶ Q)
        = f ≫ (FinAb.ofHom 0 : H ⟶ Q) := by
      ext x
      show (QuotientAddGroup.mk' K) (FinAb.hom f x) = 0
      exact (QuotientAddGroup.eq_zero_iff _).2 ⟨x, rfl⟩
    have hmk := hepi.left_cancellation _ _ hcomp
    intro y
    have hy : (QuotientAddGroup.mk' K) y = 0 :=
      congrArg (fun (u : H ⟶ Q) => FinAb.hom u y) hmk
    exact (QuotientAddGroup.eq_zero_iff _).1 hy
  · intro hsurj
    constructor
    intro Z u v huv
    ext y
    obtain ⟨x, rfl⟩ := hsurj y
    exact congrArg (fun (w : G ⟶ Z) => FinAb.hom w x) huv

end FinAb

/-! ### Exactness of duality -/

/-- **Duality turns injections into surjections.**  A purely categorical proof:
a mono becomes an epi in the opposite category, and the dual functor is an
equivalence, hence preserves epis. -/
theorem dual_surjective_of_injective {G H : FinAb} (f : H ⟶ G)
    (hf : Function.Injective (FinAb.hom f)) :
    Function.Surjective (FinAb.hom (dualFunctor.map (Quiver.Hom.op f))) := by
  have hmono : Mono f := (FinAb.mono_iff_injective f).2 hf
  have hepi : Epi (Quiver.Hom.op f) := inferInstance
  have : Epi (dualFunctor.map (Quiver.Hom.op f)) := dualFunctor.map_epi _
  exact (FinAb.epi_iff_surjective _).1 this

/-- **Duality turns surjections into injections.** -/
theorem dual_injective_of_surjective {G H : FinAb} (f : H ⟶ G)
    (hf : Function.Surjective (FinAb.hom f)) :
    Function.Injective (FinAb.hom (dualFunctor.map (Quiver.Hom.op f))) := by
  have hepi : Epi f := (FinAb.epi_iff_surjective f).2 hf
  have hmono : Mono (Quiver.Hom.op f) := inferInstance
  have : Mono (dualFunctor.map (Quiver.Hom.op f)) := dualFunctor.map_mono _
  exact (FinAb.mono_iff_injective _).1 this

/-- Type-level form of exactness: the dual of an injective homomorphism of
finite abelian groups is surjective. -/
theorem dualHom_surjective_of_injective {G H : Type} [AddCommGroup G] [Finite G]
    [AddCommGroup H] [Finite H] (φ : H →+ G) (hφ : Function.Injective φ) :
    Function.Surjective (dualHom φ) :=
  dual_surjective_of_injective (G := FinAb.of G) (H := FinAb.of H) (FinAb.ofHom φ) hφ

/-- Type-level form of exactness: the dual of a surjective homomorphism of
finite abelian groups is injective. -/
theorem dualHom_injective_of_surjective' {G H : Type} [AddCommGroup G] [Finite G]
    [AddCommGroup H] [Finite H] (φ : H →+ G) (hφ : Function.Surjective φ) :
    Function.Injective (dualHom φ) :=
  dual_injective_of_surjective (G := FinAb.of G) (H := FinAb.of H) (FinAb.ofHom φ) hφ

/-! ### The character extension theorem -/

/-- **Character extension theorem.**  Every character of a subgroup of a finite
abelian group is the restriction of a character of the whole group.  Proved as a
corollary of the exactness of Pontryagin duality. -/
theorem addChar_extend {G : Type} [AddCommGroup G] [Finite G] (K : AddSubgroup G)
    (χ : AddChar (↥K) ℂ) : ∃ ψ : AddChar G ℂ, ∀ k : ↥K, ψ (k : G) = χ k := by
  obtain ⟨ψ, hψ⟩ := dualHom_surjective_of_injective K.subtype Subtype.val_injective χ
  exact ⟨ψ, fun k => congrArg (fun (θ : AddChar (↥K) ℂ) => θ k) hψ⟩

/-! ### Annihilators -/

/-- The number of characters of a finite abelian group equals its order. -/
lemma nat_card_addChar {X : Type} [AddCommGroup X] [Finite X] :
    Nat.card (AddChar X ℂ) = Nat.card X := by
  have : Fintype X := Fintype.ofFinite X
  simp [Nat.card_eq_fintype_card, AddChar.card_eq (α := X)]

/-- The **annihilator** of a subgroup `K ≤ G`: the characters of `G` that are
trivial on `K`.  It is the kernel of the restriction map `Ĝ →+ K̂`. -/
noncomputable def annihilator {G : Type} [AddCommGroup G] [Finite G] (K : AddSubgroup G) :
    AddSubgroup (AddChar G ℂ) := (dualHom K.subtype).ker

lemma mem_annihilator {G : Type} [AddCommGroup G] [Finite G] {K : AddSubgroup G}
    {ψ : AddChar G ℂ} : ψ ∈ annihilator K ↔ ∀ k : ↥K, ψ (k : G) = 1 := by
  constructor
  · intro h k
    exact congrArg (fun (θ : AddChar (↥K) ℂ) => θ k) (AddMonoidHom.mem_ker.1 h)
  · intro h
    exact AddMonoidHom.mem_ker.2 (AddChar.ext _ _ fun k => h k)

/-- **Annihilator counting.**  For every subgroup `K` of a finite abelian group
`G`, the annihilator of `K` in `Ĝ` has exactly `|G| / |K|` elements; equivalently
`|K^⊥| · |K| = |G|`.  This is the quantitative form of exactness of duality. -/
theorem card_annihilator {G : Type} [AddCommGroup G] [Finite G] (K : AddSubgroup G) :
    Nat.card (annihilator K) * Nat.card ↥K = Nat.card G := by
  have hsurj : Function.Surjective (dualHom K.subtype) :=
    dualHom_surjective_of_injective K.subtype Subtype.val_injective
  have hsplit : Nat.card (AddChar G ℂ)
      = Nat.card (AddChar (↥K) ℂ) * Nat.card (dualHom K.subtype).ker := by
    rw [AddSubgroup.card_eq_card_quotient_mul_card_addSubgroup (dualHom K.subtype).ker]
    congr 1
    exact Nat.card_congr
      (QuotientAddGroup.quotientKerEquivOfSurjective _ hsurj).toEquiv
  rw [nat_card_addChar (X := G), nat_card_addChar (X := ↥K)] at hsplit
  rw [annihilator, mul_comm]
  exact hsplit.symm

end FourierFunctor