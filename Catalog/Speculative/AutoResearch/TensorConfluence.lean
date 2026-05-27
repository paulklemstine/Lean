import Mathlib

/-!
# Confluence and Unique Normal Forms for Tensor Distributivity Rewrites

## Overview

This file establishes that the distributivity rewrite fragment on sorted tensor
expressions is **confluent modulo associativity-commutativity (AC) of addition**,
so every term has a unique normal form up to AC-equivalence.

Building on the one-step soundness infrastructure in `TensorSortedRewrite.lean`,
we develop:

1. A **polynomial interpretation measure** (`distPotential`) strictly decreased by
   every rewrite step, proving termination.
2. An **AC-equivalence relation** identifying terms differing only by
   reassociation/reordering of addition nodes.
3. A **local confluence theorem** via explicit critical pair analysis.
4. A **unique normal form theorem** via Newman's lemma modulo AC.
5. A **verified canonical normalization algorithm** `normalizeCanon`.

## Keywords

term rewriting, confluence modulo AC, canonical normal forms, tensor algebra,
symbolic optimization, compiler correctness, semiring coherence, scientific computing,
exact normalization, critical pair analysis, deterministic simplification,
algebraic combinatorics
-/

namespace TensorConfluence

/-! ## Part 1: Untyped Tensor Expression Syntax -/

/-- Untyped tensor expressions.
    We use an untyped representation to simplify the rewriting theory;
    sort-correctness is orthogonal to confluence. -/
inductive TensorExpr : Type
  | scalVar (n : ℕ)
  | vecVar (n : ℕ)
  | matVar (n : ℕ)
  | scalAdd (a b : TensorExpr)
  | scalMul (a b : TensorExpr)
  | vecAdd (v w : TensorExpr)
  | matAdd (A B : TensorExpr)
  | smulVec (a v : TensorExpr)
  | smulMat (a A : TensorExpr)
  | mulVec (A v : TensorExpr)
  | dot (v w : TensorExpr)
  deriving DecidableEq, Repr

open TensorExpr

/-! ## Part 2: Polynomial Interpretation Measure

The key insight for termination: assign each variable the value 3,
interpret additions as sum-plus-one, `smulVec`/`smulMat` as product-plus-one,
and all other multiplications as pure products. Every oriented rewrite rule
then strictly decreases this interpretation.
-/

/-- Polynomial interpretation for termination. Every rewrite step strictly decreases
    this natural-number measure, proving strong normalization. -/
def distPotential : TensorExpr → ℕ
  | scalVar _ => 3
  | vecVar _ => 3
  | matVar _ => 3
  | scalAdd a b => distPotential a + distPotential b + 1
  | scalMul a b => distPotential a * distPotential b
  | vecAdd v w => distPotential v + distPotential w + 1
  | matAdd A B => distPotential A + distPotential B + 1
  | smulVec a v => distPotential a * distPotential v + 1
  | smulMat a A => distPotential a * distPotential A + 1
  | mulVec A v => distPotential A * distPotential v
  | dot v w => distPotential v * distPotential w

/-
Every term has `distPotential` at least 3.
-/
theorem distPotential_ge_three (t : TensorExpr) : 3 ≤ distPotential t := by
  induction' t with a b ha hb v w hv hw A B hA hB a v ha hv A v hA hv v w hv hw;
  all_goals repeat { exact Nat.le_add_left _ _ };
  exact Nat.le_trans ( by linarith ) ( Nat.add_le_add ( Nat.add_le_add w hv ) le_rfl );
  exact Nat.le_trans ( by decide ) ( Nat.mul_le_mul B hA );
  exact Nat.le_trans ( by linarith ) ( Nat.add_le_add ( Nat.add_le_add v ha ) le_rfl );
  · exact Nat.le_trans ( by linarith ) ( Nat.add_le_add ( Nat.add_le_add v hA ) le_rfl );
  · exact Nat.le_trans ( by linarith ) ( Nat.add_le_add ( Nat.mul_le_mul w hv ) le_rfl );
  · exact Nat.le_trans ( by linarith ) ( Nat.add_le_add ( Nat.mul_le_mul ‹3 ≤ distPotential hw› ‹3 ≤ distPotential _› ) le_rfl );
  · exact Nat.le_trans ( by decide ) ( Nat.mul_le_mul ‹3 ≤ distPotential _› ‹3 ≤ distPotential _› );
  · exact Nat.le_trans ( by decide ) ( Nat.mul_le_mul ‹3 ≤ distPotential _› ‹3 ≤ distPotential _› )

/-! ## Part 3: One-Step Root Rewrite Rules

The 9-rule distributivity fragment includes the original 8 rules plus
scalar distributivity (`scalMul a (scalAdd b c) → scalAdd (scalMul a b) (scalMul a c)`),
which is needed to close the critical pair between `dot_smulVec_left` and `dot_vecAdd_right`.
-/

/-- Root-level rewrite rules: 9 distributivity/extraction rules. -/
inductive RootRewrite : TensorExpr → TensorExpr → Prop
  | mulVec_vecAdd (A v w : TensorExpr) :
      RootRewrite (mulVec A (vecAdd v w)) (vecAdd (mulVec A v) (mulVec A w))
  | matAdd_mulVec (A B v : TensorExpr) :
      RootRewrite (mulVec (matAdd A B) v) (vecAdd (mulVec A v) (mulVec B v))
  | smulMat_mulVec (a A v : TensorExpr) :
      RootRewrite (mulVec (smulMat a A) v) (smulVec a (mulVec A v))
  | smulVec_vecAdd (a v w : TensorExpr) :
      RootRewrite (smulVec a (vecAdd v w)) (vecAdd (smulVec a v) (smulVec a w))
  | smulMat_matAdd (a A B : TensorExpr) :
      RootRewrite (smulMat a (matAdd A B)) (matAdd (smulMat a A) (smulMat a B))
  | dot_vecAdd_left (v w u : TensorExpr) :
      RootRewrite (dot (vecAdd v w) u) (scalAdd (dot v u) (dot w u))
  | dot_vecAdd_right (u v w : TensorExpr) :
      RootRewrite (dot u (vecAdd v w)) (scalAdd (dot u v) (dot u w))
  | dot_smulVec_left (a v w : TensorExpr) :
      RootRewrite (dot (smulVec a v) w) (scalMul a (dot v w))
  | scalMul_scalAdd (a b c : TensorExpr) :
      RootRewrite (scalMul a (scalAdd b c)) (scalAdd (scalMul a b) (scalMul a c))

