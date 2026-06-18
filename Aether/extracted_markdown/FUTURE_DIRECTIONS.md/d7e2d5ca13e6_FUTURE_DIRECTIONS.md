# FUTURE_DIRECTIONS: Tropical Differential Algebra

## Synthesis

This cycle established the foundational infrastructure for tropical differential algebra in Lean 4: tropical power series over `WithTop ℤ`, tropical convolution (`tmul`), the tropical derivative as a shift operator (`tderiv`), and tropical order (`torder`). The central achievement is the **Tropical Leibniz Rule as an equality** — `D(f ⊙ g) = (Df ⊙ g) ⊕ (f ⊙ Dg)` — which is stronger than the classical analogue where cancellation can weaken the identity to an inequality in tropical settings. The equality holds because the index decomposition `{0,...,n+1} = {0,...,n} ∪ {1,...,n+1}` is exact (every pair `(i,j)` with `i+j=n+1` has `i≥1` or `j≥1`).

We also proved that tropical convolution is commutative, the tropical derivative decreases order by exactly 1, and that tropical order is subadditive under convolution. These four results together give the tropical power series ring a well-behaved differential algebra structure suitable for studying tropical ODEs.

A structural insight: the use of `Finset.inf'` over `Finset.range(n+1)` avoids universe and decidability issues that arise with `iInf` on `WithTop ℤ`. This representation cleanly integrates with Mathlib's lattice infrastructure.

## Results Summary

| Theorem | Status | Significance |
|---------|--------|-------------|
| `tropical_leibniz` | **proved** | D(f⊙g) = (Df⊙g)⊕(f⊙Dg) — the Leibniz rule holds as equality, not just inequality |
| `tmul_comm` | **proved** | Tropical convolution is commutative — essential for algebraic structure |
| `tderiv_order_exact` | **proved** | Tropical derivative decreases order by exactly 1 — key for Newton polygon analysis |
| `torder_tmul_le` | **proved** | Tropical order is subadditive: ord(f⊙g) ≥ ord(f)+ord(g) — bounds solution growth |
| `range_succ_union` | **proved** | Combinatorial lemma: {0,...,n+1} = {0,...,n} ∪ {1,...,n+1} — heart of Leibniz proof |
| `torder_below_top` | **proved** | Series below its order are ⊤ — helper for order theory |

## Research Directions

### Direction 1: Higher-Order Tropical Leibniz and Newton Polygon

**Hypothesis**: For the k-th iterated tropical derivative, `D^k(f ⊙ g)(n) = ⨁_{j=0}^{k} C(k,j) ⊙ D^j(f) ⊙ D^{k-j}(g)` where `C(k,j)` is the tropical binomial coefficient (which in the min-plus setting is 0, so the formula simplifies to `⨁_{j=0}^{k} D^j(f) ⊙ D^{k-j}(g)`). This should follow by induction from `tropical_leibniz`.

**Test**: State and prove `tropical_leibniz_higher : tderiv^[k] (tmul f g) = tadd-fold over j of tmul (tderiv^[j] f) (tderiv^[k-j] g)`. The inductive step applies `tropical_leibniz` to `tderiv^[k-1](tmul f g)`.

**Why now**: The exact equality in `tropical_leibniz` (not an inequality) makes the induction clean — there is no error accumulation across iterations.

**If true**: This enables the definition of a tropical Newton polygon for differential polynomials `P(y, Dy, ..., D^k y)` and the classification of leading-term behavior of ODE solutions.

**If false**: The higher-order formula might require a correction term; understanding where it breaks would reveal hidden structure in tropical differentiation.

### Direction 2: Tropical Associativity and Semiring Structure

**Hypothesis**: `tmul` is associative: `tmul (tmul f g) h = tmul f (tmul g h)`. Combined with the existing `tmul_comm`, this gives tropical power series the structure of a commutative monoid under tropical multiplication (with the unit being the series `δ_0` where `δ_0(0) = 0` and `δ_0(n) = ⊤` for `n > 0`).

**Test**: Prove `tmul_assoc` by showing both sides equal `Finset.inf'` of `f(i) + g(j) + h(k)` over all `(i,j,k)` with `i+j+k = n`. The key step is the Finset rearrangement: `⨆ over (a,b) with a+b=n of (⨆ (i,j) with i+j=a of f(i)+g(j)) + h(b)` equals the triple infimum.

