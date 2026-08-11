/-
# Doppelgänger Phase-Lock — decidability and extremal experiments

Third research cycle.  The finite synchronization theorem is *effective*: because a
phase-locking agent must lock within `(|S| - 1)·|S|²` stimuli
(`Doppelganger.exists_lock_length_le_of_phaseLocking`), the search for a locking word can
be confined to a finite set.  This yields a genuine `Decidable` instance: *whether two
identical agents can be telepathically synchronized is an algorithmically decidable
property of the agent design*.

We then run the decision procedure as an experiment on the three-state Černý agent, and
prove — by exhaustive certified search — that its minimal phase-lock time is exactly
`4 = (3-1)²`, the Černý extremal value.  This is a genuine (kernel-checked, no
`native_decide`) computation, not a definitional triviality.

## Main results

* `Doppelganger.phaseLocking_iff_exists_bounded` — reduction to a finite search.
* `Doppelganger.decidablePhaseLocking` — decidability of doppelgänger telepathy.
* `Doppelganger.cerny3_lock_time_eq_four` — the Černý agent locks in exactly four shared
  stimuli, and in no fewer.
-/
import Applications.DoppelgangerPhaseLock.Finite
import Applications.DoppelgangerPhaseLock.Boundary

namespace Doppelganger

/-- Locking is a decidable property of a finite agent and a finite stimulus word. -/
instance decidableLocks {S I : Type*} [Fintype S] [DecidableEq S] (δ : S → I → S) (w : List I) :
    Decidable (Locks δ w) := by unfold Locks; infer_instance

section Decide

variable {S I : Type*} [Fintype S] [DecidableEq S] [Fintype I] [DecidableEq I]

omit [Fintype I] [DecidableEq I] in
/-- **Reduction to a finite search.**  Thanks to the cubic bound on the phase-lock time,
telepathy of an agent design is witnessed, if at all, by a word of bounded length. -/
theorem phaseLocking_iff_exists_bounded [Nonempty S] (δ : S → I → S) :
    PhaseLocking δ ↔ ∃ m < (Fintype.card S - 1) * (Fintype.card S * Fintype.card S) + 1,
      ∃ f : Fin m → I, Locks δ (List.ofFn f) := by
  constructor
  · intro h
    obtain ⟨w, hlen, hw⟩ := exists_lock_length_le_of_phaseLocking δ h
    exact ⟨w.length, by omega, fun i => w[i], by simpa using hw⟩
  · rintro ⟨m, _, f, hf⟩
    exact ⟨List.ofFn f, hf⟩

/-- **Telepathy is decidable.**  For finite state spaces and finite stimulus alphabets,
whether two separated copies of the agent can be phase-locked is decidable. -/
instance decidablePhaseLocking [Nonempty S] (δ : S → I → S) : Decidable (PhaseLocking δ) :=
  decidable_of_iff _ (phaseLocking_iff_exists_bounded δ).symm

end Decide

/-! ### Running the decision procedure -/

theorem copyAgent_phaseLocking_by_decision : PhaseLocking copyAgent := by decide

theorem parityAgent_not_phaseLocking_by_decision : ¬ PhaseLocking parityAgent := by decide

/-- The three-state Černý agent: stimulus `0` rotates the internal state, stimulus `1`
collapses state `0` onto state `1` and fixes the rest. -/
def cerny3 : Fin 3 → Fin 2 → Fin 3 :=
  fun s i => if i = 0 then s + 1 else (if s = 0 then 1 else s)

theorem cerny3_locks_baab : Locks cerny3 [1, 0, 0, 1] := by decide

theorem cerny3_phaseLocking : PhaseLocking cerny3 := ⟨_, cerny3_locks_baab⟩

theorem cerny3_no_short_lock_ofFn : ∀ m < 4, ∀ f : Fin m → Fin 2, ¬ Locks cerny3 (List.ofFn f) := by
  decide

/-- **Extremality experiment.**  The minimal doppelgänger phase-lock time of the
three-state Černý agent is exactly `4 = (3-1)²`: the word `baab` locks it, and no shorter
stimulus word does. -/
theorem cerny3_lock_time_eq_four :
    Locks cerny3 [1, 0, 0, 1] ∧ ∀ w : List (Fin 2), w.length < 4 → ¬ Locks cerny3 w := by
  refine ⟨cerny3_locks_baab, fun w hw hlock => ?_⟩
  have hofFn : List.ofFn (fun i : Fin w.length => w[i]) = w := List.ofFn_getElem w
  exact cerny3_no_short_lock_ofFn w.length hw (fun i => w[i]) (by rw [hofFn]; exact hlock)

/-- The four-state Černý agent. -/
def cerny4 : Fin 4 → Fin 2 → Fin 4 :=
  fun s i => if i = 0 then s + 1 else (if s = 0 then 1 else s)

set_option maxRecDepth 10000 in
theorem cerny4_locks : Locks cerny4 [1, 0, 0, 0, 1, 0, 0, 0, 1] := by decide

set_option maxRecDepth 100000 in
theorem cerny4_no_short_lock_ofFn :
    ∀ m < 9, ∀ f : Fin m → Fin 2, ¬ Locks cerny4 (List.ofFn f) := by decide

/-- **Second extremality experiment.**  The four-state Černý agent locks in exactly
`9 = (4-1)²` shared stimuli.  Together with `Doppelganger.cerny3_lock_time_eq_four` this
gives certified data points `(n, minimal lock time) = (3, 4), (4, 9)` for the quadratic
Černý pattern `(n-1)²`, well below our proved cubic upper bound. -/
theorem cerny4_lock_time_eq_nine :
    Locks cerny4 [1, 0, 0, 0, 1, 0, 0, 0, 1] ∧
      ∀ w : List (Fin 2), w.length < 9 → ¬ Locks cerny4 w := by
  refine ⟨cerny4_locks, fun w hw hlock => ?_⟩
  have hofFn : List.ofFn (fun i : Fin w.length => w[i]) = w := List.ofFn_getElem w
  exact cerny4_no_short_lock_ofFn w.length hw (fun i => w[i]) (by rw [hofFn]; exact hlock)

end Doppelganger