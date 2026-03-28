# 🚫 The Forbidden Theorems

**Machine-verified explorations of mathematics' strangest, most beautiful, and most counterintuitive results.**

## Overview

This collection contains **43 formally verified theorems** organized into five "forbidden zones":

| File | Theme | Theorems | Status |
|------|-------|----------|--------|
| `BrokenMirror.lean` | 🪞 Symmetry breaking, involutions, Cantor diagonal | 8 | ✅ All proved |
| `TheMatrix.lean` | 🔴🔵 Matrix algebra, traces, determinants | 8 | ✅ All proved |
| `Area51.lean` | 👽 Prime theory, Wilson, Fermat, irrationality | 9 | ✅ All proved |
| `StrangeLoops.lean` | 🔄 Fixed points, periodicity, quines, chaos | 10 | ✅ All proved |
| `ForbiddenConvergence.lean` | ∞ Series, summation, inequalities | 8 | ✅ All proved |

## Highlights

- **Zero sorries** — every theorem is fully machine-verified
- **No non-standard axioms** — only propext, Classical.choice, Quot.sound
- **Accompanied by Python demos** in `demos/` with visualizations
- **Scientific American article** and **research paper** in `papers/`

## Building

```bash
cd core
lake build ForbiddenTheorems
```

## Key Theorems

### The Broken Mirror Theorem
Every involution on a finite set of odd cardinality has a fixed point.

### The Commutator Trace Theorem
tr(AB - BA) = 0 for all square matrices.

### The Prime Gap Theorem
For any k, there exist k consecutive composite numbers.

### The Quine Theorem
If eval is surjective, every transformation has a self-reproducing fixed point.

### The Grandi Series
The partial sums of 1-1+1-1+... oscillate between 0 and 1.
