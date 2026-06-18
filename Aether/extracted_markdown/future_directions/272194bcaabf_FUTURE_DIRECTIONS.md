# Future Directions: Tropical BSD Machine

## Direction 1: Tropical BSD for Groups with Torsion

### Theorem Statement

For a finitely generated abelian group modeled as ℤⁿ × (ℤ/m₁ℤ) × ... × (ℤ/mₖℤ), define:
- Tropical rank = n (free rank only)
- Tropical L-series with coefficient function c indexed by subsets of generators
- Tropical torsion correction term |tors|² (in the tropical/additive sense: 2·log|tors|)

**Conjecture:** Under genericity,
```
tropVanishingOrder(c) = n
```
and
```
tropResidue(c) = tropRegulator(M) + tropTamagawa(S, τ) - 2·tropTorsion(m₁,...,mₖ)
```

### Why It Matters
This would bring the tropical BSD machine closer to the actual Mordell–Weil group structure, where torsion subgroups play an important role in the leading coefficient formula.

### Building On
- `tropical_BSD_split_model` (current cycle): provides the torsion-free base case
- `tropical_residue_model_exact`: provides the residue decomposition framework

### Formalization Difficulty
**Medium.** The main challenge is defining the torsion correction cleanly in the tropical/additive setting and proving that the vanishing order is unchanged by torsion (since torsion does not affect rank).

### Proof Strategy
1. Define `TropicalMWGroupWithTorsion` as a structure with free rank n and torsion data
2. Show vanishing order depends only on the free part
3. Extend residue decomposition to include torsion correction
4. Use the existing split model theorem as the core ingredient

---

## Direction 2: Tropical Height Pairing and Exact Regulator Formulas

### Theorem Statement

For vectors v₁, ..., vₙ ∈ ℝⁿ, define the tropical height pairing matrix:
```
H[i,j] = tropHeight(vᵢ, vⱼ) := ‖vᵢ‖_∞ + ‖vⱼ‖_∞ - ‖vᵢ - vⱼ‖_∞
```

**Theorem (Tropical Regulator = Tropical Permanent of Height Matrix):**
For a diagonal basis {e₁, ..., eₙ} with heights hᵢ,
```
tropicalRegulator(H) = ∑ᵢ hᵢ
```
and this equals the tropical permanent of the height matrix, achieved by the identity permutation.

More generally, for a Monge matrix M (satisfying M[i,j] + M[k,l] ≤ M[i,l] + M[k,j] for i < k, j < l), the identity permutation is optimal.

### Why It Matters
This would establish a genuine tropical analogue of the Néron–Tate height pairing and connect the regulator to intrinsic geometric data of the lattice, rather than an abstract matrix.

### Building On
- `tropicalRegulator_diagonal` and `tropicalRegulator_diagonal_eq` (current cycle)
- `tropical_residue_model_exact`: regulator appears in residue

### Formalization Difficulty
**Medium-High.** Requires formalizing the Monge property and proving the identity permutation is optimal for Monge matrices (a well-known combinatorial result, but potentially complex in Lean).

### Proof Strategy
1. Define `TropicalHeightPairing` from vector data
2. Prove the Monge property for height matrices from orthogonal bases
3. Apply the Monge-optimality theorem to conclude identity permutation is optimal
4. Derive exact regulator formula

---

## Direction 3: Newton Polygon Equivalence

### Theorem Statement

For a tropical L-series L(t) = min_I (|I|·t + c(I)), define its Newton polygon as the graph of L. Let slope₀⁺(L) be the right slope of L at t = 0.

**Theorem:** Under the genericity condition,
```
slope₀⁺(L) = tropVanishingOrder(c) = n
```

More precisely: the right slope at t = 0 of the lower envelope of the affine family {|I|·t + c(I)} equals the minimum cardinality among coefficient minimizers.

### Why It Matters
This establishes the tropical vanishing order as a *geometric* quantity (slope of a Newton polygon), connecting the BSD framework to classical algebraic geometry where Newton polygons encode valuations of p-adic L-functions.

### Building On
- `tropLSeries_eq_some_piece` (current cycle): the L-series equals one of its pieces
- `tropical_BSD_split_model`: the equality theorem

