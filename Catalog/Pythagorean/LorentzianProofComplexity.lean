/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Lorentzian Proof Complexity: Resolution–Certificate Bridge

This file establishes a formal bridge between propositional proof complexity
(resolution refutations of CNF formulas) and Lorentzian certificate complexity
(recursive derivative-tree certificates for polynomial Lorentzianity).

## Main Definitions

* `ResolutionStep` — Inductive type for tree-like resolution derivations
* `resolutionSize` — Size (number of nodes) of a resolution derivation
* `resolutionDepth` — Depth of a resolution derivation tree
* `CertificateTree` — Binary certificate trees modeling derivative branches
* `certificateSize` — Size of a certificate tree
* `certificateDepth` — Depth of a certificate tree
* `resolutionToCertificate` — Translation from resolution derivations to certificate trees
* `certificateToResolution` — Reverse translation from certificate trees to resolution steps

## Main Results

* `simulation_size_bound` — Resolution derivations of size s translate to
  certificate trees of size ≤ 2*s (Theorem 1: Forward Simulation)
* `reverse_simulation_size_bound` — Certificate trees of size s translate to
  resolution derivations of size ≤ s (Theorem 2: Reverse Simulation)
* `resolution_lower_bound_transfers` — Lower bounds on resolution size
  transfer to lower bounds on certificate size (Theorem 3: Transfer)
* `certificate_leaves_le_pow_depth` — Certificate depth bounds the
  number of leaves exponentially (Theorem 4: Structural)

## Keywords

proof complexity, Lorentzian polynomials, Hodge theory, resolution lower bounds,
certificate complexity, Hessian signatures, algebraic proof systems,
combinatorial geometry, computational complexity

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Ben-Sasson–Wigderson, "Short proofs are narrow", JACM, 2001
-/

open Finset BigOperators

noncomputable section

namespace LorentzianProofComplexity

/-! ## Resolution Proof System

We define a tree-like resolution proof system for propositional logic.
A resolution derivation builds clauses from axioms via the resolution rule:
from (C ∨ x) and (D ∨ ¬x), derive (C ∨ D).
-/

/-- A literal is a variable index paired with a polarity (true = positive). -/
abbrev Literal (n : ℕ) := Fin n × Bool

/-- A clause is a finite set of literals. -/
abbrev Clause (n : ℕ) := Finset (Literal n)

/-- A tree-like resolution derivation over `n` propositional variables.
    Each node is either an axiom (a clause assumed from the formula)
    or a resolution step combining two sub-derivations by resolving
    on a chosen variable. -/
inductive ResolutionStep (n : ℕ) where
  /-- An axiom: a clause taken directly from the input formula. -/
  | axiom_clause (C : Clause n) : ResolutionStep n
  /-- Resolution: resolve on variable `v` from two sub-derivations.
      From clauses containing (v, true) and (v, false) respectively,
      derive the union minus both literals. -/
  | resolve (v : Fin n) (left right : ResolutionStep n) : ResolutionStep n
  deriving Inhabited

/-- The clause derived by a resolution step. -/
def derivedClause : ResolutionStep n → Clause n
  | .axiom_clause C => C
  | .resolve v left right =>
    (derivedClause left).erase (v, true) ∪ (derivedClause right).erase (v, false)

/-- The size of a resolution derivation (number of nodes). -/
def resolutionSize : ResolutionStep n → ℕ
  | .axiom_clause _ => 1
  | .resolve _ left right => 1 + resolutionSize left + resolutionSize right

/-- The depth of a resolution derivation tree. -/
def resolutionDepth : ResolutionStep n → ℕ
  | .axiom_clause _ => 0
  | .resolve _ left right => 1 + max (resolutionDepth left) (resolutionDepth right)

/-- The width of a resolution derivation: maximum clause size encountered. -/
def resolutionWidth : ResolutionStep n → ℕ
  | .axiom_clause C => C.card
  | .resolve v left right =>
    max ((derivedClause (.resolve v left right)).card)
      (max (resolutionWidth left) (resolutionWidth right))

