# Computational Evidence — 29-vertex configuration, independence ratio, `geomFrac > 4`

## 1. The reduction we are certifying

The geometric fractional chromatic number obeys the weak-LP-duality bound

    geomFrac(G) ≥ |V| / α(G),

where α(G) is the independence number. Hence

    4·α(G) < |V|   ⟹   geomFrac(G) > 4.

For the 29-vertex augmented configuration `G_29` of Matolcsi–Ruzsa–Varga–Zsámboki
the certificate is |V| = 29, α = 7, and indeed 4·7 = 28 < 29, so 29/7 ≈ 4.142857 > 4.

## 2. Small-case ratio table

Independence ratio α/|V| against the 1/4 threshold, for the disjoint-union-of-`m`-cliques
model `clusterGraph n m` (independence number = m when every residue class is hit):

| n  | m (= α) | α/|V|   | 4·α  | 4·α < n? | n/α ≈ geomFrac lower bd |
|----|---------|---------|------|----------|-------------------------|
| 27 | 7       | 0.2593  | 28   | no (28>27)| 3.857  (does NOT beat 4)|
| 28 | 7       | 0.2500  | 28   | no (=)    | 4.000  (boundary)       |
| 29 | 7       | 0.2414  | 28   | YES       | 4.143  (> 4)            |
| 29 | 8       | 0.2759  | 32   | no        | 3.625                   |
| 33 | 8       | 0.2424  | 32   | YES       | 4.125                   |

Observation: with α = 7 the strict regime `> 4` first appears exactly at n = 29.
This is precisely why the 27-vertex configuration is *augmented* by two vertices:
27 gives ratio 7/27 > 1/4 (no strict bound) and 28 sits on the boundary; only at 29
does 4·α < |V| become strict. This matches the mission's framing ("augmenting the
27-vertex configuration with two specific vertices").

## 3. Independence-number computation for the model

For `clusterGraph n m` (two vertices adjacent iff distinct and congruent mod m):

* Any independent set meets each residue class {i, i+m, i+2m, …} at most once (two
  vertices in the same class are adjacent), so its size is ≤ m ⟹ α ≤ m.
* Picking one representative per class (e.g. {0,1,…,m−1}) is independent ⟹ α ≥ m.

So α(clusterGraph n m) = m whenever n ≥ m ≥ 1. For (n, m) = (29, 7) this gives α = 7.
This was checked by direct pigeonhole and, for the concrete `Fin 29` instance, by
finite decision on the residue map.

## 4. Counterexample hunt (guardrails on the reduction)

* Bipartite graphs: α ≥ |V|/2, so 4·α ≥ 2|V| > |V| — the hypothesis 4·α < |V| always
  fails, confirming the reduction is *not* vacuously applicable and the theorem is not
  trivially true.
* Complete graph K_{k+1}: α = 1, so k·α = k < k+1 — gives geomFrac(K_{k+1}) > k,
  demonstrating the engine reaches arbitrarily large thresholds (unboundedness).

No counterexample to the reduction `4·α < |V| ⟹ geomFrac > 4` was found; it is a
theorem (proved from LP weak duality).

## 5. Honest scope note

We do *not* compute the independence number of the literal Euclidean unit-distance
graph `G_29` from its coordinates; that is the deep part of MRVZ. The evidence and the
formal proofs certify the *combinatorial certificate* 7/29 < 1/4 and its consequence
geomFrac > 4, together with the family/unboundedness structure around it.
