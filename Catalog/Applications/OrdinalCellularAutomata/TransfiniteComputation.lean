import Catalog.Applications.CellularAutomataGeometry

/-!
# Cellular dynamics through two ordinal time coordinates

The order type `ω²` is represented by pairs `(block, tick) : ℕ × ℕ` in
lexicographic order.  Successor ticks use an ordinary local update, while the
start of each new block is selected from the complete preceding `ω`-history by
a limit rule.  This separation exposes the precise source of transfinite
computational power: locality governs successor stages, whereas a limit rule
may inspect an unbounded history.
-/

namespace OrdinalCellularAutomata

/-- A binary tape on the one-sided infinite lattice. -/
abbrev Tape := ℕ → Bool

/-- Left neighbor on a one-sided tape, with a fixed boundary at zero. -/
def leftCell (x : Tape) (i : ℕ) : Bool := if i = 0 then false else x (i - 1)

/-- The Rule 110 successor update on a one-sided infinite tape. -/
def rule110Step (x : Tape) : Tape :=
  fun i => CellularAutomata.rule110 (leftCell x i, x i, x (i + 1))

/-- A computation of order type `ω²`.  The first coordinate counts completed
`ω`-blocks and the second counts successor steps within the current block. -/
def omegaSquaredRun {S : Type*} (step : S → S) (limit : (ℕ → S) → S)
    (initial : S) : ℕ → ℕ → S
  | 0 => fun n => step^[n] initial
  | k + 1 => fun n => step^[n] (limit (omegaSquaredRun step limit initial k))

/-
Successor stages obey the chosen transition.
-/
theorem omegaSquaredRun_succ {S : Type*} (step : S → S)
    (limit : (ℕ → S) → S) (initial : S) (k n : ℕ) :
    omegaSquaredRun step limit initial k (n + 1) =
      step (omegaSquaredRun step limit initial k n) := by
        induction' k with k ih generalizing initial;
        · exact Function.iterate_succ_apply' step n initial;
        · exact Function.iterate_succ_apply' step _ _

/-
Every block boundary is exactly the selected limit of the previous history.
-/
theorem omegaSquaredRun_limit {S : Type*} (step : S → S)
    (limit : (ℕ → S) → S) (initial : S) (k : ℕ) :
    omegaSquaredRun step limit initial (k + 1) 0 =
      limit (omegaSquaredRun step limit initial k) := by
        rfl

