# Future Directions: From Height and Width to the Full Order Type of the p-Degrees

## Synthesis

The order-theoretic core of the Cook–Reckhow program in this catalog now describes the
poset of p-degrees `Antisymmetrization (ProofSystem ℕ) (· ≤ ·)` along *two independent
axes*:

* **Vertical / height** (`Catalog/Logic/ProofComplexity/DegreeLattice.lean`): binary meets
  exist (`isGLB_sumSystem`, `simulation_directed`); the master reduction
  `simulates_sysOfSize_iff` turns every separation into pointwise polynomial domination of
  size functions; and the ladder `n ↦ 2^(n^k)` gives an infinite strictly increasing chain
  (`powSystem_strictMono`, `powSystem_pdegrees_injective`).

* **Horizontal / width** (`Catalog/Logic/ProofComplexity/DegreeAntichain.lean`, this cycle):
  an infinite *antichain*. The residue-class spike `spikeSize p n = if p ∣ n then 2^(n²)
  else 2^n` places a super-exponential bump on the multiples of a prime `p`. For distinct
  primes `p ≠ q`, the explicit witness `n = p·(q·(c+1)+1)` is divisible by `p` but, by
  coprimality, not by `q`, and satisfies `n ≥ c+1`; on it `spikeSize p` carries a `2^(n²)`
  spike against a flat `2^n` of `spikeSize q`, and the elementary gap
  `spike_growth_gap : (2^n+2)^c < 2^(n²)` for `n ≥ c+1` shows no polynomial blow-up can
  absorb it. Hence `spikeSystem_incomparable` / `not_simulates_spikeSystem` give two-sided
  non-simulation, and indexing by the `i`-th prime yields `infinite_antichain_pdegrees`: an
  injective ℕ-indexed antichain of p-degrees. The poset therefore has **infinite width**.

The unifying lesson, now battle-tested in both directions: the right invariant is
*polynomial comparability of size functions*, and `simulates_sysOfSize_iff` makes every
structural question elementary arithmetic on `ℕ → ℕ`. Chains come from growth *orders* that
strictly increase (`n^k`); antichains come from super-polynomial spikes that recur on
residue classes the competitor misses; meets come from `max` of blow-ups.

## Results Summary (this cycle)

| Result | Statement | Status |
|---|---|---|
| `spike_growth_gap` | `(2^n + 2)^c < 2^(n²)` for `n ≥ c+1` | proved |
| `spike_witness` | `n = p·(q·(c+1)+1)` is `p`-divisible, `q`-indivisible, `≥ c+1` | proved |
| `not_simulates_spikeSystem` | distinct primes: `spikeSystem p` ⋬ `spikeSystem q` | proved |
| `spikeSystem_incomparable` | distinct primes give incomparable degrees | proved |
| `antichainSystem_incomparable` | nth-prime family is pairwise incomparable | proved |
| `infinite_antichain_pdegrees` | injective ℕ-indexed antichain of p-degrees | proved |

All results are `sorry`-free and depend only on `propext, Classical.choice, Quot.sound`.

## Research Directions

### 1. The poset of p-degrees is a meet-semilattice but *not* a lattice

We now have both meets (`isGLB_sumSystem`) and concrete incomparable pairs
(`spikeSystem_incomparable`). The dual conjecture is that binary **joins** (least upper
bounds in strength) do *not* always exist: there is a pair of size systems with no least
common refinement under simulation. Candidate: the two parity-swapped spikes
`a(n) = if 2 ∣ n then 2^(n²) else 2^n` and `b(n) = if 2 ∣ n then 2^n else 2^(n²)`. Any common
upper bound must dominate both interleavings, i.e. dominate `2^(n²)` everywhere; we conjecture
no *least* such dominator exists in the polynomial-domination preorder.

*The key insight is* that a join would require a single growth rate that is simultaneously the
smallest dominator of two parity-incomparable spikes, but the domination preorder modulo
polynomial equivalence is not upward-directed at the level of *least* bounds — the asymmetry
between `min` (always realized by `sumSystem`) and a hypothetical `sup` is the falsifiable
crux.

*Why now?* `simulates_sysOfSize_iff` already reduces joins to least-upper-bound questions in
pointwise polynomial domination, and `spike_growth_gap` is exactly the spike-vs-polynomial
estimate needed to refute any proposed candidate join. The two-sided machinery of
`not_simulates_spikeSystem` is the template for the refutation.

