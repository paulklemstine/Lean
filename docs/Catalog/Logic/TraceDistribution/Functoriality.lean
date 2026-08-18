/-
# Functoriality: the trace invariant is a Burnside-ring homomorphism

The trace distribution `{|X^g| : g ∈ G}` is the *unordered* shadow of the finer
pointwise invariant `g ↦ |X^g|`, the **mark** (or permutation-character) function of the
`G`-set `X`.  This file records the structural behaviour of the mark function under the
two operations that make the isomorphism classes of finite `G`-sets into the *Burnside
ring*:

* `fixedCard_prod` — `|(X × Y)^g| = |X^g| · |Y^g|` (multiplication);
* `fixedCard_sum` — `|(X ⊕ Y)^g| = |X^g| + |Y^g|` (addition);
* `fixedCard_of_equivariant_equiv` — invariance under equivariant bijections.

Combining these with the main theorem of `Logic.TraceDistribution.Core` yields a
genuinely two-sided statement (`orbitCount_prod_congr`, `orbitCount_sum_congr`):
*mark equivalence is a congruence for the Burnside-ring operations, and therefore the
whole orbit-count spectrum of a product or a coproduct is determined by the
orbit-count spectra of the factors.*

This is the sense in which Conjecture A is not an isolated identity but a statement
about a ring homomorphism: `X ↦ (g ↦ |X^g|)` from the Burnside ring `A(G)` to the ring
of `ℕ`-valued functions on `G`, and the orbit-count spectrum `k ↦ |X^k / G|` recovers
the image of `X` up to reordering.

## Lab notes (experimental data)

`G = ℤ/2`, `X = G` (regular, marks `(2, 0)`), `Y = Unit` (marks `(1, 1)`):

* `X × Y` has marks `(2·1, 0·1) = (2, 0)`, so `X × Y` is mark-equivalent to `X` —
  consistent with `X × Unit ≅ X`.
* `X ⊕ X` has marks `(4, 0)`; orbit counts `1, 2, 8, 32, …` (`= 4^k / 2` for `k ≥ 1`).
* `X ⊕ Y` has marks `(3, 1)`; orbit counts `1, 2, 5, 14, …` (`= (3^k + 1)/2`).
  Both `X ⊕ X` and `X ⊕ Y` have `4` points and `2` orbits, so the `k = 0` and `k = 1`
  counts agree; separation happens first at `k = 2` (`8` versus `5`), exactly as the
  threshold analysis predicts.
-/
import Mathlib
import Logic.TraceDistribution.Core

open MulAction Finset

namespace TraceDistribution

variable {G : Type*} [Group G]

/-! ## Fixed points of products and coproducts -/

/-- A pair is fixed exactly when both components are. -/
def fixedByProdEquiv (X Y : Type*) [MulAction G X] [MulAction G Y] (g : G) :
    fixedBy (X × Y) g ≃ (fixedBy X g × fixedBy Y g) where
  toFun p := ⟨⟨p.1.1, by have h := p.2; rw [mem_fixedBy] at h ⊢; exact congrArg Prod.fst h⟩,
              ⟨p.1.2, by have h := p.2; rw [mem_fixedBy] at h ⊢; exact congrArg Prod.snd h⟩⟩
  invFun p := ⟨(p.1.1, p.2.1), by
    rw [mem_fixedBy]
    exact Prod.ext p.1.2 p.2.2⟩
  left_inv p := by ext <;> rfl
  right_inv p := by ext <;> rfl

/-- An element of a disjoint union is fixed exactly when its representative is. -/
def fixedBySumEquiv (X Y : Type*) [MulAction G X] [MulAction G Y] (g : G) :
    fixedBy (X ⊕ Y) g ≃ (fixedBy X g ⊕ fixedBy Y g) where
  toFun := fun p => match p with
    | ⟨Sum.inl x, h⟩ => Sum.inl ⟨x, by
        rw [mem_fixedBy] at h ⊢
        exact Sum.inl_injective h⟩
    | ⟨Sum.inr y, h⟩ => Sum.inr ⟨y, by
        rw [mem_fixedBy] at h ⊢
        exact Sum.inr_injective h⟩
  invFun := fun p => match p with
    | Sum.inl x => ⟨Sum.inl x.1, by rw [mem_fixedBy]; exact congrArg Sum.inl x.2⟩
    | Sum.inr y => ⟨Sum.inr y.1, by rw [mem_fixedBy]; exact congrArg Sum.inr y.2⟩
  left_inv := by rintro ⟨x | y, h⟩ <;> rfl
  right_inv := by rintro (x | y) <;> rfl

