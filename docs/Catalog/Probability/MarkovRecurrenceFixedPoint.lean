/-
# Cycle 9: Recurrence as a **greatest modal fixed point**

Cycle 1 (`Logic.ProvabilityLogic.TangledSoundness`) characterised converse
well-foundedness by the *least* fixed point of the box operator.  This file settles the
dual question raised as Future Direction 3 of Cycle 7: what does the *greatest* fixed
point of the diamond operator compute on the support frame of a Markov chain?

## Main results

* `gfpDia` — the greatest post-fixed point of the diamond operator `diaOp`, built by hand
  (Knaster–Tarski: the union of all post-fixed sets), together with
  `gfpDia_postFixed`, `gfpDia_greatest` and `diaOp_gfpDia` showing it *is* a fixed point.
* `mem_diaOp_iff_sat_dia` — the operator is the semantic diamond `¬□¬`, so `gfpDia` is a
  genuinely modal object.
* `gfpDia_eq_reachesRecurrent` — **the identification**: on a *finite* frame the greatest
  fixed point of the diamond is exactly the set of worlds that can reach a world lying on
  a cycle.  One inclusion is a post-fixed-point argument, the other a pigeonhole on the
  orbit of a choice function.
* `recurrent_iff_exists_iterSound` — recurrence *is* positive internal soundness degree
  (Cycle 2), so `gfpDia` is the set of worlds that can reach a self-sound world.
* `exists_reachesRecurrent_of_rowStochastic`, `stepPow_reaches_recurrent` — the
  probabilistic readings: on a finite chain every state reaches a state with positive
  return probability; this strengthens Cycle 6's
  `exists_positive_sound_world_of_rowStochastic` from "some world" to "from every world".

## Critique — the naive form of the conjecture is **false**

Direction 3 conjectured that the greatest fixed point is the *recurrent* set (the union
of terminal strongly connected components).  It is not: `absorbChain` (the two-state
chain that jumps to state `1` and stays there) has state `0` transient yet in the
greatest fixed point, since `0` *reaches* the recurrent state `1`.  This is proved, not
asserted: `absorb_zero_mem_gfpDia`, `absorb_zero_not_recurrent`,
`gfpDia_ne_recurrent`.  The corrected statement — "reaches a recurrent world" — is what
`gfpDia_eq_reachesRecurrent` proves, and it is exactly the modal content of the diamond
gfp, since the basic modal language cannot distinguish a world from its successors'
future.

## Lab Notes

*Hypothesis (Stage 1).*  The gfp of the diamond detects the existence of an infinite
forward path; on a finite frame an infinite path must repeat a world.

*Experiment (Stage 2).*  Formalised the union-of-post-fixed-points construction rather
than `OrderHom.gfp`, so that "greatest" is available as a one-line inclusion and the
fixed-point property is proved by the `insert w X` trick.  The pigeonhole reuses the
orbit technique of `exists_positive_sound_world_of_rowStochastic`, but with a choice
function that is only defined on the post-fixed set, which forced the use of `choose!`
plus an invariance lemma (`iterate_mem`).

*Analysis (Stage 3).*  The gap between `gfpDia` and the recurrent set is exactly
transience, and it is invisible to the diamond because `diaOp` only ever looks forward.
Recovering the recurrent set needs a *cyclic* operator (`iterR F m w w`), not a fixed
point of a monotone operator on sets.

*Critique (Stage 4).*  Every statement below is about a genuinely nonempty situation:
the counterexample is exhibited with proofs of both halves, and the main equality is an
equality of sets, not an inclusion.
-/
import Mathlib
import Probability.MarkovExponentBounds

namespace MarkovModal

open GLPLogic TangledSoundness FrameDefinability

variable {S : Type} {α : Type}

/-! ## Part A — The diamond operator and its greatest fixed point -/

/-- The **diamond operator** on sets of worlds: `diaOp F X` is the set of worlds with a
successor in `X`. -/
def diaOp (F : KFrame) (X : Set F.W) : Set F.W := {w | ∃ v, F.R w v ∧ v ∈ X}

theorem diaOp_mono (F : KFrame) {X Y : Set F.W} (h : X ⊆ Y) : diaOp F X ⊆ diaOp F Y := by
  rintro w ⟨v, hv, hvX⟩
  exact ⟨v, hv, h hvX⟩

/-- `diaOp` is the semantic diamond `¬□¬`: membership in `diaOp F X` is falsity of
`□¬p` at `w` under the valuation that reads `p` as `X`. -/
theorem mem_diaOp_iff_sat_dia (F : KFrame) (X : Set F.W) (p : α) (w : F.W) :
    w ∈ diaOp F X ↔
      sat F (fun _ x => x ∈ X) w (.imp (.box (.imp (.var p) .bot)) .bot) := by
  constructor
  · rintro ⟨v, hv, hvX⟩ hbox
    exact hbox v hv hvX
  · intro h
    by_contra hno
    exact h (fun v hv hvX => hno ⟨v, hv, hvX⟩)

