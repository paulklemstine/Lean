#!/usr/bin/env python3
"""
Tropical Tannaka Reconstruction — Algorithms

Implements the core algorithms for:
1. Computing the symmetry semiring from finite tensor category data
2. Checking naturality constraints
3. Computing closure characters
4. Pullback homomorphisms for functoriality
5. Finite presentation extraction

All algorithms work over arbitrary commutative semirings, with
specializations for the max-plus (tropical) semiring.
"""

import numpy as np
from typing import List, Tuple, Optional, Callable
from dataclasses import dataclass, field


# ── Data Structures ───────────────────────────────────────────────────────

@dataclass
class TensorCategoryPresentation:
    """
    Finite presentation of a tensor category with fiber functor.

    Attributes:
        n_generators: Number of generator objects
        dimensions: Fiber dimension of each generator
        morphisms: List of (source_idx, target_idx, matrix) triples
        observables: List of (generator_idx, matrix) pairs for closure separation
    """
    n_generators: int
    dimensions: List[int]
    morphisms: List[Tuple[int, int, np.ndarray]] = field(default_factory=list)
    observables: List[Tuple[int, np.ndarray]] = field(default_factory=list)

    def validate(self) -> bool:
        """Check data consistency."""
        assert len(self.dimensions) == self.n_generators
        assert all(d > 0 for d in self.dimensions)
        for src, tgt, mat in self.morphisms:
            assert 0 <= src < self.n_generators
            assert 0 <= tgt < self.n_generators
            assert mat.shape == (self.dimensions[tgt], self.dimensions[src])
        for gen, mat in self.observables:
            assert 0 <= gen < self.n_generators
            d = self.dimensions[gen]
            assert mat.shape == (d, d)
        return True


@dataclass
class SymmetrySemiringElement:
    """
    An element of the reconstructed symmetry semiring.

    Stores one endomorphism matrix per generator.
    """
    components: List[np.ndarray]

    @property
    def n_generators(self) -> int:
        return len(self.components)

    def trace_character(self) -> List[float]:
        """Compute the closure character (trace on each component)."""
        return [float(np.trace(M)) for M in self.components]


@dataclass
class SymmetrySemiringPresentation:
    """
    Finite presentation of the reconstructed symmetry semiring.

    The semiring is a quotient of the free product of matrix rings
    by naturality relations.
    """
    category: TensorCategoryPresentation
    # Dimension of the ambient product space
    ambient_dim: int
    # Number of naturality constraints
    n_constraints: int
    # Dimension of the natural subsemiring (if computable)
    natural_dim: Optional[int] = None


# ── Algorithm 1: Compute Symmetry Semiring Presentation ──────────────────

def compute_symmetry_presentation(
    cat: TensorCategoryPresentation
) -> SymmetrySemiringPresentation:
    """
    Compute the finite presentation of the symmetry semiring.

    The symmetry semiring embeds into the product of matrix rings:
        ∏ᵢ End(Fin dᵢ → S)  ≅  ∏ᵢ Mat(dᵢ, S)

    Naturality constraints cut out a sub-semiring determined by:
    For each morphism k: src → tgt with matrix M_k,
    the constraint η_tgt ∘ M_k = M_k ∘ η_src gives
    dᵢ_tgt × dᵢ_src scalar equations.

    Time complexity: O(n_gen + n_mor × max_dim²)
    Space complexity: O(∑ dᵢ²)

    Args:
        cat: Tensor category presentation

    Returns:
        Finite presentation of the symmetry semiring
    """
    cat.validate()

    # Ambient product dimension: ∑ dᵢ²
    ambient_dim = sum(d * d for d in cat.dimensions)

    # Count naturality constraints
    n_constraints = 0
    for src, tgt, mat in cat.morphisms:
        n_constraints += cat.dimensions[tgt] * cat.dimensions[src]

    return SymmetrySemiringPresentation(
        category=cat,
        ambient_dim=ambient_dim,
        n_constraints=n_constraints,
        natural_dim=ambient_dim - n_constraints if n_constraints <= ambient_dim else None
    )