/-- **Multiplicativity of marks.** -/
theorem fixedCard_prod (X Y : Type*) [MulAction G X] [MulAction G Y] (g : G) :
    fixedCard (X × Y) g = fixedCard X g * fixedCard Y g := by
  rw [fixedCard, Nat.card_congr (fixedByProdEquiv X Y g), Nat.card_prod, fixedCard, fixedCard]

/-- **Additivity of marks.** -/
theorem fixedCard_sum (X Y : Type*) [MulAction G X] [MulAction G Y]
    [Finite X] [Finite Y] (g : G) :
    fixedCard (X ⊕ Y) g = fixedCard X g + fixedCard Y g := by
  have _ : Finite (fixedBy X g) := Subtype.finite
  have _ : Finite (fixedBy Y g) := Subtype.finite
  rw [fixedCard, Nat.card_congr (fixedBySumEquiv X Y g), Nat.card_sum, fixedCard, fixedCard]

/-- Marks are invariant under equivariant bijections. -/
theorem fixedCard_of_equivariant_equiv {X Y : Type*} [MulAction G X] [MulAction G Y]
    (e : X ≃ Y) (he : ∀ (g : G) (x : X), e (g • x) = g • e x) (g : G) :
    fixedCard X g = fixedCard Y g := by
  refine Nat.card_congr ⟨fun x => ⟨e x.1, ?_⟩, fun y => ⟨e.symm y.1, ?_⟩, fun x => by simp,
    fun y => by simp⟩
  · have h := x.2
    rw [mem_fixedBy] at h ⊢
    rw [← he, h]
  · have h := y.2
    rw [mem_fixedBy] at h ⊢
    apply e.injective
    rw [he, Equiv.apply_symm_apply, h]

/-! ## Mark equivalence is a congruence -/

/-- Pointwise equality of marks is exactly equality of trace distributions "on the
nose", and hence gives agreement of the whole orbit-count spectrum. -/
theorem traceDistribution_eq_of_fixedCard_eq [Fintype G] (X Y : Type*)
    [MulAction G X] [MulAction G Y] (h : ∀ g : G, fixedCard X g = fixedCard Y g) :
    traceDistribution G X = traceDistribution G Y := by
  rw [traceDistribution, traceDistribution, funext h]

theorem orbitCount_eq_of_fixedCard_eq [Fintype G] (X Y : Type*)
    [MulAction G X] [MulAction G Y] [Finite X] [Finite Y]
    (h : ∀ g : G, fixedCard X g = fixedCard Y g) (k : ℕ) :
    orbitCount G X k = orbitCount G Y k :=
  card_orbits_eq_of_traceDistribution_eq X Y (traceDistribution_eq_of_fixedCard_eq X Y h) k

/-- **Congruence for products.**  If `X` is mark-equivalent to `X'` and `Y` to `Y'`,
then `X × Y` and `X' × Y'` have the same number of orbits on `k`-tuples, for every `k`. -/
theorem orbitCount_prod_congr [Fintype G] (X X' Y Y' : Type*)
    [MulAction G X] [MulAction G X'] [MulAction G Y] [MulAction G Y']
    [Finite X] [Finite X'] [Finite Y] [Finite Y']
    (hX : ∀ g : G, fixedCard X g = fixedCard X' g)
    (hY : ∀ g : G, fixedCard Y g = fixedCard Y' g) (k : ℕ) :
    orbitCount G (X × Y) k = orbitCount G (X' × Y') k := by
  refine orbitCount_eq_of_fixedCard_eq (X × Y) (X' × Y') (fun g => ?_) k
  rw [fixedCard_prod, fixedCard_prod, hX g, hY g]

/-- **Congruence for coproducts.** -/
theorem orbitCount_sum_congr [Fintype G] (X X' Y Y' : Type*)
    [MulAction G X] [MulAction G X'] [MulAction G Y] [MulAction G Y']
    [Finite X] [Finite X'] [Finite Y] [Finite Y']
    (hX : ∀ g : G, fixedCard X g = fixedCard X' g)
    (hY : ∀ g : G, fixedCard Y g = fixedCard Y' g) (k : ℕ) :
    orbitCount G (X ⊕ Y) k = orbitCount G (X' ⊕ Y') k := by
  refine orbitCount_eq_of_fixedCard_eq (X ⊕ Y) (X' ⊕ Y') (fun g => ?_) k
  rw [fixedCard_sum, fixedCard_sum, hX g, hY g]

end TraceDistribution