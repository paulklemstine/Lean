import Mathlib

/-!
# Tropical Differential Equations: Power Series Solutions

This file develops the **valuation (order) tropicalization** of the ring of formal power
series `R⟦X⟧` and uses it to study *tropical differential constraints*: lower bounds on the
order (= valuation) of solutions of differential equations.

The tropicalization map sends a power series to the `trop` of its `order`, landing in the
**min-plus tropical semiring** `Tropical (WithTop ℕ)`.  Under this map:

* multiplication of series becomes tropical multiplication (= ordinary `+` of valuations),
* addition of series becomes a *lower bound* by tropical addition (= `min` of valuations),
* formal differentiation `d⁄dX` lowers the valuation by *at most* one — a tropical bound
  that propagates to iterated derivatives, hence to every differential monomial.

The headline application (`linODE_order_zero`) is a **tropical valuation-pinning theorem**:
over a characteristic-zero field, any nonzero solution of the linear differential equation
`f' = c·f` (`c ≠ 0`) must have order `0`.  The tropical equation
`min(ord f', ord (c·f))` cannot be balanced unless the valuation collapses to the bottom.

## Main results

* `tropOrder_mul`        — tropicalization is multiplicative: `T(f·g) = T f · T g`.
* `tropOrder_add_le`     — tropicalization is super-additive: `T f + T g ≤ T(f+g)`.
* `order_deriv_succ_le`  — derivative bound: `ord f ≤ ord f' + 1` (any commutative ring).
* `order_iterate_deriv_le` — iterated bound: `ord f ≤ ord (f⁽ᵏ⁾) + k`.
* `order_deriv_eq_of_pos`  — exact drop in char 0: `0 < ord f → ord f' + 1 = ord f`.
* `linODE_order_zero`      — valuation pinning for `f' = c·f`.

## Catalog synthesis

This extends the project's tropical line (e.g. `Tropical.DiffConstraints`, which proves
difference-constraint polyhedra are tropically convex, and `Tropical.Convexity`) by adding
the **differential** dimension: instead of static linear inequalities on coordinates, we
tropicalize the *derivation* on `R⟦X⟧`.  Where `DiffConstraints` tropicalizes a polyhedron,
here we tropicalize an analytic operator, connecting the min-plus semiring `Tropical`
(from `Mathlib.Algebra.Tropical.Basic`) with `PowerSeries.order` and `PowerSeries.derivative`.

## References

* Aroca, Garay, Toghani, *The fundamental theorem of tropical differential algebraic
  geometry*, Pacific J. Math. (2016).
* Maclagan, Sturmfels, *Introduction to Tropical Geometry*.
-/

open PowerSeries Tropical

namespace TropicalDiff

noncomputable section

variable {R : Type*}

/-- **Tropicalization by valuation.**  Send a power series to the `trop` of its `order`,
landing in the min-plus tropical semiring `Tropical (WithTop ℕ)`. -/
def tropOrder [Semiring R] (f : R⟦X⟧) : Tropical (WithTop ℕ) := trop (order f)

@[simp] theorem tropOrder_def [Semiring R] (f : R⟦X⟧) :
    tropOrder f = trop (order f) := rfl

-- !-- Lab Notebook: tropOrder_mul -- !--
-- !-- Hypothesis: valuation tropicalization turns the product of series into the tropical
--     product (ordinary addition of orders), so it should be a multiplicative homomorphism. -- !--
-- !-- Result: Proved directly from `PowerSeries.order_mul` and `Tropical.trop_add`. -- !--
-- !-- Insight: over a domain `order` is an additive valuation; `trop_add` is exactly the
--     statement that ordinary `+` becomes tropical `*`, so the hom property is automatic. -- !--
-- !-- Failure analysis: none; the only subtlety was choosing the *min*-tropical convention. -- !--
-- !-- End Lab Notebook -- !--

-- !-- tropOrder_mul: order_mul makes order additive on a domain; trop_add turns that
--     additive law into tropical multiplication. -- !--
/-- **Tropicalization is multiplicative.**  `T(f·g) = T f · T g`, the tropical product law. -/
theorem tropOrder_mul [Semiring R] [NoZeroDivisors R] (f g : R⟦X⟧) :
    tropOrder (f * g) = tropOrder f * tropOrder g := by
  unfold tropOrder; rw [order_mul, trop_add]

