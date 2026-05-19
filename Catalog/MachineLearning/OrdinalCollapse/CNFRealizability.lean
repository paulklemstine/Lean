import Mathlib

/-!
# Cantor Normal Form Realizability and ω^ω Realization

This module extends the ordinal collapse theory to prove that `InfBranchTree`
provides a **complete constructive semantics for all ordinals below ω^ω** via
Cantor normal form, and constructs a tree realizing `ω^ω` itself.

## Main Definitions

* `InfBranchTree.prepend` — Tree composition yielding ordinal addition on ranks.
* `InfBranchTree.mulByNat` — Tree repetition yielding ordinal multiplication by ℕ.
* `InfBranchTree.omegaPowTree` — Canonical tree of rank `ω^n`.
* `InfBranchTree.cnfTree` — Tree built from a CNF coefficient/exponent list.
* `InfBranchTree.omegaToOmegaTree` — Canonical tree of rank `ω^ω`.

## Main Results

### Cluster E: Tree Algebra Operations
* `rank_prepend` — `rank (prepend s t) = rank s + rank t`
* `rank_mulByNat` — `rank (mulByNat t k) = rank t * k`

### Cluster F: Ordinal Power Realization
* `rank_omegaPowTree` — `rank (omegaPowTree n) = ω^n`

### Cluster G: Cantor Normal Form Realizability
* `rank_cnfTree` — CNF lists are exactly realized by `cnfTree`.

### Cluster H: ω^ω Realization
* `rank_omegaToOmegaTree` — `rank omegaToOmegaTree = ω^ω`
-/

noncomputable section

open Ordinal

/-! ## InfBranchTree (reproduced from Basic) -/

/-- A well-founded tree with countably infinite branching at each internal node. -/
inductive InfBranchTree where
  | leaf : InfBranchTree
  | node : (ℕ → InfBranchTree) → InfBranchTree

namespace InfBranchTree

/-- The ordinal rank (depth) of an infinitely branching tree. -/
def rank : InfBranchTree → Ordinal
  | .leaf => 0
  | .node children => ⨆ i : ℕ, Order.succ (rank (children i))

/-! ## Cluster E: Tree Algebra Operations -/

/-- `prepend s t` inserts `s` at every leaf of `t`.
When `t = leaf`, the result is `s`. When `t = node f`, each child is recursively prepended.
This yields ordinal addition: `rank (prepend s t) = rank s + rank t`. -/
def prepend : InfBranchTree → InfBranchTree → InfBranchTree
  | s, .leaf => s
  | s, .node f => .node (fun i => prepend s (f i))

private theorem succ_add_eq_add_succ (a b : Ordinal) :
    Order.succ (a + b) = a + Order.succ b := by
      rw [ Order.succ_eq_add_one, Order.succ_eq_add_one, add_assoc ]

private theorem add_iSup_eq (a : Ordinal) (f : ℕ → Ordinal) :
    a + ⨆ i, f i = ⨆ i, (a + f i) := by
      convert Ordinal.IsNormal.map_iSup ( isNormal_add_right a ) ?_ using 1;
      · infer_instance;
      · exact ⟨ 0 ⟩

/-- **Rank Addition Theorem**: Prepending realizes ordinal addition on ranks.
The key identity is `rank (prepend s t) = rank s + rank t`. -/
theorem rank_prepend (s t : InfBranchTree) :
    rank (prepend s t) = rank s + rank t := by
  induction t with
  | leaf => simp [prepend, rank, add_zero]
  | node f ih =>
    simp only [prepend, rank]
    conv_lhs => arg 1; ext i; rw [ih i]
    simp_rw [succ_add_eq_add_succ]
    rw [add_iSup_eq]

/-- `mulByNat t k` builds a tree of rank `rank t * k` by iterating prepend. -/
def mulByNat : InfBranchTree → ℕ → InfBranchTree
  | _, 0 => .leaf
  | t, k + 1 => prepend t (mulByNat t k)

