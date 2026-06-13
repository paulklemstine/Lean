/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Discrete Dynamics of Self-Modifying Computation

The foundational file `Catalog/Computation/SelfModifyingHalt.lean` showed that a
self-modifying machine is *behaviourally* a standard machine over the product space
`P × S` (`selfmod_halts_iff_standard`), so its halting problem is Turing-equivalent to
the classical one.  That result is about *behaviour*.  This file pushes past behaviour
into the **dynamics** of the orbit itself.

A machine that never halts (`SelfModMachine.Total`) is, on a finite configuration
space, a *self-map* `dyn : P × S → P × S`.  We transport the elementary theory of
finite dynamical systems through the bridge lemma `run_eq_iter` (run = iterate of
`dyn`) and extract three structural facts:

* **Finiteness makes prediction trivial.**  `orbit_mem_initial_segment` confines every
  iterate to the first `card (P × S)` steps, so `selfmod_reaches_bad_iff_bounded` turns
  an infinite-horizon orbit property into a bounded search.
* **Finiteness forces self-reproduction.**  `selfmod_quine_cycle` shows a total finite
  machine re-enters a previously visited configuration within `card (P × S)` steps — a
  finitary Kleene/quine fixed point.
* **Reachability — not step complexity — is where control fails.**
  `alignment_obstruction` / `selfmod_alignment_obstruction` show that under strong
  connectivity a single misaligned state poisons the whole space: there is no nonempty
  forward-invariant safe region, and every start reaches a bad state.

## Main results

* `FiniteDynamics.dyn_eventually_periodic`
* `FiniteDynamics.orbit_mem_initial_segment`
* `FiniteDynamics.alignment_obstruction`
* `selfmod_quine_cycle`
* `selfmod_reaches_bad_iff_bounded`
* `selfmod_alignment_obstruction`
-/

import Mathlib
import Catalog.Computation.SelfModifyingHalt

open Function

namespace SelfModHalt

/-
-- !-- Lab Notebook (Section 1: abstract finite dynamics) -- !--
Hypothesis: On a finite type every self-map is "eventually periodic with bounded
preperiod and period", and its whole orbit is already visible in the first `card`
iterates.  Strong connectivity should then make a single bad point unavoidable.
Result: All four abstract lemmas below proved with `sorry = 0`.
Insight: The single pigeonhole collision `i < j ≤ card`, `f^[i] = f^[j]`, is the
generator of *every* finite-dynamics fact used downstream — eventual periodicity,
orbit confinement, and (via `ForwardInvariant`) the alignment obstruction.
Failure analysis: A naive `rw [← e]` to fold `n = (n - p) + p` rewrote both sides;
the fix was a directed `conv_lhs` rewrite.  `omega` discharges all index arithmetic.
-/

namespace FiniteDynamics

variable {A : Type*}

/-- `Reaches f x y`: `y` lies on the forward orbit of `x` under `f`. -/
def Reaches (f : A → A) (x y : A) : Prop := ∃ n : ℕ, f^[n] x = y

/-- `f` is strongly connected: every configuration reaches every other. -/
def StronglyConnected (f : A → A) : Prop := ∀ x y, Reaches f x y

/-- A set is forward-invariant under `f` if `f` maps it into itself. -/
def ForwardInvariant (f : A → A) (R : Set A) : Prop := ∀ x ∈ R, f x ∈ R

section Finite

variable [Fintype A]

/-- **Pigeonhole collision.**  On a finite type, two distinct iterate indices in
`[0, card A]` already collide.

-- !-- The orbit map `Fin (card+1) → A` cannot be injective (`card+1 > card`), so
two iterate indices agree; order them. --!-- -/
theorem iterate_collision (f : A → A) (x : A) :
    ∃ i j : ℕ, i < j ∧ j ≤ Fintype.card A ∧ f^[i] x = f^[j] x := by
  have h : Fintype.card A < Fintype.card (Fin (Fintype.card A + 1)) := by simp
  obtain ⟨a, b, hab, hfab⟩ :=
    Fintype.exists_ne_map_eq_of_card_lt (fun k : Fin (Fintype.card A + 1) => f^[k] x) h
  rcases lt_or_gt_of_ne hab with h1 | h1
  · exact ⟨a, b, h1, Nat.lt_succ_iff.mp b.2, hfab⟩
  · exact ⟨b, a, h1, Nat.lt_succ_iff.mp a.2, hfab.symm⟩

