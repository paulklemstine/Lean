import Mathlib
import Logic.GLRankStratification

/-!
# Ordinal rank as a functor: products, duality, and polymodal monotonicity

This file is the *category-theoretic / set-theoretic* continuation of the GL Kripke
program built in
`Catalog/Logic/GLKripke.lean` (`GLFrame`, `GLFrame.boxSet`, `GLFrame.diamondSet`,
`gl_frame_validates_loeb`, `diamond_box_dual`),
`Catalog/Logic/PolymodalGL.lean` (`GLFrame.rank`, `gl_rank_lt_of_R`, `GLFrame.prod`,
`GLPFrame`, `GLPFrame.level`, `GLPFrame.R_anti`), and
`Catalog/Logic/GLRankStratification.lean`
(`GLFrame.boxSet_iterate_eq_rank_lt`, the rank stratification `□^k ∅ = {rank < k}`).

The unifying theme: the **ordinal rank** of a GL frame behaves like a functor that
turns the constructions of the GL world (categorical products, modal duality, the
polymodal nesting of accessibility relations) into elementary ordinal arithmetic.

## Main results

* `IsWellFounded.rank_mono_of_subrel` — a general set-theoretic lemma: the
  well-founded rank is **monotone under shrinking the relation**.  Restricting a
  well-founded relation can only lower ordinal ranks.

* `GLFrame.diamondSet_iterate_univ_eq_rank_ge` — the **diamond dual of the rank
  stratification**: `◇^k univ = {w | k ≤ rank w}`.  The `k`-fold "consistency"
  statement holds exactly at worlds of ordinal rank at least `k`, the exact
  set-complement of the Löb stratification `□^k ∅ = {rank < k}`.

* `GLFrame.prod_rank_eq_min` — the **rank of a categorical product is the pointwise
  minimum**: `rank (a,b) = min (rank a) (rank b)` in `F.prod G`.  A synchronized
  descending chain stops as soon as *either* coordinate is exhausted, so the
  consistency strength of a product world is the weaker of its two coordinates.

* `GLPFrame.rank_anti_in_level` — **polymodal rank is antitone in the modality
  index**: for `n ≤ m`, `(level m).rank w ≤ (level n).rank w`.  Sparser, higher
  modalities assign smaller ordinals — the rank-theoretic shadow of the GLP
  monotonicity axiom `[n]φ → [n+1]φ`.

-- !-- Lab Notebook: GLRankCategory (overview) -- !--
-- !-- Hypothesis: The ordinal rank `GLFrame.rank` is "functorial": modal duality, -- !--
-- !--   categorical products, and the polymodal nesting all become ordinal arithmetic. -- !--
-- !-- Result: All four targets proved. Diamond duality is the set-complement of the -- !--
-- !--   Löb stratification; product rank is the pointwise min; polymodal rank is -- !--
-- !--   antitone in the level via a general subrelation-monotonicity lemma. -- !--
-- !-- Insight: `rank` converts the *order-theoretic* operations on frames into the -- !--
-- !--   *lattice* operations on ordinals (min for product, complement for duality, -- !--
-- !--   ≤ for relation inclusion). The accessibility relation is the only structure; -- !--
-- !--   every modal fact is a fact about a single converse-well-founded order. -- !--
-- !-- Failure analysis: see per-theorem notes; the recurring trap is the `succ` in -- !--
-- !--   `rank w = ⨆ succ (rank v)`, which forces strict `<` and off-by-one care. -- !--
-- !-- End Lab Notebook -- !--
-/

open Set Function

universe u

/-! ## Part 0: Rank monotonicity under shrinking the relation (Set Theory) -/

/-
!-- Lab Notebook: IsWellFounded.rank_mono_of_subrel -- !--
!-- Hypothesis: Shrinking a well-founded relation can only decrease ordinal ranks. -- !--
!-- Result: Proved by well-founded induction on `r`; each `r`-predecessor is an -- !--
!--   `s`-predecessor, and the indexing set of the `⨆` over `r` embeds into that of `s`. -- !--
!-- Insight: Rank is the order type of the predecessor tree; deleting edges can only -- !--
!--   prune the tree, never deepen it. This is the abstract engine behind both the -- !--
!--   polymodal antitonicity and (one direction of) the product-rank computation. -- !--
!-- Failure analysis: A direct ⨆-comparison needs the predecessor *subtype* inclusion, -- !--
!--   handled by bounding each summand and using `Ordinal.iSup_le_iff`. -- !--
!-- End Lab Notebook -- !--

