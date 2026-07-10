import Mathlib

/-!
# Isomorphisms of Meaning: When Structures Collide

This file formalizes, in the concrete setting of additive groups (and the cyclic
groups `ZMod n` in particular), the philosophical thesis that *isomorphic
structures preserve all structural truth yet fail to pin down the individual
"meaning" of their elements*.

The mathematical backbone is the observation that the collection of isomorphisms
between two isomorphic objects is a **torsor** over the automorphism group of
either endpoint.  Concretely:

* `autEquivIsoDom`, `isoEquivAutCod` — the "isomorphism of isomorphisms": the set
  of all identifications `G ≃+ H` is in canonical bijection with the automorphism
  group of the domain (and of the codomain), once *any one* identification is
  fixed.  There is no canonical basepoint, exactly as in a torsor.
* `iso_diff_by_aut`, `aut_unique_of_trans_eq` — any two identifications differ by
  a unique automorphism.

**Truth is preserved.**  Every structural predicate is transported across an
isomorphism:

* `transport_addOrderOf` — element orders are preserved;
* `transport_isAddCyclic` — cyclicity is preserved;
* `transport_card` — cardinality is preserved;
* `structural_invariance` — *any* isomorphism-invariant predicate `P` satisfies
  `P G ↔ P H`.  No formal system whose predicates respect isomorphism can tell
  `G` and `H` apart.

**Meaning is not preserved.**  The identification is genuinely ambiguous whenever
the automorphism group is nontrivial:

* `negAut_ne_refl` — negation is a nontrivial automorphism of `ZMod n` (`n ≥ 3`),
  so `+1` and `-1` play interchangeable structural roles: no formal predicate can
  distinguish them;
* `nonunique_identification` — a nontrivial automorphism yields a genuinely
  different identification;
* `card_aut_zmod`, `card_iso_to_zmod` — the number of distinct identifications of
  a cyclic group with `ZMod n` is exactly Euler's totient `φ(n)`.  "Meaning" is
  `φ(n)`-fold ambiguous.

**Structures that should not collide, do not.**  The order-spectrum invariant is
strong enough to *separate* non-isomorphic groups of equal size:

* `crtCollision` — the Chinese Remainder Theorem exhibits `ZMod 6` and
  `ZMod 2 × ZMod 3` as the *same* structure wearing two different faces;
* `no_iso_klein` — yet `ZMod 4` and the Klein four-group `ZMod 2 × ZMod 2` are
  *not* isomorphic, distinguished by whether an element of order `4` exists.

This is the number-theoretic shadow of Hofstadter's Copycat architecture: an
analogy ("do to `H` what the isomorphism does to `G`") is fixed only up to the
symmetry group of the target; the "slippage" between equally valid analogies is
measured precisely by the automorphism group.
-/

namespace IsoMeaning

variable {G H K : Type*} [AddGroup G] [AddGroup H] [AddGroup K]

/-! ## The isomorphism of isomorphisms (torsor structure) -/

/-- **Isomorphism of isomorphisms (domain version).**  Fixing one identification
`e : G ≃+ H`, the automorphisms of `G` are in canonical bijection with *all*
identifications `G ≃+ H`, via `u ↦ u.trans e`.  There is no distinguished
element: this is the torsor property. -/
def autEquivIsoDom (e : G ≃+ H) : (G ≃+ G) ≃ (G ≃+ H) where
  toFun u := u.trans e
  invFun f := f.trans e.symm
  left_inv u := by ext x; simp
  right_inv f := by ext x; simp

/-- **Isomorphism of isomorphisms (codomain version).**  The identifications
`G ≃+ H` are in canonical bijection with the automorphisms of the codomain `H`,
via `f ↦ e.symm.trans f`. -/
def isoEquivAutCod (e : G ≃+ H) : (G ≃+ H) ≃ (H ≃+ H) where
  toFun f := e.symm.trans f
  invFun u := e.trans u
  left_inv f := by ext x; simp
  right_inv u := by ext x; simp

/-- Any two identifications differ by an automorphism of the domain. -/
theorem iso_diff_by_aut (f g : G ≃+ H) : g = (g.trans f.symm).trans f := by
  ext x; simp

/-- The connecting automorphism is unique: right-composition with a fixed
isomorphism is injective. -/
theorem aut_unique_of_trans_eq (f : G ≃+ H) {u v : G ≃+ G}
    (h : u.trans f = v.trans f) : u = v := by
  ext x
  have := DFunLike.congr_fun h x
  simpa using f.injective this

/-! ## Truth is preserved: structural invariants transport -/

/-- Isomorphisms preserve the additive order of every element. -/
theorem transport_addOrderOf (e : G ≃+ H) (a : G) : addOrderOf (e a) = addOrderOf a := by
  simp

/-- Isomorphisms preserve cyclicity. -/
theorem transport_isAddCyclic (e : G ≃+ H) [IsAddCyclic G] : IsAddCyclic H :=
  isAddCyclic_of_surjective e e.surjective

/-- Isomorphisms preserve cardinality. -/
theorem transport_card (e : G ≃+ H) : Nat.card G = Nat.card H :=
  Nat.card_congr e.toEquiv

/-- **No formal system distinguishes isomorphic structures.**  Any predicate `P`
that respects isomorphism has the same truth value on isomorphic groups. -/
theorem structural_invariance {P : (X : Type) → [AddGroup X] → Prop}
    (hP : ∀ {A B : Type} [AddGroup A] [AddGroup B], (A ≃+ B) → P A → P B)
    {G H : Type} [AddGroup G] [AddGroup H] (e : G ≃+ H) : P G ↔ P H :=
  ⟨hP e, hP e.symm⟩

