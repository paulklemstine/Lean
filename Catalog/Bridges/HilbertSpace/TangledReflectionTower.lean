import Logic.PhysicsConsistency.Incompleteness
import Logic.ProofSystemCollapse

/-!
# Consistency Reflection Strictly Raises Proof-Theoretic Strength

A consistency-reflection step adjoins to a proof system its own object-language
consistency sentence. This connects the Hilbert–Bernays–Löb analysis of
self-reference with the simulation preorder on proof systems.

The central result says that reflection is a genuine strict ascent: the reflected
system simulates the original, but no consistent GL theory can simulate its own
reflection. Iterating reflection with fresh tags produces a finite hierarchy whose
later levels simulate earlier ones, while no later level can be translated back to
a consistent GL level below it.
-/

namespace TangledReflectionTower

open ProofSystemCollapse
open PhysicsConsistency PhysicsConsistency.Form

/-- Adjoin the consistency sentence for tag `i` as a new axiom. -/
def reflectConsistency (i : ℕ) (S : ProofSys Form) : ProofSys Form :=
  union S (singletonSys (Con i))

/-- Every theory is simulated by its consistency-reflection extension. -/
theorem reflection_simulates_base (i : ℕ) (S : ProofSys Form) :
    Simulates (reflectConsistency i S) S := by
  convert union_simulates_left S (singletonSys (Con i)) using 1

/-- A theory simulates its consistency-reflection extension exactly when it already
proves its own consistency sentence. -/
theorem simulates_reflection_iff_proves_consistency (i : ℕ) (S : ProofSys Form) :
    Simulates S (reflectConsistency i S) ↔ Provable S (Con i) := by
  constructor
  · intro h
    exact h _ ⟨Sum.inr (), rfl⟩
  · intro h f hf
    obtain ⟨p, hp⟩ := hf
    cases p with
    | inl p => exact ⟨p, hp⟩
    | inr p =>
      cases p
      simp [reflectConsistency, singletonSys] at hp
      subst f
      exact h

/-- **Strict consistency reflection.** For a consistent GL theory, adjoining its
own consistency sentence strictly increases strength in the simulation preorder. -/
theorem consistency_reflection_strict {i : ℕ} {S : ProofSys Form}
    (hGL : IsGLTheory i S) (hc : Consistent S) :
    Simulates (reflectConsistency i S) S ∧
      ¬ Simulates S (reflectConsistency i S) := by
  refine ⟨reflection_simulates_base i S, ?_⟩
  intro h
  exact goedel_two hGL hc ((simulates_reflection_iff_proves_consistency i S).mp h)

/-- A consistency-reflection edge cannot lie on a simulation cycle. Any system
above the reflected theory is therefore not simulated by the base theory. -/
theorem no_simulation_cycle_through_reflection {i : ℕ} {S T : ProofSys Form}
    (hGL : IsGLTheory i S) (hc : Consistent S)
    (hup : Simulates T (reflectConsistency i S)) : ¬ Simulates S T := by
  intro hdown
  exact (consistency_reflection_strict hGL hc).2 (simulates_trans hdown hup)

/-- The strictness survives the quantitative refinement: there is no polynomial
translation of reflected proofs back into a consistent GL base theory. -/
theorem no_polynomial_collapse_of_reflection {i : ℕ} {S : ProofSys Form}
    (hGL : IsGLTheory i S) (hc : Consistent S) :
    ¬ PSimulates S (reflectConsistency i S) := by
  intro h
  exact (consistency_reflection_strict hGL hc).2 (psim_implies_simulates h)

/-- The standard converse-well-founded Kripke theory gives a concrete non-vacuity
witness: every tagged consistency-reflection step over it is strict. -/
theorem standard_model_reflection_strict (i : ℕ) :
    Simulates (reflectConsistency i stdSys) stdSys ∧
      ¬ Simulates stdSys (reflectConsistency i stdSys) := by
  exact consistency_reflection_strict (isGL_stdSys i) consistent_stdSys

/-- The finite reflection tower over `S`; stage `n+1` adjoins the stage-`n`
consistency sentence, using `n` as its fresh provability tag. -/
def reflectionTower (S : ProofSys Form) : ℕ → ProofSys Form
  | 0 => S
  | n + 1 => reflectConsistency n (reflectionTower S n)

/-- Every successor stage simulates its predecessor. -/
theorem reflectionTower_step (S : ProofSys Form) (n : ℕ) :
    Simulates (reflectionTower S (n + 1)) (reflectionTower S n) := by
  exact reflection_simulates_base _ _

/-- Later stages of the tower simulate all earlier stages. -/
theorem reflectionTower_mono (S : ProofSys Form) {m n : ℕ} (hmn : m ≤ n) :
    Simulates (reflectionTower S n) (reflectionTower S m) := by
  induction' hmn with n hmn ih
  · exact simulates_refl (reflectionTower S m)
  · exact simulates_trans (reflectionTower_step S n) ih

/-- **No collapse across a reflection tower.** If stage `m` is a consistent GL
system for its own tag, then no strictly later stage can be simulated by stage `m`,
even though every later stage simulates stage `m`. -/
theorem reflectionTower_strict {S : ProofSys Form} {m n : ℕ} (hmn : m < n)
    (hGL : IsGLTheory m (reflectionTower S m))
    (hc : Consistent (reflectionTower S m)) :
    Simulates (reflectionTower S n) (reflectionTower S m) ∧
      ¬ Simulates (reflectionTower S m) (reflectionTower S n) := by
  refine ⟨reflectionTower_mono S hmn.le, ?_⟩
  apply no_simulation_cycle_through_reflection hGL hc
  exact reflectionTower_mono S (Nat.succ_le_of_lt hmn)

end TangledReflectionTower
-- !-- Lab Notes -- !--
--
-- Hypothesis:
--   Adding a system's own consistency sentence should be a strict ascent in the
--   proof-system simulation order, and iterated reflection should form an acyclic
--   hierarchy whenever each lower stage satisfies its local GL conditions.
--
-- Experiment:
--   Consistency reflection was represented as the lattice join of the base system
--   with the singleton system containing `Con i`. The join laws give upward
--   simulation, while singleton duality identifies downward simulation with a proof
--   of `Con i`. Induction then composes adjacent simulations along a finite tower.
--
-- Analysis:
--   Collapse of one reflection step is exactly provability of the consistency
--   sentence. Thus Löb's theorem becomes a strict-order theorem. For nonadjacent
--   levels, monotonicity transports any alleged downward simulation to the first
--   reflection edge, where second incompleteness refutes it.
--
-- Critique:
--   Consistency and the local GL hypothesis are essential. An inconsistent theory
--   can prove its consistency sentence and collapse the step. The standard Kripke
--   system witnesses non-vacuity. Fresh tags are essential too: repeatedly adjoining
--   one fixed sentence would stabilize after the first stage rather than form a
--   genuine tower.
--
-- Synthesis:
--   Consistency reflection creates acyclic strict edges in proof-theoretic strength.
--   The finite tower theorem is the structural seed for ordinal-indexed reflection:
--   limit stages should be joins, while successor strictness remains governed by
--   local instances of second incompleteness.
-- !-- Lab Notes -- !--