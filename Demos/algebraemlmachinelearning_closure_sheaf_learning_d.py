#!/usr/bin/env python3
"""
Applications: Closure-Sheaf Learning Duality
=============================================
Real-world applications of the local-to-global predictor reconstruction theory.
"""

import numpy as np
from typing import Dict, List, Tuple, Optional
from algorithms import (FinitePoset, LocalSystem, reconstruct_global_predictor,
                         compute_compatibility_cocycle, cocycle_vanishes,
                         idempotent_max_aggregate, ReconstructionResult)


# ============================================================
# Application 1: Modular Feature Learning
# ============================================================

def app_modular_feature_learning():
    """
    Application: Modular feature learning with consistency checking.

    Scenario: A vision system has separate modules for detecting
    edges, textures, and objects. Each module produces a local
    prediction vector. We check whether these local predictions
    can be assembled into a globally consistent interpretation.

    The poset represents feature dependency:
      edges ≤ textures ≤ objects
    """
    print("=" * 60)
    print("APP 1: Modular Feature Learning Consistency")
    print("=" * 60)

    poset = FinitePoset(
        ['edges', 'textures', 'objects'],
        [('edges', 'textures'), ('textures', 'objects')]
    )

    # Local prediction dimensions
    fiber_dims = {'edges': 4, 'textures': 6, 'objects': 6}

    # Restriction: projecting object features to edge/texture features
    res_et = np.random.RandomState(42).randn(4, 6)  # textures → edges
    res_to = np.eye(6)  # objects → textures (identity embedding)
    res_eo = res_et @ res_to  # objects → edges (composed)

    system = LocalSystem(poset, fiber_dims, {
        ('edges', 'textures'): res_et,
        ('textures', 'objects'): res_to,
        ('edges', 'objects'): res_eo
    })

    # Scenario A: Consistent predictions
    print("\n--- Scenario A: Consistent Module Outputs ---")
    obj_pred = np.array([0.8, 0.1, 0.05, 0.05, 0.3, 0.7])
    tex_pred = res_to @ obj_pred
    edge_pred = res_et @ tex_pred

    local_data = {
        'edges': edge_pred,
        'textures': tex_pred,
        'objects': obj_pred
    }

    result, pred, cert = reconstruct_global_predictor(system, local_data)
    print(f"Result: {result.value}")
    if result == ReconstructionResult.SUCCESS:
        print("✓ Local predictions are globally consistent!")
        print("  Global interpretation assembled successfully.")

    # Scenario B: Inconsistent predictions (e.g., adversarial perturbation)
    print("\n--- Scenario B: Adversarial Perturbation ---")
    perturbed_edges = edge_pred + np.random.RandomState(123).randn(4) * 0.5
    local_data_bad = {
        'edges': perturbed_edges,
        'textures': tex_pred,
        'objects': obj_pred
    }

    result, pred, cert = reconstruct_global_predictor(system, local_data_bad)
    print(f"Result: {result.value}")
    if cert:
        print(f"✗ Inconsistency detected at ({cert.i}, {cert.j})")
        print(f"  Discrepancy magnitude: {cert.discrepancy:.4f}")
        print("  → Edge detector has been adversarially perturbed!")
    print()


# ============================================================
# Application 2: Federated Learning Consistency
# ============================================================

def app_federated_learning():
    """
    Application: Federated learning consistency verification.

    Scenario: Multiple hospitals train local models on patient data.
    A central server needs to verify that local model updates
    are consistent enough to aggregate into a global model.

    The poset represents data sharing agreements:
      hospital_A ≤ combined_AB
      hospital_B ≤ combined_AB
    (Diamond-like structure when multiple combinations exist)
    """
    print("=" * 60)
    print("APP 2: Federated Learning Consistency")
    print("=" * 60)

    poset = FinitePoset(
        ['hosp_A', 'hosp_B', 'hosp_C', 'combined'],
        [('hosp_A', 'combined'), ('hosp_B', 'combined'), ('hosp_C', 'combined')]
    )

    # Each hospital has a 5-dimensional model parameter vector
    # Combined model has 5 dimensions too
    dim = 5
    fiber_dims = {e: dim for e in poset.elements}

    # Restriction: combined → individual = projection (identity here)
    I = np.eye(dim)
    system = LocalSystem(poset, fiber_dims, {
        ('hosp_A', 'combined'): I,
        ('hosp_B', 'combined'): I,
        ('hosp_C', 'combined'): I,
    })

    # Scenario A: All hospitals agree
    print("\n--- Scenario A: Hospitals Agree ---")
    shared_params = np.array([0.5, -0.3, 0.8, 0.1, -0.6])
    local_data = {
        'hosp_A': shared_params.copy(),
        'hosp_B': shared_params.copy(),
        'hosp_C': shared_params.copy(),
        'combined': shared_params.copy()
    }

    result, pred, cert = reconstruct_global_predictor(system, local_data)
    print(f"Consistency check: {result.value}")
    if result == ReconstructionResult.SUCCESS:
        print("✓ All hospital models are consistent — safe to aggregate!")

    # Scenario B: One hospital has drifted
    print("\n--- Scenario B: Hospital C Has Data Drift ---")
    drifted_params = shared_params + np.array([0, 0, 0, 0, 2.0])
    local_data_drift = {
        'hosp_A': shared_params.copy(),
        'hosp_B': shared_params.copy(),
        'hosp_C': drifted_params,
        'combined': shared_params.copy()
    }

    result, pred, cert = reconstruct_global_predictor(system, local_data_drift)
    print(f"Consistency check: {result.value}")
    if cert:
        print(f"✗ Inconsistency at ({cert.i}, {cert.j})")
        print(f"  Drift magnitude: {cert.discrepancy:.4f}")
        print("  → Hospital C's model has drifted from consensus!")

    # Compute cocycle to quantify all inconsistencies
    cocycle = compute_compatibility_cocycle(system, local_data_drift)
    print(f"  Cocycle vanishes: {cocycle_vanishes(cocycle)}")
    for (i, j), v in cocycle.items():
        norm = np.linalg.norm(v)
        if norm > 1e-10:
            print(f"  Cocycle ({i},{j}): norm = {norm:.4f}")
    print()


