/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Escher Staircases in Algebra: infinite ascending ideal chains that loop back

An *Escher staircase* in a commutative ring `R` is an infinite strictly ascending
chain of ideals
  `I 0 < I 1 < I 2 < ⋯`
It is a purely order-theoretic gadget, but it captures exactly the failure of the
ascending chain condition: a ring admits an Escher staircase **iff** it is not
Noetherian.

The "impossible architecture" flavour of the name comes from the following: for the
concrete staircase we build in the product ring `ℕ → ℤ`, the chain starts at the
bottom, `I 0 = ⊥ = {0}`, and this bottom is exactly the infimum `⨅ n, I n` of the
whole (ascending) chain.  So the chain "loops back": climbing forever, the meet of
everything you ever reach is the single point you started from, the zero element,
which of course also sits inside every rung `I 1, I 2, …`.

## Main results

* `EscherStaircase` : the definition (an infinite strictly monotone chain of ideals).
* `escherStaircase_iff_not_isNoetherianRing` :
    `EscherStaircase R ↔ ¬ IsNoetherianRing R`.
* `EscherStaircase.pi_int` : the product ring `ℕ → ℤ` has an Escher staircase,
    together with `tailZeroIdeal_iInf_eq_bot` (the chain loops back to `⊥`) and
    `not_isNoetherianRing_pi_int` (so `ℕ → ℤ` is not Noetherian).
* `not_escherStaircase_padicInt` : the `p`-adic integers `ℤ_[p]` — a DVR, hence
    Noetherian — have **no** Escher staircase.

-- !-- Lab Notes -- !--
### Hypothesis (Hypothesizer)
Candidate conjectures about "Escher staircases" (infinite strictly ascending ideal
chains):
  H1. A ring has an Escher staircase iff it is not Noetherian.               [kept]
  H2. `ℕ → ℤ` (an infinite product) has an explicit Escher staircase whose
      infimum is `⊥`, realising the "loop back to {0}" picture.              [kept]
  H3. `ℤ_[p]` has no Escher staircase (it is a DVR ⇒ PID ⇒ Noetherian).      [kept]
  H4. The original description's chain `I_n = {f : f(ℤ) ⊆ 2ⁿℤ}` is *ascending*.
      COUNTER-INTUITIVE CHECK: since `2^{n+1}ℤ ⊆ 2ⁿℤ`, that chain is *descending*,
      not ascending; the informal write-up has the inclusion reversed.       [revised]
  H5. Every non-Noetherian ring has an Escher staircase of "infinite length"
      (a chain with no top). This is H1 again: any strictly ascending `ℕ`-chain
      is already infinite.                                                    [merged]

### Experiment (Experimenter)
Small cases in `ℕ → ℤ`: the ideals `S n = {f | ∀ k ≥ n, f k = 0}` satisfy
`S 0 = {0} ⊊ S 1 ⊊ S 2 ⊊ ⋯`, the strictness witnessed by the indicator `Pi.single n 1`
which lies in `S (n+1)` but not `S n`.  The infimum `⨅ n, S n` collapses to `{0}`
because membership in `S 0` already forces `f = 0`.

### Analysis (Analyst)
The ACC characterisation is the load-bearing bridge: `IsNoetherian R R` is
definitionally well-foundedness of `(· > ·)` on `Ideal R`, and an Escher staircase
is precisely a strictly monotone `ℕ → Ideal R`, i.e. a witness that this order is
*not* well-founded.  Mathlib's `RelEmbedding.wellFounded_iff_isEmpty` and
`not_strictMono_of_wellFoundedGT` supply the two directions.

### Critique (Critic)
* Is anything trivial?  No: `escherStaircase_iff_not_isNoetherianRing` needs the
  well-founded ⇄ descending-chain equivalence; `pi_int` needs an explicit ideal
  construction plus a genuine strictness argument; `padicInt` needs the DVR instance.
* Vacuity check: `EscherStaircase (ℕ → ℤ)` is *inhabited* by an explicit chain, so
  the "not Noetherian" corollary is not vacuous.  `ℤ_[p]` is a nonzero ring, so its
  ideal lattice is nontrivial and the "no staircase" statement has content.

### Synthesis (PI)
"Escher staircase" is a faithful order-theoretic name for the failure of ACC.  The
`ℕ → ℤ` example gives the impossible-architecture picture (climb forever, meet is the
start), and `ℤ_[p]` is the clean negative instance predicted by the mission.
-- !-- Lab Notes -- !--
-/
import Mathlib

open scoped Classical

namespace Escher

/-- An **Escher staircase** in a commutative ring `R` is an infinite strictly
ascending chain of ideals `I 0 < I 1 < I 2 < ⋯`. -/
def EscherStaircase (R : Type*) [CommRing R] : Prop :=
  ∃ I : ℕ → Ideal R, StrictMono I

variable {R : Type*} [CommRing R]

