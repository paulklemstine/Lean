# Computational Evidence — Elements as Eigenvalues of a Shell Hamiltonian

## 1. Small-case calculations

### Coulomb (hydrogenic) shells, degeneracy `2n²`
Shell degeneracies `shellDeg n = 2n²`:

| n | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|----|----|----|----|
| 2n² | 2 | 8 | 18 | 32 | 50 | 72 |

Cumulative fillings `nobleGas n = ∑_{k=1}^n 2k²`:

| n | 1 | 2 | 3 | 4 | 5 |
|---|---|----|----|----|-----|
| filling | 2 | 10 | 28 | 60 | 110 |

Verified against the closed form `3·nobleGas n = n(n+1)(2n+1)`:
`3·110 = 330 = 5·6·11`. ✓

### Isotropic 3D harmonic-oscillator shells, degeneracy `(N+1)(N+2)`
Cumulative fillings `magicHO n = ∑_{N=0}^n (N+1)(N+2)`:

| n | 0 | 1 | 2 | 3 | 4 | 5 |
|---|---|---|----|----|----|-----|
| filling | 2 | 8 | 20 | 40 | 70 | 112 |

Closed form `3·magicHO n = (n+1)(n+2)(n+3)`: `3·112 = 336 = 6·7·8`. ✓

The first three, **2, 8, 20**, are exactly the first three nuclear *magic numbers*.

## 2. OEIS search results
- Coulomb fillings `2, 10, 28, 60, 110, 182, …` = `2·(1²+…+n²)` — OEIS **A002378-scaled**;
  the base sums `1,5,14,30,55` are the square pyramidal numbers **A000330**.
- Oscillator fillings `2, 8, 20, 40, 70, 112, …` are **A007290** (`2·C(n+2,3)`),
  the cumulative counts of the 3D isotropic oscillator (a.k.a. tetrahedral-shell counts).
- The angular sum rule `∑_{l<n}(2l+1) = n²` recovers the squares **A000290**.

## 3. Counterexample hunt (limits of the physical model)
- **Coulomb vs. real noble gases.** Predicted `2,10,28,60,110`; observed noble-gas
  atomic numbers `2,10,18,36,54,86`. Agreement holds only through `Z=10`; the model
  is exact as spectral bookkeeping for an `n²`-degenerate spectrum but fails as
  chemistry because real filling follows the Madelung `(n+l)` rule.
- **Oscillator vs. real magic numbers.** Predicted `2,8,20,40,70,112`; empirical
  magic numbers `2,8,20,28,50,82,126`. Agreement holds through `20`; divergence at
  `40≠28`, `70≠50` is the signature of spin–orbit coupling, absent from the bare
  diagonal Hamiltonian. These are recorded as genuine model boundaries, not defects
  of the theorems (which concern the exact degeneracy sums).

## 4. Diagonal-spectrum check
For `shellHamiltonian d = diag(E₀,…,E_{d-1})` with `E_n = -1/(n+1)²`, each standard
basis vector `eᵢ` satisfies `H eᵢ = Eᵢ eᵢ`, so the spectrum is exactly
`{E₀,…,E_{d-1}}` and `trace H = ∑ Eᵢ`. Verified symbolically (see
`basisVec_isEigen`, `shellHamiltonian_trace`).