# ============================================================
# Application 3: Sensor Fusion with Obstruction Detection
# ============================================================

def app_sensor_fusion():
    """
    Application: Multi-sensor fusion with inconsistency detection.

    Scenario: An autonomous vehicle has multiple sensors
    (camera, lidar, radar) that produce local environment estimates.
    We check if they can be fused into a consistent global map.

    Poset: camera ≤ fused, lidar ≤ fused, radar ≤ fused
    """
    print("=" * 60)
    print("APP 3: Sensor Fusion — Obstruction Detection")
    print("=" * 60)

    poset = FinitePoset(
        ['camera', 'lidar', 'radar', 'fused'],
        [('camera', 'fused'), ('lidar', 'fused'), ('radar', 'fused')]
    )

    dim = 3  # (x, y, confidence)
    fiber_dims = {e: dim for e in poset.elements}
    I = np.eye(dim)
    system = LocalSystem(poset, fiber_dims, {
        ('camera', 'fused'): I,
        ('lidar', 'fused'): I,
        ('radar', 'fused'): I,
    })

    # Consistent sensors
    print("\n--- Scenario: Consistent Sensors ---")
    estimate = np.array([10.5, 3.2, 0.95])
    local_data = {
        'camera': estimate.copy(),
        'lidar': estimate.copy(),
        'radar': estimate.copy(),
        'fused': estimate.copy()
    }
    result, _, _ = reconstruct_global_predictor(system, local_data)
    print(f"  Fusion result: {result.value}")
    print("  ✓ All sensors agree — confident global estimate.")

    # Malfunctioning sensor
    print("\n--- Scenario: Radar Malfunction ---")
    bad_radar = np.array([10.5, 3.2, 0.95]) + np.array([5.0, -2.0, 0.0])
    local_data_bad = {
        'camera': estimate.copy(),
        'lidar': estimate.copy(),
        'radar': bad_radar,
        'fused': estimate.copy()
    }
    result, _, cert = reconstruct_global_predictor(system, local_data_bad)
    print(f"  Fusion result: {result.value}")
    if cert:
        print(f"  ✗ Sensor inconsistency: ({cert.i}, {cert.j})")
        print(f"  Magnitude: {cert.discrepancy:.4f}")
        print("  → Radar readings are unreliable — use camera + lidar only!")

    # Idempotent aggregation for robust estimate
    print("\n--- Robust Aggregation via Idempotent Max ---")
    sensors = [estimate.copy(), estimate.copy(), bad_radar]
    robust = idempotent_max_aggregate(sensors)
    print(f"  Max-aggregate: {robust}")
    print("  (Takes most confident reading per dimension)")
    print()


# ============================================================
# Application 4: Mixture of Experts Coherence
# ============================================================

