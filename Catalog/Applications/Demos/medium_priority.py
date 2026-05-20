#!/usr/bin/env python3
"""
Tropical Matrix Certificate — Applications

Real-world applications of tropical matrix certificates:

1. Network delay diagnosis — detecting separable vs interacting delays
2. Cost matrix analysis — factoring transportation costs
3. Scheduling feasibility — certifying optimal schedules
4. Data analysis — testing for additive structure in log-transformed data
"""

import numpy as np
from algorithms import TropicalMatrixCertificate, tropical_matrix_multiply


def network_delay_diagnosis():
    """
    Application 1: Network Delay Diagnosis
    
    In a network with n sources and m destinations, the delay matrix D[i,j]
    records the latency from source i to destination j.
    
    If D is additively separable (D[i,j] = u[i] + v[j]), then delays
    decompose into independent source-side and destination-side components.
    No interaction effects exist.
    
    If the certificate fails, a "bad rectangle" identifies four (source, dest)
    pairs where interaction effects are present — e.g., congestion on a
    specific cross-link.
    """
    print("=" * 70)
    print("APPLICATION 1: Network Delay Diagnosis")
    print("=" * 70)
    
    # Scenario A: Separable delays (no interaction)
    source_delays = np.array([10.0, 15.0, 8.0, 20.0])  # ms
    dest_delays = np.array([5.0, 12.0, 3.0, 8.0, 15.0])  # ms
    D_sep = source_delays[:, np.newaxis] + dest_delays[np.newaxis, :]
    
    cert = TropicalMatrixCertificate(D_sep)
    print("\nScenario A: Independent source/destination delays")
    print(f"  Certificate holds: {cert.check()}")
    u, v = cert.extract_potentials()
    print(f"  Source delays (extracted): {np.round(u, 1)}")
    print(f"  Dest delays (extracted):  {np.round(v + u[0], 1)}")
    
    # Scenario B: Congested cross-link
    D_cong = D_sep.copy()
    D_cong[1, 3] += 5.0  # Extra delay on source 1 → dest 3
    D_cong[2, 0] += 3.0  # Extra delay on source 2 → dest 0
    
    cert2 = TropicalMatrixCertificate(D_cong)
    print("\nScenario B: Congested cross-links")
    print(f"  Certificate holds: {cert2.check()}")
    bad = cert2.find_bad_rectangle()
    if bad:
        i1, i2, j1, j2, viol = bad
        print(f"  Interaction detected: sources ({i1},{i2}), dests ({j1},{j2})")
        print(f"  Violation magnitude: {viol:.1f} ms")
        print("  → This identifies a congested cross-link requiring investigation")


