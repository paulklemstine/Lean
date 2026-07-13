# Computational Evidence: Oddomorphisms over GF(2)

We model an **oddomorphism** `φ : V(F) → V(G)` as a function whose `0/1` matrix
`M = funMatrix φ` (one `1` per row, `M[u,a] = [φ u = a]`) intertwines the adjacency
matrices over the field `GF(2) = ZMod 2`:

```
A_F · M  =  M · A_G      (mod 2).
```

Entrywise this is the *local parity* condition: for every `u ∈ V(F)` and `a ∈ V(G)`,
the number of neighbours of `u` sent by `φ` to `a` is **odd** iff `φ u ~ a` in `G`.

All computations below were run in Lean 4 / Mathlib with `decide` over the finite
matrices; they are what motivated (and are subsumed by) the formal theorems in
`Basic.lean` and `Examples.lean`.

## 1. Self-oddomorphisms of small complete graphs

Enumerating all `φ : Fin 3 → Fin 3`, the self-oddomorphisms of the triangle `K₃`
are **exactly the 6 permutations**:

```
(0,1,2) (0,2,1) (1,0,2) (1,2,0) (2,0,1) (2,1,0)
```

i.e. for `K₃` the self-oddomorphism monoid equals the automorphism group `S₃`.
This is consistent with the general fact (`oddEndSubmonoid`) that self-oddomorphisms
form a submonoid, here coinciding with `Aut(K₃)`.

## 2. No oddomorphism to a strictly smaller complete graph

Brute-force enumeration gives:

* `K₃ → K₂` : **0** oddomorphisms.
* `K₄ → K₃` : **0** oddomorphisms.

So complete graphs cannot be "folded" onto smaller complete graphs by an
oddomorphism — matching the intuition that oddomorphisms track a minor-like
structure rather than arbitrary homomorphisms. (Note a proper 2-colouring of `C₄`
onto `K₂` is a homomorphism but **fails** the parity test, so homomorphisms are not
oddomorphisms in general.)

## 3. A non-injective oddomorphism (the key example)

Let `F = 2·K₂` be two disjoint edges `{0,1}, {2,3}` on `Fin 4` and `G = K₂` the single
edge on `Fin 2`. The folding map

```
merge = (0 ↦ 0, 1 ↦ 1, 2 ↦ 0, 3 ↦ 1)
```

satisfies `A_F · funMatrix merge = funMatrix merge · A_G` (verified `true`), so it is a
**surjective, non-injective oddomorphism** `2·K₂ → K₂`.  The constant map
`(0,0,0,0)` fails the test (`false`).  This is exactly a minor witness: `K₂` is a
minor of `2·K₂`.  It is formalized as `Examples.exists_noninjective_oddomorphism`.

## 4. Counterexample hunt

We probed the *converse-style* claims and the local structure:

* Homomorphism ⇒ oddomorphism is **false** (the `C₄ → K₂` 2-colouring above).
* Injective/surjective is **not** forced (the `merge` example is non-injective).

No counterexample was found to the structural theorems we prove (reflexivity,
transitivity/composition, iso ⇒ oddomorphism, the parity characterization); these
are proved in full generality in `Basic.lean`.

## Note on OEIS

The counts above (e.g. `|Aut(K_n)| = n!`, and the "0" folding counts for complete
graphs) are not distinctive enough to warrant an OEIS identification; the relevant
sequence `n!` is `A000142`.
