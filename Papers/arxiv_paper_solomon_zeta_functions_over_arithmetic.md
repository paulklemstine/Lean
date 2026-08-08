# Computational evidence

All formulas below were first checked by hand on small cases; the items marked
**[Lean]** are additionally machine-verified as theorems in `Catalog/Shared/SolomonZeta/`
(built with Lean 4.28.0 / Mathlib, no `sorry`, only the standard axioms
`propext`, `Classical.choice`, `Quot.sound`).

## 1. The counting identity being formalized

For a finitely generated module `M` over a ring `R` and a finite `R`-module `X`:

```
#Aut(X) · #{N ≤ M : M/N ≅ X}  =  Σ_{Y ≤ X} μ(Y, X) · #Hom(M, Y)          [Lean]
```

The right-hand side is the "Möbius polynomial" weight; for `M = Rⁿ` it becomes
`Σ_{Y ≤ X} μ(Y, X) · |Y|ⁿ`. **[Lean]**

## 2. Small cases: free lattices over `ℤ`, cyclic quotient of prime order

`X = ℤ/p` is simple, so its submodule poset is `{⊥, ⊤}`, `μ(⊥, ⊤) = -1`, and

```
(p − 1) · #{N ≤ ℤⁿ : ℤⁿ/N ≅ ℤ/p} = pⁿ − 1,   i.e.  count = 1 + p + ⋯ + p^{n−1}    [Lean]
```

| n | p | predicted count | classical value (points of ℙ^{n−1}(𝔽_p)) |
|---|---|-----------------|-------------------------------------------|
| 1 | 2 | 1               | 1                                          |
| 2 | 2 | 3               | 3                                          |
| 3 | 2 | 7               | 7  **[Lean]** (`quotIsoCount_rank_three_two`) |
| 2 | 3 | 4               | 4  **[Lean]** (`quotIsoCount_rank_two_three`) |
| 3 | 3 | 13              | 13                                         |

These are the Gaussian binomial coefficients `[n choose 1]_p`; the sequence
`1, 3, 7, 15, …` for `p = 2` is A000225 (`2ⁿ − 1`), and `1, 4, 13, 40, …` for `p = 3`
is A003462 (`(3ⁿ − 1)/2`).

## 3. Rank one lattice: `ζ_ℤ(s) = ζ(s)`

Every index `k ≥ 1` is realized by exactly one sublattice `kℤ ≤ ℤ`, so all Solomon
coefficients of the rank one lattice equal `1`. **[Lean]**
(`indexCount_int_eq_one`, `quotIsoCount_int_zmod`).

## 4. A Möbius computation on the subgroup lattice of `(ℤ/p)²`

The lattice has `⊥`, `p + 1` lines, and `⊤`, hence

```
μ(⊤, ⊤) = 1,   μ(line, ⊤) = −1,   μ(⊥, ⊤) = −(1 − (p+1)) = p.
```

Therefore, with `|⊤| = p²`, `|line| = p`, `|⊥| = 1`:

* `n = 1`:  `p² · 1 + (p+1)·p·(−1) + 1·p = p² − p² − p + p = 0`. This vanishing is *forced*:
  `ℤ` cannot surject onto `(ℤ/p)²`. **[Lean]** (`mobius_identity_zmod_sq`).
* `n = 2`:  `p⁴ − (p+1)p² + p = p⁴ − p³ − p² + p = (p²−1)(p²−p) = #GL₂(𝔽_p)`, matching
  `#Aut((ℤ/p)²) · #{N ≤ ℤ² : ℤ²/N ≅ (ℤ/p)²} = #GL₂(𝔽_p) · 1` — the unique such sublattice
  is `pℤ²`. **[Lean]** (`quotIsoCount_elementaryAbelian_two`, and the uniqueness statement
  `quotIsoCount_elementaryAbelian_self`).
* General `d`: `#GL_d(𝔽_p) · #{N ≤ ℤⁿ : ℤⁿ/N ≅ (ℤ/p)^d} = ∏_{i<d}(pⁿ − p^i)` **[Lean]**
  (`card_GL_mul_quotIsoCount_elementaryAbelian`), i.e. the counts are the Gaussian binomials
  `[n choose d]_p`; for `p = 2, d = 2` these are `1, 7, 35, 155, …` (A006095).

## 5. Cyclic quotients of prime power order

For `X = ℤ/p^e` the submodule poset is a chain of length `e + 1`, so `μ(Y, ⊤)` is `1` at
`⊤`, `−1` at the coatom and `0` elsewhere, giving

```
φ(p^e) · #{N ≤ ℤⁿ : ℤⁿ/N ≅ ℤ/p^e} = p^{en} − p^{(e−1)n}.
```

