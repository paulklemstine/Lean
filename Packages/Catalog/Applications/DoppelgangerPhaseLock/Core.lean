/-
# Doppelgänger Phase-Lock — Core theory

Two spatially separated but *identical* agents are modelled as two copies of one
deterministic reactive system

```
δ : S → I → S
```

(`S` = internal state space, `I` = alphabet of environmental stimuli).  Both
copies observe the *same* stimulus stream; the question of "quantum telepathic
synchronization" is thereby demystified into an exact mathematical question:

> for which `δ` does there exist a finite stimulus word `w` after which the two
> copies occupy the *same* internal state, no matter how far apart their initial
> states were?

This is exactly the classical notion of a **synchronizing (reset) word** for a
deterministic automaton, and this file develops it from scratch in the language
of phase-locking agents.

## Main definitions

* `Doppelganger.drive δ w s` — the state reached from `s` after the stimulus word `w`.
* `Doppelganger.Locks δ w` — `w` *phase-locks* the pair of agents: it maps **all**
  states to a common state.
* `Doppelganger.Mergeable δ s t` — the particular pair `(s,t)` can be locked.
* `Doppelganger.PhaseLocking δ` — some word locks the doppelgänger pair.

## Main results

* `Doppelganger.drive_append`, `Doppelganger.transitionHom` — the stimulus monoid acts
  on the state space; `w ↦ drive δ w` is a monoid *anti*-homomorphism
  `FreeMonoid I →* (Function.End S)ᵐᵒᵖ` (algebraic layer).
* `Doppelganger.locks_ideal` — the set of phase-locking words is a two-sided ideal of
  the free monoid of stimuli: *once telepathy is possible, no amount of extra noise,
  before or after, can destroy it*.
* `Doppelganger.Locks.flatten_of_mem` — a stimulus stream chopped into blocks locks as
  soon as **one** block locks (used for the quantitative rarity estimates).
* `Doppelganger.phaseLocking_iff_const_mem_range` — phase-locking is equivalent to the
  transition monoid containing a constant map (rank-one element).
* `Doppelganger.locked_forever` — phase-lock is absorbing: the diagonal is invariant.
-/
import Mathlib

namespace Doppelganger

variable {S I : Type*}

/-! ### The stimulus action -/

/-- `drive δ w s` is the state reached by an agent with transition rule `δ`, started in
state `s`, after observing the finite stimulus word `w` (left to right). -/
def drive (δ : S → I → S) (w : List I) (s : S) : S := w.foldl δ s

@[simp] lemma drive_nil (δ : S → I → S) (s : S) : drive δ [] s = s := rfl

@[simp] lemma drive_cons (δ : S → I → S) (i : I) (w : List I) (s : S) :
    drive δ (i :: w) s = drive δ w (δ s i) := rfl

lemma drive_eq_id_nil (δ : S → I → S) : drive δ ([] : List I) = id := rfl

/-- Concatenation of stimuli = composition of state maps (in the opposite order). -/
lemma drive_append (δ : S → I → S) (w v : List I) (s : S) :
    drive δ (w ++ v) s = drive δ v (drive δ w s) := by
  simp [drive]

/-- The length-`n` prefix of an infinite stimulus stream. -/
def pre (x : ℕ → I) (n : ℕ) : List I := List.ofFn fun i : Fin n => x i

@[simp] lemma length_pre (x : ℕ → I) (n : ℕ) : (pre x n).length = n := by simp [pre]

/-! ### Phase-locking -/

/-- The stimulus word `w` **phase-locks** the agents: after observing `w`, two copies of
the agent are in the same internal state whatever their initial states were. -/
def Locks (δ : S → I → S) (w : List I) : Prop := ∀ s t : S, drive δ w s = drive δ w t

/-- The particular pair of states `(s,t)` can be merged by some stimulus word. -/
def Mergeable (δ : S → I → S) (s t : S) : Prop := ∃ w : List I, drive δ w s = drive δ w t

/-- The agent design `δ` admits doppelgänger phase-lock. -/
def PhaseLocking (δ : S → I → S) : Prop := ∃ w : List I, Locks δ w

