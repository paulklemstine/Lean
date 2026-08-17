/-
# Cycle 3: The Spectrum of Tangles — Iterated Reflection and Cycle Length

Cycles 1–2 showed that internalising the soundness schema `□φ → φ` at a world is
*equivalent* to a self-loop, and traced the consequences (no rank, no Löb fixed point,
no interior semantics, one loop per stratification step).  This cycle calibrates the
phenomenon: how *weak* can an internal soundness principle be before the tangle
disappears?

Two sharp answers:

* **From below the schema cannot be weakened.**  `atomicSound_iff_uniformlySound`:
  reflection for *propositional variables only* already forces the self-loop, hence
  the full reflection schema for all formulas.  There is no non-trivial fragment of
  soundness that a well-founded system can afford.
* **From above the tangle can be stretched, not removed.**  `iterSound_iff_cycle`:
  the `n`-fold reflection principle `□ⁿφ → φ` holds at `w` (uniformly) **iff** `w`
  lies on a cycle of length `n`.  The cycle frames `ZMod n` realise every point of
  this spectrum (`cycleFrame_iterSound_self`, `cycleFrame_not_iterSound_lt`), so
  internal soundness comes in a strictly increasing hierarchy of tangle lengths —
  but every one of them tangles the transitive closure
  (`iterSound_transGen_isTangled`) and none is available on a GL frame
  (`glFrame_no_iterSound`).
* **Where the boundary really is.**  Consistency (`¬□⊥`) is *not* on this spectrum:
  `twoChain` is converse well-founded, loop-free, and internally consistent
  (`twoChain_consistent_true`).  Consistency costs nothing; reflection costs a loop.

## Relationship to catalog
Extends `Logic.ProvabilityLogic.TangledSoundness` (Cycle 1) and
`Logic.ProvabilityLogic.SoundnessTopology` (Cycle 2); uses `GLFrame`, `MFormula` from
`Logic.ProvabilityLogic.GLPFrames` and `IsTangled` from `Logic.TangledHierarchies`.
-/

import Mathlib
import Logic.ProvabilityLogic.SoundnessTopology

namespace TangledSoundness

open GLPLogic

universe u

variable {α : Type*}

/-! ## Part A — Atomic reflection already forces the loop -/

/-- The **atomic** reflection fragment: `□p → p` for propositional *variables* `p`
only. -/
def AtomicSoundAt (F : KFrame) (α : Type*) (w : F.W) : Prop :=
  ∀ (V : α → F.W → Prop) (p : α), sat F V w (reflection (.var p))

