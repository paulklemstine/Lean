/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Discrete Čech Cohomology of a Cover Nerve, and Adversarial Obstructions

This module builds an explicit, fully computable discrete first Čech cohomology
for the two canonical one-dimensional nerves of an open cover:

* the **path nerve** of `n+1` overlapping regions `U₀, U₁, …, Uₙ`
  (consecutive overlaps only), and
* the **cyclic nerve** of `n+1` regions arranged in a loop
  `U₀, …, Uₙ, U₀` (a closed chain of overlaps).

A cover of a neural-network weight space (or of a decision boundary) by linear
activation regions has a nerve.  Local certified-robustness data — one real
number per region (a local certified radius / section value) and a compatible
discrepancy on each overlap — is exactly a Čech `0`- and `1`-cochain.  The
coboundary `δ⁰` measures the failure of local sections to glue.

We prove the two structural facts that drive the whole story:

* `H1_path_vanishes` : on a **tree** nerve (the path) `δ⁰` is *surjective*, i.e.
  `H¹ = 0`.  Every overlap discrepancy is the coboundary of a global potential,
  so local certificates always glue — there is no cohomological obstruction.

* `cyclic_H1_nonvanishing` : on a **loop** nerve `δ⁰` is *not* surjective, i.e.
  `H¹ ≠ 0`.  The obstruction is the holonomy `∑ᵢ gᵢ` around the loop
  (`deltaCyc_sum_zero`, `cyclic_not_coboundary`): a nonzero loop sum is a
  certified-section discrepancy that *cannot* be removed by any global
  reparametrisation.  This nonzero stalk class is precisely a detected
  adversarial vulnerability: a cycle of regions whose local certificates are
  mutually inconsistent.

The kernel computation `delta0_eq_zero_iff_const` identifies `H⁰` with the
constants (a connected nerve has one-dimensional `H⁰`).

-- !-- Lab Notes -- !--
* Hypothesis (Hypothesizer): "Vanishing first cohomology of the cover nerve is
  equivalent to global gluability of local robustness certificates, and the
  obstruction to gluing on a loop is a single scalar holonomy."  Bold form:
  *every* loop in a decision-boundary cover with nonzero holonomy hosts an
  adversarial example.
* Experiment (Experimenter): formalised `δ⁰` on the path nerve and proved
  surjectivity by the explicit potential `f k = ∑_{j<k} gⱼ` (telescoping).
  For the loop, proved `∑ᵢ (δ_cyc f)ᵢ = 0` via the bijection `i ↦ i+1` on
  `Fin (n+1)`, giving a closed-form obstruction.
* Analysis (Analyst): the path proof is a discrete fundamental theorem of
  calculus; the loop obstruction is discrete monodromy.  "True but needed the
  right potential": a naïve recursive potential blew up in `Fin` arithmetic, the
  filter/partial-sum potential is clean.
* Critique (Critic): is `cyclic_H1_nonvanishing` vacuous?  No — it exhibits the
  *constant `1`* cochain (loop sum `n+1 > 0`) as an explicit non-coboundary, so
  the failure of surjectivity is witnessed, not abstract.
* Synthesis (PI): `H¹` of the nerve is the exact ledger of gluability; the path
  certifies, the loop obstructs.
-/

import Mathlib

open BigOperators Finset

namespace SheafCohomologyRobustness

variable {n : ℕ}

/-! ## §1. Cochains and the path coboundary -/

/-- `0`-cochains on the path nerve with `n+1` open sets: one real value per open
set (a local section value / local certified radius). -/
abbrev Cochain0 (n : ℕ) := Fin (n + 1) → ℝ

/-- `1`-cochains on the path nerve: one value per consecutive overlap
`Uᵢ ∩ Uᵢ₊₁` (an overlap discrepancy of local sections). -/
abbrev Cochain1 (n : ℕ) := Fin n → ℝ

/-- The Čech coboundary `δ⁰` on the path nerve: `(δ⁰ f) i = f(i+1) − f(i)`.
It records the jump of a `0`-cochain across the overlap `Uᵢ ∩ Uᵢ₊₁`. -/
def delta0 (f : Cochain0 n) : Cochain1 n := fun i => f i.succ - f i.castSucc

/-- **`H⁰` is the constants.**  A `0`-cochain is a (global) section — i.e. lies
in `ker δ⁰` — iff it is constant.  Equivalently the connected path nerve has
one-dimensional zeroth cohomology. -/
theorem delta0_eq_zero_iff_const (f : Cochain0 n) :
    delta0 f = 0 ↔ ∀ i j, f i = f j := by
  constructor
  · intro h
    have hstep : ∀ k : Fin n, f k.castSucc = f k.succ := by
      intro k
      have := congrFun h k
      simp only [delta0, Pi.zero_apply] at this
      linarith
    -- every value equals `f 0`
    have hval : ∀ k : Fin (n + 1), f k = f 0 := by
      intro k
      obtain ⟨k, hk⟩ := k
      induction k with
      | zero => rfl
      | succ m ih =>
          have hm : m < n + 1 := Nat.lt_of_succ_lt hk
          have hmn : m < n := Nat.succ_lt_succ_iff.mp hk
          have := hstep ⟨m, hmn⟩
          simp only [Fin.castSucc_mk, Fin.succ_mk] at this
          rw [← this]
          exact ih hm
    intro i j; rw [hval i, hval j]
  · intro h
    funext i
    simp only [delta0, Pi.zero_apply]
    rw [h i.succ i.castSucc]; ring