**Rank is monotone under shrinking the relation.**  If `r x y → s x y` for all
`x y` (i.e. `r ⊆ s`) and both relations are well-founded, then the `r`-rank is
pointwise `≤` the `s`-rank.  Removing edges from a well-founded relation can only
lower ordinal ranks.
-/
theorem IsWellFounded.rank_mono_of_subrel {α : Type*} (r s : α → α → Prop)
    [IsWellFounded α r] [IsWellFounded α s] (h : ∀ x y, r x y → s x y) (a : α) :
    IsWellFounded.rank r a ≤ IsWellFounded.rank s a := by
  induction' j : rank s a using Ordinal.induction with j ih generalizing a;
  rw [ ← j, IsWellFounded.rank_eq ];
  apply Ordinal.iSup_le;
  intro i
  have h_rank_lt : rank s i.val < rank s a := by
    exact IsWellFounded.rank_lt_of_rel ( h _ _ i.2 );
  exact Order.succ_le_of_lt ( lt_of_le_of_lt ( ih _ ( by aesop ) _ rfl ) h_rank_lt )

/-
**Rank decreases along a relation homomorphism.**  If `f : α → β` maps `r`-edges to
`s`-edges (`r x y → s (f x) (f y)`) between well-founded relations, then
`rank r a ≤ rank s (f a)`.  Generalizes `rank_mono_of_subrel` (the case `f = id`); it
is the engine for the `≤` direction of the product-rank computation, applied to the
two coordinate projections.
-/
theorem IsWellFounded.rank_le_of_relHom {α β : Type u} (r : α → α → Prop)
    (s : β → β → Prop) [IsWellFounded α r] [IsWellFounded β s] (f : α → β)
    (hf : ∀ x y, r x y → s (f x) (f y)) (a : α) :
    IsWellFounded.rank r a ≤ IsWellFounded.rank s (f a) := by
  induction' j : rank s ( f a ) using Ordinal.induction with j ih generalizing a;
  rw [ ← j, IsWellFounded.rank_eq ];
  refine' ciSup_le' _;
  rintro ⟨ b, hb ⟩;
  exact Order.succ_le_of_lt ( lt_of_le_of_lt ( ih _ ( by exact IsWellFounded.rank_lt_of_rel ( hf _ _ hb ) |> lt_of_lt_of_le <| by aesop ) _ rfl ) ( IsWellFounded.rank_lt_of_rel ( hf _ _ hb ) ) )

/-! ## Part 1: Diamond stratification — the dual of the Löb rank stratification -/

namespace GLFrame