def transportation_cost_analysis():
    """
    Application 2: Transportation Cost Factoring
    
    A shipping cost matrix C[i,j] gives the cost from warehouse i to customer j.
    
    If C is additively separable, costs decompose into:
    - Warehouse-specific handling/loading costs
    - Customer-specific delivery costs
    
    This means pricing can be done independently for each side.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Transportation Cost Analysis")
    print("=" * 70)
    
    # Separable costs
    warehouse_costs = np.array([50.0, 30.0, 45.0])
    delivery_costs = np.array([20.0, 35.0, 15.0, 40.0])
    C = warehouse_costs[:, np.newaxis] + delivery_costs[np.newaxis, :]
    
    cert = TropicalMatrixCertificate(C)
    print("\nSeparable cost structure:")
    print(f"  Certificate: {cert.check()}")
    u, v = cert.extract_potentials()
    print(f"  Warehouse costs: {np.round(u, 0)}")
    print(f"  Delivery costs:  {np.round(v, 0)}")
    print("  → Pricing can be decomposed independently!")
    
    # Non-separable: distance-dependent costs
    locations_w = np.array([[0, 0], [10, 0], [5, 8]])  # warehouse coords
    locations_c = np.array([[2, 3], [8, 1], [1, 7], [9, 6]])  # customer coords
    C_dist = np.sqrt(
        np.sum((locations_w[:, np.newaxis, :] - locations_c[np.newaxis, :, :]) ** 2, axis=2)
    )
    
    cert2 = TropicalMatrixCertificate(C_dist)
    print("\nDistance-dependent cost structure:")
    print(f"  Certificate: {cert2.check()}")
    bad = cert2.find_bad_rectangle()
    if bad:
        print(f"  Non-separable witness: warehouses ({bad[0]},{bad[1]}), "
              f"customers ({bad[2]},{bad[3]})")
        print("  → Distance-based costs have interaction effects (geometry matters)")


def schedule_analysis():
    """
    Application 3: Schedule Feasibility
    
    In project scheduling, a task matrix T[i,j] gives the time for
    worker i to complete task j. If T is additively separable:
        T[i,j] = skill[i] + difficulty[j]
    
    then workers and tasks are "independent" — no specialization effects.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Schedule Analysis")
    print("=" * 70)
    
    # Independent skills + difficulty
    skill = np.array([2.0, 5.0, 3.0, 1.0])
    difficulty = np.array([4.0, 2.0, 7.0, 1.0, 5.0])
    T = skill[:, np.newaxis] + difficulty[np.newaxis, :]
    
    cert = TropicalMatrixCertificate(T)
    print("\nNo specialization (independent skills + difficulty):")
    print(f"  Certificate: {cert.check()}")
    
    # With specialization
    T_spec = T.copy()
    T_spec[0, 2] -= 3.0  # Worker 0 is especially good at task 2
    T_spec[3, 0] -= 2.0  # Worker 3 is especially good at task 0
    
    cert2 = TropicalMatrixCertificate(T_spec)
    print("\nWith worker specialization:")
    print(f"  Certificate: {cert2.check()}")
    bad = cert2.find_bad_rectangle()
    if bad:
        print(f"  Specialization detected: workers ({bad[0]},{bad[1]}), "
              f"tasks ({bad[2]},{bad[3]})")
        print("  → Workers have task-specific advantages (cannot decompose)")


def log_data_independence():
    """
    Application 4: Testing Independence in Log-Transformed Data
    
    For a contingency table P[i,j] of joint probabilities,
    independence means P[i,j] = p_i * q_j.
    
    Taking logs: log P[i,j] = log p_i + log q_j.
    
    So tropical certificate on log P tests for independence!
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Independence Test via Log Transform")
    print("=" * 70)
    
    # Independent distribution
    p = np.array([0.3, 0.2, 0.5])
    q = np.array([0.1, 0.4, 0.15, 0.35])
    P_indep = p[:, np.newaxis] * q[np.newaxis, :]
    logP = np.log(P_indep)
    
    cert = TropicalMatrixCertificate(logP)
    print("\nIndependent distribution:")
    print(f"  Certificate on log P: {cert.check()}")
    print("  → Variables are independent (log-probability is additively separable)")
    
    # Correlated distribution
    P_corr = P_indep.copy()
    P_corr[0, 0] += 0.02
    P_corr[0, 1] -= 0.02
    P_corr[1, 0] -= 0.02
    P_corr[1, 1] += 0.02
    # Renormalize
    P_corr /= P_corr.sum()
    logP_corr = np.log(P_corr)
    
    cert2 = TropicalMatrixCertificate(logP_corr)
    print("\nCorrelated distribution:")
    print(f"  Certificate on log P: {cert2.check()}")
    bad = cert2.find_bad_rectangle()
    if bad:
        print(f"  Correlation witness: categories ({bad[0]},{bad[1]}), "
              f"outcomes ({bad[2]},{bad[3]})")
        print(f"  Violation (= interaction strength): {bad[4]:.6f}")
        print("  → Variables are NOT independent")


if __name__ == "__main__":
    network_delay_diagnosis()
    transportation_cost_analysis()
    schedule_analysis()
    log_data_independence()
    
    print("\n" + "=" * 70)
    print("All applications completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Matrix Certificate — Interactive Demo

Demonstrates:
1. Checking the tropical rectangle certificate on matrices
2. Extracting canonical potentials (u, v) from certified matrices
3. Detecting and displaying "bad rectangle" witnesses when certificate fails
4. Visualizing separable vs non-separable energy landscapes
"""

