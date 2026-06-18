# Future Directions: Lattice Shape and Parametric Separation of the Poset of p-Degrees

## Synthesis

This cycle pushed the order-theoretic core of the Cook–Reckhow program
(`Catalog/Logic/ProofComplexity/SimulationPreorder.lean` and `SimulationDegrees.lean`) from
"there is a preorder with one separating pair" to genuine **structural geometry** of the
poset of p-degrees `Antisymmetrization (ProofSystem Thm) (· ≤ ·)`. The new file
`Catalog/Logic/ProofComplexity/DegreeLattice.lean` contributes three structural facts, all
`sorry`-free and depending only on `propext, Classical.choice, Quot.sound`:

1. **Binary meets exist** (`isGLB_sumSystem`, `simulation_directed`). The direct-sum system
   `sumSystem P Q` — "keep whichever proof you like" — is the greatest lower bound of
   `{P, Q}`. The universal property is closed by taking the pointwise `max` of the two
   blow-ups (`polyMono_max`). So the p-degrees form a **meet-semilattice** and the preorder
   is down-directed.

2. **A reusable separation engine** (`simulates_sysOfSize_iff`). For `ℕ`-indexed size
   systems, `sysOfSize a` p-simulates `sysOfSize b` **iff** `a` is pointwise dominated by a
   monotone polynomial blow-up of `b`. Every separation question becomes one of *polynomial
   domination of growth rates*. This subsumes the catalog's `linSystem`/`fibSystem`
   separation (`lin_lt_fib`) and powers the chain below.

3. **Infinite height** (`powSystem_strictMono`, `powSystem_pdegrees_injective`). The growth
   ladder `n ↦ 2 ^ (n ^ k)` is a strictly increasing chain: each step is a super-polynomial
   jump (`pow_pow_succ_gap`), and the rungs descend to genuinely distinct p-degrees. So the
   poset of p-degrees contains an infinite strictly increasing chain.

The unifying lesson: the right invariant is **polynomial comparability of size functions**.
Meets are the `max`-of-blow-ups; height is a chain of growth rates that are pairwise *not*
polynomially comparable; the ladder works precisely because the exponent-of-the-exponent
`n^(k+1) = n · n^k` outruns `c · n^k + c`, whereas a plain exponential `2^(k·n)` collapses
(all such rungs are polynomially comparable, hence p-equivalent).

## Results Summary

| Result | Statement | Status |
|---|---|---|
| `isGLB_sumSystem` | `sumSystem P Q` is the GLB of `{P,Q}` | proved |
| `simulation_directed` | every two systems have a common lower bound | proved |
| `simulates_sysOfSize_iff` | simulation = polynomial domination of size functions | proved |
| `lin_lt_fib` | `linSystem < fibSystem` (strict 2-chain) | proved |
| `pow_pow_succ_gap` | `(2^(n^k)+2)^c < 2^(n^(k+1))` for some `n` (`k ≥ 1`) | proved |
| `powSystem_strictMono` | `j ↦ powSystem (j+1)` is a strict chain | proved |
| `powSystem_pdegrees_injective` | the chain gives distinct p-degrees | proved |

## Research Directions

### 1. The poset of p-degrees is a meet-semilattice but *not* a lattice

We proved that binary **meets** always exist. The dual conjecture is that binary **joins**
(least upper bounds in strength) do *not* always exist: there is a pair `P, Q` of size
systems with no least common refinement under simulation. Concretely, take two size
functions whose pointwise `min` is not polynomially comparable to any single "natural"
upper bound, e.g. `a(n) = 2^(n^2)` on even `n` (and small on odd) versus its swap on parities;
any common upper bound must dominate both interleavings, and we conjecture no *least* such
bound exists in the domination preorder.

*The key insight is* that joins would require a *single* growth rate that is simultaneously
the smallest dominator of two parity-incomparable rates, and the domination preorder on
`ℕ → ℕ` modulo polynomial equivalence is not upward-directed enough to provide one — the
asymmetry between `min` (always realizable by `sumSystem`) and a hypothetical `sup` is the
falsifiable crux.

