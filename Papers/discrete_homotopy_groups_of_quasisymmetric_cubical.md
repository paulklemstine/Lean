# Computational Evidence — Discrete homotopy groups of quasisymmetric cubical sets

This note records the small-case checks performed before committing to the formal
proofs in `DiscreteCubicalHomotopy.lean` and `DiscreteCubicalHomotopyBridge.lean`.

## 1. Model

A single square is modelled by its four boundary edges, the group
`FreeGroup (Fin 4)` with generators `e0, e1, e2, e3`. A spanning tree of the
4-cycle collapses the three edges `e0, e1, e2`. The 2-cube (if present) is the
boundary word `w = e0 · e1 · e2 · e3`.

* **Hollow square** (no 2-cube): `rels = {e0, e1, e2}`.
* **Filled square** (with 2-cube): `rels = {e0, e1, e2, w}`.

The discrete fundamental group is `PresentedGroup rels`.

## 2. Small-case calculations

| Object            | Presentation                              | Group      | π₁ nontrivial? |
|-------------------|-------------------------------------------|------------|----------------|
| Hollow square     | ⟨e0,e1,e2,e3 | e0=e1=e2=1⟩                | ℤ (⟨e3⟩)   | yes            |
| Filled square     | ⟨e0,e1,e2,e3 | e0=e1=e2=1, e0e1e2e3=1⟩    | trivial    | no             |

Reasoning for the filled case: substituting `e0=e1=e2=1` into `e0e1e2e3=1` gives
`e3=1`; all four generators are then trivial, so the group collapses.

Reasoning for the hollow case: with only `e0=e1=e2=1`, the quotient is the free
group on the single remaining generator `e3`, i.e. `ℤ`.

## 3. Detection homomorphism (nontriviality witness)

To certify the hollow case is nontrivial we exhibited an explicit homomorphism
onto `ℤ` (the "winding number"):

```
f : Fin 4 → Multiplicative ℤ,   f i = ofAdd 1 if i = 3 else 1.
```

Each relation `e0, e1, e2` maps to `1`, so `f` descends to
`PresentedGroup hollowRels →* ℤ`. Its value on `e3` is `ofAdd 1 ≠ 1`, so `e3`
is a nontrivial class. This is exactly the argument formalized in
`hollowSquare_nontrivial`.

## 4. Monotonicity check (functoriality)

For any inclusion of relation sets `r₁ ⊆ r₂`, sending each generator to itself
respects the larger relation set, so there is a well-defined homomorphism
`PresentedGroup r₁ →* PresentedGroup r₂`; it hits every generator of the target,
hence is surjective. Instantiated at `hollowRels ⊆ filledRels`, this shows
"filling can only create null-homotopies". Formalized in `discreteMap_of_subset`
and `filling_collapses`.

## 5. OEIS / counterexample hunt

No integer sequence is central to these statements (the invariants are groups,
not counts), so no OEIS lookup applies. A counterexample hunt for the
monotonicity claim (does filling ever *increase* π₁?) fails as expected: the
induced map is always surjective, so filling never enlarges the group — matching
the general principle that adding 2-cubes kills, never creates, loops.
