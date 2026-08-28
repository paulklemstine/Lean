import Pythagorean.SeqHint.Battery
import Pythagorean.SeqHint.Adaptive
import Pythagorean.SeqHint.FermatStrata
import Pythagorean.SeqHint.Economics

/-!
# Sequential hint pricing V: synthesis — one pricing structure, two faces

This file assembles the four preceding files into the statement the experiment
was designed to test, and records the machine-checked instances of the measured
configuration.

**The dichotomy.**  On one and the same search window, and for one and the same
number `k` of truthful `p ≤ t?` hints,

* every **fixed** battery leaves at least `#W / (k + 1)` candidates
  indistinguishable (`nonadapt_linear_pricing`) — linear pricing, the paper-138
  no-synergy law;
* the **adaptive** arm leaves at most `⌈#W / 2 ^ k⌉` (`bisect_width_le`) —
  geometric pricing;
* and no strategy at all beats `2 ^ k` (`isolation_ceiling`) — a hard ceiling.

`pricing_dichotomy` states the three together, and `premium_gap` extracts the
ratio `2 ^ k / (k + 1)`, which is `1` exactly at `k = 1` and grows without
bound.  So "hints price linearly" and "sequential hints compound" are not in
conflict: they are the non-adaptive and adaptive faces of a single law, and the
compounding face saturates exactly at the isolation ceiling.

**The balanced face, concretely.**  `balanced_dichotomy` is the headline
configuration at bit length `40`: on the balanced support window
`[720000, 723600)` (`ρ ≤ 1.01`, `3600` candidates),

* the `24`-threshold uniform fixed battery leaves **all 3600** candidates — it
  carries literally zero bits, speedup exactly `1.00`;
* while `12` adaptive queries isolate the factor **exactly** — speedup `3600`.

Half the queries, and the entire uncertainty removed instead of none of it.

## Lab notes (data from exp 563, seed 20260824, `n = 800` bitlen-40 semiprimes)

| quantity                                  | balanced (600 N) | unbalanced (200 N) | model here                  |
|-------------------------------------------|------------------|--------------------|-----------------------------|
| `s_adapt(12) / s_adapt(3)`                | `20.8×`          | `165.2×`           | `2 ^ 9 = 512×` (idealized)  |
| premium `r(12)` over matched fixed battery| `20.8×`          | `239.5×`           | `premium 12 = 4096/13`      |
| premium `r(1)`                            | `1.00`           | `1.00`             | `premium 1 = 1` exactly     |
| pin fraction at `k = 20 = ⌈log₂ W⌉`       | `100 %`          | `100 %`            | `ceiling_is_exact`          |
| fixed-battery speedup, all `k ≤ 24`       | `1.00` exactly   | linear             | `zero_bit_collapse`         |
| `k_opt` measured / predicted              | `10 / 9.54`      | `18 / 17.60`       | `netCost_int_argmin`        |

The measured ratios lie *below* the idealized ones because the empirical
`s_adapt` is priced in divisibility tests with an additive floor, while the model
counts pure candidate-space reduction; the qualitative laws — linear vs
geometric, `r(1) = 1`, hard pin at `⌈log₂ W⌉` — are the ones proved here.
-/

namespace Pythagorean.SeqHint

open Finset