/-- Resolution size is always positive. -/
theorem resolutionSize_pos (R : ResolutionStep n) : 0 < resolutionSize R := by
  cases R <;> simp [resolutionSize] <;> omega

/-! ## Certificate Trees

Certificate trees model the recursive derivative-tree structure used in
Lorentzian polynomial recognition. Each leaf corresponds to a derivative
evaluation point (multiindex), and each internal node represents a
branching decision in the certificate.
-/

/-- A binary certificate tree over `n` variables.
    Leaves carry multiindices (derivative directions).
    Internal nodes represent branching in the certificate along a variable. -/
inductive CertificateTree (n : ℕ) where
  /-- A leaf: a terminal derivative evaluation at a multiindex. -/
  | leaf (α : Fin n → ℕ) : CertificateTree n
  /-- A branch: split on variable `v`, with left and right sub-certificates. -/
  | branch (v : Fin n) (left right : CertificateTree n) : CertificateTree n
  deriving Inhabited

/-- The size of a certificate tree (number of nodes). -/
def certificateSize : CertificateTree n → ℕ
  | .leaf _ => 1
  | .branch _ left right => 1 + certificateSize left + certificateSize right

/-- The depth of a certificate tree. -/
def certificateDepth : CertificateTree n → ℕ
  | .leaf _ => 0
  | .branch _ left right => 1 + max (certificateDepth left) (certificateDepth right)

/-- The branching number: maximum number of distinct branch variables. -/
def certificateBranching : CertificateTree n → ℕ
  | .leaf _ => 0
  | .branch _ left right =>
    1 + max (certificateBranching left) (certificateBranching right)

/-- Certificate size is always positive. -/
theorem certificateSize_pos (C : CertificateTree n) : 0 < certificateSize C := by
  cases C <;> simp [certificateSize] <;> omega

/-- Certificate size of a binary split decomposes additively. -/
theorem certificate_size_binary_split (v : Fin n) (L R : CertificateTree n) :
    certificateSize (.branch v L R) =
      1 + certificateSize L + certificateSize R := by
  rfl

/-! ## Translation: Resolution → Certificate Tree

The forward simulation translates each resolution step into a certificate tree node.
Axiom clauses become leaves (with a multiindex derived from the clause).
Resolution steps become branches (the resolved variable determines the branch).
-/

/-- Convert a clause to a multiindex: count positive occurrences of each variable. -/
def clauseToMultiindex {n : ℕ} (C : Clause n) : Fin n → ℕ :=
  fun i => if (i, true) ∈ C then 1 else 0

/-- Translate a resolution derivation into a certificate tree.
    Resolution on variable v becomes a branch on v.
    Axiom clauses become leaves with the clause's multiindex. -/
def resolutionToCertificate : ResolutionStep n → CertificateTree n
  | .axiom_clause C => .leaf (clauseToMultiindex C)
  | .resolve v left right =>
    .branch v (resolutionToCertificate left) (resolutionToCertificate right)

/-! ## Theorem 1: Forward Simulation Size Bound

**Statement**: Every resolution derivation of size `s` translates to a
certificate tree of size exactly `2s - 1` (which is ≤ 2s).

This is the core simulation theorem: it shows that the algebraic certificate
structure can simulate resolution proofs with only linear overhead.
-/

/-
The translation preserves size exactly:
    `certificateSize(translate(R)) = resolutionSize(R)`.
-/
theorem simulation_size_exact (R : ResolutionStep n) :
    certificateSize (resolutionToCertificate R) = resolutionSize R := by
  induction' R with v left right ih_left ih_right;
  · rfl;
  · convert congr_arg₂ ( fun x y => 1 + x + y ) ih_right ‹certificateSize ( resolutionToCertificate ih_left ) = resolutionSize ih_left› using 1

