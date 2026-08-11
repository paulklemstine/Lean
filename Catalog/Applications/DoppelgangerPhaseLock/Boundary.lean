/-
# Doppelgänger Phase-Lock — boundaries of the phenomenon

The synchronization theorem of `Applications.DoppelgangerPhaseLock.Finite` is only
half of the story.  Adversarial review demands the *negative* half: which hypotheses
are genuinely needed, and what does the phenomenon **not** allow?

This file provides three sharp boundary results.

* **Reversibility obstruction.** If every stimulus acts on the internal state space by
  an injective map ("unitary"/reversible agents), phase-lock is impossible as soon as
  the agent has two distinct states.  Telepathic synchronization therefore *requires
  dissipative* (information-destroying) internal dynamics.  Concretely, the parity
  agent `s ↦ !s` never locks, while the "copy the stimulus" agent locks after one
  observation.

* **Identical stimuli are indispensable.** Modelling the two separated agents as a
  product automaton driven by a pair of stimulus streams, we show a concrete pair of
  states and of stimulus streams for which the agents never synchronize.

* **No signalling.** In the product automaton the second agent's state depends only on
  *its own* stimuli and its own initial state.  Phase-lock is therefore *not* a channel:
  nothing that happens at agent 1 can be detected at agent 2.  "Quantum telepathy" here
  is a shared-cause correlation, not communication.
-/
import Applications.DoppelgangerPhaseLock.Core

namespace Doppelganger

variable {S I : Type*}

/-! ### Reversible agents never phase-lock -/

/-- If every stimulus *occurring in `w`* acts injectively, then `w` acts injectively. -/
lemma injective_drive_of_forall_mem {δ : S → I → S} {w : List I}
    (h : ∀ i ∈ w, Function.Injective (δ · i)) : Function.Injective (drive δ w) := by
  induction w with
  | nil => simpa [drive_eq_id_nil] using Function.injective_id
  | cons i v ih =>
      intro s t hst
      simp only [drive_cons] at hst
      exact (h i (by simp)) (ih (fun j hj => h j (by simp [hj])) hst)

/-- If each stimulus acts injectively, so does every stimulus word. -/
lemma injective_drive_of_injective (δ : S → I → S) (h : ∀ i : I, Function.Injective (δ · i))
    (w : List I) : Function.Injective (drive δ w) :=
  injective_drive_of_forall_mem (fun i _ => h i)

/-- **Reversibility obstruction.**  A reversible (injective-per-stimulus) agent with at
least two internal states admits *no* phase-locking word: synchronization requires
dissipation. -/
theorem not_phaseLocking_of_reversible (δ : S → I → S)
    (h : ∀ i : I, Function.Injective (δ · i)) {s t : S} (hst : s ≠ t) :
    ¬ PhaseLocking δ := by
  rintro ⟨w, hw⟩
  exact hst (injective_drive_of_injective δ h w (hw s t))

/-- The parity agent: every stimulus flips its internal bit. -/
def parityAgent : Bool → Unit → Bool := fun s _ => !s

lemma parityAgent_injective (i : Unit) : Function.Injective (parityAgent · i) := by
  intro s t h
  simpa [parityAgent] using h

/-- A concrete non-locking pair of doppelgängers: two parity agents fed the very same
stimulus stream stay out of phase forever. -/
theorem parityAgent_not_phaseLocking : ¬ PhaseLocking parityAgent :=
  not_phaseLocking_of_reversible parityAgent parityAgent_injective (by simp : (true : Bool) ≠ false)

/-- The "copy the stimulus" agent: it overwrites its state with what it observes. -/
def copyAgent : Bool → Bool → Bool := fun _ i => i

/-- Copy agents phase-lock after a single shared observation. -/
theorem copyAgent_locks (i : Bool) : Locks copyAgent [i] := by
  intro s t
  simp [drive, copyAgent]

theorem copyAgent_phaseLocking : PhaseLocking copyAgent := ⟨[true], copyAgent_locks true⟩

/-! ### The product automaton: two agents, two stimulus streams -/

/-- The joint dynamics of the two spatially separated agents, each driven by its own
local stimulus. -/
def prodStep (δ : S → I → S) : S × S → I × I → S × S :=
  fun p q => (δ p.1 q.1, δ p.2 q.2)

/-- **Locality/factorization.**  The joint evolution factors into the two independent
local evolutions. -/
theorem drive_prodStep (δ : S → I → S) (ws : List (I × I)) (p : S × S) :
    drive (prodStep δ) ws p =
      (drive δ (ws.map Prod.fst) p.1, drive δ (ws.map Prod.snd) p.2) := by
  induction ws generalizing p with
  | nil => simp
  | cons q rest ih => simpa [prodStep] using ih (prodStep δ p q)

