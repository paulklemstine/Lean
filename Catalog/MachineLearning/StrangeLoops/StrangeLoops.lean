import Mathlib

/-!
# Strange Loops: Self-Reference and Gödel's Incompleteness

## Overview

We formalize the abstract structure underlying Gödel's incompleteness theorems
and the phenomenon of "strange loops" — self-referential structures that arise
necessarily in any sufficiently powerful formal system.

## Mathematical Content

### Part I: Lawvere's Fixed-Point Theorem
The categorical core of ALL diagonal arguments. We prove: if there is a surjection
from A to (A → B), every endomorphism of B has a fixed point. Cantor's theorem
is an immediate corollary.

### Part II: Tarski's Undefinability via Self-Reference
The "meta-level diagonal lemma" (∀ P, ∃ g, Provable g ↔ P g) is inconsistent
with any consistent system. This is Tarski's undefinability of truth: no
consistent system can fully internalize its own truth predicate.

### Part III: Abstract Gödel Incompleteness
Using explicit Gödel sentence properties (rather than the overly strong diagonal
lemma), we prove that any system with a "self-refuting sentence" is necessarily
incomplete and contains independent sentences.

### Part IV: Provability Algebra Fixed Points
The algebraic structure of provability, and the existence of independent formulas.

### Novel Definitions
- `GoedelSentenceProperty`: The precise self-referential fixed-point condition
- `ProvabilityAlgebra`: Algebraic perspective on formal deducibility
- `StrangeLoopHierarchy`: Mathematical model of Hofstadter's tangled hierarchies
-/

open Function Set

-- ============================================================================
-- Part I: Lawvere's Fixed-Point Theorem
-- ============================================================================

/-- The diagonal map d(a) = t(repr(a)(a)), used in Lawvere's theorem -/
def lawvereDiag {A B : Type*} (repr : A → (A → B)) (t : B → B) : A → B :=
  fun a => t (repr a a)

/-
**Lawvere's Fixed-Point Theorem**: If there exists a surjection from A to (A → B),
then every endomorphism of B has a fixed point.

This single theorem unifies: Cantor's diagonal argument, Russell's paradox,
the halting problem, Gödel's incompleteness, and Tarski's undefinability.

*Proof*: Define d(a) = t(repr(a)(a)). By surjectivity of repr, there exists a₀
with repr(a₀) = d. Then repr(a₀)(a₀) = d(a₀) = t(repr(a₀)(a₀)),
so b := repr(a₀)(a₀) satisfies t(b) = b.
-/
theorem lawvere_fixed_point {A B : Type*} (repr : A → (A → B))
    (hsurj : Surjective repr) (t : B → B) :
    ∃ b, t b = b := by
  obtain ⟨ a₀, ha₀ ⟩ := hsurj ( t ∘ fun a => repr a a );
  exact ⟨ _, congr_fun ha₀ a₀ |> Eq.symm ⟩

/-
**Contrapositive of Lawvere**: If t has no fixed point, then the diagonal map
is not in the range of repr — hence repr cannot be surjective.
-/
theorem lawvere_diagonal_not_in_range {A B : Type*} (repr : A → (A → B)) (t : B → B)
    (ht : ∀ b, t b ≠ b) : lawvereDiag repr t ∉ range repr := by
  exact fun ⟨ a, ha ⟩ => ht _ ( by have := congr_fun ha a; unfold lawvereDiag at this; tauto )

/-
**Cantor's Theorem** (via Lawvere): No function from A to (A → Prop) is surjective.

*Proof*: Apply the contrapositive of Lawvere with t := Not. Since ¬p ≠ p for all p
(by `Iff.ne` applied to the impossibility of p ↔ ¬p), the diagonal map
d(a) = ¬f(a)(a) is not in the range of f.
-/
theorem cantor_diagonal (A : Type*) (f : A → (A → Prop)) : ¬ Surjective f := by
  intro h_surj;
  exact absurd ( lawvere_fixed_point f h_surj ( fun b => ¬b ) ) ( by rintro ⟨ b, hb ⟩ ; tauto )

/-
**No fixed point of negation in Prop**: ¬p = p is impossible for any proposition.
This is the specific instance of "fixed-point-freeness" used in Cantor's theorem.
-/
theorem not_has_no_fixed_point : ∀ p : Prop, (¬p) ≠ p := by
  grind

-- ============================================================================
-- Part II: Tarski's Undefinability via Self-Reference
-- ============================================================================

/-- A formal system with sentences, provability, and negation -/
structure FormalSystem where
  Sentence : Type
  Provable : Sentence → Prop
  neg : Sentence → Sentence

