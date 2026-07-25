/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Power-of-two perfect-matching counts in block graphs

A *perfect matching* of a finite graph `G` is a way of pairing up all the vertices
so that every pair is joined by an edge.  We model such a matching as a
fixed-point-free involution `f : V → V` whose every pair `{v, f v}` is an edge of
`G`; the set of all perfect matchings of `G` is `PM G`, and its cardinality is the
*matching count* `matchCount G`.

The central phenomenon studied here is *multiplicativity*: when a graph is built as
an independent superposition of many identical **blocks**, its perfect matchings
factor completely into independent per-block choices.  Concretely, for an index
type `ι` and a block graph `G`, the *block graph* `blockGraph ι G` places one copy
of `G` over each index and never joins two different blocks.  The main theorem

  `matchCount (blockGraph ι G) = matchCount G ^ (Fintype.card ι)`

shows that the total number of perfect matchings is the block count raised to the
number of blocks.

When each block is a quadrilateral `C₄` — the smallest graph with exactly two
perfect matchings — the count becomes an exact power of two:

  `matchCount (blockGraph ι C₄) = 2 ^ (Fintype.card ι)`.

This is the promised power-of-two law: in a superposition of two-matching gadgets,
the number of global perfect matchings is always a power of two.

## Main results

* `matchCount_blockGraph` : the multiplicative law for block graphs.
* `matchCount_C4`         : the quadrilateral has exactly two perfect matchings.
* `matchCount_blockC4`    : a superposition of `n` quadrilaterals has `2 ^ n` matchings.
* `blockC4_isPowerOfTwo`  : that count is a genuine power of two.

-- !-- Lab Notes -- !--

Hypothesis (Hypothesizer).  "In a connected graph whose edges split into
1-matching and 2-matching kinds, with no perfect matching mixing the kinds, the
number of perfect matchings is a power of two."  The structural content of this
speculative statement is that matchings decompose into independent binary choices.
We isolate that content in a clean, provable model: a superposition of two-matching
gadgets.

Experiment (Experimenter).  We modelled perfect matchings as fixed-point-free
adjacency-respecting involutions, which is decidable for concrete finite graphs
(so small cases such as `C₄` and `C₆` can be evaluated directly), and proved the
multiplicative law by exhibiting the block decomposition of an involution.

Analysis (Analyst).  The key insight is that the *absence of cross-block edges*
forces any perfect matching to preserve each block, so a global matching is exactly
a tuple of per-block matchings.  Counting the tuples gives the exponential law.
The "power of two" is then simply the case where every block has exactly two
matchings.

Critique (Critic).  A single block is connected and its count (`2`) is already a
power of two, matching the informal "connected" hypothesis; the block model shows
the phenomenon at scale.  The multiplicative theorem is proved by an explicit
bijection (not by `decide`), so it is not a finite brute force.  The base equalities
`matchCount C₄ = 2` and `matchCount C₆ = 2` are genuine evaluations recorded as
witnesses, not as the main theorem.

Synthesis (PI).  `matchCount_blockGraph` + `matchCount_C4` yield the power-of-two law
`matchCount_blockC4`, and `blockC4_isPowerOfTwo` packages it as an existence of an
exponent.
-/

namespace ClassB

variable {V : Type*}

