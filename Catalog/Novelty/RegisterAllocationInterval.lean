/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aristotle (Harmonic)
-/
import Mathlib

/-!
# Register allocation as interval-graph colouring: the maximum-overlap law

Register allocation assigns program variables to a fixed bank of CPU registers.  Two
variables *interfere* when they are simultaneously live, and a legal assignment gives
interfering variables distinct registers; this is exactly a proper colouring of the
**interference graph**.

For programs produced by the standard *linear-scan* pipeline — and, more generally, for any
schedule in which each variable is live throughout a contiguous span of program points — the
interference graph is an **interval graph**: variables are line segments (their *live
ranges*) and two variables interfere precisely when their segments overlap.  Interval graphs
are chordal, hence perfect, so the register-allocation problem is governed by one geometric
quantity: the **maximum overlap** `maxDepth`, the largest number of live ranges active at a
single program point.

This file pins down the exact optimal register count:

* `colorable_maxDepth` — `maxDepth` registers always suffice (linear-scan optimality);
* `maxDepth_le_cliqueNum` — `maxDepth` registers are necessary;
* `chromaticNumber_eq_maxDepth`, `cliqueNum_eq_maxDepth` — `χ(G) = ω(G) = maxDepth`;
* `maxDepth_le_maxDegree_succ` — the maximum overlap never exceeds `Δ + 1`, exhibiting the
  overlap law as a sharpening of the classical greedy degree bound.

The heart of the argument is a one-dimensional **Helly property**: any set of pairwise
overlapping live ranges shares a common program point, namely the largest of their start
points.  This converts every clique into a witnessing "deep" program point, so the abstract
clique number becomes the concrete, linearly computable maximum overlap.

## Main definitions

* `Live lo hi t i`   — variable `i` is live at program point `t`.
* `interferenceGraph lo hi` — the interference graph on `Fin n`.
* `liveSet lo hi t`  — the variables live at `t`.
* `depth lo hi t`    — the overlap at `t` (`= (liveSet lo hi t).card`).
* `maxDepth lo hi`   — maximum overlap, over the start points of the live ranges.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): the general register-allocation formula "χ = max(Δ+1, ω)" is
false (Petersen: Δ+1 = 4, ω = 2, χ = 3).  But interference graphs from contiguous live
ranges are interval graphs, which are perfect; there the sharp law is χ = ω = maximum
overlap, strictly stronger than the Δ+1 greedy bound.

EXPERIMENT (Experimenter): model live ranges as closed integer segments; build the
interference graph; prove (a) a 1-D Helly property turning pairwise overlap into a common
live point, (b) the identity `clique.card ≤ maxDepth` via Helly, and (c) a greedy colouring
that processes variables "latest start first", where each variable's already-scheduled
interfering neighbours are all live at its own start point, so fewer than `maxDepth` of them
exist and a register is always free.

ANALYSIS (Analyst): Helly in one dimension is the "max of the left endpoints" witness: for
pairwise-overlapping intervals, `max lo ≤ min hi`.  The maximiser's start point is where the
deepest clique lives, which is why the geometric overlap and the graph clique number
coincide exactly, not merely up to the Δ+1 slack.  The elimination order "latest start
first" is a perfect elimination ordering.

CRITIQUE (Critic): the result is non-vacuous — at a deepest start point the live set is a
clique of size exactly `maxDepth`, so both bounds are attained and χ = ω is genuine
perfectness, not a definitional artefact.  The empty program (`n = 0`) is handled uniformly
(`maxDepth = 0`, empty clique).

SYNTHESIS (PI): the optimal register count for contiguous-live-range programs is the maximum
overlap, obtained by a single left-to-right scan; spilling is forced precisely when the
register budget drops below this overlap.
-/

open Finset SimpleGraph

namespace RegisterAllocation

variable {n : ℕ}

/-- Variable `i` is *live* at program point `t` when `t` lies in its live range `[lo i, hi i]`. -/
def Live (lo hi : Fin n → ℕ) (t : ℕ) (i : Fin n) : Prop := lo i ≤ t ∧ t ≤ hi i

/-- Two distinct variables *interfere* when their live ranges overlap. -/
def Interfere (lo hi : Fin n → ℕ) (i j : Fin n) : Prop :=
  i ≠ j ∧ lo i ≤ hi j ∧ lo j ≤ hi i

lemma Interfere.symm {lo hi : Fin n → ℕ} {i j : Fin n} (h : Interfere lo hi i j) :
    Interfere lo hi j i := ⟨h.1.symm, h.2.2, h.2.1⟩

