# Computational Evidence — Non-Existence of New Factorial Square Solutions

All checks performed in Lean (`#eval`) prior to formalization.

## H1. `n! · (n+1)!` is a perfect square ⟺ `n+1` is a perfect square
`(n, IsSquare (n!·(n+1)!), IsSquare (n+1))` for `n = 0..11`:
```
(0,T,T)(1,F,F)(2,F,F)(3,T,T)(4,F,F)(5,F,F)(6,F,F)(7,F,F)(8,T,T)(9,F,F)(10,F,F)(11,F,F)
```
Exact agreement. Reason: `n!·(n+1)! = (n!)² · (n+1)`, and `(n!)²·b` is square iff `b` is.

## H2. `n!` is never a perfect power for `n ≥ 2`
Confirmed `n!` is never a square (catalog `FactorialNotSquare`) and the same Bertrand
prime `p` with `n/2 < p ≤ n` has `v_p(n!) = 1`, blocking every exponent `k ≥ 2`.

## H3. Brocard structural invariant: `m ≡ ±1 (mod p)` for every prime `p ≤ n`
For the three Brown numbers `(n,m) = (4,5),(5,11),(7,71)`, the residues `m mod p`
over primes `p ≤ n`:
```
(4, [(2,1),(3,2)])
(5, [(2,1),(3,2),(5,1)])
(7, [(2,1),(3,2),(5,1),(7,1)])
```
Every residue is `1` or `p-1`, confirming `p ∣ (m-1)(m+1)` for each prime `p ≤ n`.
This follows from `m² = n!+1 ≡ 1 (mod p)` since `p ∣ n!`.

## OEIS
Brown numbers `4,5,7` (Brocard solutions): A085692 / A146968. Squares `n+1`: A000290.
