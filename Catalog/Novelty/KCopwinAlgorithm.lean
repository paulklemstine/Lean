import Mathlib
import Novelty.ArgumentationKernelGame

/-!
# Reproducing the finite-horizon `k`-copwin algorithm

A game state records the locations of `k` cops and one robber.  In one round the
cops first choose simultaneous legal moves (remaining in place is allowed), and
the robber then chooses a legal move after seeing the cops' choice.  The
backward-search operator adjoins captured states and states from which the cops
can force entry into the current set in one round.

The results below separate the mathematical specification from executable finite
search.  They prove monotonicity, characterize every iteration by bounded-horizon
winning strategies, show that a stabilized iterate is a fixed point, and identify
that fixed point as the least set closed under the game rules.  The finite-set
implementation is then proved extensionally equal to the specification at every
iteration.

The import of `Novelty.ArgumentationKernelGame` provides the complementary
well-founded-game viewpoint: its unique kernel describes losing positions,
whereas the operator here computes winning positions by backward induction.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the implementation's repeated table update is exactly
bounded-horizon game semantics, not merely a heuristic; moreover any stabilized
table is the least closed winning region.  Bolder extensions considered were a
polynomial stabilization bound in the number of graph vertices and quotienting
configurations by cop permutations.
Experiment (Experimenter): backward tables were expanded for paths, complete
graphs, and edgeless graphs.  Capture states enter at stage zero; each additional
iteration adds precisely states admitting one cops-first round into the previous
table.  The quantifier order `exists cops; forall robber` was essential.
Analysis (Analyst): monotonicity lifts capture inclusion through the alternating
quantifiers.  Induction then identifies iteration number with strategy horizon.
On finite state spaces the `Finset.filter` implementation has the same membership
formula, allowing an induction that connects executable and semantic tables.
Critique (Critic): reversing the quantifiers would incorrectly let cops react to
the robber's move.  A boundary case is `k = 0`: capture is empty, and the theory
correctly does not manufacture a win.  Stabilization is stated conditionally;
the crude finite-cardinality termination bound is left as a future strengthening.
Synthesis: the central implementation invariant and its fixed-point consequence
are established independently of graph size, with finite executability added as
a proved refinement.
-/

namespace KCopwin

open SimpleGraph

variable {V : Type*}

/-- A player may stay put or traverse one graph edge. -/
def StayAdj (G : SimpleGraph V) (u v : V) : Prop := u = v ∨ G.Adj u v

/-- A complete game state: the cops' locations followed by the robber's location. -/
abbrev State (V : Type*) (k : ℕ) := (Fin k → V) × V

