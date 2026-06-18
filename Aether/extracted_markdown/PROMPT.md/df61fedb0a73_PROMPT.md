
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

**Title**: This cycle delivered `Catalog/Novelty/FibCarmichaelStructure.lean`, a self-conta
**Domain**: Applications
**Mathematical framing**: # Future Directions — Fibonacci Rank of Apparition, Structure Cycle

## Synthesis

This cycle delivered `Catalog/Novelty/FibCarmichaelStructure.lean`, a self-contained,
`sorry`-free deepening of the entry-point program begun in
`Catalog/Novelty/FibonacciEntryPointDuality.lean`. The previous cycle isolated the master
*duality*

```
p ∣ F n  ↔  z(p) ∣ n            (z = fibEntry, the rank of apparition)
```

but had to work around a standing gap: nothing guaranteed that `z(p)` is *defined* (positive)
for a given modulus, and the duality treated `z` as an opaque function. This cycle closes both
gaps. We proved that `z` is **total** on `p ≥ 1` (`exists_pos_fib_dvd`, `fibEntry_pos`) by a
genuinely dynamical/homotopical argument — the apparition index is the *first return time* of the
orbit of `(0,1)` under the invertible "Fibonacci shift" on the finite phase space
`ZMod p × ZMod p` — and we showed that `z` is a **morphism of divisibility lattices**:

* `fib_dvd_gcd_iff` — `z` sends gcd to meet: `p ∣ F(gcd m n) ↔ p ∣ F m ∧ p ∣ F n`.
* `fibEntry_coprime_mul` — `z` sends coprime products to lcm: `z(m·n) = lcm(z m)(z n)`.
* `fibEntry_prod_coprime` / `fibEntry_squarefree` — the lcm law for arbitrary pairwise-coprime
  finite products and for squarefree moduli, recombining via the exact mechanism that powers the
  Korselt identity in `Catalog/Novelty/KorseltCarmichael.lean`.

The unifying realization is that the divisibility set `{ n | p ∣ F n }` is *literally* the
principal ideal `(z p) ⊆ (ℕ, ∣)`, so every lattice identity among these sets descends to an
identity of generators via one tiny lemma (`dvd_eq_of_dvd_iff`). This turns the entry point into
a structured arithmetic object rather than an ad hoc minimum.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `exists_pos_fib_dvd` | every `p ≥ 1` divides some `F k`, `k > 0` | proved, axioms = `propext, Classical.choice, Quot.sound` |
| `fibEntry_pos` | `z(p) > 0` for `p ≥ 1` (totality) | proved |
| `fib_dvd_gcd_iff` | meet law for simultaneous apparition | proved |
| `fibEntry_coprime_mul` | lcm law `z(mn) = lcm(z m)(z n)` (coprime) | proved |
| `fibEntry_prod_coprime` | lcm law over pairwise-coprime finite products | proved |
| `fibEntry_squarefree` | `z(n) = ⋁_{p ∣ n} z(p)` for squarefree `n` | proved |

All main results are `sorry`-free and depend only on the standard Mathlib axioms.

## Research Directions

### 1. The prime-power refinement: `z(p^e)` and the Wall–Sun–Sun frontier

The lcm law reduces `z(n)` for squarefree `n` to its values on primes, but the *full*
factorization law needs `z(p^e)`. Conjecture: for every prime `p` and `e ≥ 1`,
`z(p^e) = p^max(0, e - e0(p)) · z(p)` where `e0(p)` is the largest power of `p` dividing
`F(z p)`; equivalently `z(p^e) = p^{e-1} · z(p)` for all `e` precisely when `p` is *not* a
Wall–Sun–Sun prime. This is falsifiable by a single counterexample prime and is exactly the
multiplicative companion to the lcm law already proven.
**The key insight is** that the `p`-adic valuation `v_p(F n)` is, by the Lifting-the-Exponent
philosophy, `v_p(F(z p)) + v_p(n / z p)` once `z(p) ∣ n`, so the entire prime-power behaviour is
governed by the single integer `v_p(F(z p))`. **Why now?** With `fibEntry_coprime_mul` and
`fibEntry_squarefree` in hand, the only missing ingredient for a *complete* formula
`z(n) = lcm_{p^e ‖ n} z(p^e)` is this prime-power case; the catalog already contains LTE-style
divisibility scaffolding to attack `v_p(F n)` directly.

### 2. `z` as a finite-index map and the Pisano period as orbit length

