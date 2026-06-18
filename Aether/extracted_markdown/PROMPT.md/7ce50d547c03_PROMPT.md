
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are leading a research team: Hypothesizer, Experimenter, Analyst,
Critic, and Synthesist. Run the loop:
Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate.
Your ONLY job is to produce **new Lean 4 code** and **take good notes**
for the next team.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by theorem declarations)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.
5. **Lab Notebook** as `-- !-- Lab Notebook -- !--` comment blocks
   in each .lean file: Hypothesis, Result, Insight, Failure analysis.

            ### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
            - NO `ARTICLE.md`
            - NO `RESEARCH_PAPER.md`
            - NO `demo.py` / `algorithms.py`
            - NO HTML widgets
            - NO `PACKAGE.json`
            - NO prose for human readers (except FUTURE_DIRECTIONS.md)

            ### WHY THIS NARROW:
            The Lean 4 file IS the deliverable. A self-contained Lean file with
            3-5 world-class theorems is worth more than 30K characters of prose
            about trivial results. Focus 100% of your compute on the math.
            If your work is genuinely world-class, the packaging step is dispatched
            automatically and cheaply.

            ### CATALOG SYNTHESIS (required — read the catalog context below):
            The Catalog Context and Recent Discoveries sections list existing theorems
            already proven in this project. You MUST analyze these and combine concepts
            from the catalog with the research direction above. Specifically:

            1. **Identify relevant catalog theorems** — Which existing results connect
               to your research direction? Cite them by name in your proof sketches.
            2. **Build on catalog foundations** — Your theorems should EXTEND or
               GENERALIZE catalog results, not reprove them from scratch. Use `import`
               and reference existing definitions and lemmas where possible.
            3. **Combine concepts across domains** — The most valuable theorems connect
               ideas from different catalog domains (e.g., applying algebraic structures
               to topological problems, or using combinatorial arguments in number theory).
               Look for cross-domain connections in the catalog context.
            4. **Avoid duplication** — Check the catalog context before proving. If a
               similar result already exists, extend it rather than reproving it.


## Concept

**Title**: **order-theoretic core of the Cook–Reckhow program** as a
**Domain**: Applications
**Mathematical framing**: # Future Directions: Proof-System Collapse Theory × Fibonacci Separations

## Synthesis

This cycle built the **order-theoretic core of the Cook–Reckhow program** as a
self-contained, machine-checked theory and *bridged it to the catalog's Fibonacci /
entry-point number theory*.

Two new Lean files were added, both elaborating cleanly with `sorry = 0` and only the
standard axioms `propext, Classical.choice, Quot.sound`:

* `Catalog/Logic/ProofComplexity/SimulationPreorder.lean` — the abstract **p-simulation
  preorder** on proof systems. We model a (Cook–Reckhow) proof system as a
  completeness-witnessing map `proves : Proof → Thm` with a `size : Proof → ℕ`, define
  `Simulates P Q` (polynomial-blow-up translation of `Q`-proofs into `P`-proofs of the same
  theorem), and prove it is a genuine `Preorder` (`Simulates_refl`, `Simulates_trans`,
  `simulationPreorder`). Mutual simulation `PEquiv` is registered as a `Setoid` — its
  quotient is the poset of **p-degrees**. The decisive structural fact is that transitivity
  is *exactly* closure of the polynomial blow-up class under composition
  (`polyBounded_comp`).

* `Catalog/Shared/CarmichaelHelper.lean` — supplies the previously-missing **prime-index
  case** of Carmichael's primitive-divisor theorem, `fib_primitive_divisor_prime`. For
  prime `n`, the entry-point argument is *free*: any prime `p ∣ F n` has entry point
  dividing the prime `n`, which cannot be `1` (since `F 1 = 1`), hence equals `n`, so `p`
  is primitive. This closes the import that `Shared.CarmichaelProof` and
  `Speculative.AutoResearch.CarmichaelComposite` depended on.

The bridge is the theorem chain `two_pow_le_fib → not_polyBounded_fib →
no_poly_bound_dominates_fib → no_simulation_of_fib_hard`: Fibonacci growth is
super-polynomial, so a proof system that needs `F n`-size proofs of theorems another system
proves in linear size **cannot** be p-simulated by it. This is the precise sense in which
the catalog's Fibonacci lower bounds are *separation witnesses* in the simulation preorder.

## Results Summary

