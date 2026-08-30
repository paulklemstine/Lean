import Mathlib
import Bridges.TwoTreeClosure.TreeCore

/-!
# What is left after the closure: the factor-derived oracle

`Bridges.TwoTreeClosure.TreeCore` shows that no function of the hypotenuse `N`
computes the ascent letter of a Berggren/Price node, because a semiprime
`N = p q` with `p ≡ q ≡ 1 [MOD 4]` sits at **two** different nodes whose letters
differ.  This file identifies the source of that ambiguity: it is exactly the
Brahmagupta–Fibonacci composition of the two factors.

* `brahmagupta_left`, `brahmagupta_right` : the two compositions of the sums of two
  squares `p = a² + b²` and `q = c² + d²`.
* `factor_oracle_family` : for `k = 10 t` the two compositions of `5 = 2² + 1²` with
  `k² + 1²` are precisely the two nodes of `letterOf_blind_of_magnitude`, so the
  factorisation data `(a, b, c, d)` separates letters that the magnitude cannot.
* `positional_content_needs_factorisation` : the sharp contrast — no magnitude probe
  computes the letter, while the representation data does.
-/

namespace TwoTreeClosure

/-- Brahmagupta–Fibonacci, first composition. -/
theorem brahmagupta_left (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) = (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 := by
  ring

/-- Brahmagupta–Fibonacci, second composition. -/
theorem brahmagupta_right (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) = (a * c + b * d) ^ 2 + (a * d - b * c) ^ 2 := by
  ring

/-- **The two compositions of `5 · (k² + 1)` are the two colliding nodes.**
Taking `(a,b) = (2,1)` (so `a² + b² = 5`) and `(c,d) = (k,1)`, the first Brahmagupta
composition is the pair `(2k - 1, k + 2)` and the second is `(2k + 1, ±(k - 2))`. -/
theorem factor_oracle_family (k : ℤ) :
    (2 ^ 2 + 1 ^ 2) * (k ^ 2 + 1 ^ 2) = (2 * k - 1) ^ 2 + (k + 2) ^ 2 ∧
    (2 ^ 2 + 1 ^ 2) * (k ^ 2 + 1 ^ 2) = (2 * k + 1) ^ 2 + (k - 2) ^ 2 ∧
    (2 * k - 1 * 1, 2 * 1 + 1 * k) = (2 * k - 1, k + 2) ∧
    (2 * k + 1 * 1, -(2 * 1 - 1 * k)) = (2 * k + 1, k - 2) := by
  refine ⟨?_, ?_, by norm_num [add_comm], by ring_nf⟩
  · have h := brahmagupta_left 2 1 k 1
    rw [h]; ring
  · have h := brahmagupta_right 2 1 k 1
    rw [h]; ring

/-- The two compositions really are different points: the collision is genuine and
not a relabelling. -/
theorem factor_oracle_distinct (k : ℤ) :
    (2 * k - 1, k + 2) ≠ ((2 * k + 1 : ℤ), k - 2) := by
  intro h
  have h1 := congrArg Prod.fst h
  simp only at h1
  omega

/-- **Positional content needs the factorisation.**  On the one hand no probe reading
only the hypotenuse computes the ascent letter; on the other hand the pair of
Gaussian-composition coordinates does, and the two coordinates of the collision
family are produced by the two Brahmagupta compositions of the factors. -/
theorem positional_content_needs_factorisation :
    (∀ f : ℕ → Letter, ¬ (∀ m n, IsNode m n → f (hyp m n) = letterOf m n)) ∧
    (∀ t : ℕ, 1 ≤ t →
      hyp (20 * t - 1) (10 * t + 2) = hyp (20 * t + 1) (10 * t - 2) ∧
      letterOf (20 * t - 1) (10 * t + 2) ≠ letterOf (20 * t + 1) (10 * t - 2)) := by
  refine ⟨magnitude_probe_letterBlind, ?_⟩
  intro t ht
  obtain ⟨-, -, hh, hA, hB⟩ := letterOf_blind_of_magnitude t ht
  exact ⟨hh, by rw [hA, hB]; exact Letter.noConfusion⟩

/-- The collision hypotenuse of the family, in closed form: `500 t² + 5 = 5 (100 t² + 1)`,
a semiprime whenever `100 t² + 1` is prime (e.g. `t = 1`: `505 = 5 · 101`). -/
theorem collision_hyp_closed_form (t : ℕ) (ht : 1 ≤ t) :
    hyp (20 * t - 1) (10 * t + 2) = 5 * (100 * t ^ 2 + 1) := by
  obtain ⟨s, rfl⟩ : ∃ s, t = s + 1 := ⟨t - 1, by omega⟩
  simp only [hyp]
  rw [show 20 * (s + 1) - 1 = 20 * s + 19 from by omega,
      show 10 * (s + 1) + 2 = 10 * s + 12 from by omega]
  ring

end TwoTreeClosure