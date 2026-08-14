import Algebra.BerggrenPriceInterlock.Orthogonality

/-!
# Berggren–Price interlock, Part VI: the ratio law and the Fermat trade-off

The empirical statement "the Berggren tree organises the *ratio* `(p+q)/(q-p)`, not the
product `pq`" is here made exact.

* `berg_ratio_bound` — after `d` Berggren steps the node `(m,n)` satisfies
  `m ≤ (2d+3)·n`.  Equivalently the Berggren depth is at least `(m/n - 3)/2`, and `m/n`
  is exactly Fermat's ease coordinate `(p+q)/(q-p)`.
* `fermat_step_lower` — Fermat's scan length `s = m - r` obeys `2·m·s ≥ n²`.
* `berg_depth_fermat_tradeoff` — combining: `2·s·(2d+3)² ≥ m`.  A cheap Fermat scan
  (small `s`) *forces* a deep Berggren address (`d ≳ √(m/s)/2`), whose level already
  contains `3^d` nodes.  This is structural orthogonality in one inequality: the two
  cost measures are inversely coupled, so the tree can never be a shortcut.
* `price_depth_lower` — by contrast the Price depth obeys the size law `2^(d+1) ≥ m`
  with no dependence on `s` at all.
-/

namespace BerggrenPrice

/-- **Ratio law.**  A Berggren step either resets the ratio `m/n` below `3` (children
`bA`, `bB`, which set `n' = m`) or increases it by exactly `2` (child `bC`).  Hence after
`d` steps `m ≤ (2d+3)·n`. -/
theorem berg_ratio_bound (w : List (Fin 3)) :
    (applyWord berg w root).1 ≤ (2 * (w.length : ℤ) + 3) * (applyWord berg w root).2 := by
  induction w with
  | nil => norm_num [root]
  | cons i w ih =>
    have hnode := isNode_applyWord_berg w
    obtain ⟨h1, h2, -, -⟩ := hnode
    have hlen : ((i :: w).length : ℤ) = (w.length : ℤ) + 1 := by
      rw [List.length_cons]; push_cast; ring
    rw [hlen]
    set m := (applyWord berg w root).1
    set n := (applyWord berg w root).2
    have hm : 0 < m := by omega
    fin_cases i <;> (simp only [applyWord_cons, berg, bA, bB, bC]; nlinarith)

/-- Fermat's scan length `s = m - r` for `N = m² - n²` obeys `2·m·s ≥ n²`: the scan is
short exactly when `n` is small compared with `m`. -/
theorem fermat_step_lower {m n r : ℤ} (hm : 0 < m) (hr : 0 ≤ r)
    (hrN : r ^ 2 ≤ m ^ 2 - n ^ 2) : n ^ 2 ≤ 2 * m * (m - r) := by
  have hrm : r ≤ m := by nlinarith
  nlinarith

/-- **The trade-off.**  For a node at Berggren depth `d` whose odd leg `N = m² - n²` has
`r` with `r² ≤ N` (Fermat's starting point) and scan length `s = m - r`:
`2·s·(2d+3)² ≥ m`.  Cheap Fermat scans force deep Berggren addresses. -/
theorem berg_depth_fermat_tradeoff (w : List (Fin 3)) {r : ℤ} (hr : 0 ≤ r)
    (hrN : r ^ 2 ≤ oddLeg (applyWord berg w root)) :
    (applyWord berg w root).1 ≤
      2 * ((applyWord berg w root).1 - r) * (2 * (w.length : ℤ) + 3) ^ 2 := by
  have hnode := isNode_applyWord_berg w
  obtain ⟨h1, h2, -, -⟩ := hnode
  set m := (applyWord berg w root).1
  set n := (applyWord berg w root).2
  set d : ℤ := (w.length : ℤ)
  have hd : 0 ≤ d := Int.natCast_nonneg _
  have hm : 0 < m := by omega
  have hratio : m ≤ (2 * d + 3) * n := berg_ratio_bound w
  have hfermat : n ^ 2 ≤ 2 * m * (m - r) := by
    refine fermat_step_lower hm hr ?_
    simpa [oddLeg] using hrN
  have hsq : m ^ 2 ≤ (2 * d + 3) ^ 2 * n ^ 2 := by nlinarith
  have hkey : m ^ 2 ≤ (2 * d + 3) ^ 2 * (2 * m * (m - r)) := by nlinarith
  nlinarith

/-- The Price depth is size-driven and blind to Fermat's cost: `m ≤ 2^(d+1)`. -/
theorem price_depth_lower (w : List (Fin 3)) :
    (applyWord price w root).1 ≤ 2 ^ (w.length + 1) := price_fst_le w

end BerggrenPrice