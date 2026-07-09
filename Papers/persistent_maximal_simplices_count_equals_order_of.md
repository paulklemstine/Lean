# Computational Evidence

**Conjecture.** For a finite Coxeter group `W` and a generic point `a` in the fundamental
chamber, the number of maximal persistent simplices in the canonical subdivision of the
Coxeter permutahedron `Pᵂ(a)` equals `|W|`.

The conjecture is built on two structural claims:

1. (paper's input) maximal persistent simplices ↔ **vertices** of `Pᵂ(a)`;
2. (group theory) for a **regular / generic** point `a`, the vertex set `W · a` is in
   bijection with `W`, hence has `|W|` elements — independently of `a`.

Claim 2 is the falsifiable, computable core, and it is what we formalize.

## 1. Small-case calculations (vertex count = |W|)

For a regular point `a` (trivial stabilizer), `|W · a| = |W|` by orbit–stabilizer.

| Coxeter type | `W`            | order `|W|` | permutahedron   | vertices |
|--------------|----------------|-------------|-----------------|----------|
| `A₁`         | `S₂`           | 2           | segment         | 2        |
| `A₂`         | `S₃`           | 6           | hexagon         | 6        |
| `A₃`         | `S₄`           | 24          | truncated octah.| 24       |
| `B₂`/`C₂`    | dihedral `D₄`  | 8           | octagon         | 8        |
| `I₂(m)`      | dihedral `Dₘ`  | 2m          | 2m-gon          | 2m       |
| `A₄`         | `S₅`           | 120         | —               | 120      |

All rows satisfy `#vertices = |W|`.

## 2. OEIS

* Type `A` orders `|Sₙ| = n!`: **A000142** — 1, 1, 2, 6, 24, 120, 720, ...
* Type `I₂(m)` orders `2m`: even numbers **A005843**.

## 3. Counterexample hunt (necessity of genericity)

The count `= |W|` **fails at non-regular points**.  By orbit–stabilizer,
`|W · a| · |Stab(a)| = |W|`, so a nontrivial stabilizer forces `|W · a| < |W|`.

Concrete `S₃` examples (action on `ℝ³` by permuting coordinates):

| point `a`       | `Stab(a)` | `|Stab|` | `|W·a|` | `|W| = 6` |
|-----------------|-----------|----------|---------|-----------|
| `(1,2,3)`       | trivial   | 1        | 6       | 6  ✓      |
| `(1,1,2)`       | `⟨(12)⟩`  | 2        | 3       | 3  ✗      |
| `(1,1,1)`       | all of S₃ | 6        | 1       | 1  ✗      |

So the universal statement is **true exactly on the generic locus** and **false** off it:
this is the "contrarian" disproof of the ungeneric version and is formalized as
`Coxeter.card_orbit_lt_of_not_generic`.

## 4. What is formalized

`Catalog/Novelty/CoxeterPermutahedronPersistentSimplices.lean` proves, with only the standard
axioms (`propext`, `Classical.choice`, `Quot.sound`):

* generic vertex count `= |W|` (`card_orbit_of_generic`);
* independence of the generic point (`card_orbit_independent_of_point`);
* the exact factorisation `|W·a|·|Stab a| = |W|` (`card_orbit_mul_card_stabilizer`);
* strict drop at non-generic points (`card_orbit_lt_of_not_generic`);
* the conjecture skeleton "persistent simplices ↔ vertices ⟹ count `= |W|`"
  (`persistent_simplices_count`);
* the type `A` instance: `|Sₙ| = n!` and the `n!`-vertex permutahedron of a distinct-entry
  vector (`symmetricGroup_order`, `perm_fixes_iff_eq_one`, `card_permutahedron_vertices`).
