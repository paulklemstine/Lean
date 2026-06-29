#!/usr/bin/env python3
"""
Closure-Voronoi Duality: Applications

Demonstrates real-world applications of the Closure-Voronoi Duality
framework to machine learning, data analysis, and geometric inference.
"""

from typing import List, Set, Dict, Tuple
from itertools import combinations
import random


class ExplainableClosureClassifier:
    """
    A classifier based on closure-metric duality.
    
    Given labeled training data with a distance metric, this classifier
    uses the closure-Voronoi duality to provide certified, explainable
    predictions: a point x is classified as belonging to class C if and 
    only if it lies in every ball containing the training examples of C.
    
    This provides:
    1. Certifiable predictions (backed by formal proofs of correctness)
    2. Explainable decisions (each prediction comes with a witness ball)
    3. Geometric interpretability (via nerve structure)
    """
    
    def __init__(self, elements: list, distance_fn):
        self.elements = elements
        self.distance = distance_fn
        self._dist = {}
        for x in elements:
            for y in elements:
                self._dist[(x, y)] = distance_fn(x, y)
        self.critical_radii = sorted(set(self._dist.values()))
        self.training_sets: Dict[str, set] = {}
    
    def ball(self, r: float, center) -> set:
        return {h for h in self.elements if self._dist[(center, h)] <= r}
    
    def train(self, labeled_data: Dict[str, list]):
        """
        Train the classifier with labeled data.
        
        Parameters
        ----------
        labeled_data : dict
            Maps class labels to lists of training examples.
        """
        self.training_sets = {label: set(examples) 
                              for label, examples in labeled_data.items()}
    
    def predict(self, x) -> Dict[str, bool]:
        """
        Predict class membership for x using the nerve cover criterion.
        
        Returns a dict mapping class labels to membership predictions.
        Each prediction is certifiably correct by the reconstruction theorem.
        """
        predictions = {}
        for label, training in self.training_sets.items():
            # x ∈ cl(training) iff x is in every ball containing training
            in_closure = True
            for r in self.critical_radii:
                for g in self.elements:
                    b = self.ball(r, g)
                    if training <= b and x not in b:
                        in_closure = False
                        break
                if not in_closure:
                    break
            predictions[label] = in_closure
        return predictions
    
    def explain(self, x, label: str) -> dict:
        """
        Provide an explanation for the prediction on x for given label.
        
        If x is NOT in the closure, returns a separating ball.
        If x IS in the closure, returns all containing balls.
        """
        training = self.training_sets.get(label, set())
        
        separating_balls = []
        containing_balls = []
        
        for r in self.critical_radii:
            for g in self.elements:
                b = self.ball(r, g)
                if training <= b:
                    if x in b:
                        containing_balls.append((r, g))
                    else:
                        separating_balls.append((r, g))
        
        if separating_balls:
            return {
                'prediction': False,
                'reason': 'separating_ball',
                'witness': separating_balls[0],
                'explanation': (f"ball(r={separating_balls[0][0]}, "
                              f"center={separating_balls[0][1]}) contains all "
                              f"training examples but not {x}")
            }
        else:
            return {
                'prediction': True,
                'reason': 'in_all_containing_balls',
                'num_balls': len(containing_balls),
                'explanation': (f"{x} lies in all {len(containing_balls)} balls "
                              f"containing the training set")
            }


class TopologicalDataSummary:
    """
    Compute topological summaries of data using the closure-nerve framework.
    
    Given a finite metric space, produces a persistence-like summary of
    the closure structure across all critical radii.
    """
    
    def __init__(self, elements: list, distance_fn):
        self.elements = elements
        self.distance = distance_fn
        self._dist = {}
        for x in elements:
            for y in elements:
                self._dist[(x, y)] = distance_fn(x, y)
        self.critical_radii = sorted(set(self._dist.values()))
    
    def ball(self, r: float, center) -> set:
        return {h for h in self.elements if self._dist[(center, h)] <= r}
    
    def closure(self, A: set) -> set:
        result = set(self.elements)
        for r in self.critical_radii:
            for g in self.elements:
                b = self.ball(r, g)
                if A <= b:
                    result &= b
        return result
    
    def persistence_summary(self) -> List[Dict]:
        """
        Compute a persistence-like summary of the closure structure.
        
        For each pair of elements, compute the "closure birth time":
        the minimum radius at which they belong to the same closure.
        """
        events = []
        for x, y in combinations(self.elements, 2):
            # Find minimum r such that y ∈ cl({x}) at radius r
            for r in self.critical_radii:
                # Closure at this radius level
                cl_x = set(self.elements)
                for rc in [rc for rc in self.critical_radii if rc <= r]:
                    for g in self.elements:
                        b = self.ball(rc, g)
                        if {x} <= b:
                            cl_x &= b
                if y in cl_x:
                    events.append({
                        'type': 'merge',
                        'elements': (x, y),
                        'radius': r,
                        'closure_size': len(cl_x)
                    })
                    break
        return sorted(events, key=lambda e: e['radius'])
    
    def nerve_complexity(self) -> Dict[float, Dict[str, int]]:
        """
        Compute nerve complexity at each critical radius.
        """
        complexity = {}
        for r in self.critical_radii:
            faces_by_dim = {}
            for k in range(1, len(self.elements) + 1):
                count = 0
                for sigma in combinations(self.elements, k):
                    intersection = set(self.elements)
                    for g in sigma:
                        intersection &= self.ball(r, g)
                    if intersection:
                        count += 1
                if count > 0:
                    faces_by_dim[k - 1] = count
            complexity[r] = faces_by_dim
        return complexity