/-- The interference graph on `Fin n`. -/
def interferenceGraph (lo hi : Fin n → ℕ) : SimpleGraph (Fin n) where
  Adj i j := Interfere lo hi i j
  symm := fun _ _ h => h.symm
  loopless := ⟨fun _ h => h.1 rfl⟩

instance (lo hi : Fin n → ℕ) : DecidableRel (interferenceGraph lo hi).Adj := by
  intro i j; unfold interferenceGraph Interfere; infer_instance

@[simp] lemma interferenceGraph_adj (lo hi : Fin n → ℕ) (i j : Fin n) :
    (interferenceGraph lo hi).Adj i j ↔ Interfere lo hi i j := Iff.rfl

/-- The set of variables live at program point `t`. -/
def liveSet (lo hi : Fin n → ℕ) (t : ℕ) : Finset (Fin n) :=
  univ.filter (fun i => lo i ≤ t ∧ t ≤ hi i)

@[simp] lemma mem_liveSet {lo hi : Fin n → ℕ} {t : ℕ} {i : Fin n} :
    i ∈ liveSet lo hi t ↔ Live lo hi t i := by
  simp [liveSet, Live]

/-- The overlap depth at program point `t`: how many variables are simultaneously live. -/
def depth (lo hi : Fin n → ℕ) (t : ℕ) : ℕ := (liveSet lo hi t).card

/-- The maximum overlap, taken over the start points of the live ranges.  (The overall
maximum overlap over *all* program points is attained at a start point, so this agrees with
the geometric maximum.) -/
def maxDepth (lo hi : Fin n → ℕ) : ℕ := univ.sup (fun i => depth lo hi (lo i))

lemma depth_lo_le_maxDepth (lo hi : Fin n → ℕ) (m : Fin n) :
    depth lo hi (lo m) ≤ maxDepth lo hi :=
  Finset.le_sup (f := fun i => depth lo hi (lo i)) (mem_univ m)

/-
The variables live at a fixed point are pairwise interfering: they form a clique.
-/
theorem liveSet_isClique (lo hi : Fin n → ℕ) (t : ℕ) :
    (interferenceGraph lo hi).IsClique (liveSet lo hi t) := by
  intro i hi j hj hij; have := hij; simp_all +decide [ interferenceGraph, Interfere ] ;
  constructor <;> linarith [ hi.1, hi.2, hj.1, hj.2 ]

/-
**One-dimensional Helly property, clique form.**  A nonempty clique of live ranges shares
a common program point: the start point of a range with the largest start point.  Hence the
clique is contained in a single live set.
-/
theorem clique_subset_liveSet (lo hi : Fin n → ℕ) (hle : ∀ i, lo i ≤ hi i)
    (s : Finset (Fin n)) (hs : s.Nonempty)
    (hclique : (interferenceGraph lo hi).IsClique (s : Set (Fin n))) :
    ∃ m ∈ s, s ⊆ liveSet lo hi (lo m) := by
  obtain ⟨ m, hm ⟩ := Finset.exists_max_image s ( fun i => lo i ) hs;
  use m, hm.1; intro i hi; simp_all +decide [ interferenceGraph, Interfere ] ;
  by_cases hi' : i = m <;> simp_all +decide [ Live ];
  exact hclique hi hm.1 hi' |>.2.2

/-
**Perfectness bound.**  Every clique in an interval interference graph has at most
`maxDepth` vertices.
-/
theorem clique_card_le_maxDepth (lo hi : Fin n → ℕ) (hle : ∀ i, lo i ≤ hi i)
    (s : Finset (Fin n))
    (hclique : (interferenceGraph lo hi).IsClique (s : Set (Fin n))) :
    s.card ≤ maxDepth lo hi := by
  by_cases hs : s.Nonempty;
  · obtain ⟨ m, hm ⟩ := clique_subset_liveSet lo hi hle s hs hclique;
    exact le_trans ( Finset.card_le_card hm.2 ) ( depth_lo_le_maxDepth lo hi m );
  · aesop