-- !-- Lab Notebook: tropOrder_add_le -- !--
-- !-- Hypothesis: since orders can only increase under cancellation, the valuation of a sum
--     is bounded below by the min of valuations, i.e. tropical addition is a *lower* bound. -- !--
-- !-- Result: Proved from `min_order_le_order_add` and monotonicity of `trop`. -- !--
-- !-- Insight: in `Tropical`, `T f + T g = trop (min (ord f) (ord g))`; the inequality is
--     therefore the tropicalized form of `min (ord f) (ord g) ≤ ord (f+g)`. -- !--
-- !-- Failure analysis: had to rewrite tropical `+` as `trop ∘ min` via `← trop_min`. -- !--
-- !-- End Lab Notebook -- !--

-- !-- tropOrder_add_le: rewrite tropical `+` as `trop (min ..)`, then push the order
--     inequality `min (ord f) (ord g) ≤ ord (f+g)` through monotone `trop`. -- !--
/-- **Tropicalization is super-additive.**  `T f + T g ≤ T(f+g)`, the tropical sum law
(tropical addition is `min`, and it only lower-bounds the valuation of the sum). -/
theorem tropOrder_add_le [Semiring R] (f g : R⟦X⟧) :
    tropOrder f + tropOrder g ≤ tropOrder (f + g) := by
  unfold tropOrder
  rw [← trop_min]
  exact trop_monotone (min_order_le_order_add f g)

-- !-- Lab Notebook: order_deriv_succ_le -- !--
-- !-- Hypothesis: formal differentiation lowers the order by at most one, because the
--     coefficient of `X^i` in `f'` is `(i+1)·a_{i+1}`, which vanishes whenever `a_{i+1}` does. -- !--
-- !-- Result: Proved (any commutative ring) by bounding `ord f' ≥ ord f - 1` via `nat_le_order`. -- !--
-- !-- Insight: this is the tropicalization of the derivation `d⁄dX`: on valuations it acts as
--     `v ↦ v - 1` from below, regardless of characteristic — the universal tropical bound. -- !--
-- !-- Failure analysis: ℕ∞ subtraction is awkward, so we phrase the result additively as
--     `ord f ≤ ord f' + 1` and handle `f = 0` separately (`order 0 = ⊤`). -- !--
-- !-- End Lab Notebook -- !--

-- !-- order_deriv_succ_le: if `f = 0` both sides are `⊤`; else with `n = (ord f).toNat`,
--     every coefficient of `f'` below index `n-1` vanishes (`coeff_of_lt_order`), giving
--     `ord f' ≥ n-1`, hence `ord f = n ≤ (n-1)+1 ≤ ord f' + 1`. -- !--
/-- **Tropical derivative bound.**  Formal differentiation lowers the order by at most one:
`ord f ≤ ord f' + 1`.  Equivalently `ord f' ≥ ord f - 1`; this is the tropical action of the
derivation `d⁄dX` on valuations and holds over an arbitrary commutative ring. -/
theorem order_deriv_succ_le [CommRing R] (f : R⟦X⟧) :
    order f ≤ order (d⁄dX R f) + 1 := by
  rcases eq_or_ne f 0 with hf | hf
  · simp [hf]
  · have hfin : order f = ((order f).toNat : ℕ∞) := by
      rw [ENat.coe_toNat]; exact (order_finite_iff_ne_zero.mpr hf).ne
    set n := (order f).toNat with hn
    have hlow : ((n - 1 : ℕ) : ℕ∞) ≤ order (d⁄dX R f) := by
      apply nat_le_order
      intro i hi
      rw [coeff_derivative]
      have : ((i + 1 : ℕ) : ℕ∞) < order f := by
        rw [hfin]; exact_mod_cast by omega
      rw [coeff_of_lt_order _ this]; ring
    calc order f = (n : ℕ∞) := hfin
      _ ≤ ((n - 1 : ℕ) : ℕ∞) + 1 := by exact_mod_cast by omega
      _ ≤ order (d⁄dX R f) + 1 := by gcongr

