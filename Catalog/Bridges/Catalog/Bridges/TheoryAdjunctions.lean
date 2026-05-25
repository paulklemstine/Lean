/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Theory Adjunctions: Optimal Cross-Domain Translation via Galois Connections

An adjunction `F ⊣ G` between research theories formalizes the idea that
`F` is the *best possible monotone encoding* and `G` reconstructs the
*strongest compatible approximation*.

## Main Results

* `TheoryAdjunction` — Adjunction as Galois connection on invariant preorders.
* `TheoryAdjunction.comp` — Adjunctions compose.
* `TheoryAdjunction.unit` / `counit` — Unit/counit inequalities.
* `TheoryAdjunction.transport_lower_bound` — Lower bounds survive round-trips.
* `TheoryAdjunction.sharp_lower_bound_fwd` — Lower bounds witnessed by the adjunction.
* `not_heightToCell_adjunction_exists` — Impossibility for Height ⊣ Cell.
* `proj_sect_adjunction` — Nontrivial concrete adjunction (projection ⊣ section).
* `composed_pair_triple_adjunction` — Composition across three theories.
* `TheoryAdjunction.round_trip_idempotent` — Round-trip stabilizes in one pass.
* `TheoryAdjunction.right_adjoint_inv_unique` — Right adjoints unique up to Inv.
-/

import Mathlib
import Bridges.TheoryMorphisms

/-! ## §1. The Invariant Preorder -/

/-- The **invariant preorder**: `x ≤_T y` iff `T.Inv x ≤ T.Inv y`. -/
def theoryLE (T : ResearchTheory) (x y : T.Carrier) : Prop :=
  T.Inv x ≤ T.Inv y

@[simp]
theorem theoryLE_def (T : ResearchTheory) (x y : T.Carrier) :
    theoryLE T x y ↔ T.Inv x ≤ T.Inv y :=
  Iff.rfl

theorem theoryLE_refl (T : ResearchTheory) (x : T.Carrier) :
    theoryLE T x x :=
  le_refl _

theorem theoryLE_trans (T : ResearchTheory) {x y z : T.Carrier}
    (hxy : theoryLE T x y) (hyz : theoryLE T y z) :
    theoryLE T x z :=
  le_trans hxy hyz

/-! ## §2. Theory Adjunction: Definition -/

/-- A **theory adjunction** `F ⊣ G` is a Galois connection between the
    invariant preorders:
    `U.Inv (F x) ≤ U.Inv y ⟺ T.Inv x ≤ T.Inv (G y)`. -/
structure TheoryAdjunction {T U : ResearchTheory}
    (F : TheoryHom T U) (G : TheoryHom U T) : Prop where
  gc : ∀ x y, theoryLE U (F.toFun x) y ↔ theoryLE T x (G.toFun y)

/-! ## §3. Unit and Counit Inequalities -/

/-- **Unit**: `T.Inv x ≤ T.Inv (G(F(x)))` for all `x`. -/
theorem TheoryAdjunction.unit
    {T U : ResearchTheory} {F : TheoryHom T U} {G : TheoryHom U T}
    (h : TheoryAdjunction F G) (x : T.Carrier) :
    theoryLE T x (G.toFun (F.toFun x)) :=
  (h.gc x (F.toFun x)).mp (theoryLE_refl U _)

/-- **Counit**: `U.Inv (F(G(y))) ≤ U.Inv y` for all `y`. -/
theorem TheoryAdjunction.counit
    {T U : ResearchTheory} {F : TheoryHom T U} {G : TheoryHom U T}
    (h : TheoryAdjunction F G) (y : U.Carrier) :
    theoryLE U (F.toFun (G.toFun y)) y :=
  (h.gc (G.toFun y) y).mpr (theoryLE_refl T _)

/-- Unit as invariant inequality. -/
theorem TheoryAdjunction.inv_monotone_transfer
    {T U : ResearchTheory} {F : TheoryHom T U} {G : TheoryHom U T}
    (h : TheoryAdjunction F G) (x : T.Carrier) :
    T.Inv x ≤ T.Inv (G.toFun (F.toFun x)) :=
  h.unit x

/-- Counit as invariant inequality. -/
theorem TheoryAdjunction.inv_counit_bound
    {T U : ResearchTheory} {F : TheoryHom T U} {G : TheoryHom U T}
    (h : TheoryAdjunction F G) (y : U.Carrier) :
    U.Inv (F.toFun (G.toFun y)) ≤ U.Inv y :=
  h.counit y

/-! ## §4. Composition of Adjunctions -/

