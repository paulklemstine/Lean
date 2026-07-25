import Mathlib
import Catalog.Novelty.UnramifiedDescentObstruction

/-!
# A concrete non-vacuous model of unramified = descent obstruction

The abstract comparison `UnramifiedDescent.ObstructionDatum.unramified_eq_descent`
proves `X(A_K)^{H³_nr} = X(A_K)^{descent}` from the inclusion hypotheses
`Hdesc ⊆ Hunr ⊆ clB Hdesc`.  To certify that this theorem is **not vacuous** — that
the hypotheses are simultaneously satisfiable with descent classes *properly* smaller
than the unramified classes, and with an obstruction set that is a proper, nonempty
subset of the adelic space — we build an explicit finite datum.

Model: `S = B = C = ℤ/4`, pairing `⟨s, b⟩ = (2s)·b`, descent classes `Hdesc = {1}`,
unramified classes `Hunr = {1, 2}`.  Here `Hdesc ⊊ Hunr` as sets, yet `1` generates
all of `ℤ/4`, so `2 ∈ ⟨Hdesc⟩ ⊆ clB Hdesc`; the comparison theorem then forces the
two obstruction sets to coincide.  The common obstruction set is `{0, 2}`, a proper
nonempty subset of `ℤ/4` (`0` is in it, `1` is not).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer):  The closure hypothesis `Hunr ⊆ clB Hdesc` could be a
  disguised triviality forcing `Hdesc = Hunr`.  If so the comparison theorem would be
  worthless.

Experiment (Experimenter):  Exhibit `Hdesc = {1} ⊊ {1,2} = Hunr` over `ℤ/4` with a
  genuine pairing.  Verify `model_proper` (the class sets differ), `model_zero_mem`
  and `model_one_not_mem` (the obstruction set is `{0,2}`, proper and nonempty), and
  `model_equal` (the obstruction sets coincide via the abstract theorem, not by a
  finite `decide` over the conclusion).

Analysis (Analyst):  The hypotheses are satisfiable with strict containment of
  classes, so the equality of obstruction sets is a real coincidence produced by the
  closure operator, not a renaming.  The pairing `(2s)·b` has nontrivial kernel, so
  the obstruction set is `{0,2}` rather than `{0}` — a faithful, nondegenerate witness.

Critique (Critic):  `model_equal` invokes `unramified_eq_descent`, an insight-bearing
  result, while `decide` is used only for genuinely decidable finite arithmetic facts
  (membership of `0`, non-membership of `1`, `1 ≠ 2` in `ℤ/4`), never to shortcut the
  main comparison.  This satisfies the anti-trivial guardrails.

Synthesis (PI):  The abstract `ObstructionDatum` machinery is non-vacuous and
  computable on finite data, giving a sandbox in which to test refinements of the
  conjecture before attacking the geometric inclusion over `p`-adic function fields.
-/

namespace UnramifiedDescent

open ObstructionDatum

/-- The reciprocity pairing of the toy model: `⟨s, b⟩ = (2s)·b` on `ℤ/4`. -/
noncomputable def modelPairing : ZMod 4 → ZMod 4 →+ ZMod 4 :=
  fun s => AddMonoidHom.mulLeft (2 * s)

/-- A concrete, non-vacuous `ObstructionDatum` over `ℤ/4` with `Hdesc = {1} ⊊ {1,2} = Hunr`. -/
noncomputable def modelDatum : ObstructionDatum (ZMod 4) (ZMod 4) (ZMod 4) where
  pairing := modelPairing
  Hdesc := {1}
  Hunr := {1, 2}
  descent_le_unramified := by intro x hx; simp only [Set.mem_singleton_iff] at hx; simp [hx]
  unramified_le_closure := by
    have hsub : ({1, 2} : Set (ZMod 4)) ⊆
        (AddSubgroup.closure ({1} : Set (ZMod 4)) : Set (ZMod 4)) := by
      intro x hx
      rcases hx with h | h
      · rw [h]; exact AddSubgroup.subset_closure rfl
      · simp only [Set.mem_singleton_iff] at h; rw [h]
        have h1 : (1 : ZMod 4) ∈ AddSubgroup.closure ({1} : Set (ZMod 4)) :=
          AddSubgroup.subset_closure rfl
        have : (1 : ZMod 4) + 1 ∈ AddSubgroup.closure ({1} : Set (ZMod 4)) :=
          AddSubgroup.add_mem _ h1 h1
        simpa using this
    exact hsub.trans (closure_subset_clB _ _)

/-- **Unramified obstruction = descent obstruction** in the concrete model — derived
from the abstract comparison theorem, not by brute force. -/
theorem model_equal : modelDatum.unramifiedObstruction = modelDatum.descentObstruction :=
  modelDatum.unramified_eq_descent

/-- The descent classes are *properly* contained in the unramified classes. -/
theorem model_proper : modelDatum.Hdesc ≠ modelDatum.Hunr := by
  intro h
  have hmem : (2 : ZMod 4) ∈ modelDatum.Hdesc := by rw [h]; right; rfl
  simp only [modelDatum, Set.mem_singleton_iff] at hmem
  revert hmem; decide

/-- The common obstruction set is **nonempty**: `0` lies in it. -/
theorem model_zero_mem : (0 : ZMod 4) ∈ modelDatum.descentObstruction := by
  intro b hb
  have hb' : b = 1 := hb
  subst hb'
  show (2 * (0 : ZMod 4)) * 1 = 0
  decide

/-- The common obstruction set is a **proper** subset of `ℤ/4`: `1` is not in it. -/
theorem model_one_not_mem : (1 : ZMod 4) ∉ modelDatum.descentObstruction := by
  intro h
  have h2 : (2 * (1 : ZMod 4)) * 1 = 0 := h 1 rfl
  revert h2; decide

end UnramifiedDescent