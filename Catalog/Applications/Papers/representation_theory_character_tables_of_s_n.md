# THEOREM TRACE (internal anti-hallucination ledger)

Source of truth: `Catalog/Algebra/PartitionConjClasses.lean` (Phase A output).
Every claim in ARTICLE.md / RESEARCH_PAPER.md must map to one of the rows below.
No theorem about Burnside, Maschke, or Schur is in the Lean output, so none is
claimed as *proved*; they appear only as motivating context, clearly flagged.

| Lean name | Kind | Statement (math) | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|---|
| `partitionEquivConjClasses` | def (`≃`) | `Nat.Partition n ≃ ConjClasses (Equiv.Perm (Fin n))`: explicit bijection partitions of n ↔ conjugacy classes of Sₙ | "Main theorem" section | Theorem 1 (Main) |
| `permOfPartition` | def | For partition `p`, a permutation of `Fin n` with cycle type = parts of `p` that are ≥ 2 | "Building a permutation from a partition" | Definition 3 |
| `exists_perm_cycleType` | lemma | `∃ g : Perm (Fin n), g.cycleType = p.parts.filter (2 ≤ ·)` | (implicit, existence) | Lemma 4 |
| `permOfPartition_cycleType` | lemma | `(permOfPartition p).cycleType = p.parts.filter (2 ≤ ·)` | "the cycles match" | Lemma 5 |
| `permOfPartition_partition_parts` | lemma | `(permOfPartition p).partition.parts = p.parts` | "fixed points restore the 1's" | Lemma 6 (key) |
| `permPartition` | def | `σ.partition` reindexed as a `Nat.Partition n` | "reading a partition off a permutation" | Definition 7 |
| `permPartition_parts` | lemma | `(permPartition σ).parts = σ.partition.parts` | (implicit) | Lemma 8 |
| `parts_cast` | lemma | transporting a partition along an index equality preserves its parts | (implicit) | Lemma 9 |
| `toConjClass` | def | `p ↦ ConjClasses.mk (permOfPartition p)` (forward map) | "Main theorem" | Definition 10 |
| `ofConjClass` | def | `c ↦ permPartition (rep c)` (backward map, well defined) | "Main theorem" | Definition 11 |
| `ofConjClass_mk` | lemma | `ofConjClass (ConjClasses.mk σ) = permPartition σ` | (implicit) | Lemma 12 |
| `isConj_permOfPartition` | lemma | if `σ.partition.parts = p.parts` then `IsConj (permOfPartition p) σ` | "two permutations are conjugate iff same cycle structure" | Lemma 13 |
| `toConjClass_injective` | lemma | `toConjClass` is injective | "injectivity" | Lemma 14 |
| `toConjClass_surjective` | lemma | `toConjClass` is surjective | "surjectivity" | Lemma 15 |

Consequence used (counting corollary): `|ConjClasses (Perm (Fin n))| = p(n)`,
the number of partitions of n; with `p(3)=3, p(4)=5, p(5)=7`. This is a direct
cardinality consequence of `partitionEquivConjClasses` (an equiv preserves
cardinality) — stated as a corollary, traceable to the main theorem.

Motivating context only (NOT proved here, flagged as background in prose):
- "number of irreducible complex characters = number of conjugacy classes"
- Maschke, Schur, Burnside — named only as the surrounding theory, never as our results.
