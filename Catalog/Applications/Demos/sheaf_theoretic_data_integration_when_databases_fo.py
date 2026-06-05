"""
Sheaf-Theoretic Data Integration: Interactive Demo

Demonstrates the key results from the formalization:
1. Iterated Gluing of consistent partial databases
2. Coboundary pseudometric and triangle inequality
3. Consistency probability phase transition
4. Feature-subset sheaf properties
"""
import numpy as np
from algorithms import (
    PartialDatabase, is_consistent_pair, sheaf_condition,
    glue_pair, iterated_glue, coboundary_distance,
    total_coboundary_norm, consistency_probability,
    critical_constraint_count, feature_projection,
    check_presheaf_composition
)


def demo_iterated_gluing():
    """Demo 1: Iterated Gluing Theorem
    
    Shows that pairwise consistent partial databases can be iteratively
    glued into a section extending all of them.
    """
    print("=" * 60)
    print("DEMO 1: Iterated Gluing Theorem")
    print("=" * 60)
    
    # Create 3 partial databases that are pairwise consistent
    # Ground truth: [[1,2,3],[4,5,6],[7,8,9]]
    
    db1 = PartialDatabase(3, 3)
    db1.set(0, 0, 1); db1.set(0, 1, 2)  # Row 0: [1, 2, ?]
    db1.set(1, 0, 4)                      # Row 1: [4, ?, ?]
    
    db2 = PartialDatabase(3, 3)
    db2.set(0, 1, 2); db2.set(0, 2, 3)  # Row 0: [?, 2, 3]
    db2.set(1, 1, 5)                      # Row 1: [?, 5, ?]
    
    db3 = PartialDatabase(3, 3)
    db3.set(1, 2, 6)                      # Row 1: [?, ?, 6]
    db3.set(2, 0, 7); db3.set(2, 1, 8); db3.set(2, 2, 9)  # Row 2 complete
    
    dbs = [db1, db2, db3]
    
    print(f"\nPartial DB 1 domain: {sorted(db1.domain())}")
    print(f"Partial DB 2 domain: {sorted(db2.domain())}")
    print(f"Partial DB 3 domain: {sorted(db3.domain())}")
    
    # Check pairwise consistency
    print(f"\nPairwise consistency:")
    for i in range(3):
        for j in range(i+1, 3):
            print(f"  DB{i+1} ↔ DB{j+1}: {is_consistent_pair(dbs[i], dbs[j])}")
    
    print(f"\nSheaf condition satisfied: {sheaf_condition(dbs)}")
    
    # Iterated gluing
    result = iterated_glue(dbs)
    print(f"\nGlued result domain: {sorted(result.domain())}")
    print(f"Glued data:\n{result.data}")
    
    # Verify extension property
    for i, db in enumerate(dbs):
        extends = all(
            np.isclose(result.data[r, c], db.data[r, c])
            for r, c in db.domain()
        )
        print(f"Result extends DB{i+1}: {extends}")


def demo_coboundary_pseudometric():
    """Demo 2: Coboundary Pseudometric
    
    Shows the pseudometric properties: d(x,x)=0, d(x,y)=d(y,x),
    and the triangle inequality (when middle is global).
    """
    print("\n" + "=" * 60)
    print("DEMO 2: Coboundary Pseudometric")
    print("=" * 60)
    
    # Create databases
    db1 = PartialDatabase(2, 3, np.array([[1, 2, 3], [4, 5, 6]], dtype=float),
                          np.array([[True, True, False], [True, False, True]]))
    
    db2 = PartialDatabase(2, 3, np.array([[1, 2, 3], [4, 5, 6]], dtype=float),
                          np.ones((2, 3), dtype=bool))  # Global section
    
    db3 = PartialDatabase(2, 3, np.array([[1, 9, 3], [4, 5, 8]], dtype=float),
                          np.array([[True, True, True], [True, True, True]]))
    
    d12 = coboundary_distance(db1, db2)
    d21 = coboundary_distance(db2, db1)
    d13 = coboundary_distance(db1, db3)
    d23 = coboundary_distance(db2, db3)
    d11 = coboundary_distance(db1, db1)
    
    print(f"\nd(db1, db1) = {d11}  (should be 0)")
    print(f"d(db1, db2) = {d12}")
    print(f"d(db2, db1) = {d21}  (should equal d(db1,db2))")
    print(f"d(db1, db3) = {d13}")
    print(f"d(db2, db3) = {d23}")
    print(f"\nTriangle inequality (db2 is global):")
    print(f"  d(db1,db3) = {d13} ≤ d(db1,db2) + d(db2,db3) = {d12} + {d23} = {d12+d23}")
    print(f"  Satisfied: {d13 <= d12 + d23}")


