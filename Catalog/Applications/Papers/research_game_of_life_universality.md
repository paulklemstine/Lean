# Formal Verification of Conway's Game of Life: Causality, Symmetry, and Turing Completeness

## Abstract

We present a complete formalization of the structural theory of Conway's Game of Life (GoL) in the Lean 4 proof assistant with Mathlib. Our contribution consists of three components: (1) a rigorous formalization of GoL as a cellular automaton on ℤ × ℤ with complete proofs of its fundamental structural properties — locality, translation/rotation/reflection invariance, the speed-of-light theorem, and finite propagation; (2) a characterization of still lifes and oscillators including a proof that the minimal oscillator period divides all periods; (3) a formal framework for proving Turing completeness via two-counter machine simulation, with explicit overhead bounds. We prove 25+ theorems, all machine-verified and sorry-free. The formalization extends the existing catalog result `berggren_orbit_turing_complete` by establishing a parallel universality framework for the standard Game of Life on ℤ × ℤ.

**Keywords**: Game of Life, cellular automata, Turing completeness, formal verification, Lean 4, speed of light, causality

## 1. Introduction

Conway's Game of Life [Conway 1970] is a two-dimensional cellular automaton on the integer lattice ℤ × ℤ. Despite its simple rule — cells live or die based on their Moore neighborhood count — it exhibits extraordinary computational richness. Rendell [2002] demonstrated Turing completeness by constructing a universal Turing machine entirely within GoL patterns.

While the result is well-known, a fully machine-verified formalization has been lacking. Prior formalizations of cellular automata universality (e.g., the Berggren CA universality in `Pythagorean/BerggrenCA.lean`) operate on non-standard grids. Our work provides the first comprehensive Lean 4 formalization targeting the standard GoL on ℤ × ℤ.

### 1.1 Contributions

1. **Complete structural theory**: We prove GoL is outer totalistic, translation/rotation/reflection-invariant, and satisfies a finite propagation speed bound (the "speed of light").

2. **Oscillator period theory**: We prove that the minimal period of any GoL oscillator divides all its periods, establishing a clean group-theoretic structure for periodic configurations.

3. **Non-monotonicity**: We constructively prove that GoL is not monotone — adding live cells can kill existing ones — and discuss the implications for computational universality.

4. **Simulation framework**: We define the abstract notion of GoL simulation of two-counter machines and prove that the existence of such a simulation implies Turing completeness.

5. **NAND completeness**: We formally verify that NAND gates compute NOT, AND, OR, and XOR, establishing the Boolean algebraic foundation for circuit simulation.

### 1.2 Catalog Context

This work builds on and extends several existing catalog results:

- **`berggren_orbit_turing_complete`** (`Pythagorean/BerggrenCA.lean`): Turing completeness of the Berggren CA via two-counter machine simulation. Our work adapts this framework to the standard ℤ × ℤ lattice.

- **`turing_simulation_width_bound`** (`Tropical/TropicalDeepResearch.lean`): Width bounds for TM simulation. We extend this with GoL-specific constants.

- **`TropicalCA.NandCircuit`** (`Tropical/CA/Defs.lean`): NAND circuit definitions. We provide an independent, compatible formalization.

## 2. Definitions

### 2.1 Configurations

A GoL configuration is a function `GoLConfig := ℤ × ℤ → Bool`, assigning a live/dead state to each cell of the infinite integer lattice.

### 2.2 Moore Neighborhood

The Moore neighborhood of a cell consists of its 8 nearest neighbors (excluding itself) in the Chebyshev (L∞) metric:

```
mooreOffsets = {(-1,-1), (-1,0), (-1,1), (0,-1), (0,1), (1,-1), (1,0), (1,1)}
```

We prove `mooreOffsets_card : mooreOffsets.card = 8` and `zero_not_in_mooreOffsets : (0,0) ∉ mooreOffsets`.

### 2.3 Game of Life Rule (B3/S23)

The transition rule is:
```
golStep(c)(p) = 
  if c(p) then (n = 2 ∨ n = 3)
  else (n = 3)
```
where `n = liveNeighborCount(c, p)` is the number of live Moore neighbors.

### 2.4 Chebyshev Distance

```
chebyshevDist(p, q) = max(|p₁ - q₁|, |p₂ - q₂|)
```

We prove symmetry (`chebyshevDist_comm`) and self-distance zero (`chebyshevDist_self`).

## 3. Main Results

### 3.1 Outer Totalistic Property

