# Future Directions

Building on `Catalog/Algebra/FibonacciDivisibility.lean` (the Fibonacci gcd / coprimality /
rank-of-apparition package), several natural extensions remain.

## 1. Lucas sequences and general strong divisibility sequences

The entire package is driven by exactly two abstract facts: that `Nat.fib` is a *strong
divisibility sequence* (`gcd (a_m) (a_n) = a_(gcd m n)`) and that `a_(k+2) = a_k + a_(k+1)` makes the
shift map reversible mod `m`. Generalise the development to a typeclass / structure
`IsStrongDivSeq (a : ℕ → ℕ)` capturing the gcd identity, and re-derive the coprimality criterion,
the rank of apparition, the spine `m ∣ a_n ↔ rank m ∣ n`, and the lattice law abstractly. Concrete
instances: Lucas sequences `U_n(P, Q)` with `gcd(P, Q) = 1`, repunits `(b^n - 1)/(b - 1)`, and
`b^n - 1`. This turns the Fibonacci-specific results into corollaries of one reusable theory.

## 2. Sharp value of the rank: rank of prime powers and the Wall–Sun–Sun question

Extend `fibRank` from the lattice law to the *arithmetic* of ranks. Prove the prime-power lifting
law `fibRank (p^e) = p^(e-1) * fibRank p` for `p` not a Wall–Sun–Sun prime, and formalise the
statement of the Wall–Sun–Sun condition `fibRank (p^2) = fibRank p`. Combined with `fibRank_mul_coprime`
this gives a complete formula for `fibRank` on any factored modulus.

## 3. Pisano periods and the period–rank relationship

The existence proof already constructs the orbit of the Fibonacci shift over `ZMod m`. Promote this
to a formal theory of the **Pisano period** `pisano m` (the order of `fibStep m` restricted to the
orbit of `(0,1)`), prove `fibRank m ∣ pisano m`, and develop the multiplicative structure
`pisano (lcm a b) = lcm (pisano a) (pisano b)` paralleling `fibRank_lcm`.

## 4. Carmichael's primitive divisor theorem

The catalog contains partial primitive-divisor results. Using the spine `fibRank_dvd_iff`, formalise
Carmichael's theorem in full: every `F n` with `n ∉ {1, 2, 6, 12}` has a primitive prime divisor
(a prime `q` with `fibRank q = n`). The prime-index case follows quickly from the spine; the
composite case needs cyclotomic / growth estimates that would be valuable Mathlib contributions.

## 5. Integer and matrix formulations

Lift the divisibility package from `Nat.fib` to `Int.fib` and to the matrix model
`![![1,1],![1,0]]^n`, where the gcd identity becomes a statement about the determinant-one shift over
`ZMod m`. This connects the elementary arithmetic here to the linear-algebraic Pisano theory and
would let the coprimality criterion be stated over `ℤ` and `ZMod m` directly.
