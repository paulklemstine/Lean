# The Eight Bridges: Space–Algebra Rosetta Stone

A comprehensive research project exploring eight fundamental dualities between algebraic structures and geometric spaces, unified by the "idempotent thread" — the equation **e² = e**.

## The Eight Bridges

| # | Bridge | Algebra | Geometry | Key Equation |
|---|--------|---------|----------|--------------|
| 1 | **Classical** (Grothendieck) | Commutative rings | Affine schemes | e² = e → Spec decomposes |
| 2 | **Stone Duality** (1936) | Boolean algebras | Stone spaces | a ∧ a = a (universal!) |
| 3 | **Gelfand Duality** (1943) | Comm. C*-algebras | Compact Hausdorff | p² = p = p* → clopens |
| 4 | **Pointfree Topology** | Frames / Locales | Spaces without points | Complemented elements |
| 5 | **NC Geometry** (Connes) | NC C*-algebras | Spectral triples | P² = P = P* (projections) |
| 6 | **Derived AG** (Lurie) | E∞-ring spectra | Derived stacks | e∘e ≃ e (up to homotopy) |
| 7 | **Tropical Geometry** | Tropical semiring | Polyhedral complexes | min(a,a) = a (all idempotent!) |
| 8 | **Quantum Geometry** | B(H) | Quantum state spaces | P² = P (measurements) |

## New Discoveries (Formally Verified)

1. **Idempotent Counting Formula:** |Idem(ℤ/nℤ)| = 2^ω(n), verified for n ≤ 210
2. **Boolean Algebra of Idempotents:** Idem(R) forms a Boolean algebra with e∧f = ef, e∨f = e+f−ef
3. **Newton's Quadratic Convergence:** defect(3e²−2e³) = defect(e)²·(2e−3)(2e+1)
4. **Peirce Decomposition:** x = exe + ex(1−e) + (1−e)xe + (1−e)x(1−e)
5. **Module Splitting:** im(e) ⊕ ker(e) = M for idempotent endomorphisms
6. **Tropicalization = Classical Limit:** structural analogy with ℏ → 0

## Project Structure

### Lean 4 Formalizations (zero `sorry` — all proofs complete)
- `Bridge1_Classical.lean` — Spec functor, complement idempotent, orthogonality, powers
- `Bridge2_Stone.lean` — Boolean algebra axioms, De Morgan, propositional logic
- `Bridge3_Gelfand.lean` — Projection structure, evaluation homomorphism
- `Bridge4_Pointfree.lean` — Lattice idempotency, interior/closure, clopen characterization
- `Bridge5_Noncommutative.lean` — Commutator, trace, commuting projections
- `Bridge6_Derived.lean` — Module splitting, idempotent range/kernel, trace invariance
- `Bridge7_Tropical.lean` — Universal idempotency, tropical distributivity, determinant
- `Bridge8_Quantum.lean` — Projection lattice, orthogonal sums, diagonal projections
- `CrossBridge_IdempotentThread.lean` — Cross-bridge relationships, ZMod counting
- `NewDiscoveries.lean` — All new results: counting formula, Boolean algebra, Newton, Peirce

### Python Demos
- `demos/bridge_explorer.py` — Interactive tour of all eight bridges
- `demos/quantum_projection_demo.py` — Quantum measurement as idempotent projection
- `demos/tropical_self_reference.py` — Tropical geometry's self-referential structure
- `demos/idempotent_counting_lab.py` — **NEW:** Counting formula verification, Newton's method
- `demos/peirce_decomposition_demo.py` — **NEW:** Peirce decomposition and projection lattice

### SVG Visuals
- `visuals/eight_bridges.svg` — Overview diagram of all eight bridges
- `visuals/idempotent_thread.svg` — The idempotent thread connecting all bridges
- `visuals/rosetta_stone_table.svg` — Summary table
- `visuals/quantum_classical_bridge.svg` — Quantum-classical correspondence
- `visuals/tropical_self_reference.svg` — Tropical self-reference
- `visuals/idempotent_hierarchy.svg` — **NEW:** The six-level idempotent density hierarchy
- `visuals/newton_convergence.svg` — **NEW:** Newton's method convergence visualization
- `visuals/peirce_decomposition.svg` — **NEW:** The four-component Peirce decomposition
- `visuals/crt_idempotent_cube.svg` — **NEW:** CRT idempotent cube for ℤ/30ℤ

### Written Output
- `ResearchPaper.md` — Full research paper with all results
- `ScientificAmericanArticle.md` — Popular science article
- `ResearchNotes.md` — Detailed research notes and session log

## The Idempotent Hierarchy

```
Level 1: Universal    │ Stone, Tropical     │ density = 1     │ All elements idempotent
Level 2: Projection   │ Gelfand, Quantum    │ density = mod   │ Projections are idempotent
Level 3: Algebraic    │ Classical           │ density = 2ʷ/n  │ Some elements idempotent
Level 4: NC           │ Connes              │ density = low   │ Non-commuting projections
Level 5: Closure      │ Pointfree           │ density = var   │ Operators are idempotent
Level 6: Homotopy     │ Derived             │ density → 0     │ Idempotent up to homotopy
```

## Building

```bash
lake build RosettaStone
```

All Lean files compile without errors or `sorry` placeholders.

## Key Insight

> **The degree to which idempotents are "available" in an algebraic structure determines how completely that algebra can be decoded into geometry.**

The Rosetta Stone is not a single dictionary but a family of eight interlocking dictionaries, unified by the idempotent thread e² = e.