/-- **Eventual periodicity with bounded preperiod and period.**  Every point of a
finite self-map reaches, within `card A` steps, a point that is periodic with a
positive period `≤ card A`.

-- !-- Take the collision `i < j`; the preperiod is `i` and the period is `j - i`,
since `f^[j-i] (f^[i] x) = f^[j] x = f^[i] x`. --!-- -/
theorem dyn_eventually_periodic (f : A → A) (x : A) :
    ∃ k p : ℕ, k ≤ Fintype.card A ∧ 0 < p ∧ p ≤ Fintype.card A ∧
      f^[p] (f^[k] x) = f^[k] x := by
  obtain ⟨i, j, hij, hj, heq⟩ := iterate_collision f x
  refine ⟨i, j - i, le_trans (le_of_lt hij) hj, by omega, by omega, ?_⟩
  rw [← Function.iterate_add_apply]
  have : j - i + i = j := by omega
  rw [this, heq]

/-- **Orbit confinement.**  Every iterate of a finite self-map already occurs among
the first `card A + 1` iterates.

-- !-- From the collision, the orbit is periodic past index `i` with period `p`;
strong induction folds any `n > card A` down by `p` while staying `≥ i`. --!-- -/
theorem orbit_mem_initial_segment (f : A → A) (x : A) (n : ℕ) :
    ∃ k : ℕ, k ≤ Fintype.card A ∧ f^[n] x = f^[k] x := by
  obtain ⟨i, j, hij, hj, heq⟩ := iterate_collision f x
  set p := j - i with hp
  have hper : ∀ m, i ≤ m → f^[m + p] x = f^[m] x := by
    intro m hm
    have : m + p = (m - i) + (i + p) := by omega
    rw [this, Function.iterate_add_apply]
    have hjj : i + p = j := by omega
    rw [hjj, ← heq, ← Function.iterate_add_apply]
    congr 1; omega
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    by_cases hn : n ≤ Fintype.card A
    · exact ⟨n, hn, rfl⟩
    · have hge : i ≤ n - p := by omega
      have e : n - p + p = n := by omega
      have key : f^[n] x = f^[n - p] x := by
        conv_lhs => rw [← e]; rw [hper _ hge]
      obtain ⟨k, hk, hkeq⟩ := ih (n - p) (by omega)
      exact ⟨k, hk, by rw [key, hkeq]⟩

end Finite

