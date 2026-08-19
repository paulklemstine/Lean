/-
# Cycle 5, Part V: The Degree Monoid of a Frame

Cycle 2 graded internal soundness by degree: `IterSoundAt F α n w` (`□ⁿφ → φ` at `w`)
holds iff `w` lies on an `n`-cycle, and the cycle frames realise the degrees `n ℕ`.
Frame definability turns this *pointwise* spectrum into an *invariant of the frame*:

> `degreeMonoid F p = {n | the axiom □ⁿp → p is valid on F}`

is an additive submonoid of `ℕ` (Part A), and different frames realise genuinely
different submonoids (Parts B–C).

## Main results

* `defines_cycleAxiom` — `□ⁿp → p` defines the class of frames all of whose worlds lie
  on an `n`-cycle.  For `n = 1` this is reflexivity, recovering `defines_reflexive`.
* `degreeMonoid` — the valid degrees of a frame form an `AddSubmonoid ℕ`; the proof of
  closure under addition is Cycle 3's path-concatenation lemma `iterR_add`, lifted from
  a single world to the whole frame.
* `degreeMonoid_loeb`, `degreeMonoid_eq_rel` — the two extremes: a Löb frame realises
  `{0}`, an equality frame realises all of `ℕ`.
* `cycleFrame_degree_iff` — the cycle frame of length `n` realises exactly the
  multiples of `n`.
* `kThree_degree_iff`, `kThree_degrees_not_principal` — **the surprise.**  The
  three-world complete irreflexive frame realises `{0, 2, 3, 4, …}`, the numerical
  semigroup `⟨2,3⟩`, which is *not* of the form `d ℕ`.  Hence the degrees of internal
  soundness are not ordered by divisibility, and the Cycle-2 hierarchy
  (`soundness_degree_spectrum`) does not exhaust the possible spectra.
-/

import Mathlib
import Combinatorics.ModalFrameDefinability

namespace FrameDefinability

open GLPLogic TangledSoundness

universe u

variable {α : Type}

/-! ## Part A — The `n`-fold reflection axiom and the degree monoid -/

/-- The **`n`-fold reflection axiom** `□ⁿp → p`.  For `n = 1` this is the reflection
(soundness) instance of Cycle 1. -/
def cycleAxiom (n : ℕ) (p : α) : MFormula α := .imp (boxIter n (MFormula.var p)) (.var p)

theorem cycleAxiom_one (p : α) : cycleAxiom 1 p = reflection (MFormula.var p) := rfl

/-- **`□ⁿp → p` defines "every world lies on an `n`-cycle".**  The witnessing valuation
is `x ↦ iterR F n w x`, the set of worlds reachable from `w` in exactly `n` steps. -/
theorem defines_cycleAxiom (n : ℕ) (p : α) :
    Defines α {cycleAxiom n p} (fun F : KFrame.{u} => ∀ w, iterR F n w w) := by
  rw [defines_singleton_iff]
  intro F
  constructor
  · intro h w
    have hbox : sat F (fun _ x => iterR F n w x) w (boxIter n (MFormula.var p)) :=
      (sat_boxIter F _ n w (.var p)).mpr (fun _ hv => hv)
    exact h (fun _ x => iterR F n w x) w hbox
  · intro hcyc V w hbox
    exact (sat_boxIter F V n w (MFormula.var p)).mp hbox w (hcyc w)

/-- Degree `1` is reflexivity: `defines_cycleAxiom` at `n = 1` recovers Part I's
`defines_reflexive`. -/
theorem cycle_one_iff_reflexive (F : KFrame.{u}) (w : F.W) :
    iterR F 1 w w ↔ F.R w w := by
  constructor
  · rintro ⟨z, hz, rfl⟩; exact hz
  · intro h; exact ⟨w, h, rfl⟩

/-- **The degrees of a frame form an additive submonoid of `ℕ`.**  Zero is the trivial
axiom `p → p`, and closure under addition is concatenation of cycles (Cycle 3's
`iterR_add`). -/
def degreeMonoid (F : KFrame.{u}) (p : α) : AddSubmonoid ℕ where
  carrier := {n : ℕ | Valid F α (cycleAxiom n p)}
  zero_mem' :=
    ((defines_singleton_iff (α := α) (cycleAxiom 0 p)
      (fun F : KFrame.{u} => ∀ w, iterR F 0 w w)).mp (defines_cycleAxiom 0 p) F).mpr
      (fun _ => rfl)
  add_mem' := by
    intro m n hm hn
    have hiff := fun (k : ℕ) =>
      (defines_singleton_iff (α := α) (cycleAxiom k p)
        (fun F : KFrame.{u} => ∀ w, iterR F k w w)).mp (defines_cycleAxiom k p) F
    refine (hiff (m + n)).mpr (fun w => ?_)
    exact iterR_add F m n ((hiff m).mp hm w) ((hiff n).mp hn w)

