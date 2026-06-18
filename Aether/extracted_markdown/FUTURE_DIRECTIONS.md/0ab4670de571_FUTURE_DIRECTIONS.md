# Future Directions — The Pisano Period as a Group Order (Duality & Representation)

## Synthesis

This cycle re-cast the **Pisano period** `π(m)` — the period of the Fibonacci
sequence modulo `m` — not as an analytic property of a sequence but as the
**order of a single group element**: the Fibonacci shift `Q : (a,b) ↦ (b, a+b)`
acting as a permutation of the finite set `ZMod m × ZMod m`. The new file
`Catalog/Novelty/FibonacciPisanoRepresentation.lean` makes this dictionary precise:

* `fibStep_iterate` — the Fibonacci sequence mod `m` *is* the forward orbit of `(0,1)`
  under `Q` (the representation theorem). The closed form `fibStep_iterate_apply`
  exhibits `Qᵏ` as the classical Fibonacci `Q`-matrix `[[F(k-1),F k],[F k,F(k+1)]]`.
* `pisanoPeriod m := orderOf (fibStep m)`, with `pisanoPeriod_pos` (existence) a one-line
  consequence of finiteness of the permutation group.
* `pisano_dvd_iff` — the **period–return duality**: `π(m) ∣ k ↔ (F k ≡ 0 ∧ F(k+1) ≡ 1) mod m`.
  Algebraic divisibility on one side, dynamical "return to seed" on the other.
* `fib_pisano_periodic` — periodicity, derived purely from `Qᵖ = 1`.
* `dvd_fib_pisanoPeriod` — `m ∣ F(π m)`, so `π(m)` is an apparition index; combined with the
  catalog law `FibApparition.fib_dvd_iff_apparitionRank_dvd` this yields `z(m) ∣ π(m)`,
  bridging this file to the entry-point theory.
* `pisano_mul_coprime` — the **Chinese-Remainder / spectral decomposition**
  `π(mn) = lcm(π m, π n)` for coprime `m, n`: the product dynamical system factors as a
  product of components, mirroring the entry point's lcm law
  `FibEntryChar.fibEntryPt_prod_coprime`.

The unifying message: the *entry point* `z(m)` is the order of `Q` acting on the cyclic
*line* through `(0,1)`, while the *Pisano period* `π(m)` is the order of `Q` on the whole
*plane* `(ZMod m)²`. Both are orders of one representation; their lcm-multiplicativity is
the same CRT fact applied to two orbits.

## Results Summary

