# Future Directions: Reversible Computing and Thermodynamic Efficiency

## Synthesis of this cycle

The catalog already contained the *exact* Landauer cost for **uniform n-bit erasure**
(`entropy_drop_uniform_erasure`, `landauer_cost_exact` in
`Computation/ReversibleTropicalThermodynamics.lean`) and an algebraic characterization of
reversibility as **zero entropy loss** (`zero_entropy_loss_iff_bijective`), together with
the ancilla-optimality theory in `Computation/TightAncillaBound.lean`. These were sharp
statements about *one* very special map (uniform erasure) and about *bijections*.

This cycle supplied the missing **general principle** that subsumes them. In
`Computation/LandauerLowerBound.lean` we prove the deterministic data-processing
inequality `H(f∗p) ≤ H(p)` for an **arbitrary** function `f` and **any** nonnegative
weight function `p`, with exact equality `H(f∗p) = H(p)` precisely for injective
(reversible) `f`. Erasure becomes the extremal collapse-to-a-point case, and the catalog's
zero-loss characterization becomes the equality boundary. The proof deliberately avoids
concavity/grouping machinery: the entire content is the pointwise domination
`f∗p(f x) ≥ p x` (a fiber sum dominates one of its terms) plus monotonicity of `log`.

In `Computation/ReversibleGates.lean` we then built the concrete universal gates — CNOT,
Toffoli, Fredkin — as honest bijections, proved them logically correct (XOR/COPY, AND/NOT,
controlled-SWAP), and **fed their bijectivity into both** the catalog's
`reversible_zero_entropy_cost` *and* the new `landauer_lower_bound_zero_of_injective`,
yielding a single statement per gate: it computes the intended function, loses no entropy,
and dissipates no heat on *every* input distribution. This is the cross-domain bridge
(algebra → information theory → thermodynamics) the catalog asked for.

## Results summary

- `shannonEntropy_pushforward_le` — deterministic data-processing inequality `H(f∗p) ≤ H(p)`.
- `shannonEntropy_pushforward_of_injective` — reversible maps preserve entropy exactly.
- `landauer_lower_bound` / `landauer_lower_bound_zero_of_injective` — dissipated heat is
  nonnegative in general and exactly zero for reversible maps.
- `{cnot,toffoli,fredkin}_involutive/_bijective` — the universal gates are reversible.
- `cnot_computes_xor/_copy`, `toffoli_computes_and/_not`, `fredkin_swaps_when_control` —
  logical correctness of each gate.
- `{cnot,toffoli,fredkin}_zero_entropy_loss` and `..._landauer_zero` — thermodynamic
  optimality of each gate, synthesizing the algebraic and information-theoretic results.

## Bold, falsifiable research directions

### 1. Quantitative Landauer bound: dissipation equals collapsed information

We proved `H(f∗p) ≤ H(p)`, but the *gap* should be an explicit, computable quantity:
the conditional entropy `H(p) − H(f∗p) = ∑_y f∗p(y) · H(p|fiber y)`, the expected entropy
of the fibers `f` glues together. **Conjecture:** for every `f` and distribution `p`,
`H(p) − H(f∗p) = ∑_y (f∗p y) · H(p_y)` where `p_y` is `p` renormalized on the fiber
`f⁻¹{y}`, and this equals `0` iff every fiber meeting the support is a singleton.
*The key insight is* that the entropy gap is not merely nonnegative — it is itself a
genuine Shannon entropy (the "information that f destroyed"), so Landauer's heat is an
*equality* `Q = kT · (expected fiber entropy)`, not just a bound. *Why now?* The pointwise
telescoping `∑ₓ p x (log f∗p(f x) − log p x)` already proved here is exactly the negative
of the fiber-conditional entropy; the grouping identity needed is a single application of
`Finset.sum_fiberwise`, so the equality is within immediate reach of the current file.

### 2. Subadditivity and the cost of composed pipelines

