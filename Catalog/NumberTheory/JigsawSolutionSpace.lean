import Mathlib
import Catalog.Novelty.JigsawNPComplete

/-!
# Jigsaw Solution Spaces: Parsimony and Complement Symmetry

The satisfiability–assembly correspondence is strengthened from mere existence to
an equivalence of complete solution spaces.  For a fixed finite variable set,
assembly recipes and satisfying assignments are in bijection; consequently the
reduction preserves the exact number of solutions and uniqueness.  A second
bijection globally complements every truth value and every literal polarity.
On puzzle edges this is the tab–blank involution, connecting logical negation to
the order-two symmetry of interlocking pieces.
-/

namespace Jigsaw

/-- Extend an assignment on `Fin n` to all natural variable indices, assigning
`false` outside the declared variable set. -/
def extendAssignment (n : ℕ) (a : Fin n → Bool) : Assignment :=
  fun i => if h : i < n then a ⟨i, h⟩ else false

/-- Finite satisfying assignments for a formula whose declared variable set has
size `n`. -/
def FiniteSatisfyingAssignments (n : ℕ) (F : Formula) :=
  {a : Fin n → Bool // F.Sat (extendAssignment n a)}

/-- Finite assembly recipes for the puzzle constructed from `F`. -/
def FiniteAssemblyRecipes (n : ℕ) (F : Formula) :=
  {a : Fin n → Bool // PuzzleAssembled F (extendAssignment n a)}

instance finiteSatisfyingAssignmentsFinite (n : ℕ) (F : Formula) :
    Finite (FiniteSatisfyingAssignments n F) :=
  Finite.of_injective Subtype.val Subtype.val_injective

instance finiteAssemblyRecipesFinite (n : ℕ) (F : Formula) :
    Finite (FiniteAssemblyRecipes n F) :=
  Finite.of_injective Subtype.val Subtype.val_injective

noncomputable instance finiteSatisfyingAssignmentsFintype (n : ℕ) (F : Formula) :
    Fintype (FiniteSatisfyingAssignments n F) := Fintype.ofFinite _

noncomputable instance finiteAssemblyRecipesFintype (n : ℕ) (F : Formula) :
    Fintype (FiniteAssemblyRecipes n F) := Fintype.ofFinite _

/-- **Parsimonious correspondence.** Assembly recipes are in canonical bijection
with satisfying assignments, not merely equisatisfiable with them. -/
def assemblyRecipeEquiv (n : ℕ) (F : Formula) :
    FiniteAssemblyRecipes n F ≃ FiniteSatisfyingAssignments n F where
  toFun x := ⟨x.1, by
    intro c hc
    exact (clausePieceFits_iff (extendAssignment n x.1) c).1 (x.2 c hc)⟩
  invFun x := ⟨x.1, by
    intro c hc
    exact (clausePieceFits_iff (extendAssignment n x.1) c).2 (x.2 c hc)⟩
  left_inv x := by cases x; rfl
  right_inv x := by cases x; rfl

/-- The reduction preserves the exact number of solutions. -/
theorem assemblyRecipe_card_eq (n : ℕ) (F : Formula) :
    Fintype.card (FiniteAssemblyRecipes n F) =
      Fintype.card (FiniteSatisfyingAssignments n F) := by
  exact Fintype.card_congr ( assemblyRecipeEquiv n F )

/-- In particular, a constructed puzzle has a unique finite assembly recipe iff
its formula has a unique satisfying assignment. -/
theorem unique_assembly_iff_unique_satisfying (n : ℕ) (F : Formula) :
    Nonempty (Unique (FiniteAssemblyRecipes n F)) ↔
      Nonempty (Unique (FiniteSatisfyingAssignments n F)) := by
  unfold FiniteAssemblyRecipes FiniteSatisfyingAssignments;
  constructor <;> intro h;
  · convert h using 1;
    congr! 2;
    ext; simp [PuzzleAssembled];
    simp +decide [ Formula.Sat, clausePieceFits_iff ];
  · convert h using 1;
    congr!;
    exact ⟨ fun h => by
      exact fun c hc => ( clausePieceFits_iff ( extendAssignment n _ ) c ).1 ( h c hc ), fun h => by
      exact fun c hc => ( clausePieceFits_iff _ _ ).2 ( h c hc ) ⟩

/-- Complement every literal polarity in a clause. -/
def complementClause (c : Clause) : Clause := c.map fun ℓ => (ℓ.1, !ℓ.2)

/-- Complement every literal polarity in a formula. -/
def complementFormula (F : Formula) : Formula := F.map complementClause

/-- Complement every value of an assignment. -/
def complementAssignment (a : Assignment) : Assignment := fun i => !a i

/-- Literal satisfaction is invariant under simultaneously complementing the
assignment and the literal polarity. -/
lemma litSat_complement (a : Assignment) (ℓ : Literal) :
    litSat (complementAssignment a) (ℓ.1, !ℓ.2) ↔ litSat a ℓ := by
  constructor <;> intro h <;> simp_all +decide [ litSat, complementAssignment ]

/-- Clause satisfaction is transported by global complementation. -/
lemma clauseSat_complement (a : Assignment) (c : Clause) :
    clauseSat (complementAssignment a) (complementClause c) ↔ clauseSat a c := by
  constructor <;> intro h <;> rcases h with ⟨ ℓ, h₁, h₂ ⟩ <;> simp_all +decide [clauseSat, complementClause];
  · rcases h₁ with ⟨ a, h₁ | h₁ ⟩ <;> simp_all +decide [ litSat, complementAssignment ]; all_goals grind;
  · cases h : ℓ.2 <;> simp_all +decide [ litSat, complementAssignment ]; all_goals grind

/-- Formula satisfaction is transported by global complementation. -/
theorem formulaSat_complement (a : Assignment) (F : Formula) :
    (complementFormula F).Sat (complementAssignment a) ↔ F.Sat a := by
  unfold Formula.Sat complementFormula;
  simp +decide [ clauseSat_complement ]

/-- **Tab–blank symmetry of solvability.** Globally swapping truth values and
literal polarities preserves puzzle solvability. -/
theorem puzzleSolvable_complement (F : Formula) :
    PuzzleSolvable (complementFormula F) ↔ PuzzleSolvable F := by
  -- Apply the equivalence from puzzle_solvable_iff_satisfiable to both sides.
  have h_equiv : PuzzleSolvable (complementFormula F) ↔ (complementFormula F).Satisfiable :=
    puzzle_solvable_iff_satisfiable (complementFormula F)
  convert h_equiv using 1;
  convert puzzle_solvable_iff_satisfiable F using 1;
  constructor <;> rintro ⟨ a, ha ⟩;
  · use complementAssignment a;
    convert formulaSat_complement ( complementAssignment a ) F |>.1 _ using 1;
    convert ha using 1;
    exact funext fun x => by simp +decide [ complementAssignment ] ;
  · exact ⟨ complementAssignment a, formulaSat_complement a F |>.2 ha ⟩

/-! ## Concrete experiment -/

/-- The zero-based instance `(x₀ ∨ x₁ ∨ ¬x₂) ∧ (¬x₀ ∨ x₂)`. -/
def smallFormula : Formula :=
  [[(0, true), (1, true), (2, false)], [(0, false), (2, true)]]

/-- A concrete assignment satisfies the running instance. -/
example : smallFormula.Sat (extendAssignment 3 (fun i => i = 1)) := by
  intro c hc
  simp only [smallFormula, List.mem_cons, List.not_mem_nil, or_false] at hc
  rcases hc with rfl | rfl
  · exact ⟨(1, true), by simp, by simp [litSat, extendAssignment]⟩
  · exact ⟨(0, false), by simp, by simp [litSat, extendAssignment]⟩

/-- The same assignment gives an assembly recipe for the constructed puzzle. -/
example : PuzzleAssembled smallFormula (extendAssignment 3 (fun i => i = 1)) := by
  intro c hc
  apply (clausePieceFits_iff (extendAssignment 3 (fun i => i = 1)) c).2
  simp only [smallFormula, List.mem_cons, List.not_mem_nil, or_false] at hc
  rcases hc with rfl | rfl
  · exact ⟨(1, true), by simp, by simp [litSat, extendAssignment]⟩
  · exact ⟨(0, false), by simp, by simp [litSat, extendAssignment]⟩

#check assemblyRecipeEquiv
#check assemblyRecipe_card_eq
#check puzzleSolvable_complement
#eval (allPieces 3 smallFormula).length

/-!
-- !-- Lab Notes -- !--

**Hypothesis.** Six falsifiable targets were ranked by expected impact:
(1) unrestricted geometric jigsaw assembly is NP-complete under a polynomial
encoding; (2) the formula-to-puzzle map is parsimonious and therefore transfers
counting complexity; (3) global tab–blank complementation induces a free
order-two action on non-self-dual solution spaces; (4) uniqueness of assembly is
exactly unique satisfiability; (5) planar gadget realizations preserve the
homotopy type of an associated solution complex; and (6) boundary potential
classes obstruct assembly on surfaces with nontrivial first homology.  Targets
(1), (3), (5), and (6) are deliberately broader conjectures.  This cycle tests
the exact witness correspondence underlying (2), proves (4) for the abstract
construction, and establishes the solvability symmetry needed for (3).

**Experiment.** The full witness types were defined for a finite variable set.
The canonical witness map was tested in both directions, and an explicit
three-variable satisfying assignment was transported to an assembly recipe; the
piece-count calculation evaluates to ten.  Simultaneously negating assignments
and literal polarities was then propagated from literals through clauses and
formulas.

**Analysis.** The local lemma `clausePieceFits_iff` from the preceding reduction
is stronger than needed for decision hardness: it preserves the assignment
itself.  This yields a parsimonious reduction and transfers exact counting and
uniqueness.  Complement symmetry acts coherently at three levels: Boolean values,
edge shapes, and the entire solution space.

**Critique.** Conjectures (1), (5), and (6) remain true-or-false open targets in
this model; no geometric gadget, solution complex, or surface embedding is
constructed here.  The result does not establish NP-completeness for unrestricted
geometric jigsaw puzzles.  The inherited construction models a formula-indexed
assembly predicate, and a full complexity theorem still requires a polynomial
encoding of geometry, rotations, locations, and certificates.  The cardinality
theorem is not a finite brute-force calculation: it follows from a general
bijection.  The broader claim in (3) needs a boundary condition excluding
self-dual formulas; only invariance of solvability is proved.  Variables outside
`Fin n` are fixed to false, making this limit case explicit.

**Synthesis.** Existence, uniqueness, and exact witness counts are all preserved
by one canonical solution-space equivalence.  A second, order-two transport
explains why global tab–blank reversal leaves solvability unchanged.  This gives
a broader bridge among parsimonious complexity reductions, finite combinatorics,
and involutive edge symmetry.
-/

end Jigsaw