import Mathlib

/-!
# The cost face: Fermat's scan is short exactly when the factors are balanced

Euler's factorisation method must first *find* two representations `N = a²+b² = c²+d²`; the
competing classical method (Fermat's difference-of-squares scan) walks `s = ⌈√N⌉, ⌈√N⌉+1, …`
until `s² - N` is a square.  This file proves the exact arithmetic of the Fermat scan, which
is what makes the empirical comparison ("Euler needs two representation searches and loses by
a constant factor, catastrophically so on balanced factorisations") a statement about a
quantity one can compute.

* `EulerTwoSquares.fermat_identity` — correctness: with `p + q = 2u` and `q = p + 2v` one has
  `u² = p*q + v²`, i.e. the scan does terminate, at `s = u = (p+q)/2`.
* `EulerTwoSquares.sqrt_eq_iff_of_add_sq` — the exact criterion for `⌊√N⌋`:
  if `N + t² = (w+1)²` and `t > 0` then `⌊√N⌋ = w ↔ t² < 2(w+1)`.
* `EulerTwoSquares.fermat_halts_immediately_iff` — consequence: Fermat's scan succeeds on its
  **first** trial iff `(q-p)² < 4(p+q)`, i.e. exactly on the balanced instances.
* `EulerTwoSquares.fermat_excess_le` — the real-analytic bound
  `(p+q)/2 - √(pq) ≤ (q-p)²/(8√(pq))`, so the whole scan has length
  `O((q-p)²/√N)`: quadratically small in the imbalance.
* `EulerTwoSquares.fermat_excess_ge` — the matching lower bound
  `(q-p)²/(8·max p q) ≤ (p+q)/2 - √(pq)`, so the estimate is sharp up to a constant.
-/

namespace EulerTwoSquares

/-! ## Correctness of the difference-of-squares step -/

/-- **Fermat's identity.**  If `p + q = 2u` and `q = p + 2v` (the mid-point / half-gap
coordinates of a factorisation `N = p*q`), then `u² = N + v²`: the scan terminates at `u`. -/
theorem fermat_identity {p q u v : ℕ} (hu : p + q = 2 * u) (hv : q = p + 2 * v) :
    u ^ 2 = p * q + v ^ 2 := by
  have hup : u = p + v := by omega
  subst hv
  subst hup
  ring

/-! ## The exact position of the start of the scan -/

/-- The exact criterion for the integer square root: if `N + t² = (w+1)²` with `t > 0`, then
`⌊√N⌋ = w` iff `t² < 2(w+1)`. -/
theorem sqrt_eq_iff_of_add_sq {N t w : ℕ} (h : N + t ^ 2 = (w + 1) ^ 2) (ht : 0 < t) :
    Nat.sqrt N = w ↔ t ^ 2 < 2 * (w + 1) := by
  have hlt : Nat.sqrt N < w + 1 := Nat.sqrt_lt'.2 (by nlinarith)
  constructor
  · intro hs
    have hle : w * w ≤ N := Nat.le_sqrt.1 (le_of_eq hs.symm)
    nlinarith
  · intro hbig
    have h1 : w ≤ Nat.sqrt N := Nat.le_sqrt.2 (by nlinarith)
    omega

/-- **Fermat's scan halts on its first trial exactly on balanced instances.**  For
`N = p*q` with `p + q = 2u`, `q = p + 2v` and `v > 0`, the first trial value `⌊√N⌋ + 1`
already equals the target `u = (p+q)/2` iff `v² < 2u`, i.e. iff `(q-p)² < 4(p+q)`. -/
theorem fermat_halts_immediately_iff {p q u v : ℕ} (hu : p + q = 2 * u) (hv : q = p + 2 * v)
    (hv0 : 0 < v) :
    Nat.sqrt (p * q) + 1 = u ↔ v ^ 2 < 2 * u := by
  obtain ⟨w, rfl⟩ : ∃ w, u = w + 1 := ⟨u - 1, by omega⟩
  have hid : p * q + v ^ 2 = (w + 1) ^ 2 := (fermat_identity hu hv).symm
  have := sqrt_eq_iff_of_add_sq hid hv0
  constructor
  · intro hs; exact this.1 (by omega)
  · intro hs; have := this.2 hs; omega

/-! ## The length of the scan, analytically -/

/-- **Upper bound for the Fermat excess.**  The scan length `(p+q)/2 - √(pq)` is at most
`(q-p)²/(8√(pq))`: quadratically small in the imbalance `q - p`. -/
theorem fermat_excess_le {p q : ℝ} (hp : 0 < p) (hq : 0 < q) :
    (p + q) / 2 - Real.sqrt (p * q) ≤ (q - p) ^ 2 / (8 * Real.sqrt (p * q)) := by
  set x := Real.sqrt p with hxdef
  set y := Real.sqrt q with hydef
  have hx : 0 < x := Real.sqrt_pos.2 hp
  have hy : 0 < y := Real.sqrt_pos.2 hq
  have hx2 : x ^ 2 = p := Real.sq_sqrt hp.le
  have hy2 : y ^ 2 = q := Real.sq_sqrt hq.le
  have hs : Real.sqrt (p * q) = x * y := by rw [hxdef, hydef, ← Real.sqrt_mul hp.le]
  rw [hs, le_div_iff₀ (by positivity), ← hx2, ← hy2]
  nlinarith [sq_nonneg ((x - y) ^ 2), sq_nonneg (x - y), mul_pos hx hy]

/-- **Lower bound for the Fermat excess.**  Conversely the scan is at least
`(q-p)²/(8·max p q)` long, so a large imbalance really does cost. -/
theorem fermat_excess_ge {p q : ℝ} (hp : 0 < p) (hq : 0 < q) :
    (q - p) ^ 2 / (8 * max p q) ≤ (p + q) / 2 - Real.sqrt (p * q) := by
  set x := Real.sqrt p with hxdef
  set y := Real.sqrt q with hydef
  have hx : 0 < x := Real.sqrt_pos.2 hp
  have hy : 0 < y := Real.sqrt_pos.2 hq
  have hx2 : x ^ 2 = p := Real.sq_sqrt hp.le
  have hy2 : y ^ 2 = q := Real.sq_sqrt hq.le
  have hs : Real.sqrt (p * q) = x * y := by rw [hxdef, hydef, ← Real.sqrt_mul hp.le]
  have hm : (0 : ℝ) < max p q := lt_max_of_lt_left hp
  rw [hs, div_le_iff₀ (by positivity)]
  have hmx : x ^ 2 ≤ max p q := by rw [hx2]; exact le_max_left _ _
  have hmy : y ^ 2 ≤ max p q := by rw [hy2]; exact le_max_right _ _
  have hxy : (x + y) ^ 2 ≤ 4 * max p q := by nlinarith [sq_nonneg (x - y)]
  have hkey : (q - p) ^ 2 = (y - x) ^ 2 * (x + y) ^ 2 := by
    rw [← hx2, ← hy2]; ring
  rw [hkey]
  nlinarith [sq_nonneg (x - y), mul_pos hx hy, sq_nonneg (x + y)]

end EulerTwoSquares