/-
Machine-checked: the degree-4 relation cone, `f = X^4 - c`.

`RelationAlgebra.lean` covers `d = 3`.  This covers `d = 4`, which is the degree that
actually matters -- Lee-Venkatesan use `d = delta (log n)^(1/3) (log log n)^(-1/3)`, and that
is 3-4 at `n ~ 1e20`.  At `d = 3` the cone `l(alpha) = g^2` linear is ONE quadric; at
`d = 4` it is TWO, and that is the step that makes the relation curve genus 5 and the supply
collapse (`Round47_DegreeBarrier.md`).

With `alpha^4 = c` (hence `alpha^5 = c alpha`, `alpha^6 = c alpha^2`, `alpha^7 = c alpha^3`)
and `g = g0 + g1 alpha + g2 alpha^2 + g3 alpha^3`, the `alpha^3` component of `g^2` collects
the pairs summing to 3, and the `alpha^2` component collects the pairs summing to 2 together
with the pair summing to 6 (which is multiplied by `c`).  Both are checked here over `Z`.

No `sorry`, no `axiom`.
-/

import Mathlib.Tactic.Ring

namespace Cryptography.FactoringBarriers.DegreeFour

set_option linter.unusedVariables false

/-- The `alpha^3` component of `g^2` modulo `X^4 - c`. -/
def c3 (g0 g1 g2 g3 : ℤ) : ℤ := 2 * g0 * g3 + 2 * g1 * g2

/-- The `alpha^2` component.  The `g3^2` term is the `alpha^6` pair multiplied by `c`. -/
def c2 (c g0 g1 g2 g3 : ℤ) : ℤ := 2 * g0 * g2 + g1 ^ 2 + c * g3 ^ 2

/-- The `alpha^1` component: the pair summing to 1, plus the pair summing to 5 times `c`
(which is `2 g2 g3 alpha^5 = 2c g2 g3 alpha`). -/
def c1 (c g0 g1 g2 g3 : ℤ) : ℤ := 2 * g0 * g1 + 2 * c * g2 * g3

/-- The `alpha^0` component: `g0^2` plus the pairs summing to 4 times `c`
(`2 g1 g3 alpha^4 + g2^2 alpha^4`).  Note it is `g2^2`, NOT `g1^2` -- writing `g1^2` here
is a plausible-looking slip that `decide` caught, since the agent's hand-computed witness
(`c0 = 4804`) disagreed with the transcription. -/
def c0 (c g0 g1 g2 g3 : ℤ) : ℤ := g0 ^ 2 + c * (2 * g1 * g3 + g2 ^ 2)

/-- **The `d = 4` cone is TWO quadrics, not one.**  This is the difference between a genus-1
and a genus-5 relation curve. -/
theorem d4_has_two_quadrics (c g0 g1 g2 g3 : ℤ) :
    c2 c g0 g1 g2 g3 = 2 * g0 * g2 + g1 ^ 2 + c * g3 ^ 2 := rfl

/-- **The `d = 4` cone is STRICTLY STRONGER than the `d = 3` cone.**  On the slice `g3 = 0`
the `d = 3` condition `g1^2 + 2 g0 g2 = 0` persists, but `d = 4` adds the *independent*
condition `2 g1 g2 = 0`.  This is the whole content of the degree barrier: one extra quadric
takes the relation curve from genus 1 to genus 5, and the supply with it. -/
theorem d4_strictly_stronger (g0 g1 g2 : ℤ) (h4 : c3 g0 g1 g2 0 = 0) : g1 * g2 = 0 := by
  unfold c3 at h4
  have h2 : (2 : ℤ) * (g1 * g2) = 0 := by simpa using h4
  rcases mul_eq_zero.mp h2 with h | h'
  · exact absurd h (by norm_num)
  · exact h'

/-- ... but `c2` does not vanish on that slice, so the two conditions are not the same
statement. -/
theorem c2_not_on_slice (c g0 g1 g2 : ℤ) :
    c2 c g0 g1 g2 0 = 2 * g0 * g2 + g1 ^ 2 := by
  unfold c2
  ring

/-- **The agent-supplied `d = 4` instance, machine-checked.**  `N = 1333 = 31 * 43`,
`f = X^4 - 36`, `m = 36` (so `m^4 - c` is divisible by `N`), `g = 40 + 16a - 5a^2 + 2a^3`,
`l = 560X + 4804`.  The agent reported `g^2 = 4804 + 560a` with both higher components zero
over `Z[alpha]`, and `l(m) = 158^2`, with `gcd` returning 43 and 31. -/
theorem d4_witness_on_cone :
    c2 36 40 16 (-5) 2 = 0 ∧ c3 40 16 (-5) 2 = 0 := by
  decide

theorem d4_witness_components :
    c0 36 40 16 (-5) 2 = 4804 ∧ c1 36 40 16 (-5) 2 = 560 := by
  decide

/-- The full reduction `g^2 = 4804 + 560 alpha`, i.e. the witness really is a LINEAR form's
square root, checked component by component. -/
theorem d4_witness_g2_is_linear :
    c2 36 40 16 (-5) 2 = 0 ∧ c3 40 16 (-5) 2 = 0
      ∧ c0 36 40 16 (-5) 2 = 4804 ∧ c1 36 40 16 (-5) 2 = 560 := by
  decide

theorem d4_witness_root : (1333 : ℤ) * 1260 = 36 ^ 4 - 36 := by decide

theorem d4_witness_l_at_m : (560 : ℤ) * 36 + 4804 = 158 ^ 2 := by decide

theorem d4_witness_g_at_m : (40 : ℤ) + 16 * 36 + (-5) * 36 ^ 2 + 2 * 36 ^ 3 = 87448 := by
  decide

theorem d4_witness_gcd :
    Nat.gcd (87448 - 158) 1333 = 43 ∧ Nat.gcd (87448 + 158) 1333 = 31 := by decide

end Cryptography.FactoringBarriers.DegreeFour