/-- Forward invariance is preserved by iteration. -/
theorem iterate_mem_of_forwardInvariant (f : A → A) (R : Set A)
    (h : ForwardInvariant f R) {x : A} (hx : x ∈ R) (n : ℕ) : f^[n] x ∈ R := by
  induction n with
  | zero => simpa
  | succ n ih => rw [Function.iterate_succ_apply']; exact h _ ih

/-- A nonempty forward-invariant set of a strongly connected self-map is everything.

-- !-- Pick `x ∈ R`; for any `y`, strong connectivity gives `f^[n] x = y`, and
`iterate_mem_of_forwardInvariant` keeps the orbit inside `R`. --!-- -/
theorem forwardInvariant_eq_univ_of_stronglyConnected (f : A → A)
    (hsc : StronglyConnected f) (R : Set A) (hne : R.Nonempty)
    (hinv : ForwardInvariant f R) : R = Set.univ := by
  ext y
  simp only [Set.mem_univ, iff_true]
  obtain ⟨x, hx⟩ := hne
  obtain ⟨n, hn⟩ := hsc x y
  rw [← hn]; exact iterate_mem_of_forwardInvariant f R hinv hx n

/-- **Alignment obstruction (abstract).**  If a self-map is strongly connected and at
least one state is "bad", then there is no nonempty forward-invariant set of
exclusively safe (non-bad) states: no state-based monitor can confine the dynamics to
a safe region.

-- !-- A safe forward-invariant region would, by
`forwardInvariant_eq_univ_of_stronglyConnected`, be all of `A` — but it must then
contain the bad state, contradiction. --!-- -/
theorem alignment_obstruction (f : A → A) (hsc : StronglyConnected f)
    (bad : A → Prop) (hbad : ∃ b, bad b) :
    ¬ ∃ R : Set A, R.Nonempty ∧ ForwardInvariant f R ∧ (∀ x ∈ R, ¬ bad x) := by
  rintro ⟨R, hne, hinv, hsafe⟩
  obtain ⟨b, hb⟩ := hbad
  have : R = Set.univ := forwardInvariant_eq_univ_of_stronglyConnected f hsc R hne hinv
  exact hsafe b (this ▸ Set.mem_univ b) hb

/-- Under strong connectivity, every state reaches every bad state, hence reaches the
bad set. -/
theorem reaches_bad_of_stronglyConnected (f : A → A) (hsc : StronglyConnected f)
    (bad : A → Prop) {b : A} (hb : bad b) (x : A) :
    ∃ n : ℕ, bad (f^[n] x) := by
  obtain ⟨n, hn⟩ := hsc x b
  exact ⟨n, hn ▸ hb⟩

end FiniteDynamics

/-
-- !-- Lab Notebook (Section 2: self-modifying machines as dynamics) -- !--
Hypothesis: A `Total` (never-halting) self-modifying machine is exactly a self-map
`dyn` on `P × S`, with `run = iterate dyn`; the abstract finite-dynamics facts then
specialize to quine cycles, bounded safety search, and an alignment obstruction.
Result: `run_eq_iter`, `selfmod_quine_cycle`, `selfmod_reaches_bad_iff_bounded`, and
`selfmod_alignment_obstruction` all proved with `sorry = 0`.
Insight: `dyn` is `(m.step p s).get _`; the only content of the bridge is the trivial
`StdMachine`-style induction `run_eq_iter`.  After that the machine theory IS the
dynamics theory — self-modification adds *no* dynamical content on finite memory.
Failure analysis: `Option.some_get` is the clean way to discharge the `get`/`some`
round-trip in `step_eq_dyn`; unfolding the `toStd` match directly tripped the
dependent-`get` motive.
-/

variable {P S : Type*}

/-- A self-modifying machine is **total** if it never halts. -/
def SelfModMachine.Total (m : SelfModMachine P S) : Prop := ∀ p s, m.step p s ≠ none

/-- The one-step **dynamics** of a total machine on its configuration space `P × S`. -/
noncomputable def SelfModMachine.dyn (m : SelfModMachine P S) (h : m.Total) :
    P × S → P × S :=
  fun c => (m.step c.1 c.2).get (Option.isSome_iff_ne_none.mpr (h c.1 c.2))

/-- For a total machine, a step is literally an application of `dyn`. -/
theorem step_eq_dyn (m : SelfModMachine P S) (h : m.Total) (p : P) (s : S) :
    m.step p s = some (m.dyn h (p, s)) := by
  rw [SelfModMachine.dyn, Option.some_get]

/-- **Bridge lemma: run = iterate of `dyn`.**  Running a total machine for `n` steps
is iterating its dynamics `n` times.

-- !-- Induction on `n`: the successor step rewrites `m.step` to `some (dyn …)` via
`step_eq_dyn`, then folds into `iterate_succ_apply`. --!-- -/
theorem run_eq_iter (m : SelfModMachine P S) (h : m.Total)
    (cfg : SelfModConfig P S) (n : ℕ) :
    m.run cfg n = some ⟨((m.dyn h)^[n] (cfg.prog, cfg.state)).1,
                        ((m.dyn h)^[n] (cfg.prog, cfg.state)).2⟩ := by
  induction n generalizing cfg with
  | zero => rfl
  | succ n ih =>
    rw [Function.iterate_succ_apply]
    simp only [SelfModMachine.run, step_eq_dyn m h cfg.prog cfg.state,
      ih ⟨(m.dyn h (cfg.prog, cfg.state)).1, (m.dyn h (cfg.prog, cfg.state)).2⟩]

/-- A total machine genuinely runs forever. -/
theorem run_ne_none_of_total (m : SelfModMachine P S) (h : m.Total)
    (cfg : SelfModConfig P S) (n : ℕ) : m.run cfg n ≠ none := by
  rw [run_eq_iter m h cfg n]; exact Option.some_ne_none _

/-- **Finitary quine / Kleene cycle.**  A total self-modifying machine on a finite
configuration space re-enters a previously visited configuration within
`card (P × S)` steps, and runs forever.

-- !-- `run = some (iterate dyn)` (via `run_eq_iter`), and `iterate_collision` for
`dyn` on the finite space `P × S` gives equal iterates at `i < j ≤ card`; equal
iterates give equal `run`s. --!-- -/
theorem selfmod_quine_cycle [Fintype P] [Fintype S]
    (m : SelfModMachine P S) (h : m.Total) (cfg : SelfModConfig P S) :
    ∃ i j : ℕ, i < j ∧ j ≤ Fintype.card (P × S) ∧
      m.run cfg i = m.run cfg j ∧ (∀ n, m.run cfg n ≠ none) := by
  obtain ⟨i, j, hij, hj, heq⟩ :=
    FiniteDynamics.iterate_collision (m.dyn h) (cfg.prog, cfg.state)
  refine ⟨i, j, hij, hj, ?_, run_ne_none_of_total m h cfg⟩
  rw [run_eq_iter m h cfg i, run_eq_iter m h cfg j, heq]

/-- **Bounded safety search.**  For a total machine on finite memory, "the orbit ever
enters the region `R`" is equivalent to entering `R` within `card (P × S)` steps:
self-modification adds no analytic difficulty to infinite-horizon safety checking.

-- !-- The reverse implication is trivial; the forward one uses
`orbit_mem_initial_segment` to replace any witnessing step `n` by an equal-orbit step
`k ≤ card`. --!-- -/
theorem selfmod_reaches_bad_iff_bounded [Fintype P] [Fintype S]
    (m : SelfModMachine P S) (h : m.Total) (cfg : SelfModConfig P S)
    (R : P × S → Prop) :
    (∃ n, R ((m.dyn h)^[n] (cfg.prog, cfg.state))) ↔
    (∃ n ≤ Fintype.card (P × S), R ((m.dyn h)^[n] (cfg.prog, cfg.state))) := by
  constructor
  · rintro ⟨n, hn⟩
    obtain ⟨k, hk, hkeq⟩ :=
      FiniteDynamics.orbit_mem_initial_segment (m.dyn h) (cfg.prog, cfg.state) n
    exact ⟨k, hk, hkeq ▸ hn⟩
  · rintro ⟨n, _, hn⟩; exact ⟨n, hn⟩

/-- **Alignment obstruction for self-modifying machines.**  If the dynamics of a total
machine are strongly connected and a single configuration is bad, then:

* there is no nonempty forward-invariant safe region (no state monitor can keep the
  machine aligned), and
* every starting configuration eventually reaches a bad configuration.

-- !-- Both parts specialize `FiniteDynamics.alignment_obstruction` and
`FiniteDynamics.reaches_bad_of_stronglyConnected` to `dyn`. --!-- -/
theorem selfmod_alignment_obstruction
    (m : SelfModMachine P S) (h : m.Total)
    (hsc : FiniteDynamics.StronglyConnected (m.dyn h))
    (bad : P × S → Prop) (b : P × S) (hb : bad b) :
    (¬ ∃ R : Set (P × S), R.Nonempty ∧ FiniteDynamics.ForwardInvariant (m.dyn h) R ∧
        (∀ x ∈ R, ¬ bad x)) ∧
    (∀ cfg : SelfModConfig P S, ∃ n, bad ((m.dyn h)^[n] (cfg.prog, cfg.state))) := by
  refine ⟨FiniteDynamics.alignment_obstruction (m.dyn h) hsc bad ⟨b, hb⟩, ?_⟩
  intro cfg
  exact FiniteDynamics.reaches_bad_of_stronglyConnected (m.dyn h) hsc bad hb _

end SelfModHalt