/-
Copyright (c) 2025 Non-Archimedean Information Theory Project. All rights reserved.

# Almost-Lossless Compression XV: Sharpness of the Threshold Frontier

## Bridge: Cauchy–Schwarz (analysis) ↔ fractional covering (combinatorics)
##         ↔ derandomized compression (coding)

The tunable derandomization of `Bridges.AlmostLosslessTunableMarkov` buys a pair
of constants `(c₁, c₂)` — silent-error constant `c₁`, failure constant `c₂` —
for any pair satisfying the **fractional covering condition** `1/c₁ + 1/c₂ ≤ 1`.
Two questions were left open:

1. *Is the covering condition itself necessary?*  Yes, for the counting method:
   `exists_covering_of_density_gt_one` builds, for every pair with
   `1/c₁ + 1/c₂ > 1` and every key space large enough, two bad-key sets of the
   permitted densities that **do** cover the key space, so no key survives.  The
   hypothesis `1/c₁ + 1/c₂ ≤ 1` is exactly the boundary of the method.

2. *Which point of the admissible frontier is best?*  Writing `L = |l|/M`, the
   total error of the `(c₁,c₂)`-scheme is `δ + (c₂ + c₁δ)·L`.  Theorem
   `frontier_total_constant_ge` shows by Cauchy–Schwarz that
   `c₂ + c₁·δ ≥ (1 + √δ)²` for **every** admissible pair — not merely for the
   one-parameter family `c₁ = 1+η`, `c₂ = 1+1/η` — and
   `frontier_total_constant_balanced` shows the bound is attained exactly at
   `c₁ = 1 + 1/√δ`, `c₂ = 1 + √δ`, the tuning of
   `MachineLearning.AlmostLosslessBalancedSilent`.

Together: `δ + (1+√δ)²·|l|/M` is the *exact* optimum of the entire two-sided
derandomization method, and the √δ-balanced key attains it.

The last section turns the frontier into a scheme:
`exists_frontier_almost_lossless_scheme` realises **every** point of the
hyperbola `c₂ = c/(c-1)` by an explicit key, and
`exists_scheme_silent_constant_near_one` reads off the limiting case: the silent
constant can be brought arbitrarily close to the first-moment optimum `1`, at
failure constant `(1+ε)/ε`.

## Impact: threshold_frontier_sharpness, covering_condition_necessary
-/

import Mathlib
import MachineLearning.AlmostLosslessBalancedSilent

open Finset BigOperators NonArchInfoTheory

namespace AlmostLossless

section Frontier

/-! ### Cauchy–Schwarz optimality over the admissible frontier -/

/-- **Optimality of the balanced point over the whole frontier.**  For any pair
of thresholds `c₁, c₂ > 0` satisfying the covering condition `1/c₁ + 1/c₂ ≤ 1`,
the total-error constant `c₂ + c₁·δ` of the resulting scheme is at least
`(1 + √δ)²`.

This is Cauchy–Schwarz in the sharp form
`(c₂ + c₁ s²)(1/c₁ + 1/c₂) = (1+s)² + (c₂ - c₁ s)²/(c₁c₂)` with `s = √δ`:
the excess is a perfect square, so it vanishes exactly on the balanced ray
`c₂ = c₁·√δ`. -/
theorem frontier_total_constant_ge (δ c₁ c₂ : ℝ) (hδ : 0 ≤ δ) (hc₁ : 0 < c₁)
    (hc₂ : 0 < c₂) (hcov : 1 / c₁ + 1 / c₂ ≤ 1) :
    (1 + Real.sqrt δ) ^ 2 ≤ c₂ + c₁ * δ := by
  obtain ⟨s, hs0, rfl⟩ : ∃ s : ℝ, 0 ≤ s ∧ δ = s ^ 2 :=
    ⟨Real.sqrt δ, Real.sqrt_nonneg δ, (Real.sq_sqrt hδ).symm⟩
  rw [Real.sqrt_sq hs0]
  have hpos : 0 < c₂ + c₁ * s ^ 2 := by positivity
  have hid : (c₂ + c₁ * s ^ 2) * (1 / c₁ + 1 / c₂)
      = (1 + s) ^ 2 + (c₂ - c₁ * s) ^ 2 / (c₁ * c₂) := by
    field_simp
    ring
  have hsq : 0 ≤ (c₂ - c₁ * s) ^ 2 / (c₁ * c₂) :=
    div_nonneg (sq_nonneg _) (le_of_lt (mul_pos hc₁ hc₂))
  have hle : (c₂ + c₁ * s ^ 2) * (1 / c₁ + 1 / c₂) ≤ (c₂ + c₁ * s ^ 2) * 1 :=
    mul_le_mul_of_nonneg_left hcov (le_of_lt hpos)
  rw [hid] at hle
  linarith