Check `e = 2, n = 2, p = 2`: LHS weight `2⁴ − 2² = 12`, `φ(4) = 2`, count `= 6`. Indeed the
sublattices of `ℤ²` of index `4` number `σ(4) = 7`, of which one (namely `2ℤ²`) has quotient
`(ℤ/2)²`, leaving `6` with cyclic quotient `ℤ/4`. ✓ Consistent.

**[Lean]** (`totient_mul_quotIsoCount_zmod_prime_pow`).  The general modulus is also verified:
`φ(m)·#{N ≤ ℤⁿ : ℤⁿ/N ≅ ℤ/m} = Σ_{d ∣ m} μ(d)(m/d)ⁿ = J_n(m)`, the Jordan totient **[Lean]**
(`totient_mul_quotIsoCount_zmod_eq_jordan`).  Check `m = 6, n = 2`: `J_2(6) = 36−9−4+1 = 24`,
`φ(6) = 2`, count `= 12 = σ(6)` — every index six sublattice of `ℤ²` has cyclic quotient.
✓ **[Lean]** (`quotIsoCount_rank_two_six`).  The sequence `J_2(m)` for `m = 1, 2, 3, …` is
`1, 3, 8, 12, 24, 24, 48, …` (A007434).

## 6. Euler factorization (multiplicativity)

For distinct primes `p ≠ q`,

```
#Aut(ℤ/p × ℤ/q) · #{N ≤ ℤⁿ : ℤⁿ/N ≅ ℤ/p × ℤ/q} = (pⁿ − 1)(qⁿ − 1)                  [Lean]
```

Check `n = 1, p = 2, q = 3`: RHS `= 1·2 = 2`, and `#Aut(ℤ/6) = φ(6) = 2`, so the count is `1`
— the unique index 6 subgroup `6ℤ ≤ ℤ`. ✓ Consistent with §3.

## 7. The local (Nakayama) collapse

For a commutative local ring `R` with finite residue field `k`, `q = #k`, and a finite
`R`-module `X` with `d = dim_k X/𝔪X`:

```
#Aut(X) · #{N ≤ Rⁿ : Rⁿ/N ≅ X} = (∏_{i<d}(qⁿ − q^i)) · #(𝔪X)ⁿ                      [Lean]
```

(`mobiusWeight_free_local`, `autCard_mul_quotIsoCount_free_local`; the `ℤ_p` case is
`autCard_mul_quotIsoCount_padic_free`).

Consistency checks against the earlier sections:

| `R` | `X` | `q` | `d` | `#𝔪X` | formula | matches |
|-----|-----|-----|-----|--------|---------|---------|
| `ℤ/pᵉ` | `ℤ/pᵉ` | `p` | `1` | `p^{e−1}` | `p^{(e−1)n}(pⁿ−1) = p^{en} − p^{(e−1)n}` | §5 |
| `ℤ_p` | `(ℤ/p)^d` | `p` | `d` | `1` | `∏_{i<d}(qⁿ − q^i)` | §4 |
| `ℤ_p` | `0` | `p` | `0` | `1` | empty product `= 1` | the zero module is a quotient once |

The middle row is an instance of the machine-verified
`autCard_mul_quotIsoCount_padic_free_of_smul_eq_bot`, which is stated for an arbitrary finite
`ℤ_p`-module `X` with `pX = 0`.

## 8. Hall's formula (arbitrary finite abelian `p`-groups)

```
#Aut(X) · #{N ≤ ℤⁿ : ℤⁿ/N ≅ X} = (∏_{i<d}(pⁿ − p^i)) · #(pX)ⁿ,   d = dim_{𝔽_p} X/pX   [Lean]
```

(`autCard_mul_quotIsoCount_pGroup`, for any finite abelian `X` annihilated by `pᵉ`).

| `X` | `#pX` | `d` | formula | matches |
|-----|-------|-----|---------|---------|
| `ℤ/p` | `1` | `1` | `pⁿ − 1` | §2 |
| `ℤ/pᵉ` | `p^{e−1}` | `1` | `p^{(e−1)n}(pⁿ−1) = p^{en} − p^{(e−1)n}` | §5 |
| `(ℤ/p)^d` | `1` | `d` | `∏_{i<d}(pⁿ − p^i)` | §4 |
| `ℤ/4 × ℤ/2` | `2` | `2` | `2ⁿ(2ⁿ−1)(2ⁿ−2)` | `n = 2`: `4·3·2 = 24`, and `#Aut = 8`, so the count is `3` — the three sublattices of `ℤ²` with quotient `ℤ/4 × ℤ/2` ✓ |