For a pipeline `g ∘ f`, the erased information should be subadditive in a precise sense.
**Conjecture:** `H(p) − H((g∘f)∗p) = (H(p) − H(f∗p)) + (H(f∗p) − H(g∗(f∗p)))`, i.e. the
Landauer costs of stages add exactly, and consequently `H((g∘f)∗p) ≤ H(f∗p) ≤ H(p)` is a
monotone tower. *The key insight is* that `(g∘f)∗p = g∗(f∗p)` (pushforward is functorial),
so total dissipation telescopes stage-by-stage and reversible stages can be inserted for
free anywhere in a pipeline. *Why now?* `pushforwardFun` is defined here and the functor
law `pushforwardFun (g∘f) p = pushforwardFun g (pushforwardFun f p)` is a direct
`Finset.sum_fiberwise`/`Finset.sum_biUnion` computation, after which monotonicity is a
two-line corollary of `shannonEntropy_pushforward_le`.

### 3. Bennett embedding saturates the data-processing inequality

The catalog's Bennett construction (`Computation/ReversibleSortingBennett.lean`,
`Computation/ReversibleTropicalThermodynamics.lean`'s `finite_step_reversible_extension`)
lifts any `f` to a bijection `x ↦ (f x, x)` on an enlarged space. **Conjecture:** the
Bennett lift `B_f(x) = (f x, x)` satisfies `H(B_f∗p) = H(p)` for all `p` (zero loss), and
the marginal of `B_f∗p` on the first coordinate is exactly `f∗p`; thus the *entire*
Landauer cost of `f` is precisely the entropy of the history register that Bennett's
construction stores. *The key insight is* that reversibility "pays" for the destroyed
information by *retaining* it in the ancilla, so direction 1's fiber entropy equals the
ancilla entropy of the Bennett lift. *Why now?* `B_f` is injective, so
`shannonEntropy_pushforward_of_injective` gives the zero-loss half immediately; the only
new step is computing the first-coordinate marginal, a `Finset.sum_product` exercise.

### 4. Toffoli universality with an explicit ancilla/garbage budget

Toffoli is universal for classical reversible computation. **Conjecture:** every Boolean
function `g : Bool^n → Bool` can be realized as the designated output wire of a composition
of Toffoli gates acting on `Bool^(n+a)` with `a` ancilla wires, and the minimal `a` is
controlled by `maxFiberSize` from `Computation/TightAncillaBound.lean` (the Toffoli network
needs at least `⌈log₂ maxFiberSize⌉` clean ancilla, matching the tight ancilla bound).
*The key insight is* that the abstract ancilla-optimality theorem already proven for
arbitrary functions should be *witnessed concretely* by Toffoli networks, closing the loop
between the gate library and the counting bound. *Why now?* `toffoli_computes_and`,
`toffoli_computes_not`, and `cnot_computes_copy` already give AND/NOT/COPY — a functionally
complete basis — so the universality direction is an induction on circuit structure, and
the lower bound is a direct citation of `tight_ancilla_bound`.

### 5. Reversible gates form a group; entropy loss is the trivial homomorphism

The reversible operations on `Bool^n` are exactly `Equiv.Perm (Bool^n)`, a finite group.
**Conjecture:** `uniformEntropyLoss` restricted to this group is the constant-zero map, and
more strongly the assignment "distribution ↦ pushed-forward distribution" is a genuine
group *action* of `Equiv.Perm (Bool^n)` on the simplex of distributions that preserves
Shannon entropy — making entropy an *invariant* of the reversible-computation group action.
*The key insight is* that thermodynamic freedom of reversible computing is a structural
group-theoretic fact: the heat functional factors through the quotient by the reversible
group, which is trivial on permutations. *Why now?* `shannonEntropy_pushforward_of_injective`
already proves entropy invariance for every bijection, and `pushforwardFun (e₂ ∘ e₁) = `
`pushforwardFun e₂ ∘ pushforwardFun e₁` (direction 2's functor law) supplies the action
axioms, so packaging it as a `MulAction` with an entropy-invariance lemma is mechanical.
