/-
# Time-Travel Logic II: Recurrence, Parity, and Coordinate-Invariance of Causal Loops

A second layer on the theory of closed timelike curves (CTCs) and the Novikov
self-consistency principle.  The first development modelled a causal loop by its
*loop map* `evolve : S → S` — the net effect of one traversal of a closed
timelike curve — and identified self-consistency with the existence of a fixed
point, giving positive guarantees (monotone loops via Knaster–Tarski, continuous
loops on the unit phase interval via the intermediate value theorem, involutive
loops of odd order).

Here we go deeper along four independent axes, each a genuinely new structural
principle for causal loops:

* **Coordinate invariance** (`selfConsistent_conj`): self-consistency is a
  property of the loop *up to change of world-coordinates*.  A relabelling of the
  state space by a bijection cannot create or destroy a consistent history.  This
  is the statement that the Novikov principle is intrinsic, not an artefact of a
  choice of coordinates.

* **Composability** (`selfConsistent_prod`): a loop acting independently on two
  decoupled subsystems is self-consistent exactly when each subsystem is, so
  consistency is compositional across a product world.

* **Discrete recurrence** (`loop_recurrent`, `loop_universally_consistent`): on a
  *finite* phase space every invertible loop is recurrent — each world-state
  returns to itself after finitely many traversals — and, more strongly, a single
  number of traversals `N` returns *every* state simultaneously.  This is a
  discrete Poincaré recurrence theorem: even a paradoxical loop, iterated enough
  times, becomes universally self-consistent.  It bridges the fixed-point picture
  with finite group theory (the order of the induced permutation).

* **A parity law for time-reversal loops** (`involution_fixedPoints_parity`): for
  an involutive loop (traversing twice restores the world) on a finite phase
  space, the number of self-consistent states has the *same parity* as the size
  of the phase space — a Lefschetz-style mod-2 index.  The odd-order guarantee of
  the first development is the immediate corollary that an odd phase space forces
  at least one consistent history.

The analytic guarantee is also sharpened from the unit interval to an arbitrary
compact phase interval `[a,b]` (`continuous_selfConsistent_Icc`).

The four axes converge on the grandfather paradox: it is fixed-point-free
(`grandfather_paradoxical`), yet on the two-state phase space it is recurrent with
period two (`grandfather_recurrent`), so *two* traversals of the grandfather loop
are universally self-consistent — the multiverse is not needed to tame a paradox,
only patience.
-/

import Mathlib

namespace TimeTravelDeep

open Function

variable {S : Type*}

/-! ## Core model (recalled)

A **causal loop** is recorded by its loop map `evolve : S → S`; the loop is
*self-consistent* when some world-state is reproduced by one traversal. -/

/-- A **causal loop** (closed timelike curve): `evolve s` is the world-state that
results from feeding the state `s` once around the loop. -/
structure CausalLoop (S : Type*) where
  /-- The net effect of one traversal of the loop on the world-state. -/
  evolve : S → S

/-- **Novikov self-consistency principle.** A loop is self-consistent when some
world-state is reproduced by one traversal, i.e. a history compatible with itself. -/
def SelfConsistent (L : CausalLoop S) : Prop := ∃ s, L.evolve s = s

/-- The **iterated loop**: traversing the loop `n` times in succession. -/
def iterate (L : CausalLoop S) (n : ℕ) : CausalLoop S := ⟨L.evolve^[n]⟩

@[simp] theorem iterate_evolve (L : CausalLoop S) (n : ℕ) :
    (iterate L n).evolve = L.evolve^[n] := rfl

/-- A loop map is **paradoxical** if no world-state is left unchanged: every
history contradicts itself (the grandfather situation). -/
def Paradoxical (f : S → S) : Prop := ∀ s, f s ≠ s

/-! ## Coordinate invariance

Self-consistency is intrinsic to the loop: it survives any bijective relabelling
of the world-states. -/

