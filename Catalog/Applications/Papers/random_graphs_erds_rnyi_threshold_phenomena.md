# Theorem Trace — Erdős–Rényi Threshold Phenomena (internal)

This file maps every Lean name in the Phase A output to its mathematical
statement and records where it is stated in `ARTICLE.md` and `RESEARCH_PAPER.md`.
No theorem appears in the prose that is not listed here.

## From `Catalog/Algebra/ErdosRenyi/Concrete.lean` (provided source of truth)

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `expectation_count` | For a finite indexed family of events `A i`, `𝔼[#{i ∈ I : event i holds}] = ∑_{i∈I} ℙ(A i)`. Linearity of expectation. | §"One identity to rule them all" | Def. of expectation; Thm 1 |
| `card_edge` | `Fintype.card (Edge n) = C(n,2)`, where `Edge n = {(i,j) : i < j}`. | §"Counting the wires" | Lemma 2 |
| `expected_edges` | `𝔼[#edges in G(n,p)] = C(n,2)·p`. | §"Counting the wires" | Thm 3 |
| `incident` (def) | `incident v = {edges e : v is an endpoint of e}`. | §"When a point is an island" | Def. (incident) |
| `card_incident` | `(incident v).card = n − 1`: every vertex touches `n−1` edges. | §"When a point is an island" | Lemma 4 |
| `expected_isolated` | `𝔼[#isolated vertices] = n·(1−p)^{n−1}`. | §"When a point is an island" | Thm 5 |
| `triEdges` (def) | `triEdges T = {edges with both endpoints in T}`. | §"Triangles, the simplest social cluster" | Def. (triEdges) |
| `card_triEdges` | For `|T| = 3`, `(triEdges T).card = 3`. | §"Triangles..." | Lemma 6 |
| `expected_triangles` | `𝔼[#triangles] = C(n,3)·p³`. | §"Triangles..." | Thm 7 |

## Referenced from `Model.lean` / `SecondMoment.lean` (imported, described per lab notes)

| Lean name | Role (as documented in the Phase A header/lab notes) | Where |
|---|---|---|
| `expectation` (def) | Expectation of a real functional of a random configuration `g : E → Bool` under the product Bernoulli(`p`) law. | both, framing |
| `prob` (def) | Probability of an event (a `Finset` of configurations). | both, framing |
| `subgraphCount` (def) | Counts present copies of a family of edge-sets in a configuration. | both |
| `expectation_subgraphCount` | First moment of a subgraph count is `∑_i p^{|S_i|}`. | both |
| `allPresent` / `allAbsent` | Events "all edges of a set are present / absent". | both |
| `prob_allPresent` / `prob_allAbsent` | `ℙ(allPresent S) = p^{|S|}`, `ℙ(allAbsent S) = (1−p)^{|S|}` (edge independence). | both |
| `firstMoment` | First-moment (Markov) bound: vanishing expectation ⇒ absence whp. | both, threshold discussion |
| `second_moment_zero` | Second-moment bound: `Var/𝔼² → 0` ⇒ presence whp. | both, threshold discussion |

## Anti-hallucination notes
- The two asymptotic *sharp thresholds* (connectivity at `ln n / n`, giant
  component at `1/n`, appearance at `n^{-1/m(H)}`, Poisson triangle limit) are
  NOT proved in the Lean; they are stated as **conjectures / future directions**
  and are presented as such (clearly labelled "conjecture"/"future work") in the
  prose. The proved content is the **exact finite-`n` moment identities** above.