### Formalization Difficulty
**Medium.** The main challenge is defining the right derivative of a piecewise-linear function in Lean. Since L is the min of finitely many affines, the right derivative exists and equals the slope of the active piece with smallest slope among those active at t = 0.

### Proof Strategy
1. Define `rightSlope` for piecewise-linear functions (min of affines)
2. Show active pieces at t = 0 are exactly the minimizers of c
3. Show rightSlope = min{|I| : c(I) = c_min}
4. Connect to vanishing order definition

---

## Direction 4: Tropical Tauberian Theorem for Min-Plus Dirichlet Series

### Theorem Statement

Define a tropical Dirichlet series:
```
D(s) = min_{n ∈ S} (a(n) + s · log(n))
```
for a finite support set S ⊂ ℕ and coefficient function a: S → ℝ.

**Theorem (Tropical Tauberian):** The asymptotic growth rate of the "summatory function"
```
A(x) = min_{n ≤ x, n ∈ S} a(n)
```
is determined by the tropical order of vanishing of D at s = 0:
```
A(x) ≥ A(1) - ord_0(D) · log(x)  for all x ≥ 1
```
with equality along a subsequence under genericity.

### Why It Matters
Classical Tauberian theorems (Ikehara, Wiener) connect the behavior of L-functions at s = 1 to the distribution of primes or arithmetic objects. A tropical Tauberian theorem would establish this connection in the min-plus setting, potentially enabling tropical proofs of prime-distribution results.

### Building On
- `tropLSeries_at_zero`: L-series at basepoint
- `tropical_BSD_inequality`: the inequality direction

### Formalization Difficulty
**High.** Requires developing tropical asymptotic analysis in Lean, which is currently not in Mathlib.

### Proof Strategy
1. Define tropical Dirichlet series with logarithmic weights
2. Relate the minimum over finite sums to the L-series value
3. Prove the lower bound by direct comparison of active pieces
4. Establish equality under a non-degeneracy condition on the support

---

## Direction 5: Tropical Gross–Zagier Derivative Formula

### Theorem Statement

Define the "tropical derivative" of the L-series at t = 0:
```
L'_trop(0) := lim_{ε→0⁺} (L(ε) - L(0)) / ε
```
which equals the minimum slope among active pieces at t = 0 (= vanishing order, by definition).

For rank 1, define a tropical Heegner point h ∈ ℝ and prove:
```
L'_trop(0) = c · h²_trop
```
where h²_trop is a tropical height and c is an explicit constant.

### Why It Matters
The Gross–Zagier formula [GZ86] is one of the deepest results in arithmetic geometry, connecting L'(E,1) to Heegner point heights. A tropical analogue would provide a derivative-level identity beyond the rank equality, potentially opening a tropical route to higher-rank BSD.

### Building On
- `tropical_BSD_split_model`: rank equality (the "zeroth-order" BSD)
- `tropicalRegulator`: tropical height data

### Formalization Difficulty
**Very High.** Requires defining tropical Heegner points, which do not have a standard definition in the literature. However, a "toy" version for the split rank-1 model (n = 1) should be tractable.

### Proof Strategy
1. For n = 1: L(t) = min(c(∅), t + c({0}))
2. If c({0}) < c(∅), then L'_trop(0) = 1
3. Define h_trop = c(∅) - c({0}) (the "Heegner height")
4. Prove L'_trop(0) = 1 iff h_trop > 0 (the curve has a "Heegner point")
5. Express L(ε) - L(0) = min(0, ε - h_trop) for the residue connection

---

## Cross-Cutting Research Program

These five directions form a coherent program:

```
Direction 1 (Torsion) ──────► Direction 2 (Heights) ──────► Direction 5 (Gross-Zagier)
       │                              │
       ▼                              ▼
Direction 4 (Tauberian) ◄──── Direction 3 (Newton Polygon)
```

**Phase 1** (3–6 months): Directions 1 and 3 (torsion extension and Newton polygon), building directly on current results.

**Phase 2** (6–12 months): Direction 2 (height pairings), requiring Monge matrix theory.

**Phase 3** (12–18 months): Directions 4 and 5 (Tauberian and Gross–Zagier), requiring new tropical analysis infrastructure.

The ultimate goal: a formally verified tropical BSD framework comprehensive enough to serve as a testing ground for strategies that might eventually apply to the classical conjecture.