import numpy as np
import itertools


def check_rectangle(A, i1, i2, j1, j2):
    """Check if a single 2x2 rectangle satisfies the tropical rectangle equality."""
    return np.isclose(A[i1, j1] + A[i2, j2], A[i1, j2] + A[i2, j1])


def has_tropical_certificate(A):
    """Check if ALL 2x2 rectangles satisfy the tropical rectangle equality."""
    n, m = A.shape
    for i1, i2 in itertools.combinations(range(n), 2):
        for j1, j2 in itertools.combinations(range(m), 2):
            if not check_rectangle(A, i1, i2, j1, j2):
                return False
    return True


def find_bad_rectangle(A):
    """Find the first bad rectangle witness, or None if certificate holds."""
    n, m = A.shape
    for i1, i2 in itertools.combinations(range(n), 2):
        for j1, j2 in itertools.combinations(range(m), 2):
            if not check_rectangle(A, i1, i2, j1, j2):
                violation = abs(
                    (A[i1, j1] + A[i2, j2]) - (A[i1, j2] + A[i2, j1])
                )
                return (i1, i2, j1, j2, violation)
    return None


def extract_potentials(A, i0=0, j0=0):
    """
    Extract canonical potentials from a certified matrix.
    
    Given base indices (i0, j0), compute:
        u(i) = A(i, j0)
        v(j) = A(i0, j) - A(i0, j0)
    
    Then A(i,j) = u(i) + v(j) for all i,j (if certificate holds).
    """
    u = A[:, j0].copy()
    v = A[i0, :] - A[i0, j0]
    return u, v


def reconstruct_from_potentials(u, v):
    """Reconstruct the matrix A(i,j) = u(i) + v(j)."""
    return u[:, np.newaxis] + v[np.newaxis, :]


def generate_rank_one_matrix(n, m, seed=None):
    """Generate a random tropical rank-one matrix A(i,j) = u(i) + v(j)."""
    rng = np.random.default_rng(seed)
    u = rng.standard_normal(n)
    v = rng.standard_normal(m)
    return u[:, np.newaxis] + v[np.newaxis, :], u, v


def generate_random_matrix(n, m, seed=None):
    """Generate a random matrix (generically not rank-one)."""
    rng = np.random.default_rng(seed)
    return rng.standard_normal((n, m))


def print_matrix(A, name="A"):
    """Pretty-print a matrix."""
    print(f"\n{name} =")
    n, m = A.shape
    for i in range(n):
        row = "  [" + "  ".join(f"{A[i,j]:7.3f}" for j in range(m)) + "]"
        print(row)


def demo_rank_one():
    """Demo: A rank-one matrix passes the certificate and admits potential extraction."""
    print("=" * 70)
    print("DEMO 1: Tropical Rank-One Matrix (Certificate Holds)")
    print("=" * 70)

    A, u_true, v_true = generate_rank_one_matrix(4, 5, seed=42)
    print_matrix(A, "A (rank-one)")

    cert = has_tropical_certificate(A)
    print(f"\nCertificate holds: {cert}")

    u, v = extract_potentials(A)
    print(f"\nExtracted potentials:")
    print(f"  u = {np.array2string(u, precision=3)}")
    print(f"  v = {np.array2string(v, precision=3)}")

    A_recon = reconstruct_from_potentials(u, v)
    error = np.max(np.abs(A - A_recon))
    print(f"\nReconstruction error: {error:.2e}")

    # Show gauge relationship
    c = u_true[0] - u[0]
    print(f"\nGauge constant c = u_true[0] - u[0] = {c:.6f}")
    print(f"  u_true - u = {np.array2string(u_true - u, precision=6)}")
    print(f"  v - v_true = {np.array2string(v - v_true, precision=6)}")
    print(f"  (All entries should equal c = {c:.6f})")