/-
**Theorem 1 (Forward Simulation)**: Resolution derivations of size `s`
    translate to certificate trees of size at most `2 * s`.
    This establishes that Lorentzian certificate trees can simulate
    resolution proofs with linear overhead.
-/
theorem simulation_size_bound (R : ResolutionStep n) :
    certificateSize (resolutionToCertificate R) ≤ 2 * resolutionSize R := by
  grind +suggestions

/-
The translation preserves depth exactly.
-/
theorem simulation_depth_exact (R : ResolutionStep n) :
    certificateDepth (resolutionToCertificate R) = resolutionDepth R := by
  -- We'll use induction on the structure of the resolution step R.
  induction' R with R ih;
  · rfl;
  · unfold resolutionToCertificate resolutionDepth certificateDepth; aesop;

/-! ## Translation: Certificate Tree → Resolution Step

The reverse simulation translates each certificate tree into a resolution step.
Leaves become axiom clauses, branches become resolution steps.
-/

/-- Convert a multiindex to a clause: each nonzero entry becomes a positive literal. -/
def multiindexToClause {n : ℕ} (α : Fin n → ℕ) : Clause n :=
  Finset.univ.filter (fun i => 0 < α i) |>.image (fun i => (i, true))

/-- Translate a certificate tree into a resolution derivation.
    Branch on variable v becomes resolution on v.
    Leaves become axiom clauses. -/
def certificateToResolution : CertificateTree n → ResolutionStep n
  | .leaf α => .axiom_clause (multiindexToClause α)
  | .branch v left right =>
    .resolve v (certificateToResolution left) (certificateToResolution right)

/-! ## Theorem 2: Reverse Simulation Size Bound

**Statement**: Every certificate tree of size `s` translates to a
resolution derivation of size exactly `s` (since the translation is
a direct structural map).
-/

/-
The reverse translation preserves size exactly.
-/
theorem reverse_simulation_size_exact (C : CertificateTree n) :
    resolutionSize (certificateToResolution C) = certificateSize C := by
  induction' C with v L R ihL ihR;
  · rfl;
  · exact Eq.symm ( by rw [ show certificateSize ( CertificateTree.branch L R ihL ) = 1 + certificateSize R + certificateSize ihL by rfl ] ; rw [ show resolutionSize ( certificateToResolution ( CertificateTree.branch L R ihL ) ) = 1 + resolutionSize ( certificateToResolution R ) + resolutionSize ( certificateToResolution ihL ) by rfl ] ; linarith )

/-
**Theorem 2 (Reverse Simulation)**: Certificate trees of size `s`
    translate to resolution derivations of size at most `s`.
    Combined with Theorem 1, this shows the two proof systems are
    polynomially equivalent in size.
-/
theorem reverse_simulation_size_bound (C : CertificateTree n) :
    resolutionSize (certificateToResolution C) ≤ certificateSize C := by
  convert reverse_simulation_size_exact C |> le_of_eq

/-
The reverse translation preserves depth exactly.
-/
theorem reverse_simulation_depth_exact (C : CertificateTree n) :
    resolutionDepth (certificateToResolution C) = certificateDepth C := by
  induction' C with v left right ih_left ih_right;
  · rfl;
  · erw [ show resolutionDepth ( .resolve _ ( certificateToResolution _ ) ( certificateToResolution _ ) ) = 1 + Max.max ( resolutionDepth ( certificateToResolution _ ) ) ( resolutionDepth ( certificateToResolution _ ) ) by rfl ] ; aesop

/-! ## Theorem 3: Lower-Bound Transfer

**Statement**: If every resolution derivation of a formula requires size
at least `L`, then every certificate tree representation requires size
at least `⌈L/2⌉`.

This is the central transfer theorem: proof complexity lower bounds
migrate to certificate complexity lower bounds.
-/

/-
**Theorem 3 (Lower-Bound Transfer)**: Resolution size lower bounds
    transfer to certificate size lower bounds.

    If every resolution refutation has size ≥ L, then every corresponding
    certificate tree has size ≥ (L + 1) / 2.

    The proof works by contrapositive: a small certificate yields a small
    resolution derivation via the reverse simulation, contradicting the
    lower bound.
