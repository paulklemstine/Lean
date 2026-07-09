import Catalog.Applications.CellularAutomataVariety.Basic

/-!
# Fixed-point counts and the refutation of the complexity–dimension conjecture

Building on `CellularAutomataVariety.Basic`, this file records the *sizes* of the
fixed-point varieties `V(g)` — i.e. their numbers of `GF(2)`-points — and assembles
the central comparison.

For a linear variety `V ⊆ GF(2)^n` the number of points is `2^{dim V}`, so the
counts below translate directly into dimensions:

| rule | behaviour            | `|V(g)|`                     | dimension            |
|------|----------------------|------------------------------|----------------------|
| 204  | identity (Class 2)   | `2^n`                        | `n`  (maximal)       |
| 90   | additive             | `4` if `3 ∣ n`, else `1`     | `2` or `0`           |
| 150  | additive             | `4` if `n` even, else `2`    | `2` or `1`           |
| 110  | universal (Class 4)  | `1`                          | `0`  (minimal)       |

The decade corollaries below verify the additive number-theoretic patterns on
small cycles (Fibonacci/Pisano period `3` for Rule 90; parity for Rule 150), and
confirm the Rule 110 collapse computationally.  The two *general* theorems are
`rule204_fixedCount` (the identity attains the full `2^n`) and, from `Basic`,
`rule110_fixed_iff_zero` (the universal rule collapses to one point).

-- !-- Lab Notes -- !--

HYPOTHESIS.  If "complexity = dimension" held, Rule 110 (Class 4) would maximise
`|V(g)| = 2^n` and Rule 204 (Class 2) would not.

EXPERIMENT.  `rule110_fixedCount_*` show `|V(rule110)| = 1` on every tested cycle,
while `rule204_fixedCount` proves `|V(rule204)| = 2^n` for all `n`.

ANALYSIS.  The inequality is *inverted*: the universal rule has the smallest
variety, the trivial rule the largest.  The additive rules interpolate, with
dimensions dictated by pure arithmetic (divisibility by `3`, parity).

CRITIQUE.  The general claims (`rule204_fixedCount`, `complexity_dimension_refuted`)
are not `decide`-only; the small-cycle counts are labelled as computational
evidence for the arithmetic patterns and are kernel-checked by `decide`.

SYNTHESIS.  `complexity_dimension_refuted` is the corrected headline: fixed-point
dimension does not measure dynamical complexity.
-/

namespace CellularAutomataVariety

/-- The number of `GF(2)`-points of the fixed-point variety on a cycle of length
`n`: the count of configurations left unchanged by the rule. -/
def fixedCount (n : ℕ) [NeZero n] (g : Cell → Cell → Cell → Cell) : ℕ :=
  (Finset.univ.filter (fun s : Config n => step g s = s)).card

/-! ## The identity rule fills the whole space -/

/-- **Identity rule, exact count.**  For every cycle length the identity fixes all
`2^n` configurations: its variety is the whole affine space `GF(2)^n`. -/
theorem rule204_fixedCount (n : ℕ) [NeZero n] : fixedCount n rule204 = 2 ^ n := by
  unfold fixedCount
  have hall : (Finset.univ.filter (fun s : Config n => step rule204 s = s)) = Finset.univ := by
    apply Finset.filter_true_of_mem
    intro s _
    exact rule204_fixes_all s
  rw [hall, Finset.card_univ, Fintype.card_fun]
  simp [ZMod.card]

/-! ## Additive rules: Fibonacci (Rule 90) and parity (Rule 150)

These small-cycle counts are the computational evidence for the arithmetic of the
additive varieties. -/

