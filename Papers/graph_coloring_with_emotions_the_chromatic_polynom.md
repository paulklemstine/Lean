# Computational Evidence — Chromatic Polynomials and the Emotional Chromatic Number

All numbers below are *verified inside Lean* by the files in `Catalog/Computation/`; nothing here
comes from an unchecked script.  The Lean names in brackets are the theorems that certify each row.

## 1. Small cases of the chromatic polynomial of a clique with bystanders

`cliqueBelow N k` is the network on `N` people in which the first `k` are mutual friends and the
rest have no friends.  Closed form [`chromVal_cliqueBelow`]:

    chi(q)  =  q^{falling min(k,N)} * q^{N - min(k,N)}

| network            | clique size | chi(6) (six basic emotions)                   |
|--------------------|-------------|-----------------------------------------------|
| `cliqueBelow 10 3` | 3           | 6·5·4 · 6^7 = 33 592 320                       |
| `cliqueBelow 10 4` | 4           | 6·5·4·3 · 6^6 = 16 796 160                     |
| `cliqueBelow 10 5` | 5           | 6·5·4·3·2 · 6^5 = 5 598 720                    |
| `cliqueBelow 10 6` | 6           | 6·5·4·3·2·1 · 6^4 = 933 120                    |
| `cliqueBelow 7 7`  | 7           | 0  (six emotions are impossible)               |

[`census_six_emotion_count`, `census_count_antitone`, `seven_clique_breaks_window`]

Observation that guided the theory: the count *decreases* as the clique grows while the emotional
chromatic number *increases* — emotional "demand" and emotional "abundance" move in opposite
directions.  Formalized as `census_count_antitone` and, in general form, as
`chromVal_antitone_edges`.

## 2. Census of one hundred social networks

Fifty friendship circles `C_{i+3}` (`i < 50`) and fifty clique networks
`cliqueBelow 10 (3 + i%4)` (`i < 50`).

| value of chi_E | number of networks |
|----------------|--------------------|
| 3              | 63                 |
| 4              | 13                 |
| 5              | 12                 |
| 6              | 12                 |

Total emotional load `∑ chi_E = 373`, average `3.73`.
[`census_value_counts`, `census_total_emotional_load`, `census_window`]

Every one of the hundred networks satisfies `3 ≤ chi_E ≤ 6`, confirming the mission's empirical
claim *on this sample*.  The sample is not representative of all graphs: `cliqueBelow 7 7` has
`chi_E = 7`.

## 3. Counterexample hunt against the mission statement

* **"The chromatic polynomial has a root at k = 2 for every bipartite graph."**  FALSE, and already
  refuted in the catalog (`bipartite_root_claim_false`: `chi_{K_2}(2) = 2`).  The genuine universal
  root of a graph with an edge is at `k = 1`.
* **"chi_E(C_n) = 2 for even n."**  FALSE under the mission's own definition, which imposes
  `k ≥ 3`; the catalog proves `chi_E(C_n) = 3` for all `n ≥ 3` (`emoChrom_cycle`).
* **"chi_E is between 3 and 6 for most networks."**  TRUE under an explicit sufficient condition
  proved here — `maxDegree ≤ 5` (`six_emotions_suffice`) — and FALSE in general
  (`seven_clique_breaks_window`).
* **"chi_E is a new invariant."**  FALSE: `emoChrom G = max χ(G) 3`
  (`emoChrom_eq_max_chromaticNumber`).

## 4. Extremes used as sanity checks

| graph                | χ    | Δ+1  | ω    | chi_E | comment                                  |
|----------------------|------|------|------|-------|------------------------------------------|
| `K_n` (n ≥ 3)        | n    | n    | n    | n     | sandwich tight on both sides             |
| `C_4`                | 2    | 3    | 2    | 3     | floor decides                            |
| `C_5`                | 3    | 3    | 2    | 3     | upper bound tight, lower loose           |
| star `K_{1,m}`       | 2    | m+1  | 2    | 3     | upper bound arbitrarily loose            |
| `K_7`                | 7    | 7    | 7    | 7     | breaks the six-emotion window            |

[`emoChrom_complete_via_structure`, `emoChrom_cycle`, `emoChrom_sandwich`,
`product_law_loose_on_five_cycle`, `seven_clique_breaks_window`]

## 5. Nordhaus–Gaddum data

`|V| ≤ chi(G)·chi(Gᶜ)` [`card_le_mul_chromaticNumber_compl`].  On `C_5`: `5 < 3·3 = 9`
[`product_law_loose_on_five_cycle`]; on `K_n`: `n ≤ n·1`, an equality
[`product_law_tight_on_clique`].  Consequence used in the census discussion: a hundred-person
network with `chi_E ≤ 6` has `chi_E(Gᶜ) ≥ 17` [`emotional_duality_hundred`], and if additionally
`Δ(G) ≤ 5` then `Δ(Gᶜ) ≥ 16` [`sparse_network_has_dense_stranger_graph`].

## 6. Sequence note

The census value sequence `3,3,…,3,3,4,5,6,3,4,5,6,…` is a periodic bookkeeping device of this
experiment, not a mathematical sequence, so no OEIS identification is claimed.  The falling
factorial values `6, 30, 120, 360, 720, 720, 0` appearing in `chi(6)` are the falling factorials
`6^{\underline k}` (a standard sequence of falling factorials of 6).

## 7. Abundance bound (added in cycle 4)

`(q - d)^{|V|} ≤ chromVal G q` whenever every person has at most `d` friends
[`greedy_abundance`].  Illustrative values:

| network                          | d | q  | lower bound | exact value (where known) |
|----------------------------------|---|----|-------------|---------------------------|
| any 100 people, degree ≤ 5       | 5 | 10 | 5^100       | —                         |
| any 100 people, degree ≤ 5       | 5 | 6  | 1           | — (bound degenerates)     |
| friendless population of size n  | 0 | q  | q^n         | q^n (bound is sharp)      |

[`abundance_of_sparse_network`, `greedy_abundance_sharp_on_empty`]

## 8. The hub-and-circle network (cycle 5)

Five people in a friendship circle plus a hub friends with all of them, verified by kernel
computation over `Fin 6 → Fin q`:

| quantity                | value | Lean theorem                |
|-------------------------|-------|-----------------------------|
| chi(3)                  | 0     | `wheelNet_chromVal_three`   |
| chi(4)                  | 120   | `wheelNet_chromVal_four`    |
| max degree              | 5     | `wheelNet_maxDegree`        |
| clique number           | 3     | `wheelNet_cliqueNum`        |
| emotional chromatic no. | 4     | `wheelNet_emoChrom`         |

`chi(4) = 120` agrees with the classical wheel polynomial `q·((q-2)^5 - (q-2))` at `q = 4`, an
independent check of the encoding.  Since `max(ω,3) = 3 < 4 < 6 = max(Δ+1,3)`, both sides of the
sandwich theorem are strict for this network [`wheelNet_sandwich_strict`].
