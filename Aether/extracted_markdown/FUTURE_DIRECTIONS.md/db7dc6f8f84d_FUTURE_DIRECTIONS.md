# Future Directions: The Lattice of p-Degrees in the Cook–Reckhow Program

## Synthesis

This cycle determined the **lattice structure** of the p-simulation preorder that the
previous two cycles only established as a preorder
(`Catalog/Logic/ProofComplexity/SimulationPreorder.lean`) and proved non-trivial
(`Catalog/Logic/ProofComplexity/SimulationDegrees.lean`). The new file
`Catalog/Logic/ProofComplexity/SimulationLattice.lean` shows that the order-theoretic core
of the Cook–Reckhow program is not merely a poset of "p-degrees" but a **lattice with a
least element**, with both lattice operations realized by explicit, size-tracking
constructions on proof objects. Throughout, the orientation of the preorder is
`P ≤ Q ↔ Simulates P Q`, i.e. "stronger" means "smaller", so the strongest systems sit at
the bottom.

- the **disjoint union** `union P Q` (a `Sum` of proofs) is the **meet** / greatest lower
  bound (`union_simulates_left`, `union_simulates_right`, `union_greatest`);
- the **conclusion-matched product** `inter P Q` (matched pairs, sizes added) is the
  **join** / least upper bound (`simulates_inter_left`, `simulates_inter_right`,
  `inter_least`);
- the **trivial size-`0` system** `trivialSystem` is the **least element**
  (`simulates_trivial`);
- both operations are `PEquiv`-congruences (`union_pEquiv_congr`, `inter_pEquiv_congr`), so
  meet and join **descend** to the quotient poset of p-degrees
  `Antisymmetrization (ProofSystem Thm) (· ≤ ·)` from Cycle 2.

The decisive synthesis is *cross-file*: the qualitative `union`/`inter` of
`Catalog/Logic/ProofSystemCollapse.lean` (where a "system" forgets proof sizes) is lifted
into the **quantitative** `PolyMono`-bounded simulation preorder of Cycle 1. Cycle 1's
engine was closure of the polynomial blow-up class under *composition* (`polyMono_comp`,
which powered transitivity in `Simulates_trans`); the only additional engine needed for
binary infima and suprema turned out to be closure under *addition* (`polyMono_add`,
proved this cycle from `polyBounded_add`). Two closure lemmas plus pure order theory
deliver the entire lattice.

## Results Summary

All results are machine-checked with `sorry = 0` and depend only on the standard axioms
`propext`, `Classical.choice`, `Quot.sound` (and `simulates_trivial` on just `propext`,
`Quot.sound`).

| Theorem | Content |
|---|---|
| `polyBounded_add`, `polyMono_add` | The (monotone) polynomial blow-up class is closed under pointwise addition. |
| `union_simulates_left/right`, `union_greatest` | `union` is the meet (greatest lower bound) of the simulation preorder. |
| `simulates_inter_left/right`, `inter_least` | `inter` is the join (least upper bound). |
| `simulates_trivial` | The size-`0` system is the least element (strongest p-degree). |
| `union_pEquiv_congr`, `inter_pEquiv_congr` | Meet and join respect p-equivalence, hence descend to the p-degree poset. |

## Research Directions

### 1. Register the genuine `Lattice` instance on the p-degree poset.

We proved meet, join, and the congruences at the level of *representatives*, but stopped
short of the Mathlib `Lattice (Antisymmetrization (ProofSystem Thm) (· ≤ ·))` instance. The
conjecture is that the congruence lemmas `union_pEquiv_congr` and `inter_pEquiv_congr` are
*exactly* the data needed to lift `union`/`inter` through `Quotient.map₂` and discharge the
`inf_le_left`, `le_sup_right`, etc. obligations from the universal properties already
proved. **The key insight is** that antisymmetrization turns a
preorder-with-binary-infima-and-suprema into an honest lattice mechanically, so the only
real mathematics is the four universal properties (`union_greatest`, `inter_least`, and the
four `*_simulates_*` bounds) we already have — the rest is `Quotient` plumbing. **Why now?**
The congruences are the last missing ingredient; this is a falsifiable, self-contained
packaging task whose failure would expose a genuine gap (e.g. a missing `OrderBot` derived
from `simulates_trivial`) rather than new mathematics.