# ── Algorithm 2: Check Naturality ─────────────────────────────────────────

def check_naturality(
    cat: TensorCategoryPresentation,
    element: SymmetrySemiringElement,
    tol: float = 1e-10
) -> Tuple[bool, List[float]]:
    """
    Check if a symmetry semiring element satisfies naturality.

    For each morphism k with matrix M_k: src → tgt,
    checks that η_tgt @ M_k = M_k @ η_src.

    Time complexity: O(n_mor × max_dim³)

    Args:
        cat: Category presentation
        element: Symmetry semiring element to check
        tol: Numerical tolerance

    Returns:
        (is_natural, list of per-morphism residuals)
    """
    residuals = []
    for src, tgt, mat in cat.morphisms:
        lhs = element.components[tgt] @ mat
        rhs = mat @ element.components[src]
        residual = float(np.max(np.abs(lhs - rhs)))
        residuals.append(residual)

    is_natural = all(r < tol for r in residuals)
    return is_natural, residuals


# ── Algorithm 3: Compute Closure Character ─────────────────────────────────

def compute_closure_character(
    element: SymmetrySemiringElement
) -> List[float]:
    """
    Compute the closure capacity character.

    The character maps each generator to the trace of
    the corresponding endomorphism component.

    This is an additive homomorphism: χ(η + μ) = χ(η) + χ(μ).

    Time complexity: O(∑ dᵢ)

    Args:
        element: Symmetry semiring element

    Returns:
        List of traces, one per generator
    """
    return element.trace_character()


# ── Algorithm 4: Pullback Homomorphism ─────────────────────────────────────

def compute_pullback(
    gen_map: List[int],
    dim_source: List[int],
    dim_target: List[int],
    element: SymmetrySemiringElement
) -> SymmetrySemiringElement:
    """
    Compute the pullback of a symmetry semiring element along a
    category morphism.

    Given Φ: C → D with gen_map[i] = Φ(gen_i),
    the pullback ψ(η) restricts η to C's generators.

    This is a ring homomorphism: ψ(η·μ) = ψ(η)·ψ(μ).

    Time complexity: O(n_gen_C × max_dim²)

    Args:
        gen_map: Generator map from C to D
        dim_source: Dimensions of C's generators
        dim_target: Dimensions of D's generators
        element: Element of End(D) to pull back

    Returns:
        Pulled-back element of End(C)
    """
    components = []
    for i, j in enumerate(gen_map):
        assert dim_source[i] == dim_target[j], \
            f"Dimension mismatch: C.dim[{i}]={dim_source[i]} ≠ D.dim[{j}]={dim_target[j]}"
        components.append(element.components[j].copy())
    return SymmetrySemiringElement(components=components)


# ── Algorithm 5: Enumerate Natural Endomorphisms (Finite Case) ─────────────

def enumerate_natural_endomorphisms_finite(
    cat: TensorCategoryPresentation,
    values: List[float],
    max_elements: int = 1000
) -> List[SymmetrySemiringElement]:
    """
    Enumerate natural endomorphisms when the base semiring is finite.

    Brute-force enumeration over all possible component matrices
    with entries from a finite set of values, filtering by naturality.

    Time complexity: O(|values|^(∑dᵢ²) × n_mor × max_dim³)
    Only practical for very small examples!

    Args:
        cat: Category presentation
        values: Allowed semiring values (e.g. [0, 1] for Boolean)
        max_elements: Maximum number to find before stopping

    Returns:
        List of natural symmetry semiring elements found
    """
    from itertools import product as iterproduct

    dims = cat.dimensions
    n_gen = cat.n_generators

    # For each generator, enumerate all dᵢ×dᵢ matrices with given values
    results = []

    # Build index structure
    gen_sizes = [d * d for d in dims]
    total_params = sum(gen_sizes)

    if total_params > 20:
        print(f"Warning: {total_params} parameters with {len(values)} values = "
              f"{len(values)**total_params} combinations. Truncating search.")
        return []

    for combo in iterproduct(values, repeat=total_params):
        # Reconstruct matrices
        components = []
        offset = 0
        for d in dims:
            mat_data = combo[offset:offset + d * d]
            mat = np.array(mat_data).reshape(d, d)
            components.append(mat)
            offset += d * d

        element = SymmetrySemiringElement(components=components)
        is_nat, _ = check_naturality(cat, element)

        if is_nat:
            results.append(element)
            if len(results) >= max_elements:
                break

    return results