namespace FormalSystem

def Consistent (F : FormalSystem) : Prop :=
  ∀ s, ¬(F.Provable s ∧ F.Provable (F.neg s))

def Complete (F : FormalSystem) : Prop :=
  ∀ s, F.Provable s ∨ F.Provable (F.neg s)

def Independent (F : FormalSystem) (s : F.Sentence) : Prop :=
  ¬ F.Provable s ∧ ¬ F.Provable (F.neg s)

/-- The "meta-level diagonal lemma": for any property P on sentences,
there exists g with Provable(g) ↔ P(g). This is a very strong property
that, as we show, is incompatible with consistency. -/
def HasMetaDiagonal (F : FormalSystem) : Prop :=
  ∀ P : F.Sentence → Prop, ∃ g, F.Provable g ↔ P g

/-
**Tarski's Undefinability Theorem** (abstract version):
No system with the meta-diagonal property can be consistent.

This captures the essence of Tarski's result: a system that can fully
internalize self-reference at the meta-level cannot be consistent.
The "strange loop" of full self-reference destroys consistency.

*Proof*: Apply the meta-diagonal to P(s) := ¬Provable(s). Get g with
Provable(g) ↔ ¬Provable(g). This is a contradiction (iff_not_self).
-/
theorem tarski_meta_diagonal (F : FormalSystem)
    (hdiag : F.HasMetaDiagonal) : ¬ F.Consistent := by
  obtain ⟨ g, hg ⟩ := hdiag ( fun s => ¬F.Provable s );
  grind

end FormalSystem

-- ============================================================================
-- Part III: Abstract Gödel Incompleteness
-- ============================================================================

/-- The Gödel sentence property: a sentence G in a formal system such that:
1. If G is provable, then so is its negation (G is "self-refuting")
2. If ¬G is provable, then so is G (G is "self-affirming")

Property (1) alone (with consistency) gives ¬Provable(G).
Property (2) alone (with consistency) gives ¬Provable(¬G).
Together with consistency, G is independent.

In Gödel's proof:
- (1) comes from the fact that G says "I am not provable" — if G is provable,
  the system can derive that its Gödel number has no proof, i.e., ¬G.
- (2) comes from ω-consistency or Rosser's trick: if ¬G is provable, the
  system proves "G has a proof", and from the fixed point, G itself.

This structure IS the "strange loop": provability of G implies its refutation,
and refutation of G implies its proof. The system cannot consistently resolve
this self-reference, so G must be independent. -/
structure GoedelSentenceProperty (F : FormalSystem) where
  /-- The Gödel sentence -/
  G : F.Sentence
  /-- Self-refuting: proving G leads to proving ¬G -/
  self_refuting : F.Provable G → F.Provable (F.neg G)
  /-- Self-affirming: proving ¬G leads to proving G -/
  self_affirming : F.Provable (F.neg G) → F.Provable G

/-
**Gödel's First Incompleteness Theorem**: If a formal system has a Gödel
sentence and is consistent, then it is incomplete.

*Proof*: Suppose for contradiction that F is complete. Then for all s,
Provable(s) ∨ Provable(neg(s)). In particular, Provable(G) ∨ Provable(neg G).
- Case Provable(G): By self_refuting, Provable(neg G). So we have both
  Provable(G) and Provable(neg G), contradicting consistency.
- Case Provable(neg G): By self_affirming, Provable(G). Same contradiction.
-/
theorem goedel_incompleteness (F : FormalSystem)
    (gp : GoedelSentenceProperty F) (hcon : F.Consistent) :
    ¬ F.Complete := by
  by_contra h_complete
  have h_contradiction : F.Provable gp.G ∨ F.Provable (F.neg gp.G) := by
    exact h_complete gp.G;
  cases h_contradiction <;> have := gp.self_refuting <;> have := gp.self_affirming <;> aesop

/-
The Gödel sentence is not provable in a consistent system.

*Proof*: Suppose Provable(G). By self_refuting, Provable(neg G).
But consistency says ¬(Provable(G) ∧ Provable(neg G)). Contradiction.
-/
theorem goedel_not_provable (F : FormalSystem)
    (gp : GoedelSentenceProperty F) (hcon : F.Consistent) :
    ¬ F.Provable gp.G := by
  exact fun h => hcon _ ⟨ h, gp.self_refuting h ⟩

/-
The negation of the Gödel sentence is not provable in a consistent system.

