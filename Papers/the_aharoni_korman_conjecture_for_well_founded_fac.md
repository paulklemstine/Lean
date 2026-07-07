# Computational Evidence — Aharoni–Korman for finite posets

We investigate the claim: *every finite poset admits a chain `C` and a partition of
the order into (nonempty) antichains such that `C` meets every part.*

The construction under test is the **height-level partition**: assign to each element
`x` its height `h(x)` (length of the longest chain topped by `x`), group elements by
height into levels `L_0, L_1, …, L_H`, and take as chain the underlying set of a
longest strictly increasing chain.

## Small-case calculations

* **Antichain (width `w`, height `0`).** Every element has height `0`; the single
  level `L_0` is the whole poset, and any one-point chain meets it. Witness size: 1
  part, chain length 1. ✓

* **Chain of length `n`.** Heights are `0, 1, …, n-1`; each level is a singleton, and
  the whole chain meets every level. Witness: `n` parts, chain length `n`. ✓

* **Diamond `{⊥, a, b, ⊤}`** with `⊥ < a, b < ⊤` and `a, b` incomparable.
  Heights: `h(⊥)=0`, `h(a)=h(b)=1`, `h(⊤)=2`. Levels: `{⊥}, {a,b}, {⊤}`. A maximal
  chain `⊥ < a < ⊤` meets all three levels. ✓ The two-element level `{a,b}` is a
  genuine antichain, so this is not a chain in disguise.

* **Two-layer bipartite order** `{a_1,a_2} < {b_1,b_2}` (all `a_i < b_j`).
  Heights: `a_i ↦ 0`, `b_j ↦ 1`. Levels `{a_1,a_2}` and `{b_1,b_2}`; chain
  `a_1 < b_1` meets both. ✓

## Counterexample hunt

The only structural risk is the **empty poset**: there is no maximal element to anchor
the chain. The empty witness (`C = ∅`, empty partition) satisfies every requirement
vacuously, and this case is discharged separately in the formal proof. No finite poset
was found that violates the height-level construction — indeed the argument shows none
can exist: heights realise a contiguous block `0, 1, …, H`, and a longest chain visits
each value exactly once.

## Table: witness parameters

| poset             | #levels (H+1) | max antichain | longest chain |
|-------------------|---------------|---------------|---------------|
| antichain (w pts) | 1             | w             | 1             |
| chain (n pts)     | n             | 1             | n             |
| diamond           | 3             | 2             | 3             |
| 2×2 bipartite     | 2             | 2             | 2             |

In every finite case the number of levels equals the length of a longest chain, and
that chain meets each level in exactly one point (a chain meets an antichain in at most
one point). This matches the formal lemma `chain_inter_antichain_subsingleton`.
