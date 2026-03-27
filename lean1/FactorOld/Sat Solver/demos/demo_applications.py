#!/usr/bin/env python3
"""
Practical Applications of AUO Theory
=======================================

Demonstrates real-world applications derived from the Algorithmic Universal Oracle:

1. Coherence-guided program synthesis
2. Anomaly detection via coherence scoring
3. Multi-task learning with coherence regularization
4. Test case generation via emergent decidability
5. Data deduplication with complexity towers
"""

import zlib
import random
import time
import math
from typing import Callable


# ============================================================
# Application 1: Coherence-Guided Program Synthesis
# ============================================================

def synthesize_function(
    examples: list[tuple[int, int]], 
    max_complexity: int = 5
) -> str:
    """
    Synthesize a function from input-output examples using coherence.
    
    The AUO insight: among all functions consistent with the examples,
    the most coherent one (lowest Kolmogorov complexity) is most likely correct.
    """
    # Candidate function templates (ordered by complexity)
    templates = [
        ("x", lambda x: x),
        ("x + 1", lambda x: x + 1),
        ("x - 1", lambda x: x - 1),
        ("2 * x", lambda x: 2 * x),
        ("x * x", lambda x: x * x),
        ("x + x", lambda x: x + x),
        ("3 * x", lambda x: 3 * x),
        ("x * x + 1", lambda x: x * x + 1),
        ("2 * x + 1", lambda x: 2 * x + 1),
        ("x * (x + 1)", lambda x: x * (x + 1)),
        ("x * (x - 1)", lambda x: x * (x - 1)),
        ("x ** 3", lambda x: x ** 3),
        ("2 ** x", lambda x: 2 ** x if x < 30 else -1),
    ]
    
    # Find all consistent candidates
    consistent = []
    for name, fn in templates:
        try:
            if all(fn(x) == y for x, y in examples):
                # Measure coherence: how compressible is the function's behavior?
                extended = [fn(i) for i in range(20)]
                data = bytes([v % 256 for v in extended])
                complexity = len(zlib.compress(data, level=9))
                consistent.append((name, complexity))
        except (OverflowError, ValueError):
            pass
    
    if not consistent:
        return "NO CONSISTENT FUNCTION FOUND"
    
    # Return the most coherent (lowest complexity) candidate
    consistent.sort(key=lambda x: x[1])
    return consistent[0][0]


def demo_program_synthesis():
    """Demonstrate coherence-guided program synthesis."""
    print("=" * 60)
    print("  APPLICATION 1: Coherence-Guided Program Synthesis")
    print("=" * 60)
    print()
    
    test_cases = [
        ([(1, 2), (2, 4), (3, 6)], "2 * x"),
        ([(0, 0), (1, 1), (2, 4), (3, 9)], "x * x"),
        ([(1, 2), (2, 3), (3, 4)], "x + 1"),
        ([(0, 1), (1, 3), (2, 5), (3, 7)], "2 * x + 1"),
        ([(1, 2), (2, 6), (3, 12)], "x * (x + 1)"),
    ]
    
    print(f"  {'Examples':<35} {'Synthesized':>15} {'Expected':>15} {'Match':>6}")
    print(f"  {'-'*35} {'-'*15} {'-'*15} {'-'*6}")
    
    for examples, expected in test_cases:
        result = synthesize_function(examples)
        match = "✓" if result == expected else "✗"
        ex_str = str(examples)
        if len(ex_str) > 33:
            ex_str = ex_str[:30] + "..."
        print(f"  {ex_str:<35} {result:>15} {expected:>15} {match:>6}")
    
    print()
    print("  The coherence principle selects the simplest consistent function,")
    print("  matching the 'Occam's razor' interpretation of the AUO.")
    print()


# ============================================================
# Application 2: Anomaly Detection via Coherence Scoring
# ============================================================

def coherence_anomaly_score(data_point: bytes, context: bytes) -> float:
    """
    Score how anomalous a data point is relative to its context.
    
    AUO insight: anomalies are points that decrease the coherence
    (increase the complexity) of the overall dataset.
    """
    cx_context = len(zlib.compress(context, level=9))
    cx_with_point = len(zlib.compress(context + data_point, level=9))
    
    # Expected increase for a coherent point
    expected_increase = len(data_point) * len(zlib.compress(data_point, level=9)) / max(len(data_point), 1)
    actual_increase = cx_with_point - cx_context
    
    # Anomaly score: how much worse than expected
    return actual_increase / max(expected_increase, 1)


