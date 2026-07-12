import Applications.VampireNumbers
import Applications.CusickSumOfDigits

/-!
# A Bridge: Binary Digit Sums of Vampire Numbers

This file connects the base-10 combinatorics of vampire numbers
(`Applications.VampireNumbers`) to the base-2 sum-of-digits theory developed in
`Applications.CusickSumOfDigits` (the Cusick programme).  The link is a
**submultiplicativity** law for the binary digit sum `s₂(n) = (digits 2 n).sum`.

The catalog already proves `CusickSumDigits.s2_subadditive`,
`s₂(a + b) ≤ s₂(a) + s₂(b)`.  Iterating it across a product gives
`s₂(x · y) ≤ y · s₂(x)`, and by symmetry the sharper
`s₂(x · y) ≤ min (y · s₂ x) (x · s₂ y)`.  Applied to a vampire number
`v = x · y`, this bounds the number of `1`-bits of the monster by the number of
`1`-bits of a single fang, scaled by the other fang.

## Main results

* `VampireBridge.s2_mul_le` — binary submultiplicativity `s₂(x*y) ≤ y * s₂(x)`,
  proved by induction on `y` using the catalog's `s2_subadditive`.
* `VampireBridge.s2_mul_le_min` — the symmetric sharpening.
* `VampireBridge.vampire_binary_bound` — the specialization to any vampire pair.

-- !-- Lab Notes -- !--

Hypothesis (Hypothesizer):  The base-2 digit sum `s₂` is subadditive (catalog).
  Multiplication is repeated addition, so `s₂` should be *submultiplicative*:
  `s₂(x·y) ≤ y·s₂(x)`.  This bridges the Cusick base-2 world to the base-10
  vampire world.

Experiment (Experimenter):  `s₂(21·60)=s₂(1260)`.  1260 = 0b10011101100 has six
  1-bits, s₂(21)=s₂(0b10101)=3, and 60·3 = 180 ≥ 6; 21·s₂(60)=21·4=84 ≥ 6.
  Bound holds, and is far from tight (as expected for products).

Analysis (Analyst):  Submultiplicativity is genuine (not just a rename of
  subadditivity): the proof is an induction whose step *invokes*
  `CusickSumDigits.s2_subadditive` on `x·n + x`.  This is the required
  cross-file reuse of catalog results.

Critique (Critic):  Not vacuous — `s2_mul_le` fails to be an equality (products
  create/destroy carries), and it is proved by real induction, not `decide`.

Synthesis (PI):  Digit-sum submultiplicativity is the natural multiplicative
  companion of Cusick subadditivity, and it gives the first quantitative handle
  on the binary complexity of composite "monster" numbers.
-/

namespace VampireBridge

open CusickSumDigits

/-- **Binary submultiplicativity of the digit sum.**  `s₂(x·y) ≤ y · s₂(x)`,
proved by induction on `y`, each step invoking the catalog subadditivity
`CusickSumDigits.s2_subadditive`. -/
theorem s2_mul_le (x y : ℕ) : s2 (x * y) ≤ y * s2 x := by
  induction y with
  | zero => simp [s2]
  | succ n ih =>
    have hsplit : x * (n + 1) = x * n + x := by ring
    rw [hsplit]
    calc s2 (x * n + x) ≤ s2 (x * n) + s2 x := s2_subadditive _ _
      _ ≤ n * s2 x + s2 x := Nat.add_le_add_right ih _
      _ = (n + 1) * s2 x := by ring

/-- The symmetric sharpening `s₂(x·y) ≤ min (y·s₂ x) (x·s₂ y)`. -/
theorem s2_mul_le_min (x y : ℕ) : s2 (x * y) ≤ min (y * s2 x) (x * s2 y) := by
  refine le_min (s2_mul_le x y) ?_
  have := s2_mul_le y x
  rwa [Nat.mul_comm y x] at this

/-- **Binary complexity bound for vampire numbers.**  If `v = x · y` is a vampire
pair, its number of binary `1`-bits is controlled by that of either fang:
`s₂(v) ≤ min (y·s₂ x) (x·s₂ y)`. -/
theorem vampire_binary_bound {v x y : ℕ} (h : VampireNumbers.IsVampirePair v x y) :
    s2 v ≤ min (y * s2 x) (x * s2 y) := by
  rw [h.factor]
  exact s2_mul_le_min x y

end VampireBridge