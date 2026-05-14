/-
# Proof-Theoretic Depth: Ordinal-Valued Complexity for Derivation Objects

This module introduces a formal framework for **proof-theoretic governance of automated
mathematics**, where ordinal-valued invariants on a derivation language provide
machine-checkable certificates of structural non-triviality.

## Main Results

* `trivial_depth_lt_omega` — Every trivial expression has depth strictly below ω.
* `nontrivial_of_omega_le_depth` — Depth ≥ ω certifies non-triviality.
* `depth_le_cycleDepth` — Every element's depth is bounded by its cycle's depth.
* `shallow_cycle_all_below_threshold` — Shallow cycles contain only bounded-complexity outputs.
* `innovationScore_le_structuralDepth` — The innovation proxy is dominated by structural depth.

## Design Note: Why ω as Threshold

The ordinal ω is the natural threshold separating finite-step compositions from transfinite
constructions. In our calculus, expressions built purely from `atom`, `compose`, `bridge`,
and `iterate` have depth in the natural numbers (below ω). The `certify` constructor
introduces an ordinal exponential jump: `certify e` has depth `ω ^ e.depth`. When applied
to any expression of depth ≥ 1, this produces depth ≥ ω, crossing the threshold.

This mirrors classical proof theory, where ω marks the boundary between finitary and
transfinite induction, and Gentzen's consistency proof for PA requires induction up to ε₀.
The threshold is not arbitrary — it is the smallest limit ordinal, representing the
qualitative leap from bounded iteration to genuine transfinite construction.
-/

import Mathlib

open Ordinal

/-! ## Syntax: The Research Expression Calculus -/

/-- A simple derivation language with constructors of increasing structural complexity.
- `atom n`: atomic statement (leaf node)
- `compose e₁ e₂`: sequential composition of two derivations
- `bridge e₁ e₂`: cross-domain connection (higher-depth constructor)
- `iterate n e`: bounded iteration of a derivation
- `certify e`: certification/abstraction step introducing transfinite depth -/
inductive ResearchExpr : Type
  | atom : Nat → ResearchExpr
  | compose : ResearchExpr → ResearchExpr → ResearchExpr
  | bridge : ResearchExpr → ResearchExpr → ResearchExpr
  | iterate : Nat → ResearchExpr → ResearchExpr
  | certify : ResearchExpr → ResearchExpr
  deriving DecidableEq

namespace ResearchExpr

/-! ## Ordinal Depth

The depth function assigns an ordinal to each expression, measuring structural complexity.
Crucially, `certify` introduces an exponential jump via `ω ^ depth`, creating a phase
transition between finitary and transfinite derivations. -/

/-- Ordinal-valued depth of a research expression.
- Atoms have depth 0.
- Composition takes the successor of the max of its children.
- Bridge adds two successor steps (cross-domain cost).
- Iteration adds a natural number to the depth.
- Certification applies ordinal exponentiation: `ω ^ depth`. -/
noncomputable def depth : ResearchExpr → Ordinal
  | .atom _ => 0
  | .compose e₁ e₂ => Order.succ (max e₁.depth e₂.depth)
  | .bridge e₁ e₂ => Order.succ (Order.succ (max e₁.depth e₂.depth))
  | .iterate n e => e.depth + n
  | .certify e => omega0 ^ e.depth

/-! ## Structural Depth (Natural Number Proxy)

A natural-number-valued depth that mirrors the ordinal depth but stays in ℕ,
suitable for computation and comparison with the innovation score. -/

/-- Natural-number structural depth, a computable proxy for ordinal depth. -/
def structuralDepth : ResearchExpr → Nat
  | .atom _ => 0
  | .compose e₁ e₂ => 1 + max e₁.structuralDepth e₂.structuralDepth
  | .bridge e₁ e₂ => 2 + max e₁.structuralDepth e₂.structuralDepth
  | .iterate n e => e.structuralDepth + n
  | .certify e => 1 + e.structuralDepth

/-! ## Innovation Score

A numeric proxy for "innovation content" that counts cross-domain bridges and
certifications but ignores pure composition. This is explicitly a **proxy invariant**,
not a claim to formalize conceptual innovation. -/

/-- Innovation score: counts bridge and certify constructors, ignoring pure composition.
This measures the density of cross-domain and abstraction steps. -/
def innovationScore : ResearchExpr → Nat
  | .atom _ => 0
  | .compose e₁ e₂ => max e₁.innovationScore e₂.innovationScore
  | .bridge e₁ e₂ => 1 + max e₁.innovationScore e₂.innovationScore
  | .iterate n e => n + e.innovationScore
  | .certify e => 1 + e.innovationScore