def demo_anomaly_detection():
    """Demonstrate coherence-based anomaly detection."""
    print("=" * 60)
    print("  APPLICATION 2: Anomaly Detection via Coherence")
    print("=" * 60)
    print()
    
    # Normal data: repeating pattern with slight variations
    random.seed(42)
    normal_data = []
    for i in range(50):
        val = int(50 + 10 * math.sin(i / 5) + random.gauss(0, 2))
        normal_data.append(max(0, min(255, val)))
    
    context = bytes(normal_data)
    
    # Test points: some normal, some anomalous
    test_points = [
        ("Normal (in pattern)", bytes([int(50 + 10 * math.sin(10.2))])),
        ("Normal (slight var)", bytes([55])),
        ("Mild anomaly", bytes([90])),
        ("Strong anomaly", bytes([200])),
        ("Extreme anomaly", bytes([0, 255, 0, 255])),
        ("Pattern break", bytes([50, 50, 50, 255, 50, 50])),
    ]
    
    print(f"  Context: 50 data points from a sinusoidal pattern")
    print()
    print(f"  {'Test Point':<25} {'Score':>8} {'Assessment':<15}")
    print(f"  {'-'*25} {'-'*8} {'-'*15}")
    
    for name, point in test_points:
        score = coherence_anomaly_score(point, context)
        if score < 0.8:
            assessment = "Normal"
        elif score < 1.2:
            assessment = "Suspicious"
        else:
            assessment = "ANOMALY"
        
        bar = '█' * int(min(score, 3) * 10)
        print(f"  {name:<25} {score:8.3f} {assessment:<15} {bar}")
    
    print()
    print("  Higher scores = less coherent with context = more anomalous.")
    print()


# ============================================================
# Application 3: Test Case Generation
# ============================================================

def generate_coherent_tests(
    function: Callable[[int], int],
    num_tests: int = 10,
    input_range: tuple[int, int] = (0, 100)
) -> list[tuple[int, int, float]]:
    """
    Generate test cases that maximize coverage via coherence.
    
    AUO insight: the most informative test cases are those that
    maximize the complexity of the observed behavior — they reveal
    the most about the function's structure.
    """
    tests = []
    tested_inputs = set()
    
    for _ in range(num_tests):
        best_input = None
        best_score = -1
        
        # Sample candidates
        candidates = random.sample(
            [x for x in range(input_range[0], input_range[1]) if x not in tested_inputs],
            min(20, input_range[1] - input_range[0] - len(tested_inputs))
        )
        
        for x in candidates:
            # Compute how much new information this test would add
            y = function(x)
            existing_outputs = bytes([function(t) % 256 for t, _, _ in tests])
            new_outputs = existing_outputs + bytes([y % 256])
            
            if existing_outputs:
                info_gain = (len(zlib.compress(new_outputs, level=9)) - 
                           len(zlib.compress(existing_outputs, level=9)))
            else:
                info_gain = len(zlib.compress(new_outputs, level=9))
            
            if info_gain > best_score:
                best_score = info_gain
                best_input = x
        
        if best_input is not None:
            y = function(best_input)
            tests.append((best_input, y, best_score))
            tested_inputs.add(best_input)
    
    return tests


def demo_test_generation():
    """Demonstrate coherence-guided test generation."""
    print("=" * 60)
    print("  APPLICATION 3: Coherence-Guided Test Generation")
    print("=" * 60)
    print()
    
    # Function under test (with a "bug" at x=42)
    def function_under_test(x: int) -> int:
        if x == 42:
            return -1  # Bug!
        return x * x % 97
    
    random.seed(42)
    tests = generate_coherent_tests(function_under_test, num_tests=15, input_range=(0, 100))
    
    print(f"  Testing f(x) = x² mod 97 (with bug at x=42)")
    print()
    print(f"  {'Input':>6} {'Output':>8} {'Info Gain':>10} {'Note':<20}")
    print(f"  {'-'*6} {'-'*8} {'-'*10} {'-'*20}")
    
    found_bug = False
    for x, y, gain in tests:
        note = ""
        if x == 42:
            note = "← BUG FOUND!"
            found_bug = True
        elif y == 0:
            note = "boundary case"
        print(f"  {x:6d} {y:8d} {gain:10.1f} {note:<20}")
    
    print()
    if found_bug:
        print("  ✓ Coherence-guided testing found the bug!")
    else:
        print("  The coherence heuristic prioritized high-information inputs.")
    print("  Test cases are chosen to maximize new information about f's behavior.")
    print()


# ============================================================
# Application 4: Data Deduplication with Complexity Towers
# ============================================================

def complexity_tower_fingerprint(data: bytes, levels: int = 5) -> tuple[int, ...]:
    """
    Create a multi-level fingerprint using the complexity tower.
    
    Each level captures a different granularity of structure.
    Two data items are "duplicates" if their towers match within tolerance.
    """
    tower = []
    current = data
    for level in range(levels):
        compressed = zlib.compress(current, level=9)
        tower.append(len(compressed))
        # Next level: compress the compressed version (meta-compression)
        current = compressed
    return tuple(tower)