| Theorem | File | Statement |
|---|---|---|
| `simulationPreorder` | SimulationPreorder | `Simulates` is a `Preorder` on proof systems |
| `pEquivSetoid` | SimulationPreorder | p-equivalence is a `Setoid`; quotient = p-degrees |
| `not_polyBounded_fib` | SimulationPreorder | Fibonacci growth is not polynomially bounded |
| `no_simulation_of_fib_hard` | SimulationPreorder | Fibonacci size lower bounds separate systems |
| `fib_primitive_divisor_prime` | CarmichaelHelper | Carmichael, prime-index case (entry point) |

---

## Direction 1 — Close the composite tail of Carmichael (`n > 10000`)

`Shared.CarmichaelProof.fib_carmichael_composite` still contains a single `sorry`: the
*infinite* tail of composite indices `n > 10000`, beyond the `native_decide` range. The
conjecture is the classical statement: **every composite `n > 12` has `F n` with a
primitive prime divisor.** The key insight is that the primitive part of `F n` equals the
"Fibonacci-cyclotomic" value `Ψ_n` up to at most one *intrinsic* prime factor `p` with
`n = p · α(p)`, and that `Ψ_n` strictly exceeds `p` once `n` is large — so the primitive
part is `> 1`. Why now? The finite case is already verified computationally and the
entry-point/`gcd` infrastructure (`bridge_lemma`, `fibEntryPt_dvd_of_fib_dvd`,
`primPart_coprime_proper_divs`) is in place; what remains is purely the analytic size
bound `|Ψ_n| > p`, which is a self-contained inequality about products of `|α^d - β^d|`
over divisors `d ∣ n`, now reachable on top of the `two_pow_le_fib`-style growth lemmas
introduced this cycle.

## Direction 2 — A strict-collapse dichotomy for the simulation preorder

We proved `Simulates` is a preorder; the next falsifiable step is a **collapse/separation
dichotomy**: for the two-element antichain `{P, Q}`, either `PEquiv P Q` (collapse) or one
of `¬ Simulates P Q`, `¬ Simulates Q P` holds with an explicit super-polynomial witness.
The key insight is that `no_simulation_of_fib_hard` already gives a *reusable separation
template* — any function `s : ℕ → ℕ` that is monotone but dominates `F` (hence is not
`PolyBounded`, by `no_poly_bound_dominates_fib`) yields a separating pair. Why now? The
template is generic over the hardness function; replacing `Nat.fib` by any provably
super-polynomial catalog sequence (e.g. the Gilbert–Varshamov or Shannon-entropy growth
rates already in `Speculative/AutoResearch`) instantly manufactures new separations,
turning the single Fibonacci bridge into a *family* of preorder separations.

## Direction 3 — Antisymmetrization: the partial order of p-degrees

`pEquivSetoid` gives the equivalence whose classes are p-degrees; the conjecture is that
`Quotient pEquivSetoid` carries a genuine `PartialOrder` induced by `Simulates`, i.e. the
simulation preorder antisymmetrizes to a poset, and that this poset is **not** a lattice in
general. The key insight is that `Simulates` descends to the quotient precisely because it
is `PEquiv`-respecting on both arguments (immediate from `Simulates_trans`), so the order
is well-defined; non-latticeness should follow from exhibiting two incomparable degrees
with two distinct minimal upper bounds. Why now? Mathlib's `Antisymmetrization` API plus the
`Preorder` instance proven this cycle make the poset construction essentially free, and the
separation template of Direction 2 supplies the incomparable degrees needed to refute the
lattice hypothesis.

## Direction 4 — Quantitative entry-point spectrum for prime indices

`fib_primitive_divisor_prime` shows *every* prime factor of `F p` (prime `p`) is primitive.
The sharper, falsifiable conjecture: for prime `p`, the number of *distinct* primitive prime
divisors of `F p` is exactly `ω(F p)` (all of them), and each has entry point exactly `p`,
so `α(q) = p` for every `q ∣ F p`. The key insight is that the entry-point map restricted to
prime divisors of `F p` is *constant* (equal to `p`) when the index is prime — a rigidity
that fails for composite indices, giving a clean arithmetic invariant distinguishing prime
from composite Fibonacci indices. Why now? The `dvd_fib_gcd_of_dvd` workhorse lemma proven
this cycle reduces the whole claim to `gcd p k ∈ {1, p}`, so the spectrum statement is a
short hop from what is already formalized.

## Direction 5 — Closure-class robustness of the blow-up notion

