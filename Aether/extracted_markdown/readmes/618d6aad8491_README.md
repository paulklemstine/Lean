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
| 7 | **Tropical Geometry** | Tropical semiring | Polyhedral complexes | a⊕a = a (ALL elements!) |
| 8 | **Quantum Geometry** | Operator algebras | Hilbert spaces | P² = P (measurement) |

## Project Structure

### Formally Verified Lean 4 Theorems (zero `sorry`s)
- `Bridge1_Classical.lean` — Idempotent decomposition, power stability, ℤ/nℤ counts
- `Bridge2_Stone.lean` — Boolean algebra idempotency, de Morgan, distributivity
- `Bridge3_Gelfand.lean` — Projections, complements, evaluation homomorphisms
- `Bridge5_Noncommutative.lean` — Commutators, trace vanishing, commuting projections
- `Bridge7_Tropical.lean` — Universal idempotency, tropical distributivity, determinants
- `Bridge8_Quantum.lean` — Projection operators, measurement stability, diagonal projections
- `CrossBridge_IdempotentThread.lean` — Cross-bridge connections, idempotent density in ℤ/nℤ

### Python Demos
- `demos/bridge_explorer.py` — All 8 bridges with computational examples
- `demos/tropical_self_reference.py` — Tropical self-referential property, polynomials, matrices
- `demos/quantum_projection_demo.py` — Quantum measurement, Born rule, decoherence

### SVG Visuals
- `visuals/eight_bridges.svg` — The 8 bridges radiating from the idempotent center
- `visuals/idempotent_thread.svg` — The hierarchy from tropical (most) to derived (least)
- `visuals/rosetta_stone_table.svg` — Complete translation table across all bridges
- `visuals/tropical_self_reference.svg` — Tropical polynomial visualization
- `visuals/quantum_classical_bridge.svg` — Quantum ↔ classical transition diagram

### Written Works
- `ResearchNotes.md` — Detailed oracle council research notes
- `ResearchPaper.md` — Formal research paper with theorems and proofs
- `ScientificAmericanArticle.md` — Popular science article for general audiences

## Key Discoveries

1. **The Idempotent Hierarchy**: The density of idempotent elements measures "classicality" — from tropical (all idempotent) to derived (idempotent up to homotopy).

2. **Tropicalization = Classical Limit**: Tropicalization (AG → tropical) is structurally analogous to the classical limit ℏ → 0 (quantum → classical). Both increase idempotent density.

3. **The Bridge Lattice**: The 8 bridges form a partial order under generalization, which is itself a lattice structure.

4. **ℤ/nℤ Idempotent Counting** (verified in Lean): For n = p₁·p₂·...·pₖ (distinct primes), |Idem(ℤ/nℤ)| = 2ᵏ.

## Running

```bash
# Lean 4 verification
lake build RosettaStone

# Python demos (requires numpy)
python3 demos/bridge_explorer.py
python3 demos/tropical_self_reference.py
python3 demos/quantum_projection_demo.py
```
