# Computational Evidence

Small-case numerical checks carried out before/while formalizing the universal
coefficient sequence in `Catalog/Bridges/UniversalCoefficientSequence.lean`.
All numbers below were produced by `#eval` in Lean 4 (Mathlib), not by hand.

## 1. The two edge terms of the universal coefficient sequence

Take the projective presentation

```
ℤ --·n--> ℤ --> ℤ/n --> 0
```

so `A = ℤ/n`, `P₁ = P₀ = ℤ`, and `i = ·n`.  Let `K` be a complex whose relevant
homology groups are `ℤ/m`.  The theorem
`Catalog.Bridges.UCT.universal_coefficient_theorem` then predicts

```
|[Q, K]|  =  |Ext¹(ℤ/n, ℤ/m)| · |Hom(ℤ/n, ℤ/m)|
```

with `Hom(ℤ/n, ℤ/m) = ker(·n : ℤ/m → ℤ/m)` and
`Ext¹(ℤ/n, ℤ/m) = coker(·n : ℤ/m → ℤ/m)`.

The following table was computed in Lean with

```lean
def kerCard (n m : ℕ) [NeZero m] : ℕ :=
  ((univ : Finset (ZMod m)).filter (fun x => (n : ZMod m) * x = 0)).card
def imCard (n m : ℕ) [NeZero m] : ℕ :=
  ((univ : Finset (ZMod m)).image (fun x => (n : ZMod m) * x)).card
```

| `n` | `m` | `gcd(n,m)` | `\|ker(·n)\|` = `\|Hom\|` | `\|coker(·n)\|` = `\|Ext¹\|` | predicted `\|[Q,K]\|` |
|----|----|----|----|----|----|
| 2 | 2 | 2 | 2 | 2 | 4 |
| 2 | 4 | 2 | 2 | 2 | 4 |
| 3 | 6 | 3 | 3 | 3 | 9 |
| 4 | 6 | 2 | 2 | 2 | 4 |
| 6 | 4 | 2 | 2 | 2 | 4 |
| 5 | 15 | 5 | 5 | 5 | 25 |
| 12 | 18 | 6 | 6 | 6 | 36 |

Both edge terms come out equal to `gcd(n,m)` in every case, matching the classical
computation `Hom(ℤ/n, ℤ/m) ≅ Ext¹(ℤ/n, ℤ/m) ≅ ℤ/gcd(n,m)`.  This is the sequence
of gcd's, i.e. OEIS A050873 read as a table; no new sequence appears.

## 2. Counterexample hunt: is the Ext term really needed?

The naive statement "`[Q, K] ≅ Hom(A, H_{j₀}K)`" (no `Ext¹` correction) is false
whenever the `Ext¹` term above is nonzero, which the table shows already for
`n = m = 2`.  This is *not* left at the level of numerics: the companion file
`Catalog/Bridges/UniversalCoefficients.lean` contains a fully proved
counterexample in the dual (Tor) direction,
`Catalog.Bridges.tor_correction_term_necessary`: the complex `ℤ --·2--> ℤ` is
exact in degree 1, but `ℤ/2 ⊗ -` applied to it is not.  Hence no naive
coefficient isomorphism can exist
(`Catalog.Bridges.no_naive_universal_coefficient_iso`).

## 3. Degenerate / boundary cases probed before formalizing

* `m = 1` (zero coefficients): both edge terms are trivial, sequence degenerates
  to `0 → 0 → 0`; the Lean statement is still meaningful (all three groups are
  zero) and not vacuous.
* `gcd(n,m) = 1` (e.g. `n = 2, m = 3`): both edge terms vanish, so `[Q,K] = 0`.
  This is the case that made it clear the theorem must be stated as exactness of
  a four-term sequence rather than as a splitting: the Lean statement asserts
  exactness only, since the classical splitting is unnatural and needs extra
  hypotheses.
* `j₁ = j₀`: excluded by the hypothesis `hne : j₁ ≠ j₀`.  Mathlib's
  `HomologicalComplex.double` collapses in that case, so the hypothesis is
  genuinely needed rather than cosmetic.
* Shapes with no differential into `j₁` (so `c.prev j₁ = j₁` and
  `K.d (c.prev j₁) j₁ = 0`): handled uniformly in the Lean proof by guarding the
  homotopy's only nonzero component with `c.Rel`, which was the one place where
  the naive construction failed to satisfy the `Homotopy.zero` axiom.

## Scope of this evidence

The numerics above are exploratory: they justify the *shape* of the statement
(which groups appear and that the correction term cannot be dropped).  The
mathematical content itself is established by the machine-checked proofs in
`Catalog/Bridges/`, all of which compile with 0 `sorry`s and depend only on
`propext`, `Classical.choice` and `Quot.sound`.
