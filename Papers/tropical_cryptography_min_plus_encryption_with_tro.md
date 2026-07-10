# Computational Evidence: Tropical Matrix Powers, Walks, and Eigenvalues

All statements below are *proved* in `Catalog/Tropical/TropicalCryptoConnector.lean`.
This note records the small-case computations that motivated them.

The tropical (min-plus) semiring `Tropical (WithTop ℤ)` uses `min` for `+` and
integer `+` for `*`. The multiplicative unit is `trop 0` and the additive unit
is `trop ⊤ = ∞`.

## 1. Matrix power = shortest walk weight (`Matrix.pow_apply_eq_sum_path`)

Take the min-plus matrix
```
A = | 1  3 |
    | 2  0 |
```
The tropical product `(A ⊗ A)_{ij} = min_k (A_{ik} + A_{kj})`:

| entry | candidates (2-step walks i→k→j) | min |
|-------|----------------------------------|-----|
| (0,0) | 0→0→0: 1+1=2, 0→1→0: 3+2=5       | **2** |
| (0,1) | 0→0→1: 1+3=4, 0→1→1: 3+0=3       | **3** |
| (1,0) | 1→0→0: 2+1=3, 1→1→0: 0+2=2       | **2** |
| (1,1) | 1→0→1: 2+3=5, 1→1→1: 0+0=0       | **0** |

So
```
A^{⊗2} = | 2  3 |
         | 2  0 |
```
Each entry `(A^{⊗2})_{ij}` is exactly the **minimum total weight of a 2-step
walk** from `i` to `j`. The theorem `Matrix.pow_apply_eq_sum_path` proves the
general identity (over any commutative semiring)
```
(A^k)_{ij} = Σ_{walks p: i→…→j of length k}  Π_t A_{p_t, p_{t+1}} ,
```
which under `Σ = min`, `Π = +` is the Bellman/Floyd shortest-walk recursion.
This is the algebra ↔ combinatorial-optimization bridge, and it is exactly the
"shortest-path attack" surface for the tropical discrete logarithm problem.

## 2. Tropical eigenvalues are additive (`tropical_eigenvalue_additive`)

An eigenpair `A ⊗ v = λ ⊗ v` (scalar `λ`, i.e. `A *ᵥ v = λ • v`) satisfies
```
A^{⊗k} ⊗ v = λ^{⊗k} ⊗ v ,   with   untrop(λ^{⊗k}) = k · untrop(λ).
```
Example: `λ = trop 5` gives `untrop(λ^{⊗3}) = 3·5 = 15`. So the min-plus
eigenvalue scales *linearly* with the power `k`.

**Cryptographic consequence.** The tropical Diffie–Hellman proposal publishes
`B = A^{⊗k}` and asks the adversary to recover `k` (the TDLP). Additivity turns
the multiplicative problem into a *linear* one:
```
k = untrop(λ(B)) / untrop(λ(A))     (whenever untrop(λ(A)) ≠ 0).
```
This is precisely why min-plus matrix powering is **not** a one-way function in
general — the eigenvalue is a cheap linear invariant that leaks `k`. Our formal
proof isolates the exact algebraic identity responsible.

## 3. Counterexample hunt

No counterexamples were sought for the main theorems because they are
*equalities* proved for all inputs, not universal conjectures over a search
space. The relevant "counterexample" content is negative *for cryptography*:
the additivity identity in §2 is itself the obstruction to security, and it
holds unconditionally. The `untrop(λ(A)) = 0` degenerate case (where the linear
attack fails to determine `k`) is faithfully reflected by the division
condition above.

## 4. OEIS

No integer sequence is central to these results (they are structural identities
over an arbitrary index set / semiring), so no OEIS entry applies.
