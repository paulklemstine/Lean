/-
Copyright (c) 2026. All rights reserved.

# A concrete Escher staircase in the Boolean product ring `ℕ → 𝔽₂`

This file exhibits an explicit Escher staircase (strictly ascending chain of
ideals) in the infinite Boolean product ring `ℕ → ZMod 2`, and uses the
characterization from `Core.lean` to conclude the ring is **not Noetherian**.
It also builds a bridge to the catalog file `Logic/ChainInvariants.lean`,
contrasting the ascending "loop-back" with the descending "Anti-Escher" collapse
of the dyadic chain `(2⁰) ⊇ (2¹) ⊇ ⋯` in `ℤ`.

## Main results

* `Escher.BooleanRing.suppLt_strictMono` — the "support below `n`" ideals form a
  strictly ascending chain.
* `Escher.BooleanRing.boolStaircase` — the resulting `Escher.Staircase (ℕ → 𝔽₂)`.
* `Escher.BooleanRing.boolStaircase_iInf_eq_bot` — the chain "loops back" to `{0}`:
  its infinite intersection is `⊥`, matching the classical `Int(ℤ)` picture of an
  infinite chain collapsing to the zero ideal.
* `Escher.BooleanRing.not_isNoetherianRing_boolProduct` — `ℕ → 𝔽₂` is not
  Noetherian, obtained purely from the existence of the staircase.
* `Escher.BooleanRing.dyadic_int_intersection_bot` — **bridge**: the dyadic
  *descending* chain of ideals `(2ⁿ)` in `ℤ` intersects to `⊥`, via the catalog's
  `ChainInvariants.int_anti_escher_ideal`.  Ascending loop-back and descending
  Anti-Escher collapse are the two faces of the same "vanishing intersection".

-- !-- Lab Notes -- !--
## Hypothesis (Hypothesizer)
The Boolean product ring `ℕ → 𝔽₂` should be non-Noetherian, witnessed by the
ideals `Iₙ = {f : f i = 0 for all i ≥ n}` of "eventually-zero-from-n" functions.
Conjecture: `I₀ ⊊ I₁ ⊊ ⋯` strictly, `I₀ = ⊥`, and `⨅ Iₙ = ⊥`.

## Experiment (Experimenter)
`I₀ = {f : ∀ i ≥ 0, f i = 0} = {0} = ⊥`.  The indicator `Pi.single n 1` lies in
`I_{n+1}` (it vanishes past `n`) but not `Iₙ` (it is `1` at `n`), so each
inclusion is strict.  Loop-back lemma from `Core.lean` then gives `⨅ Iₙ = I₀ = ⊥`.

## Analysis (Analyst)
The `smul_mem'` closure is what makes this an *ideal* (not merely a subgroup):
`(c * f) i = c i * f i = 0` whenever `f i = 0`, using the pointwise product of the
product ring.  Non-Noetherianity is then immediate from the `Core` characterization
— no bespoke chain-condition argument is needed.

## Critique (Critic)
Is the result vacuous or definitional?  No: `smul_mem'` and strictness both require
genuine pointwise arguments, and the non-Noetherian conclusion is a real transfer
through the biconditional.  The dyadic ℤ bridge genuinely invokes a catalog lemma,
so this file is not self-contained boilerplate.

## Synthesis
`ℕ → 𝔽₂` is a clean, fully explicit non-Noetherian ring whose Escher staircase
loops back to `{0}`; the ℤ dyadic chain is its descending mirror image.
-- !-- Lab Notes -- !--
-/
import Tropical.EscherStaircase.Core
import Logic.ChainInvariants

namespace Escher.BooleanRing

/-- The Boolean product ring `∏_{ℕ} 𝔽₂`. -/
abbrev BR := ℕ → ZMod 2

/-- The ideal of functions supported below `n`: those vanishing at every index
`≥ n`.  These are genuine ideals of the product ring. -/
def suppLt (n : ℕ) : Ideal BR where
  carrier := {f | ∀ i, n ≤ i → f i = 0}
  zero_mem' := by intro i _; rfl
  add_mem' := by intro a b ha hb i hi; simp [ha i hi, hb i hi]
  smul_mem' := by intro c a ha i hi; show (c * a) i = 0; simp [ha i hi]

@[simp] theorem mem_suppLt {n : ℕ} {f : BR} : f ∈ suppLt n ↔ ∀ i, n ≤ i → f i = 0 :=
  Iff.rfl

/-- The first ideal of the chain is the zero ideal. -/
theorem suppLt_zero : suppLt 0 = ⊥ := by
  rw [Submodule.eq_bot_iff]; intro f hf; funext i; exact hf i (Nat.zero_le i)

/-- Each inclusion `suppLt n ⊂ suppLt (n+1)` is strict. -/
theorem suppLt_lt_succ (n : ℕ) : suppLt n < suppLt (n + 1) := by
  refine lt_of_le_of_ne (fun f hf i hi => hf i (by omega)) ?_
  intro heq
  have hmem : Pi.single n (1 : ZMod 2) ∈ suppLt (n + 1) := by
    intro i hi; exact Pi.single_eq_of_ne (by omega) 1
  rw [← heq] at hmem
  have h1 := hmem n (le_refl n)
  rw [Pi.single_eq_same] at h1
  exact one_ne_zero h1

/-- The "support below `n`" ideals form a strictly ascending chain. -/
theorem suppLt_strictMono : StrictMono suppLt :=
  strictMono_nat_of_lt_succ suppLt_lt_succ

/-- The concrete Escher staircase in the Boolean product ring. -/
def boolStaircase : Escher.Staircase BR where
  I := suppLt
  strict := suppLt_strictMono

/-- **Loop-back to `{0}`.**  The infinite intersection of the strictly ascending
Boolean staircase is the zero ideal: the "impossible staircase" collapses to its
starting point `I₀ = ⊥`. -/
theorem boolStaircase_iInf_eq_bot : ⨅ n, boolStaircase.I n = ⊥ := by
  rw [boolStaircase.iInf_eq_first]; exact suppLt_zero

/-- **The Boolean product ring is not Noetherian**, witnessed by its Escher
staircase (via the characterization in `Core.lean`). -/
theorem not_isNoetherianRing_boolProduct : ¬ IsNoetherianRing BR :=
  Escher.not_isNoetherianRing_of_staircase boolStaircase

/-- **Bridge to `Logic/ChainInvariants.lean`.**  The dyadic *descending* chain of
principal ideals `(2⁰) ⊇ (2¹) ⊇ (2²) ⊇ ⋯` in `ℤ` intersects to the zero ideal:
the Anti-Escher collapse mirroring the Boolean ring's ascending loop-back. -/
theorem dyadic_int_intersection_bot :
    ⨅ n, Ideal.span ({(2 ^ n : ℤ)} : Set ℤ) = ⊥ := by
  refine ChainInvariants.int_anti_escher_ideal (fun n => 2 ^ n) (by norm_num)
    (fun n => pow_dvd_pow 2 (Nat.le_succ n)) (fun n => ?_)
  rw [Int.associated_iff]
  push_neg
  refine ⟨ne_of_lt (by apply pow_lt_pow_right₀ <;> omega), ?_⟩
  intro hcon
  have h1 : (0 : ℤ) < 2 ^ n := by positivity
  have h2 : (0 : ℤ) < 2 ^ (n + 1) := by positivity
  linarith

end Escher.BooleanRing