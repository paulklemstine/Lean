import Mathlib
import Computation.Computation.SelfModifyingHalt

/-!
# Hypercomputation, Diagonal Oracles, and Physical Resolution

This chapter separates two notions that are often conflated.  A predicate is
*essentially computable* relative to an explicitly given enumeration when it is
represented by one of the enumerated programs.  It is *accidentally computable*
when an external oracle simply supplies its values.  The anti-diagonal predicate
is available to an oracle machine in one query, but it is absent from every row
of the original enumeration.

The physical part is deliberately conditional and information-theoretic.  Rather
than asserting an unmotivated law relating energy to computation, it isolates a
precise obstruction: a system that can be programmed with every infinite binary
oracle, with exact recovery, must have infinitely many distinguishable physical
states.  Consequently no finite-capacity (finite-energy-density or finite-precision)
model can implement universal exact oracle loading.
-/

namespace Hypercomputation

/-- A program table assigns to each program code its Boolean input-output behavior. -/
abbrev ProgramTable := ℕ → ℕ → Bool

/-- Predicates represented by a row of a specified program table are essentially computable. -/
def EssentiallyComputable (table : ProgramTable) (p : ℕ → Bool) : Prop :=
  ∃ code, table code = p

/-- An oracle is an external source of answers, without a claim that its behavior is a table row. -/
structure PhysicalOracle where
  answer : ℕ → Bool

/-- Oracle evaluation: one query returns the externally supplied answer. -/
def oracleEval (oracle : PhysicalOracle) (input : ℕ) : Bool := oracle.answer input

/-- The anti-diagonal predicate associated with a program table. -/
def antiDiagonal (table : ProgramTable) : ℕ → Bool :=
  fun code => !(table code code)

/-
The anti-diagonal predicate differs from every represented program at that program's own code.
-/
theorem antiDiagonal_differs_at_code (table : ProgramTable) (code : ℕ) :
    table code code ≠ antiDiagonal table code := by
      unfold antiDiagonal; aesop;

/-
Diagonal obstruction: the anti-diagonal predicate is not essentially computable.
-/
theorem antiDiagonal_not_essential (table : ProgramTable) :
    ¬ EssentiallyComputable table (antiDiagonal table) := by
      exact fun ⟨ code, h ⟩ => antiDiagonal_differs_at_code table code <| h ▸ rfl

/-
Nevertheless, loading the anti-diagonal as a physical oracle evaluates it exactly in one query.
-/
theorem antiDiagonal_accidentally_computable (table : ProgramTable) :
    ∃ oracle : PhysicalOracle, ∀ input,
      oracleEval oracle input = antiDiagonal table input := by
        exact ⟨ ⟨ fun input => antiDiagonal table input ⟩, fun input => rfl ⟩

/-
Accidental oracle availability therefore strictly exceeds representation by the original table.
-/
theorem accidental_not_essential (table : ProgramTable) :
    ∃ oracle : PhysicalOracle,
      (∀ input, oracleEval oracle input = antiDiagonal table input) ∧
      ¬ EssentiallyComputable table oracle.answer := by
        exact ⟨ ⟨ antiDiagonal table ⟩, fun _ => rfl, antiDiagonal_not_essential table ⟩

/-! ## A halting oracle over the catalog's machine semantics -/

/-- Classical characteristic oracle for a proposition-valued predicate.  This is a
semantic specification, not an algorithm for obtaining its answers. -/
noncomputable def propositionOracle (predicate : ℕ → Prop) : PhysicalOracle where
  answer input := @ite Bool (predicate input) (Classical.dec _) true false

/-
The characteristic oracle answers `true` exactly on the specified predicate.
-/
theorem propositionOracle_spec (predicate : ℕ → Prop) (input : ℕ) :
    oracleEval (propositionOracle predicate) input = true ↔ predicate input := by
      unfold oracleEval propositionOracle; aesop;

/-
An oracle loaded with a standard machine's halting predicate answers the halting
question exactly.
-/
theorem halting_oracle_solves (machine : SelfModHalt.StdMachine ℕ) :
    ∃ oracle : PhysicalOracle, ∀ input,
      oracleEval oracle input = true ↔ machine.halts input := by
  exact ⟨propositionOracle machine.halts, propositionOracle_spec machine.halts⟩

/-
If no row of a program table decides a machine's halting predicate, its exact
halting oracle is accidentally available but not essentially computable in that table.
-/
theorem halting_oracle_separates
    (table : ProgramTable) (machine : SelfModHalt.StdMachine ℕ)
    (undecidable : ∀ decider : ℕ → Bool,
      ¬ SelfModHalt.StdHaltingDecider machine decider) :
    ∃ oracle : PhysicalOracle,
      (∀ input, oracleEval oracle input = true ↔ machine.halts input) ∧
      ¬ EssentiallyComputable table oracle.answer := by
        contrapose! undecidable;
        exact ⟨ _, fun n => propositionOracle_spec _ _ ⟩

/-! ## Exact physical loading and precision -/

/-- A physical loader stores arbitrary binary oracles in states and reads their bits back. -/
structure ExactOracleLoader (State : Type*) where
  load : (ℕ → Bool) → State
  read : State → ℕ → Bool
  exact : ∀ oracle input, read (load oracle) input = oracle input

/-
Exact recovery forces the loading map to be injective.
-/
theorem ExactOracleLoader.load_injective {State : Type*}
    (device : ExactOracleLoader State) : Function.Injective device.load := by
      intro oracle1 oracle2 h_eq;
      ext n; have := device.exact oracle1 n; have := device.exact oracle2 n; aesop;