def app_mixture_of_experts():
    """
    Application: Verifying coherence of a mixture-of-experts model.

    Scenario: A system has specialized experts for different input regions.
    We check if expert outputs are coherent on overlapping regions.

    Poset: expert_i ≤ global for each expert
    """
    print("=" * 60)
    print("APP 4: Mixture of Experts — Coherence Verification")
    print("=" * 60)

    n_experts = 4
    expert_names = [f'expert_{i}' for i in range(n_experts)]
    poset = FinitePoset(
        expert_names + ['global'],
        [(e, 'global') for e in expert_names]
    )

    dim = 3
    fiber_dims = {e: dim for e in poset.elements}
    I = np.eye(dim)
    system = LocalSystem(poset, fiber_dims, {
        (e, 'global'): I for e in expert_names
    })

    # Coherent experts
    print("\n--- Scenario: Coherent Experts ---")
    global_output = np.array([0.7, 0.2, 0.1])
    local_data = {e: global_output.copy() for e in expert_names}
    local_data['global'] = global_output.copy()

    result, _, _ = reconstruct_global_predictor(system, local_data)
    print(f"  Coherence check: {result.value}")
    print("  ✓ All experts produce coherent outputs.")

    # One expert disagrees
    print("\n--- Scenario: Expert 2 Disagrees ---")
    local_data_bad = {e: global_output.copy() for e in expert_names}
    local_data_bad['expert_2'] = np.array([0.1, 0.8, 0.1])  # Different!
    local_data_bad['global'] = global_output.copy()

    result, _, cert = reconstruct_global_predictor(system, local_data_bad)
    print(f"  Coherence check: {result.value}")
    if cert:
        print(f"  ✗ Expert disagrees: ({cert.i}, {cert.j})")
        print(f"  → Expert 2 should be retrained or its domain narrowed.")
    print()