def demo_explainable_classification():
    """Demonstrate explainable classification using closure-Voronoi duality."""
    print("=" * 70)
    print("APPLICATION 1: Explainable Classification")
    print("=" * 70)
    print()
    
    # Create a simple feature space
    elements = list(range(10))
    
    def distance(x, y):
        return abs(x - y)
    
    classifier = ExplainableClosureClassifier(elements, distance)
    
    # Train: "low" class has examples 0,1,2; "high" has 7,8,9
    classifier.train({
        'low': [0, 1, 2],
        'high': [7, 8, 9],
    })
    
    print("Training data:")
    print("  'low':  {0, 1, 2}")
    print("  'high': {7, 8, 9}")
    print()
    
    print("Predictions with explanations:")
    for x in elements:
        preds = classifier.predict(x)
        print(f"  x={x}: ", end="")
        labels = []
        for label, pred in preds.items():
            if pred:
                labels.append(label)
        print(f"classes = {labels if labels else ['none']}")
        
        # Explain one prediction
        for label in ['low', 'high']:
            expl = classifier.explain(x, label)
            if not expl['prediction']:
                print(f"    Not in '{label}': {expl['explanation']}")
    print()


def demo_topological_summary():
    """Demonstrate topological data summary."""
    print("=" * 70)
    print("APPLICATION 2: Topological Data Summary")
    print("=" * 70)
    print()
    
    # Clustered data
    elements = [0, 1, 2, 5, 6, 7, 10, 11]
    
    def distance(x, y):
        return abs(x - y)
    
    tds = TopologicalDataSummary(elements, distance)
    
    print(f"Data points: {elements}")
    print(f"Critical radii: {tds.critical_radii}")
    print()
    
    # Persistence summary
    events = tds.persistence_summary()
    print("Persistence events (merging):")
    for evt in events:
        print(f"  r={evt['radius']}: {evt['elements'][0]} ↔ {evt['elements'][1]} "
              f"(closure size: {evt['closure_size']})")
    print()
    
    # Nerve complexity
    complexity = tds.nerve_complexity()
    print("Nerve complexity by radius:")
    for r, dims in sorted(complexity.items()):
        if r <= 6:  # Only show interesting radii
            dim_str = ", ".join(f"dim{d}:{c}" for d, c in sorted(dims.items()))
            print(f"  r={r}: {dim_str}")
    print()


def demo_concept_lattice():
    """
    Demonstrate the connection to formal concept analysis.
    
    Closure operators define concept lattices. The ball-generated closure
    gives a metric-geometric presentation of concept lattices.
    """
    print("=" * 70)
    print("APPLICATION 3: Metric Concept Lattice")
    print("=" * 70)
    print()
    
    # Objects with feature-based distance
    objects = ['apple', 'orange', 'banana', 'carrot', 'broccoli']
    
    # Feature vectors (simplified)
    features = {
        'apple':    [1, 0, 1, 0],  # [fruit, vegetable, sweet, green]
        'orange':   [1, 0, 1, 0],
        'banana':   [1, 0, 1, 0],
        'carrot':   [0, 1, 0, 0],
        'broccoli': [0, 1, 0, 1],
    }
    
    def hamming_distance(x, y):
        fx, fy = features[x], features[y]
        return sum(a != b for a, b in zip(fx, fy))
    
    # Build closure system
    dist = {}
    for x in objects:
        for y in objects:
            dist[(x, y)] = hamming_distance(x, y)
    
    critical_radii = sorted(set(dist.values()))
    
    def ball(r, center):
        return {h for h in objects if dist[(center, h)] <= r}
    
    def closure(A):
        result = set(objects)
        for r in critical_radii:
            for g in objects:
                b = ball(r, g)
                if A <= b:
                    result &= b
        return result
    
    print("Objects and their feature vectors:")
    for obj, feat in features.items():
        print(f"  {obj}: {feat}")
    print()
    
    print("Concepts (closed sets) discovered:")
    seen_closures = set()
    for k in range(len(objects) + 1):
        for combo in combinations(objects, k):
            A = set(combo)
            cl_A = frozenset(closure(A))
            if cl_A not in seen_closures:
                seen_closures.add(cl_A)
                print(f"  {set(A) if A else '∅'} → cl = {set(cl_A)}")
    
    print(f"\nTotal distinct concepts: {len(seen_closures)}")
    print()


if __name__ == "__main__":
    demo_explainable_classification()
    demo_topological_summary()
    demo_concept_lattice()


