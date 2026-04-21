/-! # CatalogBuild.EML.Complexity

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 19
-/

import Mathlib

noncomputable section

/-- An EML computation tree. -/
inductive EMLCTree where
  | const : ℝ → EMLCTree
  | input : ℕ → EMLCTree
  | eml : EMLCTree → EMLCTree → EMLCTree




/-- The number of leaves. -/
def EMLCTree.leaves : EMLCTree → ℕ
  | .const _ => 1
  | .input _ => 1
  | .eml l r => l.leaves + r.leaves




/-- The number of EML (internal) nodes. -/
def EMLCTree.emlNodes : EMLCTree → ℕ
  | .const _ => 0
  | .input _ => 0
  | .eml l r => 1 + l.emlNodes + r.emlNodes




/-- Total tree size. -/
def EMLCTree.size : EMLCTree → ℕ
  | .const _ => 1
  | .input _ => 1
  | .eml l r => 1 + l.size + r.size




/-- Depth of an EML tree. -/
def EMLCTree.depth : EMLCTree → ℕ
  | .const _ => 0
  | .input _ => 0
  | .eml l r => 1 + max l.depth r.depth




/-- Size = leaves + emlNodes. -/
theorem EMLCTree.size_eq (t : EMLCTree) : t.size = t.leaves + t.emlNodes := by
  induction t with
  | const _ => simp [size, leaves, emlNodes]
  | input _ => simp [size, leaves, emlNodes]
  | eml l r ihl ihr => simp [size, leaves, emlNodes, ihl, ihr]; omega




/-- Leaves = emlNodes + 1 (binary tree property). -/
theorem EMLCTree.leaves_eq_emlNodes_succ (t : EMLCTree) :
    t.leaves = t.emlNodes + 1 := by
  induction t with
  | const _ => simp [leaves, emlNodes]
  | input _ => simp [leaves, emlNodes]
  | eml l r ihl ihr => simp [leaves, emlNodes, ihl, ihr]; omega




/-- Any EML tree has at least 1 leaf. -/
theorem EMLCTree.leaves_pos (t : EMLCTree) : 0 < t.leaves := by
  have := t.leaves_eq_emlNodes_succ; omega




/-- Size = 2 * emlNodes + 1. -/
theorem EMLCTree.size_from_nodes (t : EMLCTree) :
    t.size = 2 * t.emlNodes + 1 := by
  have h1 := t.size_eq
  have h2 := t.leaves_eq_emlNodes_succ
  omega




/-- Leaves ≤ 2^depth. -/
theorem EMLCTree.leaves_le_two_pow_depth (t : EMLCTree) :
    t.leaves ≤ 2 ^ t.depth := by
  induction t with
  | const _ => simp [leaves, depth]
  | input _ => simp [leaves, depth]
  | eml l r ihl ihr =>
    simp only [leaves, depth]
    calc l.leaves + r.leaves
        ≤ 2 ^ l.depth + 2 ^ r.depth := Nat.add_le_add ihl ihr
      _ ≤ 2 ^ max l.depth r.depth + 2 ^ max l.depth r.depth := by
          apply Nat.add_le_add
          · exact Nat.pow_le_pow_right (by omega) (Nat.le_max_left _ _)
          · exact Nat.pow_le_pow_right (by omega) (Nat.le_max_right _ _)
      _ = 2 ^ (1 + max l.depth r.depth) := by ring




/-- emlNodes ≤ 2^depth - 1. -/
theorem EMLCTree.emlNodes_le (t : EMLCTree) :
    t.emlNodes + 1 ≤ 2 ^ t.depth := by
  have := t.leaves_le_two_pow_depth
  have := t.leaves_eq_emlNodes_succ
  omega




/-- Known instruction counts for elementary operations (as a lookup table).
Each entry is (operation_name_index, EML_count, PUSH_count, total). -/
structure InstrCount where
  emlOps : ℕ
  pushOps : ℕ
  total : ℕ
  h_total : total = emlOps + pushOps




/-- [Section: # CatalogBuild.EML.Complexity
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 19] -/
def expCount : InstrCount := ⟨1, 2, 3, rfl⟩



/-- [Section: # CatalogBuild.EML.Complexity
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 19] -/
def lnCount : InstrCount := ⟨3, 4, 7, rfl⟩



def subCount : InstrCount := ⟨5, 6, 11, rfl⟩



def addCount : InstrCount := ⟨5, 6, 11, rfl⟩




/-- For any valid program producing one result, PUSH count = EML count + 1. -/
theorem push_eq_eml_plus_one (c : InstrCount)
    (h : c.pushOps = c.emlOps + 1) : c.total = 2 * c.emlOps + 1 := by
  have := c.h_total; omega




/-- exp satisfies the PUSH = EML + 1 relation. -/
theorem exp_push_eml_relation : expCount.pushOps = expCount.emlOps + 1 := rfl




/-- ln satisfies the PUSH = EML + 1 relation. -/
theorem ln_push_eml_relation : lnCount.pushOps = lnCount.emlOps + 1 := rfl




end
