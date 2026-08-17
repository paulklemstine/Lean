/-
# Cycle 5: Every Finite Semantics of a Self-Consistent System Is Tangled

Cycle 4 built proof systems (`ModalSystem`) and showed that internal soundness and the
Löb axiom cannot coexist.  This cycle answers the remaining half of the mission
statement — *"tangled hierarchies are unavoidable in any system that can reason about
its own consistency"* — on the semantic side, and closes one step of the
`FUTURE_DIRECTIONS.md` degree-monoid conjecture.

## Main results

* `ModalSystem.serial_of_provesCon` — if a system proves its own consistency `¬□⊥`
  and a frame is sound for it, that frame is **serial**: no world is a dead end.
* `ModalSystem.isEmpty_of_provesCon_of_wf`, `glFrame_not_frameSound_of_provesCon` —
  hence no *nonempty* converse well-founded (GL) frame is sound for a system that
  asserts its own consistency.
* `finite_serial_has_cycle` and `ModalSystem.provesCon_finite_isTangled` —
  **the unavoidability theorem:** every *finite* frame sound for a system that proves
  its own consistency contains a cycle, so its reference graph (the transitive closure
  of accessibility) is tangled in the sense of `Logic.TangledHierarchies`.  Finiteness
  is the honest boundary: infinite serial frames such as `ω` with `n ↦ n+1` are
  loop-free, and that frame is exhibited (`omegaChain_serial_loopFree`) to show the
  hypothesis cannot be dropped.
* `iterSound_add`, `iterSound_zero` — the internal soundness degrees of a world form a
  submonoid of `(ℕ, +)`, the first step of conjecture C1.

## Relationship to catalog
Extends `Logic.ProvabilityLogic.SelfSoundSystems` (Cycle 4) and reuses `iterR`,
`transGen_of_iterR`, `sat_con_iff` from Cycle 3.
-/

import Mathlib
import Logic.ProvabilityLogic.SelfSoundSystems

namespace TangledSoundness

open GLPLogic

variable {α : Type}

/-! ## Part A — Degrees of internal soundness form a monoid -/

/-- Concatenating an `m`-step path with an `n`-step path gives an `m + n`-step path. -/
theorem iterR_add (F : KFrame) :
    ∀ (m n : ℕ) {u v w : F.W}, iterR F m u v → iterR F n v w → iterR F (m + n) u w := by
  intro m
  induction m with
  | zero =>
      rintro n u v w rfl h
      simpa using h
  | succ m ih =>
      rintro n u v w ⟨z, hz, hzv⟩ h
      rw [show m + 1 + n = (m + n) + 1 from by omega]
      exact ⟨z, hz, ih n hzv h⟩

/-- Degree `0` reflection is a tautology: every world has it. -/
theorem iterSound_zero (F : KFrame) (w : F.W) : IterSoundAt F α 0 w :=
  fun _ _ h => h

/-- **The soundness degrees of a world are closed under addition.**  If a world
validates `□ᵐφ → φ` and `□ⁿφ → φ` then it validates `□^(m+n)φ → φ`: internal soundness
degrees form a submonoid of `(ℕ, +)` (step one of conjecture C1). -/
theorem iterSound_add (F : KFrame) (p : α) {m n : ℕ} {w : F.W}
    (hm : IterSoundAt F α m w) (hn : IterSoundAt F α n w) :
    IterSoundAt F α (m + n) w := by
  have hcm := (iterSound_iff_cycle F p m w).mp hm
  have hcn := (iterSound_iff_cycle F p n w).mp hn
  exact (iterSound_iff_cycle F p (m + n) w).mpr (iterR_add F m n hcm hcn)

/-! ## Part B — Frame soundness and internal consistency -/

/-- A system is **frame-sound** for `F` when all its theorems hold everywhere in `F`. -/
def ModalSystem.FrameSound (S : ModalSystem α) (F : KFrame) : Prop :=
  ∀ φ : MFormula α, S.Thm φ → ∀ (V : α → F.W → Prop) (w : F.W), sat F V w φ

/-- **A system that asserts its own consistency has only serial semantics.**  If `S`
proves `¬□⊥` and `F` is sound for `S`, every world of `F` has a successor. -/
theorem ModalSystem.serial_of_provesCon (S : ModalSystem α) (F : KFrame)
    (hsound : S.FrameSound F) (h : S.Thm (MFormula.con (α := α))) (w : F.W) :
    ∃ v, F.R w v :=
  (sat_con_iff F (fun _ _ => False) w).mp (hsound _ h (fun _ _ => False) w)