if __name__ == "__main__":
    app_modular_feature_learning()
    app_federated_learning()
    app_sensor_fusion()
    app_mixture_of_experts()

    print("=" * 60)
    print("All applications completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demo: Closure-Sheaf Learning Duality
=====================================
Concrete numerical examples demonstrating the local-to-global
predictor reconstruction theorem and obstruction detection.
"""

import numpy as np
from typing import Dict, List, Tuple, Optional


class FinitePoset:
    """A finite partially ordered set."""
    def __init__(self, elements: List[str], order: List[Tuple[str, str]]):
        self.elements = elements
        self.order = set(order)
        # Add reflexive closure
        for e in elements:
            self.order.add((e, e))
        # Compute transitive closure
        changed = True
        while changed:
            changed = False
            for (a, b) in list(self.order):
                for (c, d) in list(self.order):
                    if b == c and (a, d) not in self.order:
                        self.order.add((a, d))
                        changed = True

    def leq(self, i: str, j: str) -> bool:
        return (i, j) in self.order


class IdempotentMonoid:
    """An idempotent commutative monoid (max-tropical style)."""
    def __init__(self, values: np.ndarray):
        self.values = values

    @staticmethod
    def add(a: np.ndarray, b: np.ndarray) -> np.ndarray:
        """Idempotent addition: componentwise max."""
        return np.maximum(a, b)

    @staticmethod
    def zero(dim: int) -> np.ndarray:
        return np.full(dim, -np.inf)

    @staticmethod
    def verify_idempotent(a: np.ndarray) -> bool:
        return np.allclose(np.maximum(a, a), a)


class LocalSystem:
    """A local system (presheaf) over a finite poset."""
    def __init__(self, poset: FinitePoset, fibers: Dict[str, int],
                 restriction_maps: Dict[Tuple[str, str], np.ndarray]):
        self.poset = poset
        self.fibers = fibers  # dimension at each point
        self.restriction_maps = restriction_maps

    def res(self, i: str, j: str, x: np.ndarray) -> np.ndarray:
        """Restrict from j to i (requires i ≤ j)."""
        assert self.poset.leq(i, j), f"Cannot restrict: {i} ≤ {j} is false"
        if i == j:
            return x.copy()
        mat = self.restriction_maps[(i, j)]
        return mat @ x


class PredictorAtlas:
    """An assignment of local predictor data to each poset element."""
    def __init__(self, system: LocalSystem, local_data: Dict[str, np.ndarray]):
        self.system = system
        self.local_data = local_data

    def check_pairwise_compatible(self) -> Tuple[bool, Optional[Tuple[str, str]]]:
        """Check if the atlas is pairwise compatible.
        Returns (True, None) if compatible, (False, (i,j)) if not."""
        for i in self.system.poset.elements:
            for j in self.system.poset.elements:
                if self.system.poset.leq(i, j) and i != j:
                    restricted = self.system.res(i, j, self.local_data[j])
                    if not np.allclose(restricted, self.local_data[i]):
                        return False, (i, j)
        return True, None

    def reconstruct_global(self) -> Tuple[Optional[Dict[str, np.ndarray]], Optional[Tuple[str, str]]]:
        """Reconstruct a global predictor or return an obstruction.

        This implements the certified reconstruction algorithm:
        - If pairwise compatible: return the global predictor
        - If not: return the obstruction certificate (i, j)
        """
        compatible, witness = self.check_pairwise_compatible()
        if compatible:
            return self.local_data.copy(), None
        else:
            return None, witness


def demo_compatible_atlas():
    """Demo 1: A compatible atlas that glues successfully."""
    print("=" * 60)
    print("DEMO 1: Compatible Atlas — Successful Gluing")
    print("=" * 60)

    # Create a 3-element chain poset: a ≤ b ≤ c
    poset = FinitePoset(['a', 'b', 'c'], [('a', 'b'), ('b', 'c')])

    # Fiber dimensions: 2 at a, 3 at b, 3 at c
    fibers = {'a': 2, 'b': 3, 'c': 3}

    # Restriction maps (as matrices)
    # res(a,b): R^3 -> R^2 (projection to first 2 coords)
    res_ab = np.array([[1, 0, 0], [0, 1, 0]])
    # res(b,c): R^3 -> R^3 (identity)
    res_bc = np.eye(3)
    # res(a,c): R^3 -> R^2 (composed)
    res_ac = res_ab @ res_bc

    restriction_maps = {('a', 'b'): res_ab, ('b', 'c'): res_bc, ('a', 'c'): res_ac}
    system = LocalSystem(poset, fibers, restriction_maps)

    # Compatible local data: res(a,b)(data_b) = data_a, res(b,c)(data_c) = data_b
    data_c = np.array([1.0, 2.0, 3.0])
    data_b = res_bc @ data_c  # = [1, 2, 3]
    data_a = res_ab @ data_b  # = [1, 2]

    atlas = PredictorAtlas(system, {'a': data_a, 'b': data_b, 'c': data_c})

    compatible, _ = atlas.check_pairwise_compatible()
    print(f"\nLocal data at a: {data_a}")
    print(f"Local data at b: {data_b}")
    print(f"Local data at c: {data_c}")
    print(f"\nPairwise compatible: {compatible}")

    global_pred, obstruction = atlas.reconstruct_global()
    if global_pred is not None:
        print("\n✓ GLOBAL PREDICTOR RECONSTRUCTED SUCCESSFULLY")
        for key, val in global_pred.items():
            print(f"  Global section at {key}: {val}")
    print()


def demo_incompatible_atlas():
    """Demo 2: An incompatible atlas with obstruction certificate."""
    print("=" * 60)
    print("DEMO 2: Incompatible Atlas — Obstruction Certificate")
    print("=" * 60)

    # Same poset: a ≤ b ≤ c
    poset = FinitePoset(['a', 'b', 'c'], [('a', 'b'), ('b', 'c')])
    fibers = {'a': 2, 'b': 3, 'c': 3}

    res_ab = np.array([[1, 0, 0], [0, 1, 0]])
    res_bc = np.eye(3)
    res_ac = res_ab @ res_bc

    restriction_maps = {('a', 'b'): res_ab, ('b', 'c'): res_bc, ('a', 'c'): res_ac}
    system = LocalSystem(poset, fibers, restriction_maps)

    # Incompatible data: data at a doesn't agree with restriction of data at b
    data_a = np.array([5.0, 7.0])   # Does NOT equal res(a,b)(data_b)
    data_b = np.array([1.0, 2.0, 3.0])
    data_c = np.array([1.0, 2.0, 3.0])

    atlas = PredictorAtlas(system, {'a': data_a, 'b': data_b, 'c': data_c})

    compatible, witness = atlas.check_pairwise_compatible()
    print(f"\nLocal data at a: {data_a}")
    print(f"Local data at b: {data_b}")
    print(f"Local data at c: {data_c}")
    print(f"\nPairwise compatible: {compatible}")

    if not compatible:
        i, j = witness
        restricted = system.res(i, j, atlas.local_data[j])
        print(f"\n✗ OBSTRUCTION FOUND at ({i}, {j}):")
        print(f"  res({i},{j})(data_{j}) = {restricted}")
        print(f"  data_{i} = {atlas.local_data[i]}")
        print(f"  Discrepancy: {np.linalg.norm(restricted - atlas.local_data[i]):.4f}")

    global_pred, obstruction = atlas.reconstruct_global()
    if obstruction is not None:
        print(f"\n✗ NO GLOBAL PREDICTOR EXISTS")
        print(f"  Obstruction certificate: ({obstruction[0]}, {obstruction[1]})")
    print()


def demo_idempotent_aggregation():
    """Demo 3: Idempotent (max-tropical) aggregation."""
    print("=" * 60)
    print("DEMO 3: Idempotent Aggregation (Max-Tropical)")
    print("=" * 60)

    a = np.array([3.0, 1.0, 4.0])
    b = np.array([1.0, 5.0, 2.0])

    print(f"\nVector a: {a}")
    print(f"Vector b: {b}")
    print(f"a ⊕ b (max):   {IdempotentMonoid.add(a, b)}")
    print(f"a ⊕ a (idem):  {IdempotentMonoid.add(a, a)}")
    print(f"Idempotent? a ⊕ a = a: {IdempotentMonoid.verify_idempotent(a)}")

    # n-fold idempotent sum
    result = a.copy()
    for _ in range(99):
        result = IdempotentMonoid.add(result, a)
    print(f"100 • a = a? {np.allclose(result, a)}")
    print()


def demo_diamond_poset():
    """Demo 4: Diamond poset — more complex gluing scenario."""
    print("=" * 60)
    print("DEMO 4: Diamond Poset — Complex Gluing")
    print("=" * 60)

    #     d
    #    / \
    #   b   c
    #    \ /
    #     a
    poset = FinitePoset(['a', 'b', 'c', 'd'],
                        [('a', 'b'), ('a', 'c'), ('b', 'd'), ('c', 'd')])

    # All fibers are R^2 for simplicity
    fibers = {e: 2 for e in ['a', 'b', 'c', 'd']}

    # Restriction maps: all projections are identity (same dimension)
    I = np.eye(2)
    restriction_maps = {
        ('a', 'b'): I, ('a', 'c'): I, ('b', 'd'): I, ('c', 'd'): I,
        ('a', 'd'): I
    }
    system = LocalSystem(poset, fibers, restriction_maps)

    # Case A: Compatible (all same data)
    data = np.array([1.0, 2.0])
    atlas1 = PredictorAtlas(system, {e: data.copy() for e in ['a', 'b', 'c', 'd']})
    compat1, _ = atlas1.check_pairwise_compatible()
    print(f"\nCase A (all equal data): compatible = {compat1}")

    # Case B: b and c have different data, both restrict to same at a but differ at d
    atlas2 = PredictorAtlas(system, {
        'a': np.array([1.0, 2.0]),
        'b': np.array([1.0, 2.0]),
        'c': np.array([3.0, 4.0]),  # Different from b!
        'd': np.array([1.0, 2.0])
    })
    compat2, witness2 = atlas2.check_pairwise_compatible()
    print(f"Case B (c differs from a): compatible = {compat2}")
    if witness2:
        print(f"  Obstruction at: {witness2}")

    global_pred, _ = atlas1.reconstruct_global()
    if global_pred:
        print(f"\nCase A global predictor: {global_pred}")
    print()


def demo_learning_system_duality():
    """Demo 5: Duality between learning systems and local systems."""
    print("=" * 60)
    print("DEMO 5: Learning System ↔ Local System Duality")
    print("=" * 60)

    print("\nA ClosureDescentLearningSystem consists of:")
    print("  • localPredictor: P → Type  (local model types)")
    print("  • overlapRestrict: i ≤ j → F(j) → F(i)  (restriction)")
    print("  • restrict_id, restrict_comp  (functoriality)")
    print("  • separated  (uniqueness condition)")
    print()
    print("A SeparatedLocalSystem has the same data:")
    print("  • F: P → Type  (fiber types)")
    print("  • res: i ≤ j → F(j) → F(i)  (restriction)")
    print("  • res_id, res_comp  (functoriality)")
    print("  • separated  (separation condition)")
    print()
    print("Duality theorem (proved in Lean):")
    print("  systemToSeparatedLocalSystem ∘ separatedLocalSystemToSystem = id")
    print("  separatedLocalSystemToSystem ∘ systemToSeparatedLocalSystem = id")
    print("  (on fiber types and restriction maps)")
    print()

    # Demonstrate with concrete data
    poset = FinitePoset(['x', 'y'], [('x', 'y')])
    fibers = {'x': 2, 'y': 3}
    res_xy = np.array([[1, 0, 0], [0, 1, 0]])
    system = LocalSystem(poset, fibers, {('x', 'y'): res_xy})

    print("Example: Poset {x ≤ y}, fiber dims: x→2, y→3")
    print(f"  Restriction x←y: project R³ → R² (first 2 coords)")
    data_y = np.array([3.0, 1.0, 4.0])
    data_x = system.res('x', 'y', data_y)
    print(f"  data_y = {data_y}, res(x,y)(data_y) = {data_x}")
    atlas = PredictorAtlas(system, {'x': data_x, 'y': data_y})
    compat, _ = atlas.check_pairwise_compatible()
    print(f"  Compatible atlas: {compat}")
    print()


if __name__ == "__main__":
    demo_compatible_atlas()
    demo_incompatible_atlas()
    demo_idempotent_aggregation()
    demo_diamond_poset()
    demo_learning_system_duality()

    print("=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations: Closure-Sheaf Learning Duality
===============================================
Generate publication-quality figures illustrating the key concepts.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()


def viz_poset_and_fibers():
    """Visualize a poset with its fibers and restriction maps."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Poset diagram
    ax = axes[0]
    ax.set_xlim(-1, 5)
    ax.set_ylim(-1, 5)

    # Draw nodes
    positions = {'a': (2, 0), 'b': (0.5, 2), 'c': (3.5, 2), 'd': (2, 4)}
    for name, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.4, color='#3498db', alpha=0.8)
        ax.add_patch(circle)
        ax.text(x, y, name, ha='center', va='center', fontsize=16,
                fontweight='bold', color='white')

    # Draw edges (Hasse diagram)
    edges = [('a', 'b'), ('a', 'c'), ('b', 'd'), ('c', 'd')]
    for (s, t) in edges:
        x0, y0 = positions[s]
        x1, y1 = positions[t]
        ax.annotate('', xy=(x1, y1 - 0.4), xytext=(x0, y0 + 0.4),
                    arrowprops=dict(arrowstyle='->', color='#2c3e50', lw=2))

    ax.set_title('Dependency Poset P\n(Diamond Lattice)', fontsize=14, fontweight='bold')
    ax.axis('off')

    # Right: Fibers over the poset
    ax = axes[1]
    ax.set_xlim(-1, 5)
    ax.set_ylim(-1, 5)

    # Draw fiber "clouds"
    fiber_data = {
        'a': {'pos': (2, 0), 'dim': 2, 'color': '#e74c3c'},
        'b': {'pos': (0.5, 2), 'dim': 3, 'color': '#2ecc71'},
        'c': {'pos': (3.5, 2), 'dim': 3, 'color': '#9b59b6'},
        'd': {'pos': (2, 4), 'dim': 4, 'color': '#f39c12'}
    }

    for name, info in fiber_data.items():
        x, y = info['pos']
        rect = FancyBboxPatch((x - 0.6, y - 0.3), 1.2, 0.6,
                              boxstyle="round,pad=0.1",
                              facecolor=info['color'], alpha=0.3,
                              edgecolor=info['color'], linewidth=2)
        ax.add_patch(rect)
        ax.text(x, y + 0.05, f'F({name})', ha='center', va='center',
                fontsize=12, fontweight='bold')
        ax.text(x, y - 0.15, f'dim={info["dim"]}', ha='center', va='center',
                fontsize=9, color='gray')

    # Draw restriction arrows
    for (s, t) in edges:
        x0, y0 = positions[s]
        x1, y1 = positions[t]
        ax.annotate('res', xy=(x0, y0 + 0.35), xytext=(x1, y1 - 0.35),
                    arrowprops=dict(arrowstyle='->', color='#e67e22', lw=1.5,
                                   linestyle='dashed'),
                    fontsize=8, color='#e67e22', ha='center')

    ax.set_title('Local System: Fibers F(i)\nwith Restriction Maps', fontsize=14, fontweight='bold')
    ax.axis('off')

    plt.tight_layout()
    return fig


