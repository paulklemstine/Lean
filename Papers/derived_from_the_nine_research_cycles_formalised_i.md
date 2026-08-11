# Computational evidence — cycle 10 (Diophantine-lattice spectral bounds, rank two)

All the numbers below were produced by exact rational arithmetic (no floating point) before the
Lean formalisation was written.  They are *evidence*, not proof; every claim they support is
proved without `sorry` in

* `Catalog/Physics/DiophantineLatticeRankTwoStrict.lean`
* `Catalog/Physics/DiophantineLatticeBinaryEnumerator.lean`

Notation: `Q_{a,b,c}(x,y) = a x² + b x y + c y²`, `λ₁ = min_{m ≠ 0} Q(m)`,
`μ(t) = min_{m ∈ ℤ²} Q(t − m)`.

## 1. Strictness of the packing–covering inequality in rank two (Conjecture C1)

For each reduced triple the table lists `λ₁`, the gap at the `2`-torsion shift `(½,½)`, the
maximum of `μ` over a `25 × 25` grid of rational points of `[0,1]²` (a lower bound for the
covering radius²), and `λ₁/4`.

| `(a,b,c)` | `λ₁` | `μ(½,½)` | grid max of `μ` (argmax) | `λ₁/4` | strict? |
|---|---|---|---|---|---|
| (1,0,1) | 1 | 1/2 | 1/2 at (1/2,1/2) | 1/4 | yes |
| (1,1,1) | 1 | **1/4** | 1/3 at (1/3,1/3) | 1/4 | yes |
| (2,1,3) | 2 | 1 | 577/576 at (5/12,11/24) | 1/2 | yes |
| (1,0,5) | 1 | 3/2 | 3/2 at (1/2,1/2) | 1/4 | yes |
| (3,2,7) | 3 | 2 | 149/72 at (3/8,11/24) | 3/4 | yes |
| (5,4,9) | 5 | 5/2 | 385/144 at (1/3,5/12) | 5/4 | yes |
| (2,2,3) | 2 | 3/4 | 41/48 at (1/4,5/12) | 1/2 | yes |
| (1,1,2) | 1 | 1/2 | 319/576 at (7/24,5/12) | 1/4 | yes |
| (2,0,2) | 2 | 1 | 1 at (1/2,1/2) | 1/2 | yes |
| (3,3,3) | 3 | **3/4** | 1 at (1/3,1/3) | 3/4 | yes |
| (1,−1,1) | 1 | **1/4** | 1/3 at (1/3,2/3) | 1/4 | yes |

Two observations drove the formal proof.

1. In *every* case `μ(½,½) = (a − |b| + c)/4` exactly.  Since `|b| ≤ a ≤ c`, this is `> λ₁/4 = a/4`
   precisely when `|b| < c` — proved as `reduced_half_lower` + `reduced_certificate`.
2. The bold entries are the cases where the `2`-torsion certificate fails, i.e.
   `μ(½,½) = λ₁/4`.  They are exactly the hexagonal triples `a = c = |b|` — in the reduction
   domain `|b| = c` forces `a = c = |b|`.  There the maximum is attained at the `3`-torsion point
   `(⅓,±⅓)` with value `a/3`.  This is `hex_third_lower` and `hex_third_isInhomMin`.

Counterexample hunt: no reduced triple with `|b| ≤ a ≤ c` was found for which *both* certificates
fail; the formal proof shows none exists.

## 2. The hexagonal obstruction

For `Q = x² + xy + y²` the coset minima on the four classes of `L/2L` are

```
class (0,0) → 0 ,  class (1,0) → 1 ,  class (0,1) → 1 ,  class (1,1) → 1
```

so *all three* nonzero classes contain a shortest vector `(1,0)`, `(0,1)`, `(1,−1)`, and every
`2`-torsion shift has gap `1/4 = λ₁/4`, while `μ(⅓,⅓) = 1/3`.  Formalised as
`hex_two_torsion_gap`, `hex_third_isInhomMin`, `hexagonal_two_torsion_never_deepest`.

