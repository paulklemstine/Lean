#!/usr/bin/env python3
"""
Applications of the Bourgain-Gamburd Machine

This module demonstrates real-world applications of spectral gap
theory from the Bourgain-Gamburd expansion machine:

1. Network robustness via expander mixing
2. Error-correcting code design using Cayley graphs
3. Pseudorandom number generation via random walks
4. Smoothing operators for signal processing
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import permutations, product as iterproduct


def build_hyperoctahedral(n):
    """Build hyperoctahedral group B_n."""
    elements = []
    for perm in permutations(range(n)):
        for signs in iterproduct([1, -1], repeat=n):
            elements.append((perm, signs))

    def op(a, b):
        pa, sa = a
        pb, sb = b
        new_perm = tuple(pa[pb[i]] for i in range(n))
        new_signs = tuple(sa[pb[i]] * sb[i] for i in range(n))
        return (new_perm, new_signs)

    def inv_elem(a):
        pa, sa = a
        ip = [0] * n
        for i in range(n):
            ip[pa[i]] = i
        isigns = tuple(sa[ip[i]] for i in range(n))
        return (tuple(ip), isigns)

    idx = {}
    for i, e in enumerate(elements):
        idx[e] = i

    # Generators
    gens = []
    for i in range(n - 1):
        perm = list(range(n))
        perm[i], perm[i + 1] = perm[i + 1], perm[i]
        gens.append((tuple(perm), tuple([1] * n)))
    slist = [1] * n
    slist[0] = -1
    gens.append((tuple(range(n)), tuple(slist)))
    sym_gens = list(set(gens + [inv_elem(g) for g in gens]))

    # Build averaging operator
    N = len(elements)
    T = np.zeros((N, N))
    for i, g in enumerate(elements):
        for s in sym_gens:
            gs = op(g, s)
            j = idx[gs]
            T[i, j] += 1
    T /= len(sym_gens)

    return elements, sym_gens, op, idx, T


def app_network_robustness():
    """Application 1: Network robustness from expander mixing.

    Expander graphs have the property that every vertex subset S
    has many neighbors outside S. This translates to network resilience:
    even if an adversary removes a fraction of nodes, the remaining
    graph stays connected and well-mixed.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 1: Network Robustness via Expander Mixing")
    print("=" * 60)

    elements, gens, op, idx, T = build_hyperoctahedral(3)
    N = len(elements)

    # Compute spectral gap
    evals = np.sort(np.real(np.linalg.eigvals(T)))[::-1]
    gap = 1 - evals[1]
    lambda2 = evals[1]

    print(f"  Network size: {N} nodes")
    print(f"  Degree: {len(gens)} (per node)")
    print(f"  Spectral gap: {gap:.4f}")

    # Expander mixing lemma: for S, T subsets,
    # |e(S,T) - d|S||T|/n| <= lambda2 * sqrt(|S||T|)
    d = len(gens)
    print(f"\n  Expander Mixing Lemma bounds:")
    for frac in [0.1, 0.2, 0.3, 0.5]:
        s_size = int(frac * N)
        t_size = int(frac * N)
        expected_edges = d * s_size * t_size / N
        deviation = lambda2 * np.sqrt(s_size * t_size) * d
        print(f"    |S|=|T|={s_size}: expected edges={expected_edges:.1f}, "
              f"max deviation={deviation:.1f}")

    # Vertex expansion: every set S with |S| <= N/2 has
    # at least (gap * d / 2) * |S| neighbors outside S
    print(f"\n  Vertex expansion guarantee:")
    print(f"    Every set of ≤{N//2} vertices has expansion ratio ≥ {gap * d / 2:.4f}")

    return gap