We encoded "polynomially bounded" as `∃ k, f n + 1 ≤ (n+2)^k` and proved it is closed under
composition (`polyBounded_comp`). The conjecture is that the resulting preorder is
**invariant** under swapping this class for any other *composition-closed, super-polynomially
bounded* class `C` (e.g. quasi-polynomial `2^{(log n)^c}`), in the sense that `Simulates_C`
is again a preorder and the Fibonacci separation persists iff `Nat.fib ∉ C`. The key insight
is that *only two* properties of the blow-up class were used — closure under composition
(for transitivity) and `Nat.fib ∉ C` (for separation) — so the entire development is
parametric in `C`. Why now? Abstracting `PolyBounded` to a `class GrowthClass` with these two
fields would let the next cycle instantiate quasi-polynomial and sub-exponential simulations
*without reproving the order structure*, directly probing where in the growth hierarchy
Fibonacci-style separations survive.

**Concept description**: # Future Directions: Proof-System Collapse Theory × Fibonacci Separations

## Synthesis

This cycle built the **order-theoretic core of the Cook–Reckhow program** as a
self-contained, machine-checked theory and *bridged it to the catalog's Fibonacci /
entry-point number theory*.

Two new Lean files were added, both elaborating cleanly with `sorry = 0` and only the
standard axioms `propext, Classical.choice, Quot.sound`:

* `Catalog/Logic/ProofComplexity/SimulationPreorder.lean` — the abstract **p-simulation
  preorder** on proof systems. We model a (Cook–Reckhow) proof system as a
  completeness-witnessing map `proves : Proof → Thm` with a `size : Proof → ℕ`, define
  `Simulates P Q` (polynomial-blow-up translation of `Q`-proofs into `P`-proofs of the same
  theorem), and prove it is a genuine `Preorder` (`Simulates_refl`, `Simulates_trans`,
  `simulationPreorder`). Mutual simulation `PEquiv` is registered as a `Setoid` — its
  quotient is the poset of **p-degrees**. The decisive structural fact is that transitivity
  is *exactly* closure of the polynomial blow-up class under composition
  (`polyBounded_comp`).

* `Catalog/Shared/CarmichaelHelper.lean` — supplies the previously-missing **prime-index
  case** of Carmichael's primitive-divisor theorem, `fib_primitive_divisor_prime`. For
  prime `n`, the entry-point argument is *free*: any prime `p ∣ F n` has entry point
  dividing the prime `n`, which cannot be `1` (since `F 1 = 1`), hence equals `n`, so `p`
  is primitive. This closes the import that `Shared.CarmichaelProof` and
  `Speculative.AutoResearch.CarmichaelComposite` depended on.

The bridge is the theorem chain `two_pow_le_fib → not_polyBounded_fib →
no_poly_bound_dominates_fib → no_simulation_of_fib_hard`: Fibonacci growth is
super-polynomial, so a proof system that needs `F n`-size proofs of theorems another system
proves in linear size **cannot** be p-simulated by it. This is the precise sense in which
the catalog's Fibonacci lower bounds are *separation witnesses* in the simulation preorder.

## Results Summary

| Theorem | File | Statement |
|---|---|---|
| `simulationPreorder` | SimulationPreorder | `Simulates` is a `Preorder` on proof systems |
| `pEquivSetoid` | SimulationPreorder | p-equivalence is a `Setoid`; quotient = p-degrees |
| `not_polyBounded_fib` | SimulationPreorder | Fibonacci growth is not polynomially bounded |
| `no_simulation_of_fib_hard` | SimulationPreorder | Fibonacci size lower bounds separate systems |
| `fib_primitive_divisor_prime` | CarmichaelHelper | Carmichael, prime-index case (entry point) |

---

## Direction 1 — Close the composite tail of Carmichael (`n > 10000`)

`Shared.CarmichaelProof.fib_carmichael_composite` still contains a single `sorry`: the
*infinite* tail of composite indices `n > 10000`, beyond the `native_decide` range. The
conjecture is the classical statement: **every composite `n > 12` has `F n` with a
primitive prime divisor.** The key insight is that the primitive part of `F n` equals the
"Fibonacci-cyclotomic" value `Ψ_n` up to at most one *intrinsic* prime factor `p` with
`n = p · α(p)`, and that `Ψ_n` strictly exceeds `p` once `n` is large — so the primitive
part is `> 1`. Why now? The finite case is already verified computationally and the
entry-point/`gcd` infrastructure (`bridge_lemma`, `fibEntryPt_dvd_of_fib_dvd`,
`primPart_coprime_proper_divs`) is in place; what remains is purely the analytic size
bound `|Ψ_n| > p`, which is a self-contained inequality about products of `|α^d - β^d|`
over divisors `d ∣ n`, now reachable on top of the `two_pow_le_fib`-style growth lemmas
introduced this cycle.