/-
**Linear-scan optimality.**  `maxDepth` registers always suffice: the interval
interference graph is `maxDepth`-colourable.  The colouring is greedy in the "latest start
first" elimination order; at each step the interfering neighbours already scheduled are all
live at the current start point, so fewer than `maxDepth` of them exist and a register is
free.
-/
theorem colorable_maxDepth (lo hi : Fin n → ℕ) (hle : ∀ i, lo i ≤ hi i) :
    (interferenceGraph lo hi).Colorable (maxDepth lo hi) := by
  rcases n with ( _ | _ | n ) <;> norm_num at *;
  · exact ⟨ fun x => x.elim0, by simp +decide ⟩;
  · refine' ⟨ fun _ => ⟨ 0, _ ⟩, _ ⟩ <;> simp +decide [ interferenceGraph, Interfere ];
    simp +decide [ maxDepth, depth, liveSet ];
    exact ⟨ 0, by simp +decide [ hle ] ⟩;
  · -- Let `k := maxDepth lo hi` and `G := interferenceGraph lo hi`.
    set k := maxDepth lo hi
    set G := interferenceGraph lo hi
    have hk : 1 ≤ k := by
      refine' le_trans _ ( Finset.le_sup ( f := fun i => depth lo hi ( lo i ) ) ( Finset.mem_univ 0 ) ) ; simp +decide [ liveSet, depth ];
      exact ⟨ 0, by simp +decide [ hle ] ⟩
    have hcolor : ∃ c : Fin (n + 1 + 1) → Fin k, ∀ v ∈ Finset.univ, ∀ w ∈ Finset.univ, G.Adj v w → c v ≠ c w := by
      have hcolor : ∀ s : Finset (Fin (n + 1 + 1)), ∃ c : Fin (n + 1 + 1) → Fin k, ∀ v ∈ s, ∀ w ∈ s, G.Adj v w → c v ≠ c w := by
        intro s
        induction' s using Finset.strongInduction with s ih
        by_cases hs : s.Nonempty
        · obtain ⟨m, hm⟩ : ∃ m ∈ s, ∀ i ∈ s, lo i ≤ lo m := by
            exact Finset.exists_max_image _ _ hs
          obtain ⟨c, hc⟩ : ∃ c : Fin (n + 1 + 1) → Fin k, ∀ v ∈ s.erase m, ∀ w ∈ s.erase m, G.Adj v w → c v ≠ c w := by
            exact ih _ ( Finset.erase_ssubset hm.1 )
          -- Let `N := (s.erase m).filter (fun w => G.Adj m w)`.
          set N := (s.erase m).filter (fun w => G.Adj m w) with hN_def
          have hN_subset : N ⊆ liveSet lo hi (lo m) := by
            intro w hw; simp_all +decide [ interferenceGraph, Interfere ] ;
            exact ⟨ hm.2 _ hw.1.2, by linarith [ hm.2 _ hw.1.2, hle w, hw.2.2 ] ⟩
          have hN_card : N.card < k := by
            refine' lt_of_le_of_lt ( Finset.card_le_card ( show N ⊆ liveSet lo hi ( lo m ) \ { m } from _ ) ) _;
            · grind;
            · rw [ Finset.card_sdiff ];
              refine' lt_of_lt_of_le ( Nat.sub_lt _ _ ) ( depth_lo_le_maxDepth lo hi m ) <;> norm_num [ hle ]; all_goals exact ⟨ m, by simp +decide [ liveSet, hle ] ⟩
          obtain ⟨cv, hcv⟩ : ∃ cv : Fin k, cv ∉ N.image c := by
            contrapose! hN_card;
            exact le_trans ( by simpa ) ( Finset.card_le_card ( show Finset.univ ⊆ Finset.image c N from fun x _ => hN_card x ) ) |> le_trans <| Finset.card_image_le;
          use fun w => if w = m then cv else c w; (
          grind +locals);
        ·
          exact ⟨ fun _ => ⟨ 0, hk ⟩, by aesop ⟩;
      exact hcolor Finset.univ;
    obtain ⟨ c, hc ⟩ := hcolor; exact ⟨ ⟨ c, by aesop ⟩ ⟩ ;

/-
A deepest start point carries a clique of size exactly `maxDepth`.
-/
theorem exists_maxDepth_clique (lo hi : Fin n → ℕ) :
    ∃ s : Finset (Fin n), (interferenceGraph lo hi).IsNClique (maxDepth lo hi) s := by
  unfold maxDepth;
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ SimpleGraph.isNClique_iff ];
  · unfold depth; simp +decide [ interferenceGraph, Live ] ;
    simp +decide [ Fin.eq_zero, liveSet, Interfere ];
    split_ifs <;> simp_all +decide [ SimpleGraph.IsClique ];
  · -- By definition of supremum, there exists some `m` such that `depth lo hi (lo m) = sup (fun i => depth lo hi (lo i))`.
    obtain ⟨m, hm⟩ : ∃ m, depth lo hi (lo m) = Finset.univ.sup (fun i => depth lo hi (lo i)) := by
      exact Finset.exists_max_image _ _ ⟨ 0, Finset.mem_univ _ ⟩ |> fun ⟨ m, hm ⟩ => ⟨ m, hm.2 |> fun h => le_antisymm ( Finset.le_sup ( f := fun i => depth lo hi ( lo i ) ) ( Finset.mem_univ m ) ) ( Finset.sup_le fun i hi => h i hi ) ⟩;
    exact ⟨ liveSet lo hi ( lo m ), liveSet_isClique lo hi ( lo m ), hm ▸ rfl ⟩

