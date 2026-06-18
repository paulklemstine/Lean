# Future Directions — Tropical Differential Equations: Power Series Solutions

## Synthesis

This cycle built the **valuation tropicalization** of formal power series `R⟦X⟧` and used it
to turn differential constraints into min-plus arithmetic on orders.  The new file
`Catalog/Tropical/DifferentialPowerSeries.lean` defines `tropOrder f = trop (order f)`, a map
into the min-plus tropical semiring `Tropical (WithTop ℕ)`, and proves it is a *lax semiring
homomorphism*: exactly multiplicative on products (`tropOrder_mul`) and super-additive on
sums (`tropOrder_add_le`).  This is the static, algebraic half of tropicalization, and it
slots directly beside the catalog's existing `Tropical.DiffConstraints` (tropical convexity of
difference-constraint polyhedra) and `Tropical.Convexity`: where those tropicalize a *polytope*,
we tropicalize a *ring with derivation*.

The cycle's substantive discovery is the **differential** half.  The formal derivative `d⁄dX`
acts on valuations as "subtract at most one": `order_deriv_succ_le` proves `ord f ≤ ord f' + 1`
over *any* commutative ring, and `order_iterate_deriv_le` propagates this to `ord f ≤ ord f⁽ᵏ⁾ + k`.
This is the precise mechanism by which tropical data lower-bounds classical growth: every
differential monomial of order `k` can pull the valuation down by at most `k`.  The inequality
becomes an *equality* exactly in characteristic zero (`order_deriv_eq_of_pos`), where the integer
factor `(i+1)` never vanishes — pinpointing characteristic as the boundary between the lax and
exact tropical derivative.

The structural insight is that **the lax/exact dichotomy is governed by characteristic**, and
that exactness is strong enough to *pin* valuations.  The headline `linODE_order_zero` shows the
linear ODE `f' = c·f` (`c ≠ 0`) forces every nonzero solution to have order `0`: the tropicalized
equation `ord f' = ord f` collides with the exact drop `ord f' = ord f - 1`, leaving only the
bottom valuation.  This is the simplest nontrivial instance of the tropical-fundamental-theorem
phenomenon — the tropicalization of the equation determines the tropicalization of its solution
set — realized concretely rather than axiomatically.  What did *not* survive scrutiny: the same
pinning fails for `c = 0` (then `f' = 0` is solved by every nonzero constant and does not
constrain higher data), and the *equality* `order_deriv_eq_of_pos` genuinely needs char 0
(in char `p`, `f = Xᵖ` has `f' = 0`, so the order jumps to `⊤`).

## Results Summary

- `tropOrder_mul`: proved — valuation tropicalization is multiplicative, `T(f·g) = T f · T g`, the tropical product law over a domain.
- `tropOrder_add_le`: proved — valuation tropicalization is super-additive, `T f + T g ≤ T(f+g)`, the tropical (min) sum law.
- `order_deriv_succ_le`: proved — the formal derivative lowers the order by at most one, `ord f ≤ ord f' + 1`, over any commutative ring (the universal tropical derivative bound).
- `order_iterate_deriv_le`: proved — the `k`-th derivative lowers the order by at most `k`, `ord f ≤ ord f⁽ᵏ⁾ + k`, bounding every order-`k` differential monomial.
- `order_deriv_eq_of_pos`: proved — in characteristic zero the derivative drop is exact for positive order, `0 < ord f → ord f' + 1 = ord f`.
- `linODE_order_zero`: proved — over a char-0 field, every nonzero solution of `f' = c·f` (`c ≠ 0`) has order `0`: the tropicalized equation pins the valuation to the bottom.

## Research Directions

### Direction 1: Tropical balancing for general linear ODEs with polynomial coefficients
**Hypothesis**: For `a·f' = b·f` with `a, b ∈ R⟦X⟧` nonzero over a char-0 field, the tropical
balance condition `ord a + ord f - 1 = ord b + ord f` (when `ord f > 0`) determines
`ord a - 1 = ord b`, so a solution of positive order exists only if `ord a = ord b + 1`;
otherwise `ord f = 0`.
**Test**: State `linODE_poly_order` generalizing `linODE_order_zero` to power-series coefficients
and prove it from `order_deriv_eq_of_pos`, `tropOrder_mul`, and a case split on `ord a` vs `ord b`.
**Why now**: `order_deriv_eq_of_pos` already gives the exact derivative drop, and `tropOrder_mul`
already tropicalizes the coefficient products — the only new ingredient is the min-plus balance.
**If true**: yields a tropical *Newton-polygon* criterion for the existence of positive-order
solutions, the first genuine "tropical solution set = solution set of tropicalization" theorem here.
**If false**: the failure isolates which coefficient configurations break valuation determinacy,
e.g. when leading terms cancel.