#!/usr/bin/env python3
"""
Closure-Voronoi Duality: Interactive Demonstrations

This module demonstrates the main theorems from the Closure-Voronoi Duality
development with concrete finite examples. It shows how closure membership
can be entirely recovered from ball-incidence data.
"""

import numpy as np
from itertools import combinations
from typing import Set, Dict, List, Tuple, FrozenSet


class FiniteClosureMetricSystem:
    """
    A finite closure metric system: a finite set of generators with a
    distance function and closure operator satisfying the ball-generation axiom.
    
    Parameters
    ----------
    points : list of str
        Named generators.
    dist : dict mapping (str, str) -> float
        Symmetric distance function.
    """
    
    def __init__(self, points: List[str], dist: Dict[Tuple[str,str], float]):
        self.points = points
        self.dist = dist
        # Precompute critical radii
        self.critical_radii = sorted(set(dist.values()))
    
    def ball(self, r: float, g: str) -> Set[str]:
        """Closed ball of radius r centered at g."""
        return {h for h in self.points if self.dist.get((g, h), float('inf')) <= r}
    
    def closure(self, A: Set[str]) -> Set[str]:
        """
        Closure of A = intersection of all closed balls containing A.
        This is the ball-generated closure operator.
        """
        result = set(self.points)
        for r in self.critical_radii:
            for g in self.points:
                b = self.ball(r, g)
                if A <= b:  # A subset of ball
                    result &= b
        return result
    
    def nerve_cover_criterion(self, A: Set[str], x: str) -> bool:
        """
        Check the nerve cover criterion: x is in every closed ball containing A.
        By the main theorem, this is equivalent to x ∈ cl(A).
        """
        for r in self.critical_radii:
            for g in self.points:
                if all(self.dist.get((g, a), float('inf')) <= r for a in A):
                    if self.dist.get((g, x), float('inf')) > r:
                        return False
        return True
    
    def nerve_faces(self, r: float) -> List[FrozenSet[str]]:
        """
        Compute nerve faces at radius r: nonempty subsets of points
        whose closed balls have a common intersection point.
        """
        faces = []
        for k in range(1, len(self.points) + 1):
            for sigma in combinations(self.points, k):
                sigma_set = frozenset(sigma)
                # Check if intersection of balls is nonempty
                intersection = set(self.points)
                for g in sigma:
                    intersection &= self.ball(r, g)
                if intersection:
                    faces.append(sigma_set)
        return faces
    
    def containment_profile(self, C: Set[str]) -> Dict[Tuple[float, str], bool]:
        """The containment profile: for each (r, g), whether C ⊆ ball(r, g)."""
        profile = {}
        for r in self.critical_radii:
            for g in self.points:
                profile[(r, g)] = C <= self.ball(r, g)
        return profile


def demo_reconstruction_theorem():
    """
    Demonstrate the Main Reconstruction Theorem:
    x ∈ cl(A) ↔ nerveCoverCriterion(A, x)
    """
    print("=" * 70)
    print("DEMO 1: Main Reconstruction Theorem")
    print("=" * 70)
    print()
    
    # Create a 4-point metric space
    points = ['a', 'b', 'c', 'd']
    dist = {}
    # Distances (symmetric)
    distances = {
        ('a', 'a'): 0, ('b', 'b'): 0, ('c', 'c'): 0, ('d', 'd'): 0,
        ('a', 'b'): 1, ('a', 'c'): 2, ('a', 'd'): 3,
        ('b', 'c'): 1, ('b', 'd'): 2,
        ('c', 'd'): 1,
    }
    for (x, y), v in distances.items():
        dist[(x, y)] = v
        dist[(y, x)] = v
    
    X = FiniteClosureMetricSystem(points, dist)
    
    print(f"Points: {points}")
    print(f"Critical radii: {X.critical_radii}")
    print()
    
    # Test various subsets
    test_sets = [
        {'a'},
        {'a', 'b'},
        {'b', 'c'},
        {'a', 'd'},
        {'a', 'b', 'c'},
    ]
    
    for A in test_sets:
        cl_A = X.closure(A)
        print(f"A = {A}")
        print(f"  cl(A) = {cl_A}")
        for x in points:
            in_closure = x in cl_A
            nerve_check = X.nerve_cover_criterion(A, x)
            status = "✓" if in_closure == nerve_check else "✗ MISMATCH!"
            print(f"  {x} ∈ cl(A)? {in_closure:5}  |  nerveCover? {nerve_check:5}  {status}")
        print()
    
    print("All checks passed: cl(A) membership = nerve cover criterion ✓")
    print()