def demo_phase_transition():
    """Demo 3: Consistency Probability Phase Transition
    
    Shows the exponential decay of consistency probability with
    constraint count, and the critical threshold.
    """
    print("\n" + "=" * 60)
    print("DEMO 3: Phase Transition in Consistency Probability")
    print("=" * 60)
    
    rates = [0.01, 0.05, 0.1, 0.2, 0.3, 0.5]
    constraints = [1, 10, 50, 100, 500, 1000]
    
    print(f"\nConsistency probability P = (1-r)^c:")
    print(f"{'r':>6} | " + " | ".join(f"c={c:>4}" for c in constraints))
    print("-" * 70)
    for r in rates:
        probs = [consistency_probability(r, c) for c in constraints]
        print(f"{r:>6.2f} | " + " | ".join(f"{p:>6.2e}" if p < 0.01 else f"{p:>6.4f}" for p in probs))
    
    print(f"\nCritical constraint count for ε = 0.01:")
    for r in rates:
        c_star = critical_constraint_count(r, 0.01)
        print(f"  r = {r:.2f}: c* = {c_star}")
    
    # Real-world scenario
    n_features = 10
    n_rows = 100
    n_constraints = n_features * (n_features - 1) // 2 * n_rows
    r = 0.3
    p = consistency_probability(r, n_constraints)
    print(f"\nReal-world scenario: {n_features} features, {n_rows} rows, r={r}")
    print(f"  Constraints: {n_constraints}")
    print(f"  P(consistent) = {p:.2e}")
    print(f"  → Consistency is essentially impossible!")


def demo_feature_presheaf():
    """Demo 4: Feature-Subset Presheaf
    
    Shows that feature projections compose correctly (presheaf axiom).
    """
    print("\n" + "=" * 60)
    print("DEMO 4: Feature-Subset Presheaf")
    print("=" * 60)
    
    record = np.array([10, 20, 30, 40, 50])
    S = [0, 1, 2, 3]  # Features 0-3
    T = [0, 2]         # Features 0, 2 (subset of S)
    U = [0, 1, 2, 3, 4]  # All features
    
    print(f"\nFull record: {record}")
    print(f"Projected to S={S}: {feature_projection(record, S)}")
    print(f"Projected to T={T}: {feature_projection(record, T)}")
    
    # Check presheaf composition
    comp_ok = check_presheaf_composition(record, S, T)
    print(f"\nPresheaf composition (T⊆S): {comp_ok}")
    comp_ok2 = check_presheaf_composition(record, U, S)
    print(f"Presheaf composition (S⊆U): {comp_ok2}")
    comp_ok3 = check_presheaf_composition(record, U, T)
    print(f"Presheaf composition (T⊆U): {comp_ok3}")