/-
**Rank Multiplication Theorem**: `mulByNat` realizes ordinal multiplication by ℕ.
-/
theorem rank_mulByNat (t : InfBranchTree) (k : ℕ) :
    rank (mulByNat t k) = rank t * (k : Ordinal) := by
      induction' k with k ih;
      · aesop;
      · convert rank_prepend t ( t.mulByNat k ) using 1;
        rw [ ih, Nat.cast_succ, mul_add, mul_one ];
        induction' k with k ih;
        · norm_num;
        · induction' k + 1 with k ih <;> simp_all +decide [ Nat.cast_succ, mul_add, add_assoc ];
          rw [ Ordinal.mul_succ, add_assoc, ih, ← add_assoc ];
          rw [ ih, add_assoc ];
          rw [ ih ]

/-! ## Cluster F: Ordinal Power Realization -/

/-- `omegaPowTree n` is the canonical tree of rank `ω^n`.
- `omegaPowTree 0 = node (fun _ => leaf)` has rank 1 = ω^0.
- `omegaPowTree (n+1) = node (fun k => mulByNat (omegaPowTree n) k)` has rank ω^(n+1)
  since `⨆ k, succ(ω^n * k) = ω^n * ω = ω^(n+1)`. -/
def omegaPowTree : ℕ → InfBranchTree
  | 0 => .node (fun _ => .leaf)
  | n + 1 => .node (fun k => mulByNat (omegaPowTree n) k)

/-
**Ordinal Power Realization**: `omegaPowTree n` has rank exactly `ω^n`.
-/
theorem rank_omegaPowTree (n : ℕ) :
    rank (omegaPowTree n) = omega0 ^ (n : Ordinal) := by
      induction n <;> simp_all +decide [ pow_succ, omegaPowTree ];
      · simp +decide [ InfBranchTree.rank ];
      · rw [ show ( node fun k => ( omegaPowTree _ ).mulByNat k ).rank = ⨆ k : ℕ, Order.succ ( ( omegaPowTree _ ).mulByNat k ).rank from rfl ];
        simp_all +decide [ rank_mulByNat ];
        rw [ @ciSup_eq_of_forall_le_of_forall_lt_exists_gt ];
        · simp +decide [ mul_add ];
        · intro w hw;
          contrapose! hw;
          rw [ Ordinal.mul_le_iff_of_isSuccLimit ];
          · intro b' hb';
            rcases Ordinal.lt_omega0.1 hb' with ⟨ k, rfl ⟩;
            exact le_trans ( Order.le_succ _ ) ( hw k );
          · exact Ordinal.isSuccLimit_omega0

/-! ## Cluster G: Cantor Normal Form Realizability -/

/-- A CNF term is a pair `(coefficient, exponent)`. -/
def CNFTerm := ℕ × ℕ

/-- Evaluate a CNF list to its ordinal value.
Each term `(a, n)` contributes `ω^n * a` (the standard CNF convention). -/
def cnfValue : List CNFTerm → Ordinal
  | [] => 0
  | (a, n) :: rest => omega0 ^ (n : Ordinal) * (a : Ordinal) + cnfValue rest

/-- Build a tree realizing a CNF list.
Uses `prepend` to compose terms and `mulByNat`/`omegaPowTree` for individual terms. -/
def cnfTree : List CNFTerm → InfBranchTree
  | [] => .leaf
  | (a, n) :: rest => prepend (mulByNat (omegaPowTree n) a) (cnfTree rest)

/-- Strictly descending exponent order for CNF lists. -/
def StrictDescendingExponents : List CNFTerm → Prop
  | [] => True
  | [_] => True
  | (_, n₁) :: (a₂, n₂) :: rest => n₁ > n₂ ∧ StrictDescendingExponents ((a₂, n₂) :: rest)

