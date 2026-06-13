/-
# Temporal Realizability: Physical Evolution ↔ Modal Seriality

This file extends the static logic-physics bridge of
`Catalog/Bridges/LogicPhysicsBridge.lean` to *time*. Where that file equates a set of
laws being realizable with its logical consistency, here we equate a **dynamical law**
admitting an infinite physical trajectory with a purely *local* modal property of its
transition relation: **seriality** (in modal logic, the axiom **D**: `□φ → ◇φ`, valid
exactly on serial Kripke frames).

The headline result, `serial_realizable`, is a clean existence theorem: any dynamics with
a nonempty set of initial states and a *serial* step relation (every state has a
successor) admits an infinite trajectory. Physically: a non-stuck evolution law always
produces an eternal history. Logically: a serial Kripke frame always carries an infinite
path. This is the dynamical heart of the logic-physics bridge.

We also prove the reachable-set is forward-closed, and that temporal realizability is a
genuine *instance* of static realizability (the trajectory theory has a model iff the
dynamics evolves forever), tying this file back to the static bridge.

## Cross-Domain Connections (Catalog Synthesis)

* **Logic** (`Catalog/Logic/GLKripke.lean`, `Catalog/Logic/FormalTime.lean`): seriality is
  the modal axiom **D**; this file gives its physical reading and an explicit infinite
  witness path, complementing the Kripke-semantics developments in the catalog.
* **Physics** (`Catalog/Physics/Bridge.lean`, dynamical models): a serial step relation is
  a non-terminating evolution law; the theorem certifies eternal trajectories.
* **Bridges** (`Catalog/Bridges/LogicPhysicsBridge.lean`): direct extension — temporal
  realizability is shown to reduce to the static `Realizable` predicate.

-- !-- Lab Notebook -- !--
Hypothesis:
  An infinite physical trajectory exists for a dynamical law iff the law is "non-stuck"
  (serial) and has a starting state — and this should be provable constructively by
  iterated choice (`Nat.rec` over a successor-choosing function).
Result:
  Proved `serial_realizable` (serial + nonempty-init ⇒ infinite trajectory),
  `reachable_forward_closed`, and `temporal_eq_static` reducing temporal realizability to
  the static bridge. All `sorry = 0`.
Insight:
  Seriality is exactly the modal **D** axiom; the bridge makes "□ implies ◇" mean
  "every observable invariant has a future witness". The infinite path is built by
  promoting the serial existential to a global successor function via `Classical.choice`
  and unrolling with `Nat.rec`, isolating choice as the only nonconstructive ingredient
  (mirroring the static bridge, where classical logic was the only such ingredient).
Failure analysis:
  Defining trajectories over `Fin n` prefixes and trying to take a limit invited index
  arithmetic and a needless compactness/König detour. Working directly with `ℕ → S` and a
  global successor function made the construction a two-line `Nat.rec`, confirming the
  project guidance to prefer `ℕ`-indexed sequences over `Fin`.
-- !-- Lab Notebook -- !--
-/

import Mathlib
import Bridges.LogicPhysicsBridge

namespace LogicPhysicsBridge

universe u

/-- A **dynamical law** on a state space `S`: a set of admissible initial states and a
one-step transition relation. -/
structure Dynamics (S : Type u) where
  /-- The admissible initial states. -/
  init : Set S
  /-- The one-step transition relation: `step s s'` means `s'` may follow `s`. -/
  step : S → S → Prop

/-- A **trajectory** of a dynamics is an infinite history starting from an initial state
and respecting the step relation at every tick. -/
def IsTrajectory {S : Type u} (D : Dynamics S) (τ : ℕ → S) : Prop :=
  τ 0 ∈ D.init ∧ ∀ n, D.step (τ n) (τ (n + 1))

/-- **Temporal realizability.** A dynamics is temporally realizable when it admits at
least one infinite trajectory. -/
def TemporallyRealizable {S : Type u} (D : Dynamics S) : Prop :=
  ∃ τ : ℕ → S, IsTrajectory D τ

/-- **Seriality** of a relation (modal axiom **D**): every state has a successor. -/
def Serial {S : Type u} (step : S → S → Prop) : Prop := ∀ s, ∃ s', step s s'