*Why now?* `simulates_sysOfSize_iff` already reduces the entire question to elementary
polynomial-domination arithmetic on `ℕ → ℕ`, exactly the regime where `pow_pow_succ_gap`
shows we can engineer non-comparable rates. The tooling to *build* a counterexample pair and
to *refute* any proposed join is in place.

### 2. An infinite antichain: incomparable p-degrees and infinite width

`powSystem_strictMono` gives infinite *height* (a chain). Conjecture: the poset also has
infinite *width* — an infinite family of pairwise **incomparable** p-degrees. Candidate:
`A_i(n) = 2^(n^2)` when `n ≡ 0 (mod p_i)` and `2^n` otherwise, for distinct primes `p_i`;
distinct primes make neither rate polynomially dominate the other.

*The key insight is* that incomparability is "two-sided super-polynomial separation": `A_i`
must beat `A_j` infinitely often *and* be beaten infinitely often, which periodic
parity/residue gadgets deliver because no polynomial can absorb a super-polynomial spike that
recurs on an infinite residue class.

*Why now?* The same `pow_pow_succ_gap` growth estimate, applied on a residue class instead of
a tail, yields the recurring spike; `simulates_sysOfSize_iff` converts "incomparable" into a
pair of `¬ PolyBounded`-style facts we already know how to prove.

### 3. Density of the simulation order

Conjecture: between any two strictly comparable size-system degrees `sys a < sys b` there is
a third, `sys a < sys c < sys b` (the order is **dense**, hence has no covering pairs among
size systems). Candidate interpolant: a geometric-mean rate `c(n) = ⌊sqrt(a(n) · b(n))⌋` or
`a(n)^{1/2} · b(n)^{1/2}` realized in `ℕ`.

*The key insight is* that strict comparability `a < b` means `b` is super-polynomially above
`a`; halving the *logarithmic* gap (a geometric mean) lands strictly between both, because
the polynomial-domination preorder is closed under "polynomially fattened" interpolation but
the strict gap survives halving.

*Why now?* Our ladder shows the gaps are real and quantitative (`pow_pow_succ_gap` is an
explicit inequality), so the interpolation can be checked by the same `nlinarith`/`gcongr`
style arithmetic that closed the ladder; there is no analytic obstruction left to formalize.

### 4. Universality: every countable poset embeds into the p-degrees

Conjecture: every countable partial order order-embeds into
`Antisymmetrization (ProofSystem ℕ) (· ≤ ·)`. Directions 1–3 (meets, antichains, density)
are the local moves; the global statement is that the poset of p-degrees is *universal* for
countable posets, mirroring the classical universality of the Turing degrees.

*The key insight is* that polynomial-domination classes of `ℕ → ℕ` are rich enough to encode
arbitrary finite incomparability/comparability patterns via residue-class gadgets (Direction
2), and a back-and-forth construction over these gadgets realizes any countable order type.

*Why now?* With `simulates_sysOfSize_iff` the embedding target is a concrete, fully arithmetic
preorder on `ℕ → ℕ`; the gadget library needed for the back-and-forth is exactly the spike
constructions Directions 2–3 force us to build first.

### 5. Concrete bridge: instantiate the abstract degrees with real proof systems

The current systems (`linSystem`, `fibSystem`, `powSystem`) are abstract size models.
Conjecture: the abstract strict separations lift to *named* propositional proof systems —
e.g. a `ProofSystem`-instance for tree-like Resolution and one for Frege such that the known
exponential Resolution lower bounds (pigeonhole) instantiate `no_simulation_of_hard`,
yielding `resolutionSystem < fregeSystem` as a theorem of this framework.

*The key insight is* that `no_simulation_of_hard` only needs (i) a linear-size proof family in
the strong system and (ii) a super-polynomial size lower bound in the weak system; both are
available in the literature for PHP, so the missing piece is purely the *formal packaging* of
a concrete proof system as a `ProofSystem` record — not any new lower bound.

*Why now?* The abstraction layer is complete and battle-tested in this cycle; plugging in one
concrete lower bound (even an axiomatized PHP bound stated as a hypothesis) immediately
converts the catalog's order theory into statements about genuine proof complexity, closing
the loop of the Cook–Reckhow program.
