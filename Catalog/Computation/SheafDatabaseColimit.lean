/-
# When Databases Form a Sheaf — The Colimit / Information-Order Layer

This file develops the **order-theoretic skeleton** underneath the
sheaf-theoretic view of databases introduced in
`Computation.SheafDataIntegration`. The slogan "databases form a sheaf" is made
precise as an *equalizer / colimit* statement in the poset of partial databases
ordered by **information** (extension):

* partial databases form a partial order `Extends` ("has at least as much data");
* the binary gluing `GluingMap` is the **join** (least upper bound) of a
  consistent pair;
* an arbitrary indexed family glues to a canonical least upper bound
  `glueFamily` — the *colimit* of the diagram — **iff** the family is pairwise
  consistent (the sheaf condition).

The headline result, `sheaf_iff_common_extension`, is the exact two-way bridge:

    SheafCondition dbs  ↔  ∃ g, ∀ i, Extends g (dbs i)

i.e. *a family of partial databases admits a single consistent merge precisely
when it satisfies the sheaf (overlap-agreement) condition*. This sharpens the
existence-only `sheaf_condition` of the Bridges entry into a characterization,
and adds the universal property (`glueFamily_is_lub`) that pins the merge down
as a genuine colimit rather than an arbitrary witness.

We then connect this order layer back to the existing `SheafFiltration`
structure: the colimit of a filtration is exactly its top level
(`filtration_colimit_eq_top`) — progressive imputation converges to its limit.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).** "Gluability is an order-theoretic universal
  property." Conjecture: the merge produced by the sheaf condition is not just
  *some* common extension but the *least* one (the colimit), and its mere
  existence is *equivalent* to pairwise consistency, giving an iff rather than
  the one-directional existence theorem already in the catalog.
* **Experiment (Experimenter).** Introduced the information order `Extends`,
  proved it is a partial order (`extends_refl/trans/antisymm`), built an
  arbitrary-arity colimit `glueFamily` via `Classical.choose`, and proved both
  the universal property and the iff characterization.
* **Analysis (Analyst).** The forward direction (sheaf ⇒ merge) needs choice
  and the overlap-agreement hypothesis pointwise; the reverse direction
  (merge ⇒ sheaf) is *free* and choice-free — two sections of a common
  function automatically agree on overlaps. So the "hard" content of "databases
  form a sheaf" lives entirely in the forward direction, exactly the equalizer
  that grid-agnostic imputation skips.
* **Critique (Critic).** Is the iff vacuous? No: `sheaf_iff_common_extension`
  has genuine content in both directions, and `glueFamily_is_lub` shows the
  witness is canonical (antisymmetry forces uniqueness of the colimit), so the
  statement is not merely an existence wrapper.
* **Synthesis (PI).** Databases under the information order form a poset whose
  consistent families have colimits; "forming a sheaf" = "the consistency
  cocone has an initial cocone (a least common extension)". The filtration
  colimit theorem shows progressive imputation is literally taking this colimit
  level by level.
-/

import Mathlib
import Computation.SheafDataIntegration

open Classical

namespace SheafDatabaseColimit

variable {nRows nCols : ℕ} {V : Type*}

/-! ## Section 1: The information order on partial databases -/

/-- `Extends big small` means `big` has at least as much information as `small`:
    every value recorded by `small` is recorded identically by `big`. This is the
    *specialization / information order* on partial databases. -/
def Extends (big small : PartialDB nRows nCols V) : Prop :=
  ∀ p v, small p = some v → big p = some v

/--
The information order is reflexive.
-/
theorem extends_refl (db : PartialDB nRows nCols V) : Extends db db := by
  exact fun p v h => h

/--
The information order is transitive.
-/
theorem extends_trans {a b c : PartialDB nRows nCols V}
    (hab : Extends a b) (hbc : Extends b c) : Extends a c := by
  exact fun p v hv => hab p v ( hbc p v hv )

/--
The information order is antisymmetric: two mutually-extending databases are
    equal as functions.
-/
theorem extends_antisymm {a b : PartialDB nRows nCols V}
    (hab : Extends a b) (hba : Extends b a) : a = b := by
  funext p;
  cases h : a p <;> cases h' : b p <;> simp_all +decide [ Extends ]

/--
Two restrictions of one database agree on overlaps: if `g` extends both
    `a` and `b`, then `a` and `b` are consistent. This is the *choice-free*
    half of the sheaf correspondence.
-/
theorem consistentPair_of_common_extension
    {a b g : PartialDB nRows nCols V}
    (ha : Extends g a) (hb : Extends g b) : ConsistentPair a b := by
  intro p v1 v2 hpa hpb; have := ha p v1 hpa; have := hb p v2 hpb; aesop;

/-! ## Section 2: The binary gluing is the join -/

/--
The gluing always extends its first argument (no consistency needed, since
    `GluingMap` prefers the first).
-/
theorem extends_gluing_left (db1 db2 : PartialDB nRows nCols V) :
    Extends (GluingMap db1 db2) db1 := by
  exact fun p v hv => gluing_extends_left db1 db2 p v hv