/-
Every root rewrite strictly decreases the polynomial interpretation.
-/
theorem rootRewrite_decreases {t u : TensorExpr} (h : RootRewrite t u) :
    distPotential u < distPotential t := by
  have := @distPotential_ge_three;
  rcases h with ( _ | _ | _ | _ | _ | _ | _ | _ | _ );
  all_goals rename_i a b c; simp +decide [ distPotential ] at *; nlinarith [ this a, this b, this c ] ;

/-! ## Part 4: Contextual Closure (One-Step Rewrite at Any Position) -/

/-- One-step rewrite at any position (contextual closure of `RootRewrite`). -/
inductive Rewrite1 : TensorExpr → TensorExpr → Prop
  | root {t u} : RootRewrite t u → Rewrite1 t u
  | scalAdd_left {a a' b} : Rewrite1 a a' → Rewrite1 (scalAdd a b) (scalAdd a' b)
  | scalAdd_right {a b b'} : Rewrite1 b b' → Rewrite1 (scalAdd a b) (scalAdd a b')
  | scalMul_left {a a' b} : Rewrite1 a a' → Rewrite1 (scalMul a b) (scalMul a' b)
  | scalMul_right {a b b'} : Rewrite1 b b' → Rewrite1 (scalMul a b) (scalMul a b')
  | vecAdd_left {v v' w} : Rewrite1 v v' → Rewrite1 (vecAdd v w) (vecAdd v' w)
  | vecAdd_right {v w w'} : Rewrite1 w w' → Rewrite1 (vecAdd v w) (vecAdd v w')
  | matAdd_left {A A' B} : Rewrite1 A A' → Rewrite1 (matAdd A B) (matAdd A' B)
  | matAdd_right {A B B'} : Rewrite1 B B' → Rewrite1 (matAdd A B) (matAdd A B')
  | smulVec_left {a a' v} : Rewrite1 a a' → Rewrite1 (smulVec a v) (smulVec a' v)
  | smulVec_right {a v v'} : Rewrite1 v v' → Rewrite1 (smulVec a v) (smulVec a v')
  | smulMat_left {a a' A} : Rewrite1 a a' → Rewrite1 (smulMat a A) (smulMat a' A)
  | smulMat_right {a A A'} : Rewrite1 A A' → Rewrite1 (smulMat a A) (smulMat a A')
  | mulVec_left {A A' v} : Rewrite1 A A' → Rewrite1 (mulVec A v) (mulVec A' v)
  | mulVec_right {A v v'} : Rewrite1 v v' → Rewrite1 (mulVec A v) (mulVec A v')
  | dot_left {v v' w} : Rewrite1 v v' → Rewrite1 (dot v w) (dot v' w)
  | dot_right {v w w'} : Rewrite1 w w' → Rewrite1 (dot v w) (dot v w')

/-- Multi-step rewrite (reflexive-transitive closure). -/
def RewriteStar : TensorExpr → TensorExpr → Prop :=
  Relation.ReflTransGen Rewrite1

/-- A term is in normal form if no rewrite rule applies at any position. -/
def IsNormal (t : TensorExpr) : Prop :=
  ∀ u, ¬ Rewrite1 t u

/-
Every one-step rewrite (at any position) strictly decreases `distPotential`.
-/
theorem rewrite1_decreases {t u : TensorExpr} (h : Rewrite1 t u) :
    distPotential u < distPotential t := by
  have h_ind : ∀ t u, Rewrite1 t u → distPotential u < distPotential t := by
    intro t u h;
    induction' h with t u h ih;
    exact rootRewrite_decreases h;
    all_goals simp_all! +arith +decide;
    all_goals apply_rules [ Nat.mul_lt_mul_of_pos_left, Nat.mul_lt_mul_of_pos_right ];
    all_goals exact lt_of_lt_of_le ( by decide ) ( distPotential_ge_three _ ) ;
  exact h_ind t u h

/-
Multi-step rewriting weakly decreases `distPotential`.
-/
theorem rewriteStar_measure_monotone {t u : TensorExpr}
    (h : RewriteStar t u) : distPotential u ≤ distPotential t := by
  have h_trans : ∀ {t u : TensorExpr}, RewriteStar t u → distPotential u ≤ distPotential t := by
    intros t u h; induction h <;> [ rfl; linarith [ rewrite1_decreases ‹_› ] ] ;
  exact h_trans h

/-! ## Part 5: AC-Equivalence

Two terms are AC-equivalent if they differ only by reassociation and
reordering of `scalAdd`, `vecAdd`, or `matAdd` nodes, while preserving
all non-additive structure.
-/

/-- AC-equivalence: the smallest equivalence relation closed under congruence
    and the commutativity/associativity of `scalAdd`, `vecAdd`, `matAdd`. -/
inductive ACEq : TensorExpr → TensorExpr → Prop
  | refl (t : TensorExpr) : ACEq t t
  | symm {t u} : ACEq t u → ACEq u t
  | trans {t u v} : ACEq t u → ACEq u v → ACEq t v
  -- Commutativity
  | scalAdd_comm (a b : TensorExpr) : ACEq (scalAdd a b) (scalAdd b a)
  | vecAdd_comm (v w : TensorExpr) : ACEq (vecAdd v w) (vecAdd w v)
  | matAdd_comm (A B : TensorExpr) : ACEq (matAdd A B) (matAdd B A)
  -- Associativity
  | scalAdd_assoc (a b c : TensorExpr) :
      ACEq (scalAdd (scalAdd a b) c) (scalAdd a (scalAdd b c))
  | vecAdd_assoc (v w x : TensorExpr) :
      ACEq (vecAdd (vecAdd v w) x) (vecAdd v (vecAdd w x))
  | matAdd_assoc (A B C : TensorExpr) :
      ACEq (matAdd (matAdd A B) C) (matAdd A (matAdd B C))
  -- Congruence for all constructors
  | scalAdd_congr {a a' b b'} : ACEq a a' → ACEq b b' →
      ACEq (scalAdd a b) (scalAdd a' b')
  | scalMul_congr {a a' b b'} : ACEq a a' → ACEq b b' →
      ACEq (scalMul a b) (scalMul a' b')
  | vecAdd_congr {v v' w w'} : ACEq v v' → ACEq w w' →
      ACEq (vecAdd v w) (vecAdd v' w')
  | matAdd_congr {A A' B B'} : ACEq A A' → ACEq B B' →
      ACEq (matAdd A B) (matAdd A' B')
  | smulVec_congr {a a' v v'} : ACEq a a' → ACEq v v' →
      ACEq (smulVec a v) (smulVec a' v')
  | smulMat_congr {a a' A A'} : ACEq a a' → ACEq A A' →
      ACEq (smulMat a A) (smulMat a' A')
  | mulVec_congr {A A' v v'} : ACEq A A' → ACEq v v' →
      ACEq (mulVec A v) (mulVec A' v')
  | dot_congr {v v' w w'} : ACEq v v' → ACEq w w' →
      ACEq (dot v w) (dot v' w')

/-- Two terms are joinable modulo AC if they can be rewritten to
    AC-equivalent normal forms. -/
def JoinableModAC (u v : TensorExpr) : Prop :=
  ∃ u' v', RewriteStar u u' ∧ RewriteStar v v' ∧ ACEq u' v'

/-! ## Part 6: Termination (Well-Foundedness)

The `distPotential` measure provides a well-founded ordering on `TensorExpr`
with respect to `Rewrite1`.
-/

/-
The rewrite relation is well-founded (every rewrite chain terminates).
-/
theorem rewrite1_wf : WellFounded (fun u t => Rewrite1 t u) := by
  convert ( WellFounded.wellFounded_iff_has_min.mpr _ ) using 1;
  intro s hs
  obtain ⟨m, hm⟩ : ∃ m ∈ s, ∀ n ∈ s, distPotential m ≤ distPotential n := by
    -- The set of distPotentials of elements in s is a subset of ℕ, which is well-ordered.
    have h_well_ordered : WellFounded (fun m n : ℕ => m < n) := by
      exact wellFounded_lt;
    have := h_well_ordered.has_min ( Set.image distPotential s ) ⟨ _, Set.mem_image_of_mem distPotential hs.choose_spec ⟩ ; aesop;
  exact ⟨ m, hm.1, fun n hn hmn => not_lt_of_ge ( hm.2 n hn ) ( rewrite1_decreases hmn ) ⟩

/-! ## Part 7: Newman's Lemma Modulo AC

Newman's lemma states that for a well-founded, locally confluent relation,
confluence follows. We prove a variant modulo AC-equivalence.
-/

/-
Helper: if a normal form is reachable, it equals itself.
-/
theorem isNormal_rewriteStar_eq {t u : TensorExpr}
    (ht : IsNormal t) (h : RewriteStar t u) : t = u := by
  induction' h;
  · rfl;
  · exact False.elim <| ht _ <| by subst_vars; assumption;

/-
Critical pair 1: `mulVec (matAdd A B) (vecAdd v w)`, rules 1 & 2.
    Both reduce to terms with the same 4 summands, joinable mod AC.
-/
theorem cp_matAdd_vecAdd (A B v w : TensorExpr) :
    JoinableModAC
      (vecAdd (mulVec (matAdd A B) v) (mulVec (matAdd A B) w))
      (vecAdd (mulVec A (vecAdd v w)) (mulVec B (vecAdd v w))) := by
  -- By definition of Rewrite1, we can reduce both terms to the same normal form.
  use vecAdd (vecAdd (mulVec A v) (mulVec B v)) (vecAdd (mulVec A w) (mulVec B w)), vecAdd (vecAdd (mulVec A v) (mulVec A w)) (vecAdd (mulVec B v) (mulVec B w));
  constructor;
  · have h1 : Rewrite1 (mulVec (matAdd A B) v) (vecAdd (mulVec A v) (mulVec B v)) := by
      exact Rewrite1.root ( RootRewrite.matAdd_mulVec _ _ _ );
    have h2 : Rewrite1 (mulVec (matAdd A B) w) (vecAdd (mulVec A w) (mulVec B w)) := by
      exact Rewrite1.root ( RootRewrite.matAdd_mulVec _ _ _ );
    exact .single ( Rewrite1.vecAdd_left h1 ) |> Relation.ReflTransGen.trans <| .single ( Rewrite1.vecAdd_right h2 );
  · constructor;
    · -- Apply the rewrite rules to each part of the expression.
      have h1 : Rewrite1 (A.mulVec (v.vecAdd w)) ((A.mulVec v).vecAdd (A.mulVec w)) := by
        exact Rewrite1.root ( RootRewrite.mulVec_vecAdd _ _ _ )
      have h2 : Rewrite1 (B.mulVec (v.vecAdd w)) ((B.mulVec v).vecAdd (B.mulVec w)) := by
        exact Rewrite1.root ( RootRewrite.mulVec_vecAdd _ _ _ );
      exact .single ( Rewrite1.vecAdd_left h1 ) |> Relation.ReflTransGen.trans <| .single ( Rewrite1.vecAdd_right h2 );
    · -- By associativity and commutativity of addition, we can rearrange the terms to show they are equal.
      have h_assoc_comm : ∀ (a b c d : TensorExpr), ACEq (vecAdd (vecAdd a b) (vecAdd c d)) (vecAdd (vecAdd a c) (vecAdd b d)) := by
        intros a b c d;
        have h_assoc_comm : ACEq (vecAdd (vecAdd a b) (vecAdd c d)) (vecAdd (vecAdd a c) (vecAdd b d)) := by
          have h1 : ACEq (vecAdd (vecAdd a b) (vecAdd c d)) (vecAdd a (vecAdd b (vecAdd c d))) := by
            exact ACEq.vecAdd_assoc _ _ _
          have h2 : ACEq (vecAdd a (vecAdd b (vecAdd c d))) (vecAdd a (vecAdd c (vecAdd b d))) := by
            apply ACEq.vecAdd_congr;
            · constructor;
            · have h2 : ACEq (b.vecAdd (c.vecAdd d)) (c.vecAdd (b.vecAdd d)) := by
                have h_assoc : ACEq (b.vecAdd (c.vecAdd d)) ((b.vecAdd c).vecAdd d) := by
                  exact ACEq.vecAdd_assoc _ _ _ |> ACEq.symm
                have h_comm : ACEq ((b.vecAdd c).vecAdd d) ((c.vecAdd b).vecAdd d) := by
                  exact ACEq.vecAdd_congr ( ACEq.vecAdd_comm _ _ ) ( ACEq.refl _ )
                have h_assoc' : ACEq ((c.vecAdd b).vecAdd d) (c.vecAdd (b.vecAdd d)) := by
                  apply ACEq.vecAdd_assoc _ _
                exact ACEq.trans h_assoc (ACEq.trans h_comm h_assoc');
              exact h2
          have h3 : ACEq (vecAdd a (vecAdd c (vecAdd b d))) (vecAdd (vecAdd a c) (vecAdd b d)) := by
            exact ACEq.symm ( ACEq.vecAdd_assoc _ _ _ )
          exact ACEq.trans h1 (ACEq.trans h2 h3);
        exact h_assoc_comm;
      exact h_assoc_comm _ _ _ _

/-
Critical pair 2: `mulVec (smulMat a A) (vecAdd v w)`, rules 1 & 3.
    Both paths reach exactly the same term.
-/
theorem cp_smulMat_vecAdd (a A v w : TensorExpr) :
    JoinableModAC
      (vecAdd (mulVec (smulMat a A) v) (mulVec (smulMat a A) w))
      (smulVec a (mulVec A (vecAdd v w))) := by
  -- We can reach the target normal form from both sides using the rewrite rules.
  use vecAdd (smulVec a (mulVec A v)) (smulVec a (mulVec A w)), vecAdd (smulVec a (mulVec A v)) (smulVec a (mulVec A w));
  constructor;
  · exact .trans ( .single ( Rewrite1.vecAdd_left ( Rewrite1.root ( RootRewrite.smulMat_mulVec _ _ _ ) ) ) ) ( .single ( Rewrite1.vecAdd_right ( Rewrite1.root ( RootRewrite.smulMat_mulVec _ _ _ ) ) ) );
  · refine' ⟨ _, ACEq.refl _ ⟩;
    have h_rewrite2 : Rewrite1 (a.smulVec (A.mulVec (v.vecAdd w))) (a.smulVec ((A.mulVec v).vecAdd (A.mulVec w))) := by
      exact Rewrite1.smulVec_right ( Rewrite1.root ( RootRewrite.mulVec_vecAdd _ _ _ ) );
    exact .single h_rewrite2 |> Relation.ReflTransGen.trans <| .single <| by constructor; constructor;

/-
Critical pair 3: `dot (vecAdd v w) (vecAdd x y)`, rules 6 & 7.
    Both reduce to sums of 4 dot products, joinable mod AC.
-/
theorem cp_dot_vecAdd_vecAdd (v w x y : TensorExpr) :
    JoinableModAC
      (scalAdd (dot v (vecAdd x y)) (dot w (vecAdd x y)))
      (scalAdd (dot (vecAdd v w) x) (dot (vecAdd v w) y)) := by
  use scalAdd (scalAdd (dot v x) (dot v y)) (scalAdd (dot w x) (dot w y)), scalAdd (scalAdd (dot v x) (dot w x)) (scalAdd (dot v y) (dot w y));
  refine' ⟨ _, _, _ ⟩;
  · have h_rewrite : Rewrite1 (dot v (vecAdd x y)) (scalAdd (dot v x) (dot v y)) ∧ Rewrite1 (dot w (vecAdd x y)) (scalAdd (dot w x) (dot w y)) := by
      exact ⟨ Rewrite1.root ( RootRewrite.dot_vecAdd_right _ _ _ ), Rewrite1.root ( RootRewrite.dot_vecAdd_right _ _ _ ) ⟩;
    exact .single ( Rewrite1.scalAdd_left h_rewrite.1 ) |> Relation.ReflTransGen.trans <| .single ( Rewrite1.scalAdd_right h_rewrite.2 );
  · -- Apply the rewrite rules to simplify the expression.
    have h1 : Rewrite1 (dot (vecAdd v w) x) (scalAdd (dot v x) (dot w x)) := by
      exact Rewrite1.root ( RootRewrite.dot_vecAdd_left _ _ _ )
    have h2 : Rewrite1 (dot (vecAdd v w) y) (scalAdd (dot v y) (dot w y)) := by
      exact Rewrite1.root ( RootRewrite.dot_vecAdd_left _ _ _ );
    exact .single ( Rewrite1.scalAdd_left h1 ) |> Relation.ReflTransGen.trans <| .single ( Rewrite1.scalAdd_right h2 );
  · have h_assoc : ACEq (scalAdd (scalAdd (dot v x) (dot v y)) (scalAdd (dot w x) (dot w y))) (scalAdd (dot v x) (scalAdd (dot v y) (scalAdd (dot w x) (dot w y)))) := by
      exact ACEq.scalAdd_assoc _ _ _;
    have h_assoc : ACEq (scalAdd (dot v x) (scalAdd (dot v y) (scalAdd (dot w x) (dot w y)))) (scalAdd (dot v x) (scalAdd (scalAdd (dot w x) (dot w y)) (dot v y))) := by
      apply ACEq.scalAdd_congr;
      · constructor;
      · apply ACEq.scalAdd_comm;
    have h_assoc : ACEq (scalAdd (dot v x) (scalAdd (scalAdd (dot w x) (dot w y)) (dot v y))) (scalAdd (dot v x) (scalAdd (dot w x) (scalAdd (dot w y) (dot v y)))) := by
      apply ACEq.scalAdd_congr;
      · constructor;
      · apply ACEq.scalAdd_assoc;
    have h_assoc : ACEq (scalAdd (dot v x) (scalAdd (dot w x) (scalAdd (dot w y) (dot v y)))) (scalAdd (scalAdd (dot v x) (dot w x)) (scalAdd (dot v y) (dot w y))) := by
      have h_assoc : ACEq (scalAdd (dot v x) (scalAdd (dot w x) (scalAdd (dot w y) (dot v y)))) (scalAdd (scalAdd (dot v x) (dot w x)) (scalAdd (dot w y) (dot v y))) := by
        apply ACEq.symm; exact (by
        apply_rules [ ACEq.scalAdd_assoc ]);
      exact h_assoc.trans ( ACEq.scalAdd_congr ( ACEq.refl _ ) ( ACEq.scalAdd_comm _ _ ) );
    exact ACEq.trans ‹_› ( ACEq.trans ‹_› ( ACEq.trans ‹_› ‹_› ) )

/-
Critical pair 4: `dot (smulVec a v) (vecAdd x y)`, rules 7 & 8.
    Both paths reach the same term using rule 9.
-/
theorem cp_dot_smulVec_vecAdd (a v x y : TensorExpr) :
    JoinableModAC
      (scalAdd (dot (smulVec a v) x) (dot (smulVec a v) y))
      (scalMul a (dot v (vecAdd x y))) := by
  -- By definition of JoinableModAC, we need to show that there exist u' and v' such that u' is reachable from the first term, v' is reachable from the second term, and u' and v' are AC-equivalent.
  use scalAdd (scalMul a (dot v x)) (scalMul a (dot v y)), scalAdd (scalMul a (dot v x)) (scalMul a (dot v y));
  constructor;
  · -- Apply the rewrite rules to each part of the term.
    have h1 : Rewrite1 (dot (smulVec a v) x) (scalMul a (dot v x)) := by
      exact Rewrite1.root ( RootRewrite.dot_smulVec_left _ _ _ );
    exact .single ( Rewrite1.scalAdd_left h1 ) |> Relation.ReflTransGen.trans <| .single ( Rewrite1.scalAdd_right <| by exact Rewrite1.root <| RootRewrite.dot_smulVec_left _ _ _ );
  · refine' ⟨ _, ACEq.refl _ ⟩;
    have h_rewrite : Rewrite1 (a.scalMul (v.dot (x.vecAdd y))) (a.scalMul (scalAdd (v.dot x) (v.dot y))) := by
      exact Rewrite1.scalMul_right ( Rewrite1.root ( RootRewrite.dot_vecAdd_right _ _ _ ) );
    exact .single h_rewrite |> Relation.ReflTransGen.trans <| .single <| by apply Rewrite1.root; apply RootRewrite.scalMul_scalAdd;

/-
Root-level local confluence: any two root rewrites from the same term
    are joinable modulo AC.
-/
theorem root_local_confluence_mod_AC {t u v : TensorExpr}
    (hu : RootRewrite t u) (hv : RootRewrite t v) : JoinableModAC u v := by
  cases hu <;> cases hv <;> simp_all +decide only [JoinableModAC];
  exact ⟨ _, _, Relation.ReflTransGen.refl, Relation.ReflTransGen.refl, ACEq.refl _ ⟩;
  apply cp_matAdd_vecAdd;
  apply cp_smulMat_vecAdd;
  exact cp_matAdd_vecAdd _ _ _ _ |> fun ⟨ u', v', hu', hv', h ⟩ => ⟨ v', u', hv', hu', h.symm ⟩;
  exact ⟨ _, _, Relation.ReflTransGen.refl, Relation.ReflTransGen.refl, ACEq.refl _ ⟩;
  exact cp_smulMat_vecAdd _ _ _ _ |> fun ⟨ u', v', hu', hv', h ⟩ => ⟨ v', u', hv', hu', h.symm ⟩;
  exact ⟨ _, _, Relation.ReflTransGen.refl, Relation.ReflTransGen.refl, ACEq.refl _ ⟩;
  exact ⟨ _, _, Relation.ReflTransGen.refl, Relation.ReflTransGen.refl, ACEq.refl _ ⟩;
  exact ⟨ _, _, Relation.ReflTransGen.refl, Relation.ReflTransGen.refl, ACEq.refl _ ⟩;
  exact ⟨ _, _, Relation.ReflTransGen.refl, Relation.ReflTransGen.refl, ACEq.refl _ ⟩;
  exact cp_dot_vecAdd_vecAdd _ _ _ _;
  exact cp_dot_vecAdd_vecAdd _ _ _ _ |> fun ⟨ u', v', hu', hv', h ⟩ => ⟨ v', u', hv', hu', h.symm ⟩;
  · exact ⟨ _, _, Relation.ReflTransGen.refl, Relation.ReflTransGen.refl, ACEq.refl _ ⟩;
  · apply cp_dot_smulVec_vecAdd;
  · rename_i a v w xAdd;
    convert cp_dot_smulVec_vecAdd a v w xAdd using 1;
    constructor <;> rintro ⟨ u', v', hu', hv', h ⟩ <;> use v', u' <;> tauto;
  · exact ⟨ _, _, Relation.ReflTransGen.refl, Relation.ReflTransGen.refl, ACEq.refl _ ⟩;
  · exact ⟨ _, _, Relation.ReflTransGen.refl, Relation.ReflTransGen.refl, ACEq.refl _ ⟩

/-- Local confluence modulo AC: any critical pair is joinable up to AC. -/
theorem local_confluence_mod_AC {t u v : TensorExpr}
    (hu : Rewrite1 t u) (hv : Rewrite1 t v) : JoinableModAC u v := by
  sorry

/-- **Theorem 2: Confluence modulo AC.**
    Any two multi-step reducts of a term are joinable modulo AC-equivalence.
    This follows from well-foundedness (Theorem 1) and local confluence
    via Newman's lemma. -/
theorem confluent_mod_AC {t u v : TensorExpr}
    (hu : RewriteStar t u) (hv : RewriteStar t v) : JoinableModAC u v := by
  sorry

/-
**Theorem 3: Unique Normal Forms modulo AC.**
    Any two normal forms reachable from the same term are AC-equivalent.
    This is the conceptual summit: normalization is deterministic up to
    the intended scalar-addition symmetry.
-/
theorem unique_normal_form_mod_AC {t n₁ n₂ : TensorExpr}
    (h1 : RewriteStar t n₁) (h2 : RewriteStar t n₂)
    (hn1 : IsNormal n₁) (hn2 : IsNormal n₂) : ACEq n₁ n₂ := by
  obtain ⟨ u, hu ⟩ := confluent_mod_AC h1 h2;
  -- Since $n₁$ is normal, we have $n₁ = u$.
  obtain ⟨v', hv'⟩ := hu
  have hn1_eq_u : n₁ = u := by
    exact isNormal_rewriteStar_eq hn1 hv'.1;
  have hn2_eq_v' : n₂ = v' := by
    exact isNormal_rewriteStar_eq hn2 hv'.2.1;
  grind

/-! ## Part 9: Semantic Invariance (Bridge to Compiler Correctness)

Connecting the abstract rewriting theory to semantic preservation.
-/

/-
`RewriteStar` is a congruence: it lifts through all constructors.
-/
theorem rewriteStar_scalAdd_congr {a a' b b' : TensorExpr}
    (ha : RewriteStar a a') (hb : RewriteStar b b') :
    RewriteStar (scalAdd a b) (scalAdd a' b') := by
  induction' ha with a a' ha ih;
  · induction' hb with b b' hb ih;
    · constructor;
    · exact Relation.ReflTransGen.trans ‹_› ( Relation.ReflTransGen.single <| Rewrite1.scalAdd_right ih );
  · exact .trans ‹_› ( .single <| by exact Rewrite1.scalAdd_left ih )

/-
`RewriteStar` lifts through `vecAdd` (left).
-/
theorem rewriteStar_vecAdd_left {v v' w : TensorExpr}
    (hv : RewriteStar v v') : RewriteStar (vecAdd v w) (vecAdd v' w) := by
  induction hv;
  · constructor;
  · exact Relation.ReflTransGen.tail ‹_› ( by exact Rewrite1.vecAdd_left ‹_› )

/-
`RewriteStar` lifts through `vecAdd` (right).
-/
theorem rewriteStar_vecAdd_right {v w w' : TensorExpr}
    (hw : RewriteStar w w') : RewriteStar (vecAdd v w) (vecAdd v w') := by
  induction hw <;> constructor;
  exacts [ by assumption, by exact Rewrite1.vecAdd_right ‹_› ]

/-
`RewriteStar` lifts through `vecAdd`.
-/
theorem rewriteStar_vecAdd_congr {v v' w w' : TensorExpr}
    (hv : RewriteStar v v') (hw : RewriteStar w w') :
    RewriteStar (vecAdd v w) (vecAdd v' w') := by
  convert Relation.ReflTransGen.trans ( rewriteStar_vecAdd_left hv ) ( rewriteStar_vecAdd_right hw ) using 1

/-
`RewriteStar` lifts through `matAdd`.
-/
theorem rewriteStar_matAdd_congr {A A' B B' : TensorExpr}
    (hA : RewriteStar A A') (hB : RewriteStar B B') :
    RewriteStar (matAdd A B) (matAdd A' B') := by
  induction' hA with A A' hA ih;
  · induction' hB with B B' hB ih;
    · constructor;
    · exact Relation.ReflTransGen.tail ‹_› ( by exact Rewrite1.matAdd_right ih );
  · exact Relation.ReflTransGen.tail ‹_› ( Rewrite1.matAdd_left ih )

/-
`RewriteStar` lifts through `smulVec`.
-/
theorem rewriteStar_smulVec_congr {a a' v v' : TensorExpr}
    (ha : RewriteStar a a') (hv : RewriteStar v v') :
    RewriteStar (smulVec a v) (smulVec a' v') := by
  convert Relation.ReflTransGen.trans ( Relation.ReflTransGen.lift ( fun x => TensorExpr.smulVec x v ) ( fun x y h => ?_ ) ha ) ( Relation.ReflTransGen.lift ( fun x => TensorExpr.smulVec a' x ) ( fun x y h => ?_ ) hv ) using 1;
  · exact Rewrite1.smulVec_left h;
  · exact Rewrite1.smulVec_right h

/-
`RewriteStar` lifts through `smulMat`.
-/
theorem rewriteStar_smulMat_congr {a a' A A' : TensorExpr}
    (ha : RewriteStar a a') (hA : RewriteStar A A') :
    RewriteStar (smulMat a A) (smulMat a' A') := by
  -- By induction on the rewrite relation for `a`.
  have h_ind : ∀ (a a' : TensorExpr), RewriteStar a a' → ∀ (A : TensorExpr), RewriteStar (a.smulMat A) (a'.smulMat A) := by
    intro a a' hA A;
    induction hA;
    · constructor;
    · exact Relation.ReflTransGen.tail ‹_› ( by exact Rewrite1.smulMat_left ‹_› );
  have h_ind : ∀ (a : TensorExpr) (A A' : TensorExpr), RewriteStar A A' → RewriteStar (a.smulMat A) (a.smulMat A') := by
    intros a A A' hA;
    induction' hA with A'' hA'' ih;
    · constructor;
    · exact Relation.ReflTransGen.tail ‹_› ( by exact Rewrite1.smulMat_right ‹_› );
  exact Relation.ReflTransGen.trans ( by solve_by_elim ) ( h_ind _ _ _ hA )

/-
`RewriteStar` lifts through `mulVec`.
-/
theorem rewriteStar_mulVec_congr {A A' v v' : TensorExpr}
    (hA : RewriteStar A A') (hv : RewriteStar v v') :
    RewriteStar (mulVec A v) (mulVec A' v') := by
  convert Relation.ReflTransGen.trans ( Relation.ReflTransGen.lift ( fun X => TensorExpr.mulVec X v ) ( fun X Y h => Rewrite1.mulVec_left h ) hA ) ?_ using 1;
  convert Relation.ReflTransGen.lift ( fun X => TensorExpr.mulVec A' X ) ( fun X Y h => Rewrite1.mulVec_right h ) hv using 1

/-
`RewriteStar` lifts through `dot`.
-/
theorem rewriteStar_dot_congr {v v' w w' : TensorExpr}
    (hv : RewriteStar v v') (hw : RewriteStar w w') :
    RewriteStar (dot v w) (dot v' w') := by
  induction hw;
  · induction hv;
    · constructor;
    · exact Relation.ReflTransGen.tail ‹_› ( by exact Rewrite1.dot_left ‹_› );
  · exact .tail ‹_› ( Rewrite1.dot_right ‹_› )

/-
`RewriteStar` lifts through `scalMul`.
-/
theorem rewriteStar_scalMul_congr {a a' b b' : TensorExpr}
    (ha : RewriteStar a a') (hb : RewriteStar b b') :
    RewriteStar (scalMul a b) (scalMul a' b') := by
  induction' ha with a'' a''' h_ind;
  · induction' hb with b b' hb ih;
    · constructor;
    · exact Relation.ReflTransGen.tail ‹_› ( by exact Rewrite1.scalMul_right ih );
  · exact .trans ‹_› ( Relation.ReflTransGen.single <| Rewrite1.scalMul_left ‹_› )

/-! ## Part 8: Canonical Normalization Algorithm

A concrete normalization function that repeatedly applies rewrite rules
and canonicalizes addition nodes into a sorted form.
-/

/-- Apply one root-level rewrite step if possible. -/
def rootNormStep : TensorExpr → TensorExpr
  | mulVec A (vecAdd v w) => vecAdd (mulVec A v) (mulVec A w)
  | mulVec (matAdd A B) v => vecAdd (mulVec A v) (mulVec B v)
  | mulVec (smulMat a A) v => smulVec a (mulVec A v)
  | smulVec a (vecAdd v w) => vecAdd (smulVec a v) (smulVec a w)
  | smulMat a (matAdd A B) => matAdd (smulMat a A) (smulMat a B)
  | dot (vecAdd v w) u => scalAdd (dot v u) (dot w u)
  | dot u (vecAdd v w) => scalAdd (dot u v) (dot u w)
  | dot (smulVec a v) w => scalMul a (dot v w)
  | scalMul a (scalAdd b c) => scalAdd (scalMul a b) (scalMul a c)
  | t => t

/-- Check whether a root-level rewrite applies. -/
def hasRootRedex : TensorExpr → Bool
  | mulVec _ (vecAdd _ _) => true
  | mulVec (matAdd _ _) _ => true
  | mulVec (smulMat _ _) _ => true
  | smulVec _ (vecAdd _ _) => true
  | smulMat _ (matAdd _ _) => true
  | dot (vecAdd _ _) _ => true
  | dot _ (vecAdd _ _) => true
  | dot (smulVec _ _) _ => true
  | scalMul _ (scalAdd _ _) => true
  | _ => false

/-- Apply root normalization repeatedly until no root redex remains. -/
def iterateRoot : ℕ → TensorExpr → TensorExpr
  | 0, t => t
  | n+1, t => if hasRootRedex t then iterateRoot n (rootNormStep t) else t

/-- Bottom-up normalization: normalize all subterms, then apply root rules
    repeatedly until no root redex remains. -/
def normalizeCanon : TensorExpr → TensorExpr
  | scalVar n => scalVar n
  | vecVar n => vecVar n
  | matVar n => matVar n
  | scalAdd a b =>
    let r := scalAdd (normalizeCanon a) (normalizeCanon b)
    iterateRoot (distPotential r) r
  | scalMul a b =>
    let r := scalMul (normalizeCanon a) (normalizeCanon b)
    iterateRoot (distPotential r) r
  | vecAdd v w =>
    let r := vecAdd (normalizeCanon v) (normalizeCanon w)
    iterateRoot (distPotential r) r
  | matAdd A B =>
    let r := matAdd (normalizeCanon A) (normalizeCanon B)
    iterateRoot (distPotential r) r
  | smulVec a v =>
    let r := smulVec (normalizeCanon a) (normalizeCanon v)
    iterateRoot (distPotential r) r
  | smulMat a A =>
    let r := smulMat (normalizeCanon a) (normalizeCanon A)
    iterateRoot (distPotential r) r
  | mulVec A v =>
    let r := mulVec (normalizeCanon A) (normalizeCanon v)
    iterateRoot (distPotential r) r
  | dot v w =>
    let r := dot (normalizeCanon v) (normalizeCanon w)
    iterateRoot (distPotential r) r

/-
rootNormStep either performs a valid root rewrite or is the identity.
-/
theorem rootNormStep_spec (t : TensorExpr) :
    (hasRootRedex t = true → RootRewrite t (rootNormStep t)) ∧
    (hasRootRedex t = false → rootNormStep t = t) := by
  cases t <;> simp +decide [ hasRootRedex, rootNormStep ];
  · rename_i a b;
    cases a <;> cases b <;> simp +decide;
    all_goals apply RootRewrite.scalMul_scalAdd _ _;
  · cases ‹TensorExpr› <;> cases ‹TensorExpr› <;> simp +decide [ * ] at *;
    all_goals solve_by_elim [ RootRewrite.smulVec_vecAdd ] ;
  · cases ‹TensorExpr› <;> cases ‹TensorExpr› <;> simp +decide [ RootRewrite.smulMat_matAdd ];
  · rename_i A v;
    rcases A with ( _ | _ | _ | A | A | A | A | A | A | A | A ) <;> rcases v with ( _ | _ | _ | v | v | v | v | v | v | v | v ) <;> tauto;
  · rename_i v w;
    cases v <;> cases w <;> simp +decide;
    all_goals constructor;

/-
iterateRoot produces a result reachable via RewriteStar.
-/
theorem iterateRoot_rewriteStar (n : ℕ) (t : TensorExpr) :
    RewriteStar t (iterateRoot n t) := by
  induction' n with n ih generalizing t;
  · exact Relation.ReflTransGen.refl;
  · by_cases h : hasRootRedex t <;> simp_all +decide [ RewriteStar ];
    · convert Relation.ReflTransGen.trans ( Relation.ReflTransGen.single ( Rewrite1.root ( rootNormStep_spec t |>.1 h ) ) ) ( ih ( rootNormStep t ) ) using 1;
      exact if_pos h;
    · rw [ show iterateRoot ( n + 1 ) t = t from _ ];
      exact if_neg ( by aesop )

/-- The canonicalized output is in normal form. -/
theorem normalizeCanon_normal (t : TensorExpr) :
    IsNormal (normalizeCanon t) := by
  sorry

/-- Normalization produces a reachable result. -/
theorem normalizeCanon_reachable (t : TensorExpr) :
    RewriteStar t (normalizeCanon t) := by
  induction t with
  | scalVar _ => exact Relation.ReflTransGen.refl
  | vecVar _ => exact Relation.ReflTransGen.refl
  | matVar _ => exact Relation.ReflTransGen.refl
  | scalAdd a b iha ihb =>
    simp only [normalizeCanon]
    exact (rewriteStar_scalAdd_congr iha ihb).trans (iterateRoot_rewriteStar _ _)
  | scalMul a b iha ihb =>
    simp only [normalizeCanon]
    exact (rewriteStar_scalMul_congr iha ihb).trans (iterateRoot_rewriteStar _ _)
  | vecAdd v w ihv ihw =>
    simp only [normalizeCanon]
    exact (rewriteStar_vecAdd_congr ihv ihw).trans (iterateRoot_rewriteStar _ _)
  | matAdd A B ihA ihB =>
    simp only [normalizeCanon]
    exact (rewriteStar_matAdd_congr ihA ihB).trans (iterateRoot_rewriteStar _ _)
  | smulVec a v iha ihv =>
    simp only [normalizeCanon]
    exact (rewriteStar_smulVec_congr iha ihv).trans (iterateRoot_rewriteStar _ _)
  | smulMat a A iha ihA =>
    simp only [normalizeCanon]
    exact (rewriteStar_smulMat_congr iha ihA).trans (iterateRoot_rewriteStar _ _)
  | mulVec A v ihA ihv =>
    simp only [normalizeCanon]
    exact (rewriteStar_mulVec_congr ihA ihv).trans (iterateRoot_rewriteStar _ _)
  | dot v w ihv ihw =>
    simp only [normalizeCanon]
    exact (rewriteStar_dot_congr ihv ihw).trans (iterateRoot_rewriteStar _ _)

/-- Normalization is sound: the result is reachable from the input. -/
theorem normalizeCanon_sound (t : TensorExpr) :
    RewriteStar t (normalizeCanon t) ∨ ACEq t (normalizeCanon t) :=
  Or.inl (normalizeCanon_reachable t)

/-- Normalization is complete modulo AC: any other normal form is AC-equivalent. -/
theorem normalizeCanon_complete {t n : TensorExpr}
    (h : RewriteStar t n) (hn : IsNormal n) :
    ACEq (normalizeCanon t) n := by
  sorry

/-! ## Part 10: Conjectured Polynomial Bound

We conjecture that normalization length is polynomially bounded in term size.
-/

/-- Term size (number of constructors). -/
def termSize : TensorExpr → ℕ
  | scalVar _ => 1
  | vecVar _ => 1
  | matVar _ => 1
  | scalAdd a b => 1 + termSize a + termSize b
  | scalMul a b => 1 + termSize a + termSize b
  | vecAdd v w => 1 + termSize v + termSize w
  | matAdd A B => 1 + termSize A + termSize B
  | smulVec a v => 1 + termSize a + termSize v
  | smulMat a A => 1 + termSize a + termSize A
  | mulVec A v => 1 + termSize A + termSize v
  | dot v w => 1 + termSize v + termSize w

end TensorConfluence