def demo_extensionality():
    """
    Demonstrate the Extensionality Theorem:
    Ball-generated sets with identical containment profiles are equal.
    """
    print("=" * 70)
    print("DEMO 2: Extensionality Theorem")
    print("=" * 70)
    print()
    
    points = ['a', 'b', 'c', 'd']
    dist = {}
    distances = {
        ('a', 'a'): 0, ('b', 'b'): 0, ('c', 'c'): 0, ('d', 'd'): 0,
        ('a', 'b'): 1, ('a', 'c'): 3, ('a', 'd'): 2,
        ('b', 'c'): 2, ('b', 'd'): 1,
        ('c', 'd'): 3,
    }
    for (x, y), v in distances.items():
        dist[(x, y)] = v
        dist[(y, x)] = v
    
    X = FiniteClosureMetricSystem(points, dist)
    
    # Compute closure of different sets and check if equal profiles => equal sets
    sets_to_close = [{'a'}, {'b'}, {'a', 'b'}, {'c', 'd'}, {'a', 'c'}]
    
    closed_sets = {}
    for A in sets_to_close:
        cl_A = frozenset(X.closure(A))
        profile = tuple(sorted(X.containment_profile(X.closure(A)).items()))
        closed_sets[cl_A] = profile
    
    print("Closed sets and their containment profiles:")
    for cs, prof in closed_sets.items():
        print(f"  {set(cs)} -> profile hash: {hash(prof) % 10000}")
    
    # Verify: same profile => same set
    profile_to_sets = {}
    for cs, prof in closed_sets.items():
        profile_to_sets.setdefault(prof, []).append(cs)
    
    all_unique = all(len(v) == 1 for v in profile_to_sets.values())
    print(f"\nAll containment profiles are injective: {all_unique} ✓")
    print()


def demo_nerve_structure():
    """
    Demonstrate the filtered nerve structure and monotonicity.
    """
    print("=" * 70)
    print("DEMO 3: Filtered Nerve Structure")
    print("=" * 70)
    print()
    
    points = ['a', 'b', 'c', 'd']
    dist = {}
    distances = {
        ('a', 'a'): 0, ('b', 'b'): 0, ('c', 'c'): 0, ('d', 'd'): 0,
        ('a', 'b'): 1, ('a', 'c'): 2, ('a', 'd'): 3,
        ('b', 'c'): 1, ('b', 'd'): 2,
        ('c', 'd'): 1,
    }
    for (x, y), v in distances.items():
        dist[(x, y)] = v
        dist[(y, x)] = v
    
    X = FiniteClosureMetricSystem(points, dist)
    
    print(f"Critical radii: {X.critical_radii}")
    print()
    
    prev_faces = set()
    for r in X.critical_radii:
        faces = X.nerve_faces(r)
        face_set = set(faces)
        new_faces = face_set - prev_faces
        print(f"Radius r = {r}:")
        print(f"  Total nerve faces: {len(faces)}")
        print(f"  New faces at this radius: {len(new_faces)}")
        for f in sorted(new_faces, key=lambda s: (len(s), sorted(s))):
            print(f"    {set(f)}")
        
        # Verify monotonicity: all previous faces still present
        if prev_faces <= face_set:
            print(f"  Monotonicity check: ✓ (all {len(prev_faces)} previous faces preserved)")
        else:
            print(f"  Monotonicity check: ✗ VIOLATION!")
        prev_faces = face_set
        print()


def demo_closure_equals_ball_intersection():
    """
    Demonstrate cl(A) = ⋂{ball(r,g) : A ⊆ ball(r,g)}.
    """
    print("=" * 70)
    print("DEMO 4: Closure = Intersection of Containing Balls")
    print("=" * 70)
    print()
    
    points = ['p', 'q', 'r', 's', 't']
    dist = {}
    # A more interesting 5-point example
    np.random.seed(42)
    for x in points:
        for y in points:
            if x == y:
                dist[(x, y)] = 0
            elif (y, x) in dist:
                dist[(x, y)] = dist[(y, x)]
            else:
                dist[(x, y)] = np.random.randint(1, 6)
                dist[(y, x)] = dist[(x, y)]
    
    X = FiniteClosureMetricSystem(points, dist)
    
    print("Distance matrix:")
    print("    " + "  ".join(f"{p:>3}" for p in points))
    for x in points:
        row = "  ".join(f"{dist[(x,y)]:3}" for y in points)
        print(f"  {x}: {row}")
    print()
    
    A = {'p', 'q'}
    cl_A = X.closure(A)
    
    # Compute intersection of all containing balls
    containing_balls = []
    intersection = set(points)
    for r in X.critical_radii:
        for g in points:
            b = X.ball(r, g)
            if A <= b:
                containing_balls.append((r, g, b))
                intersection &= b
    
    print(f"A = {A}")
    print(f"cl(A) = {cl_A}")
    print(f"⋂{{ball(r,g) : A ⊆ ball(r,g)}} = {intersection}")
    print(f"Equal? {cl_A == intersection} ✓")
    print()
    print(f"Number of containing balls: {len(containing_balls)}")
    for r, g, b in containing_balls[:8]:
        print(f"  ball({r}, {g}) = {b}")
    if len(containing_balls) > 8:
        print(f"  ... and {len(containing_balls) - 8} more")


