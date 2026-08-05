/-
# Composition (substitution) of species

The central missing operation on species is *substitution*: an `(F ∘ G)`-structure on a
finite set `A` is a partition of `A` into nonempty blocks, an `F`-structure on the set of
blocks, and a `G`-structure on every block.

To keep transport of structure computable (and definitionally well behaved) we encode a
partition of `A` by the function that sends a point to the Boolean indicator of its
block; this is the structure `Blocking A` below.  Blocks are then the indicators in the
range of that function, and the elements of a block form a subtype of `A`.
-/
import Bridges.SpeciesPointing

noncomputable section

namespace SpeciesEGF

open scoped BigOperators
open PowerSeries

/-- A *blocking* of `A`: a partition of `A`, encoded by the map sending a point `a` to
the Boolean indicator `rel a` of the block containing `a`. -/
structure Blocking (A : Type) where
  /-- `rel a` is the indicator function of the block containing `a`. -/
  rel : A → A → Bool
  /-- Every point lies in its own block. -/
  self : ∀ a, rel a a = true
  /-- Two points in a common block have the same block. -/
  glue : ∀ a b, rel a b = true → rel b = rel a

namespace Blocking

variable {A B C : Type}

@[ext] theorem ext {p p' : Blocking A} (h : p.rel = p'.rel) : p = p' := by
  cases p; cases p'
  simp only at h
  subst h
  rfl

theorem symm' (p : Blocking A) {a b : A} (h : p.rel a b = true) : p.rel b a = true := by
  rw [p.glue a b h]; exact p.self a

theorem trans' (p : Blocking A) {a b c : A} (h : p.rel a b = true) (h' : p.rel b c = true) :
    p.rel a c = true := by
  rw [← p.glue a b h]; exact h'

/-- Transport of a blocking along a bijection. -/
def map (e : A ≃ B) (p : Blocking A) : Blocking B where
  rel b b' := p.rel (e.symm b) (e.symm b')
  self b := p.self _
  glue b b' h := by
    funext x
    exact congrFun (p.glue _ _ h) (e.symm x)