/-- Consequently no nonempty converse well-founded frame can be sound for such a
system: the well-founded reading of provability dies as soon as consistency is
internally asserted. -/
theorem ModalSystem.isEmpty_of_provesCon_of_wf (S : ModalSystem α) (F : KFrame)
    (hsound : S.FrameSound F) (h : S.Thm (MFormula.con (α := α)))
    (hwf : WellFounded (Function.swap F.R)) : IsEmpty F.W := by
  by_contra hne
  rw [not_isEmpty_iff] at hne
  obtain ⟨w⟩ := hne
  obtain ⟨m, -, hm⟩ := hwf.has_min Set.univ ⟨w, trivial⟩
  obtain ⟨v, hv⟩ := S.serial_of_provesCon F hsound h m
  exact hm v trivial hv

/-- The GL-frame version: a GL frame sound for a self-consistent system is empty. -/
theorem glFrame_not_frameSound_of_provesCon (S : ModalSystem α) (M : GLFrame)
    (hsound : S.FrameSound M.toKFrame) (h : S.Thm (MFormula.con (α := α))) :
    IsEmpty M.W :=
  S.isEmpty_of_provesCon_of_wf M.toKFrame hsound h M.R_wf

/-! ## Part C — Finite serial frames contain cycles -/

/-- Iterating a successor-choice function follows accessibility. -/
theorem transGen_iterate {F : KFrame} {f : F.W → F.W} (hf : ∀ x, F.R x (f x))
    (w : F.W) : ∀ (i k : ℕ), 0 < k → Relation.TransGen F.R (f^[i] w) (f^[i + k] w) := by
  intro i k
  induction k with
  | zero => intro h; exact absurd h (lt_irrefl 0)
  | succ k ih =>
      intro _
      rcases Nat.eq_zero_or_pos k with hk | hk
      · subst hk
        simpa [Function.iterate_succ_apply'] using
          Relation.TransGen.single (hf (f^[i] w))
      · have hstep : Relation.TransGen F.R (f^[i + k] w) (f^[i + (k + 1)] w) := by
          have : f^[i + (k + 1)] w = f (f^[i + k] w) := by
            rw [show i + (k + 1) = (i + k) + 1 by ring, Function.iterate_succ_apply']
          rw [this]
          exact Relation.TransGen.single (hf (f^[i + k] w))
        exact (ih hk).trans hstep

/-- **Finite + serial ⇒ cyclic.**  A finite frame in which every world has a successor
contains a world lying on a cycle. -/
theorem finite_serial_has_cycle (F : KFrame) [Finite F.W] [Nonempty F.W]
    (hser : ∀ w : F.W, ∃ v, F.R w v) : ∃ w : F.W, Relation.TransGen F.R w w := by
  classical
  choose f hf using hser
  obtain ⟨w⟩ := ‹Nonempty F.W›
  obtain ⟨i, j, hij, hfe⟩ :=
    Finite.exists_ne_map_eq_of_infinite (fun n : ℕ => f^[n] w)
  rcases Nat.lt_or_ge i j with hlt | hge
  · refine ⟨f^[i] w, ?_⟩
    have hk : 0 < j - i := by omega
    have := transGen_iterate hf w i (j - i) hk
    rwa [show i + (j - i) = j by omega, ← hfe] at this
  · have hlt : j < i := by omega
    refine ⟨f^[j] w, ?_⟩
    have hk : 0 < i - j := by omega
    have := transGen_iterate hf w j (i - j) hk
    rwa [show j + (i - j) = i by omega, hfe] at this

/-- **The unavoidability theorem.**  Every finite, nonempty frame that is sound for a
proof system asserting its own consistency has a tangled reference graph: the
transitive closure of accessibility contains a two-cycle in the sense of
`Logic.TangledHierarchies`.  A system that can reason about its own consistency cannot
be modelled by any finite untangled hierarchy. -/
theorem ModalSystem.provesCon_finite_isTangled (S : ModalSystem α) (F : KFrame)
    [Finite F.W] [Nonempty F.W] (hsound : S.FrameSound F)
    (h : S.Thm (MFormula.con (α := α))) :
    TangledHierarchies.IsTangled (Relation.TransGen F.R) := by
  obtain ⟨w, hw⟩ := finite_serial_has_cycle F (S.serial_of_provesCon F hsound h)
  exact TangledHierarchies.isTangled_of_selfLoop ⟨w, hw⟩

/-- Such a frame also admits no ℕ-valued grading of its reference graph. -/
theorem ModalSystem.provesCon_finite_no_grading (S : ModalSystem α) (F : KFrame)
    [Finite F.W] [Nonempty F.W] (hsound : S.FrameSound F)
    (h : S.Thm (MFormula.con (α := α))) :
    ¬ ∃ rank : F.W → ℕ,
        ∀ a b, Relation.TransGen F.R a b → rank a < rank b :=
  TangledHierarchies.tangled_has_no_grading (S.provesCon_finite_isTangled F hsound h)

/-! ## Part D — The boundary: finiteness cannot be dropped -/

/-- The `ω`-chain `n → n + 1`. -/
def omegaChain : KFrame where
  W := ℕ
  R := fun n m => m = n + 1

/-- **Finiteness is essential.**  The infinite `ω`-chain is serial and completely
loop-free (even in its transitive closure), so an infinite untangled semantics for a
self-consistent system does exist.  The unavoidability theorem is therefore sharp: the
tangle is forced by finiteness plus self-consistency, not by self-consistency alone. -/
theorem omegaChain_serial_loopFree :
    (∀ n : ℕ, ∃ m : ℕ, omegaChain.R n m) ∧
      ∀ n : ℕ, ¬ Relation.TransGen omegaChain.R n n := by
  refine ⟨fun n => ⟨n + 1, rfl⟩, fun n hn => ?_⟩
  have hsub : ∀ a b : ℕ, omegaChain.R a b → a < b := by
    intro a b h
    have hb : b = a + 1 := h
    omega
  have h2 : Relation.TransGen (· < · : ℕ → ℕ → Prop) n n := hn.mono hsub
  have hself := Relation.transGen_eq_self (r := (· < · : ℕ → ℕ → Prop))
    (fun a b c hab hbc => lt_trans hab hbc)
  rw [hself] at h2
  exact lt_irrefl n h2

/-- The tangled system of Cycle 4 illustrates the theorem: it proves its own
consistency, its semantics is the single self-accessing world, and that world's
reference graph is tangled. -/
theorem tangledSystem_frameSound_loopFrame :
    (tangledSystem α).FrameSound loopFrame ∧
      (tangledSystem α).Thm (MFormula.con (α := α)) ∧
      TangledHierarchies.IsTangled (Relation.TransGen loopFrame.R) := by
  refine ⟨fun _ h V w => h V w, tangledSystem_proves_con, ?_⟩
  exact TangledHierarchies.isTangled_of_selfLoop ⟨(), Relation.TransGen.single trivial⟩

end TangledSoundness

-- !-- Lab Notes -- !--
--
-- Hypothesis (Hypothesizer):
--   H16. Internal soundness degrees are closed under addition (conjecture C1, step 1).
--   H17. A system proving its own consistency admits only serial frame semantics, so
--        no nonempty converse well-founded frame can be sound for it.
--   H18. (Bold, the mission's claim) *Every finite* semantics of such a system is
--        tangled — a cycle is forced, not merely permitted.
--   H19. (Boundary) H18 fails without finiteness, witnessed by the ω-chain.
--
-- Experiment (Experimenter):
--   • H16: `iterR_add` (induction on the first length) transported through
--     `iterSound_iff_cycle`, giving `iterSound_add`.
--   • H17: `sat_con_iff` (Cycle 3) turns the theorem `¬□⊥` into seriality directly;
--     `WellFounded.has_min` then contradicts seriality on a nonempty frame.
--   • H18: `choose` extracts a successor function `f`; `Finite.exists_ne_map_eq_of_infinite`
--     applied to `n ↦ f^[n] w` gives a repeat `f^[i] w = f^[j] w`, and
--     `transGen_iterate` (induction with `Function.iterate_succ_apply'`) turns the gap
--     into a `TransGen` cycle.  Both orderings of `i, j` are handled.
--   • H19: `omegaChain`; transitive-closure edges strictly increase the index
--     (induction on `TransGen`), so no cycle exists.
--
-- Analysis (Analyst):
--   Survived: H16–H19, sorry-free.  The interesting failure is the *shape* of H18:
--   self-consistency alone forces only seriality, and seriality alone forces a cycle
--   only under finiteness — an infinite untangled model exists.  So the correct global
--   statement of "tangled hierarchies are unavoidable" is: unavoidable for finite
--   hierarchies, and unavoidable for well-founded ones in the strong sense that these
--   simply have no models at all (`isEmpty_of_provesCon_of_wf`).
--
-- Critique (Critic):
--   `provesCon_finite_isTangled` has genuinely satisfiable hypotheses:
--   `tangledSystem_frameSound_loopFrame` exhibits a system, a finite frame and the
--   consistency theorem together, so the result is not vacuously about an empty class.
--   The finiteness hypothesis is not a convenience: `omegaChain_serial_loopFree` shows
--   the conclusion fails without it, and this boundary is stated rather than hidden.
-- !-- Lab Notes -- !--