# Future Directions — Proof-Complexity Holography

## Synthesis

This cycle planted a first rigorous, machine-checked flag for *proof-complexity
holography*: the idea that the cost of a formal derivation is governed by two
**geometric** invariants of a discrete bulk object dual to the derivation — a **bulk
volume** (number of cells) and a **boundary-to-bulk geodesic depth** (longest directed
face-chain). We modelled a finitely presented derivation as a directed acyclic
dependency graph (`Derivation`: `n` lines, each derived from strictly earlier lines),
exactly the shape shared by propositional resolution refutations and bounded-depth
Frege proofs. Its holographic dual (`BulkComplex`) is a graded discrete complex whose
cells are the lines and whose faces are the premises.

The headline finding is a clean, provable **dictionary plus an area law with a sharp
adversarial caveat**:

- The dual preserves both invariants *by construction* (`dual_volume`, `dual_geoDepth`):
  bulk volume = proof length, geodesic depth = proof depth.
- A discrete **area law** holds (`depth_le_length`): geodesic depth ≤ bulk volume — a
  linear, hence trivially polynomial, distortion in one direction. This packages
  immediately into the **geometric lower-bound method** (`size_lower_bound`): any lower
  bound on geodesic depth is a lower bound on proof size.
- The area law is **tight** (`chain_depth`): the linear-chain derivation, the discrete
  analogue of a pure geodesic, has geodesic depth *equal* to its bulk volume.
- Crucially, the converse **fails unboundedly** (`depth_volume_independent`,
  `wide_depth_le_two`): there are derivations with real inferences whose geodesic depth
  is `≤ 2` while their bulk volume is arbitrarily large. Depth and volume are genuinely
  *independent* invariants. This is the adversarial heart of the cycle — it refutes any
  naive hope that a single geometric scalar (e.g. "geodesic radius") could recover proof
  size, and shows that a faithful holographic dictionary must track *both* numbers.

This extends the *tree-restricted* picture in `Logic.HolographicVerification`
(`Holographic.PTree.depth`, `numLeaves`, `depth_succ_le_numLeaves`) to the *DAG* setting
that resolution and Frege actually require, where derived lines are reused. The DAG area
law `depth_le_length` is the genuine generalization of the tree bound
`depth_succ_le_numLeaves`, and `chain_depth` certifies its tightness.

## Results Summary

| Result | Statement | Status |
|---|---|---|
| `dual_volume` / `dual_geoDepth` | holographic dictionary: volume = length, geodesic depth = depth | proved (axiom-free) |
| `depth_le_length` | area law: geodesic depth ≤ bulk volume | proved |
| `size_lower_bound` | depth lower bound ⇒ size lower bound | proved |
| `chain_depth` | linear chain saturates the area law (depth = volume) | proved |
| `wide_depth_le_two` / `depth_volume_independent` | bounded depth, unbounded volume: invariants are independent | proved |

All main theorems are `sorry`-free and depend only on `propext`, `Classical.choice`,
`Quot.sound`.

## Research Directions

### 1. A two-sided (polynomial) area law via a *width* invariant
The current dictionary is honest but one-sided: depth bounds volume from below only, and
the gap can be unbounded. Introduce a third geometric functional — a discrete **width**
(maximum antichain / maximum fan-in across a level) — and conjecture that
`volume ≤ poly(depth, width)` for the DAG complex, with the linear chain (`width = 1`)
and the fan-in star (`width = n`) as the two extreme calibrating families already in
this file. *The key insight is* that the unbounded depth↔volume gap exposed by
`depth_volume_independent` is entirely "horizontal" — it lives in the width direction —
so adding the width coordinate should restore a genuine polynomial equivalence and turn
the dictionary into a true holographic correspondence. *Why now?* The two saturating
families (`chain`, `wide`) are already formalized and calibrate both extremes, so the
conjecture is immediately testable against concrete witnesses rather than in the abstract.

### 2. Subadditivity of the bulk under proof composition (a gluing law)
Define the disjoint/serial composition of two derivations and conjecture a gluing law:
volume is additive (`volume(D₁ ∘ D₂) = volume D₁ + volume D₂`) while geodesic depth is
sub-/super-additive in a controlled way (`max ≤ depth(D₁ ∘ D₂) ≤ depth D₁ + depth D₂`).
*The key insight is* that holographic bulk geometry should be *local*: cutting a proof
along a boundary of intermediate lemmas must split the bulk volume exactly, mirroring how
spatial volume is additive across a bulk hypersurface in physical holography. *Why now?*
The `depthF` fuel recursion makes composition definable without well-founded-recursion
pain, and `foldr_max_le`/`le_foldr_max` already give the algebraic backbone for the max-
side inequalities.

### 3. Geodesic depth as a certified resolution lower-bound engine
Instantiate `Derivation` with a concrete resolution refutation of the pigeonhole
principle `PHP_n` and prove an explicit geodesic-depth lower bound, then push it through
`size_lower_bound` to obtain a certified, machine-checked size lower bound. *The key
insight is* that `size_lower_bound` converts the *geometric* problem of exhibiting a long
forced face-chain into a *combinatorial* problem about the dependency DAG, which is often
more tractable than directly counting clauses. *Why now?* The lower-bound transfer
theorem is already proved and axiom-free, so the only missing ingredient is a single
explicit depth bound — a self-contained, falsifiable target whose failure (a short
chain) would itself be informative.

### 4. Boundary-area scaling: from volume law to a true area law
Augment `BulkComplex` with a notion of **boundary cells** (sources / axioms) and
investigate when bulk volume is controlled by *boundary area* (number of axioms) times a
depth factor, the discrete shadow of the Bekenstein–Hawking area law invoked in
`Logic.HolographicVerification`. *The key insight is* that `wide`'s unbounded volume is
driven entirely by unbounded boundary (many axiom lines), suggesting `volume = O(area ·
depth)` rather than `O(depth)` alone — a quantitative law the present families can
already confirm or refute. *Why now?* Both calibrating families have transparent
boundary counts (chain: 1 source; wide: `m` sources), giving an immediate two-point test
of the proposed scaling.

### 5. Invariance under proof-system simulation (functoriality of the dual)
Conjecture that a polynomial *p-simulation* between two proof systems induces a map of
bulk complexes that distorts volume and geodesic depth by at most a polynomial factor —
i.e. the holographic dual is *functorial* up to polynomial distortion. *The key insight
is* that if the geometric invariants are to be meaningful complexity measures, they must
be (polynomially) intrinsic to the *theorem* proved, not to the accidental syntax of the
system, exactly as a holographic dual should be reparametrization-robust. *Why now?* The
abstract `Derivation`/`BulkComplex` interface is deliberately system-agnostic, so a
simulation is just a structure-preserving map between two `Derivation` instances — the
cleanest possible setting in which to state and test functoriality.