/--
For a consistent pair the gluing extends the second argument too.
-/
theorem extends_gluing_right (db1 db2 : PartialDB nRows nCols V)
    (hc : ConsistentPair db1 db2) :
    Extends (GluingMap db1 db2) db2 := by
  convert gluing_extends_both db1 db2 hc |>.2 using 1

/--
**The gluing is the least upper bound of a pair.** Any database extending
    both `db1` and `db2` already extends their gluing. Together with
    `extends_gluing_left/right` this exhibits `GluingMap` as the join in the
    information order.
-/
theorem gluing_is_lub {db1 db2 g : PartialDB nRows nCols V}
    (h1 : Extends g db1) (h2 : Extends g db2) :
    Extends g (GluingMap db1 db2) := by
  intro p v hv;
  unfold GluingMap at hv;
  cases h : db1 p <;> aesop

/-! ## Section 3: The arbitrary-arity colimit -/

/-- The **colimit** (least common extension) of an indexed family of partial
    databases: at each cell, take the value of some member that has one. Under
    the sheaf condition the chosen member is irrelevant. -/
noncomputable def glueFamily {ι : Type*} (dbs : ι → PartialDB nRows nCols V) :
    PartialDB nRows nCols V :=
  fun p => if h : ∃ i, dbs i p ≠ none then dbs (Classical.choose h) p else none

/--
A cell of the colimit is empty exactly when every member leaves it empty.
-/
theorem glueFamily_eq_none_iff {ι : Type*} (dbs : ι → PartialDB nRows nCols V)
    (p : DBPos nRows nCols) :
    glueFamily dbs p = none ↔ ∀ i, dbs i p = none := by
  constructor <;> intro h;
  · contrapose! h;
    unfold glueFamily;
    grind;
  · unfold glueFamily; aesop;

/--
**The colimit extends every member** (forward direction; uses the sheaf
    condition and choice).
-/
theorem glueFamily_extends {ι : Type*} (dbs : ι → PartialDB nRows nCols V)
    (hsc : SheafCondition dbs) (i : ι) :
    Extends (glueFamily dbs) (dbs i) := by
  intro p v hv;
  unfold glueFamily;
  split_ifs with h;
  · obtain ⟨ j, hj ⟩ := Classical.choose_spec h |> fun h => Option.ne_none_iff_exists'.mp h;
    have := hsc ( Classical.choose h ) i p j v hj hv; aesop;
  · exact h ⟨ i, hv.symm ▸ by simp +decide ⟩

/--
**The colimit is the least common extension** (universal property; choice-
    free). Any common extension `g` of the family already extends the colimit.
-/
theorem glueFamily_is_lub {ι : Type*} (dbs : ι → PartialDB nRows nCols V)
    {g : PartialDB nRows nCols V} (hg : ∀ i, Extends g (dbs i)) :
    Extends g (glueFamily dbs) := by
  unfold Extends;
  unfold glueFamily; aesop;

/-! ## Section 4: Databases form a sheaf — the characterization -/

/--
**Main theorem: databases form a sheaf.** A family of partial databases
    admits a single common extension (a consistent merge) **iff** it satisfies
    the sheaf (overlap-agreement) condition. The forward direction is the
    gluing axiom; the reverse is separatedness.
-/
theorem sheaf_iff_common_extension {ι : Type*}
    (dbs : ι → PartialDB nRows nCols V) :
    SheafCondition dbs ↔ ∃ g : PartialDB nRows nCols V, ∀ i, Extends g (dbs i) := by
  constructor;
  · exact fun h => ⟨ SheafDatabaseColimit.glueFamily dbs, fun i => SheafDatabaseColimit.glueFamily_extends dbs h i ⟩;
  · rintro ⟨ g, hg ⟩ i j;
    exact consistentPair_of_common_extension (hg i) (hg j)

/--
The colimit is the canonical witness of gluability.
-/
theorem glueFamily_extends_all {ι : Type*} (dbs : ι → PartialDB nRows nCols V)
    (hsc : SheafCondition dbs) :
    (∀ i, Extends (glueFamily dbs) (dbs i)) ∧
    (∀ g, (∀ i, Extends g (dbs i)) → Extends g (glueFamily dbs)) := by
  exact ⟨ fun i => glueFamily_extends dbs hsc i, fun g hg => glueFamily_is_lub dbs hg ⟩

/--
**Completeness of the merge.** The colimit is a *global* section (a complete
    database with no missing cells) iff every cell is observed by some member.
    This characterizes when sheaf imputation fully reconstructs the database.
-/
theorem glueFamily_isGlobalSection_iff {ι : Type*}
    (dbs : ι → PartialDB nRows nCols V) :
    IsGlobalSection (glueFamily dbs) ↔ ∀ p : DBPos nRows nCols, ∃ i, dbs i p ≠ none := by
  constructor <;> intro h <;> simp_all +decide [ IsGlobalSection ];
  · exact fun a b => by contrapose! h; unfold glueFamily; aesop;
  · intro a b; obtain ⟨ i, hi ⟩ := h a b; unfold glueFamily; simp +decide ;
    exact ⟨ i, hi, Classical.choose_spec ( h a b ) ⟩