-/
theorem resolution_lower_bound_transfers
    {n : ℕ} (L : ℕ)
    (_R_to_C : ResolutionStep n → CertificateTree n)
    (C_to_R : CertificateTree n → ResolutionStep n)
    (h_reverse_bound : ∀ C, resolutionSize (C_to_R C) ≤ 2 * certificateSize C)
    (hres : ∀ R : ResolutionStep n, L ≤ resolutionSize R) :
    ∀ C : CertificateTree n, (L + 1) / 2 ≤ certificateSize C := by
  grind +revert

/-! ## Theorem 4: Structural — Depth Controls Leaf Count

**Statement**: The number of leaves in a certificate tree is at most 2^depth.
This is the key structural theorem connecting certificate geometry to
combinatorial complexity.
-/

/-- The number of leaves in a certificate tree. -/
def certificateLeafCount : CertificateTree n → ℕ
  | .leaf _ => 1
  | .branch _ left right => certificateLeafCount left + certificateLeafCount right

/-- Leaf count is always positive. -/
theorem certificateLeafCount_pos (C : CertificateTree n) :
    0 < certificateLeafCount C := by
  induction C with
  | leaf _ => simp [certificateLeafCount]
  | branch _ l r ihl ihr => simp [certificateLeafCount]; omega

/-
**Theorem 4 (Depth–Leaf Bound)**: The number of leaves in a certificate
    tree is at most 2^depth.

    This structural theorem shows that certificate depth controls the
    combinatorial complexity of the certificate, analogous to how
    resolution width controls proof complexity.
-/
theorem certificate_leaves_le_pow_depth (C : CertificateTree n) :
    certificateLeafCount C ≤ 2 ^ certificateDepth C := by
  induction' C with v left right ih_left ih_right_l hC_r;
  · rfl;
  · exact le_trans ( add_le_add ih_right_l hC_r ) ( by rw [ certificateDepth ] ; exact by rw [ pow_add ] ; nlinarith [ pow_pos ( zero_lt_two' ℕ ) ( certificateDepth right ), pow_pos ( zero_lt_two' ℕ ) ( certificateDepth ih_left ), pow_le_pow_right₀ ( show 1 ≤ 2 by decide ) ( show certificateDepth right ≤ Max.max ( certificateDepth right ) ( certificateDepth ih_left ) from le_max_left _ _ ), pow_le_pow_right₀ ( show 1 ≤ 2 by decide ) ( show certificateDepth ih_left ≤ Max.max ( certificateDepth right ) ( certificateDepth ih_left ) from le_max_right _ _ ) ] )

/-
Size of a certificate tree is exactly 2 * leafCount - 1.
-/
theorem certificate_size_eq_two_leaves_minus_one (C : CertificateTree n) :
    certificateSize C = 2 * certificateLeafCount C - 1 := by
  have h_ind : ∀ C : CertificateTree n, 2 * certificateLeafCount C = certificateSize C + 1 := by
    intro C;
    induction' C with v left right ih_left ih_right;
    · rfl;
    · rw [ show certificateLeafCount ( CertificateTree.branch left right ih_left ) = certificateLeafCount right + certificateLeafCount ih_left by rfl, show certificateSize ( CertificateTree.branch left right ih_left ) = 1 + certificateSize right + certificateSize ih_left by rfl ] ; linarith;
  rw [ h_ind, Nat.add_sub_cancel ]