/-! ## Meaning is not preserved: ambiguity of the identification -/

/-- A nontrivial automorphism of the domain yields a genuinely different
identification: `u.trans f ≠ f`.  The correspondence of individual elements is
therefore not determined by the abstract structure. -/
theorem nonunique_identification (f : G ≃+ H) {u : G ≃+ G}
    (hu : u ≠ AddEquiv.refl G) : u.trans f ≠ f := by
  intro h
  apply hu
  have : u.trans f = (AddEquiv.refl G).trans f := by
    ext x; simpa using DFunLike.congr_fun h x
  exact aut_unique_of_trans_eq f this

/-! ## Number-theoretic incarnations -/

/-- Negation is a **nontrivial** automorphism of `ZMod n` for `n ≥ 3`: the
element `1` and its negation `-1` are structurally interchangeable, so no formal
predicate of the additive group can distinguish them. -/
theorem negAut_ne_refl (n : ℕ) (hn : 3 ≤ n) :
    AddEquiv.neg (ZMod n) ≠ AddEquiv.refl (ZMod n) := by
  intro h
  have h1 : (AddEquiv.neg (ZMod n)) (1 : ZMod n) = (AddEquiv.refl (ZMod n)) 1 :=
    DFunLike.congr_fun h 1
  simp only [AddEquiv.neg_apply, AddEquiv.coe_refl, id_eq] at h1
  have h2 : (2 : ZMod n) = 0 := by linear_combination -h1
  have h3 : (n : ℕ) ∣ 2 := by
    have hcast : ((2 : ℕ) : ZMod n) = 0 := by push_cast; exact h2
    exact (CharP.cast_eq_zero_iff (ZMod n) n 2).1 hcast
  have := Nat.le_of_dvd (by norm_num) h3
  omega

/-- For `n ≥ 3` there are (at least) two distinct self-identifications of
`ZMod n`: the identity and negation.  The abstract cyclic structure does not
single out either. -/
theorem two_distinct_self_isos (n : ℕ) (hn : 3 ≤ n) :
    (AddEquiv.neg (ZMod n)).trans (AddEquiv.refl (ZMod n)) ≠ AddEquiv.refl (ZMod n) :=
  nonunique_identification (AddEquiv.refl (ZMod n)) (negAut_ne_refl n hn)

/-- **Structures collide (CRT).**  The Chinese Remainder Theorem exhibits
`ZMod 6` and `ZMod 2 × ZMod 3` as one and the same additive structure wearing
two semantically different faces (a single residue vs. a pair of residues). -/
noncomputable def crtCollision : ZMod 6 ≃+ ZMod 2 × ZMod 3 :=
  (ZMod.chineseRemainder (show Nat.Coprime 2 3 by decide)).toAddEquiv

/-- The CRT collision preserves cardinality (a sanity check on transport). -/
theorem crtCollision_card : Nat.card (ZMod 6) = Nat.card (ZMod 2 × ZMod 3) :=
  transport_card crtCollision

/-- **The measure of ambiguity is Euler's totient.**  The number of
automorphisms of `ZMod n` — equivalently, the number of self-identifications —
is exactly `φ(n)`. -/
theorem card_aut_zmod (n : ℕ) [NeZero n] :
    Nat.card (ZMod n ≃+ ZMod n) = Nat.totient n := by
  have h1 : Nat.card (ZMod n ≃+ ZMod n) = Nat.card (ZMod n)ˣ :=
    Nat.card_congr (ZMod.AddAutEquivUnits n).toEquiv
  rw [h1, Nat.card_eq_fintype_card, ZMod.card_units_eq_totient]

/-- **Capstone.**  For *any* additive group `G` isomorphic to `ZMod n`, the number
of ways to identify `G` with `ZMod n` is exactly `φ(n)`.  The "meaning" carried
by such an identification is `φ(n)`-fold ambiguous, and no additional structural
data reduces the ambiguity. -/
theorem card_iso_to_zmod (n : ℕ) [NeZero n] (e : G ≃+ ZMod n) :
    Nat.card (G ≃+ ZMod n) = Nat.totient n := by
  have h : Nat.card (G ≃+ ZMod n) = Nat.card (ZMod n ≃+ ZMod n) :=
    Nat.card_congr (isoEquivAutCod e)
  rw [h, card_aut_zmod]

/-! ## Non-collision: structural invariants separate distinct structures -/

/-- Every element of the Klein four-group `ZMod 2 × ZMod 2` is `2`-torsion. -/
theorem two_nsmul_klein (y : ZMod 2 × ZMod 2) : (2 : ℕ) • y = 0 := by
  revert y; decide

/-- **Structures that should not collide, do not.**  `ZMod 4` and the Klein
four-group `ZMod 2 × ZMod 2` have the same cardinality but are *not* isomorphic:
`ZMod 4` has an element of additive order `4`, while the Klein group has
exponent `2`.  Preserved truth (`transport_addOrderOf`) is exactly what makes the
two distinguishable. -/
theorem no_iso_klein : IsEmpty (ZMod 4 ≃+ ZMod 2 × ZMod 2) := by
  constructor
  intro e
  have h4 : addOrderOf (e 1) = 4 := by
    rw [transport_addOrderOf e 1, ZMod.addOrderOf_one]
  have hd : addOrderOf (e 1) ∣ 2 :=
    addOrderOf_dvd_iff_nsmul_eq_zero.2 (two_nsmul_klein (e 1))
  rw [h4] at hd
  have := Nat.le_of_dvd (by norm_num) hd
  omega

end IsoMeaning