/-
# Deck transformations, regular coverings and the universal cover of a `K(G,1)`

This file continues `Bridges/FundamentalGroupCoveringGalois.lean`.  Coverings of the
homotopy `1`-type `K(G,1)` are modelled by action groupoids of `G`-sets, a connected
covering corresponding to a transitive `G`-set `G ⧸ H`.  Here we compute its group of
deck transformations and identify the regular (normal) coverings and the universal
cover.

Main results:

* `deck_eq_one_of_fixed`: the deck group of a connected covering acts freely;
* `deckMulEquivNormalizerQuotient`: **the deck group of the covering `G ⧸ H` is
  `N_G(H) / H`**;
* `deck_transitive_iff_normal`: the covering is regular exactly when `H` is normal;
* `deckUniversalMulEquiv`: the deck group of the universal cover is `G` itself, and
  `universalCover_simply_connected` shows the universal cover is simply connected;
* `isFreeGroup_aut_of_isFreeGroup`: **every connected covering of a `K(F,1)` with `F`
  free is again a `K(F',1)` with `F'` free** (Nielsen–Schreier through the covering
  dictionary).
-/
import Mathlib
import Bridges.FundamentalGroupCoveringGalois

open CategoryTheory MulAction
open FundamentalGroupCompleteInvariant (ConnectedAt)

namespace FundamentalGroupCovering

universe u

variable {G : Type u} [Group G] {X : Type u} [MulAction G X]

/-! ## The deck transformation group -/

/-- The group of deck transformations of a covering: the equivariant permutations of the
fibre, equivalently the automorphisms of the covering over its base. -/
def DeckSubgroup (G : Type u) [Group G] (X : Type u) [MulAction G X] :
    Subgroup (Equiv.Perm X) where
  carrier := {f | ∀ (g : G) (x : X), f (g • x) = g • f x}
  one_mem' := by intro g x; rfl
  mul_mem' {f f'} hf hf' := by
    intro g x
    show f (f' (g • x)) = g • f (f' x)
    rw [hf' g x, hf g (f' x)]
  inv_mem' {f} hf := by
    intro g x
    apply f.injective
    show f (f.symm (g • x)) = f (g • f.symm x)
    rw [Equiv.apply_symm_apply, hf g (f.symm x), Equiv.apply_symm_apply]

theorem mem_deckSubgroup_iff (f : Equiv.Perm X) :
    f ∈ DeckSubgroup G X ↔ ∀ (g : G) (x : X), f (g • x) = g • f x := Iff.rfl

/-- **Deck transformations of a connected covering act freely**: one that fixes a single
point of the fibre is the identity. -/
theorem deck_eq_one_of_fixed [IsPretransitive G X] {f : Equiv.Perm X}
    (hf : f ∈ DeckSubgroup G X) {x : X} (hx : f x = x) : f = 1 := by
  ext u
  obtain ⟨g, rfl⟩ := IsPretransitive.exists_smul_eq (M := G) x u
  rw [hf g x, hx]
  rfl

