# Computational Evidence

Bridge theorem: for a contracting, monotone finite pruning update
`F : Finset α → Finset α` and finite candidate set `S`, the coercion of the
iteratively-computed pruning kernel equals the Knaster–Tarski greatest fixed
point `OrderHom.gfp (G F S)` on the complete lattice `Set α`.

## 1. Small-case calculations

Take `F T = T ∩ A` (delete every candidate not in a fixed set `A`), which is
contracting and monotone. The pruning loop stabilizes in **one** round:

| `S`             | `A`         | `rounds F 1 S = F S` | greatest kernel `K` | `gfp (G F S)` |
|-----------------|-------------|----------------------|---------------------|---------------|
| `{0,1,2,3}`     | `{1,3}`     | `{1,3}`              | `{1,3}`             | `↑{1,3}`      |
| `{0,1,2}`       | `{5,6}`     | `∅`                  | `∅`                 | `↑∅ = ∅`      |
| `{0,1,2,3,4}`   | `{0,1,2,3,4}`| `{0,1,2,3,4}`       | `{0,1,2,3,4}`       | `↑S`          |

In each row `↑(F S) = gfp (G F S)`, matching `gfp_inter_fixed`.

A genuinely iterative example (`deleteMin`, removing the least element each
round) needs `|S|` rounds to reach the empty fixed point, showing the `|S|`
round bound of `exists_fixed_round_le_card` is attained:

| `S`          | rounds to fix | fixed point |
|--------------|---------------|-------------|
| `{0,1,2,3}`  | `4`           | `∅`         |

(The `deleteMin` example and its sharpness are recorded in the sibling
`Pythagorean/KCopwinTermination.lean` via `native_decide`.)

## 2. OEIS

No integer sequence is central to the statement. The only numeric invariant is
the trivially sharp round bound `|S|`, so no OEIS lookup is warranted.

## 3. Counterexample hunt

The two hypotheses are both load-bearing:

* **Contraction removed.** The two-state swap `{0} ↦ {1} ↦ {0} ↦ …` never
  stabilizes: no fixed point exists and the correspondence with `gfp` breaks.
  (Recorded as the oscillation example in `KCopwinTermination.lean`.)
* **Monotonicity removed.** Without monotonicity, `↑K` need not be a fixed point
  of the lifted map `G`, so `OrderHom.le_gfp` cannot be applied; the equality
  `gfp = ↑K` can fail.

No counterexample to the theorem itself (under both hypotheses) was found; the
formal proof in `Catalog/Bridges/CopwinKnasterTarski.lean` establishes it in
full generality.

## 4. Tables / plots

The tables above suffice; the phenomenon is discrete and small-dimensional.
