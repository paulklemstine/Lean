# Future Directions: The Full Order Type of the p-Degrees

## Synthesis

The order-theoretic core of the Cook–Reckhow program in this catalog has, over successive
cycles, been assembled from the simulation preorder `Simulates` on abstract proof systems
(`Catalog/Logic/ProofComplexity/SimulationPreorder.lean`) and its quotient, the **poset of
p-degrees** `Antisymmetrization (ProofSystem ℕ) (· ≤ ·)`. Earlier cycles proved the
qualitative skeleton: a `Preorder`/`Setoid` structure, the master reduction
`simulates_sysOfSize_iff` (simulation between size-indexed systems is *exactly* polynomial
domination of their size functions), infinite **height** (`powSystem_strictMono`), infinite
**width** (`spikeSys_isAntichain`), a **bottom** (`zeroSys_isBot`), **no top** (`no_top`),
binary **meets** (`isGLB_sumSystem`), and local **density** at two places
(`exists_strictly_between_lin_fib`, `exists_strictly_between_powSystem`).

This cycle (`Catalog/Logic/ProofComplexity/OrderEmbedding.lean`) sharpened that skeleton
from *qualitative facts* to *concrete embedded suborders*:

- **`powSystem_orderEmbedding`** upgrades "infinite height" to a genuine order embedding
  `ℕ ↪o (p-degrees)`: the p-degrees literally contain `(ℕ, ≤)`.
- **`spikeSys_bounded_antichain`** shows the infinite spike antichain is *order-bounded* —
  trapped strictly between `zeroSys` and the single degree `powSystem 2`. Infinite width is
  therefore present *arbitrarily low* in the order, not banished to infinity.
- **`powSystem_two_bounds_lin_fib_chain`** places the Fibonacci density 3-chain
  `linSystem < interSys < fibSystem` under the *same* ceiling `powSystem 2`. Height and
  width thus coexist inside one finite-height interval `(⊥, powSystem 2]`.
- **`pdegrees_order_type_summary`** bundles the embedded `ℕ`-chain, an incomparable pair,
  the absence of a top, and the bottom into one statement.

The unifying lesson — the "homotopy-invariant" content, in the spirit of working with the
poset up to p-equivalence (the natural notion of *equivalence* in this localization) — is
that the right invariant is the **growth rate of the size function up to polynomial
re-parameterization**, and every structural feature (chains, antichains, gaps, bounds)
reduces, via `simulates_sysOfSize_iff`, to elementary arithmetic of growth rates. The four
directions below push this from "the p-degrees contain ℕ and a bounded antichain" toward a
full identification of the order type.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `powSystem_orderEmbedding` | `ℕ ↪o` p-degrees | proved, `sorry = 0` |
| `spikeSys_bounded_antichain` | bounded infinite antichain in `(⊥, powSystem 2]` | proved, `sorry = 0` |
| `powSystem_two_bounds_lin_fib_chain` | density 3-chain also `≤ powSystem 2` | proved, `sorry = 0` |
| `pdegrees_order_type_summary` | embedded ℕ-chain + incomparable pair + no top + bottom | proved, `sorry = 0` |

All depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. The p-degrees embed `(ℚ, <)` — a countable dense suborder
The two local density theorems (`exists_strictly_between_lin_fib`,
`exists_strictly_between_powSystem`) are isolated witnesses; the conjecture is that density
is *global on a definable subfamily*: there is an order embedding `ℚ ↪o (p-degrees)`,
realized inside the bounded interval `(⊥, powSystem 2]`. **The key insight is** that the
interleaving construction behind `interSys` (Fibonacci-fast on evens, linear on odds) is a
*binary-digit dial*: indexing a size function by a rational's continued-fraction / dyadic
data turns the dense order of ℚ into a dense chain of growth rates, and
`simulates_sysOfSize_iff` converts "strictly between" into a pair of polynomial-domination
inequalities that the dial controls coordinatewise. **Why now?** This cycle already proved
both a `ℕ`-embedding and that density witnesses live under the single ceiling `powSystem 2`;
the remaining step is to make the *one* intermediate degree into a *dense family* of them,
reusing exactly the `interSys`/`spikeSys` machinery rather than new analysis. Falsifiable:
exhibit a covering pair (two degrees with nothing strictly between) inside any candidate
interval and the embedding fails there.