/-! ## Node Count -/

/-- Total number of nodes in the syntax tree. -/
def nodeCount : ResearchExpr → Nat
  | .atom _ => 1
  | .compose e₁ e₂ => 1 + e₁.nodeCount + e₂.nodeCount
  | .bridge e₁ e₂ => 1 + e₁.nodeCount + e₂.nodeCount
  | .iterate _ e => 1 + e.nodeCount
  | .certify e => 1 + e.nodeCount

end ResearchExpr

/-! ## Triviality Fragment

The trivial fragment is a syntactically restricted class of expressions:
only atoms and single-step compositions of atoms. This is intentionally strict,
capturing the idea that trivial derivations are those with no structural depth. -/

/-- A trivial expression is either an atom or a single composition of two atoms.
This fragment captures "zero-effort" derivations. -/
inductive TrivialExpr : ResearchExpr → Prop
  | atom (n : Nat) : TrivialExpr (.atom n)
  | compose_atoms (a b : Nat) : TrivialExpr (.compose (.atom a) (.atom b))

/-! ## Theorem 1: Trivial Expressions Have Bounded Depth -/

/-
Every trivial expression has ordinal depth strictly below ω.
This is the formal anchor: trivial work lives in the finite ordinals.
-/
theorem trivial_depth_lt_omega :
    ∀ {e : ResearchExpr}, TrivialExpr e → e.depth < omega0 := by
  intro e h;
  obtain ⟨a, b, hab⟩ : ∃ a b : Nat, e = .compose (.atom a) (.atom b) ∨ e = .atom a := by
    cases h <;> aesop;
  cases hab <;> simp_all +decide [ ResearchExpr.depth ]

/-! ## Theorem 2: Depth Beyond ω Certifies Non-Triviality -/

/-
If an expression has depth ≥ ω, it is provably outside the trivial fragment.
This is the machine-checkable **non-triviality certificate**.
-/
theorem nontrivial_of_omega_le_depth :
    ∀ {e : ResearchExpr}, omega0 ≤ e.depth → ¬ TrivialExpr e := by
  exact fun { e } h₁ h₂ => not_le_of_gt ( trivial_depth_lt_omega h₂ ) h₁

/-! ## Cycle Depth and Governance -/

/-- The depth of a finite research cycle is the supremum of its elements' depths. -/
noncomputable def cycleDepth (S : Finset ResearchExpr) : Ordinal :=
  S.sup ResearchExpr.depth

/-! ## Theorem 3: Individual Depth Bounded by Cycle Depth -/

/-
Every element's depth is bounded by its cycle's depth.
-/
theorem depth_le_cycleDepth (S : Finset ResearchExpr) {e : ResearchExpr}
    (he : e ∈ S) : e.depth ≤ cycleDepth S := by
  exact Finset.le_sup ( f := ResearchExpr.depth ) he

/-! ## Theorem 3b: Existence of Maximum Depth in Nonempty Cycles -/

/-
In any nonempty finite cycle, there exists an element attaining the maximum depth.
-/
theorem exists_max_depth_expr (S : Finset ResearchExpr) (hS : S.Nonempty) :
    ∃ e ∈ S, ∀ e' ∈ S, e'.depth ≤ e.depth := by
  convert Finset.exists_max_image _ ( fun e => e.depth ) hS

/-! ## Policy Predicates -/

/-- An expression is accepted at threshold θ if its depth meets the threshold. -/
def AcceptsAtThreshold (θ : Ordinal) (e : ResearchExpr) : Prop :=
  θ ≤ e.depth

/-- A cycle should be escalated if its total depth falls below threshold θ. -/
def EscalateCycle (θ : Ordinal) (S : Finset ResearchExpr) : Prop :=
  cycleDepth S < θ

/-! ## Theorem 4: Shallow Cycles Contain Only Bounded-Complexity Outputs -/

/-
If a cycle's depth is below threshold θ, then every element's depth is below θ.
This is the formal kernel of "automatically reject or escalate shallow cycles."
-/
theorem shallow_cycle_all_below_threshold
    (θ : Ordinal) (S : Finset ResearchExpr)
    (h : cycleDepth S < θ) :
    ∀ e ∈ S, e.depth < θ := by
  exact fun e he => lt_of_le_of_lt ( Finset.le_sup ( f := ResearchExpr.depth ) he ) h

