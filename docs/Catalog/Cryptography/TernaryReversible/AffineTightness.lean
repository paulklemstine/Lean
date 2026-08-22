import Cryptography.TernaryReversible.AffineTest

/-!
# The length-`8` test for affine rules is sharp

`AffineTest.lean` reduces cycle-bijectivity of an affine ternary rule to injectivity on the
single cycle of length `8`.  Here we show that this length cannot be lowered: the affine
rule

`addRule 1 1 2 0 : a b c ↦ a + b + 2c`

is injective on **every** cycle of length `1, 2, 3, 4, 5, 6, 7` and yet fails at length `8`,
so no test using only cycles of length `≤ 7` can decide reversibility, even inside the
affine class.

The mechanism is arithmetic in `𝔽₉`: the characteristic polynomial `2x² + x + 1` of the
recurrence has roots of multiplicative order `8` in `𝔽₉ˣ` (a cyclic group of order `8`), so
the first cycle length carrying a nonzero kernel vector is exactly `8`.

## Main results

* `addRule_injective_iff_kernel_trivial` — for affine rules injectivity on a cycle is
  triviality of the kernel of the linear part;
* `affine_eight_test_sharp` — `addRule 1 1 2 0` is injective on all cycles of length
  `≤ 7` but is not cycle-bijective.
-/

namespace Cryptography
namespace TernaryReversible

set_option maxRecDepth 4000

/-- For an affine rule, injectivity of the global map on the cycle of length `n` is exactly
triviality of the kernel of its linear part on that cycle. -/
theorem addRule_injective_iff_kernel_trivial (α β γ δ : Alph) (n : ℕ) :
    Function.Injective (globalMap (n := n) (addRule α β γ δ)) ↔
      ∀ s : ZMod n → Alph, (∀ i : ZMod n, α * s (i - 1) + β * s i + γ * s (i + 1) = 0) →
        s = fun _ => 0 := by
  constructor
  · intro hinj s hker
    by_contra hs
    exact not_injective_of_kernel s hs hker hinj
  · intro hker s t hst
    have hzero : (fun i => s i - t i) = fun _ => (0 : Alph) := by
      refine hker _ ?_
      intro i
      have h := congrFun hst i
      have h' : α * s (i - 1) + β * s i + γ * s (i + 1) + δ
          = α * t (i - 1) + β * t i + γ * t (i + 1) + δ := h
      have : α * (s (i - 1) - t (i - 1)) + β * (s i - t i) + γ * (s (i + 1) - t (i + 1))
          = (α * s (i - 1) + β * s i + γ * s (i + 1) + δ)
            - (α * t (i - 1) + β * t i + γ * t (i + 1) + δ) := by ring
      rw [this, h']
      ring
    funext i
    have := congrFun hzero i
    exact sub_eq_zero.1 this

/-! ### The kernel of `a + b + 2c` is trivial on every cycle of length at most `7` -/

theorem kernel_trivial_112_one :
    ∀ s : ZMod 1 → Alph,
      (∀ i : ZMod 1, (1 : Alph) * s (i - 1) + 1 * s i + 2 * s (i + 1) = 0) → s = fun _ => 0 := by
  decide

theorem kernel_trivial_112_two :
    ∀ s : ZMod 2 → Alph,
      (∀ i : ZMod 2, (1 : Alph) * s (i - 1) + 1 * s i + 2 * s (i + 1) = 0) → s = fun _ => 0 := by
  decide

theorem kernel_trivial_112_three :
    ∀ s : ZMod 3 → Alph,
      (∀ i : ZMod 3, (1 : Alph) * s (i - 1) + 1 * s i + 2 * s (i + 1) = 0) → s = fun _ => 0 := by
  decide

theorem kernel_trivial_112_four :
    ∀ s : ZMod 4 → Alph,
      (∀ i : ZMod 4, (1 : Alph) * s (i - 1) + 1 * s i + 2 * s (i + 1) = 0) → s = fun _ => 0 := by
  decide

theorem kernel_trivial_112_five :
    ∀ s : ZMod 5 → Alph,
      (∀ i : ZMod 5, (1 : Alph) * s (i - 1) + 1 * s i + 2 * s (i + 1) = 0) → s = fun _ => 0 := by
  decide +kernel

theorem kernel_trivial_112_six :
    ∀ s : ZMod 6 → Alph,
      (∀ i : ZMod 6, (1 : Alph) * s (i - 1) + 1 * s i + 2 * s (i + 1) = 0) → s = fun _ => 0 := by
  decide +kernel

theorem kernel_trivial_112_seven :
    ∀ s : ZMod 7 → Alph,
      (∀ i : ZMod 7, (1 : Alph) * s (i - 1) + 1 * s i + 2 * s (i + 1) = 0) → s = fun _ => 0 := by
  decide +kernel

/-- **Sharpness of the length-`8` test.** The affine rule `a b c ↦ a + b + 2c` is injective
on every cycle of length at most `7`, yet is not bijective on the `8`-cycle, hence not
cycle-bijective.  So no finite test using cycles of length `≤ 7` decides reversibility. -/
theorem affine_eight_test_sharp :
    (∀ n : ℕ, 0 < n → n ≤ 7 → Function.Injective (globalMap (n := n) (addRule 1 1 2 0))) ∧
      ¬ CycleBijective (addRule 1 1 2 0) := by
  constructor
  · intro n hn hn7
    interval_cases n
    · exact (addRule_injective_iff_kernel_trivial 1 1 2 0 1).2 kernel_trivial_112_one
    · exact (addRule_injective_iff_kernel_trivial 1 1 2 0 2).2 kernel_trivial_112_two
    · exact (addRule_injective_iff_kernel_trivial 1 1 2 0 3).2 kernel_trivial_112_three
    · exact (addRule_injective_iff_kernel_trivial 1 1 2 0 4).2 kernel_trivial_112_four
    · exact (addRule_injective_iff_kernel_trivial 1 1 2 0 5).2 kernel_trivial_112_five
    · exact (addRule_injective_iff_kernel_trivial 1 1 2 0 6).2 kernel_trivial_112_six
    · exact (addRule_injective_iff_kernel_trivial 1 1 2 0 7).2 kernel_trivial_112_seven
  · exact kernel8a (by decide)

end TernaryReversible
end Cryptography