def tower_similarity(t1: tuple[int, ...], t2: tuple[int, ...]) -> float:
    """Compute similarity between two complexity tower fingerprints."""
    if not t1 or not t2:
        return 0.0
    diffs = [abs(a - b) / max(a, b, 1) for a, b in zip(t1, t2)]
    return 1.0 - sum(diffs) / len(diffs)


def demo_deduplication():
    """Demonstrate complexity tower deduplication."""
    print("=" * 60)
    print("  APPLICATION 4: Complexity Tower Deduplication")
    print("=" * 60)
    print()
    
    documents = [
        ("Doc A (original)", b"The quick brown fox jumps over the lazy dog. " * 10),
        ("Doc B (copy)", b"The quick brown fox jumps over the lazy dog. " * 10),
        ("Doc C (modified)", b"The quick brown cat jumps over the lazy dog. " * 10),
        ("Doc D (reordered)", b"Over the lazy dog jumps the quick brown fox. " * 10),
        ("Doc E (different)", b"Lorem ipsum dolor sit amet consectetur. " * 10),
        ("Doc F (random)", bytes(random.Random(42).randbytes(450))),
    ]
    
    # Compute fingerprints
    fingerprints = {}
    for name, data in documents:
        fp = complexity_tower_fingerprint(data)
        fingerprints[name] = fp
    
    # Show similarity matrix
    names = [name for name, _ in documents]
    print(f"  {'':>20}", end="")
    for name in names:
        print(f" {name[:6]:>7}", end="")
    print()
    
    print(f"  {'':>20}", end="")
    for _ in names:
        print(f" {'---':>7}", end="")
    print()
    
    for n1 in names:
        print(f"  {n1:>20}", end="")
        for n2 in names:
            sim = tower_similarity(fingerprints[n1], fingerprints[n2])
            print(f" {sim:7.3f}", end="")
        print()
    
    print()
    print("  Similarity > 0.95 → likely duplicate")
    print("  Similarity > 0.80 → similar content (near-duplicate)")
    print("  The complexity tower captures structure at multiple scales,")
    print("  enabling robust deduplication even with modifications.")
    print()


# ============================================================
# Application 5: Hypothesis Ranking
# ============================================================

def demo_hypothesis_ranking():
    """
    Demonstrate using coherence to rank competing hypotheses.
    
    Given observed data, the AUO framework suggests preferring
    the hypothesis that makes the data maximally coherent.
    """
    print("=" * 60)
    print("  APPLICATION 5: Coherence-Based Hypothesis Ranking")
    print("=" * 60)
    print()
    
    # Observed data: a sequence that could be explained by several hypotheses
    observed = [2, 4, 8, 16, 32, 64, 128, 256]
    
    hypotheses = [
        ("Powers of 2: 2^n", lambda n: 2 ** (n + 1)),
        ("Double previous: a_{n+1} = 2·a_n", lambda n: 2 * (2 ** n) if n > 0 else 2),
        ("Polynomial: 2·4^(n/2)", lambda n: int(2 * 4 ** (n / 2))),
        ("Lookup table (memorize)", lambda n: observed[n] if n < len(observed) else 0),
        ("Linear: 32n - 30", lambda n: 32 * (n + 1) - 30),
    ]
    
    print(f"  Observed: {observed}")
    print()
    print(f"  {'Hypothesis':<35} {'Fits?':>5} {'Coherence':>10} {'Prediction[8]':>13}")
    print(f"  {'-'*35} {'-'*5} {'-'*10} {'-'*13}")
    
    for name, fn in hypotheses:
        # Check if hypothesis fits observed data
        try:
            predicted = [fn(i) for i in range(len(observed))]
            fits = all(p == o for p, o in zip(predicted, observed))
        except Exception:
            fits = False
            predicted = [0] * len(observed)
        
        # Compute coherence of hypothesis
        extended = [fn(i) % 256 for i in range(20)]
        data = bytes(extended)
        coh = 1.0 - len(zlib.compress(data, level=9)) / max(len(data), 1)
        
        # Prediction for next value
        try:
            next_val = fn(len(observed))
        except Exception:
            next_val = "ERROR"
        
        marker = "  ★" if fits and coh > 0.3 else ""
        print(f"  {name:<35} {'Yes' if fits else 'No':>5} {coh:10.4f} {str(next_val):>13}{marker}")
    
    print()
    print("  ★ The most coherent hypothesis that fits the data is preferred.")
    print("  This implements Occam's razor via Kolmogorov complexity.")
    print()


if __name__ == "__main__":
    demo_program_synthesis()
    demo_anomaly_detection()
    demo_test_generation()
    demo_deduplication()
    demo_hypothesis_ranking()
    
    print("=" * 60)
    print("  All application demos complete.")
    print("=" * 60)
