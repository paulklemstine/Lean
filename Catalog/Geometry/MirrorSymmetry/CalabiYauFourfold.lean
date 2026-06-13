/-
  Calabi–Yau fourfold Hodge diamonds and the mirror involution.

  This file EXTENDS the combinatorial mirror-symmetry skeleton of
  `Geometry.MirrorSymmetry.ArithmeticMirror` (the `eulerChar` / `mirror`
  machinery and the threefold relation `χ(mirror Y) = -χ(X)`) from threefolds
  to **fourfolds** (complex dimension `n = 4`), realizing research direction #5
  ("Higher-Dimensional Hodge Diamond Classification") of the arithmetic
  mirror-symmetry program.

  A smooth Calabi–Yau fourfold `X` has a Hodge diamond fully determined, after
  the symmetries

    * Hodge symmetry        `h^{p,q} = h^{q,p}`,
    * Serre duality         `h^{p,q} = h^{n-p,n-q}`,
    * Calabi–Yau vanishing  `h^{p,0} = 0` for `0 < p < n`, `h^{0,0} = h^{n,0} = 1`,

  by the **four** independent Hodge numbers `h^{1,1}, h^{2,1}, h^{3,1}, h^{2,2}`.
  We package these into `CY4`, build the full `ℕ → ℕ → ℤ` diamond, and prove:

    * `CY4.eulerChar_eq` — the topological Euler characteristic of the diamond is
      the explicit linear form `χ = 4 + 2 h¹¹ + 2 h³¹ + h²² − 4 h²¹`
      (this is unconditional combinatorics, *not* the Chern relation);
    * `CY4.mirror_diamond_eq` — the catalog mirror reflection `p ↦ n − p`
      (`ArithmeticMirror.mirror 4`) agrees on the support `p, q ≤ 4` with the
      diamond of the `CY4` whose `h¹¹` and `h³¹` are *swapped*: mirror symmetry
      exchanges `h^{1,1} ↔ h^{3,1}` while fixing `h^{2,1}` and `h^{2,2}`;
    * `CY4.swap_involutive` — that exchange is an involution (a `ℤ/2`-action);
    * `CY4.eulerChar_swap_invariant` / `CY4.eulerChar_mirror_invariant` — for the
      *even* dimension `4`, `χ(mirror X) = χ(X)` (contrast the threefold sign flip
      `ArithmeticMirror.eulerChar_mirror_threefold`), recovered as the `(-1)^4 = 1`
      shadow of the catalog theorem `ArithmeticMirror.eulerChar_mirror`;
    * `CY4.eulerChar_KLRY` — under the Klemm–Lian–Roan–Yau Chern-class relation
      `h²² = 2(22 + 2h¹¹ + 2h³¹ − h²¹)` the Euler characteristic collapses to the
      celebrated F-theory formula `χ = 6(8 + h¹¹ + h³¹ − h²¹)`.

  Everything is exact integer combinatorics over the catalog `eulerChar`.
-/
import Mathlib
import Geometry.MirrorSymmetry.ArithmeticMirror

open Finset

namespace CY4Fold

-- !-- Lab Notebook -- !--
-- Hypothesis: the n=4 Calabi–Yau Hodge diamond, after Hodge symmetry + Serre
-- duality + CY vanishing, has exactly 4 free numbers (h11,h21,h31,h22), its
-- Euler characteristic is a fixed linear form in them, and the catalog mirror
-- reflection p ↦ 4−p realizes the F-theory exchange h11 ↔ h31.
-- Result: all six facts proved (`eulerChar_eq`, `mirror_diamond_eq`,
-- `swap_involutive`, `eulerChar_swap_invariant`, `eulerChar_mirror_invariant`,
-- `eulerChar_KLRY`).
-- Insight: the *parity of the dimension* is the whole story — n=4 is even so the
-- catalog sign (-1)^n is +1, flipping the threefold χ ↦ −χ into χ ↦ χ; and the
-- KLRY Chern relation is precisely the affine substitution turning the bare
-- combinatorial form 4+2h11+2h31+h22−4h21 into 6(8+h11+h31−h21).
-- Failure analysis: defining the diamond by a `match` means the reflection
-- `mirror 4` only matches the swapped diamond on the support p,q ≤ 4 (outside,
-- ℕ-truncation of 4−p makes them disagree), so the exchange is stated pointwise
-- on the support, exactly as in the catalog `mirror_mirror_h`.

/-- The four independent Hodge numbers of a Calabi–Yau fourfold:
`h^{1,1}` (Kähler moduli), `h^{2,1}`, `h^{3,1}` (complex-structure moduli) and the
middle number `h^{2,2}`. -/
structure CY4 where
  /-- `h^{1,1}`: the Kähler / divisor moduli. -/
  h11 : ℤ
  /-- `h^{2,1}`. -/
  h21 : ℤ
  /-- `h^{3,1}`: the complex-structure moduli. -/
  h31 : ℤ
  /-- `h^{2,2}`: the middle Hodge number. -/
  h22 : ℤ

/-- The full Hodge diamond `h^{p,q}` of a Calabi–Yau fourfold, as a function on
`ℕ × ℕ`, built from the four free numbers via Hodge symmetry, Serre duality and
the Calabi–Yau vanishing conditions. Only the values with `p, q ≤ 4` are
meaningful; the rest are padding `0`. -/
def CY4.diamond (X : CY4) : ℕ → ℕ → ℤ := fun p q =>
  match p, q with
  | 0, 0 => 1
  | 4, 4 => 1
  | 0, 4 => 1
  | 4, 0 => 1
  | 1, 1 => X.h11
  | 3, 3 => X.h11
  | 3, 1 => X.h31
  | 1, 3 => X.h31
  | 2, 2 => X.h22
  | 2, 1 => X.h21
  | 1, 2 => X.h21
  | 2, 3 => X.h21
  | 3, 2 => X.h21
  | _, _ => 0