/-- All coefficients in a CNF list are positive. -/
def PositiveCoeffs : List CNFTerm → Prop :=
  List.Forall fun t => 0 < t.1

/-
**CNF Realizability Theorem**: The rank of `cnfTree L` equals the
CNF ordinal value `cnfValue L`. This holds for all lists, not just valid CNFs.
-/
theorem rank_cnfTree (L : List CNFTerm) :
    rank (cnfTree L) = cnfValue L := by
      induction' L with L_head L_tail L_ih;
      · rfl;
      · convert rank_prepend ( mulByNat ( omegaPowTree L_head.2 ) L_head.1 ) ( cnfTree L_tail ) using 1;
        rw [ L_ih, rank_mulByNat, rank_omegaPowTree ];
        rfl

/-! ## Cluster H: ω^ω Realization -/

/-- `omegaToOmegaTree` is the canonical tree of rank `ω^ω`.
Its n-th child is `omegaPowTree n`, the tree of rank `ω^n`. -/
def omegaToOmegaTree : InfBranchTree :=
  .node (fun n => omegaPowTree n)

/-
Auxiliary: `⨆ n : ℕ, ω^n = ω^ω`
-/
theorem iSup_omega0_pow_nat :
    ⨆ n : ℕ, omega0 ^ (n : Ordinal) = omega0 ^ omega0 := by
      convert ( Ordinal.IsNormal.map_iSup _ _ );
      convert rfl;
      rotate_left;
      convert ( Ordinal.IsNormal.map_iSup _ _ );
      convert rfl;
      convert Ordinal.iSup_natCast;
      all_goals try infer_instance;
      · exact Ordinal.isNormal_opow one_lt_omega0;
      · exact Ordinal.isNormal_opow ( by simp +decide );
      · convert ( Ordinal.IsNormal.map_iSup _ _ );
        · exact Ordinal.isNormal_opow one_lt_omega0;
        · infer_instance;
        · exact ⟨ 0 ⟩

/-
**ω^ω Realization Theorem**: `omegaToOmegaTree` has rank exactly `ω^ω`.
This is the first true limit-stage synthesis theorem: the tree formalism
can encode transfinite convergence of structural complexity.
-/
theorem rank_omegaToOmegaTree :
    rank omegaToOmegaTree = omega0 ^ omega0 := by
      convert iSup_omega0_pow_nat using 1;
      refine' le_antisymm _ _;
      · refine' Ordinal.iSup_le _;
        intro n; rw [ rank_omegaPowTree ] ; exact le_trans ( by aesop ) ( le_ciSup ( Ordinal.bddAbove_of_small _ ) ( n + 1 ) ) ;
      · refine' ciSup_le fun n => _;
        refine' le_trans _ ( le_ciSup _ n );
        · rw [ rank_omegaPowTree ];
          exact le_of_lt ( Order.lt_succ _ );
        · refine' ⟨ omega0 ^ omega0 + 1, Set.forall_mem_range.2 fun i => _ ⟩;
          refine' le_trans ( Order.succ_le_of_lt _ ) ( le_add_of_nonneg_right zero_le_one );
          rw [ rank_omegaPowTree ];
          exact_mod_cast Ordinal.opow_lt_opow_iff_right ( by norm_num ) |>.2 ( Ordinal.nat_lt_omega0 i )

/-! ## Corollaries -/

/-- Every ordinal expressible in CNF is realized by a tree. -/
theorem exists_tree_of_cnfValue (L : List CNFTerm) :
    ∃ t : InfBranchTree, rank t = cnfValue L :=
  ⟨cnfTree L, rank_cnfTree L⟩

/-- `ω^ω` is realized by a tree. -/
theorem exists_tree_of_omega_pow_omega :
    ∃ t : InfBranchTree, rank t = omega0 ^ omega0 :=
  ⟨omegaToOmegaTree, rank_omegaToOmegaTree⟩

end InfBranchTree

end