# Computational Evidence

All numbers below were produced by `#eval` inside the Lean project (against the
catalog definitions `PhysicsConsistency.sat`, `Form`, `Con`), and every claim they
suggest is subsequently *proved* in
`Catalog/Novelty/ArithmetizedQFTReflection.lean` and
`Catalog/Novelty/PhysicalCountermodelCompleteness.lean`.

## 1. Truth of iterated boxed falsum in the Kripke model on `(ℕ, <)`

`sat m φ` is the catalog's Kripke satisfaction; world `m` sees exactly the worlds
`n < m`.  Evaluating at the worlds `m = 0,1,2,3`:

| formula `φ` | `m=0` | `m=1` | `m=2` | `m=3` |
|---|---|---|---|---|
| `□⊥`        | true | false | false | false |
| `□□⊥`       | true | true  | false | false |
| `□□□⊥`      | true | true  | true  | false |
| `□_0⊥ → □_1⊥` | true | true | true | true |
| `Con 0 = ¬□_0⊥` | false | true | true | true |

Pattern: **`□^k ⊥` is true at `m` iff `m < k`.**  This is proved as
`sat_boxPow_bot`.

Consequences read off the table and then proved:

* Validity at the worlds `{0,…,n}` (the theory `capSysN n`) proves `□^k ⊥` iff
  `n < k` (`provable_capSysN_boxPow_bot`).  In particular `capSysN 1` proves `□□⊥`
  but not `□⊥`: the uniform reflection rule (1-consistency) fails while the minimal
  soundness condition `⊬ □⊥` holds — the separating example of Future Direction 2.
* The strict hierarchy `capSysN 0 ⊋ capSysN 1 ⊋ capSysN 2 ⊋ …` in provability is
  witnessed by `□^{n+1}⊥` (`capSysN_strict_hierarchy`).
* `□_0⊥ → □_1⊥` is valid at every world (the box is index-insensitive in this model),
  which is why the finite-height models validate the arithmetized interpretation
  axiom `transferAxiom` used to build the explicit theories `PAsys` / `PAbi`.

## 2. Counterexample hunt for the physical countermodel

For the two-state switch semantics (worlds `Bool`, "reads on" ≙ `w = true`,
"reads off" ≙ `w = false`), an exhaustive check over the finite world type gives

```
#eval decide (∀ w : Bool, ¬ ((w = true) ∧ (w = false)))   -- true
```

i.e. no operational state realizes the consistent finite constraint set
`{on, off}`.  Proved as `switchTheory_not_realizable`; the full statement with
nonemptiness, finiteness and soundness is `constructive_physical_countermodel`.

## 3. Search for a counterexample to the completeness characterization

The conjectured boundary is

`(∀ T, Consistent P T ↔ PhysicallyConsistent M T) ↔ (FalsumSound M ∧ Complete M)`.

Small hand-enumerated semantics over `S = ℕ` with one or two worlds were checked for
each of the four possible truth-value combinations of the two conditions:

| semantics | `FalsumSound` | `Complete` | equivalence holds |
|---|---|---|---|
| switch (worlds `Bool`, `{on,off}` unrealizable) | yes | no | no |
| `Proves Γ φ := φ∈Γ ∨ 1∈Γ`, one world, `sat φ := φ≠0` | no | yes | no |
| `Proves Γ φ := φ∈Γ ∨ (1∈Γ ∧ φ=2)`, worlds `Bool`, `sat w φ := φ≠0 ∧ (w ∨ φ≠2)` | yes | yes | yes (and `Sound` fails) |

No counterexample was found, and the characterization is then proved in full
generality (`consistency_equivalence_iff`), together with the three sharpness
witnesses above.

## 4. Tag-sensitive semantics: the one-sided transfer countermodel

For `Catalog/Novelty/ConsistencyTransferSharpness.lean` the truth tables of the
tag-sensitive satisfaction `satC (sepHeight 0)` (tag `0` at height `0`, tag `1` at
height `1`) were evaluated at the worlds `0, 1, 2` before the proofs were attempted:

| formula | world 0 | world 1 | world 2 |
|---|---|---|---|
| `□₀ ⊥` | true | true | true |
| `□₁ ⊥` | true | false | true |
| `Con 0` | false | false | false |
| `Con 1` | false | true | false |
| `Con 0 → Con 1` | true | true | true |
| `Con 1 → Con 0` | true | false | true |

