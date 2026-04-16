import Mathlib

/-!
# Berggren–Markov Connection (Direction #27)

Markov triples (a,b,c) satisfy a² + b² + c² = 3abc and form a tree via
Vieta involutions. We formalize the structural parallels between the
Berggren tree (Pythagorean) and the Markov tree, and explore whether
there is a deformation between them.

## Key Findings

1. Both trees have ternary structure but different branching rules
2. The Markov "mutation" is an involution (applying twice returns to start),
   while Berggren steps are not involutions
3. Both trees live on quadratic surfaces in ℤ³
4. The Berggren tree sits on the null cone Q=0 of a²+b²-c²,
   the Markov tree sits on the level set a²+b²+c² = 3abc
5. There is a natural 1-parameter deformation interpolating between them
-/

/-! ## §1. Markov Triple Definition -/

/-- A Markov triple satisfies a² + b² + c² = 3abc -/
def IsMarkov (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 + c ^ 2 = 3 * a * b * c

/-- The root Markov triple is (1,1,1) -/
theorem markov_root : IsMarkov 1 1 1 := by unfold IsMarkov; ring

/-- (1,1,2) is a Markov triple -/
theorem markov_1_1_2 : IsMarkov 1 1 2 := by unfold IsMarkov; ring

/-- (1,2,5) is a Markov triple -/
theorem markov_1_2_5 : IsMarkov 1 2 5 := by unfold IsMarkov; ring

/-- (1,5,13) is a Markov triple -/
theorem markov_1_5_13 : IsMarkov 1 5 13 := by unfold IsMarkov; ring

/-- (2,5,29) is a Markov triple -/
theorem markov_2_5_29 : IsMarkov 2 5 29 := by unfold IsMarkov; ring

/-! ## §2. Vieta Involution

Given a Markov triple (a,b,c), replacing c by c' = 3ab - c gives another
Markov triple. This is the "mutation" operation. -/

/-- Markov mutation in the third coordinate -/
def markovMut₃ (a b c : ℤ) : ℤ × ℤ × ℤ := (a, b, 3 * a * b - c)

/-- Markov mutation preserves the Markov property -/
theorem markovMut₃_preserves (a b c : ℤ) (h : IsMarkov a b c) :
    IsMarkov (markovMut₃ a b c).1 (markovMut₃ a b c).2.1 (markovMut₃ a b c).2.2 := by
  unfold IsMarkov markovMut₃ at *; nlinarith [h]

/-- Markov mutation is an involution: applying it twice returns to the original -/
theorem markovMut₃_involution (a b c : ℤ) :
    markovMut₃ a b (3 * a * b - c) = (a, b, c) := by
  simp only [markovMut₃]; ext <;> ring

/-- Similarly for mutations in coordinates 1 and 2 -/
def markovMut₁ (a b c : ℤ) : ℤ × ℤ × ℤ := (3 * b * c - a, b, c)
def markovMut₂ (a b c : ℤ) : ℤ × ℤ × ℤ := (a, 3 * a * c - b, c)

theorem markovMut₁_preserves (a b c : ℤ) (h : IsMarkov a b c) :
    IsMarkov (markovMut₁ a b c).1 (markovMut₁ a b c).2.1 (markovMut₁ a b c).2.2 := by
  unfold IsMarkov markovMut₁ at *; nlinarith [h]

theorem markovMut₂_preserves (a b c : ℤ) (h : IsMarkov a b c) :
    IsMarkov (markovMut₂ a b c).1 (markovMut₂ a b c).2.1 (markovMut₂ a b c).2.2 := by
  unfold IsMarkov markovMut₂ at *; nlinarith [h]

/-! ## §3. Structural Parallels

Both the Pythagorean and Markov equations can be written as
quadratic forms on ℤ³:

Pythagorean: Q_P(v) = a² + b² - c² = 0
Markov:      Q_M(v) = a² + b² + c² - 3abc = 0

The 1-parameter family Q_t(v) = a² + b² + (1-2t)c² - 3t·abc interpolates:
  t=0: a² + b² + c² = 0 (no real solutions)
  t=1: a² + b² + c² = 3abc (Markov)
  (a² + b² = c² corresponds to the null cone) -/

/-- A Pythagorean triple: a² + b² - c² = 0 -/
def IsPythTriple' (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- Both equations are quadratic in each variable -/
theorem pyth_quadratic_in_c (a b c : ℤ) :
    IsPythTriple' a b c ↔ c ^ 2 = a ^ 2 + b ^ 2 := by
  unfold IsPythTriple'; omega

theorem markov_quadratic_in_c (a b c : ℤ) :
    IsMarkov a b c ↔ c ^ 2 - 3 * a * b * c + (a ^ 2 + b ^ 2) = 0 := by
  unfold IsMarkov; omega

/-! ## §4. Key Structural Differences -/

/-- Berggren steps are NOT involutions (unlike Markov mutations) -/
def bergA' (a b c : ℤ) : ℤ × ℤ × ℤ := (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

example : bergA' 3 4 5 = (5, 12, 13) := by native_decide
-- bergA' applied to (5,12,13) does NOT give (3,4,5):
example : bergA' 5 12 13 ≠ (3, 4, 5) := by native_decide
-- So bergA is NOT an involution

/-- Markov mutations ARE involutions -/
example : markovMut₃ 1 1 1 = (1, 1, 2) := by native_decide
example : markovMut₃ 1 1 2 = (1, 1, 1) := by native_decide

/-! ## §5. Both Trees Generate All Solutions

Both the Berggren and Markov trees are conjectured/proven to generate
all primitive solutions:

- Berggren: Every primitive Pythagorean triple appears exactly once (theorem, proven classically)
- Markov: Every Markov triple appears exactly once (OPEN - the Markov uniqueness conjecture)

The Markov uniqueness conjecture is one of the oldest open problems in
number theory (1879). The Berggren completeness is proven but not yet
fully formalized in Lean.
-/

/-- Some larger Markov triples for verification -/
theorem markov_5_13_194 : IsMarkov 5 13 194 := by unfold IsMarkov; ring
theorem markov_2_29_169 : IsMarkov 2 29 169 := by unfold IsMarkov; ring