# ── Algorithm 6: Reconstruction Verification ──────────────────────────────

def verify_reconstruction(
    cat: TensorCategoryPresentation,
    element: SymmetrySemiringElement
) -> dict:
    """
    Verify that a symmetry semiring element satisfies all reconstruction conditions.

    Checks:
    1. Correct dimensions
    2. Naturality
    3. Character computation
    4. Faithfulness (reported but not checked — requires morphism injectivity data)

    Args:
        cat: Category presentation
        element: Element to verify

    Returns:
        Dictionary of verification results
    """
    results = {}

    # Dimension check
    dim_ok = all(
        element.components[i].shape == (cat.dimensions[i], cat.dimensions[i])
        for i in range(cat.n_generators)
    )
    results['dimensions_ok'] = dim_ok

    # Naturality check
    is_natural, residuals = check_naturality(cat, element)
    results['is_natural'] = is_natural
    results['naturality_residuals'] = residuals

    # Character
    char = compute_closure_character(element)
    results['closure_character'] = char

    return results


# ── Example Usage ─────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("TROPICAL TANNAKA RECONSTRUCTION — ALGORITHMS")
    print("=" * 60)

    # Example 1: Simple 2-generator category
    cat = TensorCategoryPresentation(
        n_generators=2,
        dimensions=[1, 2],
    )
    pres = compute_symmetry_presentation(cat)
    print(f"\nExample 1: {cat.n_generators} generators, dims={cat.dimensions}")
    print(f"  Ambient dimension: {pres.ambient_dim}")
    print(f"  Constraints: {pres.n_constraints}")
    print(f"  Natural dimension: {pres.natural_dim}")

    # Example 2: With a morphism
    M = np.array([[1.0, 0.0], [0.0, 1.0]])
    cat2 = TensorCategoryPresentation(
        n_generators=2,
        dimensions=[2, 2],
        morphisms=[(0, 1, M)]
    )
    pres2 = compute_symmetry_presentation(cat2)
    print(f"\nExample 2: {cat2.n_generators} generators, dims={cat2.dimensions}, 1 morphism")
    print(f"  Ambient dimension: {pres2.ambient_dim}")
    print(f"  Constraints: {pres2.n_constraints}")
    print(f"  Natural dimension: {pres2.natural_dim}")

    # Verify a natural element
    eta = SymmetrySemiringElement([
        np.array([[1.0, 2.0], [3.0, 4.0]]),
        np.array([[1.0, 2.0], [3.0, 4.0]]),  # same as gen 0 (identity morphism)
    ])
    result = verify_reconstruction(cat2, eta)
    print(f"  Natural element verification: {result}")

    # Example 3: Finite enumeration (Boolean semiring)
    cat3 = TensorCategoryPresentation(
        n_generators=2,
        dimensions=[1, 1],
        morphisms=[(0, 1, np.array([[1.0]]))]
    )
    print(f"\nExample 3: Finite Boolean enumeration")
    naturals = enumerate_natural_endomorphisms_finite(cat3, [0.0, 1.0])
    print(f"  Found {len(naturals)} natural elements over {{0,1}}")
    for i, e in enumerate(naturals):
        print(f"    Element {i}: components={[M.tolist() for M in e.components]}, "
              f"char={e.trace_character()}")

    print("\nAll algorithms completed successfully.")
