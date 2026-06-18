# Future Directions: Crystallographic Restriction and Periodic Pattern Symmetry

## 1. Full Classification of Finite-Order Integer Matrices

The crystallographic restriction theorem we proved constrains the trace of non-scalar finite-order 2×2 integer matrices to {-1, 0, 1}. The natural next step is to prove that for each allowed trace value, the matrix order is uniquely determined: trace -1 gives order 3, trace 0 gives order 4, and trace 1 gives order 6. This would complete the algebraic classification.

The key insight is that the Chebyshev sequence `cheb(t, ·)` is periodic modulo its first zero: for t = -1, the sequence is 0, 1, -1, 0, 1, -1, ... (period 3); for t = 0, it is 0, 1, 0, -1, 0, 1, ... (period 4); for t = 1, it is 0, 1, 1, 0, -1, -1, 0, ... (period 6). Proving this periodicity formally and connecting it to matrix order would close the classification.

Why now? We have the non-vanishing infrastructure (`cheb_pos`, `cheb_mono`, `cheb_neg`) and the recurrence machinery. The periodicity for each fixed t ∈ {-1, 0, 1} is a finite computation that `native_decide` can verify, but the structural proof connecting periodicity to matrix order requires the Cayley-Hamilton correspondence we've already set up.

## 2. Enumeration of the 17 Wallpaper Groups via Point Group Classification

The 2D crystallographic restriction constrains point groups of planar lattices to 10 isomorphism classes (cyclic and dihedral groups of orders 1, 2, 3, 4, 6). The 17 wallpaper groups arise as extensions of the translation lattice ℤ² by these point groups. A formal enumeration would involve:
- Classifying lattice types compatible with each point group (oblique, rectangular, square, hexagonal)
- Computing H²(P, ℤ²) for each point group P to enumerate extensions
- Showing exactly 17 non-isomorphic groups result

The key insight is that the extension classification reduces to a finite cohomology computation: H²(P, ℤ²) is a finite abelian group for each of the 10 point groups, and the total count across all (P, lattice type) pairs is 17. This is a significant but tractable formalization project.

Why now? The trace constraint we proved is the foundation of the point group classification. With the Chebyshev recurrence infrastructure, extending to the full wallpaper group enumeration becomes a matter of lattice theory and group cohomology rather than analysis.

## 3. Quasicrystallographic Extensions: 5-fold Symmetry and Penrose Patterns

Our theorem proves that 5-fold rotational symmetry is impossible for periodic 2D patterns (since cheb(t, n) ≠ 0 for |t| ≥ 2 rules out trace values corresponding to 5-fold rotation). However, quasicrystals (discovered by Shechtman, 2011 Nobel Prize) exhibit 5-fold symmetry through aperiodic tilings. Formalizing the distinction between periodic and quasiperiodic patterns — showing that relaxing strict periodicity to "almost periodicity" (in the Bohr or Besicovitch sense) allows exactly the additional rotational orders {5, 8, 10, 12, ...} — would bridge our algebraic result with quasicrystal theory.

The key insight is that our non-vanishing theorem `cheb_ne_zero` is tight: it uses periodicity (the condition cheb(t,n) = 0 for some finite n) essentially. For quasiperiodic patterns, the relevant condition involves the sequence approaching zero without reaching it, which our growth bounds (`cheb_exponential_growth`) show cannot happen for |t| ≥ 2. This means the obstruction to 5-fold symmetry is quantitative (exponential growth), not just qualitative.

Why now? The exponential growth bound `cheb_exponential_growth` provides the quantitative foundation. Connecting this to almost-periodic functions requires defining Bohr almost-periodicity in Lean and showing that the Chebyshev recurrence analysis extends to that setting.

## 4. Higher-Dimensional Crystallographic Restrictions

In dimension d, the crystallographic restriction constrains finite-order elements of GL_d(ℤ) via the characteristic polynomial. For d = 3, the allowed rotation orders are {1, 2, 3, 4, 6} (same as d = 2), yielding 230 space groups. For d = 4, additional orders {5, 8, 10, 12} become possible, and the number of crystallographic groups grows to 4894.

The key insight is that our Chebyshev recurrence generalizes to higher dimensions via the characteristic polynomial: for an n×n integer matrix M, the sequence of traces tr(Mᵏ) satisfies a linear recurrence determined by the coefficients of the characteristic polynomial. The non-vanishing argument extends, but the polynomial constraints become richer: instead of a single trace bound, one needs to analyze the full characteristic polynomial over ℤ.

Why now? The `chebDet` generalization we defined (parameterized by determinant d) is the first step toward the higher-dimensional theory. The next step is defining a multivariate Chebyshev-like sequence for n×n matrices and proving analogous growth bounds.

## 5. Musical Pattern Classification: Computational Verification

While the theoretical framework classifies periodic 2D patterns by their symmetry groups, the connection to music remains conjectural. A computational direction: define a concrete mapping from MIDI drum patterns (represented as binary matrices ℤ/m × ℤ/n → Bool for typical values m = 16, n = 12) to their symmetry groups, and verify computationally that:
- All 10 point groups (and hence all 17 wallpaper groups via extension data) appear in practice
- The distribution is non-uniform, with p1 (no symmetry) and pm (mirror/palindrome) dominating

The key insight is that for finite patterns on ℤ/m × ℤ/n, the symmetry group computation reduces to a finite search over the group elements, making it decidable and computable in Lean via `Decidable` instances. This would give the first formally verified classification of musical pattern symmetries.

Why now? The `periodAddSubgroup` and `periodAddSubgroup_general` constructions provide the theoretical foundation. Extending to 2D patterns on ZMod m × ZMod n and adding point group detection (checking for reflection and rotation invariance) is a natural extension of the code we have.
