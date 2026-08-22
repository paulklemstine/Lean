import Cryptography.TernaryReversible.Additive
import Cryptography.TernaryReversible.Periodicity

/-!
# A single cycle length decides reversibility of affine ternary rules

`Additive.lean` shows that an affine rule `addRule α β γ δ` is bijective on every finite
cycle iff exactly one of `α, β, γ` is nonzero, the obstruction in the remaining cases being
a kernel vector living on a cycle of length `1`, `2`, `4` or `8` (the orders of the roots
of unity available in `𝔽₉ˣ`).

Combining this with the divisor monotonicity of `Periodicity.lean` — injectivity at length
`n` implies injectivity at every divisor of `n` — all four bad lengths can be *pulled up
into the single length* `8`, because `1, 2, 4, 8` all divide `8`.  The infinite test
"bijective on every cycle" therefore collapses, inside the affine class, to **one finite
test on the `8`-cycle**, i.e. to injectivity of a single map on `3⁸ = 6561` states.

## Main results

* `not_injective_at_eight_of_not_exactlyOne` — every affine obstruction is visible at
  length `8`;
* `addRule_cycleBijective_iff_injective_at_eight` — the one-length criterion;
* `addRule_bad_lengths_multiples_of_eight` — a non-reversible affine rule fails on *every*
  multiple of `8`, hence on infinitely many cycle lengths.
-/

namespace Cryptography
namespace TernaryReversible

/-- The ternary global map is the general one, specialised to `Alph`. -/
theorem globalMap_eq_globalMapA (g : LocalRule) (n : ℕ) :
    globalMap (n := n) g = globalMapA (n := n) g := rfl

/-- Every affine kernel obstruction, whatever its native length `1`, `2`, `4` or `8`, is
already visible on the cycle of length `8`. -/
theorem not_injective_at_eight_of_not_exactlyOne {α β γ δ : Alph}
    (h : ¬ ExactlyOneNonzero α β γ) :
    ¬ Function.Injective (globalMap (n := 8) (addRule α β γ δ)) := by
  have lift : ∀ m : ℕ, m ∣ 8 → ¬ Function.Injective (globalMap (n := m) (addRule α β γ δ)) →
      ¬ Function.Injective (globalMap (n := 8) (addRule α β γ δ)) := by
    intro m hm hmm
    rw [globalMap_eq_globalMapA]
    rw [globalMap_eq_globalMapA] at hmm
    exact not_injective_globalMapA_of_dvd hm hmm
  have hcases : ∀ x : Alph, x = 0 ∨ x = 1 ∨ x = 2 := by decide
  rcases hcases α with rfl | rfl | rfl <;> rcases hcases β with rfl | rfl | rfl <;>
    rcases hcases γ with rfl | rfl | rfl <;>
    first
      | exact absurd (show ExactlyOneNonzero _ _ _ by decide) h
      | exact lift 1 (by norm_num) (kernelInj1 (by decide))
      | exact lift 2 (by norm_num) (kernelInj2 (by decide))
      | exact lift 4 (by norm_num) (kernelInj4 (by decide))
      | exact kernelInj8a (by decide)
      | exact kernelInj8b (by decide)

/-- **One finite test.** An affine ternary radius-one rule is bijective on *every* nonempty
finite cycle as soon as its global map is injective on the single cycle of length `8`. -/
theorem addRule_cycleBijective_iff_injective_at_eight (α β γ δ : Alph) :
    CycleBijective (addRule α β γ δ) ↔
      Function.Injective (globalMap (n := 8) (addRule α β γ δ)) := by
  constructor
  · intro h
    exact (h 8 (by norm_num)).1
  · intro h
    by_cases hEx : ExactlyOneNonzero α β γ
    · exact addRule_cycleBijective_of_exactlyOne hEx
    · exact absurd h (not_injective_at_eight_of_not_exactlyOne hEx)

/-- A non-reversible affine rule is non-injective on every multiple of `8`: its set of bad
cycle lengths is infinite, never a sporadic single length. -/
theorem addRule_bad_lengths_multiples_of_eight {α β γ δ : Alph}
    (h : ¬ CycleBijective (addRule α β γ δ)) (k : ℕ) :
    ¬ Function.Injective (globalMap (n := 8 * k) (addRule α β γ δ)) := by
  have h8 : ¬ Function.Injective (globalMap (n := 8) (addRule α β γ δ)) := by
    intro hinj
    exact h ((addRule_cycleBijective_iff_injective_at_eight α β γ δ).2 hinj)
  rw [globalMap_eq_globalMapA]
  rw [globalMap_eq_globalMapA] at h8
  exact not_injective_globalMapA_of_dvd ⟨k, rfl⟩ h8

end TernaryReversible
end Cryptography