/-- **The pricing dichotomy.**  Fixed batteries price linearly, adaptive queries
price geometrically, and nothing beats the geometric ceiling. -/
theorem pricing_dichotomy (m k : ℕ) (hk : k ≤ m) (T : Finset ℕ) (x : ℕ)
    (hx : x ∈ (Window.mk 0 (2 ^ m)).carrier) :
    -- (1) linear pricing of any fixed battery of `#T` thresholds
    (∃ C ⊆ Finset.Ico 0 (2 ^ m),
        2 ^ m / (T.card + 1) ≤ C.card ∧ ∀ a ∈ C, ∀ b ∈ C, ∀ t ∈ T, (a ≤ t ↔ b ≤ t)) ∧
    -- (2) geometric pricing of the adaptive arm
    (bisect x k ⟨0, 2 ^ m⟩).width ≤ 2 ^ (m - k) ∧
    -- (3) no strategy at all beats the geometric ceiling
    (∀ S : Strategy, ∀ j < m, ∃ a ∈ (Window.mk 0 (2 ^ m)).carrier,
        ∃ b ∈ (Window.mk 0 (2 ^ m)).carrier, a ≠ b ∧ transcript S a j = transcript S b j) := by
  refine ⟨?_, ?_, (ceiling_is_exact m).2⟩
  · have h := nonadapt_linear_pricing T (Finset.Ico 0 (2 ^ m))
    have hcard : (Finset.Ico 0 (2 ^ m)).card = 2 ^ m := by simp
    rw [hcard] at h
    exact h
  · have hw : (Window.mk 0 (2 ^ m)).width = 2 ^ m := by simp [Window.width]
    calc (bisect x k ⟨0, 2 ^ m⟩).width
        ≤ halfIter k (Window.mk 0 (2 ^ m)).width := bisect_width_le x k _ hx
      _ = halfIter k (2 ^ m) := by rw [hw]
      _ = 2 ^ (m - k) := halfIter_pow k m hk

/-- **The premium gap.**  The two faces of the law differ by the factor
`2 ^ k / (k + 1)`: exactly `1` at `k ≤ 1`, and unbounded thereafter. -/
theorem premium_gap (k : ℕ) :
    premium k = 2 ^ k / (k + 1) ∧ premium 1 = 1 ∧ (5 ≤ k → (k : ℚ) ≤ premium k) := by
  refine ⟨rfl, premium_one, fun hk => premium_superlinear k hk⟩

/-- **The headline balanced configuration, machine-checked.**  On the balanced
support window at bit length `40`: the `24`-query uniform fixed battery removes
*no* uncertainty at all, while `12` adaptive queries remove *all* of it. -/
theorem balanced_dichotomy :
    cls (uniformBattery 1048576 24) (Ico 720000 723600)
        (sig (uniformBattery 1048576 24) 720000) = Ico 720000 723600 ∧
    ∀ x ∈ (Window.mk 720000 723600).carrier,
      (bisect x 12 ⟨720000, 723600⟩).carrier = {x} := by
  refine ⟨uniform_battery_residual_full, ?_⟩
  intro x hx
  refine bisection_isolates x 12 ⟨720000, 723600⟩ hx ?_
  simp [Window.width]

/-- The saturation point of the experiment: on the `2 ^ 20` window used at bit
length `40`, `20` adaptive queries pin every candidate exactly, and no strategy
with `19` or fewer queries pins any. -/
theorem saturation_at_twenty :
    (∀ x ∈ (Window.mk 0 (2 ^ 20)).carrier, (bisect x 20 ⟨0, 2 ^ 20⟩).carrier = {x}) ∧
    (∀ S : Strategy, ∃ a ∈ (Window.mk 0 (2 ^ 20)).carrier,
        ∃ b ∈ (Window.mk 0 (2 ^ 20)).carrier, a ≠ b ∧ transcript S a 19 = transcript S b 19) := by
  obtain ⟨h₁, h₂⟩ := ceiling_is_exact 20
  exact ⟨h₁, fun S => h₂ S 19 (by norm_num)⟩

/-! ### Numerical values of the premium curve (the `k`-grid of the experiment) -/

example : premium 0 = 1 := by norm_num [premium]
example : premium 2 = 4 / 3 := by norm_num [premium]
example : premium 3 = 2 := by norm_num [premium]
example : premium 6 = 64 / 7 := by norm_num [premium]
example : premium 9 = 512 / 10 := by norm_num [premium]
example : premium 12 = 4096 / 13 := by norm_num [premium]
example : premium 20 = 1048576 / 21 := by norm_num [premium]

/-- The idealized compounding ratio between the two grid points the experiment
compares, `k = 3` and `k = 12`: a factor `2 ^ 9 = 512`, versus the factor `4`
that linear pricing would predict. -/
theorem grid_ratio_three_to_twelve :
    halfIter 3 (2 ^ 20) / halfIter 12 (2 ^ 20) = 512 := by
  rw [halfIter_pow 3 20 (by norm_num), halfIter_pow 12 20 (by norm_num)]
  norm_num

end Pythagorean.SeqHint