Reading off the two worlds `0, 1` that define the theory `sepSys 0`: the transfer
implication `Con 0 → Con 1` is valid, its converse is not, `□₀ ⊥` is valid (so `Con 0`
is refuted), while `Con 1` and `□₁ ⊥` are both invalid (so `Con 1` is independent).
This is exactly the configuration proved in `one_sided_transfer_insufficient`.  Note
that world `2` lies above both heights, where every box is vacuously true — which is
why the theory is truncated at height `1`.

## 5. OEIS

No integer sequence of independent interest arises; the only sequence in play is the
threshold `k > n` of §1, which is not an OEIS-worthy object.

## 6. Height spectrum of independence and transfer (for `HeightSpectrumTransfer.lean`)

Before proving anything, the two halves of the conjectured "height spectrum" for the
tag-sensitive theories `capC c N` were tested exhaustively.  Provability in
`capC c N` is decidable — it is validity at the worlds `0, …, N` — so the check is a
finite `#eval` over `List.range (N+1)`.  Heights `c 0 = a`, `c 1 = b` and bounds `N`
were ranged over `{0, 1, 2, 3}` (64 configurations).

**Independence of `Con 0`** (`true` = independent), for `c ≡ h` constant:

| `h \ N` | 0 | 1 | 2 | 3 |
|---|---|---|---|---|
| **0** | false | false | false | false |
| **1** | false | true | true | true |
| **2** | false | true | true | true |
| **3** | false | true | true | true |

The pattern is `1 ≤ h ∧ 1 ≤ N`, *not* the conjectured `1 ≤ h ≤ N`: the entries
`(h, N) = (2, 1), (3, 1), (3, 2)` are independent with `h > N`.

**Transfer `Con 0 → Con 1`.**  Comparing the evaluated provability with the predicate
`min N a ≤ b` over all 64 triples `(a, b, N)` produced an **empty** list of
disagreements.  Comparing instead with the conjectured predicate `a ≤ b ∨ a = 0`
produced 10 disagreements, the smallest being `(a, b, N) = (1, 0, 0)` (provable but
not predicted) and `(a, b, N) = (2, 1, 1)` (provable, `a ≠ 0`, `a > b`).  The
conjectured independence description likewise failed on 12 of the 64 triples.

These two counterexample families are exactly the witnesses formalized as
`transfer_spectrum_conjecture_false` and `height_spectrum_conjecture_false`, and the
matching predicates are the ones proved in `capC_transfer_iff` and
`capC_Con_independent_iff`.

## Realizable transfer preorders (3 tags) — evidence for `TransferPreorderRealization.lean`

Before proving the characterization of realizable consistency-strength preorders, the
two sides were enumerated for three tags `{0, 1, 2}` and small bounds `N`.

*Realized side.*  All `4³ = 64` height assignments `c : {0,1,2} → {0,1,2,3}` were
evaluated, each producing the `3 × 3` transfer matrix `min N (c i) ≤ min N (c j)`
(this is `capC_transfer_iff`, already proved).  The number of **distinct** transfer
relations obtained was

| `N` | 0 | 1 | 2 | 3 |
|---|---|---|---|---|
| distinct transfer relations | 1 | 7 | 13 | 13 |

*Admissible side.*  All `2⁹ = 512` binary relations on `{0,1,2}` were filtered for
"transitive ∧ total ∧ no strict chain of length `N+1`", giving

| `N` | 0 | 1 | 2 |
|---|---|---|---|
| admissible relations | 1 | 7 | 13 |

The two lists agree in every case, and the count saturates at `13`, the number of
total preorders on three labelled points (ordered Bell / Fubini number `a(3) = 13`,
OEIS A000670: 1, 1, 3, 13, 75, 541, …) — as it must, since with only three tags no
strict chain can have length `3`.  The counts `1, 7, 13` are the numbers of ordered
set partitions of `{0,1,2}` into at most `N + 1` blocks.

This is exactly the content later proved in full generality:
`transfer_preorder_characterization`, `totalPreorder_iff_rank_representation` (the
realizing height is the rank function), `transfer_pigeonhole` (at most `N + 1`
strengths) and `transfer_linear_order_realized` (the bound `N + 1` is attained).
The enumeration above was exploratory; the Lean file contains the verified proofs.