/-- **The balanced point attains the frontier optimum.**  At
`c₁ = 1 + 1/√δ` and `c₂ = 1 + √δ` the covering condition holds with equality
and `c₂ + c₁·δ = (1 + √δ)²`.  Hence the bound of `frontier_total_constant_ge`
is sharp, and the √δ-balanced scheme is *the* optimal member of the whole
two-parameter method, not just of the one-parameter family. -/
theorem frontier_total_constant_balanced (δ : ℝ) (hδ : 0 < δ) :
    1 / (1 + 1 / Real.sqrt δ) + 1 / (1 + Real.sqrt δ) = 1
    ∧ (1 + Real.sqrt δ) + (1 + 1 / Real.sqrt δ) * δ = (1 + Real.sqrt δ) ^ 2 := by
  obtain ⟨s, hs0, rfl⟩ : ∃ s : ℝ, 0 < s ∧ δ = s ^ 2 :=
    ⟨Real.sqrt δ, Real.sqrt_pos.mpr hδ, (Real.sq_sqrt (le_of_lt hδ)).symm⟩
  rw [Real.sqrt_sq (le_of_lt hs0)]
  have h1 : (0 : ℝ) < 1 + 1 / s := by positivity
  have h2 : (0 : ℝ) < 1 + s := by linarith
  constructor
  · field_simp
    ring
  · field_simp
    ring

end Frontier

section CoveringConverse

/-- Counting the keys below a threshold index. -/
theorem card_filter_val_lt (K n : ℕ) :
    (Finset.univ.filter (fun k : Fin K => k.val < n)).card = min n K := by
  classical
  rw [← Finset.card_image_of_injective _ Fin.val_injective]
  have himg : (Finset.univ.filter (fun k : Fin K => k.val < n)).image Fin.val
      = Finset.range (min n K) := by
    ext i
    simp only [Finset.mem_image, Finset.mem_filter, Finset.mem_univ, true_and,
      Finset.mem_range, lt_min_iff]
    constructor
    · rintro ⟨k, hk, rfl⟩; exact ⟨hk, k.isLt⟩
    · rintro ⟨h1, h2⟩; exact ⟨⟨i, h2⟩, h1, rfl⟩
  rw [himg, Finset.card_range]

/-- **The covering condition is necessary for the counting method.**

If `1/c₁ + 1/c₂ > 1` — quantitatively, if the excess density satisfies
`1 < K·(1/c₁ + 1/c₂ - 1)` — then there are two subsets `B₁, B₂` of the key space
whose sizes are *strictly* below the Markov thresholds (`|Bᵢ|·cᵢ < K`, exactly
the bound `card_badMassC_lt` provides) and which nevertheless **cover** the key
space.  No union-bound argument at thresholds `(c₁, c₂)` can therefore produce a
good key, and the hypothesis `1/c₁ + 1/c₂ ≤ 1` of `exists_tunable_good_key` is
the precise boundary of the two-sided derandomization method.