All theorems are proved with no `sorry` and depend only on the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`). The Fibonacci-specific content is fully
localized in one induction (`fibStep_iterate_apply`); every period statement afterwards is
generic `orderOf` algebra plus elementary `ℕ` divisibility.

## Research Directions

### 1. The exact entry-point / Pisano ratio `π(m) / z(m) ∈ {1, 2, 4}`

We proved `z(m) ∣ π(m)`. The classical theory asserts the quotient `π(m)/z(m)` is always
**1, 2, or 4** (it equals the multiplicative order of `(-1)^{z(m)} F(z(m)-1)` etc.).
**The key insight is** that `Qᵏ = 1` forces `F k ≡ 0, F(k+1) ≡ 1`, whereas `Q` killing the
*line* `(0,1)` only forces `F k ≡ 0`; the obstruction is exactly the scalar `Q^{z}` acts by
on that line, an element of `(ZMod m)ˣ` whose order is the ratio. So the ratio is the order
of a single unit — bounded once one shows `(Q^{z})² ` or `(Q^z)⁴` is scalar `1`.
**Why now?** The closed-form `fibStep_iterate_apply` already expresses `Q^z` as an explicit
matrix; reading off its action on `(0,1)` reduces the conjecture to computing the order of a
concrete unit, with no new infrastructure needed.

### 2. Spectral formula for `π(p)` via the golden ratio in `𝔽_p` and `𝔽_{p²}`

For a prime `p ≠ 5`, `π(p)` should equal the multiplicative order of the **eigenvalues** of
`Q` (the roots `φ, ψ` of `x² = x + 1`) in `𝔽_p` (when `5` is a QR mod `p`) or in `𝔽_{p²}`
(when it is not). **The key insight is** that `Q` is diagonalizable over the splitting field
of `x²-x-1`, so `orderOf Q = lcm(ord φ, ord ψ) = ord φ` (since `φψ = -1`), turning the period
into a genuine *spectral* invariant. **Why now?** Our `pisanoPeriod = orderOf (fibStep m)`
definition is precisely the object whose eigenvalue-order formula this would be; Mathlib has
`ZMod p` field structure and quadratic-residue API, so the QR-split case is immediately
attackable, and the `𝔽_{p²}` case needs only `Polynomial.SplittingField`.

### 3. Prime-power lifting: `π(pᵉ) = pᵉ⁻¹ · π(p)` unless `p` is a Wall–Sun–Sun prime

Beyond coprime multiplicativity (proved here), the remaining structural law is the
prime-power growth `π(pᵉ⁺¹) = p · π(pᵉ)` for `e ≥ 1`. **The key insight is** that lifting
`Qᵖ⁽ᵐ⁾ = 1 (mod pᵉ)` to mod `pᵉ⁺¹` is governed by the `p`-adic valuation of `F(π(pᵉ))`,
which is exactly the Lifting-the-Exponent content already in the catalog
(`Tropical_p_adic_Valuation_Bounds_and_Lifting_the_Exponent_for_Fibonacci_Primitive_Divisors`).
A counterexample at `e=1` is, by definition, a **Wall–Sun–Sun prime** — a famously open
search. **Why now?** Combining `pisano_mul_coprime` (coprime part) with an LTE-based
prime-power lemma would yield a *complete* formula for `π(m)` from `π(p)` on primes, the
exact analogue of `fibEntryPt_prod_coprime`, and would formalize the precise statement whose
failure defines Wall–Sun–Sun primes.

### 4. A general "linear-recurrence period = group order" functor

`fibStep` is the companion matrix of `x² - x - 1`. **The key insight is** that *nothing*
in this file used the Fibonacci coefficients beyond the recurrence `F(k+2)=F k+F(k+1)`: for
any monic `f ∈ ℤ[x]` of degree `d` with invertible constant term, its companion matrix `C_f`
is a unit in `GL_d(ZMod m)`, and the period of the associated linear recurrence is
`orderOf C_f`. **Why now?** Re-stating `fibStep`, `fibStep_iterate_apply`, `pisano_dvd_iff`
and `pisano_mul_coprime` over an arbitrary companion matrix would subsume the entire
Pisano/entry-point catalog under one representation-theoretic head and connect directly to
Mathlib's `Matrix.charpoly` / `LinearRecurrence` API — generalization with essentially the
same proofs.

### 5. The dual pairing: period of `m` vs. period of the dual modulus and reciprocity

View `Q` and its inverse-transpose `Q⁻ᵀ` as a duality pairing on `(ZMod m)²`. **The key
insight is** that `Q` is conjugate to `Q⁻¹` (Fibonacci is a *symmetric* recurrence, `det Q =
-1`), so the orbit structure forward and backward in time coincide up to the involution
`(a,b) ↦ (b,-a)`; this predicts a clean **reciprocity** between `π(m)` and the period of the
*Lucas* companion action, refining the catalog's `FibonacciLucasBridge`. **Why now?** With
`pisano_dvd_iff` giving an exact algebraic certificate for the period, testing whether the
Lucas period satisfies the dual divisibility `π_L(m) ∣ k ↔ (L k ≡ 2 ∧ L(k+1) ≡ 1)` is a
direct, falsifiable computation, and a proof would unify the two companion sequences as dual
representations of the same group element.
