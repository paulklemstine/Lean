/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The Emergent Fixed Point as a Limit of Finite Self-Observation Stages

A recurring picture in the study of self-reference is that a system's stable
self-image should *emerge* as the limit of finitely many rounds of
self-observation: start from a completely uninformed state, apply the
observation operator once, twice, and so on, and pass to the limit.  The
present development turns this picture into a precise approximation theorem.

Working in a complete lattice of "observation states", we model a round of
self-observation by a monotone operator `f`.  The finite **stages** are the
iterates `f^[n] ⊥`, starting from the least (uninformed) state `⊥`, and the
**emergent state** is their supremum.  The main results are:

* `emergent_le_of_prefixed` — the emergent state lies below every pre-fixed
  point; in particular below every fixed point.  This needs only monotonicity.
* `emergent_le_lfp` — consequently the emergent state never exceeds the least
  fixed point guaranteed by the Knaster–Tarski theorem.
* `emergent_fixed` — if the observation operator is (countably) continuous,
  i.e. it commutes with suprema of increasing sequences, the emergent state is
  itself a fixed point.
* `emergent_eq_lfp` — the **Kleene approximation theorem**: for a continuous
  operator the emergent state *equals* the least fixed point.  The stable
  self-image is exactly the supremum of the finite self-observation stages.

The final section records the sharpness of the continuity hypothesis: on a
lattice with two limit levels there is a monotone but discontinuous operator
whose emergent state is strictly below its least fixed point.  Thus continuity
is not a technical convenience but the exact condition under which the limit of
finite stages captures the whole fixed point.

## References

- S. C. Kleene, *Introduction to Metamathematics* (1952), first-recursion
  theorem.
- B. Knaster and A. Tarski, lattice-theoretic fixed point theorem (1928, 1955).

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): Ranked conjectures for a "synthetic domain
--   theory" account of the emergent fixed point:
--   (1) [bold] the least fixed point of a self-observation operator is the
--       supremum of the finite iterates of the least element — a genuine
--       approximation theorem, not merely an existence statement;
--   (2) the emergent supremum is always below the Knaster–Tarski least fixed
--       point, for any monotone operator;
--   (3) [bold] continuity of the operator is exactly the boundary: without it
--       the emergent supremum can be strictly smaller than the least fixed
--       point;
--   (4) concrete reachability operators realise the emergent point as a
--       maximal (top) state.
-- Experiment (Experimenter): (1) and (2) proved in full generality in a
--   complete lattice. (4) verified on the successor/reachability operator on
--   subsets of the naturals, whose emergent state is the whole set. (3)
--   witnessed by a discontinuous operator on two stacked limit levels.
-- Analysis (Analyst): Monotonicity alone controls the emergent point from
--   above (it is a pre-fixed-point bound); continuity is what closes the gap
--   from below by making the supremum a fixed point. The proof of the fixed
--   point property is a one-line index shift once continuity is available,
--   isolating precisely where the hypothesis is spent. The failure mode in the
--   discontinuous case is exactly that the operator "jumps" at the limit stage.
-- Critique (Critic): The main theorem is not `native_decide` or definitional;
--   it consumes an honest continuity hypothesis and reproduces the classical
--   Kleene fixed-point theorem. The boundary section prevents the theorem from
--   being read as unconditional: the discontinuous witness exhibits a strict
--   gap `emergent < lfp` and explicitly violates the continuity hypothesis.
-- Synthesis (PI): Together these give the "least emergent fixed point is the
--   supremum of finite stages from bottom" statement requested by the research
--   direction, with a sharp characterisation of when it holds.
-/
import Mathlib

namespace EmergentFixedPoint

/-! ## Finite stages and the emergent state -/

variable {α : Type*} [CompleteLattice α] (f : α →o α)

/-- The `n`-th finite approximation stage: `n` rounds of self-observation
applied to the least (uninformed) state `⊥`. -/
def stage (n : ℕ) : α := (⇑f)^[n] ⊥

/-- The emergent state: the supremum of all finite self-observation stages. -/
def emergent : α := ⨆ n, stage f n

@[simp] lemma stage_zero : stage f 0 = ⊥ := rfl

lemma stage_succ (n : ℕ) : stage f (n + 1) = f (stage f n) :=
  Function.iterate_succ_apply' _ _ _

/-- The stages form an increasing sequence. -/
lemma stage_monotone : Monotone (stage f) := by
  apply monotone_nat_of_le_succ
  intro n
  induction n with
  | zero => simp
  | succ k ih => rw [stage_succ, stage_succ]; exact f.mono ih