theorem mem_degreeMonoid_iff (F : KFrame.{u}) (p : α) (n : ℕ) :
    n ∈ degreeMonoid F p ↔ ∀ w, iterR F n w w :=
  (defines_singleton_iff (α := α) (cycleAxiom n p)
    (fun F : KFrame.{u} => ∀ w, iterR F n w w)).mp (defines_cycleAxiom n p) F

/-! ## Part B — The two extremes -/

/-- A Löb frame realises the trivial degree monoid `{0}`. -/
theorem degreeMonoid_loeb (F : KFrame.{u}) (p : α) [Nonempty F.W]
    (h : Valid F α (loebInst (MFormula.var p))) (n : ℕ) :
    n ∈ degreeMonoid F p ↔ n = 0 := by
  rw [mem_degreeMonoid_iff]
  constructor
  · intro hcyc
    by_contra hn
    obtain ⟨w⟩ := ‹Nonempty F.W›
    exact no_cycle_of_valid_loebInst F p h (Nat.pos_of_ne_zero hn) w (hcyc w)
  · rintro rfl
    intro w
    rfl

/-- An equality frame realises the full monoid `ℕ`. -/
theorem degreeMonoid_eq_rel (F : KFrame.{u}) (p : α)
    (heq : ∀ w v : F.W, F.R w v ↔ v = w) (n : ℕ) : n ∈ degreeMonoid F p :=
  (mem_degreeMonoid_iff F p n).mpr (fun w => iterR_self_of_eq_rel F heq w n)

/-- The cycle frame of length `n` realises exactly the multiples of `n`. -/
theorem cycleFrame_degree_iff (n : ℕ) (p : α) (k : ℕ) :
    k ∈ degreeMonoid (cycleFrame n) p ↔ n ∣ k := by
  rw [mem_degreeMonoid_iff]
  constructor
  · intro h
    have h0 := h (show (cycleFrame n).W from (0 : ZMod n))
    rw [cycleFrame_iterR] at h0
    have hk0 : ((k : ℕ) : ZMod n) = 0 := by simpa using h0.symm
    exact (ZMod.natCast_eq_zero_iff k n).mp hk0
  · intro hdvd i
    rw [cycleFrame_iterR]
    have hk0 : ((k : ℕ) : ZMod n) = 0 := (ZMod.natCast_eq_zero_iff k n).mpr hdvd
    rw [hk0, add_zero]

/-! ## Part C — A non-principal degree monoid: the complete three-world frame -/

/-- The complete irreflexive frame on three worlds: every world sees every *other*
world. -/
@[reducible] def kThree : KFrame.{0} where
  W := Fin 3
  R := fun i j => i ≠ j

theorem kThree_exists_ne (i : Fin 3) : ∃ z : Fin 3, i ≠ z := by
  revert i; decide

theorem kThree_exists_triangle (i : Fin 3) : ∃ z y : Fin 3, i ≠ z ∧ z ≠ y ∧ y ≠ i := by
  revert i; decide

/-- Every world of `kThree` lies on a 2-cycle. -/
theorem kThree_cycle_two (i : Fin 3) : iterR kThree 2 i i := by
  obtain ⟨z, hz⟩ := kThree_exists_ne i
  exact ⟨z, hz, i, Ne.symm hz, rfl⟩

/-- Every world of `kThree` lies on a 3-cycle. -/
theorem kThree_cycle_three (i : Fin 3) : iterR kThree 3 i i := by
  obtain ⟨z, y, hiz, hzy, hyi⟩ := kThree_exists_triangle i
  exact ⟨z, hiz, y, hzy, i, hyi, rfl⟩

/-- Every world of `kThree` lies on a `k`-cycle for every `k ≠ 1`: the lengths form the
numerical semigroup generated by `2` and `3`. -/
theorem kThree_cycle_of_ne_one : ∀ k : ℕ, k ≠ 1 → ∀ i : Fin 3, iterR kThree k i i := by
  intro k
  induction k using Nat.strong_induction_on with
  | _ k ih =>
      intro hk i
      match k, hk with
      | 0, _ => exact rfl
      | 2, _ => exact kThree_cycle_two i
      | 3, _ => exact kThree_cycle_three i
      | (m + 4), _ =>
          have hm : (m + 2) ≠ 1 := by omega
          have hlt : m + 2 < m + 4 := by omega
          have h2 : iterR kThree 2 i i := kThree_cycle_two i
          have hrec : iterR kThree (m + 2) i i := ih (m + 2) hlt hm i
          have := iterR_add kThree 2 (m + 2) h2 hrec
          simpa [show 2 + (m + 2) = m + 4 from by omega] using this

/-- `kThree` has no world on a 1-cycle: it is irreflexive. -/
theorem kThree_no_cycle_one (i : Fin 3) : ¬ iterR kThree 1 i i := by
  rintro ⟨y, hy, rfl⟩
  exact hy rfl