/-
The iterated diamond of the universe is the set-complement of the iterated box of
the empty set: `◇^k univ = (□^k ∅)ᶜ`.  Pure modal duality, lifted through iteration.
-/
theorem diamondSet_iterate_univ_eq_compl_box (F : GLFrame) (k : ℕ) :
    F.diamondSet^[k] (Set.univ) = (F.boxSet^[k] (∅ : Set F.World))ᶜ := by
  convert Set.ext _;
  induction k <;> simp_all +decide [ Function.iterate_succ_apply', GLFrame.diamondSet, GLFrame.boxSet ]

/-
!-- Lab Notebook: GLFrame.diamondSet_iterate_univ_eq_rank_ge -- !--
!-- Hypothesis: `◇^k univ = {w | k ≤ rank w}`, the dual of `□^k ∅ = {rank < k}`. -- !--
!-- Result: Proved by combining the iterated-duality lemma `◇^k univ = (□^k ∅)ᶜ` -- !--
!-- with the stratification `boxSet_iterate_eq_rank_lt` and `not_lt` on ordinals. -- !--
!-- Insight: Consistency `◇^k ⊤` and inconsistency `□^k ⊥` partition every GL frame -- !--
!-- by the single ordinal-rank cut at `k`. Gödel "k-consistency" = "rank ≥ k". -- !--
!-- Failure analysis: Must use the linear order of Ordinal (`not_lt`) to flip the -- !--
!-- complement of `{rank < k}` into `{k ≤ rank}`; a Boolean `decide` will not do it. -- !--
!-- End Lab Notebook -- !--

**The diamond rank stratification.**  For every `k`, the `k`-fold diamond of the
universe is exactly the set of worlds of ordinal rank `≥ k`:
`◇^k univ = { w | k ≤ rank w }`.  This is the exact set-theoretic complement of the
Löb stratification `□^k ∅ = { w | rank w < k }`, so the "`k`-fold consistency"
statement and the "`k`-fold falsity" statement carve every GL frame at the single
ordinal cut `rank = k`.
-/
theorem diamondSet_iterate_univ_eq_rank_ge (F : GLFrame) (k : ℕ) :
    F.diamondSet^[k] (Set.univ) = { w | (k : Ordinal) ≤ F.rank w } := by
  rw [ GLFrame.diamondSet_iterate_univ_eq_compl_box ];
  have := GLFrame.boxSet_iterate_eq_rank_lt F k; ext w; simp +decide [ this ] ;

/-! ## Part 2: Rank of a categorical product is the pointwise minimum -/

/-
**`≤` direction of the product-rank theorem.**  The rank of a product world is at
most the rank of each coordinate, hence at most their minimum.  Each bound is an
instance of `IsWellFounded.rank_le_of_relHom` for a coordinate projection, which is a
relation homomorphism `flip (F.prod G).R → flip F.R` (resp. `G`).
-/
theorem prod_rank_le (F G : GLFrame) (a : F.World) (b : G.World) :
    (F.prod G).rank (a, b) ≤ min (F.rank a) (G.rank b) := by
  refine' le_min _ _;
  · convert @IsWellFounded.rank_le_of_relHom _ _ ( fun p q => ( F.prod G ).R q p ) ( fun p q => F.R q p ) _ _ ( fun p => p.1 ) _ ( a, b ) using 1;
    exact fun x y h => h.1;
  · convert @IsWellFounded.rank_le_of_relHom _ _ ( fun p q => ( F.prod G ).R q p ) ( fun p q => G.R q p ) _ _ ( fun p => p.2 ) _ ( a, b ) using 1;
    aesop

/-
**`≥` direction of the product-rank theorem.**  The minimum of the coordinate
ranks is at most the product rank.  Proof: well-founded induction on the product
accessibility; for any ordinal `o` below the minimum we find coordinate successors
`v, w` with `o ≤ rank v` and `o ≤ rank w`; then `(v,w)` is a product successor and the
induction hypothesis gives `o ≤ min (rank v) (rank w) ≤ rank (v,w) < rank (a,b)`.
-/
theorem prod_rank_ge (F G : GLFrame) (a : F.World) (b : G.World) :
    min (F.rank a) (G.rank b) ≤ (F.prod G).rank (a, b) := by
  have h_le : ∀ (p : (F.prod G).World), min (F.rank p.1) (G.rank p.2) ≤ (F.prod G).rank p := by
    intro p;
    induction' p using WellFoundedLT.induction with p ih;
    convert le_of_forall_lt _;
    rotate_left;
    exact ⟨ fun x y => ( F.prod G ).R y x ⟩;
    · exact ⟨ F.prod G |> GLFrame.flip_wellFounded ⟩;
    · intro c hc;
      -- By definition of rank, there exist $v \in F$ and $w \in G$ such that $F.R p.1 v$, $G.R p.2 w$, and $c \leq \min(F.rank v, G.rank w)$.
      obtain ⟨v, hv⟩ : ∃ v : F.World, F.R p.1 v ∧ c ≤ F.rank v := by
        have h_succ : c < ⨆ (i : {v // F.R p.1 v}), Order.succ (F.rank i) := by
          convert hc.trans_le ( min_le_left _ _ ) using 1;
          convert IsWellFounded.rank_eq ( flip F.R ) p.1 |> Eq.symm using 1;
        contrapose! h_succ;
        refine' ciSup_le' _;
        exact fun i => Order.succ_le_of_lt ( h_succ _ i.2 )
      obtain ⟨w, hw⟩ : ∃ w : G.World, G.R p.2 w ∧ c ≤ G.rank w := by
        contrapose! hc;
        refine' le_trans ( min_le_right _ _ ) _;
        rw [ GLFrame.rank ];
        rw [ IsWellFounded.rank_eq ];
        refine' ciSup_le' _;
        rintro ⟨ w, hw ⟩;
        exact Order.succ_le_of_lt ( hc _ hw );
      refine' lt_of_le_of_lt _ ( gl_rank_lt_of_R ( F.prod G ) ( show ( F.prod G ).R p ( v, w ) from ⟨ hv.1, hw.1 ⟩ ) );
      refine' le_trans _ ( ih ( v, w ) _ );
      · exact le_min hv.2 hw.2;
      · exact ⟨ hv.1, hw.1 ⟩;
  exact h_le ( a, b )

-- !-- Lab Notebook: GLFrame.prod_rank_eq_min -- !--
-- !-- Hypothesis: In the synchronized product `F.prod G`, `rank (a,b) = min (rank a) (rank b)`. -- !--
-- !-- Result: Proved by well-founded induction on the product accessibility relation. -- !--
-- !-- Insight: A product step advances both coordinates; the longest synchronized -- !--
-- !-- descending chain has length `min` of the two component heights. Rank turns the -- !--
-- !-- categorical product into the lattice meet of ordinals. -- !--
-- !-- Failure analysis: The `⨆ succ` over product predecessors must be matched against -- !--
-- !-- `min` of two component `⨆ succ`; `max_{c,d} min(rank c, rank d) = min(max,max)` is -- !--
-- !-- the combinatorial heart, valid because predecessors of `a` and `b` are independent. -- !--
-- !-- End Lab Notebook -- !--
/-- **The rank of a categorical product is the pointwise minimum.**  In the
synchronized product frame `F.prod G`, the ordinal rank of a pair is the minimum of
the coordinate ranks: `rank (a, b) = min (rank a) (rank b)`.  Because a product step
must advance *both* coordinates, a synchronized descending chain terminates as soon
as either coordinate is exhausted; consistency strength of a product world is that of
its weaker coordinate.  This is the ordinal-arithmetic signature of a categorical
product (meet), complementing `prod_diamond_rectangle`. -/
theorem prod_rank_eq_min (F G : GLFrame) (a : F.World) (b : G.World) :
    (F.prod G).rank (a, b) = min (F.rank a) (G.rank b) :=
  le_antisymm (prod_rank_le F G a b) (prod_rank_ge F G a b)

end GLFrame

/-! ## Part 3: Polymodal rank is antitone in the modality index -/

namespace GLPFrame

/-
!-- Lab Notebook: GLPFrame.rank_anti_in_level -- !--
!-- Hypothesis: Higher (sparser) modalities assign smaller ordinal ranks. -- !--
!-- Result: Proved from `IsWellFounded.rank_mono_of_subrel` applied to the converse -- !--
!-- relations, using `R_anti` (R m ⊆ R n for n ≤ m). -- !--
!-- Insight: This is the rank-theoretic content of the GLP axiom [n]φ → [n+1]φ: as -- !--
!-- the modality index grows, the accessibility shrinks, so ordinal capital drops. -- !--
!-- Failure analysis: `rank` is defined via `flip R`; the subrelation lemma must be -- !--
!-- fed the *flipped* inclusion, which holds because `flip` is monotone in the relation. -- !--
!-- End Lab Notebook -- !--

**Polymodal rank is antitone in the modality index.**  For a GLP frame and
`n ≤ m`, the ordinal rank computed at the sparser level `m` is `≤` the rank at level
`n`: `(level m).rank w ≤ (level n).rank w`.  Since `R m ⊆ R n`, the higher modality
sees fewer worlds and therefore spends less ordinal capital — the rank shadow of the
GLP monotonicity axiom `[n]φ → [n+1]φ`.
-/
theorem rank_anti_in_level (G : GLPFrame) {n m : ℕ} (hnm : n ≤ m) (w : G.World) :
    (G.level m).rank w ≤ (G.level n).rank w := by
  haveI hm : IsWellFounded G.World (flip (G.R m)) := ⟨(G.level m).flip_wellFounded⟩
  haveI hn : IsWellFounded G.World (flip (G.R n)) := ⟨(G.level n).flip_wellFounded⟩
  have key :
      @IsWellFounded.rank G.World (flip (G.R m)) hm w
        ≤ @IsWellFounded.rank G.World (flip (G.R n)) hn w :=
    IsWellFounded.rank_mono_of_subrel (flip (G.R m)) (flip (G.R n))
      (fun x y h => G.R_anti hnm h) w
  exact key

end GLPFrame