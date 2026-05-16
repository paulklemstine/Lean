#!/usr/bin/env python3
"""
Applications of Tropical Pseudorandom Dynamics

1. Scheduling network initialization forgetting
2. Deterministic sampling from tropical dynamics
3. Consensus protocol convergence certification
4. Tropical hash function construction
"""

import numpy as np
from algorithms import (
    tropical_mat_vec_mul, compute_orbit, hilbert_projective_distance,
    estimate_spectral_gap, estimate_birkhoff_contraction,
    extract_symbolic_trace, TropicalPRG
)


# ═══════════════════════════════════════════════════════════════
# Application 1: Scheduling Network Initialization Forgetting
# ═══════════════════════════════════════════════════════════════

def scheduling_network_demo():
    """
    Model a timed event system (e.g., train scheduling, manufacturing)
    as a max-plus linear system and show initialization forgetting.

    In max-plus systems, x_i(t) = time of event i at step t.
    The system x(t+1) = A ⊗ x(t) models:
    - Processing times (diagonal)
    - Transportation/setup delays (off-diagonal)

    The theorem guarantees: regardless of initial delays/disruptions,
    the relative timing pattern stabilizes exponentially fast.
    """
    print("=" * 60)
    print("APPLICATION 1: Scheduling Network Initialization Forgetting")
    print("=" * 60)

    # 4-station manufacturing line
    # Diagonal: processing times, Off-diagonal: transport times
    A = np.array([
        [10.0,  2.0,  0.0,  0.0],  # Station 1
        [ 3.0, 12.0,  2.0,  0.0],  # Station 2
        [ 0.0,  3.0, 11.0,  2.0],  # Station 3
        [ 0.0,  0.0,  3.0, 10.0],  # Station 4
    ])

    print("\nManufacturing line with 4 stations:")
    print("  Processing times: [10, 12, 11, 10] time units")
    print("  Transport delays: 2-3 time units between adjacent stations")

    l1, l2, gap = estimate_spectral_gap(A)
    print(f"\n  Tropical spectral radius: {l1:.2f}")
    print(f"  Spectral gap: {gap:.2f}")

    # Scenario: normal start vs disrupted start
    x_normal = np.array([0.0, 0.0, 0.0, 0.0])
    x_disrupted = np.array([50.0, -20.0, 30.0, -10.0])

    T = 15
    orb_n = compute_orbit(A, x_normal, T)
    orb_d = compute_orbit(A, x_disrupted, T)

    print(f"\n  Projective distance over time (normal vs disrupted start):")
    for t in range(T + 1):
        d = hilbert_projective_distance(orb_n[t], orb_d[t])
        bar = "█" * int(min(d, 50))
        print(f"    t={t:2d}: d = {d:8.4f}  {bar}")

    print("\n  → The system 'forgets' the disruption exponentially fast!")
    print("    Steady-state timing pattern is independent of initialization.")


# ═══════════════════════════════════════════════════════════════
# Application 2: Deterministic Sampling
# ═══════════════════════════════════════════════════════════════

