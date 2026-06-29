# Computational Evidence: Girth–Expansion Equivalence

## The claim under test

> A left-`d`-regular bipartite graph is an *s-optimal small-set expander*
> (every set `X` of `≤ s` left vertices has *exactly* `d·|X|` distinct neighbors)
> **iff** its girth is `≥ 2s+2`.

`OptimalExpander s` means `|N(X)| = d·|X|` for all `|X| ≤ s`. Since each
`|N(u)| = d` and `|N(X)| ≤ Σ_{u∈X}|N(u)| = d·|X|`, equality holds iff the
neighborhoods are **pairwise disjoint** on `X`.

## Small-case calculation: the s = 2 case collapses

For `|X| = 2`, `X = {u,v}`: `|N(u) ∪ N(v)| = 2d` forces `N(u) ∩ N(v) = ∅`.
So `OptimalExpander 2` ⇔ *every* pair of left vertices has **disjoint**
neighborhoods ⇔ the graph is a vertex-disjoint union of stars ⇔ it has **no
cycle at all** (girth = ∞). This is *strictly stronger* than girth `≥ 6`
(which only forbids two vertices sharing `≥ 2` neighbors).

Hence the forward direction `optimal ⇒ girth ≥ 2s+2` is **TRUE**, but the
converse is **FALSE** for `s ≥ 2`.

## Counterexample hunt (converse is false)

Graph `L = Fin 2`, `R = Fin 3`, `d = 2`:

| left vertex | neighbors |
|-------------|-----------|
| `0`         | `{0,1}`   |
| `1`         | `{1,2}`   |

Computed in Lean (`#eval`):

* `(Ncex u).card = 2` for all `u`  → left-`2`-regular ✓
* `|N(0) ∩ N(1)| = 1`  → **no 4-cycle**, so girth `≥ 6` ✓
* `|N({0,1})| = 3 ≠ 4 = d·2`  → **NOT** `OptimalExpander 2` ✗

So `GirthGe (s=2)` holds while `OptimalExpander 2` fails: the literal "iff"
is refuted. (The two share a single neighbor — a path `0–1–1`, which is acyclic
yet already destroys optimal expansion.)

## What survives / corrected bridges

1. **Forward bridge (true):** `OptimalExpander s ⇒ GirthGe (2s+2)`.
2. **Expansion structure theorem (true):** for `s ≥ 2`,
   `OptimalExpander s ⇔ AllPairsDisjoint` (independent of `s`).
3. **Genuine girth bridge (true):** girth `≥ 6` (no 4-cycle)
   `⇔ ∀ u≠v, |N(u) ∩ N(v)| ≤ 1`.
4. **Collapse:** disjoint neighborhoods ⇒ no cycle of any length.

## OEIS

No integer sequence is central to the corrected statements; the content is the
structural equivalence above rather than an enumeration, so no OEIS lookup applies.