### Direction 2: Tropicalization as a bona fide lax semiring homomorphism object
**Hypothesis**: `tropOrder` extends to a structure-preserving map recorded as a Mathlib bundled
morphism that is a `MonoidHom` (for `*`) and satisfies the lax `+` law, with `tropOrder 1 = 1`
and `tropOrder 0 = 0` (the tropical bottom `⊤`).
**Test**: Build `tropOrderMonoidHom : R⟦X⟧ →* Tropical (WithTop ℕ)` and prove `map_one`/`map_mul`
discharge from `tropOrder_mul` plus `order_one`; check the unit/zero edge cases.
**Why now**: `tropOrder_mul` is exactly `map_mul`, so the bundling is immediate; this packages the
cycle's static half into a reusable catalog object other files can `import`.
**If true**: gives downstream files (e.g. tropical Bezout / divisor theory) a ready valuation hom
into the tropical semiring, enabling cross-domain reuse.
**If false**: would reveal that `order` fails some homomorphism law (it cannot — but the *lax* `+`
shows why a full `RingHom` is impossible, an instructive boundary).

### Direction 3: Support-level fundamental theorem for monomial differential equations
**Hypothesis**: For a single differential monomial equation `∏ⱼ (f⁽ʲ⁾)^{eⱼ} = 0` over an integral
domain, the support (set of nonzero-coefficient indices) of any solution is constrained by the
tropical equation `∑ⱼ eⱼ·(ord f - j) = ⊤`, i.e. the tropicalized monomial forces `ord f = ⊤`
(so `f = 0`) whenever every factor is enforced.
**Test**: Define `tropMonomial` evaluating `∑ eⱼ (v - j)` on `v = ord f` and prove the implication
`(monomial = 0) → tropMonomial (ord f) = ⊤` using `tropOrder_mul` and `order_iterate_deriv_le`.
**Why now**: `order_iterate_deriv_le` already tropicalizes each derivative factor and `tropOrder_mul`
multiplies them; only the assembly into a monomial sum is missing.
**If true**: this is the multiplicative core of the Aroca–Garay–Toghani fundamental theorem,
formalized for the monomial case.
**If false**: pinpoints which monomial shapes admit nonzero solutions despite vanishing
tropicalization, a genuine counterexample to over-optimistic tropical determinacy.

### Direction 4: Riccati and the boundary of valuation pinning
**Hypothesis**: The nonlinear equation `f' = f²` over a char-0 field admits *no* power-series
solution of positive order, but unlike the linear case it also constrains the leading coefficient:
matching `ord f' = ord f - 1` with `ord f² = 2·ord f` forces `ord f - 1 = 2·ord f`, i.e.
`ord f = -1`, which is impossible in `ℕ∞`, so `f` must be a unit or zero.
**Test**: Prove `riccati_no_positive_order` from `order_deriv_eq_of_pos` and `order_mul`; then probe
the boundary by allowing Laurent series (`ord f = -1` becomes realizable: `f = -1/X`).
**Why now**: `order_deriv_eq_of_pos` plus `order_mul` give both sides of the balance directly;
this is the first nonlinear stress test of the pinning method.
**If true**: shows the tropical method extends verbatim from linear to nonlinear equations and
predicts the *Laurent* pole order, motivating a `LaurentSeries` port.
**If false**: the obstruction reveals where nonlinearity defeats simple valuation balancing.

### Direction 5: From valuation tropicalization to the Newton polygon of a power series
**Hypothesis**: The lower convex hull of `{(n, v(aₙ))}` (with a second valuation `v` on `R`)
refines `tropOrder`, and its first slope equals `ord f`; differentiation shifts the polygon left
by one, recovering `order_deriv_succ_le` as the slope inequality.
**Test**: Define `newtonSlopes f` for `R` a valued field and prove `firstSlope = order` and a
shift lemma for `d⁄dX`, recovering `order_deriv_succ_le` as a corollary.
**Why now**: this cycle established the one-dimensional (order-only) tropicalization; the Newton
polygon is the natural two-dimensional refinement, and the derivative-shift law is already proved
in its degenerate form.
**If true**: connects `DifferentialPowerSeries` to the catalog's amoeba/Ronkin tropical-geometry
files (`Tropical.AmoebaRonkin`) via Newton polygons, a cross-domain bridge.
**If false**: identifies where the order-valuation and coefficient-valuation tropicalizations
diverge, clarifying the limits of single-valuation tropical methods.