`exists_pos_fib_dvd` builds the apparition index as a first-return time on `ZMod p × ZMod p`.
Conjecture: the full orbit length (the Pisano period `π(p)`) equals `z(p) · ord` where `ord` is
the multiplicative order of `F(z(p)+1)` in `(ZMod p)^×`, and `z(p) ∣ π(p) ∣ z(p)·(p-1)`.
**The key insight is** that once the orbit returns to the line `{(0, *)}` after `z(p)` steps, the
second coordinate `F(z(p)+1)` is a unit acting by scalar multiplication on that line, so the
period is the apparition index times the order of that scalar — a clean semidirect-product
decomposition of the orbit. **Why now?** The `fibStep`/`fibPair` phase-space machinery is already
formalized and verified here; defining `π(p)` as `orderOf (fibStep p)` (the shift is an `Equiv`,
hence a permutation) makes both divisibilities purely group-theoretic and Mathlib-native.

### 3. A Fibonacci Korselt criterion (Fibonacci–Carmichael pseudoprimes)

`KorseltCarmichael.lean` proves Korselt's criterion `(p-1) ∣ (n-1)` for Fermat–Carmichael
numbers. The Fibonacci analogue replaces `p-1` by the apparition index. Conjecture: a squarefree
composite `n` is a *Fibonacci–Carmichael number* (i.e. `n ∣ F(n - (5|n))` for the Jacobi symbol
`(5|n)`) **iff** `z(p) ∣ n - (5|p)` for every prime `p ∣ n`. This is a falsifiable structural
criterion directly parallel to Korselt.
**The key insight is** that `fibEntry_squarefree` already expresses `z(n)` as the lcm of the
`z(p)`, so `n ∣ F m ↔ ∀ p ∣ n, z(p) ∣ m` — the multi-prime apparition condition is *exactly* a
conjunction of per-prime divisibilities, mirroring how the Korselt product recombination works.
**Why now?** Both halves now exist in the same catalog namespace: the squarefree lcm law (this
file) supplies the "for every prime factor" reduction, and `KorseltCarmichael.dvd_pow_sub_self`
supplies the template for the squarefree-recombination proof. Bridging them is a cross-domain
synthesis of two finished results rather than new theory from scratch.

### 4. The law of apparition `z(p) ∣ p - (5|p)` for primes

The deepest classical fact about `z` is Lucas's law of apparition: for a prime `p ≠ 5`,
`z(p) ∣ p - (5|p)`, with `z(p) ∣ p-1` when `5` is a QR mod `p` and `z(p) ∣ p+1` otherwise.
Conjecture (formalizable target): this holds, and combined with direction 1 yields a complete,
checkable formula for `z(n)` for all `n`. It is sharply falsifiable (any prime violating the
stated divisibility refutes it).
**The key insight is** that in `ZMod p` the Fibonacci closed form `F n = (φ^n - ψ^n)/√5` becomes
exact once `5` is a square mod `p`, so `z(p)` is the order of `φ/ψ` in `(ZMod p)^×` (the QR case)
or in the norm-1 subgroup of `(ZMod p)(√5)^×` (the non-QR case) — in both cases an order dividing
`p ∓ 1` by Lagrange. **Why now?** Mathlib has `ZMod`, quadratic reciprocity, and `legendreSym`;
the phase-space `fibStep` from this file already realizes `z(p)` as an order, so the remaining
work is to diagonalize `fibStep p` over `ZMod p` or its quadratic extension — concrete linear
algebra rather than open-ended search.

### 5. Functoriality: `z` as a lattice/monoid homomorphism object

We proved `z(gcd) = meet` (on apparition sets) and `z(coprime product) = lcm`. Conjecture: `z`
extends to a homomorphism from the monoid `(ℕ_{≥1}, ·, coprimality)` into the lattice
`(ℕ, lcm, gcd)` in the strongest possible sense — namely `z(m) ∣ z(n)` whenever `m ∣ n`
(monotonicity), and the apparition sets form a *sublattice* of the lattice of ideals of `(ℕ,∣)`
closed under the Fibonacci convolution. This is falsifiable: a single pair `m ∣ n` with
`z(m) ∤ z(n)` would refute monotonicity.
**The key insight is** that `m ∣ n` implies `F m ∣ F n` (strong divisibility, already in the
duality file as `fib_dvd_iff`), so anything killed by `F m` is killed by... — wait, the direction
must be tracked carefully through the duality, which is exactly what makes this a crisp, provable
lemma rather than folklore. **Why now?** Monotonicity is the last elementary structural property
of `z` not yet recorded, it follows in two lines from `fib_dvd_iff_fibEntry_dvd`, and it is the
natural capstone making `z` a first-class catalog object that downstream cycles (directions 1–4)
can cite as a homomorphism.

**Concept description**: # Future Directions — Fibonacci Rank of Apparition, Structure Cycle

## Synthesis