## Direction 2 — A strict-collapse dichotomy for the simulation preorder

We proved `Simulates` is a preorder; the next falsifiable step is a **collapse/separation
dichotomy**: for the two-element antichain `{P, Q}`, either `PEquiv P Q` (collapse) or one
of `¬ Simulates P Q`, `¬ Simulates Q P` holds with an explicit super-polynomial witness.
The key insight is that `no_simulation_of_fib_hard` already gives a *reusable separation
template* — any function `s : ℕ → ℕ` that is monotone but dominates `F` (hence is not
`PolyBounded`, by `no_poly_bound_dominates_fib`) yields a separating pair. Why now? The
template is generic over the hardness function; replacing `Nat.fib` by any provably
super-polynomial catalog sequence (e.g. the Gilbert–Varshamov or Shannon-entropy growth
rates already in `Speculative/AutoResearch`) instantly manufactures new separations,
turning the single Fibonacci bridge into a *family* of preorder separations.

## Direction 3 — Antisymmetrization: the partial order of p-degrees

`pEquivSetoid` gives the equivalence whose classes are p-degrees; the conjecture is that
`Quotient pEquivSetoid` carries a genuine `PartialOrder` induced by `Simulates`, i.e. the
simulation preorder antisymmetrizes to a poset, and that this poset is **not** a lattice in
general. The key insight is that `Simulates` descends to the quotient precisely because it
is `PEquiv`-respecting on both arguments (immediate from `Simulates_trans`), so the order
is well-defined; non-latticeness should follow from exhibiting two incomparable degrees
with two distinct minimal upper bounds. Why now? Mathlib's `Antisymmetrization` API plus the
`Preorder` instance proven this cycle make the poset construction essentially free, and the
separation template of Direction 2 supplies the incomparable degrees needed to refute the
lattice hypothesis.

## Direction 4 — Quantitative entry-point spectrum for prime indices

`fib_primitive_divisor_prime` shows *every* prime factor of `F p` (prime `p`) is primitive.
The sharper, falsifiable conjecture: for prime `p`, the number of *distinct* primitive prime
divisors of `F p` is exactly `ω(F p)` (all of them), and each has entry point exactly `p`,
so `α(q) = p` for every `q ∣ F p`. The key insight is that the entry-point map restricted to
prime divisors of `F p` is *constant* (equal to `p`) when the index is prime — a rigidity
that fails for composite indices, giving a clean arithmetic invariant distinguishing prime
from composite Fibonacci indices. Why now? The `dvd_fib_gcd_of_dvd` workhorse lemma proven
this cycle reduces the whole claim to `gcd p k ∈ {1, p}`, so the spectrum statement is a
short hop from what is already formalized.

## Direction 5 — Closure-class robustness of the blow-up notion

We encoded "polynomially bounded" as `∃ k, f n + 1 ≤ (n+2)^k` and proved it is closed under
composition (`polyBounded_comp`). The conjecture is that the resulting preorder is
**invariant** under swapping this class for any other *composition-closed, super-polynomially
bounded* class `C` (e.g. quasi-polynomial `2^{(log n)^c}`), in the sense that `Simulates_C`
is again a preorder and the Fibonacci separation persists iff `Nat.fib ∉ C`. The key insight
is that *only two* properties of the blow-up class were used — closure under composition
(for transitivity) and `Nat.fib ∉ C` (for separation) — so the entire development is
parametric in `C`. Why now? Abstracting `PolyBounded` to a `class GrowthClass` with these two
fields would let the next cycle instantiate quasi-polynomial and sub-exponential simulations
*without reproving the order structure*, directly probing where in the growth hierarchy
Fibonacci-style separations survive.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v13 Depth Requirements -- First-Principles Grounding Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **First-Principles Grounding**. Focus on elegance, structural simplicity, and building blocks of deep theories.

### RESEARCH CORE METHODOLOGY:
1. **Foundational Clarity**: Build theories starting from clean, minimal, first-principles assumptions. Keep definitions mathematically pure, elegant, and simple.
2. **Lemma Factorization**: Decompose large, complex theorems into a hierarchy of beautiful, standalone, reusable lemmas. Each lemma should be a complete mathematical statement of independent interest.
3. **Explanatory Elegance**: Design proofs that are not only correct but structurally beautiful and easy to understand. Let the proofs explain the mathematical mechanism.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
