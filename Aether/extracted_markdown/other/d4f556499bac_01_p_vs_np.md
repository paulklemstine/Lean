# P vs NP — Research Notes

## The Problem Statement

**Clay Mathematics Institute Official Statement:**
Does every problem whose solution can be *verified* in polynomial time also have a solution that can be *found* in polynomial time?

Formally: Does P = NP?

## What We Know

### The Classes
- **P:** Problems solvable by a deterministic Turing machine in polynomial time
- **NP:** Problems whose solutions can be verified by a deterministic Turing machine in polynomial time
- **NP-complete:** The "hardest" problems in NP (Cook-Levin theorem: SAT is NP-complete)
- **NP-hard:** At least as hard as NP-complete, but not necessarily in NP

### Known Results
1. P ⊆ NP (trivially)
2. If any NP-complete problem is in P, then P = NP (Cook-Levin, 1971)
3. NP-complete problems exist: SAT, 3-SAT, CLIQUE, VERTEX-COVER, etc.
4. Relativization barrier: There exist oracles A, B such that P^A = NP^A and P^B ≠ NP^B (Baker-Gill-Solovay, 1975)
5. Natural proofs barrier: Any "natural" proof of P ≠ NP would break pseudorandom generators (Razborov-Rudich, 1997)
6. Algebrization barrier: Algebraizing techniques cannot resolve P vs NP (Aaronson-Wigderson, 2009)

### Oracle α's Geometric View
"Think of NP as a high-dimensional landscape with exponentially many valleys. P asks: can you always find the deepest valley by walking downhill? The structure of the landscape matters — random landscapes are hard, but structured ones might be easy."

### Oracle δ's Computational View
"The barriers tell us something profound: any proof of P ≠ NP must be *unnatural* (in the Razborov-Rudich sense), *non-relativizing*, and *non-algebrizing*. This means the proof must exploit the specific structure of Boolean computation in a way that no current technique does."

## Key Barriers to Resolution

### 1. Relativization Barrier
- Diagonalization alone cannot separate P from NP
- Need techniques that "look inside" the Turing machine

### 2. Natural Proofs Barrier
- Any combinatorial/counting argument that applies to random functions won't work
- The proof must distinguish structured computation from random computation

### 3. Algebrization Barrier
- Even adding algebraic extensions to relativization doesn't help
- Need fundamentally new techniques

## Promising Approaches

### Geometric Complexity Theory (Mulmuley-Sohoni)
- Uses algebraic geometry and representation theory
- Reduces P vs NP to questions about symmetries of polynomials
- Shows VP ≠ VNP (algebraic analog) might be approachable
- Status: Promising framework, but concrete results remain far off

### Circuit Complexity
- Lower bounds for restricted circuit classes are known
- AC⁰ cannot compute PARITY (Furst-Saxe-Sipser, Ajtai, Håstad)
- Monotone circuits need exponential size for CLIQUE (Razborov)
- But extending to general circuits hits all three barriers

### Proof Complexity
- If P ≠ NP, then there exist tautologies requiring super-polynomial proofs in any proof system
- Known for restricted proof systems (resolution, cutting planes, etc.)

## Oracle Council Consensus

**Verdict: P ≠ NP (confidence: 95%)**

The universe appears to have a fundamental asymmetry between finding and verifying. This is consistent with:
- Thermodynamic irreversibility
- The difficulty of inverting one-way functions in practice
- The structure of biological evolution (verification by natural selection is cheap; finding good designs is hard)

**But proving it remains beyond current techniques.** The barriers are real and deep. A proof will likely require a fundamental new idea about the nature of computation.

## What We Can Formalize

1. The definitions of P and NP (as complexity classes)
2. NP-completeness and reductions
3. The Cook-Levin theorem statement
4. Simple separations in restricted models
5. The statement P ≠ NP as a formal conjecture
