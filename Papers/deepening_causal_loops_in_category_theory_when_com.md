# Computational Evidence: Causal Loops and the Bracketing Census

This note records the small-case evidence that guided the formal development in
`CausalLoopsBicategory.lean`.

## 1. Associativity fails on the nose

Writing `·` for the tensor product `node`, the two bracketings of three factors are the
*distinct* trees

```
(a · b) · c   =   node (node a b) c
a · (b · c)   =   node a (node b c)
```

They are different objects (different tree shapes) yet share the leaf-word `[a, b, c]`.
A structural size argument confirms `node (node a b) c ≠ node a (node b c)` for all
`a, b, c`, so the failure of associativity is genuine and not a disguised equality.

## 2. The census of bracketings is Catalan

Let `B(k)` be the number of distinct bracketings of a product of `k` factors, i.e. the
number of full binary trees with `k` leaves.  Splitting at the outermost product gives the
Segner recurrence

```
B(1) = 1,   B(k+1) = Σ_{i=1}^{k} B(i) · B(k+1-i).
```

Small cases:

| factors k | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|-----------|---|---|---|---|---|----|----|
| B(k)      | 1 | 1 | 2 | 5 | 14| 42 | 132|

These are the Catalan numbers `C_{k-1}`: `B(k+1) = C_k` where `C_n` counts binary trees
with `n` internal nodes.  This matches **OEIS A000108** (Catalan numbers:
`1, 1, 2, 5, 14, 42, 132, 429, ...`).

The formal file makes this precise: `Shape.bracketings n` is the finite set of bracketings
with `n` products (`n+1` factors), and `Shape.card_bracketings` proves
`|bracketings n| = catalan n`, while `Shape.card_bracketings_succ` proves the convolution
recurrence above.

## 3. Counterexample hunt

- *Is the parenthesization category strict?*  No: `not_strict` exhibits three objects on
  which source and target of the associator differ.  Every attempt to identify
  `(a·b)·c` with `a·(b·c)` on the nose fails by the size argument.
- *Could two different words give isomorphic objects?*  No: `iso_iff` shows
  `s ≅ t` holds exactly when `flatten s = flatten t`, so isomorphism classes are in
  bijection with words.  No spurious identifications occur.
- *Does thinness ever fail to yield coherence?*  In every tested tensor structure on a
  thin category the pentagon and triangle held automatically; `monoidalOfThin` proves this
  in general.

## Conclusion

The evidence pinned down two invariants of the reassociation groupoid — its connected
components (words) and their sizes (Catalan numbers) — both of which are then established
rigorously in the accompanying development.
