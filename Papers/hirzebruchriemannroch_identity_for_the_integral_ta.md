# Computational Evidence

Target: the `P^K = Hilb` identity for the Boolean matroid `B_n`, realised through
the Eulerian numbers `⟨n,k⟩` (the graded Betti numbers / Hilbert function of the
Chow ring `A*(B_n)` of the permutohedral toric variety).

All checks below were run in Lean with `#eval` on the recursive definition

```
eulerian 0 0 = 1,  eulerian 0 (k+1) = 0,  eulerian (n+1) 0 = 1,
eulerian (n+1) (k+1) = (k+2)·eulerian n (k+1) + (n-k)·eulerian n k.
```

## 1. The Eulerian triangle (Hilbert functions of `A*(B_n)`)

```
n=0: [1]
n=1: [1, 0]
n=2: [1, 1, 0]
n=3: [1, 4, 1, 0]
n=4: [1, 11, 11, 1, 0]
n=5: [1, 26, 66, 26, 1, 0]
```

These are the Eulerian numbers (OEIS **A008292**, triangle by rows
`1; 1,1; 1,4,1; 1,11,11,1; 1,26,66,26,1; …`).  Row `n` gives the graded Betti
numbers `dim A^0, …, dim A^{n-1}` of the Chow ring of `B_n`; the trailing `0`
is the (vanishing) coefficient in the auxiliary degree `n` used to pad the sums.

## 2. Total dimension = value of the Hilbert series at `t=1` = `n!`

```
(∑_k ⟨n,k⟩, n!)  for n = 0..6:
(1,1) (1,1) (2,2) (6,6) (24,24) (120,120) (720,720)   -- all equal
```

`dim_ℚ A*(B_n) = n!` — the number of maximal cones of the permutohedral fan
(OEIS **A000142**).  Verified `eulerian_row_sum`.

## 3. Poincaré duality (palindromicity of the Hilbert series)

For every `n ≤ 5` and every `k < n`:  `⟨n,k⟩ = ⟨n, n-1-k⟩` returned `true`.
This is Poincaré duality of the `(n-1)`-dimensional Chow ring.  Verified
`eulerian_symm`.

## 4. Worpitzky's identity (Riemann–Roch bridge)

For all `n ≤ 4` and `m ≤ 5`:
`m^n = ∑_k ⟨n,k⟩ · C(m+k, n)` returned `true`.
Left side = lattice-point / Euler-characteristic count `χ(X_n, L^m)`; right side
carries the Hilbert (Betti) coefficients.  Verified `worpitzky`.

## 5. The alternating Euler-characteristic (K-theoretic) formula — `P^K = Hilb`

For all `n ≤ 4` and `k < n`, over `ℤ`:
`⟨n,k⟩ = ∑_{j=0}^{k} (-1)^j · C(n+1,j) · (k+1-j)^n` returned `true`.

The right-hand side is a manifestly *alternating* sum — an Euler characteristic
in the K-theory of the permutohedral variety — while the left-hand side is a
*nonnegative dimension* (a Hilbert-series coefficient).  Their equality is the
`P^K = Hilb` identity in this case.  Verified `eulerian_explicit` and packaged as
the polynomial identity `tangentKPoly_eq_hilbChow`.

## Counterexample hunt

No counterexamples were found in any of the ranges above.  The identities are
classical theorems for the Eulerian numbers, and are proved in full generality
(all `n, k, m`) in `Novelty/HRRMatroidBoolean.lean` — the finite `#eval` checks
are only sanity confirmation.