/-- A deck transformation is determined by its value at one point of a connected covering. -/
theorem deck_eq_of_eq_at [IsPretransitive G X] {f f' : Equiv.Perm X}
    (hf : f ∈ DeckSubgroup G X) (hf' : f' ∈ DeckSubgroup G X) {x : X} (hx : f x = f' x) :
    f = f' := by
  have hmem : f'⁻¹ * f ∈ DeckSubgroup G X := mul_mem (inv_mem hf') hf
  have hfix : (f'⁻¹ * f) x = x := by
    show f'.symm (f x) = x
    rw [hx, Equiv.symm_apply_apply]
  have h1 := deck_eq_one_of_fixed hmem hfix
  have h2 := congrArg (fun p : Equiv.Perm X => f' * p) h1
  simpa [← mul_assoc] using h2

/-! ## The deck group of the covering `G ⧸ H` -/

section Quotient

variable (H : Subgroup G)

/-- Right translation by `n⁻¹` on `G ⧸ H`, for `n` in the normaliser of `H`. -/
def rtrans (n : H.normalizer) : G ⧸ H → G ⧸ H := fun q =>
  Quotient.liftOn' q (fun a => ((a * (n : G)⁻¹ : G) : G ⧸ H)) <| by
    intro a b hab
    have hab' : a⁻¹ * b ∈ H := QuotientGroup.leftRel_apply.mp hab
    apply QuotientGroup.eq.mpr
    have hrw : (a * (n : G)⁻¹)⁻¹ * (b * (n : G)⁻¹)
        = (n : G) * (a⁻¹ * b) * ((n : G))⁻¹ := by group
    rw [hrw]
    exact (Subgroup.mem_normalizer_iff.mp n.2 _).mp hab'

@[simp] theorem rtrans_mk (n : H.normalizer) (a : G) :
    rtrans H n ((a : G ⧸ H)) = ((a * (n : G)⁻¹ : G) : G ⧸ H) := rfl

theorem rtrans_comp (n m : H.normalizer) (q : G ⧸ H) :
    rtrans H n (rtrans H m q) = rtrans H (n * m) q := by
  refine QuotientGroup.induction_on q ?_
  intro a
  simp only [rtrans_mk, Subgroup.coe_mul]
  congr 1
  group

theorem rtrans_one (q : G ⧸ H) : rtrans H 1 q = q := by
  refine QuotientGroup.induction_on q ?_
  intro a
  simp [rtrans_mk]

/-- Right translation as a permutation of the fibre. -/
def rperm (n : H.normalizer) : Equiv.Perm (G ⧸ H) where
  toFun := rtrans H n
  invFun := rtrans H n⁻¹
  left_inv q := by rw [rtrans_comp, inv_mul_cancel, rtrans_one]
  right_inv q := by rw [rtrans_comp, mul_inv_cancel, rtrans_one]

@[simp] theorem rperm_mk (n : H.normalizer) (a : G) :
    rperm H n ((a : G ⧸ H)) = ((a * (n : G)⁻¹ : G) : G ⧸ H) := rfl

theorem rperm_mem_deck (n : H.normalizer) : rperm H n ∈ DeckSubgroup G (G ⧸ H) := by
  intro g q
  refine QuotientGroup.induction_on q ?_
  intro a
  show rperm H n (((g * a : G) : G ⧸ H)) = ((g * (a * (n : G)⁻¹) : G) : G ⧸ H)
  rw [rperm_mk, mul_assoc]

/-- The homomorphism from the normaliser of `H` to the deck group of the covering
`G ⧸ H`. -/
def deckHom : H.normalizer →* DeckSubgroup G (G ⧸ H) where
  toFun n := ⟨rperm H n, rperm_mem_deck H n⟩
  map_one' := by
    apply Subtype.ext
    ext q
    exact rtrans_one H q
  map_mul' n m := by
    apply Subtype.ext
    ext q
    exact (rtrans_comp H n m q).symm

@[simp] theorem deckHom_apply_mk (n : H.normalizer) (a : G) :
    ((deckHom H n : Equiv.Perm (G ⧸ H)) ((a : G ⧸ H))) = ((a * (n : G)⁻¹ : G) : G ⧸ H) := rfl

theorem deckHom_ker : (deckHom H).ker = H.subgroupOf H.normalizer := by
  ext n
  constructor
  · intro hn
    have hn1 : ((deckHom H n : Equiv.Perm (G ⧸ H)) (((1 : G) : G ⧸ H))) = ((1 : G) : G ⧸ H) := by
      rw [hn]; rfl
    rw [deckHom_apply_mk] at hn1
    have hmem : ((1 : G) * (n : G)⁻¹)⁻¹ * (1 : G) ∈ H := QuotientGroup.eq.mp hn1
    have : (n : G) ∈ H := by
      have hrw : ((1 : G) * (n : G)⁻¹)⁻¹ * (1 : G) = (n : G) := by group
      rwa [hrw] at hmem
    exact Subgroup.mem_subgroupOf.mpr this
  · intro hn
    have hnH : (n : G) ∈ H := Subgroup.mem_subgroupOf.mp hn
    apply Subtype.ext
    ext q
    refine QuotientGroup.induction_on q ?_
    intro a
    show ((a * (n : G)⁻¹ : G) : G ⧸ H) = ((a : G) : G ⧸ H)
    refine QuotientGroup.eq.mpr ?_
    have hrw : (a * (n : G)⁻¹)⁻¹ * a = (n : G) := by group
    rw [hrw]
    exact hnH

theorem deckHom_surjective : Function.Surjective (deckHom H) := by
  rintro ⟨f, hf⟩
  obtain ⟨a, ha⟩ : ∃ a : G, f (((1 : G) : G ⧸ H)) = ((a : G) : G ⧸ H) := by
    refine QuotientGroup.induction_on (f (((1 : G) : G ⧸ H))) ?_
    intro b
    exact ⟨b, rfl⟩
  have hfinv : f⁻¹ ∈ DeckSubgroup G (G ⧸ H) := inv_mem hf
  obtain ⟨b, hb⟩ : ∃ b : G, f⁻¹ (((1 : G) : G ⧸ H)) = ((b : G) : G ⧸ H) := by
    refine QuotientGroup.induction_on (f⁻¹ (((1 : G) : G ⧸ H))) ?_
    intro c
    exact ⟨c, rfl⟩
  have hcoe : ∀ g : G, ((g : G) : G ⧸ H) = g • (((1 : G) : G ⧸ H)) := by
    intro g
    show ((g : G) : G ⧸ H) = ((g * 1 : G) : G ⧸ H)
    rw [mul_one]
  have hval : ∀ g : G, f (((g : G) : G ⧸ H)) = ((g * a : G) : G ⧸ H) := by
    intro g
    rw [hcoe g, hf g, ha]
    rfl
  have hval' : ∀ g : G, f⁻¹ (((g : G) : G ⧸ H)) = ((g * b : G) : G ⧸ H) := by
    intro g
    rw [hcoe g, hfinv g, hb]
    rfl
  have hab : a * b ∈ H := by
    have hcomp : f⁻¹ (f (((1 : G) : G ⧸ H))) = ((1 : G) : G ⧸ H) := by
      show f.symm (f (((1 : G) : G ⧸ H))) = ((1 : G) : G ⧸ H)
      rw [Equiv.symm_apply_apply]
    rw [ha, hval'] at hcomp
    have hmem : (a * b)⁻¹ * (1 : G) ∈ H := QuotientGroup.eq.mp hcomp
    have hrw : (a * b)⁻¹ * (1 : G) = (a * b)⁻¹ := by group
    rw [hrw] at hmem
    simpa using inv_mem hmem
  have hconj : ∀ h : G, h ∈ H → a⁻¹ * h * a ∈ H := by
    intro h hh
    have heq : (((h : G) : G ⧸ H)) = (((1 : G) : G ⧸ H)) := by
      refine QuotientGroup.eq.mpr ?_
      have hrw : h⁻¹ * (1 : G) = h⁻¹ := by group
      rw [hrw]
      exact inv_mem hh
    have h1 : f (((h : G) : G ⧸ H)) = f (((1 : G) : G ⧸ H)) := by rw [heq]
    rw [hval h, ha] at h1
    have hmem : (h * a)⁻¹ * a ∈ H := QuotientGroup.eq.mp h1
    have h2 := inv_mem hmem
    have hrw : ((h * a)⁻¹ * a)⁻¹ = a⁻¹ * h * a := by group
    rwa [hrw] at h2
  have hconj' : ∀ h : G, h ∈ H → b⁻¹ * h * b ∈ H := by
    intro h hh
    have heq : (((h : G) : G ⧸ H)) = (((1 : G) : G ⧸ H)) := by
      refine QuotientGroup.eq.mpr ?_
      have hrw : h⁻¹ * (1 : G) = h⁻¹ := by group
      rw [hrw]
      exact inv_mem hh
    have h1 : f⁻¹ (((h : G) : G ⧸ H)) = f⁻¹ (((1 : G) : G ⧸ H)) := by rw [heq]
    rw [hval' h, hb] at h1
    have hmem : (h * b)⁻¹ * b ∈ H := QuotientGroup.eq.mp h1
    have h2 := inv_mem hmem
    have hrw : ((h * b)⁻¹ * b)⁻¹ = b⁻¹ * h * b := by group
    rwa [hrw] at h2
  have hmem : a ∈ H.normalizer := by
    rw [Subgroup.mem_normalizer_iff]
    intro h
    constructor
    · intro hh
      have hb' : b⁻¹ * h * b ∈ H := hconj' h hh
      have hrw : a * h * a⁻¹ = (a * b) * (b⁻¹ * h * b) * (a * b)⁻¹ := by group
      rw [hrw]
      exact mul_mem (mul_mem hab hb') (inv_mem hab)
    · intro hh
      have := hconj _ hh
      have hrw : a⁻¹ * (a * h * a⁻¹) * a = h := by group
      rwa [hrw] at this
  refine ⟨⟨a⁻¹, inv_mem hmem⟩, ?_⟩
  apply Subtype.ext
  ext q
  refine QuotientGroup.induction_on q ?_
  intro g
  show ((g * ((a⁻¹ : G))⁻¹ : G) : G ⧸ H) = f (((g : G) : G ⧸ H))
  rw [hval g, inv_inv]

/-- **The deck transformation group of the covering `G ⧸ H` of a `K(G,1)` is `N_G(H)/H`.**
In topological language: the deck group of the covering of a `K(G,1)` classified by the
subgroup `H ≤ π₁` is the quotient of the normaliser of `H` by `H`. -/
noncomputable def deckMulEquivNormalizerQuotient :
    (H.normalizer ⧸ H.subgroupOf H.normalizer) ≃* DeckSubgroup G (G ⧸ H) :=
  (QuotientGroup.quotientMulEquivOfEq (deckHom_ker H).symm).trans
    (QuotientGroup.quotientKerEquivOfSurjective (deckHom H) (deckHom_surjective H))

/-- **A covering is regular exactly when its subgroup is normal.** -/
theorem deck_transitive_iff_normal :
    (∀ p q : G ⧸ H, ∃ f ∈ DeckSubgroup G (G ⧸ H), f p = q) ↔ H.Normal := by
  constructor
  · intro htr
    rw [← Subgroup.normalizer_eq_top_iff]
    refine eq_top_iff.mpr ?_
    intro g _
    obtain ⟨f, hfmem, hfg⟩ := htr (((1 : G) : G ⧸ H)) (((g : G) : G ⧸ H))
    obtain ⟨n, hn⟩ := deckHom_surjective H ⟨f, hfmem⟩
    have hnf : (rperm H n) = f := congrArg Subtype.val hn
    have hn' : rperm H n (((1 : G) : G ⧸ H)) = ((g : G) : G ⧸ H) := by
      rw [hnf]; exact hfg
    rw [rperm_mk] at hn'
    have hgn : ((1 : G) * (n : G)⁻¹)⁻¹ * g ∈ H := QuotientGroup.eq.mp hn'
    have hgn' : (n : G) * g ∈ H := by
      have hrw : ((1 : G) * (n : G)⁻¹)⁻¹ * g = (n : G) * g := by group
      rwa [hrw] at hgn
    have hg : g = (n : G)⁻¹ * ((n : G) * g) := by group
    rw [hg]
    exact mul_mem (inv_mem n.2) (Subgroup.le_normalizer hgn')
  · intro hnormal p q
    refine QuotientGroup.induction_on p ?_
    intro a
    refine QuotientGroup.induction_on q ?_
    intro b
    have hn : b⁻¹ * a ∈ H.normalizer := by
      rw [Subgroup.normalizer_eq_top_iff.mpr hnormal]; trivial
    refine ⟨rperm H ⟨b⁻¹ * a, hn⟩, rperm_mem_deck H _, ?_⟩
    rw [rperm_mk]
    congr 1
    show a * (b⁻¹ * a)⁻¹ = b
    group

end Quotient

/-! ## The universal cover -/

section Universal

variable (G)

/-- In the left-regular action every stabiliser is trivial: the universal cover is a
free `G`-set. -/
theorem stabilizer_regular_eq_bot (a : G) : stabilizer G a = ⊥ := by
  ext g
  simp only [mem_stabilizer_iff, smul_eq_mul, Subgroup.mem_bot]
  constructor
  · intro hg
    have h1 : g * a = 1 * a := by rw [hg, one_mul]
    exact mul_right_cancel h1
  · intro hg
    rw [hg, one_mul]

/-- **The universal cover is simply connected**: its fundamental group at any point of
the fibre is trivial. -/
theorem universalCover_simply_connected (a : G) :
    Subsingleton (Aut (ActionCategory.objEquiv G G a)) := by
  have h : Subsingleton (stabilizer G a) := by
    rw [stabilizer_regular_eq_bot]
    infer_instance
  exact (autMulEquivStabilizer a).toEquiv.subsingleton

/-- **The deck group of the universal cover of a `K(G,1)` is `G` itself.**  A deck
transformation of the left-regular action is right translation by a group element; the
inverse is taken so that the correspondence is a homomorphism rather than an
anti-homomorphism. -/
def deckUniversalMulEquiv : DeckSubgroup G G ≃* G where
  toFun f := ((f : Equiv.Perm G) 1)⁻¹
  invFun g := ⟨Equiv.mulRight g⁻¹, by
    intro a b
    show (a * b) * g⁻¹ = a * (b * g⁻¹)
    rw [mul_assoc]⟩
  left_inv f := by
    apply Subtype.ext
    ext a
    have h : (f : Equiv.Perm G) (a * 1) = a * (f : Equiv.Perm G) 1 := f.2 a 1
    rw [mul_one] at h
    show a * (((f : Equiv.Perm G) 1)⁻¹)⁻¹ = (f : Equiv.Perm G) a
    rw [inv_inv, h]
  right_inv g := by
    show ((1 : G) * g⁻¹)⁻¹ = g
    rw [one_mul, inv_inv]
  map_mul' f f' := by
    have h : (f : Equiv.Perm G) ((f' : Equiv.Perm G) 1 * 1)
        = (f' : Equiv.Perm G) 1 * (f : Equiv.Perm G) 1 := f.2 ((f' : Equiv.Perm G) 1) 1
    rw [mul_one] at h
    show ((f : Equiv.Perm G) ((f' : Equiv.Perm G) 1))⁻¹
        = ((f : Equiv.Perm G) 1)⁻¹ * ((f' : Equiv.Perm G) 1)⁻¹
    rw [h, mul_inv_rev]

end Universal

/-! ## Nielsen–Schreier through the covering dictionary -/

section Free

/-- **Every connected covering of a `K(F,1)` with `F` free is a `K(F',1)` with `F'` free.**
The fundamental group of the covering is a subgroup of the free group `G`, and subgroups
of free groups are free (Nielsen–Schreier). -/
theorem isFreeGroup_aut_of_isFreeGroup [IsFreeGroup G] (x : X) :
    IsFreeGroup (Aut (ActionCategory.objEquiv G X x)) :=
  IsFreeGroup.ofMulEquiv (autMulEquivStabilizer x).symm

end Free

end FundamentalGroupCovering