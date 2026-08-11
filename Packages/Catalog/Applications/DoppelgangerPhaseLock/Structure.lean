/-
# Doppelgänger Phase-Lock — structural calculus of phase-locking agents

Second research cycle.  Having established *when* phase-lock happens, we ask how the
property behaves under the natural constructions on agents: parallel composition,
coarse-graining (simulation/quotient), relabelling of the stimulus alphabet, and order
structure on the internal state space.

## Main results

* `Doppelganger.phaseLocking_par` — **compositional telepathy**: two independent
  phase-locking subsystems observing the same environment lock jointly, and the joint
  locking time is at most the sum of the individual ones (`Doppelganger.locks_par`).
* `Doppelganger.locks_of_simulation` — **coarse-graining preserves telepathy**: a
  surjective simulation (a homomorphic image of the agent) inherits every locking word.
* `Doppelganger.locks_relabel_iff` — functoriality in the stimulus alphabet.
* `Doppelganger.monotone_locks_iff` — **order rigidity**: for an agent whose every
  stimulus acts monotonically on a linearly ordered state space, locking the two *extreme*
  states already locks *all* states.  Consequently
  `Doppelganger.monotone_lock_length` gives a *quadratic* phase-lock time for monotone
  agents, improving the general cubic bound
  `Doppelganger.exists_lock_length_le_of_phaseLocking`.
-/
import Applications.DoppelgangerPhaseLock.Finite

namespace Doppelganger

variable {S S' I I' : Type*}

/-! ### Parallel composition of agents -/

/-- Two agents, each with its own internal state space, observing the *same* environment. -/
def par (δ₁ : S → I → S) (δ₂ : S' → I → S') : S × S' → I → S × S' :=
  fun p i => (δ₁ p.1 i, δ₂ p.2 i)