The construction is an interval split at `n = ⌈K/c₁⌉ - 1`: the lower block has
fewer than `K/c₁` keys by the ceiling bound, and the upper block has fewer than
`K/c₂` keys precisely because of the assumed density excess. -/
theorem exists_covering_of_density_gt_one {K : ℕ} (hK : 0 < K) {c₁ c₂ : ℝ}
    (hc₁ : 0 < c₁) (hc₂ : 0 < c₂) (hexc : 1 < (K : ℝ) * (1 / c₁ + 1 / c₂ - 1)) :
    ∃ B₁ B₂ : Finset (Fin K),
      ((B₁.card : ℝ) * c₁ < K) ∧ ((B₂.card : ℝ) * c₂ < K) ∧ B₁ ∪ B₂ = Finset.univ := by
  classical
  have hKR : (0 : ℝ) < K := by exact_mod_cast hK
  set x : ℝ := (K : ℝ) / c₁ with hx
  have hxpos : 0 < x := div_pos hKR hc₁
  set n : ℕ := ⌈x⌉₊ - 1 with hn
  have hceil1 : 1 ≤ ⌈x⌉₊ := Nat.one_le_ceil_iff.mpr hxpos
  have hncast : (n : ℝ) = (⌈x⌉₊ : ℝ) - 1 := by
    rw [hn, Nat.cast_sub hceil1, Nat.cast_one]
  have hnlt : (n : ℝ) < x := by
    have := Nat.ceil_lt_add_one (le_of_lt hxpos)
    rw [hncast]; linarith
  have hnge : x - 1 ≤ (n : ℝ) := by
    have := Nat.le_ceil x
    rw [hncast]; linarith
  refine ⟨Finset.univ.filter (fun k : Fin K => k.val < n),
    Finset.univ.filter (fun k : Fin K => ¬ k.val < n), ?_, ?_, ?_⟩
  · -- the lower block is below the `c₁`-threshold
    rw [card_filter_val_lt]
    have hmin : ((min n K : ℕ) : ℝ) ≤ (n : ℝ) := by
      exact_mod_cast Nat.min_le_left n K
    have : (n : ℝ) * c₁ < K := by
      rw [hx] at hnlt
      calc (n : ℝ) * c₁ < ((K : ℝ) / c₁) * c₁ := by
            exact mul_lt_mul_of_pos_right hnlt hc₁
        _ = K := by field_simp
    nlinarith [hmin, hc₁]
  · -- the upper block is below the `c₂`-threshold, thanks to the density excess
    have hpart : (Finset.univ.filter (fun k : Fin K => k.val < n)).card
        + (Finset.univ.filter (fun k : Fin K => ¬ k.val < n)).card = K := by
      have := Finset.card_filter_add_card_filter_not
        (s := (Finset.univ : Finset (Fin K))) (p := fun k : Fin K => k.val < n)
      simpa [Finset.card_univ] using this
    rw [card_filter_val_lt] at hpart
    rcases le_or_gt n K with hnK | hnK
    · have hmin : min n K = n := Nat.min_eq_left hnK
      rw [hmin] at hpart
      have hcard : ((Finset.univ.filter (fun k : Fin K => ¬ k.val < n)).card : ℝ)
          = (K : ℝ) - (n : ℝ) := by
        have : (Finset.univ.filter (fun k : Fin K => ¬ k.val < n)).card = K - n := by
          omega
        rw [this, Nat.cast_sub hnK]
      rw [hcard]
      -- `K - n < K/c₂` follows from `n ≥ K/c₁ - 1` and the density excess
      have hgoal : (K : ℝ) - (n : ℝ) < (K : ℝ) / c₂ := by
        have h1 : (K : ℝ) / c₁ - 1 ≤ (n : ℝ) := by rw [hx] at hnge; exact hnge
        have h2 : (1 : ℝ) < (K : ℝ) / c₁ + (K : ℝ) / c₂ - K := by
          have hrw : (K : ℝ) * (1 / c₁ + 1 / c₂ - 1)
              = (K : ℝ) / c₁ + (K : ℝ) / c₂ - K := by ring
          rw [hrw] at hexc; exact hexc
        linarith
      calc ((K : ℝ) - (n : ℝ)) * c₂ < ((K : ℝ) / c₂) * c₂ :=
            mul_lt_mul_of_pos_right hgoal hc₂
        _ = K := by field_simp
    · have hmin : min n K = K := Nat.min_eq_right (le_of_lt hnK)
      rw [hmin] at hpart
      have hzero : (Finset.univ.filter (fun k : Fin K => ¬ k.val < n)).card = 0 := by
        omega
      rw [hzero]
      simpa using hKR
  · -- the two blocks cover the key space
    ext k
    simp only [Finset.mem_union, Finset.mem_filter, Finset.mem_univ, true_and,
      iff_true]
    exact em _

