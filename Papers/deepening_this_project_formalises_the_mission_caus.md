# Computational Evidence — Strictification and the Catalan census

The central new theorem is structural (an equivalence of categories `PTree α ≌ Discrete
(List α)`), so the relevant "computational" checks concern the combinatorial census that
accompanies it: the number of bracketings (objects of a connected component) of `n + 1`
factors.

## 1. Small-case counts of bracketings

`Shape.bracketings n` is the finite set of bracketing shapes with `n` internal products
(equivalently `n + 1` leaves). Its cardinality is proved to equal `catalan n`:

| n (products) | factors n+1 | #bracketings = catalan n |
|--------------|-------------|--------------------------|
| 0            | 1           | 1                        |
| 1            | 2           | 1                        |
| 2            | 3           | 2                        |
| 3            | 4           | 5                        |
| 4            | 5           | 14                       |
| 5            | 6           | 42                       |
| 6            | 7           | 132                      |

These are the Catalan numbers.

## 2. OEIS

The sequence `1, 1, 2, 5, 14, 42, 132, ...` is the Catalan numbers, **OEIS A000108** —
famously the number of ways to parenthesize a product of `n + 1` factors. This is exactly
the enumeration our census formalises (`Shape.card_bracketings`), together with the Segner
convolution recurrence `C_{n+1} = Σ_i C_i · C_{n-i}` (`Shape.card_bracketings_succ`).

## 3. Non-associativity is genuine (counterexample to strictness)

`PTree.node_assoc_ne` shows that `(a ⊗ b) ⊗ c` and `a ⊗ (b ⊗ c)` are *distinct objects*
for all `a b c` (checked by a `sizeOf` argument), so the monoidal structure really is
non-strict: no dressing-up of definitional equality. The strictification is therefore a
non-trivial equivalence, not an identity.

## 4. Consistency of the equivalence

For a word `l : List α`, the round trip `flatten (ofList l) = l` (`PTree.flatten_ofList`)
and, on the other side, every bracketing `s` satisfies `flatten (ofList (flatten s)) =
flatten s`, giving the unit isomorphism `s ≅ ofList (flatten s)`. This is the concrete
data underlying `strictify`.

All the above facts are discharged in `CausalLoopsStrictification.lean` with complete
proofs (no `sorry`), so the evidence is fully machine-checked rather than heuristic.