def demo_coboundary_bridge():
    """Demo 5: Coboundary Kernel = Sheaf Condition (Bridge Theorem)
    
    Shows that total coboundary norm being zero is equivalent to
    the sheaf condition.
    """
    print("\n" + "=" * 60)
    print("DEMO 5: Bridge Theorem — Coboundary Kernel = Sheaf Sections")
    print("=" * 60)
    
    # Consistent family
    db1 = PartialDatabase(2, 2)
    db1.set(0, 0, 1); db1.set(0, 1, 2)
    
    db2 = PartialDatabase(2, 2)
    db2.set(0, 1, 2); db2.set(1, 0, 3)
    
    db3 = PartialDatabase(2, 2)
    db3.set(1, 0, 3); db3.set(1, 1, 4)
    
    consistent_family = [db1, db2, db3]
    
    norm_c = total_coboundary_norm(consistent_family)
    sheaf_c = sheaf_condition(consistent_family)
    print(f"\nConsistent family:")
    print(f"  Total coboundary norm = {norm_c}")
    print(f"  Sheaf condition = {sheaf_c}")
    print(f"  norm=0 ↔ sheaf: {(norm_c == 0) == sheaf_c} ✓")
    
    # Inconsistent family
    db4 = PartialDatabase(2, 2)
    db4.set(0, 0, 1); db4.set(0, 1, 2)
    
    db5 = PartialDatabase(2, 2)
    db5.set(0, 1, 99)  # Disagrees with db4 at (0,1)!
    
    inconsistent_family = [db4, db5]
    
    norm_i = total_coboundary_norm(inconsistent_family)
    sheaf_i = sheaf_condition(inconsistent_family)
    print(f"\nInconsistent family:")
    print(f"  Total coboundary norm = {norm_i}")
    print(f"  Sheaf condition = {sheaf_i}")
    print(f"  norm=0 ↔ sheaf: {(norm_i == 0) == sheaf_i} ✓")


if __name__ == "__main__":
    demo_iterated_gluing()
    demo_coboundary_pseudometric()
    demo_phase_transition()
    demo_feature_presheaf()
    demo_coboundary_bridge()
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


"""
Visualization: Consistency Probability Phase Transition

Shows the exponential decay of P(consistent) = (1-r)^c as a function
of constraint count c for various missing rates r.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def consistency_probability(r, c):
    return (1 - r) ** c

def plot_phase_transition():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Panel 1: P vs c for different r
    ax1 = axes[0]
    constraints = np.arange(0, 101)
    rates = [0.01, 0.05, 0.1, 0.2, 0.3, 0.5]
    colors = plt.cm.viridis(np.linspace(0, 0.9, len(rates)))
    
    for r, color in zip(rates, colors):
        probs = [consistency_probability(r, c) for c in constraints]
        ax1.plot(constraints, probs, color=color, linewidth=2, label=f'r = {r}')
    
    ax1.set_xlabel('Constraint Count (c)', fontsize=12)
    ax1.set_ylabel('Consistency Probability P(c)', fontsize=12)
    ax1.set_title('Exponential Decay of Consistency', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.set_ylim(-0.05, 1.05)
    ax1.axhline(y=0.01, color='red', linestyle='--', alpha=0.5, label='ε = 0.01')
    ax1.grid(True, alpha=0.3)
    
    # Panel 2: Critical constraint count vs r
    ax2 = axes[1]
    r_values = np.linspace(0.005, 0.99, 200)
    epsilon = 0.01
    c_star = [np.log(epsilon) / np.log(1 - r) for r in r_values]
    
    ax2.plot(r_values, c_star, 'b-', linewidth=2)
    ax2.fill_between(r_values, c_star, alpha=0.1, color='blue')
    ax2.set_xlabel('Missing Rate (r)', fontsize=12)
    ax2.set_ylabel('Critical Constraint Count c*', fontsize=12)
    ax2.set_title(f'Phase Transition Threshold (ε = {epsilon})', fontsize=14)
    ax2.set_ylim(0, 500)
    ax2.grid(True, alpha=0.3)
    ax2.annotate('P(c) < ε\n(inconsistent)', xy=(0.5, 100),
                fontsize=12, ha='center', color='blue', alpha=0.7)
    ax2.annotate('P(c) ≥ ε\n(possibly consistent)', xy=(0.1, 400),
                fontsize=12, ha='center', color='green', alpha=0.7)
    
    plt.tight_layout()
    plt.savefig('phase_transition.png', dpi=150, bbox_inches='tight')
    print("Saved phase_transition.png")

if __name__ == "__main__":
    plot_phase_transition()