/-- The **mirror exchange** on free Hodge data: swap `h^{1,1} ↔ h^{3,1}`, fixing
`h^{2,1}` and `h^{2,2}`. This is the F-theory mirror map at the level of the four
moduli numbers. -/
def CY4.swap (X : CY4) : CY4 where
  h11 := X.h31
  h21 := X.h21
  h31 := X.h11
  h22 := X.h22

-- !-- comment -- !--
-- Expand the 5×5 alternating double sum (`Finset.sum_range_succ`), reduce each
-- literal `diamond p q` by the `match`, and collect terms with `ring`.
-- !-- comment -- !--
/-- **Euler characteristic of a CY fourfold diamond.** The topological Euler
characteristic (the catalog `ArithmeticMirror.eulerChar` at `n = 4`) is the
explicit linear form `χ = 4 + 2 h¹¹ + 2 h³¹ + h²² − 4 h²¹`. This is pure
combinatorics of the diamond — no Chern-class input. -/
theorem CY4.eulerChar_eq (X : CY4) :
    ArithmeticMirror.eulerChar 4 X.diamond
      = 4 + 2 * X.h11 + 2 * X.h31 + X.h22 - 4 * X.h21 := by
  unfold ArithmeticMirror.eulerChar CY4.diamond
  norm_num [Finset.sum_range_succ]
  ring

-- !-- comment -- !--
-- Both sides are 0 off the support and, for each of the ≤25 index pairs with
-- p,q ≤ 4, `mirror 4 X.diamond p q = X.diamond (4-p) q` reduces by the `match`
-- to the corresponding entry of the swapped diamond.
-- !-- comment -- !--
/-- **Mirror exchanges `h^{1,1}` and `h^{3,1}`.** On the support `p, q ≤ 4` the
catalog mirror reflection `ArithmeticMirror.mirror 4` of the diamond coincides
with the diamond of the swapped data `X.swap`. This is the F-theory mirror map
`h^{1,1} ↔ h^{3,1}` (with `h^{2,1}, h^{2,2}` fixed). -/
theorem CY4.mirror_diamond_eq (X : CY4) {p q : ℕ} (hp : p ≤ 4) (hq : q ≤ 4) :
    ArithmeticMirror.mirror 4 X.diamond p q = X.swap.diamond p q := by
  interval_cases p <;> interval_cases q <;> rfl

-- !-- comment -- !--
-- Swapping h11 and h31 twice returns the original; the other two fields are
-- untouched: `cases X` then `rfl`.
-- !-- comment -- !--
/-- **The mirror exchange is an involution** (a `ℤ/2`-action on CY-fourfold
Hodge data). -/
theorem CY4.swap_involutive (X : CY4) : X.swap.swap = X := by
  cases X; rfl

-- !-- comment -- !--
-- `eulerChar_eq` is symmetric in h11 and h31, and `swap` exchanges exactly those
-- two, so the Euler characteristic is unchanged.
-- !-- comment -- !--
/-- **Euler characteristic is mirror-invariant for fourfolds.** Because `4` is
even, the catalog sign `(-1)^4 = 1`, so unlike the threefold case
(`ArithmeticMirror.eulerChar_mirror_threefold`, `χ ↦ -χ`) the mirror preserves
the Euler characteristic. Equivalently, `eulerChar_eq` is symmetric under the
`h^{1,1} ↔ h^{3,1}` swap. -/
theorem CY4.eulerChar_swap_invariant (X : CY4) :
    ArithmeticMirror.eulerChar 4 X.swap.diamond
      = ArithmeticMirror.eulerChar 4 X.diamond := by
  rw [CY4.eulerChar_eq, CY4.eulerChar_eq]
  simp only [CY4.swap]
  ring

-- !-- comment -- !--
-- Direct corollary of the catalog `eulerChar_mirror` at n = 4: the prefactor is
-- (-1)^4 = 1.
-- !-- comment -- !--
/-- **Catalog form of fourfold mirror invariance.** Specializing
`ArithmeticMirror.eulerChar_mirror` to `n = 4`: reflecting the first Hodge index
fixes the Euler characteristic, since `(-1)^4 = 1`. -/
theorem CY4.eulerChar_mirror_invariant (h : ℕ → ℕ → ℤ) :
    ArithmeticMirror.eulerChar 4 (ArithmeticMirror.mirror 4 h)
      = ArithmeticMirror.eulerChar 4 h := by
  rw [ArithmeticMirror.eulerChar_mirror]
  norm_num

-- !-- comment -- !--
-- Substitute the KLRY value of h22 into `eulerChar_eq` and simplify with `ring`.
-- !-- comment -- !--
/-- **Klemm–Lian–Roan–Yau / F-theory Euler formula.** Under the Chern-class
relation `h²² = 2(22 + 2h¹¹ + 2h³¹ − h²¹)` (the geometric constraint coming from
`c₄(X) = χ` on a CY fourfold), the combinatorial Euler characteristic collapses
to the celebrated F-theory formula `χ = 6(8 + h¹¹ + h³¹ − h²¹)`. -/
theorem CY4.eulerChar_KLRY (X : CY4)
    (hChern : X.h22 = 2 * (22 + 2 * X.h11 + 2 * X.h31 - X.h21)) :
    ArithmeticMirror.eulerChar 4 X.diamond
      = 6 * (8 + X.h11 + X.h31 - X.h21) := by
  rw [CY4.eulerChar_eq, hChern]
  ring

end CY4Fold