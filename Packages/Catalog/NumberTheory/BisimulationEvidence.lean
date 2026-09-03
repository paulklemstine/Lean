import NumberTheory.BisimulationCollapseThreshold

/-!
# Computational evidence for the bisimulation/isomorphism resolution files

This file contains no theorems: it is the reproducible evidence script behind
`ComputationalEvidence.md`.  It enumerates all modal formulas over one atom and one
tag built in `k` layers (`2, 8, 80, 6560` formulas for `k = 0, 1, 2, 3`) and counts how
many of them separate the witness pairs of
`NumberTheory.BisimulationMultiplicityGap` and
`NumberTheory.BisimulationBeyondMultiplicity`.  The counts are `0` for both witness
pairs and `90` for the two controls, matching the proved theorems.  The `#print axioms`
checks confirm that the main results use only `propext`, `Classical.choice` and
`Quot.sound`.
-/

open PhysicsConsistency ProofSystemCollapse Form Bisim MultGap Beyond

/-- All formulas over the single atom `0` and the single tag `0`, built in `k` layers. -/
def allForms : ℕ → List Form
  | 0 => [bot, atom 0]
  | k + 1 =>
      let prev := allForms k
      prev ++ (prev.flatMap fun a => prev.map fun b => imp a b) ++ prev.map (box 0)

def sepCount (R : ℕ → ℕ → ℕ → Bool) (V : ℕ → ℕ → Bool) (R' : ℕ → ℕ → ℕ → Bool)
    (V' : ℕ → ℕ → Bool) (m n k : ℕ) : ℕ :=
  ((allForms k).filter fun a => satF R V m a != satF R' V' n a).length

#eval (allForms 0).length
#eval (allForms 1).length
#eval (allForms 2).length
#eval (allForms 3).length

-- multiplicity witness: worlds 3 and 4 of `multR` (out-degrees 2 and 1)
#eval sepCount multR multV multR multV 3 4 3
-- sharing witness: root 5 of the shared diamond versus root 5 of its unravelling
#eval sepCount shareR shV treeR shV 5 5 3
-- control: the chain worlds 1 and 2 are separated by many formulas
#eval sepCount Hierarchy.chainR Hierarchy.chainV Hierarchy.chainR Hierarchy.chainV 1 2 3
-- control: worlds 3 and 5 of `multR` (different behaviour) are separated
#eval sepCount multR multV multR multV 3 1 3
-- out-degrees
#eval (outDeg multR 0 3, outDeg multR 0 4)
#eval (outDeg shareR 0 5, outDeg treeR 0 5, outDeg shareR 0 3, outDeg treeR 0 4)

#print axioms Bisim.bisimilar_iff_modEq
#print axioms Bisim.modalInvariant_iff_bisimInvariant
#print axioms MultGap.multiplicity_gap
#print axioms Hierarchy.full_resolution_hierarchy
#print axioms Beyond.multiplicity_does_not_close_the_gap
#print axioms Beyond.two_step_ladder
#print axioms TheoryTransfer.glTheory_cannot_detect_sharing
#print axioms Budget.nominal_budget_threshold
#print axioms Collapse.collapse_threshold_sharp