/-- **The soundness schema cannot be weakened.**  Reflection for atoms alone already
forces the self-loop, hence (by Cycle 1) the reflection schema for *every* formula:
the atomic fragment and the full schema are equivalent. -/
theorem atomicSound_iff_uniformlySound (F : KFrame) (p : α) (w : F.W) :
    AtomicSoundAt F α w ↔ UniformlySoundAt F α w := by
  constructor
  · intro h
    refine (uniformlySound_iff_selfLoop F p w).mpr ?_
    exact h (fun _ v => F.R w v) p (fun v hv => hv)
  · intro h V p'
    exact h V (.var p')

/-! ## Part B — `n`-step accessibility and `n`-fold reflection -/

/-- `n`-step accessibility: `iterR F n u v` iff there is a path of exactly `n` edges
from `u` to `v`. -/
def iterR (F : KFrame) : ℕ → F.W → F.W → Prop
  | 0, u, v => u = v
  | n + 1, u, v => ∃ z, F.R u z ∧ iterR F n z v

/-- `n`-fold box: `□ⁿφ`. -/
def boxIter : ℕ → MFormula α → MFormula α
  | 0, φ => φ
  | n + 1, φ => .box (boxIter n φ)

/-- Truth of `□ⁿφ` is truth of `φ` at every world reachable in exactly `n` steps. -/
theorem sat_boxIter (F : KFrame) (V : α → F.W → Prop) :
    ∀ (n : ℕ) (w : F.W) (φ : MFormula α),
      sat F V w (boxIter n φ) ↔ ∀ v, iterR F n w v → sat F V v φ := by
  intro n
  induction n with
  | zero =>
      intro w φ
      constructor
      · rintro h v rfl; exact h
      · intro h; exact h w rfl
  | succ n ih =>
      intro w φ
      simp only [boxIter, sat_box, ih]
      constructor
      · rintro h v ⟨z, hz, hzv⟩
        exact h z hz v hzv
      · intro h z hz v hzv
        exact h v ⟨z, hz, hzv⟩

/-- **`n`-fold internal soundness**: every instance of `□ⁿφ → φ` holds at `w`, under
every valuation.  For `n = 1` this is `UniformlySoundAt`. -/
def IterSoundAt (F : KFrame) (α : Type*) (n : ℕ) (w : F.W) : Prop :=
  ∀ (V : α → F.W → Prop) (φ : MFormula α), sat F V w (.imp (boxIter n φ) φ)

/-- **The tangle spectrum theorem.**  A world validates the `n`-fold reflection
principle `□ⁿφ → φ` (uniformly in the valuation) **iff** it lies on a cycle of length
exactly `n`.  Internal soundness of degree `n` *is* an `n`-cycle. -/
theorem iterSound_iff_cycle (F : KFrame) (p : α) (n : ℕ) (w : F.W) :
    IterSoundAt F α n w ↔ iterR F n w w := by
  constructor
  · intro h
    have hb : sat F (fun _ v => iterR F n w v) w (boxIter n (MFormula.var p)) :=
      (sat_boxIter F _ n w (.var p)).mpr (fun _ hv => hv)
    exact h (fun _ v => iterR F n w v) (.var p) hb
  · intro hcyc V φ hbox
    exact (sat_boxIter F V n w φ).mp hbox w hcyc

/-- `n = 1` recovers Cycle 1: one-fold reflection is a self-loop. -/
theorem iterSound_one_iff_uniformlySound (F : KFrame) (p : α) (w : F.W) :
    IterSoundAt F α 1 w ↔ UniformlySoundAt F α w := by
  rw [iterSound_iff_cycle F p 1 w, uniformlySound_iff_selfLoop F p w]
  constructor
  · rintro ⟨z, hz, rfl⟩; exact hz
  · intro h; exact ⟨w, h, rfl⟩

/-- A nonzero-length path is a step of the transitive closure. -/
theorem transGen_of_iterR (F : KFrame) :
    ∀ (n : ℕ), 0 < n → ∀ {u v : F.W}, iterR F n u v → Relation.TransGen F.R u v := by
  intro n
  induction n with
  | zero => intro h; exact absurd h (lt_irrefl 0)
  | succ n ih =>
      intro _ u v hpath
      obtain ⟨z, hz, hzv⟩ := hpath
      rcases Nat.eq_zero_or_pos n with hn | hn
      · subst hn
        cases hzv
        exact Relation.TransGen.single hz
      · exact Relation.TransGen.head hz (ih hn hzv)

/-- **Every degree of internal soundness tangles the reference graph.**  If a world
validates `n`-fold reflection for some `n ≥ 1`, the transitive closure of
accessibility has a two-cycle in the sense of `Logic.TangledHierarchies`. -/
theorem iterSound_transGen_isTangled (F : KFrame) (p : α) {n : ℕ} (hn : 0 < n)
    (w : F.W) (h : IterSoundAt F α n w) :
    TangledHierarchies.IsTangled (Relation.TransGen F.R) := by
  have hcyc : Relation.TransGen F.R w w :=
    transGen_of_iterR F n hn ((iterSound_iff_cycle F p n w).mp h)
  exact TangledHierarchies.isTangled_of_selfLoop ⟨w, hcyc⟩

/-- On a transitive frame, an `n`-step path (`n ≥ 1`) collapses to a single edge. -/
theorem iterR_imp_R_of_trans (F : KFrame)
    (htrans : ∀ u v w : F.W, F.R u v → F.R v w → F.R u w) :
    ∀ (n : ℕ), 0 < n → ∀ {u v : F.W}, iterR F n u v → F.R u v := by
  intro n
  induction n with
  | zero => intro h; exact absurd h (lt_irrefl 0)
  | succ n ih =>
      intro _ u v hpath
      obtain ⟨z, hz, hzv⟩ := hpath
      rcases Nat.eq_zero_or_pos n with hn | hn
      · subst hn
        cases hzv
        exact hz
      · exact htrans u z v hz (ih hn hzv)

/-- **No GL frame has internal soundness of any degree.**  Not just `□φ → φ`: every
`n`-fold reflection principle fails at every world of a provability frame. -/
theorem glFrame_no_iterSound (M : GLFrame) (p : α) {n : ℕ} (hn : 0 < n) (w : M.W) :
    ¬ IterSoundAt M.toKFrame α n w := by
  intro h
  have hcyc := (iterSound_iff_cycle M.toKFrame p n w).mp h
  have hR : (M.toKFrame).R w w :=
    iterR_imp_R_of_trans M.toKFrame (fun _ _ _ h₁ h₂ => M.R_trans h₁ h₂) n hn hcyc
  exact M.irrefl w hR

/-! ## Part C — Realising the spectrum: cycle frames -/

/-- The **cycle frame** of length `n`: worlds `ZMod n`, each accessing its successor.
For `n ≥ 2` it has no self-loops, yet it validates `n`-fold reflection everywhere. -/
def cycleFrame (n : ℕ) : KFrame where
  W := ZMod n
  R := fun i j => j = i + 1

/-- `k`-step accessibility in a cycle frame is "add `k`". -/
theorem cycleFrame_iterR (n : ℕ) :
    ∀ (k : ℕ) (i j : ZMod n), iterR (cycleFrame n) k i j ↔ j = i + (k : ZMod n) := by
  intro k
  induction k with
  | zero => intro i j; simp [iterR, eq_comm]
  | succ k ih =>
      intro i j
      constructor
      · rintro ⟨z, rfl, hzj⟩
        rw [ih] at hzj
        rw [hzj]
        push_cast
        ring
      · intro hj
        refine ⟨i + 1, rfl, ?_⟩
        rw [ih, hj]
        push_cast
        ring

/-- **The cycle frame validates `n`-fold reflection at every world.**  A system can
internalise a *delayed* soundness principle without any one-step self-reference. -/
theorem cycleFrame_iterSound_self (n : ℕ) (i : ZMod n) :
    IterSoundAt (cycleFrame n) α n i := by
  intro V φ hbox
  refine (sat_boxIter (cycleFrame n) V n i φ).mp hbox i ?_
  rw [cycleFrame_iterR]
  simp

/-- **…but no shorter reflection principle.**  For `0 < k < n` the cycle frame refutes
`k`-fold reflection, so the degrees of internal soundness form a strictly increasing
hierarchy: no degree implies a smaller one. -/
theorem cycleFrame_not_iterSound_lt (n k : ℕ) (p : α) (hk : 0 < k) (hkn : k < n)
    (i : ZMod n) : ¬ IterSoundAt (cycleFrame n) α k i := by
  haveI : NeZero n := ⟨by omega⟩
  intro h
  have hcyc := (iterSound_iff_cycle (cycleFrame n) p k i).mp h
  rw [cycleFrame_iterR] at hcyc
  have hk0 : ((k : ℕ) : ZMod n) = 0 := by
    have := hcyc.symm
    simpa using this
  have hdvd : n ∣ k := (ZMod.natCast_eq_zero_iff k n).mp hk0
  have := Nat.le_of_dvd hk hdvd
  omega

/-- In particular, for `n ≥ 2` the cycle frame is loop-free: it internalises `n`-fold
soundness with no world referring to itself in one step. -/
theorem cycleFrame_no_selfLoop (n : ℕ) (hn : 2 ≤ n) (i : ZMod n) :
    ¬ (cycleFrame n).R i i := by
  haveI : NeZero n := ⟨by omega⟩
  intro h
  have h1 : ((1 : ℕ) : ZMod n) = 0 := by
    have : (1 : ZMod n) = 0 := by
      have := h.symm
      simpa using this
    simpa using this
  have hdvd : n ∣ 1 := (ZMod.natCast_eq_zero_iff 1 n).mp h1
  have := Nat.le_of_dvd one_pos hdvd
  omega

/-- **Spectrum summary.**  For every `n ≥ 2` there is a frame that internalises
soundness of degree exactly `n`: it validates `□ⁿφ → φ` everywhere, refutes `□ᵏφ → φ`
for all `0 < k < n`, has no self-loops at all — and is nevertheless tangled in its
transitive closure. -/
theorem soundness_degree_spectrum (n : ℕ) (p : α) (hn : 2 ≤ n) :
    (∀ i : ZMod n, IterSoundAt (cycleFrame n) α n i) ∧
      (∀ k, 0 < k → k < n → ∀ i : ZMod n, ¬ IterSoundAt (cycleFrame n) α k i) ∧
      (∀ i : ZMod n, ¬ (cycleFrame n).R i i) ∧
      TangledHierarchies.IsTangled (Relation.TransGen (cycleFrame n).R) := by
  haveI : NeZero n := ⟨by omega⟩
  have hn0 : 0 < n := by omega
  refine ⟨fun i => cycleFrame_iterSound_self n i,
    fun k hk hkn i => cycleFrame_not_iterSound_lt n k p hk hkn i,
    fun i => cycleFrame_no_selfLoop n hn i, ?_⟩
  exact iterSound_transGen_isTangled (cycleFrame n) p hn0 (0 : ZMod n)
    (cycleFrame_iterSound_self n (0 : ZMod n))

/-! ## Part D — The boundary: consistency is free -/

/-- Internal **consistency** `¬□⊥` at a world is exactly seriality there, and it does
not depend on the valuation. -/
theorem sat_con_iff (F : KFrame) (V : α → F.W → Prop) (w : F.W) :
    sat F V w (MFormula.con (α := α)) ↔ ∃ v, F.R w v := by
  simp only [MFormula.con, MFormula.neg, sat_imp, sat_box, sat_bot]
  constructor
  · intro h
    by_contra hno
    push_neg at hno
    exact h (fun v hv => absurd hv (hno v))
  · rintro ⟨v, hv⟩ hbox
    exact hbox v hv

/-- A two-world chain `t → f`: a bona fide GL-style frame (converse well-founded,
loop-free). -/
def twoChain : KFrame where
  W := Bool
  R := fun x y => x = true ∧ y = false

theorem twoChain_no_selfLoop (x : Bool) : ¬ twoChain.R x x := by
  rintro ⟨rfl, h⟩
  exact absurd h (by simp)

theorem twoChain_converse_wf : WellFounded (Function.swap twoChain.R) := by
  have hfalse : Acc (Function.swap twoChain.R) false := by
    refine Acc.intro false ?_
    rintro y ⟨hy, -⟩
    exact absurd hy (by simp)
  refine ⟨fun x => ?_⟩
  cases x with
  | false => exact hfalse
  | true =>
      refine Acc.intro true ?_
      rintro y ⟨-, rfl⟩
      exact hfalse

/-- **Consistency is tangle-free.**  The loop-free, converse well-founded frame
`twoChain` internally asserts its own consistency at the world `t`.  So the jump from
"no tangle" to "tangle" happens exactly at reflection, not at consistency: this is the
precise boundary of Gödel's second incompleteness phenomenon in frame terms. -/
theorem twoChain_consistent_true (V : α → Bool → Prop) :
    sat twoChain V true (MFormula.con (α := α)) :=
  (sat_con_iff twoChain V true).mpr ⟨false, ⟨rfl, rfl⟩⟩

/-- The same world is **not** internally sound, even atomically: consistency is
strictly weaker than reflection. -/
theorem twoChain_true_not_sound (p : α) :
    ¬ UniformlySoundAt twoChain α true := by
  intro h
  exact twoChain_no_selfLoop true ((uniformlySound_iff_selfLoop twoChain p true).mp h)

/-- **Cycle-3 synthesis.**  Internal consistency is compatible with a well-founded,
loop-free hierarchy; internal soundness of *any* degree is not, and the degrees form a
strict hierarchy realised by cycle frames. -/
theorem consistency_vs_reflection_boundary (p : α) :
    (WellFounded (Function.swap twoChain.R) ∧
      (∀ x : Bool, ¬ twoChain.R x x) ∧
      (∀ V : α → Bool → Prop, sat twoChain V true (MFormula.con (α := α))) ∧
      ¬ UniformlySoundAt twoChain α true) ∧
    (∀ (M : GLFrame) (n : ℕ), 0 < n → ∀ w : M.W, ¬ IterSoundAt M.toKFrame α n w) :=
  ⟨⟨twoChain_converse_wf, twoChain_no_selfLoop, fun V => twoChain_consistent_true V,
      twoChain_true_not_sound p⟩,
    fun M _ hn w => glFrame_no_iterSound M p hn w⟩

end TangledSoundness

-- !-- Lab Notes -- !--
--
-- Hypothesis (Hypothesizer):
--   H10. Reflection restricted to propositional *atoms* already forces the tangle, so
--        the soundness schema has no affordable fragment.
--   H11. (Bold) `n`-fold reflection `□ⁿφ → φ` is equivalent to lying on a cycle of
--        length exactly `n`: internal soundness is *graded by cycle length*.
--   H12. (Bold) The grading is strict and realised: cycle frames `ZMod n` validate
--        degree `n` and refute every smaller positive degree, with no self-loops.
--   H13. Consistency `¬□⊥` sits strictly below the whole spectrum: it is satisfiable
--        on a loop-free converse well-founded frame.
--
-- Experiment (Experimenter):
--   • H10: `atomicSound_iff_uniformlySound` — the Cycle-1 valuation `p ↦ R w ·` only
--     ever used a variable, so the atomic fragment suffices; the converse is trivial.
--   • H11: `sat_boxIter` (induction on `n`, `iterR` bookkeeping) turns `□ⁿφ` into a
--     statement about `n`-step reachability; then the same valuation trick, now with
--     `p ↦ iterR F n w ·`, gives `iterSound_iff_cycle`.
--   • H12: `cycleFrame_iterR` (induction, `push_cast; ring`) computes `k`-step
--     accessibility in `ZMod n` as `+k`; degree `n` holds by `ZMod.natCast_self`, and
--     failure for `0 < k < n` reduces to `n ∤ k` via `ZMod.natCast_eq_zero_iff`.
--   • H13: `twoChain` with explicit `Acc` witnesses; `sat_con_iff` identifies internal
--     consistency with seriality.
--
-- Analysis (Analyst):
--   Survived: H10–H13, sorry-free.  Structural pattern: *the modal degree of a
--   reflection principle equals the combinatorial girth it forces.*  Degree 1 forces a
--   loop (Cycle 1), degree n forces an n-cycle, degree 0 forces nothing (`iterR 0` is
--   equality, and indeed `□⁰φ → φ` is a tautology), and consistency is not a
--   reflection principle at all — it forces only seriality, which well-founded frames
--   supply freely.  This explains, semantically, why consistency statements are
--   comparatively cheap while reflection principles are not.
--   Corner case found by testing: for `n = 1` the "cycle frame" `ZMod 1` is a single
--   reflexive world, so `cycleFrame_no_selfLoop` genuinely needs `2 ≤ n`; the
--   hypothesis is stated rather than hidden.
--
-- Critique (Critic):
--   `soundness_degree_spectrum` is not vacuous: it exhibits a concrete frame with a
--   positive property (degree-`n` soundness) alongside the negative ones, and the
--   `NeZero n` instance is derived from `2 ≤ n` rather than assumed.  No theorem is
--   `rfl`-only: the interesting content of `iterSound_iff_cycle` is the valuation
--   construction, and of `cycleFrame_not_iterSound_lt` the divisibility argument.
--   `consistency_vs_reflection_boundary` only assembles previously proved results.
-- !-- Lab Notes -- !--