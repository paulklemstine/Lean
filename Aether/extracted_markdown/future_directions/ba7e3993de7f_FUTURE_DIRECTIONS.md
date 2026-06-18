# Future Directions — Landauer Thermodynamics of Proof Length

## Synthesis

The new module `Catalog/Logic/ProofThermodynamics.lean` turns the *length-graded
proof metric* of `Logic.ProofMetric` (`minDerivLen`, `derivOfLen_comp`,
`minDerivLen_triangle`, `minDerivLen_chain_eq`, `minDerivLen_chain_geodesic`) into a
genuine **energetic functional** on proofs by applying Landauer's principle. The single
organizing observation is that the positive linear map

  `length ↦ length · T · ln 2`

transports every order-theoretic fact about proof length into a thermodynamic law:
monotonicity becomes "shorter proofs are strictly cheaper" (`landauerCost_strictMono`),
the triangle inequality becomes Landauer subadditivity of cost (`minCost_triangle`), the
chain's geodesic rigidity becomes zero-dissipation (`minCost_chain_geodesic`), and the
unboundedness of proof length becomes a Chaitin-style "no global cost bound"
(`cost_unbounded`). The reflexive geodesic costs nothing (`minCost_self`), while every
non-trivial proof costs at least one quantum `T · ln 2` (`landauerCost_quantum`).

## Results Summary (all `sorry`-free, axioms `propext/Classical.choice/Quot.sound`)

- `landauerCost_nonneg`, `landauerCost_mono`, `landauerCost_strictMono` — cost is a
  nonnegative, (strictly at `T>0`) increasing functional of proof length.
- `landauerCost_quantum` — the irreducible one-bit quantum `T · ln 2` for any proof of
  length `≥ 1`.
- `minCost_self` — tautologies are thermodynamically free.
- `minCost_triangle` — Landauer subadditivity: composing proofs never costs more than the
  sum of the legs (scaling of `minDerivLen_triangle`).
- `minCost_chain_eq` / `minCost_chain_geodesic` — closed form `(b-a)·T·ln 2` and exact
  additivity (zero dissipation) on the chain theory (scaling of `minDerivLen_chain_geodesic`).
- `cost_unbounded` — at any positive temperature the minimal proof cost exceeds every
  finite bound `B` over the theorem set; the proof-theoretic analogue of Chaitin's theorem.

## Research Directions

### 1. A second law: cost is monotone under proof rewriting / cut elimination
Conjecture: equip a theory with a *rewrite relation* on derivations (e.g. cut-elimination
steps, or detour reductions) and define the dissipated cost of a rewrite as
`landauerCost (len before) T − landauerCost (len after) T`. Then any normalizing rewrite
sequence has nonnegative total dissipation, and the normal form realizes `minCost`. This is
falsifiable: exhibit a theory and rewrite where normalization *increases* length (cut
elimination can blow up proof size!), giving a *negative* dissipation step — a concrete
"Maxwell demon" of proof theory. The key insight is that `minCost` is the energy of the
geodesic, so any rewrite that does not reach the geodesic must leave residual free energy,
and length-increasing normalization is exactly an entropy-consuming (work-requiring) step.
Why now? `derivOfLen_comp` and `minDerivLen_triangle` already give the additive accounting
needed to bound rewrite dissipation; only a rewrite relation must be added.

### 2. Sharp Chaitin constant: incompressibility with an explicit growth rate
Conjecture: strengthen `cost_unbounded` from "unbounded" to a *rate*: on the chain,
`minCost chainT 0 n T = n · T · ln 2`, so the cost of the cheapest proof of the `n`-th
theorem grows exactly linearly in the *index* but, under a length-`Θ(log n)` naming of
statements, *exponentially in description length* — recovering the conjectured `Θ(2^n)`
average cost for statements of description length `n`. Falsifiable: pick any encoding of
chain statements as bitstrings and prove (or refute) `average over length-n names of
minCost = Θ(2^n)`. The key insight is that the chain already separates *index* from
*description length*, so the exponential gap between them is the precise origin of the
`Θ(2^n)` average-cost law in the concept brief. Why now? `minCost_chain_eq` supplies the
exact per-statement cost; only the counting/encoding layer remains.

### 3. Temperature phase transition between geodesic and generic theories
Conjecture: define the *dissipation gap* of a triple `(a,b,c)` as
`minCost a b T + minCost b c T − minCost a c T ≥ 0`. The chain has gap `≡ 0`
(`minCost_chain_geodesic`); a theory with genuine "shortcuts" (an axiom skipping several
chain steps) has a *strictly positive* gap on some triple. Conjecture a dichotomy: a theory
is geodesic (gap `≡ 0`) iff its axiom relation is the covering relation of a partial order.
Falsifiable: build a non-covering theory and prove a strict gap; or prove the order-theoretic
characterization. The key insight is that zero dissipation is exactly the absence of proof
shortcuts, i.e. the metric is already the graph distance of the Hasse diagram. Why now? The
gap is definable directly from `minCost`, and `minDerivLen_triangle` guarantees its
nonnegativity, so only the strict/zero classification is open.

### 4. Loop cost spectra and a Frobenius energy
Conjecture: by `ProofMetric.loopLengths_add` the lengths of closed derivations `a ⊢ a`
form an additive submonoid `S ⊆ ℕ`; hence the achievable *loop costs* are
`{s · T · ln 2 : s ∈ S}`. For a finitely generated `S` with Frobenius number `g`, every
energy above `(g+1)·T·ln 2` is realizable while a finite set below it is not — a
"spectral gap" in proof energy. Falsifiable: exhibit a theory whose loop-length monoid is,
say, `⟨3,5⟩` and verify the predicted forbidden energies `T·ln2, 2·T·ln2, 4·T·ln2`. The key
insight is that the numerical-semigroup structure already proven for loop *lengths* lifts
verbatim, under the Landauer scaling, to a quantized *energy spectrum* with a Frobenius gap.
Why now? The submonoid structure is already a catalog theorem; only the scaling and a
concrete generator computation are needed.

### 5. Cost as a quasi-pseudometric and its metric completion
Conjecture: `dCost T temp a b := minCost T a b temp` is an asymmetric ℝ≥0-valued
quasi-pseudometric (reflexivity from `minCost_self`, triangle from `minCost_triangle`); its
symmetrization `dCost a b + dCost b a` is a genuine pseudometric, and on the chain it equals
`|b−a|·T·ln 2`, the scaled graph metric. Falsifiable: prove the symmetrization satisfies the
pseudometric axioms in general, or exhibit a theory where it fails the triangle inequality
(it cannot, if the conjecture holds — so a counterexample refutes it). The key insight is
that Landauer scaling makes the proof *quasi-metric* land in ℝ≥0, opening the entire
Mathlib pseudometric/`EMetric` API (completions, balls, Lipschitz maps between theories) to
proof complexity. Why now? Both metric axioms are already proven as `minCost_self` and
`minCost_triangle`; wiring them into a Mathlib `PseudoMetricSpace`/`Quasi` instance is the
only remaining step.