## 3. The covering weight enumerator (Conjecture D′ in rank two)

Coset minima computed by exhaustive search over `p, q ∈ [−6,6]` for each of the four classes:

| `(a,b,c)` | `W = {4μ(v/2) : v ∈ L/2L}` | predicted `{0, a, c, a + c − |b|}` |
|---|---|---|
| (1,0,1) | {0,1,1,2} | {0,1,1,2} |
| (1,1,1) | {0,1,1,1} | {0,1,1,1} |
| (2,1,3) | {0,2,3,4} | {0,2,3,4} |
| (1,0,5) | {0,1,5,6} | {0,1,5,6} |
| (3,2,7) | {0,3,7,8} | {0,3,7,8} |
| (5,4,9) | {0,5,9,10} | {0,5,9,10} |
| (2,2,3) | {0,2,3,3} | {0,2,3,3} |
| (1,1,2) | {0,1,2,2} | {0,1,2,2} |
| (3,3,3) | {0,3,3,3} | {0,3,3,3} |
| (1,−1,1) | {0,1,1,1} | {0,1,1,1} |
| (2,−1,3) | {0,2,3,4} | {0,2,3,4} |
| (4,3,5) | {0,4,5,6} | {0,4,5,6} |

Agreement in all 12 cases.  Since `|b| ≤ a ≤ c` gives `a ≤ c ≤ a + c − |b|`, the multiset is
automatically sorted, which is why `min`, `max` and the total sum recover `(a, c, |b|)` —
formalised as `coverEnum_determines` and `coverEnum_complete_invariant`.

No OEIS sequence is involved: the objects here are multisets of rationals attached to individual
lattices rather than an integer sequence.

## 4. The exact covering radius of a binary lattice (cycle 11)

Conjecture tested: for a reduced triple `0 ≤ b ≤ a ≤ c` the covering radius² is the circumradius²
of the Delaunay triangle `{0, e₁, e₁ − e₂}`,

  `μ(a,b,c) = a c (a − b + c) / (4 a c − b²)`.

Exhaustive rational minimisation over `p, q ∈ [−4, 4]` at the predicted deep hole
`u = c(2a−b)/(4ac−b²)`, `v = a(2c−b)/(4ac−b²)` (all values exact rationals):

| `(a,b,c)` | deep hole `(u,v)` | `μ` predicted | brute-force min at the deep hole | `λ₁/4` | `(a−b+c)/4` |
|---|---|---|---|---|---|
| (1,0,1) | (1/2, 1/2) | 1/2 | 1/2 | 1/4 | 1/2 |
| (1,1,1) | (1/3, 1/3) | 1/3 | 1/3 | 1/4 | 1/4 |
| (2,1,3) | (9/23, 10/23) | 24/23 | 24/23 | 1/2 | 1 |
| (1,0,5) | (1/2, 1/2) | 3/2 | 3/2 | 1/4 | 3/2 |
| (3,2,7) | (7/20, 9/20) | 21/10 | 21/10 | 3/4 | 2 |
| (1,1,2) | (2/7, 3/7) | 4/7 | 4/7 | 1/4 | 1/2 |

Agreement in every case, and the two-sided bracket of cycle 10 —
`(a−b+c)/4 ≤ μ ≤ (a+b+c)/4` — is seen to be attained on the left exactly when `b = 0`
(rows 1 and 4), which is `covRad_eq_two_torsion_iff`.  The hexagonal row is the unique reduced
triple (up to scaling) at which `μ = λ₁/3` rather than `λ₁/2`.

The check was rerun as a Lean `#eval` against the formalised `covRad` and `deepHole`; the
theorems `deepHole_isInhomMin`, `binary_covering_le` and `rank_two_covering_radius` are proved,
so these numbers are illustrations rather than the evidence base.
