# SPB Research Extensions

## New Lean 4 Formalizations

| File | Description | Theorems | Status |
|------|-------------|----------|--------|
| `HyperbolicGeometry.lean` | SPB-based hyperbolic distance, Poincaré disk model, Klein model | 10+ | ✅ Zero sorries |
| `MatrixRepresentation.lean` | 2×2 matrix encoding, determinant, scaled product identity | 8+ | ✅ Zero sorries |
| `InvolutionTheory.lean` | Reflection identities, triple formula, conjugation theorem | 12+ | ✅ Zero sorries |
| `FiniteFieldStructure.lean` | Extended p±1 law verification for 14 primes, positive & negative tests | 25+ | ✅ Zero sorries |
| `TropicalSPB.lean` | First tropical SPB definition, commutativity, negative-input identity | 5+ | ✅ Zero sorries |

## Key Results

### Matrix Representation
- `spbMatrix_det`: det M(a) = 1 + a² > 0
- `spbMatrix_mul_entries`: M(a)·M(b) = [[1-ab, a+b], [-(a+b), 1-ab]]
- `spbMatrix_mul_eq_scaled`: M(a)·M(b) = (1-ab)·M(spb(a,b))
- `spbMatrix_det_mul`: det product = product of dets

### Involution Theory
- `spb_conjugation_trivial`: spb(a, spb(x, -a)) = x
- `spb_triple_expand`: symmetric triple formula
- `spb_sum_reflection`: spb(x,y) + spb(x,-y) identity
- `spb_product_reflection`: spb(x,y)·spb(x,-y) identity

### Finite Fields
- p±1 law verified for all primes 3 ≤ p ≤ 47
- Negative verification: wrong periodicity confirmed to fail

### Hyperbolic Geometry
- `hypDist_symm`, `hypDist_self`: metric axioms
- `spbH_hyp_subluminal`: (-1,1) closure

### Tropical SPB
- `tropSPB_comm`: commutativity
- `tropSPB_neg_neg`: for x,y < 0, tspb(x,y) = min(x,y)

## Python Demos

- `spb_research_explorer.py` — 10 comprehensive demos
- `spb_bloch_sphere.py` — Quantum computing connection