/-! ## Theorem 5: Innovation Score Dominated by Structural Depth -/

/-
The innovation score is always bounded by the structural depth.
This monotone domination theorem ensures that the innovation proxy
cannot exceed the structural complexity of a derivation.
-/
theorem innovationScore_le_structuralDepth :
    ∀ e : ResearchExpr, e.innovationScore ≤ e.structuralDepth := by
  intro e;
  -- We'll use induction on the structure of `e`.
  induction' e with e₁ e₂ ih₁ ih₂;
  · exact Nat.le_of_ble_eq_true rfl;
  · exact le_trans ( max_le_max ih₂ ‹_› ) ( by simp +arith +decide [ ResearchExpr.structuralDepth ] );
  · exact Nat.add_le_add ( by norm_num ) ( max_le_max ‹_› ‹_› );
  · -- By definition of innovation score and structural depth, we can simplify the goal.
    simp [ResearchExpr.innovationScore, ResearchExpr.structuralDepth];
    grobner;
  · exact Nat.add_le_add_left ‹_› 1

/-! ## Helper: Natural number bounded by ω ^ d for certify case -/

private theorem nat_le_omega0_opow (n : ℕ) (d : Ordinal) (hnd : (n : Ordinal) ≤ d) :
    ((n + 1 : ℕ) : Ordinal) ≤ omega0 ^ d := by
  by_cases hd : d = 0 <;> simp_all +decide [ Nat.cast_succ ];
  -- Since $d \neq 0$, we have $\omega^d \geq \omega$.
  have h_omega_d_ge_omega : omega0 ≤ omega0 ^ d := by
    exact le_trans ( by norm_num ) ( Ordinal.opow_le_opow_right Ordinal.omega0_pos ( show d ≥ 1 from Ordinal.one_le_iff_ne_zero.mpr hd ) );
  exact lt_of_lt_of_le ( Ordinal.nat_lt_omega0 _ ) h_omega_d_ge_omega

/-! ## Bridge Lemma: Structural Depth Bounded Below Ordinal Depth -/

/-
The natural-number structural depth, when cast to an ordinal, is bounded
by the ordinal depth. This connects the computable proxy to the ordinal invariant
for expressions whose depth is below ω (the finitary fragment).
-/
theorem natCast_structuralDepth_le_depth :
    ∀ e : ResearchExpr, (e.structuralDepth : Ordinal) ≤ e.depth := by
  -- We proceed by induction on the structure of the expression.
  intro e
  induction' e with e₁ e₂ ih₁ ih₂;
  · exact le_rfl;
  · simp +arith +decide [ ResearchExpr.depth, ResearchExpr.structuralDepth ];
    cases max_cases e₂.structuralDepth ih₁.structuralDepth <;> simp +decide [ * ];
  · simp +arith +decide [ ResearchExpr.structuralDepth ];
    rename_i e₁ e₂ ih₁ ih₂;
    norm_cast;
    erw [ Order.succ_le_succ_iff ];
    erw [ Order.succ_le_succ_iff ];
    cases max_choice e₁.structuralDepth e₂.structuralDepth <;> simp +decide [ * ];
    · exact Or.inl ( by exact le_of_eq_of_le rfl ih₁ );
    · exact Or.inr ( by norm_cast );
  · simp [ResearchExpr.structuralDepth, ResearchExpr.depth];
    grind +suggestions;
  · rename_i e ih;
    convert nat_le_omega0_opow e.structuralDepth e.depth ih using 1;
    exact_mod_cast add_comm _ _

/-! ## Bridge Lemma: Trivial Fragment Has Bounded Structural Depth -/

/-
Trivial expressions have structural depth at most 1.
This gives a concrete computable bound on the trivial fragment.
-/
theorem trivial_structuralDepth_le_one :
    ∀ {e : ResearchExpr}, TrivialExpr e → e.structuralDepth ≤ 1 := by
  rintro e ( h | h ) <;> simp_all +arith +decide [ ResearchExpr.structuralDepth ] ;

/-! ## Corollary: High Innovation Implies Non-Triviality -/

/-
If an expression's innovation score exceeds 1, it is non-trivial.
This connects the computable innovation proxy to the triviality classification.
-/
theorem nontrivial_of_high_innovation :
    ∀ {e : ResearchExpr}, 1 < e.innovationScore → ¬ TrivialExpr e := by
  intro e he h; have := trivial_structuralDepth_le_one h; linarith [ innovationScore_le_structuralDepth e ] ;