### 2. Density of the simulation order

Conjecture: between any two strictly comparable size-system degrees `sysOfSize a < sysOfSize
b` there is a third, `sysOfSize a < sysOfSize c < sysOfSize b` — the order is **dense**, so the
chain `powSystem k` has no covering pairs among size systems. Candidate interpolant between
exponents: `c(n) = 2^(a'(n) · ⌊√n⌋)` where the lower rung has exponent `a'(n)`, halving the
*logarithmic* gap.

*The key insight is* that strict comparability `a < b` means `b` is super-polynomially above
`a`, and a geometric-mean rate sits strictly between because the polynomial-domination
preorder is closed under polynomially-fattened interpolation while the strict gap survives a
"square-root in the exponent".

*Why now?* `spike_growth_gap` and `pow_pow_succ_gap` show the gaps are explicit and
quantitative; the same `nlinarith`/`gcongr` arithmetic that closed those gaps can verify a
geometric-mean interpolant. The only new ingredient is `Nat.sqrt` arithmetic, which is
self-contained.

### 3. Realizing the product order ℕ × ℕ: simultaneous height and width

We have an infinite chain (height) and an infinite antichain (width) *separately*. Conjecture:
the poset of p-degrees contains an order-embedded copy of `ℕ × ℕ` with the product order.
Candidate: combine the two engines into
`combo k i (n) = if pᵢ ∣ n then 2^(n^(k+2)) else 2^(n^(k+1))`, where the `k`-axis is the
`powSystem` ladder and the `i`-axis is the prime-spike antichain.

*The key insight is* that the chain parameter `k` controls the *baseline* growth order while
the prime parameter `i` controls *where* a one-notch-higher spike recurs; the two parameters
are independent because polynomial domination compares baselines along `k` and residue-class
spikes along `i` without interference.

*Why now?* Both axes are already formalized and reduce to the same `simulates_sysOfSize_iff`
arithmetic; `spike_growth_gap` (residue spike) and `pow_pow_succ_gap` (ladder) are precisely
the two inequalities a product embedding needs, so the construction is a *combination*, not a
new theory.

### 4. Universality: every countable poset embeds into the p-degrees

Conjecture: every countable partial order order-embeds into
`Antisymmetrization (ProofSystem ℕ) (· ≤ ·)`, mirroring the classical universality of the
Turing degrees. Directions 1–3 are the local moves (joins fail, density holds, products
embed); the global statement is a back-and-forth construction over prime-residue spike
gadgets.

*The key insight is* that polynomial-domination classes of `ℕ → ℕ` are rich enough to encode
arbitrary finite comparability/incomparability patterns via residue-class spike gadgets
(Direction 3 builds the two-dimensional case), and a back-and-forth argument over these
gadgets realizes any countable order type.

*Why now?* With `simulates_sysOfSize_iff` the embedding target is a concrete arithmetic
preorder on `ℕ → ℕ`; the gadget library for the back-and-forth is exactly the spike/ladder
constructions Directions 2–3 force us to build, so universality is the capstone once the
two-dimensional embedding is in hand.

### 5. Concrete bridge: instantiate the abstract degrees with named proof systems

The systems here (`linSystem`, `fibSystem`, `powSystem`, `spikeSystem`) are abstract size
models. Conjecture: the abstract separations lift to *named* propositional proof systems —
e.g. a `ProofSystem` instance for tree-like Resolution and one for Frege such that a known
exponential Resolution lower bound (pigeonhole) instantiates `no_simulation_of_hard`, yielding
`resolutionSystem < fregeSystem` as a theorem of this framework.

*The key insight is* that `no_simulation_of_hard` only needs (i) a linear-size proof family in
the strong system and (ii) a super-polynomial size lower bound in the weak system; both are in
the literature for PHP, so the missing piece is the *formal packaging* of a concrete proof
system as a `ProofSystem` record — not any new lower bound.

*Why now?* The abstraction layer is complete and now exercised across chains *and* antichains;
plugging in one concrete (or hypothesized) lower bound immediately converts the catalog's
order theory into statements about genuine proof complexity, closing the loop of the
Cook–Reckhow program.
