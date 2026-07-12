# Computational Evidence — Stable Extensions: the Existence Gap

This cycle (contrarian mode) targets **existence and non-existence of stable
extensions**, the open direction flagged in the previous cycle
(`ArgumentationStable.lean`): *unlike preferred extensions, stable extensions
need not exist.*

## Bold conjectures under test

1. **(C1, existence)** Every finite argumentation framework has a stable
   extension. — **DISPROVED** (odd cycle).
2. **(C2)** Every preferred extension is stable. — **DISPROVED** (odd cycle).
3. **(C3, positive)** Every finite *symmetric irreflexive* framework has a
   stable extension. — **PROVED**.
4. **(C4)** Irreflexivity is unnecessary in C3: every finite symmetric framework
   has a stable extension. — **DISPROVED** (self-attacks).

## Small-case enumeration (brute force over all subsets)

Framework `cycle3` on `Fin 3`: `R a b ↔ b = a + 1`, i.e. `0→1→2→0`.

| framework            | #conflict-free | #admissible | #preferred | #stable |
|----------------------|:--------------:|:-----------:|:----------:|:-------:|
| `cycle3` (3-cycle)   |       7        |      1      |     1      |  **0**  |
| complete graph `K_3` |       4        |      4      |     3      |    3    |

Computed by filtering `Finset (Finset (Fin 3))`:

- `#{S | ConflictFree cycle3 S ∧ dominates}` = **0**  → no stable extension.
- `#{S | Admissible cycle3 S}` = **1**, that single set has cardinality `0`
  (the empty set). Hence `∅` is the unique admissible = grounded = **preferred**
  extension, and it is *not* stable. This witnesses both C1 and C2 being false.
- For the complete graph `K_3` (symmetric, irreflexive) the stable count is `3`,
  matching the `n` singletons — consistent with `ArgumentationStable.lean`.

## Why the 3-cycle has no stable extension (hand proof)

`Stable S` needs `S` conflict-free and: `a ∉ S ⇒ (a-1) ∈ S` (the unique attacker
of `a` is `a-1`).

- If `0 ∈ S`: then `1 ∉ S` (else `0` attacks `1`, a conflict). Also `2 ∉ S`
  (else `2` attacks `0`). But `2 ∉ S` forces its attacker `1 ∈ S`,
  contradicting `1 ∉ S`.
- If `0 ∉ S`: its attacker `2 ∈ S`. Then `1 ∉ S` (else `1` attacks `2`). But
  `1 ∉ S` forces its attacker `0 ∈ S`, contradiction.

So no `S` is stable. The same argument works for every odd cycle.

## Why symmetric + reflexive can fail (C4)

If `R a a` for some/all `a`, no nonempty set is conflict-free, so the only
conflict-free set is `∅`; but `∅` is stable only if it attacks every argument,
impossible when the framework is nonempty. Concretely `reflAF : Fin 1` with
`R _ _ = True` is symmetric and has **no** stable extension.

## Why symmetric + irreflexive always succeeds (C3)

On a finite type the conflict-free sets form a nonempty finite family, hence a
maximal one `S` exists. In a symmetric irreflexive framework a maximal
conflict-free set is stable (proved in `ArgumentationStable.lean` as
`maximalConflictFree_stable_of_symmetric`): any `a ∉ S` must conflict with some
`b ∈ S`, and symmetry turns that conflict into an attack `R b a`.

All four findings are formalized in `Catalog/Novelty/ArgumentationStableGap.lean`.
