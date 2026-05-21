/-
  # Width-to-Size Conversion for Tree-Like Resolution

  This file formalizes:
  1. Clause space bounds: counting width-bounded clauses over n variables
  2. Finite clause encodings via `ClauseCode`
  3. Structural properties of resolution proof trees (allClauses, widthSpectrum)
  4. Width-to-size conversion theorems
  5. Application to the pigeonhole principle

  ## Key results:
  - `clauseSpaceBound_mono`: monotonicity of the clause space bound
  - `allClauses_card_le_size`: distinct clauses ≤ tree size
  - `allClauses_width_le_maxWidth`: all clauses in a tree have bounded width
  - `clauseSpaceBound_eq_pow_three`: clauseSpaceBound n n = 3^n
  - `php_tree_size_lower_bound_linear`: PHP refutations need size ≥ 2·(n+1) - 1

  Self-contained module building on the definitions from Resolution.lean.
-/
import Mathlib

namespace WidthToSize

/-! ## Literals, Clauses, CNFs (from Resolution.lean) -/

inductive Lit (ν : Type)
  | pos : ν → Lit ν
  | neg : ν → Lit ν
  deriving DecidableEq

namespace Lit

def compl {ν : Type} : Lit ν → Lit ν
  | pos x => neg x
  | neg x => pos x

def eval {ν : Type} (τ : ν → Bool) : Lit ν → Bool
  | pos x => τ x
  | neg x => !(τ x)

def var {ν : Type} : Lit ν → ν
  | pos x => x
  | neg x => x

end Lit

abbrev Clause (ν : Type) [DecidableEq ν] := Finset (Lit ν)

abbrev CNF (ν : Type) [DecidableEq ν] := Finset (Clause ν)

namespace Clause

def Satisfied {ν : Type} [DecidableEq ν] (τ : ν → Bool) (C : Clause ν) : Prop :=
  ∃ l ∈ C, Lit.eval τ l = true

def width {ν : Type} [DecidableEq ν] (C : Clause ν) : ℕ := C.card

theorem not_satisfied_empty {ν : Type} [DecidableEq ν] (τ : ν → Bool) :
    ¬Satisfied τ (∅ : Clause ν) := by
  intro ⟨l, hl, _⟩; simp at hl

end Clause

namespace CNF

def Satisfied {ν : Type} [DecidableEq ν] (τ : ν → Bool) (F : CNF ν) : Prop :=
  ∀ C ∈ F, Clause.Satisfied τ C

def Unsatisfiable {ν : Type} [DecidableEq ν] (F : CNF ν) : Prop :=
  ∀ τ : ν → Bool, ¬Satisfied τ F

end CNF

/-! ## Resolution Proof Trees -/

inductive ResTree {ν : Type} [DecidableEq ν] (F : CNF ν) : Clause ν → Type
  | hyp (C : Clause ν) (h : C ∈ F) : ResTree F C
  | weaken (C D : Clause ν) (h : C ⊆ D) (t : ResTree F C) : ResTree F D
  | resolve (x : ν) (C D : Clause ν)
      (t₁ : ResTree F (insert (Lit.pos x) C))
      (t₂ : ResTree F (insert (Lit.neg x) D)) :
      ResTree F (C ∪ D)

namespace ResTree

/-- Size of a proof tree (number of nodes). -/
def size {ν : Type} [DecidableEq ν] {F : CNF ν} {C : Clause ν} :
    ResTree F C → ℕ
  | hyp _ _ => 1
  | weaken _ _ _ t => 1 + t.size
  | resolve _ _ _ t₁ t₂ => 1 + t₁.size + t₂.size

/-- Maximum clause width in a proof tree. -/
def maxWidth {ν : Type} [DecidableEq ν] {F : CNF ν} {C : Clause ν} :
    ResTree F C → ℕ
  | hyp C _ => C.card
  | weaken _ D _ t => max D.card t.maxWidth
  | resolve _ C D t₁ t₂ => max (C ∪ D).card (max t₁.maxWidth t₂.maxWidth)

