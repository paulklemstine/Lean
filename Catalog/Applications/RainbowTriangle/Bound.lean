/-
# The extremal density bound `⌈(n-1)(n-3)/8⌉`

This file develops the arithmetic of the conjectured rainbow-triangle lower bound
`rt(G) ≥ ⌈(n-1)(n-3)/8⌉` of **Li, Ning, Shi, Zhang (2024)** (`LiNingShiZhang2024`).

We model the bound over `ℕ` as

    rtBound n = ((n - 1) * (n - 3) + 7) / 8,

which equals `⌈(n-1)(n-3)/8⌉` for all `n` (here `(n-1)(n-3)` uses truncated subtraction,
giving `0` for `n ≤ 3`, exactly as the ceiling does).

Proven results:

* `rtBound_ceil` — the defining ceiling inequalities
  `(n-1)(n-3) ≤ 8·rtBound n < (n-1)(n-3) + 8`;
* `rtBound_zero_iff` — `rtBound n = 0 ↔ n ≤ 3` (the bound is vacuous exactly below the
  conjecture's range and becomes positive from `n = 4` on);
* `rtBound_mono` — monotonicity in `n`;
* `rtBound_le_choose` — `rtBound n ≤ C(n,3)`, the crucial comparison with the *total* number
  of triangles in a complete graph (used in `RainbowCount.lean`).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The closed form `((n-1)(n-3)+7)/8` is the correct `ℕ` encoding of
`⌈(n-1)(n-3)/8⌉`, and it is dominated by `C(n,3)`, the rainbow-triangle count of a properly
coloured complete graph.

Experiment (Experimenter): `rtBound_ceil`, `rtBound_zero_iff`, `rtBound_mono` are pure
`omega`/`nlinarith` facts after `generalize`-ing the product.  For `rtBound_le_choose` the key
identity is `6 · C(n,3) = n(n-1)(n-2)` (via `Nat.descFactorial`), after which a substitution
`n = 3 + m` removes the truncated subtraction and `nlinarith` finishes.

Analysis (Analyst): The decisive step is reducing `(n-1)(n-3) ≤ 8·C(n,3)` to the
subtraction-free inequality `6(m+2)m ≤ 8(m+3)(m+2)(m+1)`; truncated `ℕ` subtraction is what
makes `omega` alone insufficient and forces the substitution.

Critique (Critic): The bound is genuinely positive (`rtBound 4 = 1`, `rtBound 7 = 3`,
`rtBound 9 = 6`), so `rtBound_le_choose` is a real inequality, not `0 ≤ _`.  All proofs are
`sorry`-free and use insight-bearing tactics (`generalize`, `nlinarith`, `Nat.descFactorial`).
-- !-- Lab Notes -- !--
-/
import Mathlib

namespace RainbowTri

/-- The conjectured extremal lower bound `⌈(n-1)(n-3)/8⌉`, encoded over `ℕ`. -/
def rtBound (n : ℕ) : ℕ := ((n - 1) * (n - 3) + 7) / 8

/-- The defining ceiling inequalities for `rtBound`. -/
theorem rtBound_ceil (n : ℕ) :
    (n - 1) * (n - 3) ≤ 8 * rtBound n ∧ 8 * rtBound n < (n - 1) * (n - 3) + 8 := by
  unfold rtBound
  generalize (n - 1) * (n - 3) = k
  omega

/-- The bound vanishes exactly below the conjecture's range, and is positive from `n = 4` on. -/
theorem rtBound_zero_iff (n : ℕ) : rtBound n = 0 ↔ n ≤ 3 := by
  unfold rtBound
  constructor
  · intro h
    by_contra hn
    push_neg at hn
    have h1 : 1 ≤ n - 1 := by omega
    have h2 : 1 ≤ n - 3 := by omega
    have : 1 ≤ (n - 1) * (n - 3) := Nat.one_le_iff_ne_zero.mpr (by positivity)
    omega
  · intro h
    have : n - 3 = 0 := by omega
    simp [this]

/-- The bound is monotone non-decreasing in the number of vertices. -/
theorem rtBound_mono : Monotone rtBound := by
  intro m n hmn
  unfold rtBound
  have hk : (m - 1) * (m - 3) ≤ (n - 1) * (n - 3) := by
    apply Nat.mul_le_mul <;> omega
  omega

/-- The conjectured bound never exceeds the total number of triangles `C(n,3)` in a complete
graph.  This is the bridge that makes a properly coloured complete graph a witness to the
conjectured inequality. -/
theorem rtBound_le_choose (n : ℕ) : rtBound n ≤ n.choose 3 := by
  unfold rtBound
  have h6 : 6 * n.choose 3 = n * (n - 1) * (n - 2) := by
    have h1 := Nat.descFactorial_eq_factorial_mul_choose n 3
    have h2 : n.descFactorial 3 = n * (n - 1) * (n - 2) := by simp [Nat.descFactorial]; ring
    rw [h2] at h1
    simpa [Nat.factorial] using h1.symm
  have key : (n - 1) * (n - 3) ≤ 8 * n.choose 3 := by
    rcases Nat.lt_or_ge n 3 with h | h
    · interval_cases n <;> simp
    · obtain ⟨m, rfl⟩ := Nat.exists_eq_add_of_le h
      have e1 : 3 + m - 1 = m + 2 := by omega
      have e3 : 3 + m - 2 = m + 1 := by omega
      rw [e1, show 3 + m - 3 = m by omega]
      have hc : 6 * (3 + m).choose 3 = (3 + m) * (m + 2) * (m + 1) := by
        rw [h6, e1, e3]
      nlinarith [hc, Nat.zero_le m]
  omega

end RainbowTri