def demo_random():
    """Demo: A random matrix fails the certificate and has a bad rectangle."""
    print("\n" + "=" * 70)
    print("DEMO 2: Random Matrix (Certificate Fails)")
    print("=" * 70)

    A = generate_random_matrix(4, 5, seed=123)
    print_matrix(A, "A (random)")

    cert = has_tropical_certificate(A)
    print(f"\nCertificate holds: {cert}")

    bad = find_bad_rectangle(A)
    if bad:
        i1, i2, j1, j2, violation = bad
        print(f"\nBad rectangle witness: rows ({i1},{i2}), cols ({j1},{j2})")
        print(f"  A[{i1},{j1}] + A[{i2},{j2}] = {A[i1,j1]:.4f} + {A[i2,j2]:.4f} = {A[i1,j1]+A[i2,j2]:.4f}")
        print(f"  A[{i1},{j2}] + A[{i2},{j1}] = {A[i1,j2]:.4f} + {A[i2,j1]:.4f} = {A[i1,j2]+A[i2,j1]:.4f}")
        print(f"  Violation magnitude: {violation:.6f}")


def demo_perturbation():
    """Demo: Perturbing a rank-one matrix breaks the certificate."""
    print("\n" + "=" * 70)
    print("DEMO 3: Perturbed Rank-One Matrix")
    print("=" * 70)

    A, _, _ = generate_rank_one_matrix(4, 5, seed=7)
    print_matrix(A, "A (rank-one)")
    print(f"Certificate holds: {has_tropical_certificate(A)}")

    # Perturb one entry
    A_pert = A.copy()
    A_pert[1, 2] += 0.5
    print_matrix(A_pert, "A_perturbed (A[1,2] += 0.5)")
    print(f"Certificate holds: {has_tropical_certificate(A_pert)}")

    bad = find_bad_rectangle(A_pert)
    if bad:
        i1, i2, j1, j2, violation = bad
        print(f"Bad rectangle: rows ({i1},{i2}), cols ({j1},{j2}), violation = {violation:.6f}")


def demo_statistics():
    """Demo: Statistical analysis — how many random matrices are rank-one?"""
    print("\n" + "=" * 70)
    print("DEMO 4: Statistical Analysis")
    print("=" * 70)

    sizes = [(3, 3), (4, 4), (5, 5), (3, 6)]
    n_trials = 200

    print(f"\nTesting {n_trials} random matrices per size:")
    print(f"{'Size':>10s} | {'Rank-one':>10s} | {'Not rank-one':>12s} | {'% rank-one':>10s}")
    print("-" * 50)

    for n, m in sizes:
        rank_one_count = 0
        for trial in range(n_trials):
            A = generate_random_matrix(n, m, seed=1000 * n + trial)
            if has_tropical_certificate(A):
                rank_one_count += 1
        pct = 100.0 * rank_one_count / n_trials
        print(f"{n}x{m:>2d}      | {rank_one_count:>10d} | {n_trials - rank_one_count:>12d} | {pct:>9.1f}%")

    print("\n(Random matrices are generically NOT rank-one — tropical rank one")
    print(" requires n*m - n - m + 1 independent constraints to hold exactly.)")


def demo_row_diff_constancy():
    """Demo: Row-difference constancy (vanishing curl) on certified matrices."""
    print("\n" + "=" * 70)
    print("DEMO 5: Row-Difference Constancy (Vanishing Curl)")
    print("=" * 70)

    A, _, _ = generate_rank_one_matrix(4, 5, seed=99)
    print_matrix(A, "A (rank-one)")

    print("\nRow differences A(i, 0) - A(i, 1) for each row i:")
    for i in range(4):
        diff = A[i, 0] - A[i, 1]
        print(f"  Row {i}: {diff:.6f}")
    print("  (All equal — this is the vanishing curl condition)")

    print("\nRow differences A(i, 2) - A(i, 3) for each row i:")
    for i in range(4):
        diff = A[i, 2] - A[i, 3]
        print(f"  Row {i}: {diff:.6f}")
    print("  (Again all equal)")


if __name__ == "__main__":
    demo_rank_one()
    demo_random()
    demo_perturbation()
    demo_statistics()
    demo_row_diff_constancy()

    print("\n" + "=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)