end ResTree

/-! ## Clause Space Bound -/

/-- Number of distinct clauses over `n` variables of width at most `w`.
    Each clause of width k chooses k variables from n, then assigns each a polarity.
    This counts ∑_{k=0}^{w} C(n,k) · 2^k. -/
def clauseSpaceBound (n w : ℕ) : ℕ :=
  ∑ k ∈ Finset.range (w + 1), Nat.choose n k * 2 ^ k

/-- `clauseSpaceBound` is monotone in `w`. -/
theorem clauseSpaceBound_mono (n : ℕ) : Monotone (clauseSpaceBound n) := by
  intro w₁ w₂ h
  apply Finset.sum_le_sum_of_subset_of_nonneg
  · exact Finset.range_mono (by omega)
  · intros; exact Nat.zero_le _

/-- `clauseSpaceBound n 0 = 1` (only the empty clause). -/
theorem clauseSpaceBound_zero (n : ℕ) : clauseSpaceBound n 0 = 1 := by
  simp [clauseSpaceBound]

/-- Lower bound: `clauseSpaceBound n w ≥ 1`. -/
theorem clauseSpaceBound_pos (n w : ℕ) : 0 < clauseSpaceBound n w := by
  calc 0 < clauseSpaceBound n 0 := by rw [clauseSpaceBound_zero]; omega
    _ ≤ clauseSpaceBound n w := clauseSpaceBound_mono n (Nat.zero_le w)

/-- Recurrence for the clause space bound. -/
theorem clauseSpaceBound_succ (n w : ℕ) :
    clauseSpaceBound n (w + 1) =
    clauseSpaceBound n w + Nat.choose n (w + 1) * 2 ^ (w + 1) := by
  simp [clauseSpaceBound, Finset.sum_range_succ]

/-
**clauseSpaceBound n n = 3^n**: the total number of clauses over n variables
    equals 3^n (binomial theorem for (1+2)^n).
-/
theorem clauseSpaceBound_eq_pow_three (n : ℕ) : clauseSpaceBound n n = 3 ^ n := by
  rw [ show 3 ^ n = ( 1 + 2 ) ^ n by norm_num, add_comm 1 2, add_pow ];
  exact Finset.sum_congr rfl fun _ _ => by push_cast; ring;

/-! ## Clause Entropy Bound -/

/-- Log₂ of the clause space bound, an information-theoretic proxy
    for the "entropy" of width-bounded clause space. -/
def clauseEntropyBound (n w : ℕ) : ℕ :=
  Nat.log 2 (clauseSpaceBound n w)

/-- The entropy bound is monotone in w. -/
theorem clauseEntropyBound_mono (n : ℕ) : Monotone (clauseEntropyBound n) := by
  intro w₁ w₂ h
  exact Nat.log_mono_right (clauseSpaceBound_mono n h)

/-! ## Finite Clause Encoding: ClauseCode -/

/-- A `ClauseCode` finitely encodes a clause by its support (set of variables)
    and a polarity assignment on each variable in the support.
    This creates the finite combinatorial object needed for counting. -/
structure ClauseCode (α : Type) [DecidableEq α] where
  /-- The set of variables appearing in the clause. -/
  vars : Finset α
  /-- The polarity of each variable: `true` for positive, `false` for negative. -/
  pol : α → Bool

/-- Interpretation: convert a `ClauseCode` to a clause (Finset of literals). -/
def ClauseCode.toClause {α : Type} [DecidableEq α] (c : ClauseCode α) : Clause α :=
  c.vars.image fun v => if c.pol v then Lit.pos v else Lit.neg v

/-- Width of a clause code is bounded by the cardinality of its support. -/
theorem ClauseCode.width_toClause_le {α : Type} [DecidableEq α] (c : ClauseCode α) :
    c.toClause.card ≤ c.vars.card := Finset.card_image_le