/-- A set is **post-fixed** for the diamond when each of its worlds has a successor
inside it. -/
def DiaPostFixed (F : KFrame) (X : Set F.W) : Prop := X ⊆ diaOp F X

/-- The **greatest fixed point of the diamond**, built as the union of all post-fixed
sets (Knaster–Tarski, by hand). -/
def gfpDia (F : KFrame) : Set F.W := {w | ∃ X : Set F.W, DiaPostFixed F X ∧ w ∈ X}

theorem gfpDia_greatest (F : KFrame) {X : Set F.W} (hX : DiaPostFixed F X) :
    X ⊆ gfpDia F := fun _ hw => ⟨X, hX, hw⟩

theorem gfpDia_postFixed (F : KFrame) : DiaPostFixed F (gfpDia F) := by
  rintro w ⟨X, hX, hwX⟩
  obtain ⟨v, hv, hvX⟩ := hX hwX
  exact ⟨v, hv, ⟨X, hX, hvX⟩⟩

/-- The greatest post-fixed point really is a fixed point. -/
theorem diaOp_gfpDia (F : KFrame) : diaOp F (gfpDia F) = gfpDia F := by
  apply Set.Subset.antisymm
  · rintro w ⟨v, hv, X, hX, hvX⟩
    refine ⟨insert w X, ?_, Set.mem_insert _ _⟩
    rintro x hx
    rcases hx with hx | hx
    · exact ⟨v, hx ▸ hv, Set.mem_insert_of_mem _ hvX⟩
    · obtain ⟨y, hy, hyX⟩ := hX hx
      exact ⟨y, hy, Set.mem_insert_of_mem _ hyX⟩
  · exact gfpDia_postFixed F

/-! ## Part B — Recurrence -/

/-- A world is **recurrent** when it lies on a cycle of positive length. -/
def Recurrent (F : KFrame) (w : F.W) : Prop := ∃ m, 0 < m ∧ iterR F m w w

/-- A world **reaches recurrence** when some recurrent world is accessible from it. -/
def ReachesRecurrent (F : KFrame) (w : F.W) : Prop :=
  ∃ v, (∃ k, iterR F k w v) ∧ Recurrent F v

/-- **Recurrence is positive internal soundness** (Cycle 2): a world lies on a cycle iff
it validates `□ᵐφ → φ` for some `m > 0`. -/
theorem recurrent_iff_exists_iterSound (F : KFrame) (p : α) (w : F.W) :
    Recurrent F w ↔ ∃ m, 0 < m ∧ IterSoundAt F α m w := by
  constructor
  · rintro ⟨m, hm, hcyc⟩
    exact ⟨m, hm, (iterSound_iff_cycle F p m w).mpr hcyc⟩
  · rintro ⟨m, hm, hs⟩
    exact ⟨m, hm, (iterSound_iff_cycle F p m w).mp hs⟩

/-- Reaching recurrence is a post-fixed property of the diamond. -/
theorem reachesRecurrent_postFixed (F : KFrame) :
    DiaPostFixed F {w | ReachesRecurrent F w} := by
  rintro w ⟨v, ⟨k, hk⟩, m, hm, hcyc⟩
  cases k with
  | zero =>
      -- `w = v` is itself recurrent: step once along its cycle
      cases hk
      obtain ⟨z, hz, hzw⟩ : ∃ z, F.R w z ∧ iterR F (m - 1) z w := by
        obtain ⟨m', rfl⟩ : ∃ m', m = m' + 1 := ⟨m - 1, by omega⟩
        obtain ⟨z, hz, hzw⟩ := hcyc
        exact ⟨z, hz, by simpa using hzw⟩
      exact ⟨z, hz, w, ⟨m - 1, hzw⟩, m, hm, hcyc⟩
  | succ k =>
      obtain ⟨z, hz, hzv⟩ := hk
      exact ⟨z, hz, v, ⟨k, hzv⟩, m, hm, hcyc⟩

