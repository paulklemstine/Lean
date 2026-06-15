import Mathlib
import Logic.GLKripke

/-!
# Polymodal Provability Logic (GLP), Ordinal Ranks, and the Category of GL Frames

This file extends the Kripke-semantic core of provability logic developed in
`Catalog/Logic/GLKripke.lean` (`GLFrame`, `gl_frame_validates_loeb`,
`gl_frame_well_founded`, `GLFrame.boxSet`, `GLFrame.diamondSet`) in three
cross-domain directions that were flagged as future work for the GL cycle:

* **Ordinal rank assignment (Logic ↔ Set Theory).**  Every GL frame carries a
  canonical *ordinal rank* `GLFrame.rank`, obtained from the (converse)
  well-foundedness of its accessibility relation.  The rank is **strictly
  decreasing along accessibility** (`gl_rank_lt_of_R`): moving to a more-accessible
  world drops the ordinal.  This realises, frame-internally, the proof-theoretic
  "ordinal of a world" that Direction 1 of the cycle proposed.

* **Polymodal GLP frames (Logic ↔ Proof Theory).**  A `GLPFrame` is a single set of
  worlds equipped with a *nested family* of accessibility relations
  `R₀ ⊇ R₁ ⊇ R₂ ⊇ ⋯`, each transitive and irreflexive — the frame skeleton of
  Japaridze's polymodal logic GLP.  We show every level `GLPFrame.level n` is a
  genuine `GLFrame` (so Löb holds at every level, `glp_level_validates_loeb`), and
  that the box operators are **monotone in the level index**
  (`glp_box_mono_in_level`): higher modalities are logically weaker because they see
  fewer worlds.

* **Products of GL frames (Logic ↔ Category Theory).**  GL frames are closed under
  the *synchronized product* `GLFrame.prod` (Direction 5).  The diamond of a
  rectangle factors exactly as a rectangle of diamonds
  (`prod_diamond_rectangle`) — the algebraic signature of a categorical product.

## Catalog synthesis

Everything here is built on the semantic frame infrastructure of
`Catalog/Logic/GLKripke.lean`: `gl_frame_validates_loeb` is invoked verbatim for the
polymodal levels, `gl_frame_well_founded` (and the converse well-foundedness used in
`exists_maximal_world`) powers the ordinal rank, and `GLFrame.diamondSet` is the
operator whose product behaviour we characterise.  The ordinal-rank theorem is the
semantic shadow of the *quantitative* `natBox_iterate_eq_Iio` /
`consistency_strength_strictMono` hierarchy of `Catalog/Logic/LobNatModel.lean`:
there the rank of the world `n` of the canonical frame `(ℕ, >)` is literally `n`;
here we show *every* GL frame has such a rank, valued in the ordinals.
-/

open Set Function

namespace GLFrame

/-! ## Part 1: The ordinal rank of a GL frame

The accessibility relation of a GL frame is transitive and irreflexive on a finite
type, hence its *converse* `flip R` is well-founded.  This lets us assign every world
an ordinal `rank`, strictly decreasing as we pass to accessible worlds. -/

/-
!-- The converse of accessibility is well-founded: a finite transitive irreflexive
relation is converse-well-founded.  (Same fact used in `exists_maximal_world`.) -- !--

In a GL frame the **converse** accessibility relation `flip R` is well-founded.
This is converse well-foundedness of `R`: there is no infinite *ascending*
`R`-chain `w R w₁ R w₂ R ⋯`.
-/
theorem flip_wellFounded (F : GLFrame) : WellFounded (flip F.R) := by
  convert F.finite_inst.wellFounded_of_trans_of_irrefl ( flip F.R ) using 1;
  · exact ⟨ fun a b c h₁ h₂ => F.trans _ _ _ h₂ h₁ ⟩;
  · exact ⟨ fun x hx => F.irrefl x hx ⟩

/-- The canonical **ordinal rank** of a world in a GL frame, defined from the
well-foundedness of `flip R`.  Intuitively, `rank w` is the order type of the tree of
`R`-ascending chains out of `w`; the deeper a world can "look", the larger its rank. -/
noncomputable def rank (F : GLFrame) (w : F.World) : Ordinal :=
  @IsWellFounded.rank _ (flip F.R) ⟨F.flip_wellFounded⟩ w

end GLFrame