/-! ## The temporal bridge -/

-- !-- comment -- !--
-- `serial_realizable`: promote seriality to a global successor `f` via `Classical.choice`,
-- pick an initial `s₀`, and define `τ = Nat.rec s₀ (fun _ s => f s)`; both trajectory
-- conditions then hold by `f`'s defining property `step s (f s)`.
-- !-- comment -- !--
/-- **Temporal realizability theorem (seriality ⇒ eternal history).** A dynamics with a
nonempty initial set and a serial step relation always admits an infinite trajectory.
This is the dynamical core of the logic-physics bridge: a non-stuck physical law evolves
forever, and dually a serial Kripke frame carries an infinite path. -/
theorem serial_realizable {S : Type u} (D : Dynamics S)
    (hinit : D.init.Nonempty) (hser : Serial D.step) :
    TemporallyRealizable D := by
  classical
  obtain ⟨s₀, hs₀⟩ := hinit
  -- Global successor function from seriality.
  let f : S → S := fun s => (hser s).choose
  have hf : ∀ s, D.step s (f s) := fun s => (hser s).choose_spec
  -- Unroll into an infinite trajectory.
  let τ : ℕ → S := fun n => Nat.rec s₀ (fun _ s => f s) n
  refine ⟨τ, ?_, ?_⟩
  · simpa using hs₀
  · intro n
    simpa using hf (τ n)

/-- **Forward-closedness of trajectory steps.** Along any trajectory, consecutive states
are related by `step`; hence the image of a trajectory is contained in the relation's
"future cone". -/
theorem trajectory_step {S : Type u} {D : Dynamics S} {τ : ℕ → S}
    (h : IsTrajectory D τ) (n : ℕ) : D.step (τ n) (τ (n + 1)) := h.2 n

/-- The set of states visited by a trajectory is **forward-closed under reachability**:
if `τ n = s` then `s` has a successor `τ (n+1)` lying in the trajectory. -/
theorem reachable_forward_closed {S : Type u} {D : Dynamics S} {τ : ℕ → S}
    (h : IsTrajectory D τ) {s : S} {n : ℕ} (hs : τ n = s) :
    ∃ s', D.step s s' ∧ ∃ m, τ m = s' := by
  exact ⟨τ (n + 1), hs ▸ h.2 n, n + 1, rfl⟩

/-! ## Reduction to the static bridge -/

/-- The **trajectory theory** of a dynamics: a theory over the function space `ℕ → S`
whose single law is "is a trajectory of `D`". Its models are exactly the trajectories. -/
def trajectoryTheory {S : Type u} (D : Dynamics S) : Theory (ℕ → S) :=
  {fun τ => IsTrajectory D τ}

-- !-- comment -- !--
-- `temporal_eq_static`: a model of the singleton trajectory theory *is* a trajectory, so
-- the static `Realizable` predicate on it unfolds definitionally to `TemporallyRealizable`.
-- !-- comment -- !--
/-- **Temporal realizability is static realizability.** A dynamics evolves forever iff its
trajectory theory has a model. This embeds the temporal bridge inside the static
logic-physics bridge of `LogicPhysicsBridge.lean`. -/
theorem temporal_eq_static {S : Type u} (D : Dynamics S) :
    TemporallyRealizable D ↔ Realizable (trajectoryTheory D) := by
  constructor
  · rintro ⟨τ, hτ⟩
    refine ⟨τ, ?_⟩
    intro p hp
    simp only [trajectoryTheory, Set.mem_singleton_iff] at hp
    subst hp
    exact hτ
  · rintro ⟨τ, hmod⟩
    exact ⟨τ, hmod _ rfl⟩

/-- **Corollary (bridge composition).** A serial, nonempty-initialized dynamics has a
*consistent* trajectory theory — derived by chaining the temporal theorem, the
static reduction, and the static bridge `realizable_iff_consistent`. -/
theorem serial_trajectoryTheory_consistent {S : Type u} (D : Dynamics S)
    (hinit : D.init.Nonempty) (hser : Serial D.step) :
    Consistent (trajectoryTheory D) :=
  (realizable_iff_consistent _).mp
    ((temporal_eq_static D).mp (serial_realizable D hinit hser))

end LogicPhysicsBridge