/-- **The degree monoid of `kThree` is `⟨2,3⟩ = {0, 2, 3, 4, …}`.** -/
theorem kThree_degree_iff (p : α) (k : ℕ) :
    k ∈ degreeMonoid kThree p ↔ k ≠ 1 := by
  rw [mem_degreeMonoid_iff]
  constructor
  · intro h hk
    subst hk
    exact kThree_no_cycle_one 0 (h 0)
  · intro hk
    exact kThree_cycle_of_ne_one k hk

/-- **The soundness degrees are not ordered by divisibility.**  No modulus `d` has
`{k | d ∣ k}` equal to the degree monoid of `kThree`, so the cycle-frame hierarchy of
Cycle 2 — where the realised degrees were always the multiples of a single number — is
not the whole story. -/
theorem kThree_degrees_not_principal (p : α) :
    ¬ ∃ d : ℕ, ∀ k : ℕ, k ∈ degreeMonoid kThree p ↔ d ∣ k := by
  rintro ⟨d, hd⟩
  have h2 : d ∣ 2 := (hd 2).mp ((kThree_degree_iff p 2).mpr (by omega))
  have h3 : d ∣ 3 := (hd 3).mp ((kThree_degree_iff p 3).mpr (by omega))
  have hd1 : d ∣ 1 := (Nat.dvd_sub h3 h2)
  have : d = 1 := Nat.dvd_one.mp hd1
  subst this
  exact (kThree_degree_iff p 1).mp ((hd 1).mpr (one_dvd 1)) rfl

/-- **Spectrum summary, sharpened.**  Three frames realise three genuinely different
degree monoids: `{0}` (Löb frames), `n ℕ` (cycle frames), and the non-principal
numerical semigroup `⟨2,3⟩` (the complete three-world frame).  Since `degreeMonoid` is
a frame invariant defined by validity of an axiom, these frames are pairwise
non-equivalent as frames for internal soundness. -/
theorem degree_monoid_trichotomy (p : α) :
    (∀ k : ℕ, k ∈ degreeMonoid (cycleFrame 2) p ↔ 2 ∣ k) ∧
      (∀ k : ℕ, k ∈ degreeMonoid kThree p ↔ k ≠ 1) ∧
      (2 ∈ degreeMonoid kThree p ∧ 3 ∈ degreeMonoid kThree p ∧
        3 ∉ degreeMonoid (cycleFrame 2) p) := by
  refine ⟨fun k => cycleFrame_degree_iff 2 p k,
    fun k => kThree_degree_iff p k, ?_, ?_, ?_⟩
  · exact (kThree_degree_iff p 2).mpr (by omega)
  · exact (kThree_degree_iff p 3).mpr (by omega)
  · intro h
    have := (cycleFrame_degree_iff 2 p 3).mp h
    omega

end FrameDefinability

-- !-- Lab Notes -- !--
--
-- Hypothesis (Hypothesizer):
--   H24. The set of degrees `n` for which `□ⁿp → p` is *frame*-valid is an additive
--        submonoid of ℕ — a frame invariant, not just a pointwise one.
--   H25. (Bold) That invariant is not always principal: there is a finite frame whose
--        realised degrees are `⟨2,3⟩`, so Cycle 2's cycle-frame hierarchy `n ℕ` misses
--        possible spectra.
--
-- Experiment (Experimenter):
--   H24: confirmed (`degreeMonoid`).  Closure under addition is exactly `iterR_add`
--        from Cycle 3; the zero element is the tautology `p → p`, matching
--        `iterR F 0 w w = rfl`.
--   H25: confirmed.  `kThree` (the complete irreflexive digraph on `Fin 3`) has every
--        world on a 2-cycle and on a 3-cycle, hence on a `k`-cycle for every `k ≥ 2`
--        by strong induction with step `k ↦ k + 2`; `k = 1` fails by irreflexivity.
--        `kThree_degrees_not_principal` shows no modulus reproduces this set: `d ∣ 2`
--        and `d ∣ 3` force `d = 1`, but `1 ∈ degreeMonoid` would need `1 ≠ 1`.
--
-- Analysis (Analyst):
--   Cycle 2 exhibited the degrees realised by *one* family (cycle frames) and read the
--   hierarchy off it.  The monoid perspective explains why that family looked
--   linearly ordered: a single cycle realises a principal monoid, and only frames with
--   several independent cycles through every world can realise a non-principal one.
--   The question "which submonoids of ℕ are degree monoids?" is now precise, and is
--   recorded as a conjecture in FUTURE_DIRECTIONS.md.
--
-- Critique (Critic):
--   `degreeMonoid_loeb` needs `[Nonempty F.W]`: on the empty frame *every* axiom is
--   valid, so the degree monoid is ℕ, not `{0}`.  This is the same boundary case as
--   `nonempty_not_definable` in Part I, and it is stated rather than hidden.