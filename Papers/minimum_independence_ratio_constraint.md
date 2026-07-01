# Computational Evidence — Minimum Independence Ratio Constraint

## 1. Small-case calculations

Independence ratio `alpha(G) / n` for standard finite unit-distance graphs:

| Graph                         | n | alpha | ratio  | >= 1/4 ? |
|-------------------------------|---|-------|--------|----------|
| single edge (K_2)             | 2 | 1     | 0.5000 | yes      |
| equilateral triangle (K_3)    | 3 | 1     | 0.3333 | yes      |
| Moser spindle                 | 7 | 2     | 0.2857 | yes      |
| Golomb graph                  | 10| 3     | 0.3000 | yes      |
| hexagonal 7-vertex wheel      | 7 | 2     | 0.2857 | yes      |

Every small explicit unit-distance graph sits comfortably above `1/4`. This is
consistent with the proven statement (`triGraph_indep_ratio_eq_third`) that the
smallest non-trivial planar witness, the unit triangle, has ratio exactly
`1/3`.

## 2. The subtlety behind the "1/4" threshold

The mission claim is that the ratio can *never* fall below `1/4`. The relevant
sequence is the **independence ratio of the plane**, i.e. the infimum over all
finite unit-distance graphs. Known bounds (density / packing arguments):

* lower bound on the maximal density of a distance-1-avoiding set: about `0.229`;
* upper bound: about `0.254`.

Because the lower endpoint `0.229 < 0.25`, the "one quarter" figure is **not**
established; it is a conjectural threshold, and current constructions leave open
the possibility that the true infimum is below `1/4`. Colouring cannot rescue
the bound: de Grey's 2018 construction gives a finite planar unit-distance graph
of chromatic number `5`, so there is no global `4`-colouring of the plane.

## 3. What is provable, and what we proved

The genuinely theorem-shaped statement is the **conditional** one:

* If a finite graph is `4`-colourable then its independence ratio is `>= 1/4`
  (`indep_ratio_ge_quarter_of_four_colorable`), by the pigeonhole
  "largest colour class" argument.
* This bound `1/k` is tight for `K_k` (`completeGraph_ratio_eq`), so `1/4` is the
  exact constant available from `4`-colourability.
* The unit equilateral triangle realises the hypotheses concretely with true
  ratio `1/3` (`triGraph_indep_ratio_eq_third`).

## 4. Counterexample hunt

No finite unit-distance graph with independence ratio below `1/4` is known, and
none was found among the small graphs above. However, the *unconditional* claim
is **not** verified here: it is equivalent to a density lower bound that current
mathematics places out of reach (the best proven lower bound is `~0.229`). We
therefore certify only the conditional (colouring-based) form and record the
gap honestly.

## 5. OEIS note

The sequence of independence numbers of the record `k`-chromatic planar
unit-distance graphs is not a clean OEIS entry; the numeric density bounds
(`0.229 ...`, `0.254 ...`) are real constants from the packing literature rather
than integer sequences, so no OEIS identifier applies.