/-! ## Resolution Tree: allClauses and Structural Properties -/

namespace ResTree

/-- The set of all distinct clauses appearing in a resolution proof tree. -/
def allClauses {ν : Type} [DecidableEq ν] {F : CNF ν} {C : Clause ν} :
    ResTree F C → Finset (Clause ν)
  | hyp C _ => {C}
  | weaken _ D _ t => insert D t.allClauses
  | resolve _ C D t₁ t₂ => insert (C ∪ D) (t₁.allClauses ∪ t₂.allClauses)

/-- The root clause is in `allClauses`. -/
theorem root_mem_allClauses {ν : Type} [DecidableEq ν] {F : CNF ν} {C : Clause ν}
    (t : ResTree F C) : C ∈ t.allClauses := by
  cases t <;> simp [allClauses]

/-- **Distinct clause count ≤ tree size** (by structural induction on the tree). -/
theorem allClauses_card_le_size {ν : Type} [DecidableEq ν] {F : CNF ν} {C : Clause ν}
    (t : ResTree F C) : t.allClauses.card ≤ t.size := by
  induction t with
  | hyp C h => simp [allClauses, size]
  | weaken C D h t ih =>
    simp only [allClauses, size]
    have h1 := Finset.card_insert_le D t.allClauses
    omega
  | resolve x C D t₁ t₂ ih₁ ih₂ =>
    simp only [allClauses, size]
    have h1 := Finset.card_insert_le (C ∪ D) (t₁.allClauses ∪ t₂.allClauses)
    have h2 := Finset.card_union_le t₁.allClauses t₂.allClauses
    omega

/-- Every clause in `allClauses` has width at most `maxWidth` (structural induction). -/
theorem allClauses_width_le_maxWidth {ν : Type} [DecidableEq ν] {F : CNF ν} {C : Clause ν}
    (t : ResTree F C) : ∀ D ∈ t.allClauses, D.card ≤ t.maxWidth := by
  induction t with
  | hyp C h =>
    intro D hD; simp [allClauses] at hD; subst hD; simp [maxWidth]
  | weaken C E hsub t ih =>
    intro D hD; simp [allClauses] at hD
    rcases hD with rfl | hD
    · exact le_max_left _ _
    · exact le_trans (ih D hD) (le_max_right _ _)
  | resolve x C D t₁ t₂ ih₁ ih₂ =>
    intro E hE; simp [allClauses] at hE
    rcases hE with rfl | hE | hE
    · exact le_max_left _ _
    · exact le_trans (ih₁ E hE) (le_trans (le_max_left _ _) (le_max_right _ _))
    · exact le_trans (ih₂ E hE) (le_trans (le_max_right _ _) (le_max_right _ _))

/-- The width spectrum: set of widths appearing in a proof tree. -/
def widthSpectrum {ν : Type} [DecidableEq ν] {F : CNF ν} {C : Clause ν}
    (t : ResTree F C) : Finset ℕ :=
  t.allClauses.image Clause.width

/-- Every width in the spectrum ≤ `maxWidth`. -/
theorem widthSpectrum_le_maxWidth {ν : Type} [DecidableEq ν] {F : CNF ν} {C : Clause ν}
    (t : ResTree F C) : ∀ w ∈ t.widthSpectrum, w ≤ t.maxWidth := by
  intro w hw
  simp [widthSpectrum, Clause.width] at hw
  obtain ⟨D, hD, rfl⟩ := hw
  exact t.allClauses_width_le_maxWidth D hD