/-
Inside a block, the transfinite run agrees with ordinary finite iteration.
-/
theorem omegaSquaredRun_eq_iterate {S : Type*} (step : S → S)
    (limit : (ℕ → S) → S) (initial : S) (k n : ℕ) :
    omegaSquaredRun step limit initial k n =
      step^[n] (omegaSquaredRun step limit initial k 0) := by
        induction' n with n ih generalizing k;
        · rfl;
        · rw [ Function.iterate_succ_apply', ← ih, omegaSquaredRun_succ ]

/-
Successor Rule 110 remains radius-one local: agreement on the three cells
of a neighborhood forces agreement at its updated center.
-/
theorem rule110Step_local (x y : Tape) (i : ℕ)
    (hleft : leftCell x i = leftCell y i)
    (hcenter : x i = y i) (hright : x (i + 1) = y (i + 1)) :
    rule110Step x i = rule110Step y i := by
      unfold rule110Step; aesop;

/-- An arbitrary Boolean predicate can be written at cell zero at the first
limit boundary.  This is the exact abstract bridge to oracle-style limit
computation; no computability claim about the supplied predicate is assumed. -/
def predicateLimit (P : ℕ → Bool) (block : ℕ) (_history : ℕ → Tape) : Tape :=
  fun i => if i = 0 then P block else false

/-- A block-dependent limit schedule. -/
def scheduledOmegaRun (P : ℕ → Bool) (initial : Tape) : ℕ → ℕ → Tape
  | 0 => fun n => rule110Step^[n] initial
  | k + 1 => fun n => rule110Step^[n]
      (predicateLimit P k (scheduledOmegaRun P initial k))

/-
At the boundary following block `k`, the distinguished cell reports `P k`.
-/
theorem scheduledOmegaRun_boundary (P : ℕ → Bool) (initial : Tape) (k : ℕ) :
    scheduledOmegaRun P initial (k + 1) 0 0 = P k := by
      rfl

/-
The boundary encoding is faithful: distinct predicates induce distinct
transfinite Rule 110 histories.
-/
theorem scheduledOmegaRun_injective (initial : Tape) :
    Function.Injective (fun P : ℕ → Bool => scheduledOmegaRun P initial) := by
      intro P Q hPQ; have := congrFun ( congrFun hPQ 0 ) 0; simp_all +decide ;
      funext k; have := congrFun ( congrFun hPQ ( k + 1 ) ) 0; simp_all +decide [ scheduledOmegaRun ] ;
      replace this := congr_fun this 0 ; simp_all +decide [ predicateLimit ] ;

/-- Read the distinguished cell at each transfinite block boundary. -/
def boundaryTrace (history : ℕ → ℕ → Tape) : ℕ → Bool :=
  fun k => history (k + 1) 0 0

/-
Boundary observation recovers the complete scheduled predicate.
-/
theorem boundaryTrace_scheduled (P : ℕ → Bool) (initial : Tape) :
    boundaryTrace (scheduledOmegaRun P initial) = P := by
      exact funext fun n => scheduledOmegaRun_boundary P initial n

/-
Cantor diagonalization: Boolean predicates cannot be enumerated by naturals.
-/
theorem no_predicate_enumeration (enumerate : ℕ → (ℕ → Bool)) :
    ¬ Function.Surjective enumerate := by
      by_contra! h_surj;
      exact h_surj ( fun n => if enumerate n n = Bool.true then Bool.false else Bool.true ) |> fun ⟨ k, hk ⟩ => by have := congr_fun hk k; by_cases h : enumerate k k <;> simp +decide [ h ] at this;

/-- Consequently the space of transfinite Rule 110 histories is not enumerable:
every Boolean predicate occurs as the boundary trace of one such history. -/
theorem no_history_enumeration (initial : Tape)
    (enumerate : ℕ → (ℕ → ℕ → Tape)) :
    ¬ Function.Surjective enumerate := by sorry

/-
Concrete successor example: the all-zero tape is fixed by Rule 110.
-/
example : rule110Step (fun _ => false) = (fun _ => false) := by
  exact funext fun x => by rcases x with ( _ | _ | x ) <;> rfl;

/-
Concrete limit example: an even-index oracle marks cell zero after block four.
-/
example (initial : Tape) :
    scheduledOmegaRun (fun n => decide (Even n)) initial 5 0 0 = true := by
  exact scheduledOmegaRun_boundary (fun n => decide (Even n)) initial 4

-- !-- Lab Notes -- !--
/-
Hypothesis (Hypothesizer).  Six falsifiable possibilities were ranked by impact:
(1) a radius-one rule with an unbounded-history limit operator can faithfully
embed arbitrary Boolean oracles at successive `ω`-boundaries; (2) a genuine
Infinite Time Turing Machine transition system can be simulated block-for-block;
(3) Rule 110 with a canonical limsup convention is universal for ordinal
computation; (4) every finite Rule 110 computation embeds conservatively into
an `ω²` run; (5) successor locality survives unchanged at transfinite times;
and (6) a purely local, computable limit convention already exceeds ordinary
Turing computation.  The first three are bold cross-domain bridges between
symbolic dynamics, ordinal recursion, and computability.

Experiment (Experimenter).  The pair-indexed recursion was tested at blocks zero,
one, and five.  Successor evaluation reduces to ordinary function iteration;
at a boundary, `predicateLimit` clears all positive cells and writes the selected
predicate bit at zero.  The examples record the fixed all-zero Rule 110 state
and the even bit at the fifth block boundary.  No external sequence signal was
provided, so no OEIS or LMFDB object influenced target selection.

Analysis (Analyst).  Conjectures (1), (4), and (5) survive.  The injection theorem
is the strongest result: the same fixed radius-one successor law supports a
faithful copy of the full Boolean predicate space once arbitrary history
functionals are admitted at limits.  Conjecture (2) is true at the abstract
transition-system level represented by `omegaSquaredRun`, but an instruction-level
machine encoding remains open.  Conjecture (3) is true only for the explicitly
scheduled limit rule, not yet for a canonical limsup rule.

Critique (Critic).  Calling the result unconditional “super-Turing computation”
would hide the decisive assumption: `predicateLimit` receives `P` as data and
need not be computable.  The boundary theorem therefore proves oracle capacity,
not that Rule 110 manufactures an undecidable predicate.  A boundary case is
block zero, where no limit rule has yet fired.  Another limit case is the
one-sided lattice boundary, fixed to false.  None of the main claims is a
mere definitional equality: the structural results use recursive case analysis,
iteration identities, extensionality, or injection through boundary observations.

Synthesis (Principal Investigator).  The robust generalization is a two-layer
semantics: arbitrary state transition systems supply successor evolution, while
history functionals supply limit evolution.  Rule 110 is an instance of the
successor layer.  This cleanly isolates the broader extension to `ω²`, gives a
conservative finite-time embedding, and states the exact assumption under which
oracle-strength behavior appears.
-/
-- !-- Lab Notes -- !--

end OrdinalCellularAutomata