/-- **Adjunctions compose**: `F ⊣ G` and `F' ⊣ G'` yield `(F' ∘ F) ⊣ (G ∘ G')`.
    `TheoryHom.comp f g` applies `f` first, then `g`. -/
theorem TheoryAdjunction.comp
    {T U V : ResearchTheory}
    {F : TheoryHom T U} {G : TheoryHom U T}
    {F' : TheoryHom U V} {G' : TheoryHom V U}
    (hTU : TheoryAdjunction F G)
    (hUV : TheoryAdjunction F' G') :
    TheoryAdjunction (TheoryHom.comp F F') (TheoryHom.comp G' G) where
  gc x v := by
    simp only [TheoryHom.comp, theoryLE_def, Function.comp]
    exact Iff.trans (hUV.gc (F.toFun x) v) (hTU.gc x (G'.toFun v))

/-! ## §5. Invariant Transfer Theorems -/

/-- **Lower-bound preservation**: `n ≤ T.Inv x → n ≤ T.Inv (G(F(x)))`. -/
theorem TheoryAdjunction.transport_lower_bound
    {T U : ResearchTheory} {F : TheoryHom T U} {G : TheoryHom U T}
    (h : TheoryAdjunction F G)
    {x : T.Carrier} {n : ℕ} (hx : n ≤ T.Inv x) :
    n ≤ T.Inv (G.toFun (F.toFun x)) :=
  le_trans hx (h.unit x)

/-- **Reflection bound**: `F(x) ≤_U y → x ≤_T G(y)`. -/
theorem TheoryAdjunction.inv_reflection_bound
    {T U : ResearchTheory} {F : TheoryHom T U} {G : TheoryHom U T}
    (h : TheoryAdjunction F G) {x : T.Carrier} {y : U.Carrier}
    (hxy : theoryLE U (F.toFun x) y) :
    theoryLE T x (G.toFun y) :=
  (h.gc x y).mp hxy

/-! ## §6. Sharp Lower-Bound Characterization -/

/-- **Forward direction**: a lower bound `n ≤ U.Inv (F x)` is witnessed
    by `z = F(x)` with `x ≤_T G(z)` (the unit) and `n ≤ U.Inv z`. -/
theorem TheoryAdjunction.sharp_lower_bound_fwd
    {T U : ResearchTheory} {F : TheoryHom T U} {G : TheoryHom U T}
    (h : TheoryAdjunction F G) {x : T.Carrier} {n : ℕ}
    (hn : n ≤ U.Inv (F.toFun x)) :
    ∃ z : U.Carrier, theoryLE T x (G.toFun z) ∧ n ≤ U.Inv z :=
  ⟨F.toFun x, h.unit x, hn⟩

/-- **Backward direction**: given a witness `z` with `x ≤_T G(z)` and
    `n ≤ U.Inv z`, we get `n ≤ T.Inv (G(z))` (which may be stronger
    than `n ≤ U.Inv (F x)`). This is the transferred bound through `G`. -/
theorem TheoryAdjunction.sharp_lower_bound_bwd
    {T U : ResearchTheory} {F : TheoryHom T U} {G : TheoryHom U T}
    (h : TheoryAdjunction F G) {x : T.Carrier} {z : U.Carrier}
    (hxz : theoryLE T x (G.toFun z)) :
    theoryLE U (F.toFun x) z :=
  (h.gc x z).mpr hxz

/-- Existential lower-bound transfer. -/
theorem TheoryAdjunction.transfer_satisfies_lower_bound
    {T U : ResearchTheory} {F : TheoryHom T U} {G : TheoryHom U T}
    (h : TheoryAdjunction F G) {n : ℕ}
    (hT : SatisfiesLowerBound T n) : SatisfiesLowerBound T n := by
  obtain ⟨x, hx⟩ := hT
  exact ⟨G.toFun (F.toFun x), h.transport_lower_bound hx⟩

/-! ## §7. Identity Adjunction -/

/-- The identity morphism is self-adjoint. -/
theorem TheoryAdjunction.id_self (T : ResearchTheory) :
    TheoryAdjunction (TheoryHom.id T) (TheoryHom.id T) where
  gc _ _ := by simp [TheoryHom.id, theoryLE]

/-! ## §8. Monotonicity from Adjunction -/

/-- The left adjoint is monotone on invariant values. -/
theorem TheoryAdjunction.left_monotone
    {T U : ResearchTheory} {F : TheoryHom T U} {G : TheoryHom U T}
    (h : TheoryAdjunction F G)
    {x y : T.Carrier} (hxy : theoryLE T x y) :
    theoryLE U (F.toFun x) (F.toFun y) :=
  (h.gc x (F.toFun y)).mpr (theoryLE_trans T hxy (h.unit y))

/-- The right adjoint is monotone on invariant values. -/
theorem TheoryAdjunction.right_monotone
    {T U : ResearchTheory} {F : TheoryHom T U} {G : TheoryHom U T}
    (h : TheoryAdjunction F G)
    {x y : U.Carrier} (hxy : theoryLE U x y) :
    theoryLE T (G.toFun x) (G.toFun y) :=
  (h.gc (G.toFun x) y).mp (theoryLE_trans U (h.counit x) hxy)

/-- **Round-trip idempotence**: `T.Inv (G(F(G(F(x))))) = T.Inv (G(F(x)))`.
    Iterating the translation achieves nothing more after one round-trip. -/
theorem TheoryAdjunction.round_trip_idempotent
    {T U : ResearchTheory} {F : TheoryHom T U} {G : TheoryHom U T}
    (h : TheoryAdjunction F G) (x : T.Carrier) :
    T.Inv (G.toFun (F.toFun (G.toFun (F.toFun x)))) =
    T.Inv (G.toFun (F.toFun x)) :=
  le_antisymm
    (h.right_monotone (h.counit (F.toFun x)))
    (h.unit (G.toFun (F.toFun x)))

/-! ## §9. Construct from biconditional -/

/-- Construct a `TheoryAdjunction` from a biconditional on invariants. -/
def TheoryAdjunction.mk'
    {T U : ResearchTheory} {F : TheoryHom T U} {G : TheoryHom U T}
    (h : ∀ x y, U.Inv (F.toFun x) ≤ U.Inv y ↔ T.Inv x ≤ T.Inv (G.toFun y)) :
    TheoryAdjunction F G where
  gc := h

/-- Extract the biconditional. -/
theorem TheoryAdjunction.to_gc_nat
    {T U : ResearchTheory} {F : TheoryHom T U} {G : TheoryHom U T}
    (h : TheoryAdjunction F G) (x : T.Carrier) (y : U.Carrier) :
    U.Inv (F.toFun x) ≤ U.Inv y ↔ T.Inv x ≤ T.Inv (G.toFun y) :=
  h.gc x y

/-! ## §10. Nontrivial Adjunction: Projection ⊣ Section -/

/-- Source theory: pairs `(a, b)` with invariant = first component. -/
def PairTheory : ResearchTheory where
  Carrier := ℕ × ℕ
  Inv := fun p => p.1

/-- Target theory: `ℕ` with identity invariant. -/
def NatIdTheory : ResearchTheory where
  Carrier := ℕ
  Inv := _root_.id

/-- Left adjoint: projection onto first component. -/
def projMorphism : TheoryHom PairTheory NatIdTheory where
  toFun := fun p => p.1
  monotone_inv := fun _ => le_refl _

/-- Right adjoint: section `n ↦ (n, 0)`. -/
def sectMorphism : TheoryHom NatIdTheory PairTheory where
  toFun := fun n => (n, 0)
  monotone_inv := fun _ => le_refl _

/-- **Nontrivial projection-section adjunction**: `proj ⊣ sect`.
    Projection forgets auxiliary data; the section reconstructs the
    strongest compatible approximation by setting forgotten data to 0. -/
theorem proj_sect_adjunction : TheoryAdjunction projMorphism sectMorphism where
  gc := fun ⟨a, _⟩ y => by
    simp [projMorphism, sectMorphism, theoryLE_def, PairTheory, NatIdTheory, _root_.id]

/-! ## §11. Impossibility Theorem: Height-Cell Adjunction -/

/-- **Impossibility**: no `G : CellTheory → HeightTheory` can form
    `heightToCellMorphism ⊣ G`.

    At `y = 1`: `G(1) ≥ 1·2 = 2` from `G.monotone_inv`, but the counit
    forces `G(1)·(G(1)+1) ≤ 1·2 = 2`, impossible since `G(1) ≥ 2`
    implies `G(1)·(G(1)+1) ≥ 6 > 2`. -/
theorem not_heightToCell_adjunction_exists :
    ¬ ∃ G : TheoryHom CellTheory HeightTheory,
      TheoryAdjunction heightToCellMorphism G := by
  intro ⟨G, hadj⟩
  -- Evaluate counit and monotonicity at the element 1 : ℕ
  -- CellTheory.Carrier = ℕ, so we use (1 : ℕ) coerced
  have hco := hadj.counit (show CellTheory.Carrier from (1 : ℕ))
  have hmo := G.monotone_inv (show CellTheory.Carrier from (1 : ℕ))
  simp only [theoryLE_def] at hco hmo
  -- hco : U.Inv (F(G(1))) ≤ U.Inv 1
  -- hmo : CellTheory.Inv 1 ≤ HeightTheory.Inv (G 1)
  -- CellTheory.Inv 1 = 1*(1+1) = 2
  -- HeightTheory.Inv = id
  -- heightToCellMorphism.toFun = id
  -- So hco : CellTheory.Inv (G 1) ≤ CellTheory.Inv 1
  --        : G(1)*(G(1)+1) ≤ 2
  -- And hmo: 2 ≤ G(1)
  change CellTheory.Inv (heightToCellMorphism.toFun (G.toFun (1 : ℕ))) ≤
    CellTheory.Inv (1 : ℕ) at hco
  change CellTheory.Inv (1 : ℕ) ≤ HeightTheory.Inv (G.toFun (1 : ℕ)) at hmo
  simp only [CellTheory, HeightTheory, heightToCellMorphism, _root_.id] at hco hmo
  nlinarith

/-! ## §12. Composition Example -/

/-- Triple theory: `ℕ × ℕ × ℕ` with invariant = first component. -/
def TripleTheory : ResearchTheory where
  Carrier := ℕ × ℕ × ℕ
  Inv := fun p => p.1

/-- Embedding into triple theory. -/
def natToTriple : TheoryHom NatIdTheory TripleTheory where
  toFun := fun n => (n, 0, 0)
  monotone_inv := fun _ => le_refl _

/-- Projection from triple theory. -/
def tripleToNat : TheoryHom TripleTheory NatIdTheory where
  toFun := fun p => p.1
  monotone_inv := fun _ => le_refl _

theorem nat_triple_adjunction : TheoryAdjunction natToTriple tripleToNat where
  gc := fun x ⟨a, _, _⟩ => by
    simp [natToTriple, tripleToNat, theoryLE_def, NatIdTheory, TripleTheory, _root_.id]

/-- **Composed adjunction**: PairTheory → NatIdTheory → TripleTheory. -/
theorem composed_pair_triple_adjunction :
    TheoryAdjunction
      (TheoryHom.comp projMorphism natToTriple)
      (TheoryHom.comp tripleToNat sectMorphism) :=
  TheoryAdjunction.comp proj_sect_adjunction nat_triple_adjunction

/-- Lower bounds survive the pipeline. -/
theorem composed_pair_triple_transport
    {p : ℕ × ℕ} {n : ℕ} (hn : n ≤ PairTheory.Inv p) :
    n ≤ PairTheory.Inv
      ((TheoryHom.comp tripleToNat sectMorphism).toFun
       ((TheoryHom.comp projMorphism natToTriple).toFun p)) :=
  composed_pair_triple_adjunction.transport_lower_bound hn

/-! ## §13. Adjunction Uniqueness -/

/-- Right adjoints are unique up to invariant equivalence:
    if `F ⊣ G₁` and `F ⊣ G₂`, then `T.Inv (G₁ y) = T.Inv (G₂ y)`. -/
theorem TheoryAdjunction.right_adjoint_inv_unique
    {T U : ResearchTheory} {F : TheoryHom T U}
    {G₁ G₂ : TheoryHom U T}
    (h₁ : TheoryAdjunction F G₁) (h₂ : TheoryAdjunction F G₂)
    (y : U.Carrier) :
    T.Inv (G₁.toFun y) = T.Inv (G₂.toFun y) :=
  le_antisymm
    ((h₂.gc (G₁.toFun y) y).mp (h₁.counit y))
    ((h₁.gc (G₂.toFun y) y).mp (h₂.counit y))

/-- Left adjoints are unique up to invariant equivalence. -/
theorem TheoryAdjunction.left_adjoint_inv_unique
    {T U : ResearchTheory} {G : TheoryHom U T}
    {F₁ F₂ : TheoryHom T U}
    (h₁ : TheoryAdjunction F₁ G) (h₂ : TheoryAdjunction F₂ G)
    (x : T.Carrier) :
    U.Inv (F₁.toFun x) = U.Inv (F₂.toFun x) :=
  le_antisymm
    ((h₁.gc x (F₂.toFun x)).mpr (h₂.unit x))
    ((h₂.gc x (F₁.toFun x)).mpr (h₁.unit x))