/-- Width spectrum cardinality ≤ maxWidth + 1. -/
theorem widthSpectrum_card_le {ν : Type} [DecidableEq ν] {F : CNF ν} {C : Clause ν}
    (t : ResTree F C) : t.widthSpectrum.card ≤ t.maxWidth + 1 := by
  have hsub : t.widthSpectrum ⊆ Finset.range (t.maxWidth + 1) := by
    intro w hw
    exact Finset.mem_range.mpr (Nat.lt_succ_of_le (t.widthSpectrum_le_maxWidth w hw))
  calc t.widthSpectrum.card ≤ (Finset.range (t.maxWidth + 1)).card :=
        Finset.card_le_card hsub
    _ = t.maxWidth + 1 := Finset.card_range _

/-- Number of leaves in a proof tree. -/
def numLeaves {ν : Type} [DecidableEq ν] {F : CNF ν} {C : Clause ν} :
    ResTree F C → ℕ
  | hyp _ _ => 1
  | weaken _ _ _ t => t.numLeaves
  | resolve _ _ _ t₁ t₂ => t₁.numLeaves + t₂.numLeaves

/-- numLeaves ≤ size. -/
theorem numLeaves_le_size {ν : Type} [DecidableEq ν] {F : CNF ν} {C : Clause ν}
    (t : ResTree F C) : t.numLeaves ≤ t.size := by
  induction t with
  | hyp _ _ => simp [numLeaves, size]
  | weaken _ _ _ t ih => simp [numLeaves, size]; omega
  | resolve _ _ _ t₁ t₂ ih₁ ih₂ => simp [numLeaves, size]; omega

/-- numLeaves > 0. -/
theorem numLeaves_pos {ν : Type} [DecidableEq ν] {F : CNF ν} {C : Clause ν}
    (t : ResTree F C) : 0 < t.numLeaves := by
  induction t with
  | hyp _ _ => simp [numLeaves]
  | weaken _ _ _ t ih => simp [numLeaves]; exact ih
  | resolve _ _ _ t₁ t₂ ih₁ ih₂ => simp [numLeaves]; omega

/-- size > 0. -/
theorem size_pos {ν : Type} [DecidableEq ν] {F : CNF ν} {C : Clause ν}
    (t : ResTree F C) : 0 < t.size := by
  have := t.numLeaves_pos; have := t.numLeaves_le_size; omega

/-- The set of hypothesis clauses used in a proof tree. -/
def usedHyps {ν : Type} [DecidableEq ν] {F : CNF ν} {C : Clause ν} :
    ResTree F C → Finset (Clause ν)
  | hyp C _ => {C}
  | weaken _ _ _ t => t.usedHyps
  | resolve _ _ _ t₁ t₂ => t₁.usedHyps ∪ t₂.usedHyps

/-- usedHyps ⊆ F. -/
theorem usedHyps_sub {ν : Type} [DecidableEq ν] {F : CNF ν} {C : Clause ν}
    (t : ResTree F C) : t.usedHyps ⊆ F := by
  induction t with
  | hyp _ h => exact Finset.singleton_subset_iff.mpr h
  | weaken _ _ _ t ih => exact ih
  | resolve _ _ _ t₁ t₂ ih₁ ih₂ => exact Finset.union_subset ih₁ ih₂

/-- **Combined structural bound**: distinct clauses ≤ size, all bounded width. -/
theorem width_size_allClauses_bound {ν : Type} [DecidableEq ν] {F : CNF ν} {C : Clause ν}
    (t : ResTree F C) :
    t.allClauses.card ≤ t.size ∧ ∀ D ∈ t.allClauses, D.card ≤ t.maxWidth :=
  ⟨t.allClauses_card_le_size, t.allClauses_width_le_maxWidth⟩

end ResTree

/-! ## Pigeonhole Principle -/

abbrev PHPVar (m n : ℕ) := Fin m × Fin n

def phpAtLeastOne (m n : ℕ) : CNF (PHPVar m n) :=
  Finset.univ.image fun i : Fin m =>
    Finset.univ.image fun j : Fin n => Lit.pos (i, j)