/-- **The identification theorem.**  On a finite frame the greatest fixed point of the
diamond operator is exactly the set of worlds that reach a recurrent world. -/
theorem gfpDia_eq_reachesRecurrent (F : KFrame) [Fintype F.W] :
    gfpDia F = {w | ReachesRecurrent F w} := by
  apply Set.Subset.antisymm
  · rintro w ⟨X, hX, hwX⟩
    -- a choice function stepping inside `X`
    have hstepX : ∀ x : F.W, x ∈ X → ∃ y, F.R x y ∧ y ∈ X := fun x hx => hX hx
    choose! g hg1 hg2 using hstepX
    have hmem : ∀ i : ℕ, g^[i] w ∈ X := by
      intro i
      induction i with
      | zero => simpa using hwX
      | succ i ih => rw [Function.iterate_succ_apply']; exact hg2 _ ih
    have hpath : ∀ (t i : ℕ), iterR F t (g^[i] w) (g^[i + t] w) := by
      intro t
      induction t with
      | zero => intro i; simp [iterR]
      | succ t ih =>
          intro i
          refine ⟨g^[i + 1] w, ?_, ?_⟩
          · rw [Function.iterate_succ_apply']
            exact hg1 _ (hmem i)
          · have := ih (i + 1)
            have hidx : i + 1 + t = i + (t + 1) := by omega
            rwa [hidx] at this
    have hcard : Fintype.card F.W < Fintype.card (Fin (Fintype.card F.W + 1)) := by simp
    obtain ⟨a, b, hab, heq⟩ :=
      Fintype.exists_ne_map_eq_of_card_lt (fun i : Fin (Fintype.card F.W + 1) => g^[(i : ℕ)] w)
        hcard
    have key : ∀ a b : ℕ, a < b → g^[a] w = g^[b] w → ReachesRecurrent F w := by
      intro a b hlt hgab
      refine ⟨g^[a] w, ⟨a, by simpa using hpath a 0⟩, b - a, by omega, ?_⟩
      have := hpath (b - a) a
      have hidx : a + (b - a) = b := by omega
      rw [hidx, ← hgab] at this
      exact this
    rcases lt_or_gt_of_ne hab with hlt | hlt
    · exact key a b (Fin.lt_def.mp hlt) heq
    · exact key b a (Fin.lt_def.mp hlt) heq.symm
  · exact gfpDia_greatest F (reachesRecurrent_postFixed F)

/-- On a serial frame the greatest fixed point is everything. -/
theorem gfpDia_eq_univ_of_serial (F : KFrame) (hser : ∀ w : F.W, ∃ v, F.R w v) :
    gfpDia F = Set.univ := by
  refine Set.eq_univ_of_univ_subset ?_
  refine gfpDia_greatest F (X := Set.univ) ?_
  intro w _
  obtain ⟨v, hv⟩ := hser w
  exact ⟨v, hv, trivial⟩

/-- **Every world of a finite serial frame reaches recurrence.** -/
theorem reachesRecurrent_of_serial (F : KFrame) [Fintype F.W]
    (hser : ∀ w : F.W, ∃ v, F.R w v) (w : F.W) : ReachesRecurrent F w := by
  have h := gfpDia_eq_reachesRecurrent F
  rw [gfpDia_eq_univ_of_serial F hser] at h
  have hw : w ∈ {w : F.W | ReachesRecurrent F w} := by rw [← h]; trivial
  exact hw

/-! ## Part C — The probabilistic readings -/

/-- **From every state, recurrence is reachable.**  In a finite row-stochastic chain
every state can reach a state that returns to itself with positive probability — a
strengthening of Cycle 6's `exists_positive_sound_world_of_rowStochastic`, which produced
only *one* such state. -/
theorem exists_reachesRecurrent_of_rowStochastic [Fintype S] [DecidableEq S]
    {P : S → S → ℝ} (hP : RowStochastic P) (u : S) :
    ReachesRecurrent (suppFrame P) u :=
  reachesRecurrent_of_serial (suppFrame P) (fun w => serial_of_rowStochastic hP w) u

/-- The same statement in matrix language: positive `k`-step passage to a state with a
positive `m`-step return probability. -/
theorem stepPow_reaches_recurrent [Fintype S] [DecidableEq S] {P : S → S → ℝ}
    (hP : RowStochastic P) (u : S) :
    ∃ (v : S) (k m : ℕ), 0 < m ∧ 0 < stepPow P k u v ∧ 0 < stepPow P m v v := by
  obtain ⟨v, ⟨k, hk⟩, m, hm, hcyc⟩ := exists_reachesRecurrent_of_rowStochastic hP u
  exact ⟨v, k, m, hm, (stepPow_pos_iff hP.1 k u v).mpr hk,
    (stepPow_pos_iff hP.1 m v v).mpr hcyc⟩

/-- Modal form: from every state one reaches a state of positive internal soundness
degree. -/
theorem reaches_iterSound_of_rowStochastic [Fintype S] [DecidableEq S] {P : S → S → ℝ}
    (hP : RowStochastic P) (p : α) (u : S) :
    ∃ (v : S) (k m : ℕ), 0 < m ∧ iterR (suppFrame P) k u v ∧
      IterSoundAt (suppFrame P) α m v := by
  obtain ⟨v, ⟨k, hk⟩, m, hm, hcyc⟩ := exists_reachesRecurrent_of_rowStochastic hP u
  exact ⟨v, k, m, hm, hk, (iterSound_iff_cycle (suppFrame P) p m v).mpr hcyc⟩

/-! ## Part D — The counterexample: the gfp is *not* the recurrent set -/

/-- The two-state **absorbing chain**: from anywhere, jump to state `1` and stay. -/
def absorbChain : Fin 2 → Fin 2 → ℝ := fun _ j => if j = 1 then 1 else 0

theorem absorbChain_nonneg (i j : Fin 2) : 0 ≤ absorbChain i j := by
  unfold absorbChain; split <;> norm_num

@[simp] theorem absorbChain_pos_iff (i j : Fin 2) : 0 < absorbChain i j ↔ j = 1 := by
  unfold absorbChain; split <;> simp_all

theorem absorbChain_rowStochastic : RowStochastic absorbChain := by
  refine ⟨absorbChain_nonneg, fun u => ?_⟩
  rw [Fin.sum_univ_two]
  norm_num [absorbChain]

/-- State `1` is recurrent: it carries a self-loop. -/
theorem absorb_one_recurrent : Recurrent (suppFrame absorbChain) (1 : Fin 2) := by
  refine ⟨1, one_pos, ⟨(1 : Fin 2), ?_, rfl⟩⟩
  show (0 : ℝ) < absorbChain 1 1
  simp

/-- Everything reachable in a positive number of steps is state `1`. -/
theorem absorbChain_iterR_eq_one :
    ∀ (k : ℕ) (u v : Fin 2), 0 < k → iterR (suppFrame absorbChain) k u v → v = 1 := by
  intro k
  induction k with
  | zero => intro u v h; omega
  | succ k ih =>
      intro u v _ h
      obtain ⟨z, hz, hzv⟩ := h
      rcases Nat.eq_zero_or_pos k with hk | hk
      · subst hk
        have hz1 : z = (1 : Fin 2) := (absorbChain_pos_iff u z).mp hz
        cases hzv
        exact hz1
      · exact ih z v hk hzv

/-- State `0` is **transient**: it never returns to itself. -/
theorem absorb_zero_not_recurrent : ¬ Recurrent (suppFrame absorbChain) (0 : Fin 2) := by
  rintro ⟨m, hm, hcyc⟩
  have : (0 : Fin 2) = 1 := absorbChain_iterR_eq_one m 0 0 hm hcyc
  exact absurd this (by decide)

/-- Nevertheless state `0` belongs to the greatest fixed point of the diamond, because
it reaches the recurrent state `1`. -/
theorem absorb_zero_mem_gfpDia : (0 : Fin 2) ∈ gfpDia (suppFrame absorbChain) := by
  rw [gfpDia_eq_reachesRecurrent]
  refine ⟨(1 : Fin 2), ⟨1, ⟨(1 : Fin 2), ?_, rfl⟩⟩, absorb_one_recurrent⟩
  show (0 : ℝ) < absorbChain 0 1
  simp

/-- **Refutation of the naive conjecture.**  The greatest fixed point of the diamond is
strictly larger than the recurrent set: transient states that feed into a cycle are
modally indistinguishable from recurrent ones. -/
theorem gfpDia_ne_recurrent :
    gfpDia (suppFrame absorbChain) ≠ {w : Fin 2 | Recurrent (suppFrame absorbChain) w} := by
  intro h
  have h0 : (0 : Fin 2) ∈ {w : Fin 2 | Recurrent (suppFrame absorbChain) w} :=
    h ▸ absorb_zero_mem_gfpDia
  exact absorb_zero_not_recurrent h0

/-! ## Part E — Capstone -/

/-- **Cycle-9 capstone.**  For a finite row-stochastic chain: the greatest fixed point of
the diamond operator on the support frame is the whole state space, it coincides with the
set of states reaching a recurrent state, every state does reach a state of positive
internal soundness degree, and — by the absorbing witness — the greatest fixed point is
in general strictly larger than the recurrent set. -/
theorem markov_recurrence_capstone [Fintype S] [DecidableEq S] [Nonempty S]
    {P : S → S → ℝ} (hP : RowStochastic P) (p : α) :
    gfpDia (suppFrame P) = Set.univ ∧
      gfpDia (suppFrame P) = {w | ReachesRecurrent (suppFrame P) w} ∧
      (∀ u : S, ∃ (v : S) (k m : ℕ), 0 < m ∧ iterR (suppFrame P) k u v ∧
        IterSoundAt (suppFrame P) α m v) ∧
      gfpDia (suppFrame absorbChain) ≠
        {w : Fin 2 | Recurrent (suppFrame absorbChain) w} :=
  ⟨gfpDia_eq_univ_of_serial (suppFrame P) (fun w => serial_of_rowStochastic hP w),
   gfpDia_eq_reachesRecurrent (suppFrame P),
   fun u => reaches_iterSound_of_rowStochastic hP p u,
   gfpDia_ne_recurrent⟩

end MarkovModal