end CoveringConverse

section FrontierScheme

variable {α : Type*} [Fintype α] [DecidableEq α] {K M : ℕ}

/-- **The frontier scheme: every point of the hyperbola is achievable.**

Parametrising the admissible frontier by the silent constant `c > 1` — the
boundary case of `1/c₁ + 1/c₂ ≤ 1` is `c₂ = c/(c-1)` — a single key achieves

1. silent-corruption probability `≤ c·δ·|l|/M`;
2. failure probability `≤ δ + (c/(c-1))·|l|/M`;
3. decoding cost exactly `|l|`.

This is the closed form of the whole trade-off curve: `c = 2` is the cycle-2
scheme, `c = 1 + 1/√δ` is the balanced scheme, and `c ↓ 1` drives the silent
constant to the first-moment optimum. -/
theorem exists_frontier_almost_lossless_scheme (μ : FinProbDist α)
    {H : Fin K → α → Fin M} (hU : Universal2 H) (hK : 0 < K) (hM : 0 < M)
    (l : List α) (hnd : l.Nodup) (δ : ℝ) (hδ : setMass μ (l.toFinset)ᶜ ≤ δ)
    {c : ℝ} (hc : 1 < c) :
    ∃ k : Fin K,
      setMass μ (Finset.univ.filter (fun x => ¬ (hashScheme l (H k)).Succeeds x))
          ≤ δ + (c / (c - 1)) * (l.length : ℝ) / M
      ∧ setMass μ (Finset.univ.filter (fun x => (hashScheme l (H k)).SilentError x))
          ≤ c * δ * (l.length : ℝ) / M
      ∧ ∀ i : Fin M, (scanCost (H k) i l).2 = l.length := by
  classical
  have hη : (0 : ℝ) < c - 1 := by linarith
  obtain ⟨k, hfail, hsilent, hcost⟩ :=
    exists_tunable_almost_lossless_scheme μ hU hK hM l hnd δ hδ hη
  have h1 : (1 : ℝ) + (c - 1) = c := by ring
  have h2 : (1 : ℝ) + 1 / (c - 1) = c / (c - 1) := by
    field_simp
    ring
  rw [h1] at hsilent
  rw [h2] at hfail
  exact ⟨k, hfail, hsilent, hcost⟩

/-- **The silent constant reaches the first-moment optimum.**  For every
`ε > 0` there is a key whose silent-corruption probability is at most
`(1+ε)·δ·|l|/M`: the constant `1` of the first-moment (averaging) bound is
approached arbitrarily closely by a single derandomized key, at the price of a
failure constant `(1+ε)/ε`.  This is the limiting statement behind the tunable
family. -/
theorem exists_scheme_silent_constant_near_one (μ : FinProbDist α)
    {H : Fin K → α → Fin M} (hU : Universal2 H) (hK : 0 < K) (hM : 0 < M)
    (l : List α) (hnd : l.Nodup) (δ : ℝ) (hδ : setMass μ (l.toFinset)ᶜ ≤ δ)
    {ε : ℝ} (hε : 0 < ε) :
    ∃ k : Fin K,
      setMass μ (Finset.univ.filter (fun x => (hashScheme l (H k)).SilentError x))
          ≤ (1 + ε) * δ * (l.length : ℝ) / M
      ∧ setMass μ (Finset.univ.filter (fun x => ¬ (hashScheme l (H k)).Succeeds x))
          ≤ δ + ((1 + ε) / ε) * (l.length : ℝ) / M := by
  have hc : (1 : ℝ) < 1 + ε := by linarith
  obtain ⟨k, hfail, hsilent, _⟩ :=
    exists_frontier_almost_lossless_scheme μ hU hK hM l hnd δ hδ hc
  have hrw : (1 + ε) - 1 = ε := by ring
  rw [hrw] at hfail
  exact ⟨k, hsilent, hfail⟩

end FrontierScheme

end AlmostLossless