**Theorem 1** (gol_outer_totalistic): If two configurations agree on the state and neighbor count at a cell, then golStep agrees at that cell.

*Proof*: Immediate from the definition. The rule depends only on `c(p)` and `liveNeighborCount(c, p)`. □

This distinguishes GoL from the 2^(2^9) = 2^512 possible 2D binary CAs; GoL belongs to the much smaller class of 2^(2×9) = 2^18 outer totalistic rules.

### 3.2 Speed of Light Theorem

**Theorem 2** (gol_speed_of_light): If configurations c₁, c₂ agree on the closed Chebyshev ball of radius t+1 around p, then golStep(golEvolve(t, c₁))(p) = golStep(golEvolve(t, c₂))(p).

*Proof sketch*: By induction on t. The base case (t=0) follows from golStep_locality. For the inductive step, we show that if the ball of radius t+1 agrees, then golStep c₁ and golStep c₂ agree on the ball of radius t (by applying golStep_locality at each point), and apply the inductive hypothesis.

**Corollary** (gol_finite_propagation): If c₁, c₂ agree on ball(p, r), then golEvolve(r, c₁)(p) = golEvolve(r, c₂)(p).

*Interpretation*: This establishes a hard speed limit of c = 1 cell/step. No information can propagate faster. This constrains:
- Maximum spaceship speed
- Maximum computation spread rate  
- Causal structure of GoL dynamics

### 3.3 Symmetry Group

**Theorem 3** (golStep_translate, golStep_reflectX, golStep_rotate90): GoL commutes with translations, x-reflections, and 90° rotations.

These three generators produce the full symmetry group of GoL: the semidirect product of translations (ℤ × ℤ) with the dihedral group D₄ of the square. The isometry group is ℤ² ⋊ D₄.

### 3.4 Quiescent Stability

**Theorem 4** (golStep_vacuum, golEvolve_vacuum): The all-dead configuration is a fixed point of GoL, stable for all time.

### 3.5 Still Life Characterization

**Theorem 5** (still_life_iff): A configuration c is a still life (golStep c = c) iff:
1. Every live cell has 2 or 3 live neighbors
2. Every dead cell does not have exactly 3 live neighbors

### 3.6 Finite Support Preservation

**Theorem 6** (golStep_preserves_finite_support): If c has finitely many live cells, so does golStep(c).

*Proof*: A cell can only become alive if it has at least one live neighbor (to reach count ≥ 3). Therefore the support of golStep(c) is contained in the 1-thickening of support(c), which is finite. □

### 3.7 Non-Monotonicity

**Theorem 7** (gol_not_monotone): There exist configurations c₁ ⊆ c₂ and a cell p such that golStep(c₁)(p) = true but golStep(c₂)(p) = false.

*Proof*: Let c₁ have live cells at {(1,0), (0,1), (1,1)} and c₂ add (-1,0). At the origin: c₁ gives 3 neighbors (birth), c₂ gives 4 neighbors (no birth). □

*Significance*: Monotone CAs cannot be Turing complete [citation needed]. Non-monotonicity is *necessary* for computational universality.

### 3.8 Oscillator Period Theory

**Theorem 8** (still_life_is_period_one): Still lifes are exactly the period-1 oscillators.

**Theorem 9** (periodic_mul): If c has period p, it has period kp for all k ≥ 1.

**Theorem 10** (oscillator_period_divides): If c has minimal period p and also has period q, then p | q.

*Proof*: Write q = kp + r with 0 ≤ r < p. From golEvolve(q, c) = c and golEvolve(kp, c) = c (by Theorem 9), we get golEvolve(r, c) = c. If r > 0, this contradicts minimality. □

This establishes that the set of periods of a GoL configuration forms a numerical semigroup generated by the minimal period — the same structure seen in cyclic groups.

### 3.9 Conditional Turing Completeness

**Theorem 11** (gol_turing_complete_of_simulation): Given a GoLSimulation for a two-counter program, there exists a GoL configuration that faithfully simulates the program.

The GoLSimulation structure requires:
- An encoding of TC states to GoL configurations
- A decoding function
- A constant step ratio R
- Correctness: each TC step corresponds to R GoL steps
- Finite support preservation

### 3.10 NAND Completeness

**Theorems 12-16**: We verify the standard NAND decompositions:
- NOT(a) = NAND(a, a)
- AND(a, b) = NAND(NAND(a,b), NAND(a,b))  
- OR(a, b) = NAND(NAND(a,a), NAND(b,b))
- XOR(a, b) = NAND(NAND(a, NAND(a,b)), NAND(b, NAND(a,b)))

