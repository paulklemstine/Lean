# FUTURE_DIRECTIONS.md — Tropical Karchmer–Wigderson Games

## Synthesis

This cycle established the foundational bridge between tropical/max-plus piecewise-affine classifiers and the Karchmer–Wigderson communication game framework. We defined integer affine pieces, tropical threshold classifiers, and the KW witness relation, then proved that witness existence follows directly from the "lossy selection" property of the tropical max operation: the argmax piece for a positively-classified input automatically separates it from any negatively-classified input, because all pieces evaluate below threshold for the latter. This is a clean, self-contained result that required no deep Mathlib infrastructure.

We then built the protocol/decision tree translation pipeline. The key structural insight is that tropical decision trees map to Alice-only protocols (Alice can evaluate any affine piece on her own input), and the translation preserves depth exactly. This means that any depth lower bound on KW protocols immediately transfers to a depth lower bound on tropical decision trees. The leaf bound theorem (≤ 2^d leaves at depth d) provides the information-theoretic backbone for such lower bounds.

What we did NOT attempt in this cycle: concrete lower bounds for specific tropical classifiers, the converse direction (protocol → decision tree), or connection to the existing canonical tropical polynomial normal form in `Tropical/Canonical/Basic.lean`. These are the natural next steps.

## Results Summary

- `tropical_witness_exists`: **proved** — For any tropical threshold classifier, if x is classified true and y false, there exists a separating affine piece index. This is the foundational KW witness theorem for the tropical domain.
- `tropicalTree_to_protocol_valid`: **proved** — A sound tropical decision tree yields a valid KW protocol. Soundness transfers through the evaluation agreement lemma.
- `tropicalTree_to_protocol_depth`: **proved** — The extracted protocol preserves the depth of the decision tree exactly.
- `tropical_kw_leaf_bound`: **proved** — Protocol leaf count is at most 2^depth, the information-theoretic backbone for lower bounds.
- `TropKWProto.run_mem_leafLabels`: **proved** — Protocol output is always a leaf label.
- `TropKWProto.card_leafLabels_le`: **proved** — Leaf count bound by structural induction.
- `tropicallySeparated_implies_witness`: **proved** — The stronger geometric notion of tropical separation implies the algebraic witness condition.

## Research Directions

### Direction 1: Concrete Tropical KW Lower Bounds via Hard Pairs
**Hypothesis**: For the tropical classifier computing "max(x₁, x₂, ..., xₙ) > 0" with n affine pieces (each piece = coordinate projection), every valid KW protocol has depth ≥ ⌈log₂ n⌉.
**Test**: Construct n hard pairs where the maximizing coordinate differs, prove they must reach distinct leaves, and apply the leaf bound.
**Why now**: The leaf bound `card_leafLabels_le` and witness existence theorem are already proved; the missing piece is showing that n hard pairs force n distinct leaves.
**If true**: This gives the first concrete tropical depth lower bound and validates the pipeline end-to-end.
**If false**: It would reveal that tropical KW witnesses are more degenerate than expected — multiple hard pairs might share a leaf, indicating a weakness in the witness notion.

### Direction 2: Protocol-to-Tree Converse (Completeness)
**Hypothesis**: Every valid tropical KW protocol can be compiled into a tropical decision tree of the same depth.
**Test**: Define a compilation function `TropKWProto → TropDecTree` that replaces Bob queries with universal quantification over thresholds, prove depth preservation and soundness.
**Why now**: The forward direction (tree → protocol) is complete. The key insight is that Bob nodes can be replaced by exhaustive threshold testing since the classifier is piecewise-affine with finitely many breakpoints.
**If true**: This establishes a KW-style equivalence: protocol depth = decision tree depth, making the communication complexity a perfect measure of tropical decision complexity.
**If false**: The gap between protocol and tree depths would itself be interesting — it would mean communication games are strictly more powerful than decision trees for tropical classifiers, suggesting an analogue of the formula-vs-circuit depth gap.

### Direction 3: Canonical Witness Selection from Tropical Normal Forms
**Hypothesis**: When a tropical polynomial is in canonical normal form (sorted slopes, all terms essential as in `Tropical/Canonical/Basic.lean`), the set of necessary KW witnesses equals exactly the set of canonical affine pieces.
**Test**: Import `TropicalPoly.Canonical` and prove that for a canonical tropical polynomial, the TropicallySeparated witnesses are exactly the canonical terms.
**Why now**: The `TropicallySeparated` predicate is already defined and shown to imply the witness condition. The key insight is that canonical form means every piece is the unique maximizer on some interval, so every piece is needed as a witness for some hard pair.
**If true**: This gives an algorithmic pipeline: canonical normal form → witness set → protocol leaf labels, connecting tropical geometry directly to communication complexity.
**If false**: It would mean that canonical forms contain redundant pieces for the KW game, suggesting a notion of "KW-canonical" form that is strictly coarser than tropical canonical form.

### Direction 4: Bob-Side Tropical Protocols and Two-Player Separation
**Hypothesis**: For classifiers of the form "max_i p_i(x) > max_j q_j(y)" (where Alice and Bob each have a tropical polynomial), the KW game requires both Alice and Bob queries, and the depth gap between Alice-only and two-player protocols can be exponential.
**Test**: Define a two-player tropical classifier and construct a family where Alice-only protocols require depth Ω(n) but two-player protocols achieve depth O(log n).
**Why now**: Our current pipeline only uses Alice nodes. The key insight is that comparing two tropical polynomials (one per player) naturally requires both players to reveal information about their maximizers.
**If true**: This would establish a genuine communication complexity separation in the tropical domain, potentially connecting to circuit complexity separations.
**If false**: It would mean tropical max structure is so rigid that Alice can always simulate Bob's queries, which would itself be a surprising structural result about piecewise-affine functions.

### Direction 5: Integration with Existing KW Infrastructure
**Hypothesis**: The `TropKWProto` type can be embedded into the generic `KWProtocol ℕ` from `Catalog/Bridges/KarchmerWigderson.lean` via a faithful functor that preserves depth and validity.
**Test**: Define an embedding `TropKWProto n m → KWProtocol ℕ` and prove that validity and depth are preserved. Then transfer the STConn lower bound machinery to tropical classifiers computing graph connectivity.
**Why now**: Both the tropical and generic KW protocol types are defined with the same structure (leaf/aliceNode/bobNode). The key insight is that the witness type `Fin m` embeds into `ℕ`, and the query functions can be lifted.
**If true**: This unifies the two KW formalizations and enables cross-pollination: tropical lower bound techniques apply to classical problems and vice versa.
**If false**: A mismatch between the validity conditions (tropical witnesses vs. variable separation) would clarify exactly where the tropical and classical KW games diverge semantically.
