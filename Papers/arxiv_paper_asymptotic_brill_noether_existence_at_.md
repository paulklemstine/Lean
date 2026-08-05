# Computational evidence

Exploratory (non-verified) computations carried out before formalisation, on small
graphs, in exact/floating-point Python.  They are *not* part of the Lean development;
the Lean theorems in `Catalog/Pythagorean/BrillNoether/` are proved for arbitrary
finite graphs.

## 1. Basic invariants

`genus = m - n + 1`, canonical divisor `K(v) = deg(v) - 2`, `λ₂` = second smallest
Laplacian eigenvalue (Jacobi method).

| graph      | n | m  | genus g | deg K | 2g − 2 | λ₂     |
|------------|---|----|---------|-------|--------|--------|
| P₄ (path)  | 4 | 3  | 0       | −2    | −2     | 0.5858 |
| C₄ (cycle) | 4 | 4  | 1       | 0     | 0      | 2.0000 |
| K₄         | 4 | 6  | 3       | 4     | 4      | 4.0000 |
| C₅         | 5 | 5  | 1       | 0     | 0      | 1.3820 |
| K₅         | 5 | 10 | 6       | 10    | 10     | 5.0000 |
| K₃,₃       | 6 | 9  | 4       | 6     | 6      | 3.0000 |

`deg K = 2g − 2` holds in every case; this identity is proved in Lean as
`BrillNoetherDivisor.deg_canonical`.

## 2. Cheeger inequality (easy direction), all vertex subsets

Checked `λ₂ · |S| · |Sᶜ| ≤ n · cut(S)` for every subset `S`; reported is the smallest
slack `n·cut(S) − λ₂|S||Sᶜ|`.

| graph | min slack | attained at |
|-------|-----------|-------------|
| P₄    | 1.6569    | S = {0,1}   |
| C₄    | 0.0000    | S = {0,1}   |
| K₄    | 0.0000    | S = {0}     |
| C₅    | 1.7082    | S = {0,1}   |
| K₅    | 0.0000    | S = {0}     |
| K₃,₃  | 0.0000    | S = {0,3}   |

No violation; the inequality is tight for `C₄`, `Kₙ` and `K₃,₃`.  Formalised as
`BrillNoetherEnergy.spectralGap_mul_le_cut`.

## 3. Covering radius bound

For each subset `S` we took the explicit witness `y = c·1_S` with `c = n/(2|S||Sᶜ|)`
used in the Lean proof, and searched all lattice points `L f`, `f ∈ {−2,…,2}^{n−1}`
(`f` normalised to vanish at the last vertex, since `L` kills constants), checking

    n · λ₂ ≤ 4 · |S| · |Sᶜ| · E(y − L f).

| graph | min (rhs − lhs) | minimiser |
|-------|-----------------|-----------|
| P₄    | 1.6569          | S = {0,1}, f = 0 |
| C₄    | 0.0000          | S = {0,1}, f = 0 |
| K₄    | 0.0000          | S = {0},   f = 0 |
| C₅    | 1.4235          | S = {0,1}, f = 0 |
| K₅    | 0.0000          | S = {0},   f = 0 |
| K₃,₃  | 0.0000          | S = {0,3}, f = 0 |

No violation, and the bound is attained for `C₄`, `Kₙ`, `K₃,₃`.  Formalised as
`BrillNoetherEnergy.exists_far_from_lapLattice`.

## 4. Baker–Norine ranks at the half-canonical degree

Ranks computed by brute force (linear equivalence tested by searching firing vectors
`f ∈ {−3,…,3}^{n−1}`, divisors enumerated with entries in `[−1, g]`).

| graph | g | d = g−1 | max rank found | BN prediction ⌊√g⌋−1 | proved bound ⌊d/n⌋ |
|-------|---|---------|----------------|----------------------|--------------------|
| C₄    | 1 | 0       | 0              | 0                    | 0                  |
| K₄    | 3 | 2       | 0              | 0                    | 0                  |
| K₃,₃  | 4 | 3       | 1              | 1                    | 0                  |
| K₅    | 6 | 5       | 2              | 1                    | 1                  |

This quantifies the gap the paper is concerned with: the unconditional "diagonal"
bound `⌊d/n⌋` proved in `exists_divisor_deg_rankAtLeast` is of the right order only
when the graph is dense, whereas the conjecture asks for `≈ √g`.  Under a covering
radius hypothesis the stronger bound of `rankAtLeast_of_covering` applies.

## 5. OEIS

No new integer sequence arose; the sequences appearing (`2g − 2`, numbers of spanning
trees of `Kₙ`) are classical and were not the object of formalisation.