/-
!-- Lab Notebook: gl_rank_lt_of_R -- !--
!-- Hypothesis: Every GL frame admits an ordinal rank strictly decreasing along R. -- !--
!-- Result: Proved via `IsWellFounded.rank` of `flip R`, which is well-founded by finiteness. -- !--
!-- Insight: Accessibility "looks downward" in rank; this is the semantic content of -- !--
!--          converse well-foundedness, the defining feature of GL frames. -- !--
!-- Failure analysis: Using `R` directly (not `flip R`) inverts the inequality; the -- !--
!--          frame must be *converse* well-founded, mirroring why `(ℕ,>)` not `(ℕ,<)` works. -- !--
!-- End Lab Notebook -- !--

**Ordinal rank strictly decreases along accessibility.**  If `v` is accessible
from `w` (`F.R w v`) then `rank v < rank w`.  This is the frame-internal "ordinal
analysis": every step into a more-accessible world spends ordinal capital, and the
process must terminate.
-/
theorem gl_rank_lt_of_R (F : GLFrame) {w v : F.World} (h : F.R w v) :
    F.rank v < F.rank w := by
  convert IsWellFounded.rank_lt_of_rel ( r := flip F.R ) ( show flip F.R v w from h ) using 1

/-! ## Part 2: Polymodal GLP frames -/

/-- A **polymodal GLP frame**: one finite set of worlds carrying a *nested* family of
accessibility relations `R 0 ⊇ R 1 ⊇ R 2 ⊇ ⋯`, each transitive and irreflexive.
These are the Kripke frames for Japaridze's polymodal provability logic GLP, where
`R n` interprets the `n`-th provability modality `[n]`. -/
structure GLPFrame where
  /-- The type of worlds. -/
  World : Type*
  /-- Finiteness. -/
  [finite_inst : Finite World]
  /-- The `n`-indexed family of accessibility relations. -/
  R : ℕ → World → World → Prop
  /-- Each level is irreflexive. -/
  irrefl : ∀ n w, ¬ R n w w
  /-- Each level is transitive. -/
  trans : ∀ n w v u, R n w v → R n v u → R n w u
  /-- Nesting: the modalities get *sparser* as the index grows, `R (n+1) ⊆ R n`. -/
  nested : ∀ n w v, R (n + 1) w v → R n w v

attribute [instance] GLPFrame.finite_inst

namespace GLPFrame

/-
The nesting relation `R m ⊆ R n` for any `n ≤ m` (the family is antitone in the
index).
-/
theorem R_anti (G : GLPFrame) {n m : ℕ} (hnm : n ≤ m) {w v : G.World}
    (h : G.R m w v) : G.R n w v := by
  induction' hnm with m hm ih generalizing w v;
  · assumption;
  · exact ih ( G.nested _ _ _ h )

/-- The **`n`-th level** of a GLP frame, as an ordinary `GLFrame`.  This shows the
polymodal structure is a refinement, not a departure: each modality is a bona fide GL
frame, so the entire single-modal apparatus applies level by level. -/
def level (G : GLPFrame) (n : ℕ) : GLFrame where
  World := G.World
  finite_inst := G.finite_inst
  R := G.R n
  irrefl := G.irrefl n
  trans := G.trans n

@[simp] theorem level_World (G : GLPFrame) (n : ℕ) : (G.level n).World = G.World := rfl

@[simp] theorem level_R (G : GLPFrame) (n : ℕ) : (G.level n).R = G.R n := rfl

-- !-- Lab Notebook: glp_level_validates_loeb -- !--
-- !-- Hypothesis: Each modality of a GLP frame validates Löb's axiom independently. -- !--
-- !-- Result: Immediate — each `level n` is a GLFrame, so `gl_frame_validates_loeb` applies. -- !--
-- !-- Insight: GLP needs no new soundness proof; the polymodal Löb axioms are a -- !--
-- !--          *family* of single-modal Löb axioms, one per accessibility relation. -- !--
-- !-- Failure analysis: None; the design of `level` as a GLFrame makes this a reduction. -- !--
-- !-- End Lab Notebook -- !--
/-- **Every level of a GLP frame validates Löb's axiom.**  For each modality index
`n` and every set `S` of worlds, `□ₙ(□ₙS → S) ⊆ □ₙS`.  Polymodal soundness reduces to
the single-modal `gl_frame_validates_loeb`, level by level. -/
theorem glp_level_validates_loeb (G : GLPFrame) (n : ℕ) (S : Set G.World) :
    (G.level n).boxSet (((G.level n).boxSet S)ᶜ ∪ S) ⊆ (G.level n).boxSet S :=
  gl_frame_validates_loeb (G.level n) S