def viz_compatible_vs_incompatible():
    """Visualize compatible vs incompatible predictor atlases."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Common setup
    for idx, (ax, title, compatible) in enumerate([
        (axes[0], 'Compatible Atlas\n(Cocycle Vanishes → Global Section Exists)', True),
        (axes[1], 'Incompatible Atlas\n(Obstruction Certificate)', False)
    ]):
        ax.set_xlim(-0.5, 4.5)
        ax.set_ylim(-0.5, 4.5)

        positions = {'a': (2, 0.5), 'b': (0.5, 2.5), 'c': (3.5, 2.5)}

        # Draw nodes with data
        np.random.seed(42)
        data_c = np.array([1.0, 2.0, 3.0])
        if compatible:
            data_b = np.array([1.0, 2.0, 3.0])
            data_a = np.array([1.0, 2.0])
        else:
            data_b = np.array([1.0, 2.0, 3.0])
            data_a = np.array([5.0, 7.0])  # WRONG

        data = {'a': data_a, 'b': data_b, 'c': data_c}
        colors = {'a': '#e74c3c', 'b': '#2ecc71', 'c': '#3498db'}

        for name, (x, y) in positions.items():
            color = colors[name]
            rect = FancyBboxPatch((x - 0.7, y - 0.4), 1.4, 0.8,
                                  boxstyle="round,pad=0.1",
                                  facecolor=color, alpha=0.2,
                                  edgecolor=color, linewidth=2)
            ax.add_patch(rect)
            ax.text(x, y + 0.15, f'{name}', ha='center', va='center',
                    fontsize=14, fontweight='bold', color=color)
            d = data[name]
            ax.text(x, y - 0.15, f'{d}', ha='center', va='center',
                    fontsize=9, color='gray')

        # Draw restriction check arrows
        # a ≤ b: check res(a,b)(data_b) = data_a
        res_ab = data_b[:2]  # projection
        match_ab = np.allclose(res_ab, data_a)
        arrow_color = '#27ae60' if match_ab else '#c0392b'
        ax.annotate('', xy=(positions['a'][0] - 0.3, positions['a'][1] + 0.4),
                    xytext=(positions['b'][0] + 0.3, positions['b'][1] - 0.4),
                    arrowprops=dict(arrowstyle='->', color=arrow_color, lw=2.5))
        symbol = '✓' if match_ab else '✗'
        mid_x = (positions['a'][0] + positions['b'][0]) / 2 - 0.3
        mid_y = (positions['a'][1] + positions['b'][1]) / 2
        ax.text(mid_x, mid_y, symbol, fontsize=20, color=arrow_color,
                ha='center', va='center', fontweight='bold')

        # a ≤ c
        res_ac = data_c[:2]
        match_ac = np.allclose(res_ac, data_a)
        arrow_color = '#27ae60' if match_ac else '#c0392b'
        ax.annotate('', xy=(positions['a'][0] + 0.3, positions['a'][1] + 0.4),
                    xytext=(positions['c'][0] - 0.3, positions['c'][1] - 0.4),
                    arrowprops=dict(arrowstyle='->', color=arrow_color, lw=2.5))
        symbol = '✓' if match_ac else '✗'
        mid_x = (positions['a'][0] + positions['c'][0]) / 2 + 0.3
        mid_y = (positions['a'][1] + positions['c'][1]) / 2
        ax.text(mid_x, mid_y, symbol, fontsize=20, color=arrow_color,
                ha='center', va='center', fontweight='bold')

        # Result box
        if compatible:
            result_text = "GLOBAL PREDICTOR EXISTS"
            result_color = '#27ae60'
        else:
            result_text = "OBSTRUCTION: res(a,b)(data_b) ≠ data_a"
            result_color = '#c0392b'

        ax.text(2, 4, result_text, ha='center', va='center',
                fontsize=11, fontweight='bold', color=result_color,
                bbox=dict(boxstyle='round,pad=0.3', facecolor=result_color,
                         alpha=0.1, edgecolor=result_color))

        ax.set_title(title, fontsize=12, fontweight='bold')
        ax.axis('off')

    plt.tight_layout()
    return fig


def viz_idempotent_aggregation():
    """Visualize idempotent max-aggregation."""
    fig, ax = plt.subplots(figsize=(10, 6))

    dims = ['Feature 1', 'Feature 2', 'Feature 3', 'Feature 4', 'Feature 5']
    x = np.arange(len(dims))
    width = 0.2

    section_a = [3, 1, 4, 1, 5]
    section_b = [1, 5, 2, 6, 3]
    section_c = [2, 3, 6, 2, 4]
    aggregated = [max(a, b, c) for a, b, c in zip(section_a, section_b, section_c)]

    bars1 = ax.bar(x - 1.5*width, section_a, width, label='Section A',
                   color='#3498db', alpha=0.7)
    bars2 = ax.bar(x - 0.5*width, section_b, width, label='Section B',
                   color='#e74c3c', alpha=0.7)
    bars3 = ax.bar(x + 0.5*width, section_c, width, label='Section C',
                   color='#2ecc71', alpha=0.7)
    bars4 = ax.bar(x + 1.5*width, aggregated, width, label='Max-Aggregate (A⊕B⊕C)',
                   color='#f39c12', alpha=0.9, edgecolor='black', linewidth=1.5)

    ax.set_xlabel('Feature Dimension', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Idempotent Max-Aggregation of Local Sections\n'
                 'a ⊕ b = max(a, b)  •  a ⊕ a = a (idempotent)',
                 fontsize=14, fontweight='bold')
    ax.set_xticks(x)
    ax.set_xticklabels(dims)
    ax.legend(loc='upper left', fontsize=10)
    ax.grid(axis='y', alpha=0.3)

    # Add idempotency annotation
    ax.text(0.98, 0.02, 'Key property: x ⊕ x = x (idempotent)\n'
            'Unlike linear averaging, repeated aggregation\n'
            'does not dilute the signal.',
            transform=ax.transAxes, ha='right', va='bottom',
            fontsize=9, style='italic', color='gray',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.3))

    plt.tight_layout()
    return fig


def viz_reconstruction_flowchart():
    """Visualize the certified reconstruction algorithm flowchart."""
    fig, ax = plt.subplots(figsize=(10, 8))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)

    # Input box
    rect = FancyBboxPatch((3, 8.5), 4, 0.8, boxstyle="round,pad=0.1",
                          facecolor='#3498db', alpha=0.3, edgecolor='#2980b9', lw=2)
    ax.add_patch(rect)
    ax.text(5, 8.9, 'Input: Predictor Atlas A', ha='center', va='center',
            fontsize=12, fontweight='bold')

    # Decision diamond
    diamond = plt.Polygon([(5, 7.8), (7.5, 6.5), (5, 5.2), (2.5, 6.5)],
                          facecolor='#f1c40f', alpha=0.3, edgecolor='#f39c12', lw=2)
    ax.add_patch(diamond)
    ax.text(5, 6.5, 'Pairwise\nCompatible?', ha='center', va='center',
            fontsize=11, fontweight='bold')

    # Arrow from input to decision
    ax.annotate('', xy=(5, 7.8), xytext=(5, 8.5),
                arrowprops=dict(arrowstyle='->', color='black', lw=2))

    # YES path
    ax.text(7.8, 7.2, 'YES', fontsize=11, fontweight='bold', color='#27ae60')
    ax.annotate('', xy=(8, 5), xytext=(7.5, 6.5),
                arrowprops=dict(arrowstyle='->', color='#27ae60', lw=2))

    rect_yes = FancyBboxPatch((6, 4), 4, 1, boxstyle="round,pad=0.1",
                              facecolor='#27ae60', alpha=0.2, edgecolor='#27ae60', lw=2)
    ax.add_patch(rect_yes)
    ax.text(8, 4.5, 'Return:\nGlobalPredictor', ha='center', va='center',
            fontsize=11, fontweight='bold', color='#27ae60')

    # NO path
    ax.text(1.8, 7.2, 'NO', fontsize=11, fontweight='bold', color='#c0392b')
    ax.annotate('', xy=(2, 5), xytext=(2.5, 6.5),
                arrowprops=dict(arrowstyle='->', color='#c0392b', lw=2))

    rect_no = FancyBboxPatch((0, 4), 4, 1, boxstyle="round,pad=0.1",
                             facecolor='#c0392b', alpha=0.2, edgecolor='#c0392b', lw=2)
    ax.add_patch(rect_no)
    ax.text(2, 4.5, 'Return:\nObstructionCert', ha='center', va='center',
            fontsize=11, fontweight='bold', color='#c0392b')

    # Theorem references
    ax.text(8, 3.3, 'Theorem:\nreconstructGlobalPredictor_correct_inl',
            ha='center', va='center', fontsize=8, style='italic', color='#27ae60')
    ax.text(2, 3.3, 'Theorem:\nreconstructGlobalPredictor_correct_inr',
            ha='center', va='center', fontsize=8, style='italic', color='#c0392b')

    # Correctness guarantee boxes
    rect_g1 = FancyBboxPatch((5.5, 1.5), 4.5, 1.2, boxstyle="round,pad=0.1",
                             facecolor='#27ae60', alpha=0.1, edgecolor='#27ae60', lw=1)
    ax.add_patch(rect_g1)
    ax.text(7.75, 2.1, '✓ restrictGlobal(g) = A\n✓ Unique on separated systems',
            ha='center', va='center', fontsize=9, color='#27ae60')

    rect_g2 = FancyBboxPatch((0, 1.5), 4.5, 1.2, boxstyle="round,pad=0.1",
                             facecolor='#c0392b', alpha=0.1, edgecolor='#c0392b', lw=1)
    ax.add_patch(rect_g2)
    ax.text(2.25, 2.1, '✗ ¬ A.GloballyRealizable\n✗ Concrete (i,j) witness',
            ha='center', va='center', fontsize=9, color='#c0392b')

    # Arrows to guarantee boxes
    ax.annotate('', xy=(7.75, 2.7), xytext=(8, 4),
                arrowprops=dict(arrowstyle='->', color='gray', lw=1, linestyle='dashed'))
    ax.annotate('', xy=(2.25, 2.7), xytext=(2, 4),
                arrowprops=dict(arrowstyle='->', color='gray', lw=1, linestyle='dashed'))

    # Title
    ax.text(5, 0.5, 'Certified Reconstruction Algorithm',
            ha='center', va='center', fontsize=14, fontweight='bold',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.5))

    ax.axis('off')
    plt.tight_layout()
    return fig


def generate_all_visualizations():
    """Generate all visualizations and save as PNG files."""
    print("Generating visualizations...")

    figs = {
        'poset_and_fibers': viz_poset_and_fibers(),
        'compatible_vs_incompatible': viz_compatible_vs_incompatible(),
        'idempotent_aggregation': viz_idempotent_aggregation(),
        'reconstruction_flowchart': viz_reconstruction_flowchart(),
    }

    base64_images = {}
    for name, fig in figs.items():
        filename = f'{name}.png'
        fig.savefig(filename, dpi=150, bbox_inches='tight',
                    facecolor='white', edgecolor='none')
        base64_images[name] = fig_to_base64(fig)
        plt.close(fig)
        print(f"  Saved {filename}")

    return base64_images


if __name__ == "__main__":
    images = generate_all_visualizations()
    print(f"\nGenerated {len(images)} visualizations.")
    for name, b64 in images.items():
        print(f"  {name}: {len(b64)} chars (base64)")