/-- **No-signalling theorem.**  Agent 2's internal state depends only on agent 2's own
initial state and on agent 2's own stimuli: neither agent 1's initial state nor agent 1's
stimuli have any influence.  Phase-lock is a shared-cause correlation, never a channel. -/
theorem no_signalling (δ : S → I → S) (ws ws' : List (I × I))
    (hsnd : ws.map Prod.snd = ws'.map Prod.snd) (s s' t : S) :
    (drive (prodStep δ) ws (s, t)).2 = (drive (prodStep δ) ws' (s', t)).2 := by
  rw [drive_prodStep, drive_prodStep, hsnd]

/-- Driving the product automaton with *identical* stimuli is exactly the doppelgänger
situation: both agents see `w`. -/
theorem drive_prodStep_diagonal (δ : S → I → S) (w : List I) (s t : S) :
    drive (prodStep δ) (w.map fun i => (i, i)) (s, t) = (drive δ w s, drive δ w t) := by
  rw [drive_prodStep]
  simp [List.map_map, Function.comp_def]

/-- Phase-locking words are exactly the words that steer the product automaton onto the
diagonal from every initial configuration. -/
theorem locks_iff_prod_diagonal (δ : S → I → S) (w : List I) :
    Locks δ w ↔ ∀ p : S × S,
      (drive (prodStep δ) (w.map fun i => (i, i)) p).1
        = (drive (prodStep δ) (w.map fun i => (i, i)) p).2 := by
  constructor
  · intro h p
    rw [show p = (p.1, p.2) from rfl, drive_prodStep_diagonal]
    exact h p.1 p.2
  · intro h s t
    have := h (s, t)
    rwa [drive_prodStep_diagonal] at this

/-- **Identical stimuli are indispensable.**  Two copy agents — which lock instantly on a
shared stimulus — remain permanently out of phase when their stimulus streams differ,
however long they observe. -/
theorem desync_of_distinct_stimuli (n : ℕ) :
    (drive (prodStep copyAgent) (List.replicate n (true, false)) (true, false)).1
      ≠ (drive (prodStep copyAgent) (List.replicate n (true, false)) (true, false)).2 := by
  have hconst : ∀ (b : Bool) (m : ℕ), drive copyAgent (List.replicate m b) b = b := by
    intro b m
    induction m with
    | zero => simp
    | succ k ih => simpa [List.replicate_succ, copyAgent] using ih
  rw [drive_prodStep]
  simp only [List.map_replicate]
  rw [hconst, hconst]
  simp

/-! ### Finiteness is indispensable -/

/-- The **countdown agent** on an infinite state space: every stimulus decreases the
internal counter by one (and `0` is absorbing). -/
def countdownAgent : ℕ → Unit → ℕ := fun s _ => s - 1

lemma drive_countdown (w : List Unit) (s : ℕ) : drive countdownAgent w s = s - w.length := by
  induction w generalizing s with
  | nil => simp
  | cons i v ih =>
      simp only [drive_cons, countdownAgent, List.length_cons]
      rw [ih (s - 1)]
      omega

/-- Any *two* countdown doppelgängers do synchronize — watch long enough and both counters
hit `0`. -/
theorem countdown_pairwise_mergeable (s t : ℕ) : Mergeable countdownAgent s t := by
  refine ⟨List.replicate (max s t) (), ?_⟩
  rw [drive_countdown, drive_countdown]
  simp only [List.length_replicate]
  omega

/-- … yet **no single stimulus word locks them all**: a word of length `n` fails on the pair
`(n+1, 0)`.  Hence `Doppelganger.phaseLocking_iff_pairwise_mergeable` genuinely needs the
finiteness of the internal state space: pairwise telepathy does *not* imply universal
telepathy for unbounded memory. -/
theorem countdown_not_phaseLocking : ¬ PhaseLocking countdownAgent := by
  rintro ⟨w, hw⟩
  have h := hw (w.length + 1) 0
  rw [drive_countdown, drive_countdown] at h
  omega

/-- Sharp form of the previous two results: pairwise mergeability without global
phase-lock is possible — exactly what the finite-state theorem excludes. -/
theorem pairwise_mergeable_not_phaseLocking :
    (∀ s t : ℕ, Mergeable countdownAgent s t) ∧ ¬ PhaseLocking countdownAgent :=
  ⟨countdown_pairwise_mergeable, countdown_not_phaseLocking⟩

end Doppelganger