import Mathlib
import Speculative.SumThreeCubes.Defs

/-!
# Bounded Search for Sum of Three Cubes

We prove soundness and monotonicity of the bounded-search representability
predicate, establishing it as a certified semidecision procedure for the
sum-of-three-cubes problem.
-/

/-
Soundness: bounded-search representability implies full representability.
-/
theorem boundedSumThreeCubes_sound {B : ℕ} {k : ℤ} :
    boundedSumThreeCubes B k → SumThreeCubes k := by
  exact fun ⟨ x, y, z, hx, hy, hz, hk ⟩ => ⟨ x, y, z, hk ⟩

/-
Monotonicity: increasing the search bound preserves representability.
-/
theorem boundedSumThreeCubes_mono {B₁ B₂ : ℕ} (hB : B₁ ≤ B₂) {k : ℤ} :
    boundedSumThreeCubes B₁ k → boundedSumThreeCubes B₂ k := by
  -- Assume there exist integers $x$, $y$, and $z$ such that $|x| \leq B₁$, $|y| \leq B₁$, $|z| \leq B₁$, and $x^3 + y^3 + z^3 = k$.
  intro h
  obtain ⟨x, y, z, hx, hy, hz, hk⟩ := h
  -- Since $B₁ \leq B₂$, it follows that $|x| \leq B₂$, $|y| \leq B₂$, and $|z| \leq B₂$.
  have hx' : |x| ≤ B₂ := by
    linarith
  have hy' : |y| ≤ B₂ := by
    exact le_trans hy ( mod_cast hB )
  have hz' : |z| ≤ B₂ := by
    grind +splitIndPred
  -- Therefore, $k$ is representable as a sum of three cubes with bound $B₂$.
  exact ⟨x, y, z, hx', hy', hz', hk⟩