This cycle delivered `Catalog/Novelty/FibCarmichaelStructure.lean`, a self-contained,
`sorry`-free deepening of the entry-point program begun in
`Catalog/Novelty/FibonacciEntryPointDuality.lean`. The previous cycle isolated the master
*duality*

```
p ∣ F n  ↔  z(p) ∣ n            (z = fibEntry, the rank of apparition)
```

but had to work around a standing gap: nothing guaranteed that `z(p)` is *defined* (positive)
for a given modulus, and the duality treated `z` as an opaque function. This cycle closes both
gaps. We proved that `z` is **total** on `p ≥ 1` (`exists_pos_fib_dvd`, `fibEntry_pos`) by a
genuinely dynamical/homotopical argument — the apparition index is the *first return time* of the
orbit of `(0,1)` under the invertible "Fibonacci shift" on the finite phase space
`ZMod p × ZMod p` — and we showed that `z` is a **morphism of divisibility lattices**:

* `fib_dvd_gcd_iff` — `z` sends gcd to meet: `p ∣ F(gcd m n) ↔ p ∣ F m ∧ p ∣ F n`.
* `fibEntry_coprime_mul` — `z` sends coprime products to lcm: `z(m·n) = lcm(z m)(z n)`.
* `fibEntry_prod_coprime` / `fibEntry_squarefree` — the lcm law for arbitrary pairwise-coprime
  finite products and for squarefree moduli, recombining via the exact mechanism that powers the
  Korselt identity in `Catalog/Novelty/KorseltCarmichael.lean`.

The unifying realization is that the divisibility set `{ n | p ∣ F n }` is *literally* the
principal ideal `(z p) ⊆ (ℕ, ∣)`, so every lattice identity among these sets descends to an
identity of generators via one tiny lemma (`dvd_eq_of_dvd_iff`). This turns the entry point into
a structured arithmetic object rather than an ad hoc minimum.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `exists_pos_fib_dvd` | every `p ≥ 1` divides some `F k`, `k > 0` | proved, axioms = `propext, Classical.choice, Quot.sound` |
| `fibEntry_pos` | `z(p) > 0` for `p ≥ 1` (totality) | proved |
| `fib_dvd_gcd_iff` | meet law for simultaneous apparition | proved |
| `fibEntry_coprime_mul` | lcm law `z(mn) = lcm(z m)(z n)` (coprime) | proved |
| `fibEntry_prod_coprime` | lcm law over pairwise-coprime finite products | proved |
| `fibEntry_squarefree` | `z(n) = ⋁_{p ∣ n} z(p)` for squarefree `n` | proved |

All main results are `sorry`-free and depend only on the standard Mathlib axioms.

## Research Directions

### 1. The prime-power refinement: `z(p^e)` and the Wall–Sun–Sun frontier

The lcm law reduces `z(n)` for squarefree `n` to its values on primes, but the *full*
factorization law needs `z(p^e)`. Conjecture: for every prime `p` and `e ≥ 1`,
`z(p^e) = p^max(0, e - e0(p)) · z(p)` where `e0(p)` is the largest power of `p` dividing
`F(z p)`; equivalently `z(p^e) = p^{e-1} · z(p)` for all `e` precisely when `p` is *not* a
Wall–Sun–Sun prime. This is falsifiable by a single counterexample prime and is exactly the
multiplicative companion to the lcm law already proven.
**The key insight is** that the `p`-adic valuation `v_p(F n)` is, by the Lifting-the-Exponent
philosophy, `v_p(F(z p)) + v_p(n / z p)` once `z(p) ∣ n`, so the entire prime-power behaviour is
governed by the single integer `v_p(F(z p))`. **Why now?** With `fibEntry_coprime_mul` and
`fibEntry_squarefree` in hand, the only missing ingredient for a *complete* formula
`z(n) = lcm_{p^e ‖ n} z(p^e)` is this prime-power case; the catalog already contains LTE-style
divisibility scaffolding to attack `v_p(F n)` directly.

### 2. `z` as a finite-index map and the Pisano period as orbit length

`exists_pos_fib_dvd` builds the apparition index as a first-return time on `ZMod p × ZMod p`.
Conjecture: the full orbit length (the Pisano period `π(p)`) equals `z(p) · ord` where `ord` is
the multiplicative order of `F(z(p)+1)` in `(ZMod p)^×`, and `z(p) ∣ π(p) ∣ z(p)·(p-1)`.
**The key insight is** that once the orbit returns to the line `{(0, *)}` after `z(p)` steps, the
second coordinate `F(z(p)+1)` is a unit acting by scalar multiplication on that line, so the
period is the apparition index times the order of that scalar — a clean semidirect-product
decomposition of the orbit. **Why now?** The `fibStep`/`fibPair` phase-space machinery is already
formalized and verified here; defining `π(p)` as `orderOf (fibStep p)` (the shift is an `Equiv`,
hence a permutation) makes both divisibilities purely group-theoretic and Mathlib-native.

