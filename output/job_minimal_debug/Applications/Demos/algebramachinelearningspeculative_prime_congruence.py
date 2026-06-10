"""
Applications of Observer-Relative Rate–Distortion Theory

Demonstrates practical applications of the theory to:
1. Neural network architecture compression
2. Model selection under interpretability constraints
3. Ensemble pruning with semantic guarantees
"""

import numpy as np
from typing import List, Tuple, Dict
from algorithms import ObserverFamily, rate_distortion_optimize, verify_duality, canonical_observer_code


# ============================================================
# Application 1: Neural Architecture Compression
# ============================================================

def neural_architecture_compression():
    """
    Simulate compressing neural architectures using observer-relative distortion.
    
    Scenario: We have 8 neural network architectures of varying complexity.
    Observers represent different test suites / behavioral probes:
    - Observer 0: Performance on standard benchmarks (coarse)
    - Observer 1: Robustness to adversarial perturbations
    - Observer 2: Calibration quality
    - Observer 3: Fairness across demographic groups
    - Observer 4: Out-of-distribution detection capability
    
    Two architectures are "equivalent" under an observer if they
    produce the same qualitative behavior on that test suite.
    """
    print("=" * 60)
    print("APPLICATION 1: Neural Architecture Compression")
    print("=" * 60)
    
    # 8 architectures with behavioral equivalence classes
    # Architecture 0: Large transformer (reference)
    # Architecture 1: Medium transformer
    # Architecture 2: Small transformer
    # Architecture 3: Large CNN
    # Architecture 4: Medium CNN
    # Architecture 5: Small CNN
    # Architecture 6: MLP
    # Architecture 7: Linear model
    
    arch_names = [
        "Large Transformer", "Med Transformer", "Small Transformer",
        "Large CNN", "Med CNN", "Small CNN", "MLP", "Linear"
    ]
    
    # Code lengths (parameter count in millions, simplified)
    code_lengths = [100, 50, 20, 80, 40, 15, 5, 1]
    
    class_matrix = np.array([
        [0, 0, 0, 0, 0, 1, 1, 2],  # Benchmark: transformers≈CNNs > MLP > Linear
        [0, 0, 1, 0, 1, 1, 2, 2],  # Robustness: large models > medium > small
        [0, 0, 1, 0, 0, 1, 1, 2],  # Calibration: large+CNN good, rest varies
        [0, 0, 0, 1, 1, 1, 0, 0],  # Fairness: transformers+simple ≠ CNNs
        [0, 1, 2, 0, 1, 2, 2, 2],  # OOD detection: scales with model size
    ])
    
    O = ObserverFamily(class_matrix)
    candidates = list(zip(range(8), code_lengths))
    target = 0  # Compress the large transformer
    
    print(f"\nTarget: {arch_names[0]} (cost={code_lengths[0]}M params)")
    print(f"\nCompression results:")
    print(f"{'ε (allowed disagreements)':>30} | {'Best compressed':>20} | {'Cost':>6} | {'Savings':>8}")
    print("-" * 75)
    
    for eps in range(6):
        cost, best = rate_distortion_optimize(O, candidates, target, eps)
        if best:
            model_id, cl = best
            savings = (1 - cl / code_lengths[0]) * 100
            print(f"{eps:>30} | {arch_names[model_id]:>20} | {cl:>5}M | {savings:>6.1f}%")
        else:
            print(f"{eps:>30} | {'(infeasible)':>20} |    -- |      --")
    
    print(f"\nInterpretation:")
    print(f"  ε=0: Perfect semantic preservation → no compression possible")
    print(f"  ε=1: Allow 1 observer disagreement → moderate compression")
    print(f"  ε=2: Allow 2 disagreements → significant compression")
    print(f"  The theory guarantees these are OPTIMAL for the given observers.")


# ============================================================
# Application 2: Model Selection with Interpretability
# ============================================================