lemma stage_le_emergent (n : ℕ) : stage f n ≤ emergent f := le_iSup (stage f) n

/-- Dropping the initial stage does not change the supremum. -/
lemma iSup_stage_shift : (⨆ n, stage f (n + 1)) = ⨆ n, stage f n := by
  apply le_antisymm
  · exact iSup_le (fun n => le_iSup (stage f) (n + 1))
  · exact iSup_le (fun n => le_trans (stage_monotone f (Nat.le_succ n))
      (le_iSup (fun k => stage f (k + 1)) n))

/-! ## The emergent state as a bound and as a fixed point -/

/-- The emergent state lies below every pre-fixed point.  Monotonicity alone
suffices — no continuity is needed for this direction. -/
theorem emergent_le_of_prefixed {x : α} (hx : f x ≤ x) : emergent f ≤ x := by
  apply iSup_le
  intro n
  induction n with
  | zero => simp
  | succ k ih => rw [stage_succ]; exact le_trans (f.mono ih) hx

/-- The emergent state never exceeds the Knaster–Tarski least fixed point. -/
theorem emergent_le_lfp : emergent f ≤ OrderHom.lfp f :=
  emergent_le_of_prefixed f (OrderHom.map_lfp f).le

/-- **Continuity closes the loop.**  If `f` commutes with suprema of increasing
sequences, the emergent state is a fixed point of `f`. -/
theorem emergent_fixed
    (hf : ∀ c : ℕ → α, Monotone c → f (⨆ n, c n) = ⨆ n, f (c n)) :
    f (emergent f) = emergent f := by
  unfold emergent
  rw [hf (stage f) (stage_monotone f)]
  have h : (⨆ n, f (stage f n)) = ⨆ n, stage f (n + 1) := by
    simp [stage_succ]
  rw [h, iSup_stage_shift]

/-- **Kleene approximation theorem.**  For a (countably) continuous monotone
operator, the emergent state — the supremum of the finite self-observation
stages from `⊥` — equals the least fixed point. -/
theorem emergent_eq_lfp
    (hf : ∀ c : ℕ → α, Monotone c → f (⨆ n, c n) = ⨆ n, f (c n)) :
    emergent f = OrderHom.lfp f := by
  apply le_antisymm
  · exact emergent_le_lfp f
  · exact OrderHom.lfp_le f (emergent_fixed f hf).le

/-! ## Examples

Concrete instantiations of the emergent construction. -/

section Examples

/-- The identity observation operator: no information is ever gained, so the
emergent state remains `⊥`. -/
example : emergent (OrderHom.id : Set ℕ →o Set ℕ) = ⊥ := by
  unfold emergent stage
  simp

/-- The **reachability operator** on subsets of `ℕ`: one round of observation
adds `0` and the successor of everything already present. -/
def reach : Set ℕ →o Set ℕ where
  toFun S := insert 0 (Nat.succ '' S)
  monotone' := fun _ _ h => Set.insert_subset_insert (Set.image_mono h)

/-- Every natural number enters the reachability stages after finitely many
rounds: `k` appears at stage `k + 1`. -/
lemma mem_stage_reach : ∀ k : ℕ, k ∈ stage reach (k + 1) := by
  intro k
  induction k with
  | zero => rw [stage_succ]; left; rfl
  | succ m ih => rw [stage_succ]; exact Or.inr ⟨m, ih, rfl⟩

/-- The emergent state of the reachability operator is *all* of `ℕ`: every
natural number is reachable in the limit of finite stages. -/
example : emergent reach = Set.univ := by
  rw [Set.eq_univ_iff_forall]
  intro k
  exact stage_le_emergent reach (k + 1) (mem_stage_reach k)

#check @emergent_eq_lfp
#check @emergent_le_lfp

end Examples

/-! ## Boundary: continuity is necessary

We exhibit a monotone but discontinuous operator whose emergent state is
*strictly* below its least fixed point.  The carrier is the lattice
`Ldbl := WithTop (WithTop ℕ)`, which stacks two limit levels above the natural
numbers:

```
  0 < 1 < 2 < ⋯ < ω < ω+1
```

where `ω = some ⊤` (the coerced top of the inner `WithTop ℕ`) and `ω+1 = ⊤`.
The operator `gapMap` sends each finite level to its successor and jumps the
first limit level `ω` straight to `ω+1`.  Its finite stages from `⊥` climb the
naturals, so the emergent state is `ω`; but the only fixed point is `ω+1`. -/