### 3. A Fibonacci Korselt criterion (Fibonacci–Carmichael pseudoprimes)

`KorseltCarmichael.lean` proves Korselt's criterion `(p-1) ∣ (n-1)` for Fermat–Carmichael
numbers. The Fibonacci analogue replaces `p-1` by the apparition index. Conjecture: a squarefree
composite `n` is a *Fibonacci–Carmichael number* (i.e. `n ∣ F(n - (5|n))` for the Jacobi symbol
`(5|n)`) **iff** `z(p) ∣ n - (5|p)` for every prime `p ∣ n`. This is a falsifiable structural
criterion directly parallel to Korselt.
**The key insight is** that `fibEntry_squarefree` already expresses `z(n)` as the lcm of the
`z(p)`, so `n ∣ F m ↔ ∀ p ∣ n, z(p) ∣ m` — the multi-prime apparition condition is *exactly* a
conjunction of per-prime divisibilities, mirroring how the Korselt product recombination works.
**Why now?** Both halves now exist in the same catalog namespace: the squarefree lcm law (this
file) supplies the "for every prime factor" reduction, and `KorseltCarmichael.dvd_pow_sub_self`
supplies the template for the squarefree-recombination proof. Bridging them is a cross-domain
synthesis of two finished results rather than new theory from scratch.

### 4. The law of apparition `z(p) ∣ p - (5|p)` for primes

The deepest classical fact about `z` is Lucas's law of apparition: for a prime `p ≠ 5`,
`z(p) ∣ p - (5|p)`, with `z(p) ∣ p-1` when `5` is a QR mod `p` and `z(p) ∣ p+1` otherwise.
Conjecture (formalizable target): this holds, and combined with direction 1 yields a complete,
checkable formula for `z(n)` for all `n`. It is sharply falsifiable (any prime violating the
stated divisibility refutes it).
**The key insight is** that in `ZMod p` the Fibonacci closed form `F n = (φ^n - ψ^n)/√5` becomes
exact once `5` is a square mod `p`, so `z(p)` is the order of `φ/ψ` in `(ZMod p)^×` (the QR case)
or in the norm-1 subgroup of `(ZMod p)(√5)^×` (the non-QR case) — in both cases an order dividing
`p ∓ 1` by Lagrange. **Why now?** Mathlib has `ZMod`, quadratic reciprocity, and `legendreSym`;
the phase-space `fibStep` from this file already realizes `z(p)` as an order, so the remaining
work is to diagonalize `fibStep p` over `ZMod p` or its quadratic extension — concrete linear
algebra rather than open-ended search.

### 5. Functoriality: `z` as a lattice/monoid homomorphism object

We proved `z(gcd) = meet` (on apparition sets) and `z(coprime product) = lcm`. Conjecture: `z`
extends to a homomorphism from the monoid `(ℕ_{≥1}, ·, coprimality)` into the lattice
`(ℕ, lcm, gcd)` in the strongest possible sense — namely `z(m) ∣ z(n)` whenever `m ∣ n`
(monotonicity), and the apparition sets form a *sublattice* of the lattice of ideals of `(ℕ,∣)`
closed under the Fibonacci convolution. This is falsifiable: a single pair `m ∣ n` with
`z(m) ∤ z(n)` would refute monotonicity.
**The key insight is** that `m ∣ n` implies `F m ∣ F n` (strong divisibility, already in the
duality file as `fib_dvd_iff`), so anything killed by `F m` is killed by... — wait, the direction
must be tracked carefully through the duality, which is exactly what makes this a crisp, provable
lemma rather than folklore. **Why now?** Monotonicity is the last elementary structural property
of `z` not yet recorded, it follows in two lines from `fib_dvd_iff_fibEntry_dvd`, and it is the
natural capstone making `z` a first-class catalog object that downstream cycles (directions 1–4)
can cite as a homomorphism.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v10 Depth Requirements -- Conceptual Unifier Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Conceptual Unification (Grothendieck style)**. Search for deep, hidden structures, universal patterns, and bridges across domains.

### RESEARCH CORE METHODOLOGY:
1. **Abstract Structural Patterns**: Frame your objects and mappings in terms of universal structures, symmetries, and invariant properties. Look for the underlying categorical, topological, or algebraic foundations that make the specific problem a special case of a deeper truth.
2. **Cross-Domain Bridges**: Connect apparently distinct mathematical worlds (e.g. applying algebraic structures to computational complexity, or geometry to logic).
3. **Generalization Over Specialization**: Prefer elegant, universal formulations that unify multiple separate facts into single, coherent conceptual frameworks.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
