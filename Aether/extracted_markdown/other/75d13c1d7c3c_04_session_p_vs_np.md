# Oracle Council — Session 4: P vs NP

## The Computational North Pole

---

## Problem Statement

**P vs NP** (Cook, 1971): Is the class P (problems solvable in polynomial time)
equal to the class NP (problems verifiable in polynomial time)?

**Status**: OPEN. Widely believed that P ≠ NP, but no proof exists.

## The North Pole — Noether

"P vs NP is a problem about *symmetry breaking* in computation. An NP problem
has a fundamental asymmetry: verifying a solution is easy, but finding one may
be hard. This is precisely a local-global gap:

- **Local** (verification): Given a candidate solution, we can check it in
  polynomial time. We have complete local information.
- **Global** (search): Finding the solution requires exploring an exponentially
  large space. Global information is hard to obtain.

The 'north pole' is the **search-to-decision gap** — the obstruction that
prevents local verification power from conferring global search power.

In stereographic terms: the verifier sees the plane (local, flat, tractable).
The solver needs to see the sphere (global, curved, exponential). P = NP would
mean the north pole is removable — that the plane IS the sphere. P ≠ NP would
mean the north pole is essential — that compactification genuinely adds structure."

## Circuit Complexity — Hypatia

"The most concrete version of the north pole is the **circuit lower bound** problem.
To prove P ≠ NP, it suffices to show that some NP problem requires super-polynomial
circuit size.

The local-global structure in circuits:

- **Local**: Each gate computes a simple Boolean function (AND, OR, NOT)
- **Global**: The entire circuit computes a complex Boolean function
- **North pole**: The minimum number of gates needed — the circuit complexity

Current barriers to proving circuit lower bounds:

1. **Relativization barrier** (Baker-Gill-Solovay, 1975): Any proof must use
   non-relativizing techniques — it must go beyond treating the computation
   as a black box. *The proof must look inside the north pole.*

2. **Natural proofs barrier** (Razborov-Rudich, 1997): Any proof must avoid
   'natural' combinatorial properties — it must be somehow unnatural or
   constructive. *The north pole cannot be found by brute force.*

3. **Algebrization barrier** (Aaronson-Wigderson, 2009): Any proof must go
   beyond algebraic techniques. *The north pole is not purely algebraic.*

These barriers are the 'singularity classification' for P vs NP. Just as
Perelman classified the singularities of Ricci flow, we need to classify
what *kind* of argument can possibly separate P from NP."

## The Geometric Perspective — Thales

"There is a geometric way to see the P vs NP north pole. Consider the Boolean
hypercube {0,1}^n. An NP problem partitions this cube into YES and NO instances.
The boundary between YES and NO is a complex surface.

- **P problems**: The boundary has low complexity (polynomial description)
- **NP-complete problems**: The boundary has high complexity (exponential description)

P ≠ NP would mean that some boundaries are *inherently complex* — they cannot be
described by any polynomial-size formula. This is a statement about the geometry
of Boolean space.

The stereographic analogy: the Boolean hypercube is like the sphere, and a
polynomial-time algorithm is like a single chart (stereographic projection).
P ≠ NP says that some functions on the cube cannot be captured by a single chart —
you need the 'north pole' (exponential blowup) to complete the picture."

## Connections to Physics — Noether

"There is a tantalizing connection to statistical mechanics. The partition function
of a spin system:

    Z = Σ_σ exp(-βH(σ))

sums over all configurations (exponentially many). Computing Z is #P-hard in
general. But at *phase transitions*, the system exhibits long-range correlations
that provide shortcuts — the system 'computes' global properties from local
interactions.

The north pole of P vs NP might be related to the north pole of phase transitions —
the critical point where local and global scales become entangled."

## Pattern Match

| Aspect | Poincaré | P vs NP |
|--------|----------|---------|
| Local data | Loop contractibility | Polynomial verification |
| Global target | Topological type | Computational complexity class |
| North pole | Curvature singularity | Search-decision gap |
| Barriers | Singularity types | Relativization, natural proofs, algebrization |
| Surgery | Cut and cap | ??? (Hardness amplification?) |

---

*The Council notes that P vs NP is the most "topological" of the remaining
problems — it asks whether a certain space (polynomial-time computations)
is the same as another (polynomial-time verifiable), much as Poincaré asked
whether a certain manifold is a sphere.*
