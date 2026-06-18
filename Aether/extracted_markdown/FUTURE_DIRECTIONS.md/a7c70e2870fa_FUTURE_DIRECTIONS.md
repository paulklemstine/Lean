# Future Directions — The Self-Simulating Universe as a Computational Fixed Point

## Synthesis

`Catalog/Speculative/SelfSimulatingUniverse.lean` distils the speculative slogan
"the laws of physics are the fixed point of a computation that simulates itself" into
a clean, fully verified order-theoretic core. A *self-simulator* is a bi-monotone map
`U : Λ →o (Λ →o Λ)` on a complete lattice of laws; feeding a candidate law into both
the initial-data slot and the governing-law slot gives the diagonal `D L = U L L`, and
a *self-consistent law* solves `U(L, L) = L`. Everything the slogan demands then
follows from Knaster–Tarski and Kleene, with a duality/representation twist:

- **Existence** (`exists_selfConsistent`): a self-consistent law always exists.
- **Canonicity** (`canonicalLaw_isLeast`): there is a least one, a distinguished
  representative.
- **Uniqueness criterion** (`selfConsistent_unique_iff`): the law is unique *iff*
  `lfp = gfp` — the order-theoretic mirror of Banach uniqueness in the catalog's
  `EML/FixedPointConvergence.lean`, but with no metric assumed.
- **Computation** (`canonicalLaw_eq_iSup_iterate`): under ω-Scott-continuity the law is
  *built* as `⨆ₙ Dⁿ ⊥` — the universe bootstraps from nothing.
- **Duality** (`greatestLaw_eq_dual_canonical`): maximal self-consistency in `Λ` equals
  minimal self-consistency in `Λᵒᵈ`.
- **Representation** (`set_representation`): the abstract law materialises as the least
  fixed *set* of a monotone set operator.

## Results Summary

Eight theorems, `sorry = 0` on all main results, verified against Mathlib `v4.28.0`.
The work strictly generalises the catalog's contraction-based fixed-point file by
removing the metric and adding the `lfp ⇌ gfp` order duality as new structure.

## Research Directions

### 1. A Banach ⇌ Tarski bridge functor for fixed points
The catalog already proves a *metric* contraction has a unique fixed point
(`EMLIterOp.iterSeq_converges`) and this file proves an *order* monotone map has a
canonical fixed point with a Kleene formula. **The key insight is** that both are the
same statement read in different enrichments: a contraction with ratio `ρ < 1` induces,
via its sublevel filtration, an ω-Scott-continuous monotone map whose `lfp = gfp`, so
`selfConsistent_unique_iff` should *recover* Banach uniqueness as a corollary. This is
falsifiable: exhibit a contraction whose induced order map has `lfp ≠ gfp`, and the
bridge conjecture dies. **Why now?** Both endpoints are already formalised in this
repository, so the only missing piece is the comparison map — a self-contained next
cycle.

### 2. Uniqueness is generic: a "spectral gap" forces collapse
Conjecture: if the diagonal `D` is *strictly* monotone on the consistency interval
`[lfp, gfp]` in the sense that `D` has no nontrivial invariant antichain there, then
`lfp = gfp` and the law is unique. **The key insight is** that the interval `[lfp, gfp]`
is itself a complete lattice (Knaster–Tarski applied to the restricted `D`), so the
multiplicity of laws is governed entirely by the internal order structure of that
sub-lattice — an "algebraic spectral gap". Falsifiable: a strictly monotone `D` with a
two-point fixed interval refutes it. **Why now?** `selfConsistent_unique_iff` reduces
the whole question to comparing `lfp` and `gfp`, turning a vague "uniqueness" wish into
a concrete lattice computation.

### 3. Duality exchanges the two arrows of time
The duality theorem `greatestLaw_eq_dual_canonical` pairs the least law (built upward
from `⊥`) with the greatest law (built downward from `⊤` via `gfp_eq_sInf_iterate`).
Conjecture: the upward Kleene tower `Dⁿ ⊥` and the downward tower `Dⁿ ⊤` are exchanged
by the order anti-isomorphism, and meet exactly at the unique law when `lfp = gfp`.
**The key insight is** that "computing the universe forward from nothing" and
"co-computing it backward from everything" are dual descriptions of one object, a
discrete time-reversal symmetry living purely in the lattice. Falsifiable: find `D`
where the two towers fail to be dual-conjugate. **Why now?** Mathlib already ships
`gfp_eq_sInf_iterate`, the exact dual of the lemma used here, so both towers are
one import away.

### 4. The fine-structure constant as a "simplest fixed point" — a falsifiable toy
The originating concept predicts `α ≈ 1/137.036` as the *simplest* fixed point. Rather
than assert physics, formalise a precise, falsifiable proxy: define a complexity
measure on rational laws (e.g. denominator size of the canonical law on a finite
lattice) and conjecture that minimal-complexity self-consistent laws cluster at
specific rationals. **The key insight is** that "simplest fixed point" becomes a
well-posed optimisation over `fixedPoints D` once `D` ranges over a search space of
small simulators — moving the claim from numerology to a decidable lattice search.
Falsifiable by exhaustive `#eval` over finite simulators: if minimal-complexity fixed
points are uniformly distributed, the "special constant" thesis fails. **Why now?**
`canonicalLaw` is already computable on finite lattices, enabling direct computational
experiments this cycle.

### 5. Self-simulation with feedback: parametrised fixed points and bifurcation
Replace the static `U` by a family `Uₜ` (a "coupling" parameter `t`) and study the map
`t ↦ canonicalLaw Uₜ`. Conjecture: when each `Uₜ` is ω-Scott-continuous and `t ↦ Uₜ` is
monotone, `t ↦ canonicalLaw Uₜ` is monotone and its discontinuities are exactly the
parameters where `lfp = gfp` fails (phase transitions / bifurcations of the universe's
law). **The key insight is** that order-continuity of the parametrised Kleene tower
turns physical "phase transitions" into failures of `lfp = gfp`, unifying this file's
uniqueness criterion with the catalog's `DiagonalPhaseTransition` theme. Falsifiable:
a monotone family with a non-monotone canonical-law curve refutes it. **Why now?** The
single-parameter monotonicity of `OrderHom.lfp` (it is itself an `OrderHom`) is already
in Mathlib, giving the monotonicity half almost for free and isolating the bifurcation
half as the real target.