/-- Simultaneous legal movement of all cops. -/
def CopsMove (G : SimpleGraph V) {k : ℕ} (c c' : Fin k → V) : Prop :=
  ∀ i, StayAdj G (c i) (c' i)

/-- The robber has already been captured in this state. -/
def Captured {k : ℕ} (s : State V k) : Prop := ∃ i, s.1 i = s.2

/-- One backward-search update.  Cops move first and the robber moves second. -/
def winStep (G : SimpleGraph V) {k : ℕ} (W : Set (State V k)) : Set (State V k) :=
  {s | Captured s ∨ ∃ c', CopsMove G s.1 c' ∧
    (Captured (c', s.2) ∨ ∀ r', StayAdj G s.2 r' → (c', r') ∈ W)}

/-- Winning within a bounded number of rounds. -/
def CapturableWithin (G : SimpleGraph V) {k : ℕ} : ℕ → State V k → Prop
  | 0, s => Captured s
  | n + 1, s => Captured s ∨ ∃ c', CopsMove G s.1 c' ∧
      (Captured (c', s.2) ∨
        ∀ r', StayAdj G s.2 r' → CapturableWithin G n (c', r'))

/-- Semantic backward-search tables, starting with immediate capture. -/
def winningRegion (G : SimpleGraph V) {k : ℕ} : ℕ → Set (State V k)
  | 0 => {s | Captured s}
  | n + 1 => winStep G (winningRegion G n)

/-- The backward update is monotone. -/
theorem winStep_mono (G : SimpleGraph V) {k : ℕ} : Monotone (winStep G (k := k)) := by
  intro A B hAB s hs
  rcases hs with hcap | ⟨c', hc', hnext⟩
  · exact Or.inl hcap
  · refine Or.inr ⟨c', hc', ?_⟩
    rcases hnext with hcap | hnext
    · exact Or.inl hcap
    · exact Or.inr fun r' hr' => hAB (hnext r' hr')

/-- Every table is contained in its successor: waiting at a captured state and
reusing the previous strategy preserves a win. -/
theorem winningRegion_subset_succ (G : SimpleGraph V) {k : ℕ} (n : ℕ) :
    winningRegion G (k := k) n ⊆ winningRegion G (n + 1) := by
  induction n with
  | zero =>
      intro s hs
      exact Or.inl hs
  | succ n ih =>
      intro s hs
      change s ∈ winStep G (winningRegion G n) at hs
      change s ∈ winStep G (winningRegion G (n + 1))
      exact winStep_mono G ih hs

/-- **Iteration invariant.** Membership in table `n` is equivalent to a cops
strategy forcing capture in at most `n` rounds. -/
theorem mem_winningRegion_iff (G : SimpleGraph V) {k : ℕ} (n : ℕ) (s : State V k) :
    s ∈ winningRegion G n ↔ CapturableWithin G n s := by
  induction n generalizing s with
  | zero => rfl
  | succ n ih =>
      change (Captured s ∨ ∃ c', CopsMove G s.1 c' ∧
        (Captured (c', s.2) ∨
          ∀ r', StayAdj G s.2 r' → (c', r') ∈ winningRegion G n)) ↔ _
      simp only [CapturableWithin]
      constructor
      · intro h
        rcases h with hcap | ⟨c', hc', hnext⟩
        · exact Or.inl hcap
        · refine Or.inr ⟨c', hc', ?_⟩
          rcases hnext with hcap' | hnext
          · exact Or.inl hcap'
          · exact Or.inr fun r' hr' => (ih (c', r')).mp (hnext r' hr')
      · intro h
        rcases h with hcap | ⟨c', hc', hnext⟩
        · exact Or.inl hcap
        · refine Or.inr ⟨c', hc', ?_⟩
          rcases hnext with hcap' | hnext
          · exact Or.inl hcap'
          · exact Or.inr fun r' hr' => (ih (c', r')).mpr (hnext r' hr')

/-- **Kernel bridge for ranked strategy graphs.** If strategy edges always lower a
natural-valued capture rank, the resulting move graph has a unique kernel of
losing positions.  This applies the catalog's well-founded game theorem to the
rank certificates suggested by backward search. -/
theorem rankedMove_existsUnique_kernel {X : Type*} (rank : X → ℕ) :
    ∃! P : Set X, ArgKernelGame.Kernel (fun a b => rank b < rank a) P := by
  apply ArgKernelGame.exists_unique_kernel
  change WellFounded (Function.onFun (· < ·) rank)
  exact Nat.lt_wfRel.wf.onFun

/-- If an iteration adds no state, the resulting table is a fixed point. -/
theorem fixed_of_stabilized (G : SimpleGraph V) {k n : ℕ}
    (h : winningRegion G (k := k) (n + 1) = winningRegion G n) :
    winStep G (winningRegion G (k := k) n) = winningRegion G n := by
  simpa only [winningRegion] using h

/-- Any set containing captured states and closed under one backward update
contains every finite-horizon winning region. -/
theorem winningRegion_least (G : SimpleGraph V) {k n : ℕ} {W : Set (State V k)}
    (hcap : {s | Captured s} ⊆ W) (hclosed : winStep G W ⊆ W) :
    winningRegion G n ⊆ W := by
  induction n with
  | zero => exact hcap
  | succ n ih =>
      intro s hs
      apply hclosed
      exact winStep_mono G ih hs

section FiniteImplementation

variable [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-- Executable one-round update by filtering the finite state space. -/
noncomputable def winStepFinset (G : SimpleGraph V) [DecidableRel G.Adj]
    {k : ℕ} (W : Finset (State V k)) : Finset (State V k) := by
  classical
  exact Finset.univ.filter fun s => Captured s ∨ ∃ c', CopsMove G s.1 c' ∧
    (Captured (c', s.2) ∨ ∀ r', StayAdj G s.2 r' → (c', r') ∈ W)

/-- Executable iteration, initialized by all immediate-capture states. -/
noncomputable def winningTable (G : SimpleGraph V) [DecidableRel G.Adj]
    {k : ℕ} : ℕ → Finset (State V k)
  | 0 => by
      classical
      exact Finset.univ.filter Captured
  | n + 1 => winStepFinset G (winningTable G n)

/-- Membership in the executable update agrees with the set-theoretic operator. -/
theorem mem_winStepFinset_iff {k : ℕ} (W : Finset (State V k)) (s : State V k) :
    s ∈ winStepFinset G W ↔ s ∈ winStep G (↑W : Set (State V k)) := by
  simp [winStepFinset, winStep]

/-- **Implementation correctness.** At every iteration, the finite table is
extensionally equal to bounded-horizon strategy semantics. -/
theorem mem_winningTable_iff {k : ℕ} (n : ℕ) (s : State V k) :
    s ∈ winningTable G n ↔ CapturableWithin G n s := by
  induction n generalizing s with
  | zero => simp [winningTable, CapturableWithin]
  | succ n ih =>
      simp only [winningTable, winStepFinset, Finset.mem_filter, Finset.mem_univ, true_and]
      simp only [CapturableWithin]
      constructor
      · intro h
        rcases h with hcap | ⟨c', hc', hnext⟩
        · exact Or.inl hcap
        · refine Or.inr ⟨c', hc', ?_⟩
          rcases hnext with hcap' | hnext
          · exact Or.inl hcap'
          · exact Or.inr fun r' hr' => (ih (c', r')).mp (hnext r' hr')
      · intro h
        rcases h with hcap | ⟨c', hc', hnext⟩
        · exact Or.inl hcap
        · refine Or.inr ⟨c', hc', ?_⟩
          rcases hnext with hcap' | hnext
          · exact Or.inl hcap'
          · exact Or.inr fun r' hr' => (ih (c', r')).mpr (hnext r' hr')

/-- Concrete boundary example: with no cops, no state is capturable at any
finite horizon. -/
example (n : ℕ) (s : State V 0) : ¬ CapturableWithin G n s := by
  induction n generalizing s with
  | zero => simp [CapturableWithin, Captured]
  | succ n ih =>
      simp only [CapturableWithin]
      push_neg
      constructor
      · simp [Captured]
      · intro c' hc'
        constructor
        · simp [Captured]
        · exact ⟨s.2, Or.inl rfl, ih (c', s.2)⟩

end FiniteImplementation

end KCopwin