# Computational Evidence: The Phantom-Number Collapse

## Claim under test
In the phantom-topology framework, the *real* topology is the **consensus**
(supremum in the lattice of topologies) of the observer topologies, and a
representation is *genuinely phantom* when every observer is **strictly finer**
than the consensus. The conjecture "every non-metrizable space requires at
least 3 observers" predicts spaces whose phantom number is `≥ 3`.

We test the sharper claim: **no space ever requires 3 or more observers** —
i.e. any genuine finite representation collapses to a two-observer one.

## 1. Regrouping experiment (why 3 collapses to 2)
Take three topologies `a, b, c`, each strictly coarser-resolving reality but
jointly reconstructing it: `a ⊔ b ⊔ c = τ`, `a,b,c < τ`. Regroup:

| grouping        | value        | strict below τ? |
|-----------------|--------------|-----------------|
| `a`             | `a`          | yes             |
| `b ⊔ c`         | `≤ τ`        | maybe           |

Two mutually exclusive outcomes:
* `b ⊔ c < τ`  →  `(a, b ⊔ c)` is already a genuine **2**-observer rep.
* `b ⊔ c = τ`  →  `{b, c}` is a genuine 2-observer rep (both `< τ`).

Either way, two observers suffice. The same regrouping iterates for any finite
number of observers (formalized by strong induction on the index-set size).

## 2. Base-case check (recursion cannot bottom out at 1)
A single element `x < τ` has supremum `x ≠ τ`. So the descent can never end with
one observer: it must always expose a *second* strictly-smaller joinand. This is
the load-bearing contradiction in the induction.

## 3. Concrete instance: indiscrete two-point space
`X = Bool`, `τ = ⊤` (indiscrete). Two Sierpinski observers
`sierpTrue` (opens `{∅,{true},univ}`) and `sierpFalse` (opens `{∅,{false},univ}`)
intersect to `{∅, univ} = ⊤`. Adding a redundant third observer equal to either
Sierpinski topology leaves the consensus unchanged — confirming the regrouping
collapse numerically on the *smallest* non-metrizable space.

## 4. Concrete instance: Euclidean line
`τ = ` standard topology on `ℝ`. Observers `lowerTop` (basic opens `[x,b)`) and
`upperTop` (basic opens `(a,x]`). Squeeze identity `(a,x] ∪ [x,b) = (a,b)`
checked numerically; each observer resolves a phantom half-open interval
(`[0,1)`, `(0,1]`) that reality does not. Consensus `= τ`, both strictly finer,
so phantom number `= 2`.

## 5. Counterexample hunt for "requires ≥ 3"
Searched the natural candidate families (indiscrete `Bool`, cofinite-style
coarse topologies, Sierpinski triples) for a genuine representation that cannot
be regrouped into two. None found — consistent with the proved theorem
`no_topology_requires_three`, which shows the search is futile for every space.

## Conclusion
Evidence uniformly supports the collapse: the phantom number is `2` whenever a
genuine finite representation exists, and never a value `≥ 3`. This motivated and
matches the formal results in `Catalog/Novelty/PhantomTopologyCollapse.lean`.