lemma Locks.mergeable {δ : S → I → S} {w : List I} (h : Locks δ w) (s t : S) :
    Mergeable δ s t := ⟨w, h s t⟩

lemma locks_iff_exists_const [Nonempty S] (δ : S → I → S) (w : List I) :
    Locks δ w ↔ ∃ c : S, ∀ s, drive δ w s = c := by
  constructor
  · intro h
    obtain ⟨s0⟩ := ‹Nonempty S›
    exact ⟨drive δ w s0, fun s => h s s0⟩
  · rintro ⟨c, hc⟩ s t; rw [hc, hc]

/-- Extra stimuli *after* a locking word cannot unlock the pair. -/
lemma Locks.append_right (δ : S → I → S) {w : List I} (h : Locks δ w) (v : List I) :
    Locks δ (w ++ v) := by
  intro s t; rw [drive_append, drive_append, h s t]

/-- Extra stimuli *before* a locking word cannot prevent the lock. -/
lemma Locks.append_left (δ : S → I → S) {w : List I} (h : Locks δ w) (u : List I) :
    Locks δ (u ++ w) := by
  intro s t; rw [drive_append, drive_append]; exact h _ _

/-- **The locking words form a two-sided ideal** of the stimulus monoid. -/
theorem locks_ideal (δ : S → I → S) {w : List I} (h : Locks δ w) (u v : List I) :
    Locks δ (u ++ w ++ v) := (h.append_left δ u).append_right δ v

/-- Once the doppelgängers are in phase, they stay in phase forever: the diagonal is an
absorbing set for the common dynamics. -/
theorem locked_forever (δ : S → I → S) {w : List I} {s t : S}
    (h : drive δ w s = drive δ w t) (v : List I) :
    drive δ (w ++ v) s = drive δ (w ++ v) t := by
  rw [drive_append, drive_append, h]

/-- If a stimulus stream is cut into blocks and *one* block already locks, the whole
stream locks. -/
lemma Locks.flatten_of_mem (δ : S → I → S) {u : List I} {bs : List (List I)}
    (hu : u ∈ bs) (h : Locks δ u) : Locks δ bs.flatten := by
  induction bs with
  | nil => simp at hu
  | cons b rest ih =>
      rcases List.mem_cons.mp hu with rfl | hmem
      · simpa using h.append_right δ rest.flatten
      · simpa using (ih hmem).append_left δ b

/-! ### The algebraic layer: the transition monoid -/

/-- The stimulus monoid acts on states; since `drive` composes contravariantly, this is
a monoid homomorphism into the *opposite* of the endomorphism monoid of `S`. -/
def transitionHom (δ : S → I → S) : FreeMonoid I →* (Function.End S)ᵐᵒᵖ where
  toFun w := MulOpposite.op (drive δ (FreeMonoid.toList w))
  map_one' := by apply MulOpposite.unop_injective; funext s; rfl
  map_mul' w v := by
    apply MulOpposite.unop_injective
    funext s
    exact drive_append δ _ _ s

@[simp] lemma transitionHom_apply (δ : S → I → S) (w : List I) (s : S) :
    (transitionHom δ (FreeMonoid.ofList w)).unop s = drive δ w s := rfl

/-- **Phase-lock ⟺ the transition monoid contains a rank-one (constant) element.** -/
theorem phaseLocking_iff_const_mem_range [Nonempty S] (δ : S → I → S) :
    PhaseLocking δ ↔
      ∃ f ∈ Set.range (transitionHom δ), ∃ c : S, (MulOpposite.unop f) = Function.const S c := by
  constructor
  · rintro ⟨w, hw⟩
    obtain ⟨s0⟩ := ‹Nonempty S›
    exact ⟨transitionHom δ (FreeMonoid.ofList w), ⟨_, rfl⟩, drive δ w s0,
      funext fun s => hw s s0⟩
  · rintro ⟨f, ⟨w, rfl⟩, c, hc⟩
    refine ⟨FreeMonoid.toList w, fun s t => ?_⟩
    have hconst : ∀ s, drive δ (FreeMonoid.toList w) s = c := fun s => congrFun hc s
    rw [hconst, hconst]

end Doppelganger