### 2. There is no greatest element: the p-degree lattice is unbounded above.

`simulates_trivial` gives a bottom; we conjecture there is provably **no top**, i.e. no
proof system `T` that *every* system simulates with polynomial blow-up (no `T` with
`∀ S, Simulates S T`). **The key insight is** that a top element would force a single
polynomial to dominate the simulation cost of arbitrarily hard families, which is precisely
what the Fibonacci separation `no_simulation_of_fib_hard` (Cycle 1) forbids — so the *same*
super-polynomial witness `fibSystem` that separates two degrees should refute a top
applied to `linSystem`. **Why now?** Cycle 2 already isolated the growth-class obstruction
(`no_poly_bound_dominates_fib`, `no_simulation_of_hard`); turning "no top" into a theorem
reuses that obstruction verbatim against a universally-quantified candidate, making it a
short, high-value corollary that sharpens the picture from "non-trivial poset" to "lattice
with bottom but no top".

### 3. The separation phenomenon is closed under meet and join.

Cycle 2 exhibited two incomparable degrees (`exists_two_distinct_pdegrees`). We conjecture
the lattice operations *preserve* separations in a structured way: if `P` does not simulate
`Q`, then neither does `union P R` simulate `Q` for any `R` (adding strength on one side
cannot manufacture a polynomial simulation of a hard family). **The key insight is** that
`union P R ≤ P` in the simulation order (`union_simulates_left`), so a simulation
`Simulates (union P R) Q` would compose via `Simulates_trans` with `Simulates P (union P R)`?
— more precisely, since `union P R` is at least as strong as `P`, any simulation of `Q` by
the meet would, by `union_simulates_left` and transitivity, yield a simulation of `Q` by `P`,
contradicting the hypothesis. **Why now?** With meet/join now in hand and `Simulates_trans`
available, this is a pure order-theoretic consequence that converts isolated
point-separations into whole *regions* of the lattice, and it is immediately falsifiable by
a single counterexample search over the concrete `linSystem`/`fibSystem` witnesses.

### 4. Quantify the lattice: an effective degree-counting / density statement.

Beyond two distinct degrees, we conjecture an **infinite strictly descending chain** of
p-degrees built from a hardness hierarchy `s_k(n)` (e.g. `n^k` or iterated Fibonacci), with
`union` realizing greatest lower bounds along the chain. **The key insight is** that
`polyBounded_of_le` (Cycle 2) makes "degree of growth class" a faithful order-embedding of
growth rates into p-degrees, so a strictly increasing family of super-polynomial growth
classes yields a strictly descending chain of degrees, with explicit size-`s_k` systems as
constructive witnesses generalizing `fibSystem`. **Why now?** The constructive
`fibSystem`/`linSystem` template generalizes mechanically to any `s : ℕ → ℕ`, and the
additive closure `polyMono_add` proved this cycle lets us combine finitely many chain
elements via `union`, so the infrastructure for an explicit, computable chain is already
present.

### 5. A relativized / oracle lattice and the collapse question.

Introduce an oracle parameter (a "system of extra axioms" added to every system) and study
the induced family of lattices indexed by oracles, asking when two oracles induce
*isomorphic* p-degree lattices ("lattice collapse"). **The key insight is** that the
abstract `ProofSystem` carrier already accommodates extra axioms as a second completeness
witness, so an oracle is just a `union` with an axiom-system, and lattice collapse becomes
the statement that `union (·) A` is a *lattice automorphism* — testable via the congruence
lemmas. **Why now?** `union_pEquiv_congr` shows `union (·) A` is well-defined on degrees;
checking whether it is meet- and join-preserving (hence an endomorphism) is the natural next
experiment, and a negative answer would give the first *quantitative* relativized separation
in this framework.