section Boundary

/-- Two limit levels above `ℕ`. -/
abbrev Ldbl := WithTop (WithTop ℕ)

/-- Successor on finite levels; the first limit level `ω = some ⊤` jumps to the
top `ω+1 = ⊤ = none`. -/
def gapMap : Ldbl → Ldbl
  | none => none
  | some none => none
  | some (some n) => some (some (n + 1))

lemma gapMap_mono : Monotone gapMap := by
  intro a b h
  match a, b with
  | none, none => exact le_refl _
  | none, some x => exact absurd (top_le_iff.mp h) (by simp)
  | some none, none => exact le_top
  | some none, some none => exact le_refl _
  | some none, some (some n) =>
      exfalso
      have h2 : (⊤ : WithTop ℕ) ≤ (n : WithTop ℕ) := WithTop.coe_le_coe.mp h
      exact absurd (top_le_iff.mp h2) (by simp)
  | some (some m), none => exact le_top
  | some (some m), some none => exact le_top
  | some (some m), some (some n) =>
      show gapMap (some (some m)) ≤ gapMap (some (some n))
      simp only [gapMap]
      exact WithTop.coe_le_coe.mpr (WithTop.coe_le_coe.mpr (by
        have : m ≤ n := WithTop.coe_le_coe.mp (WithTop.coe_le_coe.mp h); omega))

/-- The discontinuous operator as a bundled monotone map. -/
def gapHom : Ldbl →o Ldbl := ⟨gapMap, gapMap_mono⟩

/-- The finite stages of `gapHom` are exactly the finite levels. -/
lemma stage_gapHom (n : ℕ) : stage gapHom n = (some (some n) : Ldbl) := by
  induction n with
  | zero => rfl
  | succ k ih => rw [stage_succ, ih]; rfl

/-- The emergent state of `gapHom` is the first limit level `ω = some ⊤`,
strictly below the top. -/
lemma emergent_gapHom : emergent gapHom = (some none : Ldbl) := by
  apply le_antisymm
  · apply iSup_le
    intro n
    rw [stage_gapHom]
    exact WithTop.coe_le_coe.mpr le_top
  · unfold emergent
    match hv : (⨆ n, stage gapHom n) with
    | none => exact le_top
    | some none => exact le_refl _
    | some (some k) =>
        exfalso
        have h1 : stage gapHom (k + 1) ≤ (⨆ n, stage gapHom n) := le_iSup _ (k + 1)
        rw [hv, stage_gapHom] at h1
        have := WithTop.coe_le_coe.mp (WithTop.coe_le_coe.mp h1)
        omega

/-- The only fixed point of `gapHom` is the top `ω+1`. -/
lemma gapHom_fixed_unique {x : Ldbl} (hx : gapHom x = x) : x = none := by
  match x with
  | none => rfl
  | some none => exact absurd hx (by simp [gapHom, gapMap])
  | some (some k) =>
      exfalso
      have hh : gapMap (some (some k)) = some (some k) := hx
      simp only [gapMap] at hh
      have := WithTop.coe_le_coe.mp (WithTop.coe_le_coe.mp (le_of_eq hh))
      omega

/-- Consequently the least fixed point of `gapHom` is the top `ω+1`. -/
lemma lfp_gapHom : OrderHom.lfp gapHom = (none : Ldbl) :=
  gapHom_fixed_unique (OrderHom.map_lfp gapHom)

/-- **Sharpness of continuity.**  For this monotone but discontinuous operator
the emergent state is *strictly below* the least fixed point: the limit of the
finite stages misses the true fixed point. -/
theorem emergent_lt_lfp_of_discontinuous :
    emergent gapHom < OrderHom.lfp gapHom := by
  rw [emergent_gapHom, lfp_gapHom]
  exact WithTop.coe_lt_top (⊤ : WithTop ℕ)

/-- Witness that `gapHom` fails the continuity hypothesis of the Kleene theorem:
were it continuous, its emergent state would be a fixed point, which it is not. -/
theorem gapHom_not_continuous :
    ¬ (∀ c : ℕ → Ldbl, Monotone c →
        gapHom (⨆ n, c n) = ⨆ n, gapHom (c n)) := by
  intro hf
  have hfix := emergent_fixed gapHom hf
  rw [emergent_gapHom] at hfix
  simp [gapHom, gapMap] at hfix

#check @emergent_lt_lfp_of_discontinuous

end Boundary

end EmergentFixedPoint