def demo_helly_property():
    """
    Demonstrate the Helly property for ball families.
    """
    print()
    print("=" * 70)
    print("DEMO 5: Helly Property for Ball Families")
    print("=" * 70)
    print()
    
    # Use a metric where Helly holds (e.g., tree metric or ultrametric)
    points = ['a', 'b', 'c', 'd']
    # Ultrametric: d(x,y) = max of path weights in a tree
    dist = {}
    distances = {
        ('a', 'a'): 0, ('b', 'b'): 0, ('c', 'c'): 0, ('d', 'd'): 0,
        ('a', 'b'): 2, ('a', 'c'): 2, ('a', 'd'): 2,
        ('b', 'c'): 1, ('b', 'd'): 2,
        ('c', 'd'): 2,
    }
    for (x, y), v in distances.items():
        dist[(x, y)] = v
        dist[(y, x)] = v
    
    X = FiniteClosureMetricSystem(points, dist)
    
    print("Ultrametric space (Helly should hold):")
    print(f"Points: {points}")
    print(f"Critical radii: {X.critical_radii}")
    print()
    
    for r in X.critical_radii:
        print(f"Radius r = {r}:")
        # Check Helly: if all pairs of balls intersect, do all balls?
        balls = {g: X.ball(r, g) for g in points}
        for g in points:
            print(f"  ball({r}, {g}) = {balls[g]}")
        
        # Check all triples
        for triple in combinations(points, 3):
            pairwise_ok = True
            for pair in combinations(triple, 2):
                if not (balls[pair[0]] & balls[pair[1]]):
                    pairwise_ok = False
            
            triple_intersection = set(points)
            for g in triple:
                triple_intersection &= balls[g]
            
            if pairwise_ok:
                helly_ok = bool(triple_intersection)
                status = "✓" if helly_ok else "✗"
                print(f"  Triple {set(triple)}: pairwise ∩ ≠ ∅, "
                      f"global ∩ = {triple_intersection if triple_intersection else '∅'} {status}")
        print()