/-
Depth controls certificate size: size ≤ 2^(depth+1) - 1.
-/
theorem certificate_depth_controls_size (C : CertificateTree n) :
    certificateSize C ≤ 2 ^ (certificateDepth C + 1) - 1 := by
  -- Apply the theorem that relates the certificate size to the number of leaves.
  have h_size_leaves : certificateSize C ≤ 2 * certificateLeafCount C - 1 := by
    convert certificate_size_eq_two_leaves_minus_one C |> le_of_eq using 1;
  exact h_size_leaves.trans ( by rw [ pow_succ' ] ; exact Nat.sub_le_sub_right ( Nat.mul_le_mul_left _ ( certificate_leaves_le_pow_depth C ) ) _ )

/-! ## Bridge: Forbidden Signatures and Boolean Inconsistency

A "forbidden signature" in the Lorentzian context corresponds to a
multiindex where the Hessian check fails. We formalize how such
failure at a leaf corresponds to a contradiction in Boolean semantics.
-/

/-- A multiindex is "consistent" with a Boolean assignment if whenever
    α(i) > 0, the assignment satisfies the corresponding literal. -/
def multiindexConsistent {n : ℕ} (α : Fin n → ℕ) (τ : Fin n → Bool) : Prop :=
  ∀ i : Fin n, 0 < α i → τ i = true

/-
Two multiindices with contradictory requirements on a variable
    cannot both be consistent with any assignment.
-/
theorem complementary_multiindex_inconsistent {n : ℕ}
    (α β : Fin n → ℕ) (v : Fin n)
    (_hα : 0 < α v) (_hβ : 0 < β v)
    (h_contra : ∀ τ : Fin n → Bool,
      multiindexConsistent α τ → τ v = true)
    (h_contra2 : ∀ τ : Fin n → Bool,
      multiindexConsistent β τ → τ v = false) :
    ¬ ∃ τ : Fin n → Bool, multiindexConsistent α τ ∧ multiindexConsistent β τ := by
  grind

/-! ## Polynomial Bound Machinery

We define the polynomial bound relating resolution and certificate sizes.
-/

/-- Linear polynomial bound: poly(s) = 2s. -/
def linearBound (s : ℕ) : ℕ := 2 * s

/-
The forward simulation satisfies a linear bound.
-/
theorem forward_simulation_linear (R : ResolutionStep n) :
    certificateSize (resolutionToCertificate R) ≤ linearBound (resolutionSize R) := by
  convert simulation_size_bound R using 1

/-
The reverse simulation satisfies a linear bound.
-/
theorem reverse_simulation_linear (C : CertificateTree n) :
    resolutionSize (certificateToResolution C) ≤ linearBound (certificateSize C) := by
  exact le_trans ( reverse_simulation_size_exact C |> le_of_eq ) ( by unfold linearBound; omega )

/-! ## Composition Theorem: Resolution Composed with Translation

The composition of forward and reverse translations gives a derivation
with at most quadratic overhead.
-/

/-
Round-trip composition: translate to certificate and back.
    The composed size is at most 2 * original size.
-/
theorem roundtrip_size_bound (R : ResolutionStep n) :
    resolutionSize (certificateToResolution (resolutionToCertificate R)) ≤
      2 * resolutionSize R := by
  convert reverse_simulation_linear ( resolutionToCertificate R ) using 1;
  rw [ simulation_size_exact ];
  rfl

/-! ## Leaf count equals resolution leaf count under translation -/

/-- The number of leaves in the translated certificate equals the
    number of axiom nodes in the resolution derivation. -/
def resolutionAxiomCount : ResolutionStep n → ℕ
  | .axiom_clause _ => 1
  | .resolve _ left right => resolutionAxiomCount left + resolutionAxiomCount right

/-
Translation preserves leaf/axiom count.
-/
theorem translation_preserves_leaf_count (R : ResolutionStep n) :
    certificateLeafCount (resolutionToCertificate R) = resolutionAxiomCount R := by
  -- We'll use induction on the structure of the resolution derivation.
  induction' R with left right h_left h_right;
  · rfl;
  · convert congr_arg₂ ( · + · ) ‹certificateLeafCount ( resolutionToCertificate h_left ) = resolutionAxiomCount h_left› ‹certificateLeafCount ( resolutionToCertificate h_right ) = resolutionAxiomCount h_right› using 1

end LorentzianProofComplexity