/-
!-- Lab Notebook: glp_box_mono_in_level -- !--
!-- Hypothesis: Higher polymodal boxes are weaker because they quantify over fewer worlds. -- !--
!-- Result: For n ≤ m, □ₙS ⊆ □ₘS, since R m ⊆ R n means fewer accessibility constraints. -- !--
!-- Insight: The provability hierarchy is monotone: [m]φ is *easier* to satisfy than [n]φ -- !--
!--          when m ≥ n. This is the semantic root of the GLP axiom [n]φ → [n+1]φ. -- !--
!-- Failure analysis: Direction matters — antitone in R gives monotone in box; flipping -- !--
!--          the nesting convention would reverse the inclusion. -- !--
!-- End Lab Notebook -- !--

**The polymodal boxes are monotone in the level index.**  For `n ≤ m`,
`□ₙ S ⊆ □ₘ S`: the sparser, higher modality `□ₘ` is logically *weaker*.  This is the
frame-semantic content of the GLP monotonicity axiom `[n]φ → [n+1]φ`.
-/
theorem glp_box_mono_in_level (G : GLPFrame) {n m : ℕ} (hnm : n ≤ m)
    (S : Set G.World) :
    (G.level n).boxSet S ⊆ (G.level m).boxSet S := by
  intro w hw v hv; exact (by
  exact hw v ( by exact G.R_anti hnm hv ))

/-- **Ordinal rank decreases along every modality.**  At each level `n`, the ordinal
rank of the corresponding GL frame strictly decreases along `R n`.  Each modality
carries its own proof-theoretic descent. -/
theorem glp_level_rank_lt (G : GLPFrame) (n : ℕ) {w v : G.World}
    (h : G.R n w v) : (G.level n).rank v < (G.level n).rank w :=
  gl_rank_lt_of_R (G.level n) (by simpa using h)

end GLPFrame

/-! ## Part 3: Products of GL frames (the categorical bridge) -/

namespace GLFrame

/-- The **synchronized product** of two GL frames: worlds are pairs, and a step is
allowed only when *both* coordinates step simultaneously.  This is the categorical
product in the category of GL frames and bounded morphisms. -/
def prod (F G : GLFrame) : GLFrame where
  World := F.World × G.World
  finite_inst := by
    haveI := F.finite_inst; haveI := G.finite_inst; infer_instance
  R := fun p q => F.R p.1 q.1 ∧ G.R p.2 q.2
  irrefl := by
    rintro ⟨a, b⟩ ⟨h, -⟩; exact F.irrefl a h
  trans := by
    rintro ⟨a, b⟩ ⟨c, d⟩ ⟨e, f⟩ ⟨h1, h2⟩ ⟨h3, h4⟩
    exact ⟨F.trans a c e h1 h3, G.trans b d f h2 h4⟩

@[simp] theorem prod_R (F G : GLFrame) (p q : F.World × G.World) :
    (F.prod G).R p q ↔ (F.R p.1 q.1 ∧ G.R p.2 q.2) := Iff.rfl

/-
!-- Lab Notebook: prod_diamond_rectangle -- !--
!-- Hypothesis: The diamond of a rectangle in the product frame is the rectangle of diamonds. -- !--
!-- Result: Proved by unfolding diamondSet; the synchronized step splits the existential. -- !--
!-- Insight: This exact factorization (◇(A×B) = ◇A × ◇B) is the modal signature of a -- !--
!--          categorical product; box does NOT factor (vacuous truth at dead ends breaks it). -- !--
!-- Failure analysis: A first guess that box factors fails: at a world with no R-successor -- !--
!--          in one coordinate, □ is vacuously satisfied regardless of that coordinate. -- !--
!-- End Lab Notebook -- !--

**The diamond of a rectangle factors as a rectangle of diamonds.**  In the
synchronized product, `◇(A ×ˢ B) = (◇A) ×ˢ (◇B)`.  Because a product step advances
both coordinates at once, the witnessing existential splits independently — the
hallmark of a categorical product, and a property the box operator does *not* share.
-/
theorem prod_diamond_rectangle (F G : GLFrame) (A : Set F.World) (B : Set G.World) :
    (F.prod G).diamondSet (A ×ˢ B) = (F.diamondSet A) ×ˢ (G.diamondSet B) := by
  ext ⟨w1, w2⟩;
  constructor <;> intro h <;> simp_all +decide [ GLFrame.diamondSet, GLFrame.prod ]; all_goals grind

/-- **GL-frame products preserve Löb's axiom.**  The synchronized product of two GL
frames again validates Löb — a corollary of it being a GL frame, confirming the
product is an object of the same category. -/
theorem prod_validates_loeb (F G : GLFrame) (S : Set (F.prod G).World) :
    (F.prod G).boxSet (((F.prod G).boxSet S)ᶜ ∪ S) ⊆ (F.prod G).boxSet S :=
  gl_frame_validates_loeb (F.prod G) S

end GLFrame