/-- **Main theorem (the invariant).** A commutative ring admits an Escher staircase
if and only if it is not Noetherian.  In other words, an infinite strictly ascending
chain of ideals is exactly the obstruction to the ascending chain condition. -/
theorem escherStaircase_iff_not_isNoetherianRing :
    EscherStaircase R ↔ ¬ IsNoetherianRing R := by
  rw [isNoetherianRing_iff, isNoetherian_iff']
  constructor
  · rintro ⟨I, hI⟩ hwf
    exact not_strictMono_of_wellFoundedGT I hI
  · intro h
    rw [WellFoundedGT, isWellFounded_iff] at h
    rw [RelEmbedding.wellFounded_iff_isEmpty, not_isEmpty_iff] at h
    obtain ⟨e⟩ := h
    refine ⟨fun n => e n, ?_⟩
    intro a b hab
    exact e.map_rel_iff.mpr hab

/-! ### The concrete staircase in the product ring `ℕ → ℤ` -/

/-- The ideal of sequences that vanish from index `n` onwards:
`S n = {f | ∀ k ≥ n, f k = 0}`. -/
def tailZeroIdeal (n : ℕ) : Ideal (ℕ → ℤ) where
  carrier := {f | ∀ k, n ≤ k → f k = 0}
  add_mem' := by intro a b ha hb k hk; simp [ha k hk, hb k hk]
  zero_mem' := by intro k _; rfl
  smul_mem' := by intro c f hf k hk; show c k * f k = 0; rw [hf k hk, mul_zero]

@[simp] theorem mem_tailZeroIdeal {n : ℕ} {f : ℕ → ℤ} :
    f ∈ tailZeroIdeal n ↔ ∀ k, n ≤ k → f k = 0 := Iff.rfl

/-- The chain is monotone: vanishing beyond `n` implies vanishing beyond `n+1`. -/
theorem tailZeroIdeal_mono : Monotone tailZeroIdeal := by
  intro m n hmn f hf k hk; exact hf k (hmn.trans hk)

/-- The indicator `Pi.single n 1` separates rung `n` from rung `n+1`: it lies in
`tailZeroIdeal (n+1)` but not in `tailZeroIdeal n`. -/
theorem tailZeroIdeal_lt_succ (n : ℕ) : tailZeroIdeal n < tailZeroIdeal (n + 1) := by
  rw [SetLike.lt_iff_le_and_exists]
  refine ⟨tailZeroIdeal_mono (Nat.le_succ n), Pi.single n (1 : ℤ), ?_, ?_⟩
  · intro k hk
    have hkn : k ≠ n := by omega
    simp [Pi.single_eq_of_ne hkn]
  · intro h
    have := h n (le_refl n)
    simp at this

/-- The rungs form a strictly ascending chain: an explicit Escher staircase. -/
theorem tailZeroIdeal_strictMono : StrictMono tailZeroIdeal :=
  strictMono_nat_of_lt_succ tailZeroIdeal_lt_succ

/-- The bottom rung is `{0}`. -/
theorem tailZeroIdeal_zero : tailZeroIdeal 0 = ⊥ := by
  ext f
  simp only [mem_tailZeroIdeal, Submodule.mem_bot]
  constructor
  · intro h; funext k; exact h k (Nat.zero_le k)
  · intro h k _; rw [h]; rfl

/-- **The staircase loops back.** The infimum of the entire (ascending) chain is the
zero ideal `{0}` — the same bottom rung the chain starts from. -/
theorem tailZeroIdeal_iInf_eq_bot : (⨅ n, tailZeroIdeal n) = ⊥ := by
  apply le_antisymm _ bot_le
  calc (⨅ n, tailZeroIdeal n) ≤ tailZeroIdeal 0 := iInf_le _ 0
    _ = ⊥ := tailZeroIdeal_zero

/-- **The product ring `ℕ → ℤ` has an Escher staircase.** -/
theorem pi_int : EscherStaircase (ℕ → ℤ) :=
  ⟨tailZeroIdeal, tailZeroIdeal_strictMono⟩

/-- Consequently `ℕ → ℤ` is not Noetherian. -/
theorem not_isNoetherianRing_pi_int : ¬ IsNoetherianRing (ℕ → ℤ) :=
  escherStaircase_iff_not_isNoetherianRing.mp pi_int

/-! ### The negative instance: the `p`-adic integers -/

/-- **Main theorem (the negative instance).** The `p`-adic integers `ℤ_[p]` — a
discrete valuation ring, hence a PID, hence Noetherian — admit **no** Escher
staircase: every ascending chain of ideals eventually stabilises. -/
theorem not_escherStaircase_padicInt (p : ℕ) [Fact p.Prime] :
    ¬ EscherStaircase ℤ_[p] := by
  rw [escherStaircase_iff_not_isNoetherianRing, not_not]
  infer_instance

end Escher