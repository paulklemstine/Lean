# Computational / structural evidence

The objects here are *topologies on a four-element-constructor carrier*, so the
useful "computation" is not numerical but a **census of candidate models**.  All
entries in the tables below are backed by Lean theorems in
`Catalog/Novelty/`, and every one of them compiles with no `sorry`; nothing in
this file is an unchecked calculation.

## 1. Model census

A transreal compactification (`Transreal.IsCompactification`) is a compact
Hausdorff topology `t` with `fin : ℝ → Transreal` a `t`-open embedding and
`{null}` `t`-open.  The remainder of the finite fragment is `{pinf, ninf, null}`
with `null` isolated, so the interesting datum is how `pinf` and `ninf` attach
to the two ends of the line.  Enumerating the possibilities:

| # | how the two ends attach | model | compact Hausdorff? | is it the natural topology? |
|---|---|---|---|---|
| 1 | `pinf` ← `+∞`, `ninf` ← `−∞` | `Transreal.instTopologicalSpace` | yes (`instCompactSpace`, `instT2Space`) | yes, by definition |
| 2 | `pinf` ← `−∞`, `ninf` ← `+∞` | `Transreal.flipTopology` | yes (`flip_compactSpace`, `flip_t2Space`) | **no** (`flipTopology_ne`) |
| 3 | both ends → `ninf`, `pinf` isolated | `Transreal.exoticTopology` | yes (`exotic_compactSpace`, `exotic_t2Space`) | **no** (`exoticTopology_ne`) |
| 4 | both ends → `pinf`, `ninf` isolated | mirror of #3 | yes (same construction, mirrored) | no |
| 5 | both ends → the *same* point, that point also a limit of the other | impossible | — | ruled out by `exists_rays_aux` |

Rows 1–3 are constructed and verified in Lean.  Row 5 is exactly what the ends
argument excludes: `Transreal.exists_rays_aux` shows that after separating
`pinf` from `ninf` by disjoint open sets, connectedness of the two rays
`(M, ∞)` and `(−∞, −M)` forces each ray wholly into one of them, and the
"arbitrarily far finite points" property forbids the two rays from choosing the
same one.

## 2. Counterexample hunt (successful)

The conjecture as literally stated — compact Hausdorff + `fin` open embedding +
`{null}` open forces the natural topology — was tested against the census above
and **refuted** by row 3:

* `Transreal.isCompactification_exoticTopology` — the circle model satisfies
  every stated axiom;
* `Transreal.exotic_isOpen_pinf` vs `Transreal.not_isOpen_singleton_pinf` — yet
  `{pinf}` is open there and not in the natural topology;
* `Transreal.exists_isCompactification_ne` — hence the conjecture fails.

Row 2 refutes the natural first repair ("also demand that no exceptional point
besides nullity is isolated"): `flipTopology` has no isolated infinity
(`flip_not_isOpen_pinf`, `flip_not_isOpen_ninf`) and is still not the natural
topology.  What survives both refutations is the *oriented* statement
`Transreal.topology_eq_iff`, and the classification
`Transreal.classification_of_isCompactification` shows rows 1 and 2 are the only
unoriented possibilities.

## 3. Behaviour of the division boundary across the census

| statement | natural | flip | circle |
|---|---|---|---|
| `x ↦ x / x` discontinuous | yes (`selfDiv_not_continuous`) | yes (T₁, `selfDiv_not_continuous_of_t1`) | yes (`exotic_selfDiv_not_continuous`) |
| some value repairs `y ↦ 1/y` at `0` | no (`no_continuous_repair`) | no (`flip_no_continuous_repair`) | **yes**, uniquely `ninf` (`exotic_continuous_recipAt_ninf`, `exotic_repair_unique`) |

So the self-division obstruction is topology-canonical (it holds in every T₁
model), while the non-repairability of the reciprocal is *ends*-canonical: it
holds in exactly the models where both infinities are ends
(`no_continuous_repair_of_classification`) and fails in the circle model.