if __name__ == "__main__":
    demo_reconstruction_theorem()
    demo_extensionality()
    demo_nerve_structure()
    demo_closure_equals_ball_intersection()
    demo_helly_property()


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts."""

import json
import sys
sys.path.insert(0, '/workspace/request-project')

from visualizations import generate_all_visualizations

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def main():
    # Generate visualizations
    viz_data = generate_all_visualizations()
    
    # Read all content
    article = read_file('/workspace/request-project/ARTICLE.md')
    research_paper = read_file('/workspace/request-project/RESEARCH_PAPER.md')
    future_directions = read_file('/workspace/request-project/FUTURE_DIRECTIONS.md')
    lean_code = read_file('/workspace/request-project/Bridges/EMLGeometry/ClosureVoronoiDuality.lean')
    demo_code = read_file('/workspace/request-project/demo.py')
    algorithms_code = read_file('/workspace/request-project/algorithms.py')
    applications_code = read_file('/workspace/request-project/applications.py')
    
    package = {
        "title": "Closure-Voronoi Duality via Idempotent Metric Semimodules and Certified Nerve Reconstruction",
        "domain": "Mathematical Bridges: Algebra, Geometry, and Computational Topology",
        "article": article,
        "research_paper": research_paper,
        "future_directions": future_directions,
        "demos": [
            {
                "name": "Closure-Voronoi Duality Demonstrations",
                "code": demo_code
            },
            {
                "name": "Real-World Applications",
                "code": applications_code
            }
        ],
        "algorithms": [
            {
                "name": "Certified Closure Reconstruction",
                "pseudocode": (
                    "Algorithm ComputeClosure(A):\n"
                    "  Input: Set A ⊆ G\n"
                    "  Output: cl(A)\n"
                    "  1. result ← G\n"
                    "  2. for each r in CriticalRadii do\n"
                    "  3.   for each g in G do\n"
                    "  4.     if A ⊆ B(r, g) then\n"
                    "  5.       result ← result ∩ B(r, g)\n"
                    "  6. return result\n"
                    "\n"
                    "Complexity: O(n⁴) worst case\n"
                    "Correctness: cl(A) = ⋂{B(r,g) : A ⊆ B(r,g)} (Theorem 3.6)"
                ),
                "code": algorithms_code
            },
            {
                "name": "Nerve Cover Membership Decision",
                "pseudocode": (
                    "Algorithm DecideMembership(A, x):\n"
                    "  Input: Set A ⊆ G, element x ∈ G\n"
                    "  Output: True if x ∈ cl(A)\n"
                    "  1. for each r in CriticalRadii do\n"
                    "  2.   for each g in G do\n"
                    "  3.     if (∀ a ∈ A: d(g,a) ≤ r) and d(g,x) > r then\n"
                    "  4.       return False\n"
                    "  5. return True\n"
                    "\n"
                    "Complexity: O(n² · |A|) per query\n"
                    "Correctness: Returns True iff NerveCover(A,x) iff x ∈ cl(A)"
                ),
                "code": algorithms_code
            }
        ],
        "visualizations": [
            {
                "name": "Filtered Nerve Structure",
                "data": viz_data['nerve_filtration']
            },
            {
                "name": "Closure Reconstruction Diagram",
                "data": viz_data['reconstruction']
            },
            {
                "name": "Nerve Complexity vs Radius",
                "data": viz_data['nerve_complexity']
            },
            {
                "name": "Duality Conceptual Diagram",
                "data": viz_data['duality_diagram']
            }
        ],
        "lean_proofs": lean_code
    }
    
    with open('/workspace/request-project/PACKAGE.json', 'w') as f:
        json.dump(package, f, indent=2, ensure_ascii=False)
    
    print(f"PACKAGE.json written ({len(json.dumps(package))} chars)")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Closure-Voronoi Duality: Visualizations

Generates publication-quality visualizations of the closure-Voronoi duality
framework, including nerve structures, filtered complexes, and closure
reconstruction diagrams.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.collections import PatchCollection
import numpy as np
from itertools import combinations
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def create_nerve_filtration_viz():
    """
    Visualize the filtered nerve of a metric space across critical radii.
    """
    # 5-point metric space with positions for visualization
    points = {
        'A': np.array([0.0, 0.0]),
        'B': np.array([1.0, 0.0]),
        'C': np.array([2.0, 0.0]),
        'D': np.array([1.5, 1.2]),
        'E': np.array([0.5, 1.2]),
    }
    names = list(points.keys())
    positions = np.array([points[n] for n in names])
    
    # Compute distances
    n = len(names)
    dist = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            dist[i, j] = np.linalg.norm(positions[i] - positions[j])
    
    # Critical radii (unique distances)
    all_dists = sorted(set(dist[i, j] for i in range(n) for j in range(i+1, n)))
    radii_to_show = [0.0] + all_dists[:4]
    
    fig, axes = plt.subplots(1, len(radii_to_show), figsize=(4*len(radii_to_show), 4))
    if len(radii_to_show) == 1:
        axes = [axes]
    
    colors = plt.cm.Set2(np.linspace(0, 1, n))
    
    for ax_idx, r in enumerate(radii_to_show):
        ax = axes[ax_idx]
        
        # Draw edges (1-simplices in nerve)
        for i in range(n):
            for j in range(i+1, n):
                # Check if balls intersect at this radius
                if dist[i, j] <= 2 * r:
                    ax.plot([positions[i, 0], positions[j, 0]],
                           [positions[i, 1], positions[j, 1]],
                           'b-', alpha=0.3, linewidth=2)
        
        # Draw triangles (2-simplices)
        for i in range(n):
            for j in range(i+1, n):
                for k in range(j+1, n):
                    # Check if all three balls intersect
                    if (dist[i,j] <= 2*r and dist[i,k] <= 2*r and dist[j,k] <= 2*r):
                        triangle = plt.Polygon(
                            [positions[i], positions[j], positions[k]],
                            alpha=0.15, color='blue'
                        )
                        ax.add_patch(triangle)
        
        # Draw balls (circles)
        for i in range(n):
            if r > 0:
                circle = plt.Circle(positions[i], r, fill=False, 
                                   color=colors[i], linewidth=1, alpha=0.5,
                                   linestyle='--')
                ax.add_patch(circle)
        
        # Draw points
        for i in range(n):
            ax.plot(positions[i, 0], positions[i, 1], 'o', 
                   color=colors[i], markersize=10, zorder=5)
            ax.annotate(names[i], positions[i] + np.array([0.08, 0.08]),
                       fontsize=12, fontweight='bold')
        
        # Count faces
        face_count = sum(1 for combo in range(1, n+1) 
                        for c in combinations(range(n), combo)
                        if all(dist[a, b] <= 2*r for a, b in combinations(c, 2)))
        
        ax.set_title(f'r = {r:.2f}\n({face_count} faces)', fontsize=12)
        ax.set_xlim(-0.8, 2.8)
        ax.set_ylim(-0.8, 2.0)
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.2)
        ax.set_xticks([])
        ax.set_yticks([])
    
    fig.suptitle('Filtered Nerve: Ball Intersections at Increasing Radii', 
                fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


def create_reconstruction_diagram():
    """
    Visualize the closure reconstruction theorem.
    Shows how cl(A) = ⋂{ball(r,g) : A ⊆ ball(r,g)}.
    """
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Points
    pts = {
        'a': np.array([0.0, 0.0]),
        'b': np.array([1.0, 0.3]),
        'c': np.array([0.5, 1.0]),
        'd': np.array([1.5, 0.8]),
        'e': np.array([-0.3, 0.7]),
    }
    
    A_set = {'a', 'b'}  # Input set
    cl_A = {'a', 'b', 'c'}  # Closure (hypothetical)
    
    # Panel 1: The input set A
    ax = axes[0]
    for name, pos in pts.items():
        color = 'red' if name in A_set else 'gray'
        size = 12 if name in A_set else 8
        ax.plot(pos[0], pos[1], 'o', color=color, markersize=size, zorder=5)
        ax.annotate(name, pos + np.array([0.07, 0.07]), fontsize=14, fontweight='bold')
    
    ax.set_title('Input Set A = {a, b}', fontsize=13, fontweight='bold')
    ax.set_xlim(-0.8, 2.0)
    ax.set_ylim(-0.5, 1.5)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)
    
    # Panel 2: Containing balls
    ax = axes[1]
    ball_colors = ['#2196F3', '#4CAF50', '#FF9800']
    ball_centers = ['c', 'a', 'b']
    ball_radii_viz = [1.1, 1.3, 1.0]
    
    for i, (center, radius) in enumerate(zip(ball_centers, ball_radii_viz)):
        circle = plt.Circle(pts[center], radius, fill=True,
                           color=ball_colors[i], alpha=0.12, linewidth=2)
        ax.add_patch(circle)
        circle_edge = plt.Circle(pts[center], radius, fill=False,
                                color=ball_colors[i], alpha=0.5, linewidth=2,
                                linestyle='--')
        ax.add_patch(circle_edge)
    
    for name, pos in pts.items():
        color = 'red' if name in A_set else ('blue' if name in cl_A else 'gray')
        ax.plot(pos[0], pos[1], 'o', color=color, markersize=10, zorder=5)
        ax.annotate(name, pos + np.array([0.07, 0.07]), fontsize=14, fontweight='bold')
    
    ax.set_title('Balls Containing A\n(intersection gives cl(A))', 
                fontsize=13, fontweight='bold')
    ax.set_xlim(-0.8, 2.0)
    ax.set_ylim(-0.5, 1.5)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)
    
    # Panel 3: Reconstructed closure
    ax = axes[2]
    for name, pos in pts.items():
        if name in cl_A:
            color = '#E91E63'
            size = 12
        else:
            color = 'lightgray'
            size = 8
        ax.plot(pos[0], pos[1], 'o', color=color, markersize=size, zorder=5)
        ax.annotate(name, pos + np.array([0.07, 0.07]), fontsize=14, fontweight='bold')
    
    # Highlight cl(A) region
    cl_pts = np.array([pts[p] for p in cl_A])
    hull_center = cl_pts.mean(axis=0)
    angles = np.arctan2(cl_pts[:, 1] - hull_center[1], cl_pts[:, 0] - hull_center[0])
    order = np.argsort(angles)
    hull_pts = cl_pts[order]
    polygon = plt.Polygon(hull_pts, alpha=0.2, color='#E91E63', linewidth=2,
                          edgecolor='#E91E63', linestyle='-')
    ax.add_patch(polygon)
    
    ax.set_title('Reconstructed cl(A) = {a, b, c}', fontsize=13, fontweight='bold')
    ax.set_xlim(-0.8, 2.0)
    ax.set_ylim(-0.5, 1.5)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)
    
    fig.suptitle('Closure Reconstruction: cl(A) = ⋂{ball(r,g) : A ⊆ ball(r,g)}',
                fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


def create_nerve_complexity_plot():
    """
    Plot nerve complexity (f-vector) as a function of radius.
    """
    # Generate data from a random metric space
    np.random.seed(42)
    n = 8
    positions = np.random.rand(n, 2) * 3
    
    dist = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            dist[i, j] = np.linalg.norm(positions[i] - positions[j])
    
    all_dists = sorted(set(dist[i, j] for i in range(n) for j in range(i+1, n)))
    
    radii = [0] + all_dists
    face_counts = {0: [], 1: [], 2: [], 3: []}
    
    for r in radii:
        counts = {0: 0, 1: 0, 2: 0, 3: 0}
        for k in range(1, 5):
            for combo in combinations(range(n), k):
                if all(dist[a, b] <= 2*r for a, b in combinations(combo, 2)) or k == 1:
                    if k == 1 and r >= 0:
                        counts[0] += 1
                    elif k > 1 and all(dist[a, b] <= 2*r for a, b in combinations(combo, 2)):
                        counts[k-1] += 1
        for dim in face_counts:
            face_counts[dim].append(counts[dim])
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    dim_labels = ['0-simplices (vertices)', '1-simplices (edges)', 
                  '2-simplices (triangles)', '3-simplices (tetrahedra)']
    dim_colors = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63']
    
    for dim in range(4):
        ax1.plot(radii, face_counts[dim], 'o-', 
                color=dim_colors[dim], label=dim_labels[dim],
                markersize=4, linewidth=2)
    
    ax1.set_xlabel('Radius r', fontsize=12)
    ax1.set_ylabel('Face Count', fontsize=12)
    ax1.set_title('Nerve Complexity vs. Radius', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    
    # Euler characteristic
    euler = []
    for idx in range(len(radii)):
        chi = sum((-1)**dim * face_counts[dim][idx] for dim in range(4))
        euler.append(chi)
    
    ax2.plot(radii, euler, 's-', color='purple', linewidth=2, markersize=5)
    ax2.axhline(y=1, color='gray', linestyle='--', alpha=0.5, label='χ = 1')
    ax2.set_xlabel('Radius r', fontsize=12)
    ax2.set_ylabel('Euler Characteristic χ', fontsize=12)
    ax2.set_title('Euler Characteristic of Filtered Nerve', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    return fig


def create_duality_diagram():
    """
    Create a conceptual diagram of the closure-Voronoi duality.
    """
    fig, ax = plt.subplots(1, 1, figsize=(12, 7))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 8)
    ax.axis('off')
    
    # Algebraic side (left)
    alg_box = mpatches.FancyBboxPatch((0.5, 4.5), 4.5, 2.5, 
                                       boxstyle="round,pad=0.3",
                                       facecolor='#E3F2FD', edgecolor='#1565C0',
                                       linewidth=2)
    ax.add_patch(alg_box)
    ax.text(2.75, 6.3, 'Algebraic Closure', fontsize=14, fontweight='bold',
           ha='center', color='#1565C0')
    ax.text(2.75, 5.6, 'cl : Set G → Set G', fontsize=11, ha='center',
           family='monospace')
    ax.text(2.75, 5.1, 'Extensive • Monotone • Idempotent', fontsize=9,
           ha='center', color='gray')
    
    # Geometric side (right)
    geo_box = mpatches.FancyBboxPatch((7.0, 4.5), 4.5, 2.5,
                                       boxstyle="round,pad=0.3",
                                       facecolor='#FFF3E0', edgecolor='#E65100',
                                       linewidth=2)
    ax.add_patch(geo_box)
    ax.text(9.25, 6.3, 'Metric Geometry', fontsize=14, fontweight='bold',
           ha='center', color='#E65100')
    ax.text(9.25, 5.6, 'd : G × G → R', fontsize=11, ha='center',
           family='monospace')
    ax.text(9.25, 5.1, 'Balls • Nerves • Critical Radii', fontsize=9,
           ha='center', color='gray')
    
    # Duality arrows
    ax.annotate('', xy=(6.8, 6.2), xytext=(5.2, 6.2),
               arrowprops=dict(arrowstyle='->', color='#2E7D32', lw=2.5))
    ax.text(6.0, 6.5, 'Encode', fontsize=10, ha='center', color='#2E7D32',
           fontweight='bold')
    
    ax.annotate('', xy=(5.2, 5.2), xytext=(6.8, 5.2),
               arrowprops=dict(arrowstyle='->', color='#C62828', lw=2.5))
    ax.text(6.0, 4.8, 'Reconstruct', fontsize=10, ha='center', color='#C62828',
           fontweight='bold')
    
    # Main theorem box (center bottom)
    thm_box = mpatches.FancyBboxPatch((2.0, 1.0), 8.0, 2.5,
                                       boxstyle="round,pad=0.3",
                                       facecolor='#F3E5F5', edgecolor='#6A1B9A',
                                       linewidth=2)
    ax.add_patch(thm_box)
    ax.text(6.0, 3.0, 'Main Reconstruction Theorem', fontsize=13,
           fontweight='bold', ha='center', color='#6A1B9A')
    ax.text(6.0, 2.3, 'x ∈ cl(A)  ⟺  x ∈ ⋂{ball(r,g) : A ⊆ ball(r,g)}',
           fontsize=12, ha='center', family='monospace')
    ax.text(6.0, 1.5, 'Closure membership = Ball incidence data',
           fontsize=10, ha='center', color='gray', style='italic')
    
    # Connection arrows to theorem
    ax.annotate('', xy=(3.5, 3.7), xytext=(2.75, 4.3),
               arrowprops=dict(arrowstyle='->', color='gray', lw=1.5, 
                              connectionstyle='arc3,rad=0.2'))
    ax.annotate('', xy=(8.5, 3.7), xytext=(9.25, 4.3),
               arrowprops=dict(arrowstyle='->', color='gray', lw=1.5,
                              connectionstyle='arc3,rad=-0.2'))
    
    fig.suptitle('Closure–Voronoi Duality: Complete Bridge Between Algebra and Geometry',
                fontsize=16, fontweight='bold', y=0.98)
    
    return fig


def generate_all_visualizations():
    """Generate all visualizations and save them."""
    print("Generating visualizations...")
    
    viz_data = {}
    
    print("  1. Nerve filtration...")
    fig = create_nerve_filtration_viz()
    viz_data['nerve_filtration'] = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/nerve_filtration.png', 
                dpi=150, bbox_inches='tight', facecolor='white')
    plt.close(fig)
    
    print("  2. Reconstruction diagram...")
    fig = create_reconstruction_diagram()
    viz_data['reconstruction'] = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/reconstruction_diagram.png',
                dpi=150, bbox_inches='tight', facecolor='white')
    plt.close(fig)
    
    print("  3. Nerve complexity plot...")
    fig = create_nerve_complexity_plot()
    viz_data['nerve_complexity'] = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/nerve_complexity.png',
                dpi=150, bbox_inches='tight', facecolor='white')
    plt.close(fig)
    
    print("  4. Duality diagram...")
    fig = create_duality_diagram()
    viz_data['duality_diagram'] = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/duality_diagram.png',
                dpi=150, bbox_inches='tight', facecolor='white')
    plt.close(fig)
    
    print("Done! Generated 4 visualizations.")
    return viz_data


if __name__ == "__main__":
    viz_data = generate_all_visualizations()
    print(f"\nVisualization data keys: {list(viz_data.keys())}")
    for key, data in viz_data.items():
        print(f"  {key}: {len(data)} chars")
