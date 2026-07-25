import Mathlib

/-! # Pythagorean.QuadrupleParity

Parity structure of an integer **Pythagorean quadruple** `a² + b² + c² = d²`.

Unlike triples, where the parity split is `(even, odd)` among the two legs, a quadruple
is much more rigid: at most one of the three "spatial" entries can be odd.  We prove:

* `at_least_two_even` — among `a, b, c` at least two are even;
* `four_dvd_prod`     — consequently `4 ∣ a·b·c`.

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): quadruples inherit a parity obstruction one dimension up
--   from triples. Conjecture: "exactly two even" is impossible in the wrong direction,
--   i.e. you can never have two odd legs.
-- Experiment (Experimenter): squares mod 4 lie in {0,1}, and an even square is ≡ 0
--   mod 4. Hence a²+b²+c² ≡ #odd(a,b,c) (mod 4). Since d² ∈ {0,1} mod 4, we need
--   #odd ∈ {0,1}. A `ZMod 4` enumeration confirms `w·x·y = 0` whenever w²+x²+y²=z².
-- Analysis (Analyst): the count-of-odds ≡ sum-of-squares mod 4 is the structural
--   invariant; it forbids the "two odd" configuration that triples freely allow.
-- Critique (Critic): the statement is non-vacuous — `1²+2²+2² = 3²` realises "two even",
--   and `(a,b,c,d)=(1,2,2,3)` gives `4 ∣ 1·2·2 = 4`. No decide-only main theorem: the
--   parity transfer through `ZMod 4 →+* ZMod 2` is the load-bearing insight.
-- Synthesis (PI): the parity theorem and its divisibility corollary are exported as
--   reusable `ℤ`-level facts.
-/

namespace Pythagorean.QuadrupleParity

/-- Among the three entries `a, b, c` of a Pythagorean quadruple `a²+b²+c²=d²`,
    at least two are even. -/
theorem at_least_two_even (a b c d : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (Even a ∧ Even b) ∨ (Even a ∧ Even c) ∨ (Even b ∧ Even c) := by
  set f : ZMod 4 →+* ZMod 2 := ZMod.castHom (by norm_num : (2 : ℕ) ∣ 4) (ZMod 2) with hf
  have key : ∀ w x y z : ZMod 4, w ^ 2 + x ^ 2 + y ^ 2 = z ^ 2 →
      (f w = 0 ∧ f x = 0) ∨ (f w = 0 ∧ f y = 0) ∨ (f x = 0 ∧ f y = 0) := by
    rw [hf]; decide
  have hcast : ((a : ZMod 4)) ^ 2 + (b : ZMod 4) ^ 2 + (c : ZMod 4) ^ 2 = (d : ZMod 4) ^ 2 := by
    have := congrArg (Int.cast : ℤ → ZMod 4) h; push_cast at this; exact this
  have hk := key a b c d hcast
  have glue : ∀ x : ℤ, f (x : ZMod 4) = 0 ↔ Even x := by
    intro x
    have hfx : f (x : ZMod 4) = ((x : ℤ) : ZMod 2) := by rw [hf]; simp
    rw [hfx, ZMod.intCast_zmod_eq_zero_iff_dvd, even_iff_two_dvd]; norm_num
  rw [glue, glue, glue] at hk
  exact hk

/-- The product of the three entries of a Pythagorean quadruple is divisible by `4`. -/
theorem four_dvd_prod (a b c d : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (4 : ℤ) ∣ a * b * c := by
  have key : ∀ w x y z : ZMod 4, w ^ 2 + x ^ 2 + y ^ 2 = z ^ 2 → w * x * y = 0 := by decide
  have hcast : ((a : ZMod 4)) ^ 2 + (b : ZMod 4) ^ 2 + (c : ZMod 4) ^ 2 = (d : ZMod 4) ^ 2 := by
    have := congrArg (Int.cast : ℤ → ZMod 4) h; push_cast at this; exact this
  have hk := key a b c d hcast
  have : ((a * b * c : ℤ) : ZMod 4) = 0 := by push_cast; exact hk
  exact (ZMod.intCast_zmod_eq_zero_iff_dvd _ 4).mp this

/-- Non-vacuity witness: `1² + 2² + 2² = 3²`, and indeed `4 ∣ 1·2·2`. -/
example : (4 : ℤ) ∣ 1 * 2 * 2 := four_dvd_prod 1 2 2 3 (by norm_num)

end Pythagorean.QuadrupleParity