def app_pseudorandom_generator():
    """Application 2: Pseudorandom number generation via Cayley walk.

    A random walk on an expander Cayley graph produces pseudorandom
    sequences using only O(log n) truly random bits per step
    (to choose a generator), while achieving n-pseudorandom outputs.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Pseudorandom Generation via Cayley Walks")
    print("=" * 60)

    elements, gens, op, idx, T = build_hyperoctahedral(3)
    N = len(elements)
    gap, _ = 1 - np.sort(np.real(np.linalg.eigvals(T)))[::-1][1], None

    print(f"  Group size: {N}")
    print(f"  Random bits per step: {np.log2(len(gens)):.2f}")

    # Generate pseudorandom sequence
    np.random.seed(42)
    walk_length = 100
    current = elements[0]
    sequence = []

    for _ in range(walk_length):
        gen = gens[np.random.randint(len(gens))]
        current = op(current, gen)
        sequence.append(idx[current])

    # Test uniformity via chi-squared
    counts = np.bincount(sequence, minlength=N)
    expected = walk_length / N
    chi_sq = np.sum((counts - expected) ** 2 / expected)

    print(f"  Walk length: {walk_length}")
    print(f"  Chi-squared statistic: {chi_sq:.2f}")
    print(f"  Expected (uniform): {N - 1:.2f}")
    print(f"  Quality: {'Good' if chi_sq < 2 * N else 'Needs more mixing'}")

    # Mixing time bound
    t_mix = int(np.ceil(np.log(N * 100) / (2 * gap)))
    print(f"  Estimated mixing time: {t_mix} steps")


def app_smoothing_operator():
    """Application 3: Spectral smoothing via orthogonal averaging.

    The averaging operator T_S over an orthogonal group can be used
    as a smoothing/denoising operator. The spectral gap ensures that
    high-frequency components are suppressed while low-frequency
    (constant) components are preserved.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Spectral Smoothing via Orthogonal Averaging")
    print("=" * 60)

    elements, gens, op, idx, T = build_hyperoctahedral(3)
    N = len(elements)

    evals = np.sort(np.real(np.linalg.eigvals(T)))[::-1]
    gap = 1 - evals[1]

    # Create a "signal" on the group with noise
    np.random.seed(42)
    signal = np.ones(N) * 5.0  # Constant signal
    noise = np.random.randn(N) * 2.0  # Gaussian noise
    noisy_signal = signal + noise

    # Apply smoothing via T_S iterations
    smoothed = noisy_signal.copy()
    errors = [np.linalg.norm(smoothed - signal)]

    for step in range(20):
        smoothed = smoothed @ T
        errors.append(np.linalg.norm(smoothed - signal))

    print(f"  Signal: constant value 5.0")
    print(f"  Noise std: 2.0")
    print(f"  Initial error: {errors[0]:.4f}")
    print(f"  After 5 steps:  {errors[5]:.4f}")
    print(f"  After 10 steps: {errors[10]:.4f}")
    print(f"  After 20 steps: {errors[20]:.4f}")
    print(f"  Error decay rate: ~{evals[1]:.4f} per step (= λ₂)")

    # Visualize
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    ax1.semilogy(range(len(errors)), errors, 'b-o', markersize=4)
    ax1.axhline(y=0, color='gray', linestyle='--', alpha=0.3)
    ax1.set_xlabel('Averaging steps', fontsize=12)
    ax1.set_ylabel('Error (L² norm)', fontsize=12)
    ax1.set_title('Denoising via Orthogonal Averaging', fontsize=13)
    ax1.grid(True, alpha=0.3)

    # Show signal before/after
    x = range(N)
    ax2.scatter(x, noisy_signal, s=10, alpha=0.5, label='Noisy', color='red')
    final_smooth = noisy_signal.copy()
    for _ in range(10):
        final_smooth = final_smooth @ T
    ax2.scatter(x, final_smooth, s=10, alpha=0.5, label='Smoothed (10 steps)', color='blue')
    ax2.axhline(y=5.0, color='green', linestyle='--', label='True signal', alpha=0.7)
    ax2.set_xlabel('Group element index', fontsize=12)
    ax2.set_ylabel('Value', fontsize=12)
    ax2.set_title('Before/After Smoothing', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('smoothing_application.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved smoothing_application.png")


def app_error_correcting():
    """Application 4: Cayley graph codes.

    Expander Cayley graphs can be used to construct error-correcting
    codes with good distance properties. The spectral gap controls
    the minimum distance of the code.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Error-Correcting Codes from Cayley Expanders")
    print("=" * 60)

    elements, gens, op, idx, T = build_hyperoctahedral(3)
    N = len(elements)

    evals = np.sort(np.real(np.linalg.eigvals(T)))[::-1]
    gap = 1 - evals[1]
    d = len(gens)

    # Tanner code: use Cayley graph as inner code graph
    # Rate = 1 - d/N (asymptotically)
    # Distance >= gap * N / (2d) (Sipser-Spielman bound)

    rate = 1 - d / N
    distance_bound = gap * N / (2 * d)

    print(f"  Cayley graph: B_3, |V|={N}, degree={d}")
    print(f"  Spectral gap: {gap:.4f}")
    print(f"  Tanner code parameters:")
    print(f"    Rate: {rate:.4f}")
    print(f"    Distance bound: {distance_bound:.2f}")
    print(f"    Relative distance: {distance_bound / N:.4f}")


if __name__ == '__main__':
    print("BOURGAIN-GAMBURD MACHINE: APPLICATIONS")
    print("=" * 60)

    app_network_robustness()
    app_pseudorandom_generator()
    app_smoothing_operator()
    app_error_correcting()

    print("\n" + "=" * 60)
    print("All applications demonstrated successfully!")


#!/usr/bin/env python3
"""
Bourgain-Gamburd Machine: Spectral Gap Demonstrations

This module demonstrates the key concepts of the Bourgain-Gamburd
expansion machine applied to finite orthogonal groups, including:
- Random walks on Cayley graphs
- Convolution and L2 flattening
- Spectral gap computation
- Mixing time estimates

All computations are done with concrete finite groups.
"""

import numpy as np
from itertools import product as iterproduct
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def make_cayley_adjacency(group_elements, generators, group_op):
    """Build the adjacency matrix of a Cayley graph.

    Args:
        group_elements: list of group elements
        generators: list of generators (symmetric set)
        group_op: function (g, s) -> g*s

    Returns:
        numpy array: adjacency matrix
    """
    n = len(group_elements)
    idx = {tuple(g) if hasattr(g, '__iter__') else g: i
           for i, g in enumerate(group_elements)}
    A = np.zeros((n, n))
    for i, g in enumerate(group_elements):
        for s in generators:
            gs = group_op(g, s)
            key = tuple(gs) if hasattr(gs, '__iter__') else gs
            j = idx[key]
            A[i, j] = 1
    return A


def signed_permutation_group(n):
    """Generate the hyperoctahedral group B_n (signed permutations).

    Elements are (perm, signs) where perm is a permutation of {0,...,n-1}
    and signs is a tuple of +1/-1.

    Returns:
        elements: list of (perm_tuple, signs_tuple)
        generators: symmetric generating set
        group_op: group operation
    """
    from itertools import permutations
    elements = []
    for perm in permutations(range(n)):
        for signs in iterproduct([1, -1], repeat=n):
            elements.append((perm, signs))

    def group_op(a, b):
        pa, sa = a
        pb, sb = b
        # Composition: (pa, sa) * (pb, sb) = (pa∘pb, sa[pb[i]] * sb[i])
        new_perm = tuple(pa[pb[i]] for i in range(n))
        new_signs = tuple(sa[pb[i]] * sb[i] for i in range(n))
        return (new_perm, new_signs)

    identity = (tuple(range(n)), tuple([1] * n))

    # Generators: adjacent transpositions and sign flips
    gens = []
    for i in range(n - 1):
        perm = list(range(n))
        perm[i], perm[i + 1] = perm[i + 1], perm[i]
        gens.append((tuple(perm), tuple([1] * n)))
    # Sign flip of first coordinate
    signs = [1] * n
    signs[0] = -1
    gens.append((tuple(range(n)), tuple(signs)))

    # Make symmetric
    def inv_element(a):
        pa, sa = a
        inv_perm = [0] * n
        for i in range(n):
            inv_perm[pa[i]] = i
        inv_signs = tuple(sa[inv_perm[i]] for i in range(n))
        return (tuple(inv_perm), inv_signs)

    sym_gens = list(set(gens + [inv_element(g) for g in gens]))

    return elements, sym_gens, group_op


def compute_spectral_gap(adjacency_matrix):
    """Compute the spectral gap of the averaging operator.

    The spectral gap is 1 - lambda_2, where lambda_2 is the
    second-largest eigenvalue of the normalized adjacency matrix.
    """
    n = adjacency_matrix.shape[0]
    row_sums = adjacency_matrix.sum(axis=1)
    # Normalized averaging operator
    T = adjacency_matrix / row_sums[:, np.newaxis]
    eigenvalues = np.sort(np.real(np.linalg.eigvals(T)))[::-1]
    lambda_1 = eigenvalues[0]  # Should be 1
    lambda_2 = eigenvalues[1]
    return 1 - lambda_2, eigenvalues


def random_walk_mixing(T, steps=50):
    """Simulate mixing of a random walk.

    Args:
        T: transition matrix (averaging operator)
        steps: number of steps

    Returns:
        l2_distances: L2 distance from uniform at each step
    """
    n = T.shape[0]
    uniform = np.ones(n) / n
    # Start from a point mass at vertex 0
    mu = np.zeros(n)
    mu[0] = 1.0

    l2_distances = []
    for _ in range(steps):
        diff = mu - uniform
        l2_distances.append(np.sqrt(np.sum(diff ** 2)))
        mu = mu @ T

    return l2_distances


def convolution_l2_decay(mu, group_elements, group_op):
    """Compute the L2 norm squared after self-convolution.

    mu * mu (x) = sum_g mu(g) * mu(g^{-1} x)
    """
    n = len(group_elements)
    idx = {}
    for i, g in enumerate(group_elements):
        key = tuple(g) if hasattr(g, '__iter__') else g
        idx[key] = i

    # We need inverse operation
    def inv_op(g):
        # For signed permutations
        pa, sa = g
        nn = len(pa)
        inv_perm = [0] * nn
        for i in range(nn):
            inv_perm[pa[i]] = i
        inv_signs = tuple(sa[inv_perm[i]] for i in range(nn))
        return (tuple(inv_perm), inv_signs)

    result = np.zeros(n)
    for i, x in enumerate(group_elements):
        total = 0.0
        for j, g in enumerate(group_elements):
            ginv = inv_op(g)
            ginv_x = group_op(ginv, x)
            key = tuple(ginv_x) if hasattr(ginv_x, '__iter__') else ginv_x
            k = idx[key]
            total += mu[j] * mu[k]
        result[i] = total

    return result


def demo_spectral_gap():
    """Demonstrate spectral gap computation for signed permutation groups."""
    print("=" * 60)
    print("BOURGAIN-GAMBURD MACHINE: SPECTRAL GAP DEMO")
    print("=" * 60)

    for n in [2, 3]:
        print(f"\n--- Hyperoctahedral Group B_{n} ---")
        elements, generators, group_op = signed_permutation_group(n)
        print(f"  Group order: |B_{n}| = {len(elements)}")
        print(f"  Number of generators: |S| = {len(generators)}")

        # Build adjacency matrix
        A = make_cayley_adjacency(elements, generators, group_op)
        gap, eigenvalues = compute_spectral_gap(A)

        print(f"  Spectral gap: {gap:.6f}")
        print(f"  Top 5 eigenvalues: {eigenvalues[:5]}")

        # Random walk mixing
        T = A / A.sum(axis=1)[:, np.newaxis]
        distances = random_walk_mixing(T, steps=30)
        print(f"  L2 distance after 10 steps: {distances[10]:.6f}")
        print(f"  L2 distance after 20 steps: {distances[20]:.6f}")

        # L2 flattening under convolution
        mu = np.zeros(len(elements))
        for gen in generators:
            key = tuple(gen) if hasattr(gen, '__iter__') else gen
            idx = next(i for i, e in enumerate(elements)
                       if (tuple(e) if hasattr(e, '__iter__') else e) == key)
            mu[idx] = 1.0 / len(generators)

        l2_orig = np.sum(mu ** 2)
        mu_conv = convolution_l2_decay(mu, elements, group_op)
        l2_conv = np.sum(mu_conv ** 2)
        print(f"  L2 norm² of μ_S: {l2_orig:.6f}")
        print(f"  L2 norm² of μ_S * μ_S: {l2_conv:.6f}")
        print(f"  Contraction ratio: {l2_conv / l2_orig:.6f}")


def demo_mixing_visualization():
    """Create visualization of random walk mixing on Cayley graphs."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    for idx, n in enumerate([2, 3]):
        elements, generators, group_op = signed_permutation_group(n)
        A = make_cayley_adjacency(elements, generators, group_op)
        T = A / A.sum(axis=1)[:, np.newaxis]
        gap, _ = compute_spectral_gap(A)

        distances = random_walk_mixing(T, steps=40)

        ax = axes[idx]
        steps = range(len(distances))
        ax.semilogy(steps, distances, 'b-o', markersize=3, label='Random walk L²')

        # Theoretical bound: (1-gap)^t * sqrt(|G|)
        theoretical = [np.sqrt(len(elements)) * (1 - gap) ** t for t in steps]
        ax.semilogy(steps, theoretical, 'r--', label=f'Spectral bound (gap={gap:.3f})')

        ax.set_xlabel('Steps', fontsize=12)
        ax.set_ylabel('L² distance from uniform', fontsize=12)
        ax.set_title(f'Mixing in Cayley(B_{n}, S)\n|G|={len(elements)}',
                      fontsize=13)
        ax.legend(fontsize=10)
        ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('mixing_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved mixing_visualization.png")


def demo_eigenvalue_spectrum():
    """Visualize the eigenvalue spectrum of Cayley graph averaging operators."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    for idx, n in enumerate([2, 3]):
        elements, generators, group_op = signed_permutation_group(n)
        A = make_cayley_adjacency(elements, generators, group_op)
        T = A / A.sum(axis=1)[:, np.newaxis]
        _, eigenvalues = compute_spectral_gap(A)

        ax = axes[idx]
        ax.bar(range(len(eigenvalues)), sorted(eigenvalues, reverse=True),
               color='steelblue', alpha=0.7)
        ax.axhline(y=1, color='green', linestyle='--', alpha=0.5, label='λ₁ = 1')
        ax.axhline(y=eigenvalues[1], color='red', linestyle='--', alpha=0.5,
                    label=f'λ₂ = {eigenvalues[1]:.3f}')
        ax.set_xlabel('Eigenvalue index', fontsize=12)
        ax.set_ylabel('Eigenvalue', fontsize=12)
        ax.set_title(f'Spectrum of T_S on Cayley(B_{n}, S)\nSpectral gap = {1-eigenvalues[1]:.4f}',
                      fontsize=13)
        ax.legend(fontsize=10)
        ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('eigenvalue_spectrum.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved eigenvalue_spectrum.png")


def demo_l2_flattening():
    """Demonstrate L2 flattening under iterated convolution."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    for n in [2, 3]:
        elements, generators, group_op = signed_permutation_group(n)
        A = make_cayley_adjacency(elements, generators, group_op)
        T = A / A.sum(axis=1)[:, np.newaxis]

        # Start with generator measure
        mu = np.zeros(len(elements))
        for gen in generators:
            key = tuple(gen) if hasattr(gen, '__iter__') else gen
            i = next(j for j, e in enumerate(elements)
                     if (tuple(e) if hasattr(e, '__iter__') else e) == key)
            mu[i] = 1.0 / len(generators)

        l2_norms = [np.sum(mu ** 2)]
        uniform_l2 = 1.0 / len(elements)

        for step in range(15):
            mu = mu @ T
            l2_norms.append(np.sum(mu ** 2))

        # Normalize by uniform L2
        ratios = [l / uniform_l2 for l in l2_norms]
        ax.semilogy(range(len(ratios)), ratios, '-o', markersize=4,
                     label=f'B_{n} (|G|={len(elements)})')

    ax.axhline(y=1, color='gray', linestyle='--', alpha=0.5, label='Uniform')
    ax.set_xlabel('Convolution steps', fontsize=12)
    ax.set_ylabel('L² norm² / uniform L² norm²', fontsize=12)
    ax.set_title('L² Flattening Under Iterated Convolution\n'
                  'Bourgain-Gamburd Machine in Action', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('l2_flattening.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved l2_flattening.png")


if __name__ == '__main__':
    demo_spectral_gap()
    print()
    demo_mixing_visualization()
    demo_eigenvalue_spectrum()
    demo_l2_flattening()
    print("\nAll demos completed successfully!")