/-
**Necessity.**  The maximum overlap is a lower bound for the clique number, hence for the
number of registers.
-/
theorem maxDepth_le_cliqueNum (lo hi : Fin n → ℕ) :
    maxDepth lo hi ≤ (interferenceGraph lo hi).cliqueNum := by
  obtain ⟨s, hs⟩ : ∃ s : Finset (Fin n), (interferenceGraph lo hi).IsNClique (maxDepth lo hi) s := exists_maxDepth_clique lo hi
  have hs_card : s.card = maxDepth lo hi := hs.card_eq
  have hs_clique : (interferenceGraph lo hi).IsClique (s : Set _) := hs.1
  have hs_cliqueNum : s.card ≤ (interferenceGraph lo hi).cliqueNum := by
    apply_rules [ le_csSup ];
    · exact ⟨ n, by rintro x ⟨ s, hs ⟩ ; exact hs.card_eq ▸ le_trans ( Finset.card_le_univ _ ) ( by norm_num ) ⟩;
    · exact ⟨ s, by simpa [ hs_card ] using hs ⟩
  linarith [hs_card]

/-
The clique number equals the maximum overlap.
-/
theorem cliqueNum_eq_maxDepth (lo hi : Fin n → ℕ) (hle : ∀ i, lo i ≤ hi i) :
    (interferenceGraph lo hi).cliqueNum = maxDepth lo hi := by
  refine' le_antisymm ( csSup_le _ _ ) ( maxDepth_le_cliqueNum lo hi );
  · exact ⟨ 0, ⟨ ∅, by simp +decide [ SimpleGraph.isNClique_iff ] ⟩ ⟩;
  · rintro _ ⟨ s, hs ⟩ ; exact hs.card_eq ▸ clique_card_le_maxDepth lo hi hle s hs.1;

/-
**Perfectness of interval interference graphs.**  The chromatic number equals the maximum
overlap: linear-scan register allocation is optimal, and `χ(G) = ω(G)`.
-/
theorem chromaticNumber_eq_maxDepth (lo hi : Fin n → ℕ) (hle : ∀ i, lo i ≤ hi i) :
    (interferenceGraph lo hi).chromaticNumber = (maxDepth lo hi : ℕ∞) := by
  refine' le_antisymm _ _;
  · exact SimpleGraph.chromaticNumber_le_iff_colorable.mpr ( colorable_maxDepth lo hi hle );
  · refine' le_ciInf fun n => _;
    by_cases hn : ( interferenceGraph lo hi ).Colorable n <;> simp_all +decide [ SimpleGraph.cliqueNum_le_chromaticNumber ];
    obtain ⟨ c, hc ⟩ := hn;
    have := exists_maxDepth_clique lo hi;
    obtain ⟨ s, hs ⟩ := this; have := Finset.card_le_univ ( s.image c ) ; simp_all +decide [ SimpleGraph.isNClique_iff ] ;
    rwa [ Finset.card_image_of_injOn fun x hx y hy hxy => Classical.not_not.1 fun h => hc ( hs.1 hx hy h ) hxy, hs.2 ] at this

/-
The maximum overlap never exceeds `Δ + 1`: the overlap law refines the greedy degree
bound `χ ≤ Δ + 1`.
-/
theorem maxDepth_le_maxDegree_succ (lo hi : Fin n → ℕ) :
    maxDepth lo hi ≤ (interferenceGraph lo hi).maxDegree + 1 := by
  obtain ⟨s, hs⟩ : ∃ s : Finset (Fin n), (interferenceGraph lo hi).IsNClique (maxDepth lo hi) s := exists_maxDepth_clique lo hi;
  rcases ( isEmpty_or_nonempty s ) with h|⟨v, hv⟩ <;> simp_all +arith +decide [ SimpleGraph.isNClique_iff ];
  · linarith;
  · have h_card_erase : (s.erase v).card ≤ (interferenceGraph lo hi).degree v := by
      exact Finset.card_le_card fun x hx => by have := hs.1 ( Finset.mem_of_mem_erase hx ) hv; aesop;
    rw [ ← hs.2, ← Finset.card_erase_add_one hv ] ; linarith [ SimpleGraph.degree_le_maxDegree ( interferenceGraph lo hi ) v ] ;

end RegisterAllocation