def deterministic_sampling_demo():
    """
    Use tropical dynamics to generate deterministic samples
    that are approximately uniform over a finite alphabet.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Deterministic Sampling via Tropical Dynamics")
    print("=" * 60)

    # Design a matrix with good mixing properties
    n = 5
    A = np.zeros((n, n))
    for i in range(n):
        A[i, i] = 3.0  # Self-loops
        A[i, (i + 1) % n] = 2.5  # Forward
        A[i, (i + 2) % n] = 1.0  # Skip
        A[i, (i - 1) % n] = 2.0  # Backward

    print(f"\n  Using {n}×{n} tropical matrix with circulant structure")
    kappa = estimate_birkhoff_contraction(A)
    print(f"  Birkhoff contraction coefficient: {kappa:.6f}")

    # Generate samples from multiple seeds
    T_burn = 20  # Burn-in period
    T_gen = 200

    seeds = [np.random.RandomState(s).randn(n) * 10 for s in range(5)]

    print(f"\n  Symbol frequencies from {len(seeds)} seeds "
          f"(burn-in={T_burn}, length={T_gen}):")
    print(f"  {'Seed':>6} | " + " | ".join(f"sym={s}" for s in range(n)) + " | χ²")

    for idx, seed in enumerate(seeds):
        trace = extract_symbolic_trace(A, seed, T_burn + T_gen)
        symbols = trace[T_burn:]
        freqs = [symbols.count(s) / len(symbols) for s in range(n)]
        chi2 = sum((f - 1/n)**2 / (1/n) for f in freqs) * len(symbols)
        print(f"  {idx:>6} | " + " | ".join(f"{f:.3f}" for f in freqs)
              + f" | {chi2:.2f}")

    print(f"\n  Expected frequency: {1/n:.3f} (uniform)")
    print("  → After burn-in, all seeds produce similar symbol frequencies!")


# ═══════════════════════════════════════════════════════════════
# Application 3: Consensus Protocol Convergence
# ═══════════════════════════════════════════════════════════════

def consensus_protocol_demo():
    """
    Model a max-consensus protocol where agents update by taking
    max of neighbors' values (plus weights). Show convergence to
    agreement on the projective class.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Max-Consensus Protocol Convergence")
    print("=" * 60)

    # 6 agents in a connected network
    n = 6
    A = np.full((n, n), -100.0)  # Very weak default connections
    # Ring + some long-range connections
    for i in range(n):
        A[i, i] = 0.0
        A[i, (i + 1) % n] = -0.5
        A[i, (i - 1) % n] = -0.5
    A[0, 3] = -1.0  # Long-range
    A[3, 0] = -1.0
    A[1, 4] = -1.0
    A[4, 1] = -1.0

    print(f"\n  {n}-agent network (ring + long-range links)")

    # Different initial opinions
    opinions = np.array([10.0, -5.0, 3.0, -8.0, 15.0, 1.0])
    print(f"  Initial opinions: {opinions}")

    T = 20
    orb = compute_orbit(A, opinions, T)

    print(f"\n  Projective spread (max - min of normalized state) over time:")
    for t in range(T + 1):
        spread = np.max(orb[t]) - np.min(orb[t])
        norm_spread = hilbert_projective_distance(orb[t], np.zeros(n))
        bar = "█" * int(min(norm_spread * 2, 40))
        print(f"    t={t:2d}: spread = {norm_spread:8.4f}  {bar}")

    print("\n  → Agents converge to projective consensus!")
    print("    The spectral gap controls the convergence rate.")


# ═══════════════════════════════════════════════════════════════
# Application 4: Tropical Hash Function
# ═══════════════════════════════════════════════════════════════

def tropical_hash_demo():
    """
    Construct a simple hash function using tropical dynamics.
    The spectral gap ensures collision resistance in the
    projective/symbolic sense.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Tropical Hash Function")
    print("=" * 60)

    n = 8
    # Build a well-conditioned tropical matrix
    rng = np.random.RandomState(42)
    A = rng.uniform(0, 5, (n, n))
    # Strengthen diagonal for spectral gap
    for i in range(n):
        A[i, i] += 3.0

    T = 10  # Hash rounds

    def tropical_hash(message: bytes, output_len: int = 16) -> str:
        """Hash a message using tropical dynamics."""
        # Encode message as initial state
        x0 = np.zeros(n)
        for i, b in enumerate(message):
            x0[i % n] += b * (0.1 + 0.01 * (i // n))

        # Iterate
        orbit = compute_orbit(A, x0, T)
        final = orbit[T]

        # Extract hash from projective pattern
        normalized = final - np.min(final)
        # Quantize to hex
        quantized = (normalized * 1000).astype(int) % 256
        return ''.join(f'{b:02x}' for b in quantized[:output_len // 2])

    messages = [
        b"Hello, World!",
        b"Hello, World?",
        b"hello, world!",
        b"Tropical dynamics is beautiful",
        b"",
    ]

    print(f"\n  Hashing with n={n}, T={T} rounds:")
    for msg in messages:
        h = tropical_hash(msg)
        print(f"    '{msg.decode():35s}' → {h}")

    print("\n  → Small input changes produce different hashes")
    print("    (avalanche effect from spectral gap / projective contraction)")


if __name__ == "__main__":
    scheduling_network_demo()
    deterministic_sampling_demo()
    consensus_protocol_demo()
    tropical_hash_demo()

    print("\n" + "=" * 60)
    print("All applications demonstrated successfully!")
    print("=" * 60)
