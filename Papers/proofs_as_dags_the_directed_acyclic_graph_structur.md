# Computational Evidence — Dependency Networks as DAGs

We model a dependency network by a decidable relation `R` on a finite vertex type,
where `R u v` means "statement `u` is directly used to derive statement `v`".

## 1. Conservation law (directed handshaking)

Toy network: the strict order `R i j := i < j` on `Fin 5` (a maximal transitive
acyclic network — every earlier statement feeds every later one).

| statement `v` | 0 | 1 | 2 | 3 | 4 |
|---------------|---|---|---|---|---|
| in-degree     | 0 | 1 | 2 | 3 | 4 |

* `∑ v, inDeg v = 0+1+2+3+4 = 10`.
* `edgeCount = #{(i,j) : i < j} = C(5,2) = 10`.

These agree, confirming `sum_inDeg_eq_edgeCount`. The same total is obtained by summing
out-degrees `[4,3,2,1,0]`, confirming `sum_inDeg_eq_sum_outDeg`.

## 2. Hub existence

Maximum in-degree `m = 4`. The pigeonhole bound of `exists_inDeg_hub` predicts
`n · m = 5·4 = 20 ≥ 10 = edgeCount`, which holds. The bound is tight up to a factor of 2
here; for a network with a single universal hub (a "star") it becomes an equality.

## 3. Acyclicity and foundations

The strict order on `Fin 5` is acyclic: its transitive closure is again `<`, which is
irreflexive. The unique source (in-degree `0`) is statement `0` — the sole "axiom" of the
network — matching `exists_source`; the unique sink is statement `4`, matching `exists_sink`.
Adding any back-edge `j → i` with `i < j` creates a 2-cycle, destroying both the source and
the sink — the boundary case that shows the acyclicity hypothesis is load-bearing.

## 4. Counterexample hunt

* *Claim tested:* "every finite network has a source." **False** without acyclicity: the
  2-cycle `{0→1, 1→0}` on `Fin 2` has in-degree `1` at every vertex. This is why
  `exists_source`/`exists_sink` require `Acyclic R`.
* *Claim tested:* "the hub bound needs nonemptiness." On the empty type both sides are `0`,
  so the inequality is not informative; `exists_inDeg_hub` is therefore guarded by
  `0 < Fintype.card V`, under which it always locates a genuine maximiser.

No counterexample was found to any stated theorem; the failing universal claims above are
exactly the ones excluded by the hypotheses.