*Proof*: Suppose Provable(neg G). By self_affirming, Provable(G).
Consistency gives contradiction.
-/
theorem goedel_neg_not_provable (F : FormalSystem)
    (gp : GoedelSentenceProperty F) (hcon : F.Consistent) :
    ¬ F.Provable (F.neg gp.G) := by
  exact fun h => hcon _ ⟨ gp.self_affirming h, h ⟩

/-
**The Gödel sentence is independent**: neither provable nor refutable.
This combines the two previous results.
-/
theorem goedel_independent (F : FormalSystem)
    (gp : GoedelSentenceProperty F) (hcon : F.Consistent) :
    F.Independent gp.G := by
  exact ⟨ goedel_not_provable F gp hcon, goedel_neg_not_provable F gp hcon ⟩

/-
**Essential Incompleteness**: For ANY consistent system that has a
Gödel sentence, incompleteness holds. There is no escape: adding axioms
(as long as the extended system still has a Gödel sentence and is consistent)
cannot close the gap.
-/
theorem essential_incompleteness (F : FormalSystem)
    (gp : GoedelSentenceProperty F) (hcon : F.Consistent) :
    ∃ s, F.Independent s := by
  exact ⟨ gp.G, goedel_independent F gp hcon ⟩

-- ============================================================================
-- Part IV: Provability Algebra Fixed Points
-- ============================================================================

/-- A provability algebra: the algebraic perspective on formal systems,
focusing on how provability interacts with logical operations -/
structure ProvabilityAlgebra where
  Formula : Type
  Prov : Formula → Prop
  neg : Formula → Formula
  prov_neg_sound : ∀ a, Prov a → Prov (neg a) → False

namespace ProvabilityAlgebra

/-- Consistency of a provability algebra -/
def Consistent (A : ProvabilityAlgebra) : Prop :=
  ∀ a, ¬(A.Prov a ∧ A.Prov (A.neg a))

/-
Consistency follows directly from the soundness axiom
-/
theorem consistent_of_sound (A : ProvabilityAlgebra) : A.Consistent := by
  exact fun a ha => A.prov_neg_sound a ha.1 ha.2

/-- A provability algebra with the Gödel fixed-point property -/
structure GoedelFP (A : ProvabilityAlgebra) where
  φ : A.Formula
  self_refuting : A.Prov φ → A.Prov (A.neg φ)
  self_affirming : A.Prov (A.neg φ) → A.Prov φ

/-
The Gödel formula is not provable
-/
theorem goedel_fp_not_prov (A : ProvabilityAlgebra) (gfp : GoedelFP A) :
    ¬ A.Prov gfp.φ := by
  exact fun h => A.prov_neg_sound _ h ( gfp.self_refuting h )

/-
The negation of the Gödel formula is not provable
-/
theorem goedel_fp_neg_not_prov (A : ProvabilityAlgebra) (gfp : GoedelFP A) :
    ¬ A.Prov (A.neg gfp.φ) := by
  intro h;
  exact A.prov_neg_sound _ ( gfp.self_affirming h ) h

end ProvabilityAlgebra

-- ============================================================================
-- Part V: Strange Loop Hierarchy
-- ============================================================================

/-- A strange loop hierarchy: a system of levels where the self-map at a
distinguished level has a fixed point — the "loop" that "refers to itself." -/
structure StrangeLoopHierarchy where
  Level : Type
  Content : Level → Type
  selfLevel : Level
  selfMap : Content selfLevel → Content selfLevel
  loop : Content selfLevel
  loop_fixed : selfMap loop = loop

/-- **Connection theorem**: Lawvere's theorem implies that any "universal"
strange loop hierarchy (one that can represent all endomorphisms) necessarily
has fixed points at every level.

More precisely: if repr : A → (A → Content l) is surjective for some level l,
then every endomorphism of Content l has a fixed point. -/
theorem strange_loop_from_lawvere {A : Type*} {B : Type*}
    (repr : A → (A → B)) (hsurj : Surjective repr) (f : B → B) :
    ∃ b : B, f b = b := by
  exact lawvere_fixed_point repr hsurj f

-- ============================================================================
-- Part VI: Conjecture and Testable Prediction
-- ============================================================================

/-- **Conjecture (Independence Pervasiveness)**: In any finite system with n
sentences and a Gödel sentence, at least 1 sentence is independent. More
ambitiously, we conjecture that in "generic" consistent theories over n
sentences with the Gödel property, the fraction of independent sentences
grows. This is testable by enumerating finite consistent theories. -/
noncomputable def independence_count_lower_bound
    (F : FormalSystem) (_gp : GoedelSentenceProperty F) (_hcon : F.Consistent) : ℕ := 1