lemma drive_par (δ₁ : S → I → S) (δ₂ : S' → I → S') (w : List I) (p : S × S') :
    drive (par δ₁ δ₂) w p = (drive δ₁ w p.1, drive δ₂ w p.2) := by
  induction w generalizing p with
  | nil => simp
  | cons i v ih => simpa [par] using ih (par δ₁ δ₂ p i)

/-- **Compositional telepathy.**  Concatenating the two locking words locks the composite
agent: locking times add. -/
theorem locks_par {δ₁ : S → I → S} {δ₂ : S' → I → S'} {w₁ w₂ : List I}
    (h₁ : Locks δ₁ w₁) (h₂ : Locks δ₂ w₂) : Locks (par δ₁ δ₂) (w₁ ++ w₂) := by
  intro p q
  rw [drive_par, drive_par]
  have e1 : drive δ₁ (w₁ ++ w₂) p.1 = drive δ₁ (w₁ ++ w₂) q.1 := (h₁.append_right δ₁ w₂) _ _
  have e2 : drive δ₂ (w₁ ++ w₂) p.2 = drive δ₂ (w₁ ++ w₂) q.2 := (h₂.append_left δ₂ w₁) _ _
  rw [e1, e2]

theorem phaseLocking_par {δ₁ : S → I → S} {δ₂ : S' → I → S'}
    (h₁ : PhaseLocking δ₁) (h₂ : PhaseLocking δ₂) : PhaseLocking (par δ₁ δ₂) := by
  obtain ⟨w₁, hw₁⟩ := h₁
  obtain ⟨w₂, hw₂⟩ := h₂
  exact ⟨w₁ ++ w₂, locks_par hw₁ hw₂⟩

/-! ### Coarse-graining and simulation -/

/-- A simulation intertwines the two dynamics. -/
lemma drive_simulation {δ : S → I → S} {δ' : S' → I → S'} {f : S → S'}
    (hf : ∀ (s : S) (i : I), f (δ s i) = δ' (f s) i) (w : List I) (s : S) :
    f (drive δ w s) = drive δ' w (f s) := by
  induction w generalizing s with
  | nil => simp
  | cons i v ih => simp only [drive_cons]; rw [ih (δ s i), hf]

/-- **Coarse-graining preserves telepathy.**  If a coarser description `δ'` of the agent is
a surjective homomorphic image of `δ`, then every stimulus word that locks the fine-grained
agents also locks the coarse-grained ones. -/
theorem locks_of_simulation {δ : S → I → S} {δ' : S' → I → S'} {f : S → S'}
    (hf : ∀ (s : S) (i : I), f (δ s i) = δ' (f s) i) (hsurj : Function.Surjective f)
    {w : List I} (h : Locks δ w) : Locks δ' w := by
  intro a b
  obtain ⟨s, rfl⟩ := hsurj a
  obtain ⟨t, rfl⟩ := hsurj b
  rw [← drive_simulation hf, ← drive_simulation hf, h s t]

theorem phaseLocking_of_simulation {δ : S → I → S} {δ' : S' → I → S'} {f : S → S'}
    (hf : ∀ (s : S) (i : I), f (δ s i) = δ' (f s) i) (hsurj : Function.Surjective f)
    (h : PhaseLocking δ) : PhaseLocking δ' := by
  obtain ⟨w, hw⟩ := h
  exact ⟨w, locks_of_simulation hf hsurj hw⟩

/-! ### Functoriality in the stimulus alphabet -/

/-- Re-encoding the environment: the agent reacts to `i'` as it would to `g i'`. -/
def relabel (δ : S → I → S) (g : I' → I) : S → I' → S := fun s i' => δ s (g i')

lemma drive_relabel (δ : S → I → S) (g : I' → I) (w : List I') (s : S) :
    drive (relabel δ g) w s = drive δ (w.map g) s := by
  induction w generalizing s with
  | nil => simp
  | cons i v ih => simpa [relabel] using ih (δ s (g i))

theorem locks_relabel_iff (δ : S → I → S) (g : I' → I) (w : List I') :
    Locks (relabel δ g) w ↔ Locks δ (w.map g) := by
  constructor <;> intro h s t
  · simpa [drive_relabel] using h s t
  · simpa [drive_relabel] using h s t

/-! ### Order rigidity: monotone agents -/

section Monotone

variable [LinearOrder S] [OrderBot S] [OrderTop S]

omit [OrderBot S] [OrderTop S] in
lemma monotone_drive (δ : S → I → S) (hmono : ∀ i : I, Monotone (δ · i)) (w : List I) :
    Monotone (drive δ w) := by
  induction w with
  | nil => simpa [drive_eq_id_nil] using monotone_id
  | cons i v ih =>
      intro s t hst
      simp only [drive_cons]
      exact ih (hmono i hst)

/-- **Order rigidity.**  For a monotone agent, phase-locking the two *extreme* internal
states is already equivalent to phase-locking every pair: the order squeezes all
intermediate states between the two extremes. -/
theorem monotone_locks_iff (δ : S → I → S) (hmono : ∀ i : I, Monotone (δ · i)) (w : List I) :
    Locks δ w ↔ drive δ w ⊥ = drive δ w ⊤ := by
  constructor
  · intro h; exact h _ _
  · intro h s t
    have key : ∀ x : S, drive δ w x = drive δ w ⊥ := by
      intro x
      have h1 : drive δ w ⊥ ≤ drive δ w x := monotone_drive δ hmono w bot_le
      have h2 : drive δ w x ≤ drive δ w ⊤ := monotone_drive δ hmono w le_top
      rw [← h] at h2
      exact le_antisymm h2 h1
    rw [key s, key t]

theorem monotone_phaseLocking_iff (δ : S → I → S) (hmono : ∀ i : I, Monotone (δ · i)) :
    PhaseLocking δ ↔ Mergeable δ (⊥ : S) ⊤ := by
  constructor
  · rintro ⟨w, hw⟩; exact ⟨w, hw _ _⟩
  · rintro ⟨w, hw⟩; exact ⟨w, (monotone_locks_iff δ hmono w).mpr hw⟩

/-- **Quadratic phase-lock time for monotone agents**, improving the general cubic bound:
a monotone agent that can lock at all locks within `|S|²` stimuli. -/
theorem monotone_lock_length [Fintype S] (δ : S → I → S) (hmono : ∀ i : I, Monotone (δ · i))
    (h : PhaseLocking δ) :
    ∃ w : List I, w.length ≤ Fintype.card S * Fintype.card S ∧ Locks δ w := by
  obtain ⟨w, hlen, hw⟩ := exists_short_merge δ ((monotone_phaseLocking_iff δ hmono).mp h)
  exact ⟨w, hlen, (monotone_locks_iff δ hmono w).mpr hw⟩

end Monotone

end Doppelganger