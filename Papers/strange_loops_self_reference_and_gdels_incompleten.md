# Computational Evidence

The central *negative* claim of this development is that a **total semantic diagonal**
is impossible: there is no truth predicate `True_ : S → Prop` and diagonal operator
`diag : (S → Prop) → S` with `True_ (diag P) ↔ P (diag P)` for *every* `P`. We give
concrete finite evidence, then note why the fix (a `GodelSystem`) is inhabited.

## 1. Small-case counterexample hunt for the semantic diagonal

Take the smallest non-trivial sentence type `S = Bool` with `True_ b := (b = true)`.
A diagonal operator must, for each predicate `P`, return some `b` with
`(b = true) ↔ P b`. Enumerate the `2^2 = 4` predicates on `Bool`:

| `P true` | `P false` | works with `b=true`? (needs `P true`) | works with `b=false`? (needs `¬P false`) | any fixed point? |
|:--------:|:---------:|:-------------------------------------:|:----------------------------------------:|:----------------:|
|  T       |  T        | yes                                   | no                                       | **yes** (b=true) |
|  T       |  F        | yes                                   | yes                                      | **yes**          |
|  F       |  T        | no                                    | no                                       | **NO**           |
|  F       |  F        | no                                    | yes                                      | **yes** (b=false)|

The row `P true = False, P false = True` — i.e. `P = (¬ True_ ·)`, the **Liar
predicate** — has *no* fixed point. So no total `diag` exists even for `|S| = 2`.
The same Liar predicate breaks every `S`, which is exactly `no_semantic_diagonal`.

## 2. The corrected model is inhabited (verified in Lean)

`GodelSystem.inhabited` exhibits an explicit witness:

- `Sentence = Bool`, `Provable _ = False`, `Holds b = (b = true)`,
- `neg = not`, `G = true`.

Then `Holds G ↔ ¬ Provable G` reads `True ↔ ¬False`, i.e. `True ↔ True` ✓, and
soundness `Provable s → Holds s` is vacuous ✓. Hence Gödel incompleteness
(`goedel_true_unprovable`, `goedel_undecidable`) holds *non-vacuously*: it is a
theorem about a structure that provably has instances.

## 3. Lawvere fixed-point sanity check

Lawvere says a point-surjection `φ : A → (A → B)` forces every `g : B → B` to have a
fixed point. For `B = Prop`, `g = ¬·` has no fixed point (Liar), so no such surjection
exists — this is `cantor_no_surjection`, checked to compile with no extra axioms.

## Conclusion

The finite tables confirm the impossibility that motivates the whole file, and the
Lean build confirms the corrected `GodelSystem` is inhabited, so no theorem here is
vacuous. All claims are machine-checked in `Catalog/Logic/StrangeLoops/Chain.lean`.