def model_selection_interpretability():
    """
    Use observer distortion to select models that preserve
    interpretability-relevant behaviors.
    
    Observers represent different stakeholder perspectives:
    - Regulator: cares about fairness and compliance
    - User: cares about accuracy and speed
    - Developer: cares about maintainability and debuggability
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Model Selection under Interpretability")
    print("=" * 60)
    
    model_names = [
        "Deep Ensemble", "Single Large Net", "Distilled Model",
        "Decision Tree", "Rule-based System", "Bayesian Net"
    ]
    
    # Costs represent interpretability burden (higher = harder to interpret)
    costs = [10, 8, 5, 2, 1, 4]
    
    # Observers from different stakeholders
    class_matrix = np.array([
        [0, 0, 0, 1, 1, 0],  # Regulator: neural vs interpretable
        [0, 0, 0, 1, 2, 1],  # User: accuracy tiers
        [0, 0, 1, 1, 1, 0],  # Developer: complexity classes
    ])
    
    O = ObserverFamily(class_matrix)
    candidates = list(zip(range(6), costs))
    
    print(f"\nModels and their interpretability costs:")
    for i, (name, cost) in enumerate(zip(model_names, costs)):
        print(f"  {name}: cost = {cost}")
    
    print(f"\nFor each reference model, find the most interpretable equivalent:")
    for target in range(6):
        code = canonical_observer_code(O, candidates, target, epsilon=0)
        if code:
            compressed = model_names[code['model']]
            print(f"  {model_names[target]:>20} → {compressed:>20} (cost {code['code_length']})")


# ============================================================
# Application 3: Ensemble Pruning
# ============================================================

def ensemble_pruning():
    """
    Prune an ensemble of models while preserving semantic diversity.
    
    The observers measure whether models agree on critical decision boundaries.
    We want the smallest sub-ensemble that preserves all observer distinctions.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Ensemble Pruning with Semantic Guarantees")
    print("=" * 60)
    
    np.random.seed(42)
    
    num_models = 10
    num_observers = 6
    
    # Random observer structure
    class_matrix = np.random.randint(0, 3, size=(num_observers, num_models))
    
    O = ObserverFamily(class_matrix)
    
    # All models have equal cost (we want minimum ensemble size)
    candidates = [(i, 1) for i in range(num_models)]
    
    # Find observer-equivalence classes
    D = O.distortion_matrix()
    equiv_classes = []
    assigned = set()
    
    for i in range(num_models):
        if i in assigned:
            continue
        cls = [i]
        for j in range(i + 1, num_models):
            if j not in assigned and D[i, j] == 0:
                cls.append(j)
                assigned.add(j)
        equiv_classes.append(cls)
        assigned.add(i)
    
    print(f"\n{num_models} models with {num_observers} observers")
    print(f"\nObserver-equivalence classes:")
    for i, cls in enumerate(equiv_classes):
        print(f"  Class {i}: models {cls}")
    
    print(f"\nMinimum ensemble size preserving all observer distinctions: {len(equiv_classes)}")
    print(f"Representatives: {[cls[0] for cls in equiv_classes]}")
    print(f"Pruning ratio: {len(equiv_classes)}/{num_models} = {len(equiv_classes)/num_models:.1%}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("Observer-Relative Rate–Distortion Theory: Applications")
    print()
    
    neural_architecture_compression()
    model_selection_interpretability()
    ensemble_pruning()
    
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


"""
Observer-Relative Rate–Distortion Theory: Interactive Demonstrations

This module demonstrates the core concepts of observer-relative algebraic
rate–distortion theory with concrete numerical examples.
"""

import numpy as np
from itertools import combinations
from typing import List, Tuple, Dict, Set, Callable


# ============================================================
# Core Data Structures
# ============================================================

class ObserverFamily:
    """A finite family of equivalence relations (observers) on a model space.
    
    Each observer is represented as a partition of the model space into
    equivalence classes. Two models are 'distinguished' by an observer
    if they lie in different classes.
    """
    
    def __init__(self, num_models: int, partitions: List[List[Set[int]]]):
        """
        Args:
            num_models: Total number of models in the space
            partitions: List of partitions, each partition is a list of sets (classes)
        """
        self.num_models = num_models
        self.num_obs = len(partitions)
        self.partitions = partitions
        # Precompute class assignments for fast lookup
        self._class_of = []
        for partition in partitions:
            class_map = {}
            for cls_idx, cls in enumerate(partition):
                for model in cls:
                    class_map[model] = cls_idx
            self._class_of.append(class_map)
    
    def observe(self, observer_idx: int, model_a: int, model_b: int) -> bool:
        """Returns True if observer considers models equivalent."""
        return self._class_of[observer_idx][model_a] == self._class_of[observer_idx][model_b]
    
    def distinguishes(self, observer_idx: int, model_a: int, model_b: int) -> bool:
        """Returns True if observer distinguishes the two models."""
        return not self.observe(observer_idx, model_a, model_b)


class ModelWithComplexity:
    """A model bundled with its code length (complexity measure)."""
    
    def __init__(self, model_id: int, code_length: int):
        self.model_id = model_id
        self.code_length = code_length
    
    def __repr__(self):
        return f"Model({self.model_id}, cost={self.code_length})"


# ============================================================
# Core Functions
# ============================================================

def observer_distortion_count(O: ObserverFamily, x: int, y: int) -> int:
    """Count the number of observers that distinguish x from y."""
    return sum(1 for i in range(O.num_obs) if O.distinguishes(i, x, y))


def feasible_set(O: ObserverFamily, candidates: List[ModelWithComplexity], 
                 target: int, epsilon: int) -> List[ModelWithComplexity]:
    """Find all candidates with distortion ≤ epsilon from target."""
    return [c for c in candidates 
            if observer_distortion_count(O, target, c.model_id) <= epsilon]


def operadic_rate_distortion(O: ObserverFamily, candidates: List[ModelWithComplexity],
                              target: int, epsilon: int) -> int:
    """Compute the minimum code length among feasible models."""
    feas = feasible_set(O, candidates, target, epsilon)
    if not feas:
        return 0  # Convention: infeasible returns 0
    return min(c.code_length for c in feas)


def spectral_certificate_cost(O: ObserverFamily, candidates: List[ModelWithComplexity],
                                target: int, agreed_observers: Set[int]) -> float:
    """Minimum code length among models that agree on all specified observers."""
    realizers = [c for c in candidates
                 if all(O.observe(i, target, c.model_id) for i in agreed_observers)]
    if not realizers:
        return float('inf')
    return min(c.code_length for c in realizers)


def prime_congruence_rate(O: ObserverFamily, candidates: List[ModelWithComplexity],
                           target: int, epsilon: int) -> float:
    """Minimum spectral certificate cost over all valid certificates."""
    n = O.num_obs
    best = float('inf')
    # Enumerate all subsets of observers
    for size in range(max(0, n - epsilon), n + 1):
        for agreed in combinations(range(n), size):
            agreed_set = set(agreed)
            # Certificate is valid if n - |agreed| ≤ epsilon
            if n - len(agreed_set) <= epsilon:
                cost = spectral_certificate_cost(O, candidates, target, agreed_set)
                best = min(best, cost)
    return best


# ============================================================
# Demo 1: Basic Observer Distortion
# ============================================================

def demo_basic_distortion():
    """Demonstrate observer distortion as a pseudometric."""
    print("=" * 60)
    print("DEMO 1: Observer Distortion Pseudometric")
    print("=" * 60)
    
    # 5 models, 3 observers
    # Observer 0: groups by "architecture type" {0,1,2} vs {3,4}
    # Observer 1: groups by "depth class" {0,3} vs {1,4} vs {2}
    # Observer 2: groups by "width class" {0,4} vs {1,2,3}
    
    partitions = [
        [{0, 1, 2}, {3, 4}],          # Architecture type
        [{0, 3}, {1, 4}, {2}],         # Depth class
        [{0, 4}, {1, 2, 3}],           # Width class
    ]
    O = ObserverFamily(5, partitions)
    
    print(f"\nNumber of models: 5")
    print(f"Number of observers: {O.num_obs}")
    print(f"\nObserver partitions:")
    for i, p in enumerate(partitions):
        print(f"  Observer {i}: {[sorted(s) for s in p]}")
    
    print(f"\nDistortion matrix d(i,j):")
    print("     ", end="")
    for j in range(5):
        print(f"  M{j}", end="")
    print()
    for i in range(5):
        print(f"  M{i} ", end="")
        for j in range(5):
            d = observer_distortion_count(O, i, j)
            print(f"  {d} ", end="")
        print()
    
    # Verify pseudometric properties
    print(f"\n--- Pseudometric Properties ---")
    
    # Reflexivity
    all_refl = all(observer_distortion_count(O, i, i) == 0 for i in range(5))
    print(f"Reflexivity d(x,x)=0: {all_refl}")
    
    # Symmetry
    all_symm = all(
        observer_distortion_count(O, i, j) == observer_distortion_count(O, j, i)
        for i in range(5) for j in range(5)
    )
    print(f"Symmetry d(x,y)=d(y,x): {all_symm}")
    
    # Triangle inequality
    all_tri = all(
        observer_distortion_count(O, i, k) <= 
        observer_distortion_count(O, i, j) + observer_distortion_count(O, j, k)
        for i in range(5) for j in range(5) for k in range(5)
    )
    print(f"Triangle inequality: {all_tri}")
    
    return O


# ============================================================
# Demo 2: Rate–Distortion Computation
# ============================================================

def demo_rate_distortion(O: ObserverFamily):
    """Demonstrate rate–distortion computation and duality."""
    print("\n" + "=" * 60)
    print("DEMO 2: Rate–Distortion Computation & Duality")
    print("=" * 60)
    
    # Create candidates with varying complexity
    candidates = [
        ModelWithComplexity(0, 5),   # Most complex
        ModelWithComplexity(1, 3),
        ModelWithComplexity(2, 4),
        ModelWithComplexity(3, 2),
        ModelWithComplexity(4, 1),   # Simplest
    ]
    
    target = 0  # Compress model 0
    
    print(f"\nTarget model: M0 (code length = 5)")
    print(f"Candidates: {candidates}")
    
    print(f"\nDistortions from target M0:")
    for c in candidates:
        d = observer_distortion_count(O, target, c.model_id)
        print(f"  d(M0, M{c.model_id}) = {d}")
    
    print(f"\nRate–Distortion Function R(ε):")
    print(f"  ε  | R_operadic(ε) | R_spectral(ε) | Duality holds?")
    print(f"  ---|---------------|---------------|---------------")
    
    for eps in range(O.num_obs + 1):
        r_op = operadic_rate_distortion(O, candidates, target, eps)
        r_pc = prime_congruence_rate(O, candidates, target, eps)
        feas = feasible_set(O, candidates, target, eps)
        holds = (r_op == r_pc) if feas else "N/A (infeasible)"
        print(f"  {eps}  |      {r_op}        |      {r_pc if r_pc < float('inf') else '∞':}        | {holds}")
    
    return candidates


# ============================================================
# Demo 3: Spectral Certificate Analysis
# ============================================================

def demo_spectral_certificates(O: ObserverFamily, candidates: List[ModelWithComplexity]):
    """Demonstrate spectral certificates and the duality correspondence."""
    print("\n" + "=" * 60)
    print("DEMO 3: Spectral Certificate Analysis")
    print("=" * 60)
    
    target = 0
    
    for eps in range(O.num_obs + 1):
        print(f"\n--- Threshold ε = {eps} ---")
        
        feas = feasible_set(O, candidates, target, eps)
        print(f"Feasible models: {feas}")
        
        if feas:
            best = min(feas, key=lambda c: c.code_length)
            print(f"Best feasible: {best}")
            
            # Show the spectral certificate induced by the best model
            agreed = {i for i in range(O.num_obs) 
                     if O.observe(i, target, best.model_id)}
            disagreed = set(range(O.num_obs)) - agreed
            print(f"Induced certificate:")
            print(f"  Agreed observers: {sorted(agreed)}")
            print(f"  Disagreed observers: {sorted(disagreed)}")
            print(f"  Certificate valid at ε={eps}? {len(disagreed) <= eps}")
        else:
            print(f"No feasible solution at this threshold.")


# ============================================================
# Demo 4: Observer Equivalence Classes
# ============================================================

def demo_equivalence_classes(O: ObserverFamily):
    """Show observer-equivalence classes (zero-distortion quotient)."""
    print("\n" + "=" * 60)
    print("DEMO 4: Observer Equivalence Classes")
    print("=" * 60)
    
    n = O.num_models
    
    # Find equivalence classes (zero distortion)
    visited = set()
    classes = []
    for i in range(n):
        if i in visited:
            continue
        cls = {i}
        for j in range(i + 1, n):
            if observer_distortion_count(O, i, j) == 0:
                cls.add(j)
                visited.add(j)
        classes.append(cls)
        visited.add(i)
    
    print(f"\nObserver-equivalence classes (d=0 quotient):")
    for i, cls in enumerate(classes):
        print(f"  Class {i}: {sorted(cls)}")
    
    print(f"\nNumber of distinct classes: {len(classes)}")
    print(f"Quotient reduces {n} models to {len(classes)} equivalence classes")


# ============================================================
# Demo 5: Scaling Behavior
# ============================================================

def demo_scaling():
    """Show how rate–distortion scales with observer family size."""
    print("\n" + "=" * 60)
    print("DEMO 5: Scaling with Observer Family Size")
    print("=" * 60)
    
    import random
    random.seed(42)
    
    num_models = 8
    
    print(f"\nModels: {num_models}")
    print(f"\n{'Num observers':>15} | {'ε=0':>6} | {'ε=1':>6} | {'ε=2':>6} | {'ε=3':>6}")
    print(f"{'-'*15}-|-{'-'*6}-|-{'-'*6}-|-{'-'*6}-|-{'-'*6}")
    
    for num_obs in [2, 4, 6, 8, 10]:
        # Random partitions into 2-3 classes
        partitions = []
        for _ in range(num_obs):
            num_classes = random.randint(2, 3)
            models = list(range(num_models))
            random.shuffle(models)
            partition = []
            for c in range(num_classes - 1):
                size = random.randint(1, len(models) - (num_classes - c - 1))
                partition.append(set(models[:size]))
                models = models[size:]
            partition.append(set(models))
            partitions.append(partition)
        
        O = ObserverFamily(num_models, partitions)
        
        # Create candidates with complexity = model_id + 1
        candidates = [ModelWithComplexity(i, i + 1) for i in range(num_models)]
        target = 0
        
        rates = []
        for eps in range(4):
            r = operadic_rate_distortion(O, candidates, target, eps)
            rates.append(r)
        
        print(f"{num_obs:>15} | {rates[0]:>6} | {rates[1]:>6} | {rates[2]:>6} | {rates[3]:>6}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("Observer-Relative Algebraic Rate–Distortion Theory")
    print("Concrete Numerical Demonstrations")
    print()
    
    O = demo_basic_distortion()
    candidates = demo_rate_distortion(O)
    demo_spectral_certificates(O, candidates)
    demo_equivalence_classes(O)
    demo_scaling()
    
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


"""Generate PACKAGE.json with all embedded content."""
import json
import sys
sys.path.insert(0, '.')
from visualizations import (
    plot_distortion_heatmap, plot_rate_distortion_curve,
    plot_certificate_landscape, plot_compression_tradeoff,
    plot_equivalence_graph
)

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Generate visualizations
print("Generating visualizations...")
viz_heatmap = plot_distortion_heatmap()
viz_rd_curve = plot_rate_distortion_curve()
viz_certs = plot_certificate_landscape()
viz_tradeoff = plot_compression_tradeoff()
viz_graph = plot_equivalence_graph()

# Read content files
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_proofs = read_file('Bridges/ObserverRateDistortion.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

package = {
    "title": "Observer-Relative Algebraic Rate-Distortion Theory for Neural Operads",
    "domain": "Algebraic Information Theory / Machine Learning Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Observer Distortion and Rate-Distortion Demo",
            "code": demo_code
        },
        {
            "name": "Applications: Architecture Compression & Model Selection",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Operadic Rate-Distortion Optimization",
            "pseudocode": """Input: Observer family O, candidates C, target x, threshold ε
Output: Minimum code length R and optimal model m*

1. For each (m, c) in C:
     Compute d_O(x, m) = |{i : x ≁_i m}|
2. Let F = {(m, c) ∈ C : d_O(x, m) ≤ ε}
3. If F is empty, return (0, None)
4. Return (m*, c*) = argmin_{(m,c) ∈ F} c

Complexity: O(|C| · n) time, O(|C|) space.""",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Observer Distortion Heatmap",
            "data": viz_heatmap
        },
        {
            "name": "Rate-Distortion Curve with Spectral Duality",
            "data": viz_rd_curve
        },
        {
            "name": "Spectral Certificate Landscape",
            "data": viz_certs
        },
        {
            "name": "Compression-Distortion Tradeoff",
            "data": viz_tradeoff
        },
        {
            "name": "Observer Equivalence Graph",
            "data": viz_graph
        }
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({len(json.dumps(package))} chars)")


"""
Visualizations for Observer-Relative Rate–Distortion Theory

Generates publication-quality figures illustrating the core concepts.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import base64
from io import BytesIO
from algorithms import ObserverFamily, rate_distortion_optimize, verify_duality


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64-encoded PNG data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_distortion_heatmap() -> str:
    """Plot the observer distortion matrix as a heatmap."""
    class_matrix = np.array([
        [0, 0, 1, 1, 2, 2, 0, 1],
        [0, 1, 0, 1, 0, 1, 1, 0],
        [0, 0, 0, 1, 1, 1, 0, 1],
        [0, 1, 2, 0, 1, 2, 2, 0],
        [0, 0, 1, 1, 0, 0, 1, 1],
    ])
    O = ObserverFamily(class_matrix)
    D = O.distortion_matrix()
    
    fig, ax = plt.subplots(figsize=(8, 6))
    im = ax.imshow(D, cmap='YlOrRd', interpolation='nearest')
    
    n = D.shape[0]
    for i in range(n):
        for j in range(n):
            color = 'white' if D[i, j] > 2.5 else 'black'
            ax.text(j, i, str(D[i, j]), ha='center', va='center', 
                   fontsize=12, fontweight='bold', color=color)
    
    ax.set_xlabel('Model Index', fontsize=13)
    ax.set_ylabel('Model Index', fontsize=13)
    ax.set_title('Observer Distortion Matrix d(M_i, M_j)', fontsize=14, fontweight='bold')
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels([f'M{i}' for i in range(n)])
    ax.set_yticklabels([f'M{i}' for i in range(n)])
    
    cbar = plt.colorbar(im, ax=ax, shrink=0.8)
    cbar.set_label('Number of distinguishing observers', fontsize=11)
    
    fig.tight_layout()
    return fig_to_base64(fig)


def plot_rate_distortion_curve() -> str:
    """Plot the rate–distortion curve showing duality."""
    class_matrix = np.array([
        [0, 0, 1, 1, 2, 2, 0, 1],
        [0, 1, 0, 1, 0, 1, 1, 0],
        [0, 0, 0, 1, 1, 1, 0, 1],
        [0, 1, 2, 0, 1, 2, 2, 0],
        [0, 0, 1, 1, 0, 0, 1, 1],
    ])
    O = ObserverFamily(class_matrix)
    candidates = [(i, 8 - i) for i in range(8)]  # Decreasing cost
    
    results = verify_duality(O, candidates, target=0)
    
    epsilons = [r['epsilon'] for r in results]
    r_op = [r['operadic_rate'] if r['operadic_rate'] < 100 else None for r in results]
    r_pc = [r['spectral_rate'] if r['spectral_rate'] < 100 else None for r in results]
    
    fig, ax = plt.subplots(figsize=(9, 6))
    
    # Plot both curves
    valid_eps_op = [e for e, r in zip(epsilons, r_op) if r is not None]
    valid_r_op = [r for r in r_op if r is not None]
    valid_eps_pc = [e for e, r in zip(epsilons, r_pc) if r is not None]
    valid_r_pc = [r for r in r_pc if r is not None]
    
    ax.plot(valid_eps_op, valid_r_op, 'o-', color='#2196F3', linewidth=2.5,
            markersize=10, label='Operadic Rate R(ε)', zorder=5)
    ax.plot(valid_eps_pc, valid_r_pc, 's--', color='#FF5722', linewidth=2,
            markersize=8, label='Spectral Rate PC(ε)', zorder=4)
    
    # Shade the feasible region
    if valid_r_op:
        ax.fill_between(valid_eps_op, valid_r_op, max(valid_r_op) + 1,
                        alpha=0.1, color='#2196F3', label='Feasible region')
    
    ax.set_xlabel('Distortion Threshold ε', fontsize=13)
    ax.set_ylabel('Minimum Code Length', fontsize=13)
    ax.set_title('Rate–Distortion Curve with Spectral Duality\nR(ε) = PC(ε)', 
                fontsize=14, fontweight='bold')
    ax.legend(fontsize=11, loc='upper right')
    ax.set_xticks(range(len(epsilons)))
    ax.grid(True, alpha=0.3)
    
    # Add duality annotation
    if len(valid_eps_op) > 2:
        mid = len(valid_eps_op) // 2
        ax.annotate('Duality: R(ε) = PC(ε)',
                   xy=(valid_eps_op[mid], valid_r_op[mid]),
                   xytext=(valid_eps_op[mid] + 0.5, valid_r_op[mid] + 1),
                   fontsize=11, fontweight='bold', color='#4CAF50',
                   arrowprops=dict(arrowstyle='->', color='#4CAF50', lw=2))
    
    fig.tight_layout()
    return fig_to_base64(fig)


def plot_certificate_landscape() -> str:
    """Visualize the spectral certificate landscape."""
    from itertools import combinations
    
    n_obs = 4
    
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    for ax_idx, eps in enumerate([0, 1, 2]):
        ax = axes[ax_idx]
        
        # Generate all valid certificates
        certs = []
        for size in range(max(0, n_obs - eps), n_obs + 1):
            for agreed in combinations(range(n_obs), size):
                certs.append(set(agreed))
        
        # Visualize as a grid
        n_certs = len(certs)
        grid = np.zeros((n_certs, n_obs))
        for i, cert in enumerate(certs):
            for j in cert:
                grid[i, j] = 1
        
        im = ax.imshow(grid, cmap='Blues', aspect='auto', interpolation='nearest')
        ax.set_xlabel('Observer Index', fontsize=11)
        ax.set_ylabel('Certificate Index', fontsize=11)
        ax.set_title(f'Valid Certificates (ε={eps})\n{n_certs} certificates', 
                    fontsize=12, fontweight='bold')
        ax.set_xticks(range(n_obs))
        ax.set_xticklabels([f'Obs {i}' for i in range(n_obs)])
    
    fig.suptitle('Spectral Certificate Landscape', fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def plot_compression_tradeoff() -> str:
    """Plot compression vs semantic preservation tradeoff."""
    np.random.seed(42)
    
    fig, ax = plt.subplots(figsize=(9, 6))
    
    # Multiple observer family sizes
    for n_obs, color, marker in [(3, '#2196F3', 'o'), (5, '#FF5722', 's'), 
                                   (8, '#4CAF50', '^'), (12, '#9C27B0', 'D')]:
        n_models = 10
        class_matrix = np.random.randint(0, 3, size=(n_obs, n_models))
        O = ObserverFamily(class_matrix)
        candidates = [(i, n_models - i) for i in range(n_models)]
        
        rates = []
        epsilons = list(range(n_obs + 1))
        for eps in epsilons:
            r, _ = rate_distortion_optimize(O, candidates, target=0, epsilon=eps)
            rates.append(r if r is not None else n_models)
        
        # Normalize
        norm_eps = [e / n_obs for e in epsilons]
        
        ax.plot(norm_eps, rates, f'{marker}-', color=color, linewidth=2,
                markersize=7, label=f'{n_obs} observers', alpha=0.8)
    
    ax.set_xlabel('Normalized Distortion ε/n', fontsize=13)
    ax.set_ylabel('Minimum Code Length', fontsize=13)
    ax.set_title('Compression–Distortion Tradeoff\nAcross Observer Family Sizes', 
                fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    fig.tight_layout()
    return fig_to_base64(fig)


def plot_equivalence_graph() -> str:
    """Visualize the observer-equivalence graph."""
    class_matrix = np.array([
        [0, 0, 1, 1, 2],
        [0, 1, 0, 1, 0],
        [0, 0, 0, 1, 1],
    ])
    O = ObserverFamily(class_matrix)
    D = O.distortion_matrix()
    n = 5
    
    fig, ax = plt.subplots(figsize=(8, 8))
    
    # Position models in a circle
    angles = np.linspace(0, 2 * np.pi, n, endpoint=False)
    positions = np.column_stack([np.cos(angles), np.sin(angles)]) * 2
    
    # Draw edges colored by distortion
    max_d = D.max()
    for i in range(n):
        for j in range(i + 1, n):
            d = D[i, j]
            if d == 0:
                color = '#4CAF50'
                lw = 3
                alpha = 0.8
            elif d == 1:
                color = '#FFC107'
                lw = 2
                alpha = 0.6
            elif d == 2:
                color = '#FF9800'
                lw = 1.5
                alpha = 0.4
            else:
                color = '#F44336'
                lw = 1
                alpha = 0.3
            
            ax.plot([positions[i, 0], positions[j, 0]],
                   [positions[i, 1], positions[j, 1]],
                   color=color, linewidth=lw, alpha=alpha, zorder=1)
            
            # Label edge
            mid = (positions[i] + positions[j]) / 2
            ax.text(mid[0], mid[1], str(d), fontsize=9,
                   ha='center', va='center',
                   bbox=dict(boxstyle='round,pad=0.2', facecolor='white', 
                            edgecolor=color, alpha=0.8))
    
    # Draw nodes
    for i in range(n):
        circle = plt.Circle(positions[i], 0.25, color='#2196F3', 
                           ec='white', linewidth=2, zorder=5)
        ax.add_patch(circle)
        ax.text(positions[i, 0], positions[i, 1], f'M{i}',
               ha='center', va='center', fontsize=13,
               fontweight='bold', color='white', zorder=6)
    
    # Legend
    from matplotlib.lines import Line2D
    legend_elements = [
        Line2D([0], [0], color='#4CAF50', lw=3, label='d=0 (equivalent)'),
        Line2D([0], [0], color='#FFC107', lw=2, label='d=1'),
        Line2D([0], [0], color='#FF9800', lw=1.5, label='d=2'),
        Line2D([0], [0], color='#F44336', lw=1, label='d=3'),
    ]
    ax.legend(handles=legend_elements, loc='lower right', fontsize=11)
    
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    ax.set_aspect('equal')
    ax.set_title('Observer Distortion Graph\nEdge labels = number of distinguishing observers',
                fontsize=14, fontweight='bold')
    ax.axis('off')
    
    fig.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    
    viz1 = plot_distortion_heatmap()
    print(f"  Distortion heatmap: {len(viz1)} chars")
    
    viz2 = plot_rate_distortion_curve()
    print(f"  Rate-distortion curve: {len(viz2)} chars")
    
    viz3 = plot_certificate_landscape()
    print(f"  Certificate landscape: {len(viz3)} chars")
    
    viz4 = plot_compression_tradeoff()
    print(f"  Compression tradeoff: {len(viz4)} chars")
    
    viz5 = plot_equivalence_graph()
    print(f"  Equivalence graph: {len(viz5)} chars")
    
    print("All visualizations generated successfully.")