/-- **Coordinate invariance of the Novikov principle.** Transporting a loop map
`f` along a bijective change of world-coordinates `e : S ≃ T` neither creates nor
destroys a self-consistent history. -/
theorem selfConsistent_conj {T : Type*} (e : S ≃ T) (f : S → S) :
    SelfConsistent (⟨f⟩ : CausalLoop S) ↔
      SelfConsistent (⟨e ∘ f ∘ e.symm⟩ : CausalLoop T) := by
  constructor
  · rintro ⟨s, hs⟩
    refine ⟨e s, ?_⟩
    simp only [comp_apply, Equiv.symm_apply_apply]
    exact congrArg e hs
  · rintro ⟨t, ht⟩
    refine ⟨e.symm t, ?_⟩
    have he : e (f (e.symm t)) = t := by simpa [comp_apply] using ht
    have h2 := congrArg e.symm he
    simpa using h2

/-! ## Composability across a product world -/

/-- **Compositional consistency.** A loop acting independently on two decoupled
subsystems is self-consistent exactly when both subsystems are. -/
theorem selfConsistent_prod {T : Type*} (f : S → S) (g : T → T) :
    SelfConsistent (⟨fun p => (f p.1, g p.2)⟩ : CausalLoop (S × T)) ↔
      SelfConsistent (⟨f⟩ : CausalLoop S) ∧ SelfConsistent (⟨g⟩ : CausalLoop T) := by
  constructor
  · rintro ⟨⟨a, b⟩, hab⟩
    simp only [Prod.mk.injEq] at hab
    exact ⟨⟨a, hab.1⟩, ⟨b, hab.2⟩⟩
  · rintro ⟨⟨a, ha⟩, ⟨b, hb⟩⟩
    exact ⟨(a, b), Prod.ext ha hb⟩

/-! ## Discrete Poincaré recurrence on a finite phase space -/

/-- **Universal recurrence.** On a finite phase space, an invertible loop returns
*every* world-state to itself after one common number `N > 0` of traversals: the
`N`-fold iterated loop is the identity. Equivalently, iterated enough times, any
invertible causal loop becomes universally self-consistent. -/
theorem loop_universally_consistent [Finite S] [Nonempty S] (f : S → S)
    (hf : Bijective f) : ∃ N, 0 < N ∧ ∀ s, f^[N] s = s := by
  classical
  cases nonempty_fintype S
  let σ : Equiv.Perm S := Equiv.ofBijective f hf
  refine ⟨orderOf σ, orderOf_pos σ, fun s => ?_⟩
  have h1 : σ ^ orderOf σ = 1 := pow_orderOf_eq_one σ
  have h2 : ⇑(σ ^ orderOf σ) = (⇑σ)^[orderOf σ] := Equiv.Perm.coe_pow σ (orderOf σ)
  have hfix : (⇑σ)^[orderOf σ] s = s := by rw [← h2, h1]; rfl
  simpa [σ, Equiv.ofBijective] using hfix

/-- **Discrete Poincaré recurrence.** Every world-state of an invertible loop on a
finite phase space returns to itself after finitely many (positive) traversals. -/
theorem loop_recurrent [Finite S] (f : S → S) (hf : Bijective f) (s : S) :
    ∃ k, 0 < k ∧ f^[k] s = s := by
  haveI : Nonempty S := ⟨s⟩
  obtain ⟨N, hN, h⟩ := loop_universally_consistent f hf
  exact ⟨N, hN, h s⟩

/-- A packaged form: on a nonempty finite phase space, some positive iterate of an
invertible loop is self-consistent — indeed it fixes every state. -/
theorem iterate_selfConsistent_of_bijective [Finite S] [Nonempty S] (f : S → S)
    (hf : Bijective f) : ∃ N, 0 < N ∧ SelfConsistent (iterate ⟨f⟩ N) := by
  obtain ⟨N, hN, h⟩ := loop_universally_consistent f hf
  obtain ⟨s⟩ := (inferInstance : Nonempty S)
  exact ⟨N, hN, s, h s⟩