/-- The blocks of a blocking: the indicators that actually occur. -/
def Block (p : Blocking A) : Type := {c : A → Bool // ∃ a, p.rel a = c}

/-- The elements of a block, as a subtype of the underlying set. -/
abbrev Block.elems {p : Blocking A} (c : p.Block) : Type := {a : A // c.1 a = true}

/-- The block containing a given point. -/
def blockOf (p : Blocking A) (a : A) : p.Block := ⟨p.rel a, ⟨a, rfl⟩⟩

instance (p : Blocking A) [Finite A] : Finite p.Block := by
  unfold Block; infer_instance

instance [Finite A] : Finite (Blocking A) :=
  Finite.of_injective (fun p => p.rel) (by
    rintro ⟨r, h1, h2⟩ ⟨r', h1', h2'⟩ h
    simp only at h
    subst h
    rfl)

/-- Pulling a block of the transported blocking back along the bijection. -/
def Block.pull (e : A ≃ B) (p : Blocking A) (c : (p.map e).Block) : p.Block :=
  ⟨fun a => c.1 (e a), by
    obtain ⟨b, hb⟩ := c.2
    refine ⟨e.symm b, ?_⟩
    funext a
    have := congrFun hb (e a)
    simpa [map, Equiv.symm_apply_apply] using this⟩

/-- Transport of blocks along a bijection. -/
def blockEquiv (e : A ≃ B) (p : Blocking A) : p.Block ≃ (p.map e).Block where
  toFun c := ⟨fun b => c.1 (e.symm b), by
    obtain ⟨a, ha⟩ := c.2
    exact ⟨e a, by funext b; simp [map, Equiv.symm_apply_apply, ← ha]⟩⟩
  invFun c := Block.pull e p c
  left_inv c := by
    apply Subtype.ext
    funext a
    simp [Block.pull]
  right_inv c := by
    apply Subtype.ext
    funext b
    simp [Block.pull]

/-- Transport along a bijection preserves the size of every block. -/
theorem card_elems_blockEquiv (e : A ≃ B) (p : Blocking A) (c : p.Block) :
    Nat.card (blockEquiv e p c).elems = Nat.card c.elems :=
  Nat.card_congr (e.symm.subtypeEquiv fun _ => Iff.rfl)

/-- **A partition decomposes the underlying set**: every point lies in exactly one
block. -/
def blockSigmaEquiv (p : Blocking A) : (Σ c : p.Block, c.elems) ≃ A where
  toFun x := x.2.1
  invFun a := ⟨p.blockOf a, ⟨a, p.self a⟩⟩
  left_inv := by
    rintro ⟨c, ⟨a, ha⟩⟩
    have hc : p.blockOf a = c := by
      obtain ⟨u, hu⟩ := c.2
      refine Subtype.ext ?_
      have hua : p.rel u a = true := by rw [hu]; exact ha
      show p.rel a = c.1
      rw [← hu, p.glue u a hua]
    subst hc
    rfl
  right_inv _ := rfl

/-- **The block sizes of a partition sum to the size of the underlying set.** -/
theorem sum_card_elems [Finite A] (p : Blocking A) [Fintype p.Block] :
    ∑ c : p.Block, Nat.card c.elems = Nat.card A := by
  rw [← Nat.card_sigma]
  exact Nat.card_congr (blockSigmaEquiv p)

/-! ### Decomposing a blocking of `Option A` -/

theorem rel_comm (p : Blocking A) (a b : A) : p.rel a b = p.rel b a := by
  cases h : p.rel a b with
  | true => exact (p.symm' h).symm
  | false =>
      cases h' : p.rel b a with
      | true =>
          rw [p.symm' h'] at h
          exact absurd h (by simp)
      | false => rfl

/-- The indicator of the block of `none`, given its trace `q` on `A`. -/
def noneBlock (q : A → Bool) : Option A → Bool := fun x => x.elim true q

@[simp] theorem noneBlock_none (q : A → Bool) : noneBlock q none = true := rfl

@[simp] theorem noneBlock_some (q : A → Bool) (a : A) : noneBlock q (some a) = q a := rfl

variable {q : A → Bool}

/-- The relation underlying the reassembled blocking `ofDecomp`. -/
def decompRel (q : A → Bool) (p : Blocking {a : A // q a = false}) : Option A → Option A → Bool
  | none, y => noneBlock q y
  | some a, y =>
      if ha : q a = false then
        match y with
        | none => false
        | some b => if hb : q b = false then p.rel ⟨a, ha⟩ ⟨b, hb⟩ else false
      else noneBlock q y

@[simp] theorem decompRel_none (p : Blocking {a : A // q a = false}) (y : Option A) :
    decompRel q p none y = noneBlock q y := rfl

theorem decompRel_some_of_true (p : Blocking {a : A // q a = false}) {a : A} (ha : q a = true)
    (y : Option A) : decompRel q p (some a) y = noneBlock q y := by
  simp [decompRel, ha]

theorem decompRel_some_none (p : Blocking {a : A // q a = false}) {a : A} (ha : q a = false) :
    decompRel q p (some a) none = false := by
  simp [decompRel, ha]

theorem decompRel_some_some (p : Blocking {a : A // q a = false}) {a b : A} (ha : q a = false)
    (hb : q b = false) : decompRel q p (some a) (some b) = p.rel ⟨a, ha⟩ ⟨b, hb⟩ := by
  simp [decompRel, ha, hb]

theorem decompRel_some_some_true (p : Blocking {a : A // q a = false}) {a b : A} (ha : q a = false)
    (hb : q b = true) : decompRel q p (some a) (some b) = false := by
  simp [decompRel, ha, hb]

/-- Reassembling a blocking of `Option A` out of the trace `q` on `A` of the block of
`none` together with a blocking of the complement of that block. -/
def ofDecomp (q : A → Bool) (p : Blocking {a : A // q a = false}) : Blocking (Option A) where
  rel := decompRel q p
  self x := by
    match x with
    | none => rfl
    | some a =>
        cases ha : q a with
        | false =>
            rw [decompRel_some_some p ha ha]
            exact p.self _
        | true => rw [decompRel_some_of_true p ha]; simpa using ha
  glue x y h := by
    match x, y with
    | none, none => rfl
    | none, some b =>
        have hb : q b = true := by simpa using h
        funext z
        rw [decompRel_some_of_true p hb]
        rfl
    | some a, none =>
        cases ha : q a with
        | false => rw [decompRel_some_none p ha] at h; exact absurd h (by simp)
        | true =>
            funext z
            rw [decompRel_some_of_true p ha]
            rfl
    | some a, some b =>
        cases ha : q a with
        | true =>
            rw [decompRel_some_of_true p ha] at h
            have hb : q b = true := by simpa using h
            funext z
            rw [decompRel_some_of_true p hb, decompRel_some_of_true p ha]
        | false =>
            cases hb : q b with
            | true => rw [decompRel_some_some_true p ha hb] at h; exact absurd h (by simp)
            | false =>
                rw [decompRel_some_some p ha hb] at h
                have hp := p.glue ⟨a, ha⟩ ⟨b, hb⟩ h
                funext z
                match z with
                | none => rw [decompRel_some_none p hb, decompRel_some_none p ha]
                | some c =>
                    cases hc : q c with
                    | true =>
                        rw [decompRel_some_some_true p hb hc, decompRel_some_some_true p ha hc]
                    | false =>
                        rw [decompRel_some_some p hb hc, decompRel_some_some p ha hc]
                        exact congrFun hp ⟨c, hc⟩

/-- The blocking induced on the complement of the block of `none`. -/
def restrictNone (p : Blocking (Option A)) :
    Blocking {a : A // p.rel none (some a) = false} where
  rel x y := p.rel (some x.1) (some y.1)
  self x := p.self _
  glue x y h := by
    funext z
    exact congrFun (p.glue _ _ h) (some z.1)

/-- **Decomposition of a blocking of `Option A`**: it is the same thing as a subset `q`
of `A` (the rest of the block containing `none`) together with a blocking of the
complement of `q`. -/
def optionEquiv : Blocking (Option A) ≃ Σ q : A → Bool, Blocking {a : A // q a = false} where
  toFun p := ⟨fun a => p.rel none (some a), p.restrictNone⟩
  invFun x := ofDecomp x.1 x.2
  left_inv p := by
    apply Blocking.ext
    funext x y
    show decompRel (fun a => p.rel none (some a)) p.restrictNone x y = p.rel x y
    match x, y with
    | none, none => exact (p.self none).symm
    | none, some b => rfl
    | some a, y =>
        cases ha : p.rel none (some a) with
        | true =>
            have hglue := p.glue none (some a) ha
            rw [decompRel_some_of_true p.restrictNone ha, hglue]
            match y with
            | none => exact (p.self none).symm
            | some b => rfl
        | false =>
            match y with
            | none =>
                rw [decompRel_some_none p.restrictNone ha]
                rw [rel_comm]
                exact ha.symm
            | some b =>
                cases hb : p.rel none (some b) with
                | false =>
                    rw [decompRel_some_some p.restrictNone ha hb]
                    rfl
                | true =>
                    rw [decompRel_some_some_true p.restrictNone ha hb]
                    have hglue := congrFun (p.glue none (some b) hb) (some a)
                    rw [rel_comm, hglue, ha]
  right_inv x := by
    obtain ⟨q, p⟩ := x
    refine congrArg (Sigma.mk q) ?_
    apply Blocking.ext
    funext u v
    show decompRel q p (some u.1) (some v.1) = p.rel u v
    rw [decompRel_some_some p u.2 v.2]
    rfl


/-! ### The blocks of a reassembled blocking -/

theorem ofDecomp_rel (q : A → Bool) (p : Blocking {a : A // q a = false}) :
    (ofDecomp q p).rel = decompRel q p := rfl

theorem ofDecomp_none_rel (p : Blocking {a : A // q a = false}) (y : Option A) :
    (ofDecomp q p).rel none y = noneBlock q y := rfl

theorem ofDecomp_some_of_true (p : Blocking {a : A // q a = false}) {a : A} (ha : q a = true)
    (y : Option A) : (ofDecomp q p).rel (some a) y = noneBlock q y :=
  decompRel_some_of_true p ha y

theorem ofDecomp_some_none (p : Blocking {a : A // q a = false}) {a : A} (ha : q a = false) :
    (ofDecomp q p).rel (some a) none = false := decompRel_some_none p ha

theorem ofDecomp_some_some (p : Blocking {a : A // q a = false}) {a b : A} (ha : q a = false)
    (hb : q b = false) : (ofDecomp q p).rel (some a) (some b) = p.rel ⟨a, ha⟩ ⟨b, hb⟩ :=
  decompRel_some_some p ha hb

theorem ofDecomp_some_some_true (p : Blocking {a : A // q a = false}) {a b : A} (ha : q a = false)
    (hb : q b = true) : (ofDecomp q p).rel (some a) (some b) = false :=
  decompRel_some_some_true p ha hb

/-- The block of `none` inside `ofDecomp q p`. -/
def noneBlockMem (p : Blocking {a : A // q a = false}) : (ofDecomp q p).Block :=
  ⟨noneBlock q, ⟨none, rfl⟩⟩

/-- The indicator of a block of the complement, viewed as a subset of `Option A`. -/
def liftFn (q : A → Bool) (c : {a : A // q a = false} → Bool) : Option A → Bool
  | none => false
  | some a => if h : q a = false then c ⟨a, h⟩ else false

@[simp] theorem liftFn_none (q : A → Bool) (c : {a : A // q a = false} → Bool) :
    liftFn q c none = false := rfl

theorem liftFn_some (q : A → Bool) (c : {a : A // q a = false} → Bool) {a : A}
    (ha : q a = false) : liftFn q c (some a) = c ⟨a, ha⟩ := by
  simp [liftFn, ha]

theorem liftFn_some_of_true (q : A → Bool) (c : {a : A // q a = false} → Bool) {a : A}
    (ha : q a = true) : liftFn q c (some a) = false := by
  simp [liftFn, ha]

/-- A block of the complement, viewed as a block of `ofDecomp q p`. -/
def liftBlock (p : Blocking {a : A // q a = false}) (c : p.Block) : (ofDecomp q p).Block :=
  ⟨liftFn q c.1, by
    obtain ⟨u, hu⟩ := c.2
    refine ⟨some u.1, ?_⟩
    funext x
    show decompRel q p (some u.1) x = liftFn q c.1 x
    match x with
    | none => rw [decompRel_some_none p u.2]; rfl
    | some b =>
        cases hb : q b with
        | false =>
            rw [decompRel_some_some p u.2 hb, liftFn_some q c.1 hb, ← hu]
        | true => rw [decompRel_some_some_true p u.2 hb, liftFn_some_of_true q c.1 hb]⟩

@[simp] theorem liftBlock_coe (p : Blocking {a : A // q a = false}) (c : p.Block) :
    (liftBlock p c).1 = liftFn q c.1 := rfl

/-- A block of `ofDecomp q p` containing `none` is the block of `none`. -/
theorem block_eq_noneBlock {p : Blocking {a : A // q a = false}} (c : (ofDecomp q p).Block)
    (h : c.1 none = true) : c = noneBlockMem p := by
  obtain ⟨z, hz⟩ := c.2
  refine Subtype.ext ?_
  match z with
  | none => exact hz.symm
  | some a =>
      cases ha : q a with
      | true =>
          rw [← hz]
          funext y
          exact ofDecomp_some_of_true p ha y
      | false =>
          rw [← hz] at h
          rw [ofDecomp_some_none p ha] at h
          exact absurd h (by simp)

/-- A block of `ofDecomp q p` not containing `none` comes from a block of the complement. -/
theorem block_eq_liftFn {p : Blocking {a : A // q a = false}} (c : (ofDecomp q p).Block)
    (h : c.1 none = false) : c.1 = liftFn q (fun x => c.1 (some x.1)) := by
  obtain ⟨z, hz⟩ := c.2
  match z with
  | none =>
      rw [← hz, (ofDecomp q p).self none] at h
      exact absurd h (by simp)
  | some a =>
      cases ha : q a with
      | true =>
          rw [← hz, ofDecomp_some_of_true p ha] at h
          exact absurd h (by simp)
      | false =>
          funext y
          match y with
          | none => rw [h, liftFn_none]
          | some b =>
              cases hb : q b with
              | false => rw [liftFn_some q _ hb]
              | true =>
                  rw [liftFn_some_of_true q _ hb, ← hz, ofDecomp_some_some_true p ha hb]

/-- The indicator of a block of the complement is recovered from its lift. -/
theorem exists_rel_liftFn {p : Blocking {a : A // q a = false}} (c : (ofDecomp q p).Block)
    (h : c.1 none = false) :
    ∃ u : {a : A // q a = false}, p.rel u = fun x => c.1 (some x.1) := by
  obtain ⟨z, hz⟩ := c.2
  match z with
  | none =>
      rw [← hz, (ofDecomp q p).self none] at h
      exact absurd h (by simp)
  | some a =>
      cases ha : q a with
      | true =>
          rw [← hz, ofDecomp_some_of_true p ha] at h
          exact absurd h (by simp)
      | false =>
          refine ⟨⟨a, ha⟩, ?_⟩
          funext x
          rw [← hz, ofDecomp_some_some p ha x.2]

/-- The map assigning to `none` the block of `none`, and to a block of the complement its
lift. -/
def blockOption (p : Blocking {a : A // q a = false}) :
    Option p.Block → (ofDecomp q p).Block
  | none => noneBlockMem p
  | some c => liftBlock p c

theorem blockOption_bijective (p : Blocking {a : A // q a = false}) :
    Function.Bijective (blockOption p) := by
  constructor
  · intro o o' h
    match o, o' with
    | none, none => rfl
    | none, some c =>
        have : (noneBlockMem p).1 none = (liftBlock p c).1 none := congrFun (congrArg _ h) none
        simp [noneBlockMem, noneBlock] at this
    | some c, none =>
        have : (liftBlock p c).1 none = (noneBlockMem p).1 none := congrFun (congrArg _ h) none
        simp [noneBlockMem, noneBlock] at this
    | some c, some c' =>
        have hc : liftFn q c.1 = liftFn q c'.1 := congrArg Subtype.val h
        refine congrArg some (Subtype.ext (funext fun x => ?_))
        have := congrFun hc (some x.1)
        rwa [liftFn_some q c.1 x.2, liftFn_some q c'.1 x.2] at this
  · intro c
    cases h : c.1 none with
    | true => exact ⟨none, (block_eq_noneBlock c h).symm⟩
    | false =>
        refine ⟨some ⟨fun x => c.1 (some x.1), exists_rel_liftFn c h⟩, ?_⟩
        exact (Subtype.ext (block_eq_liftFn c h)).symm

/-- **The blocks of `ofDecomp q p`**: the block of `none`, together with the blocks of the
complement. -/
def blockOptionEquiv (p : Blocking {a : A // q a = false}) :
    Option p.Block ≃ (ofDecomp q p).Block :=
  Equiv.ofBijective _ (blockOption_bijective p)

@[simp] theorem blockOptionEquiv_apply (p : Blocking {a : A // q a = false})
    (o : Option p.Block) : blockOptionEquiv p o = blockOption p o := rfl

/-- The block of `none` in `ofDecomp q p` consists of `none` together with the points of
`A` where `q` is true. -/
def noneBlockElemsEquiv (p : Blocking {a : A // q a = false}) :
    (noneBlockMem p).elems ≃ Option {a : A // q a = true} where
  toFun x :=
    match x with
    | ⟨none, _⟩ => none
    | ⟨some a, ha⟩ => some ⟨a, ha⟩
  invFun o :=
    match o with
    | none => ⟨none, rfl⟩
    | some a => ⟨some a.1, a.2⟩
  left_inv x := by
    obtain ⟨x, hx⟩ := x
    match x with
    | none => rfl
    | some a => rfl
  right_inv o := by
    match o with
    | none => rfl
    | some a => rfl

theorem q_false_of_liftBlock {p : Blocking {a : A // q a = false}} {c : p.Block} {a : A}
    (h : (liftBlock p c).1 (some a) = true) : q a = false := by
  cases hq : q a with
  | false => rfl
  | true =>
      rw [liftBlock_coe, liftFn_some_of_true q c.1 hq] at h
      exact absurd h (by simp)

theorem mem_of_liftBlock {p : Blocking {a : A // q a = false}} {c : p.Block} {a : A}
    (h : (liftBlock p c).1 (some a) = true) : c.1 ⟨a, q_false_of_liftBlock h⟩ = true := by
  rw [liftBlock_coe, liftFn_some q c.1 (q_false_of_liftBlock h)] at h
  exact h

/-- Removing `none` from a subtype of `Option A` that does not contain it. -/
def optionSubtypeEquiv (f : Option A → Bool) (hf : f none = false) :
    {x : Option A // f x = true} ≃ {a : A // f (some a) = true} where
  toFun x :=
    match x with
    | ⟨none, h⟩ => absurd h (by rw [hf]; simp)
    | ⟨some a, h⟩ => ⟨a, h⟩
  invFun a := ⟨some a.1, a.2⟩
  left_inv x := by
    obtain ⟨x, hx⟩ := x
    match x with
    | none => exact absurd hx (by rw [hf]; simp)
    | some a => rfl
  right_inv a := rfl

/-- A lifted block has the same elements as the block it comes from. -/
def liftBlockElemsEquiv (p : Blocking {a : A // q a = false}) (c : p.Block) :
    (liftBlock p c).elems ≃ c.elems :=
  (optionSubtypeEquiv (liftBlock p c).1 (by simp)).trans
    { toFun := fun a => ⟨⟨a.1, q_false_of_liftBlock a.2⟩, mem_of_liftBlock a.2⟩
      invFun := fun u => ⟨u.1.1, by rw [liftBlock_coe, liftFn_some q c.1 u.1.2]; exact u.2⟩
      left_inv := fun a => rfl
      right_inv := fun u => rfl }

end Blocking

namespace Species

open Blocking

variable (F G : Species)

/-- **Composition of species**: an `(F ∘ G)`-structure on `A` is a partition of `A`, an
`F`-structure on the set of blocks, and a `G`-structure on each block. -/
def comp : Species where
  obj A := Σ p : Blocking A, F.obj p.Block × ∀ c : p.Block, G.obj c.elems
  map {A B} e x :=
    ⟨x.1.map e, F.map (blockEquiv e x.1) x.2.1,
      fun c => G.map (e.subtypeEquiv (fun _ => Iff.rfl) :
          {a : A // c.1 (e a) = true} ≃ {b : B // c.1 b = true})
        (x.2.2 (Block.pull e x.1 c))⟩
  map_refl := by
    rintro A ⟨p, u, v⟩
    dsimp only
    have h1 : blockEquiv (Equiv.refl A) p = Equiv.refl p.Block := by
      exact Equiv.ext fun c => Subtype.ext (funext fun a => rfl)
    have h2 : ∀ c : p.Block,
        ((Equiv.refl A).subtypeEquiv (fun _ => Iff.rfl) :
          {a : A // c.1 a = true} ≃ {b : A // c.1 b = true}) = Equiv.refl _ := by
      intro c; exact Equiv.ext fun a => rfl
    rw [h1, F.map_refl]
    congr 1
    congr 1
    funext c
    rw [h2 c]
    exact G.map_refl _
  map_trans := by
    rintro A B C e f ⟨p, u, v⟩
    dsimp only
    have hb : (blockEquiv e p).trans (blockEquiv f (p.map e)) = blockEquiv (e.trans f) p := by
      apply Equiv.ext
      intro c
      apply Subtype.ext
      funext x
      rfl
    congr 1
    congr 1
    · rw [F.map_trans, hb]
    · funext c
      rw [G.map_trans]
      exact congrArg (fun E => G.map E (v (Block.pull e p (Block.pull f (p.map e) c))))
        (Equiv.ext fun a => rfl)
  finite A _ := by infer_instance

/-! ### First properties of composition -/

/-- The unique blocking of the empty set. -/
def emptyBlocking : Blocking (Fin 0) where
  rel a := a.elim0
  self a := a.elim0
  glue a := a.elim0

instance : Unique (Blocking (Fin 0)) where
  default := emptyBlocking
  uniq _ := Blocking.ext (funext fun a => a.elim0)

instance (p : Blocking (Fin 0)) : IsEmpty p.Block :=
  ⟨fun c => by obtain ⟨a, -⟩ := c.2; exact a.elim0⟩

/-- On the empty set there is exactly one partition, with no blocks, so an
`(F ∘ G)`-structure is just an `F`-structure on the empty set of blocks. -/
@[simp] theorem card_comp_zero : (F.comp G).card 0 = F.card 0 := by
  haveI : Fintype (Blocking (Fin 0)) := Fintype.ofFinite _
  haveI : Fintype (default : Blocking (Fin 0)).Block := Fintype.ofIsEmpty
  show Nat.card (Σ p : Blocking (Fin 0), F.obj p.Block × ∀ c : p.Block, G.obj c.elems) = _
  rw [Nat.card_sigma, Finset.univ_unique, Finset.sum_singleton, Nat.card_prod, Nat.card_pi,
    Finset.univ_eq_empty, Finset.prod_empty, mul_one, F.card_obj]
  simp [Nat.card_eq_fintype_card]

/-- **Composition respects isomorphism of species**: `F ≅ F'` and `G ≅ G'` give
`F ∘ G ≅ F' ∘ G'`.  The partition is left untouched; only the structures on the set of
blocks and on the individual blocks are transported. -/
def Iso.compCongr {F F' G G' : Species} (φ : F ≃ₛ F') (ψ : G ≃ₛ G') :
    (F.comp G) ≃ₛ (F'.comp G') where
  hom A :=
    { toFun := fun x => ⟨x.1, φ.hom x.1.Block x.2.1, fun c => ψ.hom c.elems (x.2.2 c)⟩
      invFun := fun y =>
        ⟨y.1, (φ.hom y.1.Block).symm y.2.1, fun c => (ψ.hom c.elems).symm (y.2.2 c)⟩
      left_inv := by
        rintro ⟨p, u, v⟩
        refine congrArg (Sigma.mk p) ?_
        refine Prod.ext (by simp) ?_
        funext c
        simp
      right_inv := by
        rintro ⟨p, u, v⟩
        refine congrArg (Sigma.mk p) ?_
        refine Prod.ext (by simp) ?_
        funext c
        simp }
  naturality {A B} e x := by
    refine congrArg (Sigma.mk (x.1.map e)) ?_
    refine Prod.ext (φ.naturality _ _) ?_
    funext c
    exact ψ.naturality _ _

/-- Composition of isomorphic species has the same counting sequence. -/
theorem card_comp_congr {F F' G G' : Species} (φ : F ≃ₛ F') (ψ : G ≃ₛ G') (n : ℕ) :
    (F.comp G).card n = (F'.comp G').card n :=
  (Iso.compCongr φ ψ).card_eq n

/-- Composition of isomorphic species has the same exponential generating series. -/
theorem egf_comp_congr {F F' G G' : Species} (φ : F ≃ₛ F') (ψ : G ≃ₛ G') :
    (F.comp G).egf = (F'.comp G').egf :=
  (Iso.compCongr φ ψ).egf_eq

/-! ### The counting formula for a composite -/

noncomputable instance instFintypeBlocking (A : Type) [Finite A] : Fintype (Blocking A) :=
  Fintype.ofFinite _

noncomputable instance instFintypeBlock {A : Type} [Finite A] (p : Blocking A) :
    Fintype p.Block :=
  Fintype.ofFinite _

theorem block_elems_nonempty {A : Type} {p : Blocking A} (c : p.Block) : Nonempty c.elems := by
  obtain ⟨a, ha⟩ := c.2
  exact ⟨⟨a, by rw [← ha]; exact p.self a⟩⟩

theorem one_le_card_elems {A : Type} [Finite A] {p : Blocking A} (c : p.Block) :
    1 ≤ Nat.card c.elems := by
  have hne : Nonempty c.elems := block_elems_nonempty c
  have : Nat.card c.elems ≠ 0 := Nat.card_ne_zero.2 ⟨hne, inferInstance⟩
  omega

theorem block_nonempty {A : Type} [Nonempty A] (p : Blocking A) : Nonempty p.Block :=
  ⟨p.blockOf (Classical.arbitrary A)⟩

/-- **The counting formula for composition**: sum over all partitions of the number of
`F`-structures on the set of blocks times the product over the blocks of the number of
`G`-structures. -/
theorem card_comp (n : ℕ) :
    (F.comp G).card n
      = ∑ p : Blocking (Fin n),
          F.card (Nat.card p.Block) * ∏ c : p.Block, G.card (Nat.card c.elems) := by
  show Nat.card (Σ p : Blocking (Fin n), F.obj p.Block × ∀ c : p.Block, G.obj c.elems) = _
  rw [Nat.card_sigma]
  refine Finset.sum_congr rfl fun p _ => ?_
  rw [Nat.card_prod, Nat.card_pi, F.card_obj]
  exact congrArg _ (Finset.prod_congr rfl fun c _ => G.card_obj c.elems)

/-- If `G` has no structures on nonempty sets then `F ∘ G` has no structures at all on a
nonempty set: every block would have to carry a `G`-structure. -/
theorem card_comp_of_no_structures (hG : ∀ k, 1 ≤ k → G.card k = 0) {n : ℕ} (hn : 1 ≤ n) :
    (F.comp G).card n = 0 := by
  rw [card_comp]
  refine Finset.sum_eq_zero fun p _ => ?_
  haveI : Nonempty (Fin n) := ⟨⟨0, hn⟩⟩
  obtain ⟨c⟩ := block_nonempty p
  have hzero : ∏ c : p.Block, G.card (Nat.card c.elems) = 0 :=
    Finset.prod_eq_zero (Finset.mem_univ c) (hG _ (one_le_card_elems c))
  rw [hzero, mul_zero]

/-- Substituting the empty species: `F ∘ 0` has structures only on the empty set. -/
theorem card_comp_zero_species {n : ℕ} (hn : 1 ≤ n) : (F.comp zero).card n = 0 :=
  card_comp_of_no_structures F zero (fun k _ => card_zero_species k) hn

/-- Substituting the species `1`: `F ∘ 1` has structures only on the empty set, because
the blocks of a partition are nonempty. -/
theorem card_comp_one_species {n : ℕ} (hn : 1 ≤ n) : (F.comp one).card n = 0 := by
  refine card_comp_of_no_structures F one (fun k hk => ?_) hn
  match k with
  | 0 => omega
  | (m + 1) => exact card_one_succ m

end Species

end SpeciesEGF