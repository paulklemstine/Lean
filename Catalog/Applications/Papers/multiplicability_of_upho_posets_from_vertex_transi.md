# Theorem Trace — Multiplicability of Upho Posets from Vertex-Transitive Graphs

This internal file lists every theorem, lemma, and definition that appears in the
Phase A Lean output, its mathematical statement, and where it is stated in
`ARTICLE.md` and `RESEARCH_PAPER.md`. No result outside this list may be claimed.

## File: `Catalog/Novelty/UphoMultiplicability/LeftDivisibility.lean`

| Lean name | Kind | Mathematical statement | ARTICLE.md | RESEARCH_PAPER.md |
|---|---|---|---|---|
| `LeftDvd` | def | `a ≼ b ⟺ ∃ c, b = a·c` (left-divisibility on a monoid) | "the divides-on-the-left rule" | Def. 3.1 |
| `leftDvd_refl` | thm | `a ≼ a` | "every word is a prefix of itself" | Lem. 3.2 (refl) |
| `leftDvd_trans` | thm | `a ≼ b → b ≼ c → a ≼ c` | "chaining prefixes" | Lem. 3.2 (trans) |
| `leftDvdPreorder` | def | `LeftDvd` is a `Preorder` on any monoid | "always a preorder" | Prop. 3.3 |
| `group_leftDvd` | thm | in a group, `∀ a b, a ≼ b` | "in a group everybody divides everybody" | Lem. 3.4 |
| `group_leftDvd_antisymm_iff_subsingleton` | thm | group antisymmetry ⟺ group is trivial | "the collapse dichotomy" | Thm. 3.5 |
| `freeMonoid_leftDvd_iff_isPrefix` | thm | in `FreeMonoid α`, `a ≼ b ⟺ a <+: b` | "divisibility = prefix" | Lem. 4.2 |
| `freeMonoid_leftDvd_antisymm` | thm | prefix order is antisymmetric | "a genuine ordering" | Thm. 4.3 |
| `freeMonoid_leftDvd_finitary` | thm | every word has finitely many left-divisors | "finitely many ancestors" | Thm. 4.4 |
| `freeMonoidLeftDvdPartialOrder` | def | packaged `PartialOrder (FreeMonoid α)` | "the prototype upho poset" | Cor. 4.5 |

## File: `Catalog/Novelty/UphoMultiplicability/Sabidussi.lean`

| Lean name | Kind | Mathematical statement | ARTICLE.md | RESEARCH_PAPER.md |
|---|---|---|---|---|
| `IsFreeAction` | def | action with no nontrivial stabilizers | "no point pinned twice" | Def. 5.1 |
| `IsRegularAction` | def | action that is free and transitive (sharply transitive) | "exactly one symmetry sends u to v" | Def. 5.2 |
| `cayleyGraph` | def | Cayley graph `Cay H S` of a group `H` with symmetric `S` | "the Cayley graph" | Def. 5.3 |
| `cayleyRep` | def | left-regular representation `H →* Aut(Cay H S)` | "left multiplication is a symmetry" | Def. 5.4 |
| `IsCayleyGraph` | def | predicate: `G` is isomorphic to some Cayley graph | "being a Cayley graph" | Def. 5.5 |
| `HasRegularAutSubgroup` | def | `Aut(G)` contains a regular subgroup | "a regular subgroup of symmetries" | Def. 5.6 |
| `HasRegularAutSubgroup_of_isCayley` | thm | Cayley ⇒ regular subgroup | "forward direction" | Thm. 5.7 (⇒) |
| `isCayley_of_hasRegularAutSubgroup` | thm | regular subgroup ⇒ Cayley | "reverse direction" | Thm. 5.7 (⇐) |
| `sabidussi` | thm | `IsCayleyGraph G ⟺ HasRegularAutSubgroup G` | "Sabidussi's theorem" | Thm. 5.7 |

## Conjectures (stated as conjectures only, from Phase A future directions)

- Conjecture 1: Sabidussi ⇒ multiplicability (the fusion of the two pillars).
- Conjecture 2: the non-Cayley obstruction is order-theoretic.
- Conjecture 3: multiplicability is a Cayley-isomorphism invariant.

These are labelled CONJECTURE everywhere; they are NOT proved in the Lean output.
