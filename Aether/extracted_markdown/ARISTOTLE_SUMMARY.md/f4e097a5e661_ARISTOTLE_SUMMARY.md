# Summary of changes for run 1d0dbfbd-ea6d-4c26-a242-97842bcbf736
# Sharp √2 Bound on Pythagorean Triple Ratios — Complete

## Formally Verified Mathematics (Lean 4)

**File: `RequestProject/PythagoreanBound.lean`** — Complete, sorry-free proof depending only on standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

### Main Theorem (`BerggrenTree.pell_supremum_and_tropical_defect`)

For any primitive Pythagorean triple (a, b, c) with a² + b² = c², gcd(a,b) = 1, c > 0:

1. **Strict bound**: c / max(|a|, |b|) < √2
2. **Sharp supremum**: √2 is the least upper bound (IsLUB) of all such ratios
3. **Berggren B iterations**: Every iterate from (3,4,5) is a primitive triple with a_n - b_n = (-1)^(n+1) (consecutive legs with alternating sign)
4. **Tropical defect**: log(c) - max(log|a|, log|b|) < (1/2)·log(2)

### Correction to Part 3

The originally proposed formula `c/max = √(2 - (-1)^n/c²)` is **numerically incorrect**: for (3,4,5), the LHS = 5/4 = 1.25 while the RHS = √(49/25) = 7/5 = 1.4. The correct structural property — that the Berggren B iterations produce triples with consecutive legs (|a-b| = 1) — is what drives the ratio toward √2. This is the property we formally prove, along with the fact that the correct ratio formula is c/max = √(2 - 2/max + 1/max²) where max = max(a,b).

### Proof Architecture (15 lemmas)

- **Berggren algebra**: `berggren_B_diff` (sign reversal), `berggren_B_pyth` (Pythagorean preservation), `berggren_B_pos` (positivity), `berggren_B_coprime` (coprimality preservation via prime divisor argument with parity)
- **Strict bound**: `abs_ne_of_primitive` (|a|≠|b| from c²=2 having no integer solution), `ratio_lt_sqrt_two` (main bound)
- **Iteration properties**: `berggren_iter_pos/pyth/coprime/diff/primitive` (by induction)
- **LUB**: `berggren_iter_max_ge` (linear growth), `consecutive_csq` (c²=2M²-2M+1), `isLUB_ratio_sqrt_two` (via filter-based convergence to √2)
- **Tropical**: `tropical_defect_bound` (log monotonicity)

## Python Demonstrations

- **`demos/pythagorean_bound_demo.py`**: Generates 1593 primitive triples, verifies all ratios < √2, shows the Berggren B sequence converging to √2 (gap ~7.6×10⁻¹⁰ after 11 iterations), verifies key algebraic properties, and produces 4-panel visualization.

- **`demos/applications.py`**: Four practical applications — exact integer rotations (CORDIC), lattice shortest vector bounds, rational approximation of √2 via Pell numbers, and tropical optimization bounds.

## Research Paper

**`paper/pythagorean_bound_paper.md`**: Full mathematical paper with abstract, proof details, connection to Pell equations, tropical geometry discussion, Scientific American-style accessibility section ("How close to isosceles can integer right triangles get?"), applications, and correction note.

## Key Mathematical Insight

The proof is surprisingly elementary: the bound c/max < √2 follows from just two facts: (1) for primitive triples, |a| ≠ |b| (because c² = 2 has no integer solutions), and (2) distinct values satisfy min² < max², giving a² + b² < 2·max². The sharpness via IsLUB = √2 is deeper, requiring the Berggren B iteration to construct consecutive-leg triples approaching √2 through the Pell equation connection.