/-! ## Section 5: The algebra of gluing (a partial commutative idempotent monoid)

-- !-- Lab Notes (Cycle 2) -- !--
* **Hypothesis (Hypothesizer).** The binary merge `GluingMap` should behave
  like a *partial commutative idempotent monoid* operation: idempotent and
  associative unconditionally (first-wins precedence is associative), and
  commutative *exactly* on consistent pairs. The empty database is a two-sided
  unit.
* **Experiment (Experimenter).** Stated and proved `gluing_idem`,
  `gluing_assoc`, `gluing_comm_of_consistent`, the unit laws, and the
  domain-union law `gluing_dom`.
* **Analysis (Analyst).** Associativity and idempotence are choice-free and
  consistency-free — they are pure precedence algebra. Commutativity is the
  *only* law that needs the sheaf overlap-agreement hypothesis, isolating
  consistency as exactly the obstruction to order-independence of merging.
* **Critique (Critic).** `gluing_comm_of_consistent` is not vacuous: dropping
  consistency makes commutativity false (two databases disagreeing on a shared
  cell give different merges depending on order). The hypothesis is
  load-bearing.
* **Synthesis (PI).** Order-independent (commutative) data merging is
  equivalent to consistency, cell by cell; the colimit `glueFamily` is the
  order-independent multi-way version, and `colimit_unique` shows it is the
  unique least common extension.
-/

/--
Merging a database with itself changes nothing: `GluingMap` is idempotent.
-/
theorem gluing_idem (db : PartialDB nRows nCols V) :
    GluingMap db db = db := by
  funext p;
  unfold GluingMap; cases h : db p <;> simp +decide ;

/--
The empty database is a left unit for gluing.
-/
theorem gluing_empty_left (db : PartialDB nRows nCols V) :
    GluingMap (fun _ => none) db = db := by
  funext p; rfl

/--
The empty database is a right unit for gluing.
-/
theorem gluing_empty_right (db : PartialDB nRows nCols V) :
    GluingMap db (fun _ => none) = db := by
  funext p; unfold GluingMap; cases db p <;> rfl;

/--
**Gluing is associative** (unconditionally): first-wins precedence does not
    depend on the bracketing.
-/
theorem gluing_assoc (a b c : PartialDB nRows nCols V) :
    GluingMap (GluingMap a b) c = GluingMap a (GluingMap b c) := by
  funext p; unfold GluingMap; cases a p <;> cases b p <;> cases c p <;> simp_all +decide ;

/--
**Gluing is commutative exactly when the pair is consistent.** This isolates
    consistency as the precise obstruction to order-independent merging.
-/
theorem gluing_comm_of_consistent (a b : PartialDB nRows nCols V)
    (hc : ConsistentPair a b) :
    GluingMap a b = GluingMap b a := by
  funext p; unfold GluingMap; cases ha : a p <;> cases hb : b p <;> simp_all +decide ;
  exact hc p _ _ ha hb

/--
**Domain-union law.** The set of filled cells of a gluing is the union of
    the two domains.
-/
theorem gluing_dom (a b : PartialDB nRows nCols V) :
    (GluingMap a b).dom = a.dom ∪ b.dom := by
  ext p;
  unfold GluingMap;
  cases h : a p <;> simp +decide [ h, PartialDB.dom ]

/--
**Uniqueness of the colimit.** Any two least common extensions of the same
    family are equal. Combined with `glueFamily_extends_all`, this shows
    `glueFamily` is *the* colimit (initial common extension), not merely *a*
    common extension.
-/
theorem colimit_unique {ι : Type*} (dbs : ι → PartialDB nRows nCols V)
    {g1 g2 : PartialDB nRows nCols V}
    (h1ext : ∀ i, Extends g1 (dbs i))
    (h1min : ∀ h, (∀ i, Extends h (dbs i)) → Extends h g1)
    (h2ext : ∀ i, Extends g2 (dbs i))
    (h2min : ∀ h, (∀ i, Extends h (dbs i)) → Extends h g2) :
    g1 = g2 := by
  apply extends_antisymm;
  · grind;
  · exact h1min _ h2ext

/-! ## Section 6: Connection to the existing `SheafFiltration` -/

/--
**The colimit of a filtration is its top level.** Progressive imputation,
    modelled by a `SheafFiltration`, converges: the colimit of all filtration
    levels equals the final level.
-/
theorem filtration_colimit_eq_top {depth : ℕ}
    (F : SheafFiltration nRows nCols V depth) (hd : 0 < depth) :
    glueFamily F.level = F.level ⟨depth - 1, by omega⟩ := by
  apply extends_antisymm;
  · exact glueFamily_extends _ F.consistent _;
  · apply glueFamily_is_lub;
    exact fun i => F.monotone _ _ ( Nat.le_sub_one_of_lt i.2 )

end SheafDatabaseColimit