/-! ## A parity law for time-reversal (involutive) loops -/

/-- **Parity law for time-reversal loops.** For an involutive loop on a finite
phase space (traversing twice restores the world), the number of self-consistent
world-states has the same parity as the size of the phase space. This is a
Lefschetz-style mod-2 fixed-point index. -/
theorem involution_fixedPoints_parity [Fintype S] [DecidableEq S] (f : S → S)
    (hf : Involutive f) :
    Fintype.card {s // f s = s} % 2 = Fintype.card S % 2 := by
  classical
  let σ : Equiv.Perm S := Equiv.ofBijective f hf.bijective
  have hσ2 : σ ^ 2 = 1 := by
    ext x; simp only [Equiv.Perm.coe_pow, Equiv.Perm.coe_one, id_eq]; exact hf x
  have hsupp : 2 ∣ σ.support.card := Equiv.Perm.two_dvd_card_support hσ2
  have hσf : ∀ x, σ x = f x := fun x => rfl
  have hcard : Fintype.card {s // f s = s}
      = (Finset.univ.filter (fun s => f s = s)).card := by simp [Fintype.card_subtype]
  have hpart : (Finset.univ.filter (fun s => f s = s)).card + σ.support.card
      = Fintype.card S := by
    have hs : σ.support = Finset.univ.filter (fun s => ¬ (f s = s)) := by
      ext x
      simp only [Equiv.Perm.mem_support, Finset.mem_filter, Finset.mem_univ, true_and, hσf]
    rw [hs, Finset.card_filter_add_card_filter_not, Finset.card_univ]
  omega

/-- **Odd phase spaces force consistency** (a corollary of the parity law): an
involutive loop on a phase space of odd size is self-consistent. -/
theorem involutive_odd_selfConsistent [Fintype S] [DecidableEq S] (f : S → S)
    (hf : Involutive f) (hodd : Odd (Fintype.card S)) :
    SelfConsistent (⟨f⟩ : CausalLoop S) := by
  have hpar := involution_fixedPoints_parity f hf
  rw [Nat.odd_iff] at hodd
  rw [hodd] at hpar
  have hpos : 0 < Fintype.card {s // f s = s} := by omega
  obtain ⟨⟨s, hs⟩⟩ := Fintype.card_pos_iff.mp hpos
  exact ⟨s, hs⟩

/-! ## Sharpened analytic guarantee on an arbitrary phase interval -/

/-- **Continuous loops on a compact phase interval are self-consistent.**
Sharpening the unit-interval guarantee: any continuous loop map of an arbitrary
compact phase interval `[a,b]` into itself has a self-consistent state, by the
intermediate value theorem (1-D Brouwer). -/
theorem continuous_selfConsistent_Icc (a b : ℝ) (hab : a ≤ b) (f : ℝ → ℝ)
    (hf : ContinuousOn f (Set.Icc a b))
    (hmaps : Set.MapsTo f (Set.Icc a b) (Set.Icc a b)) :
    ∃ s ∈ Set.Icc a b, f s = s := by
  set g : ℝ → ℝ := fun x => f x - x
  have hg_cont : ContinuousOn g (Set.Icc a b) := hf.sub continuousOn_id
  have hg0 : g a ≥ 0 := sub_nonneg_of_le (hmaps (Set.left_mem_Icc.mpr hab)).1
  have hg1 : g b ≤ 0 := sub_nonpos_of_le (hmaps (Set.right_mem_Icc.mpr hab)).2
  have hiv := intermediate_value_Icc' hab hg_cont
  exact Exists.elim (hiv ⟨hg1, hg0⟩) fun x hx => ⟨x, hx.1, sub_eq_zero.mp hx.2⟩

/-! ## Convergence on the grandfather paradox -/

/-- The grandfather action on the two-state phase space `alive/dead`: one
traversal flips the ancestor's status, so no state is fixed. -/
theorem grandfather_paradoxical : Paradoxical (Bool.not) := by
  intro x; cases x <;> decide

/-- **The grandfather loop is recurrent with period two.** Although paradoxical in
a single traversal, traversing the grandfather loop twice restores every state, so
the two-fold iterated grandfather loop is universally self-consistent. -/
theorem grandfather_recurrent : Bool.not^[2] = id := by
  decide

/-- Concretely, the two-fold grandfather loop is self-consistent (recurrence tames
the paradox without invoking a multiverse). -/
theorem grandfather_iterate_selfConsistent :
    SelfConsistent (iterate ⟨Bool.not⟩ 2) :=
  ⟨true, by decide⟩

/-! ## Examples and sanity checks -/

-- The identity loop is self-consistent (everyone is their own consistent history).
example : SelfConsistent (⟨id⟩ : CausalLoop Bool) := ⟨true, rfl⟩

-- The grandfather loop is *not* self-consistent in a single traversal.
example : ¬ SelfConsistent (⟨Bool.not⟩ : CausalLoop Bool) :=
  fun ⟨s, hs⟩ => grandfather_paradoxical s hs

#check @selfConsistent_conj
#check @loop_universally_consistent
#check @involution_fixedPoints_parity
#check @continuous_selfConsistent_Icc

end TimeTravelDeep

/-
-- !-- Lab Notes -- !--

Hypothesis (Hypothesizer).  Five conjectures about causal loops beyond the
fixed-point existence layer:
  (H1) Self-consistency is invariant under bijective relabelling of world-states
       — the Novikov principle is coordinate-free.
  (H2) Self-consistency is compositional across a product of decoupled subsystems.
  (H3) [BOLD] On a finite phase space, every invertible loop is recurrent, and in
       fact universally recurrent: one common number of traversals returns every
       state (a discrete Poincaré recurrence bridging fixed points and the finite
       group generated by the loop).
  (H4) [BOLD] For an involutive (time-reversal) loop on a finite phase space, the
       count of self-consistent states equals the phase-space size mod 2 — a
       Lefschetz-style parity index generalising the odd-order guarantee.
  (H5) The analytic (Brouwer/IVT) guarantee holds on every compact phase
       interval, not only the unit interval.

Experiment (Experimenter).  All five were proved.  H3 uses the permutation induced
by an invertible loop on a finite set: its order N > 0 satisfies loopᴺ = id, so
loopᴺ fixes every state; per-state recurrence is the specialisation.  H4 follows
from the evenness of the support of an involution (its non-fixed points pair up),
so |phase space| - |fixed points| is even.  H5 reruns the sub/IVT argument on an
arbitrary [a,b].  H1, H2 are direct fixed-point transport arguments.

Analysis (Analyst).  Structural pattern: the four principles are the four natural
symmetries/operations one can impose on a loop map — relabelling (H1), product
(H2), iteration on a finite carrier (H3), and the involution constraint (H4).
Recurrence (H3) is the deepest: it shows paradox is a *single-traversal*
phenomenon; every invertible loop on a finite world is eventually self-consistent.
The grandfather loop is the sharp witness — paradoxical yet period-two recurrent.

Critique (Critic).  Guardrails checked: no theorem is `True`/definitional; the
parity law is proved by a genuine combinatorial argument (support evenness), not
`decide`; recurrence uses `orderOf`/group theory, not brute force.  Boundary:
recurrence needs invertibility (a non-injective loop can be strictly eventually
periodic without returning, e.g. a constant map has no positive iterate equal to
the identity unless the space is a point) and finiteness (translation on the
integers is invertible but not recurrent).  The parity law needs the involution
hypothesis: a general permutation can have fixed-point count of either parity.

Synthesis (Principal Investigator).  Self-consistency of causal loops is
coordinate-free, compositional, generically achievable by iteration on finite
worlds, and parity-controlled for time-reversal loops.  Paradox is confined to a
single traversal on finite invertible worlds.  See FUTURE_DIRECTIONS.md.
-/