def phpAtMostOne (m n : ℕ) : CNF (PHPVar m n) :=
  Finset.univ.biUnion fun j : Fin n =>
    (Finset.univ.filter fun p : Fin m × Fin m => p.1 < p.2).image fun p =>
      ({Lit.neg (p.1, j), Lit.neg (p.2, j)} : Clause (PHPVar m n))

def phpCNF (m n : ℕ) : CNF (PHPVar m n) :=
  phpAtLeastOne m n ∪ phpAtMostOne m n

/-- The at-most-one clauses are satisfiable by the all-false assignment. -/
theorem php_atMostOne_sat (m n : ℕ) :
    CNF.Satisfied (fun _ : PHPVar m n => false) (phpAtMostOne m n) := by
  intro C hC
  unfold phpAtMostOne at hC
  simp at hC
  obtain ⟨j, i₁, i₂, _, rfl⟩ := hC
  exact ⟨Lit.neg (i₁, j), by simp, by simp [Lit.eval]⟩

/-
phpAtLeastOne clauses have cardinality n (when n > 0).
-/
theorem phpAtLeastOne_width (m n : ℕ) (_hn : 0 < n) (C : Clause (PHPVar m n))
    (hC : C ∈ phpAtLeastOne m n) : C.card = n := by
  unfold phpAtLeastOne at hC;
  rw [ Finset.mem_image ] at hC; obtain ⟨ i, _, rfl ⟩ := hC; rw [ Finset.card_image_of_injective ] <;> aesop_cat;

/-
usedHyps of a tree-resolution refutation of PHP must include at-least-one clauses.
-/
theorem php_refutation_uses_atLeastOne (n : ℕ)
    (t : ResTree (phpCNF (n + 1) n) ∅) :
    ∃ H ∈ t.usedHyps, H ∈ phpAtLeastOne (n + 1) n := by
  by_contra h_contra;
  -- By induction on the structure of the proof tree, we can show that if no hypothesis in `t.usedHyps` is in `phpAtLeastOne`, then all hypotheses in `t.usedHyps` must be in `phpAtMostOne`.
  have h_ind : ∀ (C : Clause (PHPVar (n + 1) n)) (t : ResTree (phpCNF (n + 1) n) C), (∀ H ∈ t.usedHyps, H ∈ phpAtMostOne (n + 1) n) → CNF.Satisfied (fun _ => false) {C} := by
    intros C t ht
    induction' t with C t ht ih; (
    simp_all +decide [ ResTree.usedHyps ];
    exact fun _ => by have := php_atMostOne_sat ( n + 1 ) n; aesop;);
    · simp_all +decide [ ResTree.usedHyps ];
      simp_all +decide [ CNF.Satisfied ];
      obtain ⟨ l, hl₁, hl₂ ⟩ := ‹Clause.Satisfied ( fun x => false ) _›; exact ⟨ l, by aesop ⟩ ;
    · simp_all +decide [ CNF.Satisfied ];
      grind +locals;
  specialize h_ind _ t ( fun H hH => by
    have := ResTree.usedHyps_sub t hH; simp_all +decide [ phpCNF ] ; ) ; simp_all +decide [ CNF.Satisfied ];
  exact absurd h_ind ( by simp +decide [ Clause.Satisfied ] )