**Why now**: `tmul_comm` is proved and provides one structural constraint. The `Finset.inf'_image` and `Finset.inf'_union` machinery is already working in our codebase.

**If true**: Opens the door to tropical polynomial rings, tropical resultants, and tropical elimination theory.

**If false**: Would indicate something unexpected about `Finset.inf'` and `WithTop ℤ` addition interaction — likely a Nat subtraction edge case rather than a mathematical failure.

### Direction 3: Tropical ODE Superposition and Solution Lattice

**Hypothesis**: For a first-order tropical linear ODE `min(f(n+1), a(n) + f(n)) = b(n)`, if f and g are both solutions, then `tadd f g` (pointwise min) is also a solution. More generally, the solution set forms a sublattice of `TSeries` under pointwise min.

**Test**: Define `tropical_linear_ode_sol a b f := ∀ n, min(f(n+1), a n + f n) = b n` and prove `tropical_ode_superposition : tropical_linear_ode_sol a b f → tropical_linear_ode_sol a b g → tropical_linear_ode_sol a b (tadd f g)`. The proof uses distributivity of min over itself (idempotency) and regrouping.

**Why now**: The `tadd` definition and the `WithTop ℤ` lattice structure are established. The proof is essentially `min(min(A,C), min(B,D)) = min(min(A,B), min(C,D))` which is associativity+commutativity of min.

**If true**: Establishes the tropical analogue of the vector space structure of linear ODE solutions. Combined with `torder_tmul_le`, this constrains solution growth rates.

**If false**: Would indicate that tropical linearity is not preserved under tropical addition — which would be surprising given the distributivity of min over +.

### Direction 4: Weighted Tropical Derivative and p-adic Applications

**Hypothesis**: Define a weighted tropical derivative `tderiv_w w f n = w(n+1) + f(n+1)` where `w : ℕ → WithTop ℤ` is a weight function (e.g., `w(n) = v_p(n)` for p-adic valuation). Then a weighted Leibniz rule holds: `tderiv_w w (tmul f g) = tadd (tmul (tderiv_w w f) g) (tmul f (tderiv_w w g))` **if and only if** `w` is "tropical-additive" in an appropriate sense.

**Test**: First, try the weighted Leibniz with `w(n) = 0` (recovering the unweighted case). Then try `w(n) = n` and check whether equality or only inequality holds, using `#eval` on concrete examples.

**Why now**: The unweighted Leibniz is now proved as an exact equality. The weighted version generalizes it and connects to p-adic differential algebra, where the weight function encodes the valuation of factorial-like terms.

**If true**: Provides a single framework unifying tropical differentiation over different valued fields (trivial, p-adic, t-adic).

**If false**: The weighted Leibniz failing as an equality would identify exactly which valuations support exact tropical differentiation vs. only approximate.

### Direction 5: Tropical Order Exactness for Convolution

**Hypothesis**: The subadditivity `torder(tmul f g) ≥ torder(f) + torder(g)` proved in `torder_tmul_le` is actually an equality when neither f nor g is identically ⊤: `torder(tmul f g) = torder(f) + torder(g)`.

**Test**: First verify with `#eval` on concrete examples (e.g., `f = [⊤, 0, 1, ...]` and `g = [⊤, ⊤, 3, ...]`). Then prove it by showing `(tmul f g)(m+p) ≠ ⊤` when `f(m) ≠ ⊤` and `g(p) ≠ ⊤`: the term `f(m) + g(p)` at `i = m` is finite, and it contributes to the infimum.

**Why now**: `torder_tmul_le` gives the ≥ direction. The ≤ direction needs showing that at least one term in the infimum at index `m+p` is finite, which follows from `f(m) ≠ ⊤` and `g(p) ≠ ⊤`.

**If true**: This would be the tropical analogue of the fact that the order of a product of formal power series equals the sum of orders — a fundamental property for Newton polygon computations.

**If false**: Would require additional hypotheses (e.g., no "tropical cancellation" at index `m+p`), revealing a genuine difference between tropical and classical series multiplication.