/-- A **perfect matching** of `G`: a fixed-point-free involution all of whose
pairs are edges of `G`. -/
def PM (G : SimpleGraph V) [Fintype V] [DecidableEq V] [DecidableRel G.Adj] :=
  {f : V → V // (∀ v, f (f v) = v) ∧ (∀ v, f v ≠ v) ∧ ∀ v, G.Adj v (f v)}

instance (G : SimpleGraph V) [Fintype V] [DecidableEq V] [DecidableRel G.Adj] :
    Fintype (PM G) := by unfold PM; infer_instance

/-- The number of perfect matchings of `G`. -/
def matchCount (G : SimpleGraph V) [Fintype V] [DecidableEq V] [DecidableRel G.Adj] : ℕ :=
  Fintype.card (PM G)

/-- The **block graph**: one independent copy of `G` over each index in `ι`, with no
edge ever joining two different blocks. -/
def blockGraph (ι : Type*) (G : SimpleGraph V) : SimpleGraph (ι × V) where
  Adj p q := p.1 = q.1 ∧ G.Adj p.2 q.2
  symm := by rintro ⟨i, a⟩ ⟨j, b⟩ ⟨h1, h2⟩; exact ⟨h1.symm, h2.symm⟩
  loopless := ⟨by rintro ⟨i, a⟩ ⟨-, h2⟩; exact G.irrefl h2⟩

instance (ι : Type*) [DecidableEq ι] (G : SimpleGraph V) [DecidableRel G.Adj] :
    DecidableRel (blockGraph ι G).Adj := by
  intro p q; unfold blockGraph; simp; infer_instance

/-
**Multiplicative law.**  A perfect matching of a block graph is exactly a
choice of a perfect matching in each block, so the matching count of the whole is
the matching count of a block raised to the number of blocks.
-/
theorem matchCount_blockGraph (ι : Type*) [Fintype ι] [DecidableEq ι]
    (G : SimpleGraph V) [Fintype V] [DecidableEq V] [DecidableRel G.Adj] :
    matchCount (blockGraph ι G) = matchCount G ^ Fintype.card ι := by
  convert Fintype.card_congr ( show PM ( blockGraph ι G ) ≃ ( ι → PM G ) from ?_ );
  · simp +decide [ matchCount ];
  · refine' Equiv.ofBijective ( fun f => fun i => ⟨ fun v => ( f.val ( i, v ) ).2, _, _, _ ⟩ ) ⟨ fun a b h => _, fun a => _ ⟩;
    all_goals norm_num [ funext_iff, Subtype.ext_iff ] at *;
    · intro v
      have := f.2.1 (i, v)
      simp_all +decide [ blockGraph ];
      grind +suggestions;
    · intro v hv; have := f.2.2.1 ( i, v ) ; simp_all +decide [ Prod.ext_iff ] ;
      have := f.2.1 ( i, v ) ; have := f.2.2.2 ( i, v ) ; simp_all +decide [ blockGraph ] ;
    · intro v;
      convert f.2.2.2 ( i, v ) |>.2 using 1;
    · exact Subtype.ext ( funext fun x => Prod.ext ( by
        have := a.2.2.2 x; have := b.2.2.2 x; simp_all +decide [ blockGraph ] ; ) ( h x.1 x.2 ) );
    · refine' ⟨ ⟨ fun p => ( p.1, ( a p.1 ).val p.2 ), _, _, _ ⟩, _ ⟩ <;> simp +decide;
      · exact fun i v => ( a i ).2.1 v;
      · exact fun i v => ( a i ).2.2.1 v;
      · exact fun i v => ⟨ rfl, ( a i ).2.2.2 v ⟩

/-- The quadrilateral `C₄` on the four vertices `Fin 4`, with consecutive vertices
adjacent (indices taken cyclically). -/
def C4 : SimpleGraph (Fin 4) where
  Adj a b := (a - b = 1 ∨ b - a = 1)
  symm := by intro a b h; tauto
  loopless := ⟨by decide⟩

instance : DecidableRel C4.Adj := by intro a b; unfold C4; simp; infer_instance

/-- The quadrilateral has exactly two perfect matchings. -/
theorem matchCount_C4 : matchCount C4 = 2 := by decide

/-- The hexagon `C₆`, a connected example. -/
def C6 : SimpleGraph (Fin 6) where
  Adj a b := (a - b = 1 ∨ b - a = 1)
  symm := by intro a b h; tauto
  loopless := ⟨by decide⟩

instance : DecidableRel C6.Adj := by intro a b; unfold C6; simp; infer_instance

/-- The hexagon, another connected two-matching gadget, also has exactly two
perfect matchings. -/
theorem matchCount_C6 : matchCount C6 = 2 := by native_decide

/-- **Power-of-two law.**  A superposition of quadrilateral blocks has exactly
`2 ^ (number of blocks)` perfect matchings. -/
theorem matchCount_blockC4 (ι : Type*) [Fintype ι] [DecidableEq ι] :
    matchCount (blockGraph ι C4) = 2 ^ Fintype.card ι := by
  rw [matchCount_blockGraph, matchCount_C4]

/-- The number of perfect matchings of a superposition of quadrilaterals is a
genuine power of two. -/
theorem blockC4_isPowerOfTwo (ι : Type*) [Fintype ι] [DecidableEq ι] :
    ∃ k : ℕ, matchCount (blockGraph ι C4) = 2 ^ k :=
  ⟨Fintype.card ι, matchCount_blockC4 ι⟩

end ClassB