### 2. Every nontrivial bounded interval is "universal": `ℕ × ℕ ↪o (⊥, powSystem 2]`
We showed a chain and an antichain separately inhabit `(⊥, powSystem 2]`. Conjecture: the
product order `ℕ × ℕ` order-embeds into that *single bounded interval*, combining height and
width into one two-dimensional suborder. **The key insight is** that `spikeSys i` and
`powSystem`-style ladders act on *disjoint coordinates* of the size function — the 2-adic
spike support `{n : v₂ n = i}` versus the global exponent — so a size function
`(i, k) ↦ (spike on band i) blended with (k-fold exponent bump)` should be monotone in `k`
and incomparable across `i` simultaneously, with both axes bounded by `2^(n^2)`. **Why
now?** `spikeSys_le_powSystem_two` and `powSystem_two_bounds_lin_fib_chain` already certify
that *both* gadgets fit under the same ceiling; the open work is only to show the two
gadgets do not interfere, i.e. that the blend preserves both `powSystem_strictMono` and
`spikeSys_incomparable`. Falsifiable: if any blended family collapses an intended strict
step to a p-equivalence, the product embedding fails.

### 3. Binary joins exist — the p-degrees are a lattice, not merely a meet-semilattice
`isGLB_sumSystem` gives meets (the "run either system" direct sum is the GLB). Conjecture:
binary **joins** also exist, so the p-degrees form a lattice; the join of `sysOfSize a` and
`sysOfSize b` is `sysOfSize (fun n => min (a n) (b n))` (the *cheaper* of the two sizes at
each theorem). **The key insight is** the order-reversal in `simulates_sysOfSize_iff`:
simulation tracks *domination* of size functions, so the least upper bound in the degree
order corresponds to the *pointwise minimum* of size functions, dual to the `max`-of-blowups
that powered `polyMono_max` in the meet proof. **Why now?** The meet proof already isolated
every ingredient (the domination characterization and the `polyMono_max` lemma); the join
proof is its order-theoretic mirror and should reuse them almost verbatim. Falsifiable:
produce `a, b` whose `min` is dominated by neither a poly-blowup bound matching the LUB
universal property, and joins fail (the poset would then be only a meet-semilattice).

### 4. No minimal pairs above the bottom: density is *everywhere*, hence no atoms
`zeroSys` is the bottom and `zeroSys < spikeSys i`; conjecture: there are **no atoms** —
for every degree `d > ⊥` there is `c` with `⊥ < c < d`, so the order is downward dense above
the bottom (and, combined with Direction 1, dense throughout). **The key insight is** that
any size function `a` that is *not* polynomially bounded can be *thinned* on a sparse,
poly-density set (e.g. restrict its growth to `{n : v₂ n = 0}`) to produce a strictly
smaller-but-still-superpolynomial growth rate — the same thinning that made `interSys` land
strictly below `fibSystem`. **Why now?** `zeroSys_lt_spikeSys` and the `interSys`
construction together show both endpoints of such a thinning are reachable and strict; the
general statement just abstracts "thin on a sparse set" into a lemma about arbitrary
non-poly-bounded `a`. Falsifiable: a degree with no degree strictly below it except `⊥`
(an atom) refutes the conjecture and would reveal genuine "covering" structure.

### 5. A Lipschitz bridge: derivation path-length functorially refines simulation degree
`Holography.lean` models *derivations* as paths (`Derivable = ReflTransGen`) with a length
quasimetric `minDerivLen` and translations that are length-nonincreasing
(`minDerivLen_translate_le`, `chain_doubling_isometry`). Conjecture: assigning to each
derivation theory the proof system whose size is `minDerivLen` yields a **functor from the
homotopy category of derivation systems (objects = theories, morphisms = translations up to
path-homotopy) to the p-degrees**, sending translations to simulations. **The key insight
is** that a translation is exactly a polynomially-Lipschitz map of path spaces, and
`simulates_sysOfSize_iff` recognizes "polynomially-Lipschitz on lengths" as "p-simulation",
so the path-space invariant (length up to homotopy) *is* the order invariant (degree up to
p-equivalence). **Why now?** Both halves now exist in the catalog as `sorry`-free theory —
the metric/path side (`Holography`) and the order side (this file) — so the bridge is a
matter of naming the functor and checking it respects composition, which
`translate_comp_step` already nearly provides. Falsifiable: a translation that strictly
*increases* simulation cost (violating the Lipschitz bound) would break functoriality.
