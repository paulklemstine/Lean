/-
# Doppelgänger Phase-Lock — sharpness of the topological zero–one law

Adversarial review of `Applications.DoppelgangerPhaseLock.Topology`: the zero–one law says
the set of synchronizing stimulus streams is either empty or open and dense.  Could it be
*everything* — i.e. is a phase-locking agent guaranteed to lock along **every** stream?
And is `LockSet` perhaps even clopen, so that the dichotomy is a triviality?

Both are false, and this file proves it with an explicit witness.  For the three-state
Černý agent the constant "rotate forever" stimulus stream never locks the doppelgängers,
because the rotation stimulus acts bijectively and bijections never destroy the distinction
between two states.  Hence for that agent `LockSet` is open, dense, **not** closed and
**not** the whole space: the zero–one law of `Topology.lean` is exactly as strong as it can
be, and no stronger.

## Main results

* `Doppelganger.cerny3_rotation_stream_not_mem_lockSet` — a non-locking stream for a
  phase-locking agent.
* `Doppelganger.not_isClosed_lockSet_cerny3` — the lock set is not closed.
* `Doppelganger.lockSet_cerny3_sharp` — open + dense + neither closed nor everything.
* `Doppelganger.cerny3_not_contractive` — the same agent admits no contractive metric, so
  the analytic mechanism of `Contraction.lean` is strictly stronger than phase-lock itself.
-/
import Applications.DoppelgangerPhaseLock.Topology
import Applications.DoppelgangerPhaseLock.Contraction
import Applications.DoppelgangerPhaseLock.Decidability

namespace Doppelganger

/-- Along the constant "rotate" stimulus stream the two Černý doppelgängers never
synchronize: every prefix acts by a bijection of the state space. -/
theorem cerny3_rotation_stream_not_mem_lockSet :
    (fun _ : ℕ => (0 : Fin 2)) ∉ LockSet cerny3 := by
  rintro ⟨n, hn⟩
  have hpre : pre (fun _ : ℕ => (0 : Fin 2)) n = List.replicate n 0 := by
    apply List.ext_getElem <;> simp
  rw [hpre] at hn
  have hinj : Function.Injective (drive cerny3 (List.replicate n 0)) := by
    refine injective_drive_of_forall_mem (fun i hi => ?_)
    have hi0 : i = 0 := by simpa using List.eq_of_mem_replicate hi
    subst hi0
    intro a b hab
    simpa [cerny3] using hab
  have hcontra := hinj (hn 0 1)
  simp at hcontra

/-- Consequently the lock set of a phase-locking agent need not be everything. -/
theorem lockSet_cerny3_ne_univ : LockSet cerny3 ≠ Set.univ := by
  intro h
  exact cerny3_rotation_stream_not_mem_lockSet (h ▸ Set.mem_univ _)

/-- The lock set is *not* closed: being dense and proper, it cannot be. -/
theorem not_isClosed_lockSet_cerny3 : ¬ IsClosed (LockSet cerny3) := by
  intro hclosed
  have hdense : Dense (LockSet cerny3) := dense_lockSet cerny3 cerny3_phaseLocking
  have huniv : LockSet cerny3 = Set.univ := by
    rw [← hclosed.closure_eq, hdense.closure_eq]
  exact lockSet_cerny3_ne_univ huniv

/-- **Sharpness of the zero–one law.**  For the Černý agent the set of synchronizing
stimulus streams is open and dense, yet neither closed nor the whole stream space: the
dichotomy `Doppelganger.lockSet_dichotomy` cannot be upgraded to "empty or everything",
nor to a clopen dichotomy. -/
theorem lockSet_cerny3_sharp :
    IsOpen (LockSet cerny3) ∧ Dense (LockSet cerny3) ∧
      ¬ IsClosed (LockSet cerny3) ∧ LockSet cerny3 ≠ Set.univ :=
  ⟨isOpen_lockSet cerny3, dense_lockSet cerny3 cerny3_phaseLocking,
    not_isClosed_lockSet_cerny3, lockSet_cerny3_ne_univ⟩

/-! ### The analytic mechanism is strictly stronger than the phenomenon -/

theorem cerny3_bijective_stimulus : Function.Bijective (cerny3 · 0) := by decide

/-- **Contraction is not necessary for phase-lock.**  The Černý agent phase-locks
(`cerny3_phaseLocking`), yet *no* metric on its state space makes every stimulus a uniform
contraction: its rotation stimulus is reversible.  So the analytic mechanism of
`Applications.DoppelgangerPhaseLock.Contraction` is a strictly stronger hypothesis than the
combinatorial phenomenon it explains. -/
theorem cerny3_not_contractive (m : MetricSpace (Fin 3)) {k : ℝ} (hk : 0 ≤ k) (hk1 : k < 1)
    (hcontract : ∀ (i : Fin 2) (s t : Fin 3), m.dist (cerny3 s i) (cerny3 t i) ≤ k * m.dist s t) :
    False := by
  letI := m
  have h01 : (0 : Fin 3) = 1 :=
    no_contractive_metric_of_bijective_stimulus cerny3 0 cerny3_bijective_stimulus hk hk1
      hcontract 0 1
  simp at h01

end Doppelganger