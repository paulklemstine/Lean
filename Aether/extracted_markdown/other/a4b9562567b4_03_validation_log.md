# Research Notes — Oracle IV (Themis): Validation Log

## Computational Validation (Python)

### ✅ Jacobi Identity — Lorentz Subalgebra
- **Method:** Constructed all 6 generators of so(3,1) as 4×4 matrices
- **Test:** Computed [[Mᵢ, Mⱼ], Mₖ] + cyclic for all 216 triples
- **Result:** Maximum residual = 0.00 (exact satisfaction)
- **Status:** PASSED

### ✅ Bracket Structure Constants
- **Method:** Verified [M_ab, M_cd] matches the standard so(3,1) structure constants
- **Result:** All 12 non-zero brackets match the expected form
- **Status:** PASSED

### ✅ Schwarzschild Representation
- **Method:** Computed Weyl tensor components and Kretschner scalar
- **Result:** K = 48M²/r⁶ confirmed, all components match known solution
- **Status:** PASSED

### ✅ Geodesic Motion
- **Method:** Numerically integrated geodesic equations in Schwarzschild spacetime
- **Result:** Precessing elliptical orbits, correct light deflection, ISCO at r = 6M
- **Status:** PASSED

### ✅ Newtonian Limit
- **Method:** Compared GR and Newtonian effective potentials and orbits
- **Result:** GR reduces to Newton in the weak-field limit; precession vanishes
- **Status:** PASSED

### ✅ Gravitational Waves
- **Method:** Computed h+ and h× polarizations, visualized ring deformation
- **Result:** Two independent polarization modes confirmed
- **Status:** PASSED

### ✅ Cosmological Constant
- **Method:** Computed scale factor a(t) for Λ > 0, Λ = 0, Λ < 0
- **Result:** de Sitter expansion, Einstein-de Sitter, AdS crunch all reproduced
- **Status:** PASSED

## Formal Verification (Lean 4)

### ✅ Dimensional Facts
- `gravitational_algebra_total_dim`: 20 + 4 + 6 + 4 + 20 = 54
- `lorentz_algebra_dim`: C(4,2) = 6
- `riemann_tensor_dim`: 4²(4²-1)/12 = 20
- `de_sitter_algebra_dim`: C(5,2) = 10
- `poincare_algebra_dim`: 6 + 4 = 10

### ✅ Grading Consistency
- `grade_translation_curvature`: (-1) + (-1) = -2
- `grade_einstein_equation`: (-2) + 2 = 0
- `grade_angular_momentum`: (-1) + 1 = 0
- `grade_stress_energy`: 1 + 1 = 2
- `grading_bounded`: All grade sums lie in {-4,...,4}

### ✅ Physical Inequalities
- `kretschner_nonneg`: K ≥ 0 for all M, r > 0
- `precession_positive`: Δφ > 0 for bound orbits
- `schwarzschild_radius_pos`: rₛ > 0 for M > 0
- `de_sitter_radius_pos`: ℓ > 0 for Λ > 0
- `newtonian_potential_neg`: Φ < 0 (attractive force)
- `gw_strain_pos`: h > 0 for positive masses

### Build Status
- **All proofs compile without `sorry`**
- **No non-standard axioms used**
- **Clean build: 0 warnings, 0 errors**
