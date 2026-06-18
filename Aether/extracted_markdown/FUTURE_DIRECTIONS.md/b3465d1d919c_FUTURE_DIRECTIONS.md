# Future Directions: Representation and Duality in the Poset of p-Degrees

## Synthesis

This cycle deepened the order-theoretic core of the Cook–Reckhow program along two
axes. First, it *closed a structural gap*: the file `OrderEmbedding.lean` depended on a
`NoTopElement` module that was missing from the catalog, leaving the order-type capstone
`pdegrees_order_type_summary` unbuildable. We reconstructed `NoTopElement.lean` from
scratch and proved `no_top`: the simulation preorder has **no top element**. The proof is
a single diagonalisation — against any section `s n` of a system `T`'s proof sizes, the
size-indexed system `2 ^ (s n) + n` escapes every polynomial blow-up of `s`, unifying the
bounded-section regime (the linear term wins) and the unbounded-section regime (the
exponential term wins) into one witness.

Second, and in the spirit of the engine's duality/representation mandate, it established a
**representation theorem** identifying two a-priori different lattices:

* the *algebraic* preorder of growth functions `ℕ → ℕ` under polynomial domination, with
  its **pointwise** operations `min` and `max`; and
* the *order-theoretic* poset of p-degrees, with its **abstract** lattice operations
  (greatest lower bounds / least upper bounds in the simulation preorder).

The bridge is `sysOfSize` together with the master domination reduction
`simulates_sysOfSize_iff`. We proved `isGLB_sysOfSize_min` (abstract meet = pointwise
minimum), `isLUB_sysOfSize_max` (abstract join = pointwise maximum), the reconciliation
`sumSystem_pEquiv_sysOfSize_min` (the catalog's "run-both" direct-sum meet of
`DegreeLattice` is p-equivalent to the pointwise-min meet, by uniqueness of GLBs), and the
capstone `sysOfSize_lattice_representation` recording that the size-degrees form a
**distributive** lattice with operations computed pointwise. The conceptual payoff is a
clean *duality dictionary*: order-theoretic statements about p-degrees become arithmetic
statements about growth rates, and the only nontrivial ingredient is the blow-up algebra
`polyMono_max` (the join of two polynomial blow-ups).

## Results Summary

* `NoTopElement.no_top` — the p-degree poset has no top element (no weakest degree).
* `NoTopElement.exp_eventually_beats_poly` — uniform "exponential eventually beats
  polynomial" threshold lemma, the analytic engine of `no_top`.
* `SizeDegreeLattice.isGLB_sysOfSize_min` — abstract meet is the pointwise minimum.
* `SizeDegreeLattice.isLUB_sysOfSize_max` — abstract join is the pointwise maximum.
* `SizeDegreeLattice.sumSystem_pEquiv_sysOfSize_min` — the direct-sum meet equals the
  pointwise-min meet up to p-equivalence.
* `SizeDegreeLattice.sysOfSize_distrib` + `sysOfSize_lattice_representation` — the
  size-degrees are a distributive lattice; representation capstone.

All results compile with `sorry = 0` and depend only on `propext`, `Classical.choice`,
`Quot.sound`. Restoring `NoTopElement` also re-enabled the existing
`OrderEmbedding.pdegrees_order_type_summary`.

## Research Directions

### 1. The size-degrees carry a genuine `DistribLattice` instance on a subtype.

We proved meet = min, join = max, and the pointwise distributive law, but stopped short of
registering a Mathlib `DistribLattice` *instance*. The conjecture is that the image of
`sysOfSize` in `Antisymmetrization (ProofSystem ℕ) (· ≤ ·)` — equivalently, the quotient of
`ℕ → ℕ` by mutual polynomial domination — supports a bundled `DistribLattice` (indeed a
`Lattice` that is `Order.Frame`-like for countable suprema). **The key insight is** that
every lattice law reduces, via `simulates_sysOfSize_iff`, to a pointwise identity on `ℕ`
plus the single closure fact `polyMono_max`, so the quotient inherits the distributive
lattice structure of `(ℕ, min, max)` verbatim. **Why now?** The four theorems of this cycle
already supply the meet, join, and distributive witnesses; only the bookkeeping of
descending them through `Antisymmetrization` (which `pEquiv_iff_antisymmRel` makes
definitional) remains. Falsifiable: if joins failed to be well-defined on the quotient (two
p-equivalent size functions with non-p-equivalent pointwise maxima), the instance would not
exist.

