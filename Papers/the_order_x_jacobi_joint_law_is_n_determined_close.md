# Computational Evidence — Order × Jacobi Joint Law

All numbers below were produced by direct enumeration (exact integer arithmetic)
*before* the Lean formalisation, and every claim that survived is now a
machine-checked theorem in `Catalog/Computation/OrderJacobiJointLaw.lean`.
Nothing in this file is itself a verification; it is the exploratory stage.

Notation: `H p = (p−1)/2`, `L = lcm(H p, H q)`, `J(b|N)` the Jacobi symbol,
`v₂(n)` the 2-adic valuation.

## 1. The QR ↔ order coupling is exact

For every odd prime `p < 200` and every unit `b mod p`:

```
(b/p) = +1   ⟺   ord_p(b) | (p−1)/2
4180 / 4180 units agree  (all odd primes below 200)
```

Formalised (unconditionally, all odd primes) as
`OrderJacobi.isSquare_iff_orderOf_dvd_half`.

## 2. The lift to `N = p·q` fails exactly when the 2-adic valuations differ

Counting units `b` with `ord_N(b) | L` that are **not** residues at both primes:

| p  | q  | v₂(H p) | v₂(H q) | # counterexamples |
|----|----|---------|---------|-------------------|
| 3  | 5  | 0 | 1 | 2  |
| 3  | 7  | 0 | 0 | 0  |
| 7  | 11 | 0 | 0 | 0  |
| 5  | 13 | 1 | 1 | 0  |
| 11 | 19 | 0 | 0 | 0  |
| 5  | 7  | 1 | 0 | 6  |
| 3  | 13 | 0 | 1 | 6  |
| 7  | 23 | 0 | 0 | 0  |
| 13 | 17 | 1 | 3 | 48 |

The pattern "0 counterexamples ⟺ v₂(H p) = v₂(H q)" is exactly the content of
the proved dichotomy `OrderJacobi.orderOf_dvd_lcm_half_iff_iff_balanced`
(sufficiency: `isSquare_of_orderOf_dvd_lcm_half`; necessity:
`exists_counterexample_of_unbalanced`).  Note `v₂(H p) = 0 ⟺ p ≡ 3 (mod 4)`,
which is the "residue dial" reported by the experiment.

## 3. Conditional order means are shared by different semiprimes

```
N=35=5·7 : E[ord | J=+1] = 6.4167   E[ord | J=−1] = 7.0000   ratio 0.9167
N=39=3·13: E[ord | J=+1] = 6.4167   E[ord | J=−1] = 7.0000   ratio 0.9167
N=77=7·11: E[ord | J=+1] = 14.7000  E[ord | J=−1] = 19.6000  ratio 0.7500
N=93=3·31: E[ord | J=+1] = 14.7000  E[ord | J=−1] = 19.6000  ratio 0.7500
```

The conditional bias is real (ratios ≠ 1, consistent with the reported
0.68–1.01 range) but it is *not* a function of the factors: distinct semiprimes
share it exactly.

## 4. Joint-law collisions are abundant

Enumerating all semiprimes `N = p·q < 1000` and hashing the full multiset
`{(ord_N(b), J(b|N)) : b ∈ (Z/N)ˣ}` gives **30 classes containing two or more
distinct moduli**, e.g.

```
{35 = 5·7,  39 = 3·13}
{77 = 7·11, 93 = 3·31}
{95 = 5·19, 111 = 3·37}
{143 = 11·13, 155 = 5·31, 183 = 3·61}
{161 = 7·23, 201 = 3·67}
...
```

The smallest pair `(35, 39)` is coprime, which is what turns a collision into a
barrier.  Formalised as `OrderJacobi.jointLaw_35_eq_39` (kernel-checked
enumeration through a proven-correct computable presentation of the law) and
`OrderJacobi.no_jointLaw_factorizer`.

A structural explanation is also proved: any isomorphism of unit groups
preserving the Jacobi symbol transports the entire joint law
(`OrderJacobi.jointLaw_eq_of_jacobiPreserving`); group isomorphisms preserve
element orders automatically, so the law only sees the pair
(unit group, quadratic character), which is far coarser than the factorisation.

## 5. OEIS

No new integer sequence is introduced here; the counting statement proved is the
classical `φ(N)/4` quadrant split (`card_units_semiprime`,
`four_mul_card_half_order_class`), so no OEIS lookup was warranted.
