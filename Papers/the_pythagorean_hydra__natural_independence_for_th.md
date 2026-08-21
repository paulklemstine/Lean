# Computational evidence — the Pythagorean Hydra

All numbers below were produced by `#eval` inside the Lean project itself (against the
definitions in `Catalog/Geometry/PythagoreanHydra/`), not by an external script.  Every
structural claim they suggest is proved in the Lean files; the tables are here only to
show how the conjectures were found and checked before formalisation.

## 1. The inverse-Berggren descent on small triples

Iterating the uniform parent map `parent (a,b,c) = (|a+2b-2c|, |2a+b-2c|, 3c-2a-2b)`:

```
(117, 44, 125) → (45, 28, 53) → (5, 12, 13) → (3, 4, 5)
```

Descent lengths (= Berggren depth `bergDepth`) for all primitive triples with odd first
leg and hypotenuse ≤ 100:

| triple | depth | triple | depth |
|---|---|---|---|
| (3,4,5) | 0 | (45,28,53) | 2 |
| (5,12,13) | 1 | (55,48,73) | 2 |
| (15,8,17) | 1 | (65,72,97) | 2 |
| (21,20,29) | 1 | (77,36,85) | 2 |
| (7,24,25) | 2 | (9,40,41) | 3 |
| (33,56,65) | 2 | (63,16,65) | 3 |
| (35,12,37) | 2 | (11,60,61) | 4 |
| (39,80,89) | 2 | (13,84,85) | 5 |

Every triple tested descends to `(3,4,5)` and the hypotenuse strictly decreases at each
step — the content of `parent_hyp_lt`, `parent_isPPT` and `reach_iff_isPPT`.

*Counterexample hunt.*  The descent was also run on non-Pythagorean inputs (e.g.
`(4187,4884,6437)`, which fails `a²+b²=c²` by `41 384 425 ≠ 41 434 969`); there the
iteration enters a 2-cycle `(249,32,337) ↔ (361,144,449)`.  This is the reason the Lean
statements carry the hypothesis `IsPPT`: the descent is well-founded on primitive
Pythagorean triples only, not on arbitrary integer triples.  No counterexample was found
inside the Pythagorean class.

## 2. Spines of the tree, and OEIS

Hypotenuses along the two extreme spines of the Berggren tree:

* `A`-spine `addr (Aⁿ)` : 5, 13, 25, 41, 61, 85, 113, 145, …
  — centred square numbers `2n²+6n+5` (OEIS **A001844** shifted), so depth grows like
  `√c`;
* `B`-spine `addr (Bⁿ)` : 5, 29, 169, 985, 5741, 33461, 195025, 1136689, …
  — the NSW / half-companion Pell numbers (OEIS **A001653**), satisfying
  `c_{n+2} = 6c_{n+1} − c_n`, so depth grows like `log c`.

Consequence, visible before proving anything: *hypotenuse* is a valid but wasteful level
function for the hydra, while *address length* is the intrinsic one.  Both bounds are
proved (`pythagorean_hydra_elementary_bound`, `single_head_battle_bound`); only the
second is sharp.

## 3. The potential function and battle lengths

`phi k n = 1 + k + ⋯ + kⁿ` (the exact maximal battle length from one head at depth `n`
with branching bound `k`):

| n | phi 1 n | phi 2 n | phi 3 n |
|---|---|---|---|
| 0 | 1 | 1 | 1 |
| 1 | 2 | 3 | 4 |
| 2 | 3 | 7 | 13 |
| 3 | 4 | 15 | 40 |
| 4 | 5 | 31 | 121 |
| 5 | 6 | 63 | 364 |
| 6 | 7 | 127 | 1093 |

The growth is plainly elementary — `phi k n ≤ (k+1)^(n+1)` (`phi_le_pow`) — which is what
killed the moonshot conjecture (a Kirby–Paris phenomenon needs a length function
majorising every provably total function of PA).  The value `phi 3 5 = 364` is the one
appearing in `root_battle_bound`, and is verified in Lean by `decide`.

## 4. What the data suggested, and what was proved

| observation | status in Lean |
|---|---|
| descent always terminates at `(3,4,5)` | `reach_iff_isPPT` (proved) |
| exactly one of the three inverse moves applies | `parent_eq_inv` (proved) |
| addresses are unique | `addr_injective`, `exists_unique_addr` (proved) |
| battle length from depth `d` is `1+k+⋯+k^d` | `single_head_maximal_battle` (proved) |
| relaxing `<` to `≤` breaks termination | `hydraStepLe_has_infinite_play` (proved) |
| regrowing children breaks termination | `berg_children_infinite_battle` (proved) |
