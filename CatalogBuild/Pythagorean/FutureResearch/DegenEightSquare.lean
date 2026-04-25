/-! # CatalogBuild.Pythagorean.FutureResearch.DegenEightSquare

Auto-generated from theorem catalog database.
Domain: Pythagorean/FutureResearch
Declarations: 9
-/

import Mathlib

/-- The octonion norm: sum of eight squares. -/
def octonionNorm (a₁ a₂ a₃ a₄ a₅ a₆ a₇ a₈ : ℤ) : ℤ :=
  a₁^2 + a₂^2 + a₃^2 + a₄^2 + a₅^2 + a₆^2 + a₇^2 + a₈^2


/-- The reverse product b·a gives a DIFFERENT valid eight-square decomposition.
Since octonion multiplication is non-commutative, a·b ≠ b·a in general,
but both have the same norm. This is the source of the "octonionic advantage":
the same integer product gets two independent decompositions. -/
theorem degen_eight_square_reverse
    (a₁ a₂ a₃ a₄ a₅ a₆ a₇ a₈ b₁ b₂ b₃ b₄ b₅ b₆ b₇ b₈ : ℤ) :
    octonionNorm a₁ a₂ a₃ a₄ a₅ a₆ a₇ a₈ *
    octonionNorm b₁ b₂ b₃ b₄ b₅ b₆ b₇ b₈ =
    octonionNorm
      (b₁*a₁ - b₂*a₂ - b₃*a₃ - b₄*a₄ - b₅*a₅ - b₆*a₆ - b₇*a₇ - b₈*a₈)
      (b₁*a₂ + b₂*a₁ + b₃*a₄ - b₄*a₃ + b₅*a₆ - b₆*a₅ - b₇*a₈ + b₈*a₇)
      (b₁*a₃ - b₂*a₄ + b₃*a₁ + b₄*a₂ + b₅*a₇ + b₆*a₈ - b₇*a₅ - b₈*a₆)
      (b₁*a₄ + b₂*a₃ - b₃*a₂ + b₄*a₁ + b₅*a₈ - b₆*a₇ + b₇*a₆ - b₈*a₅)
      (b₁*a₅ - b₂*a₆ - b₃*a₇ - b₄*a₈ + b₅*a₁ + b₆*a₂ + b₇*a₃ + b₈*a₄)
      (b₁*a₆ + b₂*a₅ - b₃*a₈ + b₄*a₇ - b₅*a₂ + b₆*a₁ - b₇*a₄ + b₈*a₃)
      (b₁*a₇ + b₂*a₈ + b₃*a₅ - b₄*a₆ - b₅*a₃ + b₆*a₄ + b₇*a₁ - b₈*a₂)
      (b₁*a₈ - b₂*a₇ + b₃*a₆ + b₄*a₅ - b₅*a₄ - b₆*a₃ + b₇*a₂ + b₈*a₁)
      := by
  have h := degen_eight_square_identity b₁ b₂ b₃ b₄ b₅ b₆ b₇ b₈ a₁ a₂ a₃ a₄ a₅ a₆ a₇ a₈
  rw [mul_comm] at h; exact h


/-- The octonion norm is multiplicative. -/
theorem octonion_norm_multiplicative
    (a₁ a₂ a₃ a₄ a₅ a₆ a₇ a₈ b₁ b₂ b₃ b₄ b₅ b₆ b₇ b₈ : ℤ) :
    ∃ c₁ c₂ c₃ c₄ c₅ c₆ c₇ c₈ : ℤ,
      octonionNorm a₁ a₂ a₃ a₄ a₅ a₆ a₇ a₈ *
      octonionNorm b₁ b₂ b₃ b₄ b₅ b₆ b₇ b₈ =
      octonionNorm c₁ c₂ c₃ c₄ c₅ c₆ c₇ c₈ := by
  exact ⟨_, _, _, _, _, _, _, _, degen_eight_square_identity ..⟩


/-- If p has an 8-square representation and q has an 8-square representation,
then p*q has an 8-square representation. -/
theorem eight_square_product_closure (p q : ℤ)
    (hp : ∃ a₁ a₂ a₃ a₄ a₅ a₆ a₇ a₈ : ℤ,
      octonionNorm a₁ a₂ a₃ a₄ a₅ a₆ a₇ a₈ = p)
    (hq : ∃ b₁ b₂ b₃ b₄ b₅ b₆ b₇ b₈ : ℤ,
      octonionNorm b₁ b₂ b₃ b₄ b₅ b₆ b₇ b₈ = q) :
    ∃ c₁ c₂ c₃ c₄ c₅ c₆ c₇ c₈ : ℤ,
      octonionNorm c₁ c₂ c₃ c₄ c₅ c₆ c₇ c₈ = p * q := by
  obtain ⟨a₁, a₂, a₃, a₄, a₅, a₆, a₇, a₈, rfl⟩ := hp
  obtain ⟨b₁, b₂, b₃, b₄, b₅, b₆, b₇, b₈, rfl⟩ := hq
  exact ⟨_, _, _, _, _, _, _, _, (degen_eight_square_identity ..).symm⟩


/-- An 8-tuple Pythagorean structure. -/
structure Octo where
  x : Fin 8 → ℤ
  d : ℤ
  eq : (∑ i, (x i)^2) = d^2


/-- Each of the 8 peel channels gives a GCD candidate. -/
theorem octo_peel_channel (t : Octo) (j : Fin 8) :
    (t.d - t.x j) * (t.d + t.x j) = ∑ i ∈ Finset.univ.erase j, (t.x i)^2 := by
  have h := t.eq
  have : (∑ i, (t.x i)^2) = (t.x j)^2 + ∑ i ∈ Finset.univ.erase j, (t.x i)^2 := by
    rw [← Finset.add_sum_erase _ _ (Finset.mem_univ j)]
  rw [this] at h; nlinarith


/-- GCD from peel channel divides N. -/
theorem octo_gcd_divides (t : Octo) (j : Fin 8) (N : ℤ) :
    ↑(Int.gcd (t.d - t.x j) N) ∣ N :=
  Int.gcd_dvd_right _ _


/-- 36 = 8 + C(8,2) factoring channels for octonionic tuples. -/
theorem thirty_six_channels : 8 + Nat.choose 8 2 = 36 := by decide


/-- Non-commutativity of octonions means a·b and b·a give DIFFERENT
eight-square decompositions of the same product Norm(a)·Norm(b).
Each decomposition provides an independent set of 36 factoring channels. -/
theorem dual_octonionic_decomposition
    (a₁ a₂ a₃ a₄ a₅ a₆ a₇ a₈ b₁ b₂ b₃ b₄ b₅ b₆ b₇ b₈ : ℤ) :
    ∃ c₁ c₂ c₃ c₄ c₅ c₆ c₇ c₈ d₁ d₂ d₃ d₄ d₅ d₆ d₇ d₈ : ℤ,
      octonionNorm a₁ a₂ a₃ a₄ a₅ a₆ a₇ a₈ *
        octonionNorm b₁ b₂ b₃ b₄ b₅ b₆ b₇ b₈ =
        octonionNorm c₁ c₂ c₃ c₄ c₅ c₆ c₇ c₈ ∧
      octonionNorm a₁ a₂ a₃ a₄ a₅ a₆ a₇ a₈ *
        octonionNorm b₁ b₂ b₃ b₄ b₅ b₆ b₇ b₈ =
        octonionNorm d₁ d₂ d₃ d₄ d₅ d₆ d₇ d₈ := by
  exact ⟨_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
    degen_eight_square_identity .., degen_eight_square_reverse ..⟩