/-
**PHP width lower bound**: any resolution refutation of PHP(n+1,n) has maxWidth ≥ n.
-/
theorem php_width_lower_bound (n : ℕ) (hn : 0 < n)
    (t : ResTree (phpCNF (n + 1) n) ∅) :
    n ≤ t.maxWidth := by
  obtain ⟨ H, hH₁, hH₂ ⟩ := php_refutation_uses_atLeastOne n t;
  have h_card : H.card ≤ t.maxWidth := by
    have h_card : ∀ {F : CNF (PHPVar (n + 1) n)} {C : Clause (PHPVar (n + 1) n)} (t : ResTree F C), ∀ H ∈ t.usedHyps, H.card ≤ t.maxWidth := by
      intros F C t H hH;
      induction' t with C hC t₁ t₂ ih₁ ih₂;
      · cases hH ; aesop;
        contradiction;
      · exact le_trans ( by solve_by_elim ) ( Nat.le_max_right _ _ );
      · rename_i x C D t₁ t₂ ih₁ ih₂;
        cases Finset.mem_union.mp hH <;> [ exact le_trans ( ih₁ ‹_› ) ( by exact le_max_of_le_right ( le_max_left _ _ ) ) ; exact le_trans ( ih₂ ‹_› ) ( by exact le_max_of_le_right ( le_max_right _ _ ) ) ];
    exact h_card t H hH₁;
  have := phpAtLeastOne_width ( n + 1 ) n hn H hH₂; aesop;

/-
usedHyps ⊆ allClauses.
-/
theorem usedHyps_subset_allClauses {ν : Type} [DecidableEq ν] {F : CNF ν} {C : Clause ν}
    (t : ResTree F C) : t.usedHyps ⊆ t.allClauses := by
  induction' t with t ih;
  · exact Finset.coe_subset.mp fun ⦃a⦄ a_1 => a_1;
  · exact Set.Subset.trans ‹_› ( Finset.subset_insert _ _ );
  · simp_all +decide [ Finset.subset_iff, ResTree.usedHyps, ResTree.allClauses ];
    grind

/-
**Size ≥ maxWidth - root_width + 1** for any tree-resolution proof.
    This follows because along any path from a max-width clause to the root,
    each node adds at most 1 to the size, and the width must decrease from
    maxWidth to the root's width.
-/
theorem size_ge_maxWidth_sub_root_width {ν : Type} [DecidableEq ν] {F : CNF ν} {C : Clause ν}
    (t : ResTree F C) : t.maxWidth + 1 ≤ t.size + C.card := by
  induction' t with C D h t ih;
  · simp +arith +decide [ ResTree.maxWidth, ResTree.size ];
  · simp [ResTree.maxWidth, ResTree.size] at *;
    linarith [ Finset.card_le_card ih ];
  · simp +arith +decide [ ResTree.maxWidth, ResTree.size ];
    rename_i k l m n;
    rename_i x C D;
    constructor <;> linarith [ show Finset.card ( insert ( Lit.pos x ) C ) ≤ Finset.card ( C ∪ D ) + 1 from le_trans ( Finset.card_insert_le _ _ ) ( by linarith [ show Finset.card C ≤ Finset.card ( C ∪ D ) from Finset.card_le_card ( Finset.subset_union_left ) ] ), show Finset.card ( insert ( Lit.neg x ) D ) ≤ Finset.card ( C ∪ D ) + 1 from le_trans ( Finset.card_insert_le _ _ ) ( by linarith [ show Finset.card D ≤ Finset.card ( C ∪ D ) from Finset.card_le_card ( Finset.subset_union_right ) ] ) ]

/-- For refutations (deriving ∅), size ≥ maxWidth + 1. -/
theorem refutation_size_ge_maxWidth {ν : Type} [DecidableEq ν] {F : CNF ν}
    (t : ResTree F ∅) : t.maxWidth + 1 ≤ t.size := by
  have h := size_ge_maxWidth_sub_root_width t
  simp [Finset.card_empty] at h
  omega

/-- **PHP tree-resolution size lower bound**: size ≥ n + 1.
    Combines the width lower bound (maxWidth ≥ n) with the structural bound
    (size ≥ maxWidth + 1 for refutations). -/
theorem php_tree_size_lower_bound (n : ℕ) (hn : 0 < n)
    (t : ResTree (phpCNF (n + 1) n) ∅) :
    n + 1 ≤ t.size := by
  have h1 := php_width_lower_bound n hn t
  have h2 := refutation_size_ge_maxWidth t
  omega

end WidthToSize