/-- Rule 90 on the triangle: the Fibonacci recurrence closes up (`3 ∣ 3`), giving
a `2`-dimensional variety. -/
theorem rule90_fixedCount_three : fixedCount 3 rule90 = 4 := by decide
/-- Rule 90 on the square: the recurrence does not close (`3 ∤ 4`), collapsing to
the origin. -/
theorem rule90_fixedCount_four : fixedCount 4 rule90 = 1 := by decide
/-- Rule 90 on the pentagon (`3 ∤ 5`): the origin only. -/
theorem rule90_fixedCount_five : fixedCount 5 rule90 = 1 := by decide
/-- Rule 90 on the hexagon (`3 ∣ 6`): a `2`-dimensional variety again. -/
theorem rule90_fixedCount_six : fixedCount 6 rule90 = 4 := by decide

/-- Rule 150 on the triangle (odd): two-periodicity forces constancy, dimension
`1`. -/
theorem rule150_fixedCount_three : fixedCount 3 rule150 = 2 := by decide
/-- Rule 150 on the square (even): even and odd sublattices are independent,
dimension `2`. -/
theorem rule150_fixedCount_four : fixedCount 4 rule150 = 4 := by decide
/-- Rule 150 on the pentagon (odd): dimension `1`. -/
theorem rule150_fixedCount_five : fixedCount 5 rule150 = 2 := by decide
/-- Rule 150 on the hexagon (even): dimension `2`. -/
theorem rule150_fixedCount_six : fixedCount 6 rule150 = 4 := by decide

/-! ## The universal Rule 110 collapses to a point -/

theorem rule110_fixedCount_two : fixedCount 2 rule110 = 1 := by decide
theorem rule110_fixedCount_three : fixedCount 3 rule110 = 1 := by decide
theorem rule110_fixedCount_four : fixedCount 4 rule110 = 1 := by decide
theorem rule110_fixedCount_five : fixedCount 5 rule110 = 1 := by decide
theorem rule110_fixedCount_six : fixedCount 6 rule110 = 1 := by decide

/-! ## The headline refutation

The Turing-complete Rule 110 has the *smallest* possible fixed-point variety (a
single point, dimension `0`), while the dynamically trivial identity Rule 204 has
the *largest* (the whole space, dimension `n`).  This inverts the conjectured
correspondence "dynamical complexity = fixed-point dimension". -/

/-- **Complexity–dimension conjecture, refuted.**  On every nonempty cycle, the
identity rule (Wolfram Class 2) fixes the entire space, whereas the
computationally universal Rule 110 (Wolfram Class 4) fixes only the zero
configuration.  Hence the dimension of the fixed-point variety does *not* increase
with dynamical complexity. -/
theorem complexity_dimension_refuted {n : ℕ} [NeZero n] :
    (∀ s : Config n, IsFixed rule204 s) ∧ (∀ s : Config n, IsFixed rule110 s ↔ s = 0) :=
  ⟨rule204_fixes_all, rule110_fixed_iff_zero⟩

/-- Quantitative form of the refutation on any cycle of length `≥ 2`: the identity
variety has strictly more points than the Rule 110 variety, and the gap grows
exponentially. -/
theorem rule204_gt_rule110_count {n : ℕ} [NeZero n] (hn : 2 ≤ n) :
    fixedCount n rule110 < fixedCount n rule204 := by
  have h204 : fixedCount n rule204 = 2 ^ n := rule204_fixedCount n
  have h110 : fixedCount n rule110 ≤ 1 := by
    unfold fixedCount
    have hsub : (Finset.univ.filter (fun s : Config n => step rule110 s = s)) ⊆ {0} := by
      intro s hs
      rw [Finset.mem_filter] at hs
      have : IsFixed rule110 s := hs.2
      rw [rule110_fixed_iff_zero] at this
      simp [this]
    calc (Finset.univ.filter (fun s : Config n => step rule110 s = s)).card
        ≤ ({0} : Finset (Config n)).card := Finset.card_le_card hsub
      _ = 1 := Finset.card_singleton _
  have : (2 : ℕ) ^ 2 ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) hn
  omega

end CellularAutomataVariety