-- !-- Lab Notebook: order_iterate_deriv_le -- !--
-- !-- Hypothesis: iterating the one-step bound, the k-th derivative lowers the order by at
--     most k, so `ord f ≤ ord (f⁽ᵏ⁾) + k` — a tropical lower bound on every differential
--     monomial of order k. -- !--
-- !-- Result: Proved by induction on k from `order_deriv_succ_le`. -- !--
-- !-- Insight: this is the differential-monomial form of the fundamental-theorem inequality:
--     the tropicalization of a degree-k differential operator subtracts at most k from the
--     valuation, lower-bounding the growth of any classical solution. -- !--
-- !-- Failure analysis: `Function.iterate_succ'` (composition on the *outside*) was the right
--     unfolding so the inductive hypothesis applies to the inner k-fold derivative. -- !--
-- !-- End Lab Notebook -- !--

-- !-- order_iterate_deriv_le: induct on k; base case is trivial, the step composes the
--     inductive bound with the one-step bound `order_deriv_succ_le` applied to `f⁽ᵏ⁾`. -- !--
/-- **Iterated tropical derivative bound.**  The `k`-th formal derivative lowers the order by
at most `k`: `ord f ≤ ord (f⁽ᵏ⁾) + k`.  This bounds the valuation contribution of any
order-`k` differential monomial, the tropical mechanism by which tropical solutions provide
lower bounds on the growth of classical power-series solutions. -/
theorem order_iterate_deriv_le [CommRing R] (f : R⟦X⟧) (k : ℕ) :
    order f ≤ order ((d⁄dX R)^[k] f) + k := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [Function.iterate_succ', Function.comp_apply]
    calc order f ≤ order ((d⁄dX R)^[k] f) + k := ih
      _ ≤ (order (d⁄dX R ((d⁄dX R)^[k] f)) + 1) + k := by
            gcongr; exact order_deriv_succ_le ((d⁄dX R)^[k] f)
      _ = order (d⁄dX R ((d⁄dX R)^[k] f)) + (↑(k + 1)) := by push_cast; ring

-- !-- Lab Notebook: order_smul_eq -- !--
-- !-- Hypothesis: over a field, scaling by a nonzero constant is multiplication by a unit
--     and therefore preserves the order. -- !--
-- !-- Result: Proved via `smul_eq_C_mul`, `order_mul`, and `order (C c) = 0`. -- !--
-- !-- Insight: tropically, `C c` for `c ≠ 0` is the tropical unit (`trop 0`), so it acts as
--     the identity on valuations. -- !--
-- !-- Failure analysis: `order (C c) = 0` needed the `order_eq_nat` characterization with the
--     explicit cast `(0 : ℕ∞) = ((0 : ℕ) : ℕ∞)`. -- !--
-- !-- End Lab Notebook -- !--

-- !-- order_smul_eq: write `c • f = C c * f`, use additivity of order and `order (C c) = 0`. -- !--
/-- Scaling a power series over a field by a nonzero constant preserves its order. -/
theorem order_smul_eq [Field R] (c : R) (hc : c ≠ 0) (f : R⟦X⟧) :
    order (c • f) = order f := by
  have h1 : c • f = (C c) * f := by rw [smul_eq_C_mul]
  rw [h1, order_mul]
  have h2 : order (C (R := R) c) = 0 := by
    rw [show (0 : ℕ∞) = ((0 : ℕ) : ℕ∞) from rfl, order_eq_nat]; simp [hc]
  rw [h2, zero_add]

-- !-- Lab Notebook: order_deriv_eq_of_pos -- !--
-- !-- Hypothesis: over a characteristic-zero field the integer factor `(i+1)` never vanishes,
--     so for a series of positive order the derivative bound is *tight*: `ord f' = ord f - 1`. -- !--
-- !-- Result: Proved by sandwiching `ord f'` between `n-1` (upper bound, leading coefficient
--     survives differentiation) and `n-1` (lower bound, as in `order_deriv_succ_le`). -- !--
-- !-- Insight: characteristic zero is exactly what upgrades the universal *inequality* to an
--     *equality*, the boundary where the tropical derivative is exact rather than lax. -- !--
-- !-- Failure analysis: needed `Nat.cast_ne_zero` to see `(n : R) ≠ 0`; this is precisely the
--     place where positive characteristic would break the proof. -- !--
-- !-- End Lab Notebook -- !--

-- !-- order_deriv_eq_of_pos: with `n = (ord f).toNat ≥ 1`, the coefficient of `X^{n-1}` in
--     `f'` is `n · a_n ≠ 0` (char 0), giving `ord f' ≤ n-1`; combined with `ord f' ≥ n-1`
--     this forces `ord f' = n-1`, i.e. `ord f' + 1 = ord f`. -- !--
/-- **Exact tropical derivative in characteristic zero.**  Over a characteristic-zero field,
differentiating a nonzero series of *positive* order drops the order by exactly one:
`0 < ord f → ord f' + 1 = ord f`. -/
theorem order_deriv_eq_of_pos [Field R] [CharZero R] (f : R⟦X⟧) (hf : f ≠ 0)
    (hpos : 0 < order f) : order (d⁄dX R f) + 1 = order f := by
  have hfin : order f = ((order f).toNat : ℕ∞) := by
    rw [ENat.coe_toNat]; exact (order_finite_iff_ne_zero.mpr hf).ne
  set n := (order f).toNat with hn
  have hn1 : 1 ≤ n := by rw [hfin] at hpos; exact_mod_cast hpos
  have hcoeff : coeff n f ≠ 0 := by
    have := coeff_order (φ := f) hf
    simpa [hn] using this
  have hup : order (d⁄dX R f) ≤ ((n - 1 : ℕ) : ℕ∞) := by
    apply order_le
    rw [coeff_derivative]
    have he : (n - 1 + 1) = n := by omega
    rw [he]
    have hncast : ((n - 1 : ℕ) : R) + 1 = (n : R) := by
      have : ((n - 1 : ℕ) : R) + 1 = ((n - 1 + 1 : ℕ) : R) := by push_cast; ring
      rw [this, he]
    rw [hncast]
    exact mul_ne_zero hcoeff (by exact_mod_cast Nat.cast_ne_zero.mpr (show n ≠ 0 by omega))
  have hlow : ((n - 1 : ℕ) : ℕ∞) ≤ order (d⁄dX R f) := by
    apply nat_le_order
    intro i hi
    rw [coeff_derivative]
    have : ((i + 1 : ℕ) : ℕ∞) < order f := by
      rw [hfin]; exact_mod_cast by omega
    rw [coeff_of_lt_order _ this]; ring
  have heq : order (d⁄dX R f) = ((n - 1 : ℕ) : ℕ∞) := le_antisymm hup hlow
  rw [heq, hfin]
  exact_mod_cast (show n - 1 + 1 = n by omega)

-- !-- Lab Notebook: linODE_order_zero -- !--
-- !-- Hypothesis: the linear ODE `f' = c·f` (c ≠ 0) tropicalizes to `ord f' = ord f`, which is
--     incompatible with the exact drop `ord f' = ord f - 1` unless `ord f = 0`. -- !--
-- !-- Result: Proved over a characteristic-zero field; assuming `ord f > 0` yields the
--     contradiction `m + 1 = m` for the finite valuation `m`. -- !--
-- !-- Insight: this is a genuine *tropical differential equation* statement: the tropicalized
--     equation pins the valuation of every classical solution to the bottom element, the
--     tropical-fundamental-theorem phenomenon in its simplest nontrivial instance. -- !--
-- !-- Failure analysis: the assumption `c ≠ 0` is essential — with `c = 0` the equation
--     `f' = 0` is solved by every nonzero constant *and* fails to constrain higher orders
--     (e.g. `f = X` would need char data); see the Critic note in FUTURE_DIRECTIONS. -- !--
-- !-- End Lab Notebook -- !--

-- !-- linODE_order_zero: if `ord f > 0`, the exact drop gives `ord f' + 1 = ord f` while
--     `f' = c·f` and `order_smul_eq` give `ord f' = ord f`; for finite valuation `m` this is
--     `m + 1 = m`, impossible — so `ord f = 0`. -- !--
/-- **Tropical valuation pinning for a linear ODE.**  Over a characteristic-zero field, every
nonzero solution of `f' = c·f` with `c ≠ 0` has order `0`: the tropicalized differential
equation forces the valuation down to the bottom element.  A one-line instance of the
"tropicalization controls classical solutions" principle. -/
theorem linODE_order_zero [Field R] [CharZero R] (f : R⟦X⟧) (hf : f ≠ 0)
    (c : R) (hc : c ≠ 0) (hode : d⁄dX R f = c • f) : order f = 0 := by
  by_contra h
  have hpos : 0 < order f := pos_iff_ne_zero.mpr h
  have key := order_deriv_eq_of_pos f hf hpos
  rw [hode, order_smul_eq c hc f] at key
  have hfin : order f < ⊤ := order_finite_iff_ne_zero.mpr hf
  lift order f to ℕ using hfin.ne with m
  simp at key

end

end TropicalDiff