### 2. Countable suprema exist, but countable infima can fail: a `σ`-completeness asymmetry.

Conjecture: for any sequence `a : ℕ → (ℕ → ℕ)` of size functions whose pointwise supremum
`fun n => ⨆ k, a k n` is still everywhere finite, `sysOfSize (sup)` is the least upper
bound of `{sysOfSize (a k)}` — but the analogous countable *meet* (pointwise `inf` over an
infinite family) can drop out of the polynomial-domination class, so countable infima need
not be realised by `sysOfSize`. **The key insight is** that `polyMono_max` extends to
finite families but not to infinite ones (the blow-up exponent `k` would have to be uniform
across infinitely many summands), breaking the symmetry between joins and meets that holds
in the binary case. **Why now?** The binary `isLUB_sysOfSize_max` makes the finite case
exact; pushing to countable families is the natural next quantifier, and the engine's
spectral/duality theme predicts exactly such a join–meet asymmetry (cf. frames vs.
coframes).

### 3. The diagonalisation behind `no_top` upgrades to strict cofinality `ℵ₀`.

`no_top` says: above every degree there is a strictly larger one. Conjecture: the poset of
p-degrees has **no maximal chain of finite or countable cofinality bounded above** — more
precisely, every countable subset has a strict upper bound, witnessed by a single diagonal
`fun n => 2 ^ (sup of the sizes) + n`. **The key insight is** that the `2 ^ (s n) + n`
witness of `no_top` diagonalises against *one* section, and the very same construction
applied to the pointwise supremum of countably many sections diagonalises against all of
them at once (the supremum stays finite at each `n`). **Why now?** The proof of `no_top` is
already a diagonalisation; replacing a single `s` by a countable supremum is a direct
generalisation, and it would pin down the cofinal structure that the order-type program has
been circling (`powSystem_strictMono`, `no_top`).

### 4. A Galois connection between proof-system strength and hardness functions.

Conjecture: the maps `a ↦ sysOfSize a` (growth function ↦ degree) and `T ↦ (n ↦ minimal
size of a `T`-proof of `n`)` (degree ↦ growth function) form an **antitone Galois
connection** (a duality pairing) between the polynomial-domination preorder on `ℕ → ℕ` and
the simulation preorder on proof systems, whose induced closure operator is exactly
"polynomial-domination saturation". **The key insight is** that `simulates_sysOfSize_iff`
is already one half of the adjunction unit; the section `s n` used in `no_top` is the
candidate right adjoint, and the round-trip `sysOfSize ∘ minSize` should land in the same
p-degree as the original system whenever that system is size-indexed. **Why now?** This
cycle produced both legs of the would-be adjunction (`sysOfSize` and the
section-of-sizes construction inside `no_top`); assembling them into a `GaloisConnection`
is the canonical duality-theoretic packaging the engine is configured to seek.

### 5. The representation refines to a spectral/Stone-type duality for the height ladder.

Conjecture: the height ladder `powSystem k` (sizes `2 ^ (n ^ k)`) and the parity-glued
density witnesses `interPowSys k` generate, under `min`/`max`, a sublattice of the
size-degrees that is **order-isomorphic to a concrete lattice of eventually-polynomial
exponent functions** `ℕ → ℕ` ordered by eventual domination — a "spectrum" of the ladder.
**The key insight is** that, after taking `log₂`, every ladder size function becomes an
honest polynomial `n ↦ n^k`, so `min`/`max` of degrees corresponds to `min`/`max` of
*exponents*, turning the analytically delicate `pow_pow_succ_gap` separations into
elementary comparisons of exponent functions. **Why now?** With meet = min and join = max
now proven (`SizeDegreeLattice`), the ladder's separations (`DegreeLattice`,
`LadderDensity`) can be re-read as a lattice of exponents, exactly the kind of
"translate the hard problem into an easier dual space" move the engine prioritises.