/-! ## §2. Vanishing of `H¹` on the path (tree) nerve -/

/-- **`H¹ = 0` on the path nerve.**  The coboundary `δ⁰` is surjective: every
overlap discrepancy `g` is realised as `δ⁰ f` for the explicit potential
`f k = ∑_{j < k} gⱼ` (a discrete primitive).  Consequently local sections on a
tree-shaped cover always glue: there is no cohomological obstruction. -/
theorem H1_path_vanishes :
    Function.Surjective (delta0 : Cochain0 n → Cochain1 n) := by
  intro g
  refine ⟨fun k => ∑ j ∈ Finset.univ.filter (fun j : Fin n => j.val < k.val), g j, ?_⟩
  funext i
  show (∑ j ∈ Finset.univ.filter (fun j : Fin n => j.val < (i.succ).val), g j)
      - (∑ j ∈ Finset.univ.filter (fun j : Fin n => j.val < (i.castSucc).val), g j) = g i
  have hsucc : (i.succ).val = i.val + 1 := rfl
  have hcast : (i.castSucc).val = i.val := rfl
  rw [hsucc, hcast]
  have hins : (Finset.univ.filter (fun j : Fin n => j.val < i.val + 1))
      = insert i (Finset.univ.filter (fun j : Fin n => j.val < i.val)) := by
    ext j
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_insert]
    constructor
    · intro hj
      rcases Nat.lt_succ_iff_lt_or_eq.mp hj with h | h
      · exact Or.inr h
      · exact Or.inl (Fin.ext h)
    · rintro (rfl | h)
      · omega
      · omega
  have hnotmem : i ∉ (Finset.univ.filter (fun j : Fin n => j.val < i.val)) := by
    simp
  rw [hins, Finset.sum_insert hnotmem]
  ring

/-- Restatement of `H1_path_vanishes` in gluing language: every overlap
discrepancy `g` on a path cover is a coboundary, hence local certificates glue
to a global potential. -/
theorem path_certificates_glue (g : Cochain1 n) :
    ∃ f : Cochain0 n, delta0 f = g :=
  H1_path_vanishes g

/-! ## §3. The cyclic nerve and its cohomological obstruction -/

/-- The cyclic coboundary on a loop nerve of `n+1` regions:
`(δ_cyc f) i = f(i+1) − f(i)` where `i+1` is taken **mod `n+1`** (the loop wraps
around, closing `Uₙ` back onto `U₀`). -/
def deltaCyc (f : Fin (n + 1) → ℝ) : Fin (n + 1) → ℝ := fun i => f (i + 1) - f i

/-- **Discrete monodromy vanishes for coboundaries.**  The total jump of any
cyclic coboundary around the loop is zero: `∑ᵢ (δ_cyc f) i = 0`.  This is the
holonomy constraint that a loop nerve imposes. -/
theorem deltaCyc_sum_zero (f : Fin (n + 1) → ℝ) : ∑ i, deltaCyc f i = 0 := by
  unfold deltaCyc
  rw [Finset.sum_sub_distrib]
  have : ∑ i : Fin (n + 1), f (i + 1) = ∑ i : Fin (n + 1), f i :=
    Equiv.sum_comp (Equiv.addRight (1 : Fin (n + 1))) f
  rw [this]; ring

/-- **Holonomy is the obstruction class.**  Any overlap discrepancy `g` with
nonzero loop sum `∑ᵢ gᵢ ≠ 0` is *not* a coboundary: no global reparametrisation
removes it.  This nonzero stalk class is a detected adversarial vulnerability. -/
theorem cyclic_not_coboundary {g : Fin (n + 1) → ℝ} (hg : ∑ i, g i ≠ 0) :
    ¬ ∃ f, deltaCyc f = g := by
  rintro ⟨f, rfl⟩
  exact hg (deltaCyc_sum_zero f)

/-- **`H¹ ≠ 0` on the loop nerve.**  The cyclic coboundary is *not* surjective:
the constant cochain `1`, whose loop sum is `n+1 ≠ 0`, has no primitive.  In
contrast to the path nerve, a loop cover carries genuine first cohomology — the
home of adversarial obstructions. -/
theorem cyclic_H1_nonvanishing :
    ¬ Function.Surjective (deltaCyc : (Fin (n + 1) → ℝ) → (Fin (n + 1) → ℝ)) := by
  intro hsurj
  obtain ⟨f, hf⟩ := hsurj (fun _ => 1)
  have hsum : (n : ℝ) + 1 = 0 := by
    have := deltaCyc_sum_zero f
    rw [hf] at this
    simpa using this
  have hn : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
  linarith

end SheafCohomologyRobustness