import Algebra.BerggrenPriceInterlock.Trees

/-!
# Berggren–Price interlock, Part VII: what a tree generator can look like

Why is determinant `±2` allowed at all?  Two structural facts explain the interlock:

* `dvd_det_of_dvd_image` — a common divisor of the image of a coprime pair divides the
  determinant.  So a generator of determinant `±1` preserves coprimality for free, while
  a generator of determinant `±2` preserves it only because the parity condition forces
  the gcd to be odd.  This is exactly the gap Price's tree lives in.
* `node_map_parity` — any integer linear map sending nodes to nodes has *odd column
  sums* `a + c` and `b + d`.  Both generator triples satisfy this, and it is what rules
  out the naive "halving" maps such as `(m,n) ↦ (2m−n, n)`.

Together these are the two constraints that any classification of ternary Pythagorean
trees must start from (see `FUTURE_DIRECTIONS.md`, conjecture C4).
-/

namespace BerggrenPrice

/-- A common divisor of the image of a coprime pair under an integer matrix divides the
determinant of that matrix. -/
theorem dvd_det_of_dvd_image {a b c d x y k : ℤ} (hxy : IsCoprime x y)
    (h1 : k ∣ a * x + b * y) (h2 : k ∣ c * x + d * y) : k ∣ a * d - b * c := by
  obtain ⟨u, v, huv⟩ := hxy
  have hx : k ∣ (a * d - b * c) * x := by
    have : (a * d - b * c) * x = d * (a * x + b * y) - b * (c * x + d * y) := by ring
    rw [this]
    exact dvd_sub (h1.mul_left d) (h2.mul_left b)
  have hy : k ∣ (a * d - b * c) * y := by
    have : (a * d - b * c) * y = a * (c * x + d * y) - c * (a * x + b * y) := by ring
    rw [this]
    exact dvd_sub (h2.mul_left a) (h1.mul_left c)
  have : (a * d - b * c) = u * ((a * d - b * c) * x) + v * ((a * d - b * c) * y) := by
    linear_combination (a * d - b * c) * huv.symm
  rw [this]
  exact dvd_add (hx.mul_left u) (hy.mul_left v)

/-- Any integer linear map that sends nodes to nodes has odd column sums: `a + c` and
`b + d` are odd.  (Tested on the root `(2,1)` and on `(3,2)`.) -/
theorem node_map_parity {a b c d : ℤ}
    (h : ∀ v : Node, IsNode v → IsNode (a * v.1 + b * v.2, c * v.1 + d * v.2)) :
    Odd (a + c) ∧ Odd (b + d) := by
  have h32 : IsNode ((3 : ℤ), (2 : ℤ)) := by
    refine ⟨by norm_num, by norm_num, ⟨1, -1, by norm_num⟩, ⟨2, by norm_num⟩⟩
  have e1 : (a * 2 + b * 1 + (c * 2 + d * 1)) % 2 = 1 := by
    have hx := (h root isNode_root).2.2.2
    rwa [Int.odd_iff] at hx
  have e2 : (a * 3 + b * 2 + (c * 3 + d * 2)) % 2 = 1 := by
    have hx := (h ((3 : ℤ), (2 : ℤ)) h32).2.2.2
    rwa [Int.odd_iff] at hx
  exact ⟨Int.odd_iff.mpr (by omega), Int.odd_iff.mpr (by omega)⟩

end BerggrenPrice