/-
The space of infinite binary oracles is infinite.
-/
theorem infinite_binary_oracles : Infinite (ℕ → Bool) := by
  exact Infinite.of_injective ( fun n => fun m => if m = n then Bool.true else Bool.false ) fun a b hab => by replace hab := congr_fun hab a; aesop;

/-
A universal exact oracle loader requires infinitely many distinguishable states.
-/
theorem exact_loader_requires_infinite_precision {State : Type*}
    (device : ExactOracleLoader State) : Infinite State := by
      exact Infinite.of_injective _ device.load_injective

/-
No finite-capacity physical state space can load every oracle exactly.
-/
theorem no_finite_exact_oracle_loader (State : Type*) [Finite State] :
    IsEmpty (ExactOracleLoader State) := by
      constructor;
      intro device
      have := exact_loader_requires_infinite_precision device
      exact (by
      exact this.false)

/-
A finite energy-density model, expressed by finite distinguishable-state capacity,
precludes a universal exact oracle loader.
-/
theorem finite_energy_density_obstruction
    (State : Type*) (finiteEnergyDensity : Finite State) :
    IsEmpty (ExactOracleLoader State) := by
  letI : Finite State := finiteEnergyDensity
  exact no_finite_exact_oracle_loader State

/-- A resource interpretation records two independently finite regimes and the
physical assertion that either regime bounds distinguishable-state capacity. -/
structure ResourceInterpretation (State : Type*) where
  LowEnergyDensity : Prop
  FinitePrecision : Prop
  lowEnergy_finite : LowEnergyDensity → Finite State
  finitePrecision_finite : FinitePrecision → Finite State

/-
Under an explicit finite-capacity resource interpretation, exact universal oracle
loading requires both unbounded energy density and unbounded precision.
-/
theorem exact_loader_requires_unbounded_resources {State : Type*}
    (resources : ResourceInterpretation State) (device : ExactOracleLoader State) :
    ¬ resources.LowEnergyDensity ∧ ¬ resources.FinitePrecision := by
      constructor;
      · exact fun h => by have := resources.lowEnergy_finite h; exact exact_loader_requires_infinite_precision device |> fun h => h.false;
      · intro h;
        convert Hypercomputation.exact_loader_requires_infinite_precision device;
        simp +decide [ resources.finitePrecision_finite h ]

/-
In particular, every exact loader violates the disjunction “finite energy density
or finite precision”; both proposed finite-resource implementations are excluded.
-/
theorem exact_loader_infinite_energy_and_precision {State : Type*}
    (resources : ResourceInterpretation State) (device : ExactOracleLoader State) :
    ¬ (resources.LowEnergyDensity ∨ resources.FinitePrecision) := by
      exact not_or.mpr ( exact_loader_requires_unbounded_resources resources device )

/-! ## Finite observations cannot certify an infinite oracle -/

/-
Flipping a bit outside a finite transcript produces a distinct oracle with the same transcript.
-/
theorem finite_transcript_ambiguity (oracle : ℕ → Bool) (queries : Finset ℕ) :
    ∃ rival : ℕ → Bool,
      (∀ q ∈ queries, rival q = oracle q) ∧ rival ≠ oracle := by
        obtain ⟨q, hq⟩ : ∃ q : ℕ, q ∉ queries := by
          exact Finset.exists_notMem queries;
        exact ⟨ fun n => if n = q then !oracle q else oracle n, fun n hn => by aesop, fun h => by have := congr_fun h q; aesop ⟩

/-
No finite set of observations uniquely identifies every infinite binary oracle.
-/
theorem no_finite_observation_identification (queries : Finset ℕ) :
    ¬ ∀ oracle rival : ℕ → Bool,
      (∀ q ∈ queries, oracle q = rival q) → oracle = rival := by
        by_contra! h_contra;
        exact absurd ( finite_transcript_ambiguity ( fun _ => Bool.true ) queries ) ( by tauto )

/-! ## Cross-domain synthesis: diagonalization plus physical capacity -/

/-
Any device that exactly loads the anti-diagonal oracle computes answers outside the
original table, while a device universal for all such tables cannot have finite capacity.
-/
theorem hypercomputation_dichotomy (table : ProgramTable)
    {State : Type*} (device : ExactOracleLoader State) :
    (¬ EssentiallyComputable table (device.read (device.load (antiDiagonal table)))) ∧
    Infinite State := by
      refine' ⟨ _, _ ⟩;
      · rw [ show device.read ( device.load ( antiDiagonal table ) ) = antiDiagonal table from funext fun x => device.exact _ _ ] ; exact antiDiagonal_not_essential table;
      · exact exact_loader_requires_infinite_precision device

-- !-- Lab Notes -- !--
-- Hypothesis: Oracle access can solve a table's diagonal problem, but exact universal
-- oracle loading must cross an information-capacity boundary.
-- Experiment: The anti-diagonal was tested against an arbitrary row at its own index;
-- exact loaders were then analyzed through their load/read retraction.
-- Analysis: Two independent obstructions survive.  Diagonalization separates external
-- availability from representation, while the retraction forces an injection from all
-- bitstreams into physical states.  Finite transcripts also leave an unqueried bit free.
-- Critique: “Infinite energy density” is not derived from mathematics alone.  The valid
-- theorem uses the explicit bridge assumption that bounded energy density entails only
-- finitely many distinguishable states.  Infinite state cardinality means infinite exact
-- precision/capacity, not necessarily infinite total energy under every physical theory.
-- Synthesis: A rigorous hypercomputer is an oracle evaluator; its extra power resides in
-- the oracle-loading premise.  The diagonal oracle lies beyond the chosen program table,
-- and universal exact loading is incompatible with finite physical capacity.
-- !-- End Lab Notes -- !--

end Hypercomputation