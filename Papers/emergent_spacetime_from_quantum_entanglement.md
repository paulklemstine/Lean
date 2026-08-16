# Computational evidence

All computations below were run *before* the corresponding Lean proofs, to test
whether the conjectured recombination rules were true at all. Every claim that
ended up in the formal development is now backed by a machine-checked Lean proof
(0 `sorry`s); the tables here record the exploratory stage.

## 1. Monogamy: which recombination of three cuts works?

For three bulk regions with membership patterns `a = (a₁,a₂,a₃)`, `b = (b₁,b₂,b₃)`
at two bulk cells, we asked whether

```
Σⱼ sep(χⱼ(a), χⱼ(b))  ≤  Σᵢ sep(aᵢ, bᵢ)
```

holds pointwise for two candidate rules.

| candidate rule for the four output regions | violations over the 64 patterns |
|---|---|
| pairwise intersections `a₁∧a₂, a₁∧a₃, a₂∧a₃` + union | **8** (first at `a=(1,1,1)`, `b=(0,0,0)`: LHS 3, RHS 4) |
| minority regions `a₁∧a₂∧¬a₃, a₁∧a₃∧¬a₂, a₂∧a₃∧¬a₁` + union | **0** |

Conclusion: the naive intersection recombination is *false*, the minority rule is
true. Both facts are now theorems: `sepBit_naive_mmi_fails` and `sepBit_mmi`
(the latter proved by exhaustive Boolean evaluation inside Lean).

## 2. Five-party cyclic inequality: search for a contraction map

We searched for a map `χ : {0,1}⁵ → {0,1}⁶` (five "pair" regions plus the union)
that is a Hamming contraction and has the prescribed boundary values

```
χ(pattern of a cell in A_k) = (indicator of j with k ∈ {j, j+1}, 1),   χ(∅) = 0.
```

* Unrestricted local search over the 26 free patterns: solution found (0 violated
  pairs out of `32 × 32 = 1024`).
* Search restricted to *cyclically equivariant* maps: solution found, given by
  the single Boolean rule

```
cyc c₀ c₁ c₂ c₃ c₄  =  c₄ ∧ ¬c₂ ∧ (c₀ ∨ (c₁ ∧ ¬c₃)),      χⱼ = cyc ∘ (rotation by j).
```

* Verification of that closed-form rule: **0 violations** over all 1024 pattern
  pairs, and all six boundary conditions reproduced exactly.

This rule is `EmergentGeometry.cyc`; the contraction property is the Lean theorem
`sepBit_cyclic5`, and the resulting entropy inequality is `entropy_cyclic5`.

## 3. Star versus triangle: entropies of two competing geometries

Three boundary cells, values of the min-cut entropy `S(A)` as a function of the
number `n` of boundary cells in `A`:

| n | star (hidden bulk cell, throat areas 1) | triangle (areas 1/2, no bulk cell) |
|---|---|---|
| 0 | 0 | 0 |
| 1 | min(1, 2) = 1 | 1·2·(1/2) = 1 |
| 2 | min(2, 1) = 1 | 1 |
| 3 | 0 | 0 |

The two entropy functions coincide although the geometries differ; this became
`star_tri_same_entropy` and `bulk_geometry_not_determined_by_entanglement`.

## 4. Sanity checks of the qubit dictionary

Evaluated inside Lean (`#eval`) for the definitions used in
`Novelty/EREPRQuantumBridge.lean`:

| state | marginal purity `Tr ρ²` | linear entropy | concurrence |
|---|---|---|---|
| Bell `(|00⟩+|11⟩)/√2` | 0.5000 | 1.0000 | 1.0000 |
| product `|00⟩` | 1 | 0 | 0 |

consistent with the theorem `linearEntropy_eq_concurrence_sq`.

## 5. Counterexample hunt against the main claims

* *Is bulk reconstruction always possible?* No — item 3 is an explicit
  counterexample, and it is formalised.
* *Does monogamy hold for all quantum entropy patterns?* No — the pattern
  "every nonempty marginal has entropy 1" (four-party GHZ) satisfies
  subadditivity and strong subadditivity on all `8 × 8` subset pairs but breaks
  monogamy (`3 < 4`). Formalised as `ghzVector_subadditive`,
  `ghzVector_strong_subadditive`, `ghzVector_violates_monogamy`.
* *Can a cell be entangled with another without a direct throat?* Yes — in the
  star geometry `I(0:1) = 1 > 0` while `w(0,1) = 0`; the entanglement is carried
  by a two-step bridge (`starModel_bridge_through_bulk`).

No sequence with an OEIS entry arose in this project; the objects are Boolean
recombination rules and cut functions rather than integer sequences.

## 6. Search for a non-geometric five-party entropy vector

A local search over integer vectors `S : {0,…,31} → ℕ` (bitmask indexing of the
five parties, `S(∅) = 0`) was run with the constraint set

* subadditivity on all disjoint pairs of masks,
* strong subadditivity, weak monotonicity and monogamy on all `32³` triples of
  pairwise disjoint masks,

maximising the violation of the cyclic inequality
`Σⱼ S(AⱼAⱼ₊₁) + S(A₀…A₄) ≤ Σⱼ S(AⱼAⱼ₊₁Aⱼ₊₂)`.

The best vector found (verified independently by a second script, `0` constraint
violations) is

```
m : 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15
S : 0  3  2  5  4  5  6  5  2  5  4  7  6  6  7  5
m :16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
S : 3  6  5  7  5  4  6  4  4  5  6  6  4  3  5  2
```

with cyclic left-hand side `29` and right-hand side `28`, i.e. a violation of
exactly `1`:

| term | masks | values | sum |
|---|---|---|---|
| pairs `S(AⱼAⱼ₊₁)` | 3, 6, 12, 24, 17 | 5, 6, 6, 4, 6 | 27 |
| total `S(A₀…A₄)` | 31 | 2 | 2 |
| triples `S(AⱼAⱼ₊₁Aⱼ₊₂)` | 7, 14, 28, 25, 19 | 5, 7, 4, 5, 7 | 28 |

All of this is now machine-checked in
`Catalog/Novelty/CyclicIndependence.lean`: the four validity families are
discharged by kernel evaluation over the full `32³` case space
(`Sw_subadditive`, `Sw_strong_subadditive`, `Sw_weak_monotone`, `Sw_monogamy`),
the violation by `Sw_violates_cyclic5`, and the geometric consequence by
`no_bulk_geometry_realises_Sw`.