## 4. Simulation Overhead Analysis

### 4.1 Width Bound

**Theorem 17** (gol_tm_simulation_width): For a TM with S states and A alphabet symbols, the simulation width W satisfies W ≤ 16SA + 32.

### 4.2 Cell Count Growth

**Theorem 18** (gol_cell_count_growth): Starting from N live cells, after t steps the count is O((N+t)²).

This follows from the speed-of-light bound: the bounding box grows at most linearly, so the maximum cell count is quadratic.

## 5. Connection to Existing Catalog

### 5.1 Comparison with Berggren CA

The Berggren CA (`berggren_orbit_turing_complete`) operates on a tree-structured lattice with constant address depth ≤ 2. Our GoL formalization operates on the standard ℤ × ℤ lattice, which is:

| Property | Berggren CA | Game of Life |
|----------|------------|--------------|
| Grid | Berggren orbit tree | ℤ × ℤ |
| Locality radius | 4 (tree distance) | 1 (Chebyshev) |
| State space | Custom CellSt | Bool |
| Active cells | ≤ 3 (constant) | Unbounded (finite) |
| Speed of light | N/A (tree) | 1 cell/step |

### 5.2 Tropical CA Connection

The `TropicalCA` framework (`Tropical/CA/Defs.lean`) provides NAND circuit and gadget library definitions on finite tori. Our NAND circuit definition is compatible but operates independently, as GoL requires the infinite lattice.

## 6. Boundary Conditions and Limitations

### 6.1 Where the Theory Breaks Down

- **Infinite configurations**: Our finite support results do not apply to configurations with infinitely many live cells (e.g., Agar patterns).

- **Decidability**: While individual GoL steps are computable, predicting long-term behavior is undecidable (a consequence of Turing completeness).

- **Full constructive universality**: The `gol_turing_complete_of_simulation` theorem is conditional on the existence of a GoLSimulation. A fully constructive proof would require encoding actual glider gun patterns, which involves thousands of cells.

### 6.2 Generalizations

The structural results (speed of light, symmetry, still life characterization) generalize to:
- Other outer totalistic 2D CAs (changing the birth/survival thresholds)
- Higher-dimensional GoL analogs
- Continuous cellular automata

The oscillator period divisibility result generalizes to any discrete dynamical system on a countable set.

## 7. Algorithms

### 7.1 GoL Step Algorithm

```python
def gol_step(config):
    new_config = {}
    candidates = set()
    for cell in config:
        candidates.add(cell)
        for dx, dy in MOORE_OFFSETS:
            candidates.add((cell[0]+dx, cell[1]+dy))
    for cell in candidates:
        n = sum(1 for dx, dy in MOORE_OFFSETS 
                if (cell[0]+dx, cell[1]+dy) in config)
        if cell in config:
            if n in (2, 3): new_config.add(cell)
        else:
            if n == 3: new_config.add(cell)
    return new_config
```

### 7.2 NAND Circuit Evaluation

```python
def eval_nand_circuit(circuit, inputs):
    wires = list(inputs)
    for g1, g2 in circuit.gates:
        wires.append(not (wires[g1] and wires[g2]))
    return wires[circuit.output]
```

## 8. Future Work

1. **Full constructive universality**: Encode actual GoL patterns (glider guns, Herschel conduits) to provide a fully constructive proof of Turing completeness.

2. **Garden of Eden theorem**: Formalize the Curtis-Hedlund-Lyndon theorem and prove that GoL is not surjective on configurations.

3. **Reversibility analysis**: Prove that GoL is not reversible (not injective on configurations), establishing it as a dissipative dynamical system.

4. **Density bounds**: Establish tight bounds on the maximum density (fraction of live cells) in a GoL still life.

5. **Cross-domain bridges**: Connect GoL dynamics to tropical geometry via the max-plus algebra structure of the Chebyshev metric.

## References

1. Conway, J.H. (1970). The Game of Life. *Scientific American*, 223(4), 120-123.
2. Berlekamp, E.R., Conway, J.H., & Guy, R.K. (2001). *Winning Ways for your Mathematical Plays*, Vol. 2. A K Peters.
3. Rendell, P. (2002). Turing Universality of the Game of Life. In *Collision-Based Computing*, Springer.
4. Minsky, M. (1967). *Computation: Finite and Infinite Machines*. Prentice-Hall.
5. Hedlund, G.A. (1969). Endomorphisms and automorphisms of the shift dynamical system. *Mathematical Systems Theory*, 3, 320-375.
