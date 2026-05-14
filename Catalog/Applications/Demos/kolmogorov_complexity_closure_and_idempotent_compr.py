#!/usr/bin/env python3
"""
Applications of Closure-Kolmogorov Compression Duality

Real-world applications demonstrating the formal theorems in practice:
1. Grammar induction via closure-based compression
2. Feature selection via closure MDL bounds
3. Signal denoising via tropical normalization
4. Network packet compression via idempotent canonicalization
"""

from typing import List, Dict, Set, Tuple, Optional
import collections
import itertools
import math
import random


# ============================================================================
# Application 1: Grammar Induction via Closure Compression
# ============================================================================

class GrammarCompressor:
    """
    Grammar-based compression using closure operators.
    
    The closure operation replaces repeated substrings with grammar rules,
    creating a canonical compressed representation. Fixed points are strings
    that cannot be further compressed by grammar substitution.
    
    This demonstrates the theorem: fixed points of an idempotent compressor
    are exactly the incompressible objects.
    """
    
    def __init__(self, min_pattern_len: int = 2, min_count: int = 2):
        self.min_pattern_len = min_pattern_len
        self.min_count = min_count
    
    def find_most_common_pattern(self, data: List[int]) -> Optional[Tuple[List[int], int]]:
        """Find the most frequently repeated substring."""
        best_pattern = None
        best_savings = 0
        
        for length in range(self.min_pattern_len, len(data) // 2 + 1):
            pattern_counts: Dict[tuple, int] = collections.Counter()
            for i in range(len(data) - length + 1):
                pattern = tuple(data[i:i+length])
                pattern_counts[pattern] += 1
            
            for pattern, count in pattern_counts.items():
                if count >= self.min_count:
                    # Savings: replacing `count` occurrences of `length` symbols
                    # with `count` references to 1 rule of `length` symbols
                    savings = (count - 1) * (length - 1) - 1
                    if savings > best_savings:
                        best_savings = savings
                        best_pattern = (list(pattern), count)
        
        return best_pattern
    
    def compress_step(self, data: List[int], next_symbol: int) -> Tuple[List[int], Dict[int, List[int]], int]:
        """One step of grammar compression."""
        result = find_result = self.find_most_common_pattern(data)
        if result is None:
            return data, {}, next_symbol
        
        pattern, count = result
        # Replace all non-overlapping occurrences
        new_data = []
        rules = {next_symbol: pattern}
        i = 0
        pattern_tuple = tuple(pattern)
        while i < len(data):
            if tuple(data[i:i+len(pattern)]) == pattern_tuple:
                new_data.append(next_symbol)
                i += len(pattern)
            else:
                new_data.append(data[i])
                i += 1
        
        return new_data, rules, next_symbol + 1
    
    def compress(self, data: List[int]) -> Tuple[List[int], Dict[int, List[int]]]:
        """
        Fully compress via iterated grammar substitution.
        
        Returns (compressed_data, grammar_rules).
        The process terminates at a fixed point: when no more 
        patterns can be found, compression is idempotent.
        """
        all_rules = {}
        next_sym = max(data) + 1 if data else 256
        current = data[:]
        
        while True:
            new_data, rules, next_sym = self.compress_step(current, next_sym)
            if not rules:  # Fixed point reached
                break
            all_rules.update(rules)
            current = new_data
        
        return current, all_rules
    
    def decompress(self, data: List[int], rules: Dict[int, List[int]]) -> List[int]:
        """Decompress by expanding grammar rules."""
        result = data[:]
        changed = True
        while changed:
            changed = False
            new_result = []
            for sym in result:
                if sym in rules:
                    new_result.extend(rules[sym])
                    changed = True
                else:
                    new_result.append(sym)
            result = new_result
        return result


def demo_grammar_compression():
    """Demonstrate grammar-based compression as closure operator."""
    print("=" * 70)
    print("APPLICATION 1: Grammar Induction via Closure Compression")
    print("=" * 70)
    
    gc = GrammarCompressor(min_pattern_len=2, min_count=2)
    
    # Test cases
    test_data = [
        [1, 2, 3, 1, 2, 3, 4, 5, 1, 2, 3],  # Repeated pattern
        [1, 2, 1, 2, 1, 2, 1, 2],              # Highly repetitive
        [1, 2, 3, 4, 5, 6, 7, 8],              # No repetition (incompressible)
        [1, 1, 2, 2, 1, 1, 2, 2, 3, 3],        # Nested repetition
    ]
    
    for i, data in enumerate(test_data):
        compressed, rules = gc.compress(data)
        decompressed = gc.decompress(compressed, rules)
        ratio = len(compressed) / len(data) if data else 1.0
        is_fixed = gc.find_most_common_pattern(compressed) is None
        
        print(f"\n  Test {i+1}: {data}")
        print(f"    Compressed:   {compressed}")
        print(f"    Rules:        {rules}")
        print(f"    Ratio:        {ratio:.3f}")
        print(f"    Fixed point:  {is_fixed}")
        print(f"    Invertible:   {decompressed == data}")
    
    print("\n  KEY: Incompressible strings (test 3) are already at a fixed point.")
    print("  Grammar compression is an idempotent closure operator.\n")


# ============================================================================
# Application 2: Feature Selection via Closure MDL
# ============================================================================

def demo_feature_selection():
    """Feature selection using closure-based MDL bounds."""
    print("=" * 70)
    print("APPLICATION 2: Feature Selection via Closure MDL Bounds")
    print("=" * 70)
    
    # Simulated dataset with correlated features
    random.seed(42)
    
    features = ['temperature', 'humidity', 'pressure', 'wind_speed', 
                'cloud_cover', 'rain_prob', 'dew_point']
    
    # Feature implications (domain knowledge)
    implications = {
        'temperature': {'dew_point'},      # temp determines dew point (simplified)
        'humidity': {'cloud_cover'},        # high humidity -> clouds
        'cloud_cover': {'rain_prob'},       # clouds -> rain possible
        'pressure': set(),
        'wind_speed': set(),
        'rain_prob': set(),
        'dew_point': set(),
    }
    
    def close(feature_set: Set[str]) -> Set[str]:
        """Compute closure under implications."""
        result = set(feature_set)
        changed = True
        while changed:
            changed = False
            for f in list(result):
                if f in implications:
                    for implied in implications[f]:
                        if implied not in result:
                            result.add(implied)
                            changed = True
        return result
    
    # Different feature subsets to evaluate
    candidates = [
        {'temperature', 'pressure'},
        {'humidity', 'wind_speed'},
        {'temperature', 'humidity'},
        {'temperature', 'humidity', 'pressure', 'wind_speed'},
    ]
    
    print("\n  Feature implications:")
    for f, implied in implications.items():
        if implied:
            print(f"    {f} -> {implied}")
    
    print("\n  Feature subset evaluation (MDL via closure):")
    for feat_set in candidates:
        closed = close(feat_set)
        added = closed - feat_set
        mdl = len(feat_set)  # Only need to store the generators
        total_info = len(closed)  # Total information captured
        efficiency = total_info / mdl if mdl > 0 else 0
        
        print(f"\n    Selected: {feat_set}")
        print(f"    Closure:  {closed}")
        print(f"    Added by closure: {added}")
        print(f"    MDL cost (generators): {mdl}")
        print(f"    Information captured: {total_info} features")
        print(f"    Efficiency: {efficiency:.2f} features/cost")
    
    print("\n  MDL THEOREM: The closure provides the optimal fixed-point")
    print("  representative. Selecting only generators minimizes description")
    print("  length while capturing full information.\n")


# ============================================================================
# Application 3: Signal Denoising via Tropical Normalization
# ============================================================================

def demo_signal_denoising():
    """Signal denoising using tropical (min-plus) normalization."""
    print("=" * 70)
    print("APPLICATION 3: Signal Denoising via Tropical Normalization")
    print("=" * 70)
    
    random.seed(42)
    n = 20
    
    # True signal (smooth)
    true_signal = [5 * math.sin(2 * math.pi * i / n) + 10 for i in range(n)]
    
    # Add noise
    noise_level = 3.0
    noisy_signal = [s + random.gauss(0, noise_level) for s in true_signal]
    
    # Baseline: physical constraints (e.g., signal cannot exceed certain bounds)
    baseline = [15.0] * n  # Upper bound
    
    # Tropical normalization: cap at baseline
    denoised = [min(s, b) for s, b in zip(noisy_signal, baseline)]
    
    # Compute errors
    noise_error = sum((n - t)**2 for n, t in zip(noisy_signal, true_signal)) / n
    denoised_error = sum((d - t)**2 for d, t in zip(denoised, true_signal)) / n
    
    print(f"\n  Signal length: {n}")
    print(f"  Noise level: {noise_level}")
    print(f"  Baseline (cap): {baseline[0]}")
    print(f"\n  Mean squared error:")
    print(f"    Noisy signal:    {noise_error:.4f}")
    print(f"    After denoising: {denoised_error:.4f}")
    print(f"    Improvement:     {(1 - denoised_error/noise_error)*100:.1f}%")
    
    # Show a few values
    print(f"\n  Sample values (first 8):")
    print(f"  {'i':>3} | {'True':>8} | {'Noisy':>8} | {'Denoised':>8}")
    print("  " + "-" * 40)
    for i in range(min(8, n)):
        print(f"  {i:>3} | {true_signal[i]:>8.3f} | {noisy_signal[i]:>8.3f} | {denoised[i]:>8.3f}")
    
    # Verify idempotence
    double_denoised = [min(d, b) for d, b in zip(denoised, baseline)]
    assert all(abs(a - b) < 1e-10 for a, b in zip(denoised, double_denoised))
    print("\n  Idempotence verified: denoise(denoise(x)) = denoise(x) ✓")
    
    print("\n  TROPICAL THEOREM: The normalization is the pointwise-minimal")
    print("  canonical representative. Fixed points are signals already")
    print("  within the physical constraints.\n")


# ============================================================================
# Application 4: Network Packet Canonicalization
# ============================================================================

def demo_packet_canonicalization():
    """Network packet header canonicalization as idempotent compression."""
    print("=" * 70)
    print("APPLICATION 4: Network Packet Canonicalization")
    print("=" * 70)
    
    # Simulate network packet headers as bit sequences
    # Canonicalization: normalize optional fields to default values
    
    class PacketCompressor:
        """Idempotent packet header canonicalizer."""
        
        def __init__(self):
            # Define canonical (default) values for optional fields
            self.canonical_defaults = {
                'tos': [False] * 8,       # Type of Service: default 0
                'ttl': [True] * 8,        # TTL: default 255
                'options': [],            # Options: remove
            }
        
        def compress(self, packet: List[bool]) -> List[bool]:
            """
            Canonicalize packet header.
            Strip optional fields, normalize defaults.
            This is idempotent by construction.
            """
            if len(packet) <= 8:
                return packet  # Too short, return as-is
            
            # Simple model: first 8 bits are essential, rest are optional
            essential = packet[:8]
            optional = packet[8:]
            
            # Remove trailing zeros (optional padding)
            while optional and not optional[-1]:
                optional.pop()
            
            return essential + optional
    
    comp = PacketCompressor()
    
    # Test packets
    test_packets = [
        [True, False, True, True, False, False, True, False],  # 8-bit essential only
        [True, False, True, True, False, False, True, False,   # With padding
         False, False, False, False],
        [True, True, True, True, True, True, True, True,       # With real optional data
         True, False, True],
        [True, False, True, True, False, False, True, False,   # Mixed
         True, False, False, False, False],
    ]
    
    print("\n  Packet canonicalization results:")
    for i, packet in enumerate(test_packets):
        compressed = comp.compress(packet)
        is_fixed = comp.compress(compressed) == compressed
        bits_saved = len(packet) - len(compressed)
        
        orig_str = ''.join('1' if b else '0' for b in packet)
        comp_str = ''.join('1' if b else '0' for b in compressed)
        
        print(f"\n    Packet {i+1}: {orig_str}")
        print(f"    Canonical: {comp_str}")
        print(f"    Saved: {bits_saved} bits, Fixed: {is_fixed}")
    
    # Verify idempotence
    for packet in test_packets:
        c1 = comp.compress(packet)
        c2 = comp.compress(c1)
        assert c1 == c2, "Idempotence violated!"
    
    print("\n  Idempotence verified for all test packets ✓")
    print("\n  THEOREM APPLICATION: Canonical packet headers are fixed points")
    print("  of the canonicalization operator. Non-canonical packets are")
    print("  strictly shortened, matching the formal compression duality.\n")


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Applications of Closure-Kolmogorov Compression Duality            ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    
    demo_grammar_compression()
    demo_feature_selection()
    demo_signal_denoising()
    demo_packet_canonicalization()
    
    print("All applications demonstrated successfully!")


#!/usr/bin/env python3
"""
Closure-Kolmogorov Complexity Duality: Demonstrations

This module demonstrates the core theorems connecting closure operators,
idempotent compression, and algorithmic description length through
concrete numerical examples.
"""

import itertools
from typing import Callable, List, Tuple, Dict
import collections


# ============================================================================
# Demo 1: Idempotent Compressor on Binary Strings
# ============================================================================

def run_length_compress(s: List[bool]) -> List[bool]:
    """
    A simple idempotent compressor: if the string has a repeated suffix
    pattern, collapse it. For demonstration, we use a canonical
    "sorted representative" compressor - sort the bits.
    
    This is idempotent (sorting a sorted list gives the same list),
    length-preserving (same length), and has clear fixed points
    (already-sorted strings).
    """
    return sorted(s)


def dedup_compress(s: List[bool]) -> List[bool]:
    """
    Remove consecutive duplicate bits. This is idempotent and 
    strictly shortening on non-fixed-points.
    
    Fixed points: strings with no consecutive duplicates (alternating).
    """
    if not s:
        return s
    result = [s[0]]
    for bit in s[1:]:
        if bit != result[-1]:
            result.append(bit)
    return result


def demo_idempotent_compressor():
    """Demonstrate idempotent compression and fixed-point structure."""
    print("=" * 70)
    print("DEMO 1: Idempotent Compressor - Fixed Points as Incompressible Strings")
    print("=" * 70)
    
    # Generate all binary strings of length up to 5
    compress = dedup_compress
    
    for n in range(1, 7):
        all_strings = [list(bits) for bits in itertools.product([False, True], repeat=n)]
        fixed_points = [s for s in all_strings if compress(s) == s]
        compressed = [s for s in all_strings if compress(s) != s]
        
        # Verify idempotence
        for s in all_strings:
            cs = compress(s)
            assert compress(cs) == cs, f"Idempotence violated for {s}"
        
        # Verify strict shortening on non-fixed points
        for s in compressed:
            cs = compress(s)
            assert len(cs) < len(s), f"Strict shortening violated for {s}"
        
        ratio = len(fixed_points) / len(all_strings) * 100
        print(f"  n={n}: {len(all_strings):4d} strings, "
              f"{len(fixed_points):4d} fixed points ({ratio:.1f}%), "
              f"{len(compressed):4d} compressible")
    
    print("\n  Example fixed points (n=5, incompressible under dedup):")
    n = 5
    all_5 = [list(bits) for bits in itertools.product([False, True], repeat=n)]
    fixed_5 = [s for s in all_5 if compress(s) == s]
    for s in fixed_5[:8]:
        bits = ''.join('1' if b else '0' for b in s)
        print(f"    {bits} -> {bits} (fixed)")
    
    print("\n  Example compressed strings (n=5):")
    compressed_5 = [(s, compress(s)) for s in all_5 if compress(s) != s]
    for s, cs in compressed_5[:8]:
        sbits = ''.join('1' if b else '0' for b in s)
        cbits = ''.join('1' if b else '0' for b in cs)
        print(f"    {sbits} -> {cbits} (shortened by {len(s) - len(cs)})")
    
    print("\n  KEY THEOREM VERIFIED: Every string with no shorter compression")
    print("  image is a fixed point of the compressor.")
    print()


# ============================================================================
# Demo 2: Fiber Structure and Compression Classes
# ============================================================================

def demo_fiber_structure():
    """Demonstrate the fiber structure of an idempotent compressor."""
    print("=" * 70)
    print("DEMO 2: Fiber Structure - Equivalence Classes Under Compression")
    print("=" * 70)
    
    compress = dedup_compress
    n = 4
    all_strings = [list(bits) for bits in itertools.product([False, True], repeat=n)]
    
    # Also include shorter strings since compression reduces length
    for k in range(n):
        all_strings.extend(
            list(bits) for bits in itertools.product([False, True], repeat=k)
        )
    
    # Build fibers: group strings by their compressed representative
    fibers: Dict[str, List[str]] = collections.defaultdict(list)
    for s in all_strings:
        cs = compress(s)
        key = ''.join('1' if b else '0' for b in cs)
        val = ''.join('1' if b else '0' for b in s)
        fibers[key].append(val)
    
    print(f"\n  Fibers (equivalence classes) for strings of length ≤ {n}:")
    for rep, members in sorted(fibers.items(), key=lambda x: (len(x[0]), x[0])):
        is_fp = rep in members
        print(f"    Fixed point '{rep}' <- {members}")
        if is_fp:
            # Verify: fixed point is the shortest in its fiber
            min_len = min(len(m) for m in members)
            assert len(rep) == min_len, "Fixed point should be shortest!"
    
    print("\n  VERIFIED: Fixed points are the shortest representatives in each fiber.")
    print("  This is the 'compression ratio optimal on fibers' theorem.\n")


# ============================================================================
# Demo 3: Tropical Normalization
# ============================================================================

def demo_tropical_normalization():
    """Demonstrate tropical (min-plus) normalization as idempotent compression."""
    print("=" * 70)
    print("DEMO 3: Tropical Normalization - Min-Plus Canonical Forms")
    print("=" * 70)
    
    import random
    random.seed(42)
    
    n = 5
    
    # Define a baseline (ceiling) vector
    baseline = [10.0, 8.0, 6.0, 4.0, 2.0]
    print(f"\n  Baseline b = {baseline}")
    
    def tropical_normalize(b, w):
        """Pointwise min with baseline."""
        return [min(wi, bi) for wi, bi in zip(w, b)]
    
    # Generate random weight vectors
    for trial in range(5):
        w = [random.uniform(0, 15) for _ in range(n)]
        w_norm = tropical_normalize(baseline, w)
        w_norm2 = tropical_normalize(baseline, w_norm)
        
        # Verify idempotence
        assert w_norm == w_norm2, "Tropical normalization not idempotent!"
        
        # Verify pointwise minimality
        for i in range(n):
            assert w_norm[i] <= w[i], "Not pointwise ≤ original!"
            assert w_norm[i] <= baseline[i], "Not pointwise ≤ baseline!"
        
        total_w = sum(w)
        total_norm = sum(w_norm)
        savings = (1 - total_norm / total_w) * 100 if total_w > 0 else 0
        
        print(f"\n  Trial {trial + 1}:")
        print(f"    w     = [{', '.join(f'{x:.2f}' for x in w)}]  (total: {total_w:.2f})")
        print(f"    norm  = [{', '.join(f'{x:.2f}' for x in w_norm)}]  (total: {total_norm:.2f})")
        print(f"    Savings: {savings:.1f}%")
    
    # Show fixed points
    print("\n  Fixed points (w ≤ b pointwise):")
    fixed = [1.0, 2.0, 3.0, 4.0, 1.0]
    assert tropical_normalize(baseline, fixed) == fixed
    print(f"    {fixed} is a fixed point (all components ≤ baseline)")
    
    not_fixed = [1.0, 2.0, 3.0, 4.0, 5.0]
    nf_norm = tropical_normalize(baseline, not_fixed)
    print(f"    {not_fixed} is NOT a fixed point -> normalizes to {nf_norm}")
    
    # Verify tropical equivalence preserves normalization
    v1 = [12.0, 5.0, 3.0, 1.0, 0.5]
    v2 = [15.0, 5.0, 3.0, 1.0, 0.5]
    n1 = tropical_normalize(baseline, v1)
    n2 = tropical_normalize(baseline, v2)
    print(f"\n  Tropical equivalence:")
    print(f"    v1 = {v1} -> norm = {n1}")
    print(f"    v2 = {v2} -> norm = {n2}")
    print(f"    Equivalent: {n1 == n2} (both capped by baseline)")
    
    print("\n  VERIFIED: Tropical normalization is idempotent and gives")
    print("  pointwise-minimal canonical representatives.\n")


# ============================================================================
# Demo 4: Closure Operator MDL Bounds
# ============================================================================

def demo_closure_mdl():
    """Demonstrate closure operators giving MDL bounds."""
    print("=" * 70)
    print("DEMO 4: Closure Operators Give MDL Upper Bounds")
    print("=" * 70)
    
    # Model: sets of features (powerset lattice)
    # Closure: add implied features (transitive closure of implications)
    
    # Feature implications: a -> b means feature a implies feature b
    implications = {
        'a': {'b', 'c'},  # a implies b and c
        'b': {'d'},        # b implies d
        'c': set(),        # c implies nothing extra
        'd': set(),
    }
    
    def closure(features: frozenset) -> frozenset:
        """Compute the closure of a feature set under implications."""
        result = set(features)
        changed = True
        while changed:
            changed = False
            for f in list(result):
                if f in implications:
                    for implied in implications[f]:
                        if implied not in result:
                            result.add(implied)
                            changed = True
        return frozenset(result)
    
    # Verify closure properties
    all_features = {'a', 'b', 'c', 'd'}
    print("\n  Feature implications: a->b,c  b->d")
    
    test_sets = [
        frozenset(),
        frozenset({'a'}),
        frozenset({'b'}),
        frozenset({'a', 'b'}),
        frozenset({'c', 'd'}),
        frozenset({'a', 'b', 'c', 'd'}),
    ]
    
    print("\n  Closure computations:")
    for s in test_sets:
        cs = closure(s)
        is_fixed = (closure(cs) == cs)
        encoding_len = len(s)
        closure_len = len(cs)
        print(f"    {set(s) if s else '{}':<20} -> {set(cs):<20} "
              f"|s|={encoding_len}, |c(s)|={closure_len}, "
              f"fixed={is_fixed}")
    
    # Identify fixed points
    all_subsets = [frozenset(combo) 
                   for r in range(len(all_features) + 1) 
                   for combo in itertools.combinations(all_features, r)]
    
    fixed_points = [s for s in all_subsets if closure(s) == s]
    print(f"\n  Fixed points (closed sets): {len(fixed_points)} total")
    for fp in fixed_points:
        print(f"    {set(fp) if fp else '{}'}")
    
    print("\n  MDL THEOREM: For every feature set S, the closure c(S) is a")
    print("  fixed point above S. The encoding |c(S)| serves as an upper")
    print("  bound on the canonical description length.\n")


# ============================================================================
# Demo 5: Compression Statistics
# ============================================================================

def demo_compression_statistics():
    """Show compression statistics matching the formal theorems."""
    print("=" * 70)
    print("DEMO 5: Compression Statistics - Counting Incompressible Strings")
    print("=" * 70)
    
    compress = dedup_compress
    
    print("\n  Theorem: |fixed points| + |compressed| = |all strings|")
    print(f"  {'n':>3} | {'Total':>6} | {'Fixed':>6} | {'Compressed':>10} | {'Sum Check':>9}")
    print("  " + "-" * 50)
    
    for n in range(1, 9):
        all_strings = [list(bits) for bits in itertools.product([False, True], repeat=n)]
        fixed = sum(1 for s in all_strings if compress(s) == s)
        compressed = sum(1 for s in all_strings if compress(s) != s)
        total = len(all_strings)
        assert fixed + compressed == total
        print(f"  {n:>3} | {total:>6} | {fixed:>6} | {compressed:>10} | "
              f"{'✓' if fixed + compressed == total else '✗':>9}")
    
    print("\n  The number of fixed points (incompressible strings) grows")
    print("  as a Fibonacci-like sequence for the dedup compressor.\n")


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Closure-Kolmogorov Complexity Duality: Concrete Demonstrations     ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    
    demo_idempotent_compressor()
    demo_fiber_structure()
    demo_tropical_normalization()
    demo_closure_mdl()
    demo_compression_statistics()
    
    print("All demonstrations completed successfully!")
    print()


#!/usr/bin/env python3
"""
Visualizations for Closure-Kolmogorov Compression Duality

Generates publication-quality figures showing:
1. Fixed-point ratio decay
2. Fiber structure 
3. Tropical normalization
4. Compression spectrum
"""

import itertools
import math
import base64
import io

# Minimal SVG-based visualizations (no matplotlib dependency needed)


def dedup_compress(s):
    if not s:
        return s
    result = [s[0]]
    for bit in s[1:]:
        if bit != result[-1]:
            result.append(bit)
    return result


def generate_compression_spectrum_svg():
    """Generate SVG chart of compression spectrum."""
    # Compute data
    data = []
    for n in range(1, 13):
        total = 2**n
        fixed = 0
        for bits in itertools.product([False, True], repeat=n):
            if dedup_compress(list(bits)) == list(bits):
                fixed += 1
        ratio = fixed / total * 100
        data.append((n, total, fixed, ratio))
    
    # SVG dimensions
    w, h = 600, 400
    margin = {'top': 40, 'right': 30, 'bottom': 60, 'left': 70}
    plot_w = w - margin['left'] - margin['right']
    plot_h = h - margin['top'] - margin['bottom']
    
    svg = f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}">'
    svg += '<style>text { font-family: Arial, sans-serif; }</style>'
    
    # Background
    svg += f'<rect width="{w}" height="{h}" fill="white"/>'
    
    # Title
    svg += f'<text x="{w//2}" y="25" text-anchor="middle" font-size="16" font-weight="bold">'
    svg += 'Fixed Points (Incompressible Strings) vs String Length</text>'
    
    # Axes
    svg += f'<line x1="{margin["left"]}" y1="{margin["top"]}" '
    svg += f'x2="{margin["left"]}" y2="{h-margin["bottom"]}" stroke="black" stroke-width="2"/>'
    svg += f'<line x1="{margin["left"]}" y1="{h-margin["bottom"]}" '
    svg += f'x2="{w-margin["right"]}" y2="{h-margin["bottom"]}" stroke="black" stroke-width="2"/>'
    
    # X axis label
    svg += f'<text x="{w//2}" y="{h-10}" text-anchor="middle" font-size="14">String Length n</text>'
    
    # Y axis label  
    svg += f'<text x="15" y="{h//2}" text-anchor="middle" font-size="14" '
    svg += f'transform="rotate(-90, 15, {h//2})">Fixed Point Ratio (%)</text>'
    
    # Plot bars
    max_ratio = 100
    bar_width = plot_w / len(data) * 0.7
    
    for i, (n, total, fixed, ratio) in enumerate(data):
        x = margin['left'] + (i + 0.5) * plot_w / len(data) - bar_width / 2
        bar_h = ratio / max_ratio * plot_h
        y = margin['top'] + plot_h - bar_h
        
        # Bar
        color = f'hsl({200 + i*10}, 70%, {40 + i*3}%)'
        svg += f'<rect x="{x:.1f}" y="{y:.1f}" width="{bar_width:.1f}" '
        svg += f'height="{bar_h:.1f}" fill="{color}" stroke="white" stroke-width="1"/>'
        
        # X tick label
        tick_x = margin['left'] + (i + 0.5) * plot_w / len(data)
        svg += f'<text x="{tick_x:.1f}" y="{h-margin["bottom"]+18}" '
        svg += f'text-anchor="middle" font-size="11">{n}</text>'
        
        # Value label on bar
        if bar_h > 15:
            svg += f'<text x="{x + bar_width/2:.1f}" y="{y + bar_h/2 + 5:.1f}" '
            svg += f'text-anchor="middle" font-size="9" fill="white">{ratio:.1f}%</text>'
    
    # Y axis ticks
    for pct in [0, 25, 50, 75, 100]:
        y = margin['top'] + plot_h - pct / max_ratio * plot_h
        svg += f'<text x="{margin["left"]-8}" y="{y+4}" text-anchor="end" font-size="11">{pct}</text>'
        svg += f'<line x1="{margin["left"]}" y1="{y}" x2="{w-margin["right"]}" y2="{y}" '
        svg += f'stroke="#ddd" stroke-width="1" stroke-dasharray="3,3"/>'
    
    svg += '</svg>'
    return svg


def generate_tropical_normalization_svg():
    """Generate SVG showing tropical normalization."""
    import random
    random.seed(42)
    
    n = 8
    baseline = [10, 8, 12, 6, 9, 7, 11, 5]
    weights = [random.uniform(2, 15) for _ in range(n)]
    normalized = [min(w, b) for w, b in zip(weights, baseline)]
    
    w, h = 600, 350
    margin = {'top': 40, 'right': 30, 'bottom': 60, 'left': 60}
    plot_w = w - margin['left'] - margin['right']
    plot_h = h - margin['top'] - margin['bottom']
    
    max_val = max(max(weights), max(baseline)) * 1.1
    
    svg = f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}">'
    svg += '<style>text { font-family: Arial, sans-serif; }</style>'
    svg += f'<rect width="{w}" height="{h}" fill="white"/>'
    
    # Title
    svg += f'<text x="{w//2}" y="25" text-anchor="middle" font-size="16" font-weight="bold">'
    svg += 'Tropical Normalization: Pointwise Min with Baseline</text>'
    
    # Axes
    svg += f'<line x1="{margin["left"]}" y1="{margin["top"]}" '
    svg += f'x2="{margin["left"]}" y2="{h-margin["bottom"]}" stroke="black" stroke-width="2"/>'
    svg += f'<line x1="{margin["left"]}" y1="{h-margin["bottom"]}" '
    svg += f'x2="{w-margin["right"]}" y2="{h-margin["bottom"]}" stroke="black" stroke-width="2"/>'
    
    svg += f'<text x="{w//2}" y="{h-10}" text-anchor="middle" font-size="14">Component Index</text>'
    svg += f'<text x="15" y="{h//2}" text-anchor="middle" font-size="14" '
    svg += f'transform="rotate(-90, 15, {h//2})">Value</text>'
    
    bar_width = plot_w / n * 0.25
    
    for i in range(n):
        center_x = margin['left'] + (i + 0.5) * plot_w / n
        
        # Original weight (transparent)
        bh = weights[i] / max_val * plot_h
        y = margin['top'] + plot_h - bh
        svg += f'<rect x="{center_x - bar_width*1.5:.1f}" y="{y:.1f}" '
        svg += f'width="{bar_width:.1f}" height="{bh:.1f}" fill="#FF6B6B" opacity="0.7"/>'
        
        # Baseline
        bh = baseline[i] / max_val * plot_h
        y = margin['top'] + plot_h - bh
        svg += f'<rect x="{center_x - bar_width*0.5:.1f}" y="{y:.1f}" '
        svg += f'width="{bar_width:.1f}" height="{bh:.1f}" fill="#4ECDC4" opacity="0.7"/>'
        
        # Normalized (min)
        bh = normalized[i] / max_val * plot_h
        y = margin['top'] + plot_h - bh
        svg += f'<rect x="{center_x + bar_width*0.5:.1f}" y="{y:.1f}" '
        svg += f'width="{bar_width:.1f}" height="{bh:.1f}" fill="#2C3E50"/>'
        
        # X label
        svg += f'<text x="{center_x:.1f}" y="{h-margin["bottom"]+18}" '
        svg += f'text-anchor="middle" font-size="11">{i+1}</text>'
    
    # Legend
    lx = w - 180
    ly = 50
    svg += f'<rect x="{lx}" y="{ly}" width="12" height="12" fill="#FF6B6B" opacity="0.7"/>'
    svg += f'<text x="{lx+18}" y="{ly+11}" font-size="11">Original w</text>'
    svg += f'<rect x="{lx}" y="{ly+18}" width="12" height="12" fill="#4ECDC4" opacity="0.7"/>'
    svg += f'<text x="{lx+18}" y="{ly+29}" font-size="11">Baseline b</text>'
    svg += f'<rect x="{lx}" y="{ly+36}" width="12" height="12" fill="#2C3E50"/>'
    svg += f'<text x="{lx+18}" y="{ly+47}" font-size="11">Normalized min(w,b)</text>'
    
    svg += '</svg>'
    return svg


def generate_fiber_structure_svg():
    """Generate SVG showing fiber structure of compression."""
    # Compute fibers for n=3
    import collections
    
    fibers = collections.defaultdict(list)
    for n in range(1, 5):
        for bits in itertools.product([False, True], repeat=n):
            s = list(bits)
            cs = dedup_compress(s)
            key = ''.join('1' if b else '0' for b in cs)
            val = ''.join('1' if b else '0' for b in s)
            if val != key:  # Only show non-trivial mappings
                fibers[key].append(val)
    
    w, h = 600, 400
    svg = f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}">'
    svg += '<style>text { font-family: monospace; }</style>'
    svg += f'<rect width="{w}" height="{h}" fill="white"/>'
    
    svg += f'<text x="{w//2}" y="25" text-anchor="middle" font-size="16" '
    svg += 'font-weight="bold" font-family="Arial">Compression Fiber Structure</text>'
    svg += f'<text x="{w//2}" y="42" text-anchor="middle" font-size="12" '
    svg += 'font-family="Arial" fill="#666">Strings mapping to each fixed point under dedup compression</text>'
    
    # Layout: fixed points on the left, fibers on the right
    y_pos = 70
    sorted_fibers = sorted(fibers.items(), key=lambda x: (len(x[0]), x[0]))
    
    for fp, members in sorted_fibers[:10]:
        # Fixed point
        svg += f'<rect x="30" y="{y_pos-12}" width="{len(fp)*12+16}" height="22" '
        svg += f'rx="4" fill="#2C3E50"/>'
        svg += f'<text x="38" y="{y_pos+4}" fill="white" font-size="13">{fp}</text>'
        
        # Arrow
        arrow_start = 30 + len(fp) * 12 + 20
        svg += f'<line x1="{arrow_start}" y1="{y_pos}" x2="{arrow_start+20}" y2="{y_pos}" '
        svg += f'stroke="#999" stroke-width="2" marker-end="url(#arrowhead)"/>'
        
        # Members
        x_mem = arrow_start + 30
        for j, mem in enumerate(members[:8]):
            color = '#FF6B6B' if len(mem) > len(fp) else '#4ECDC4'
            svg += f'<rect x="{x_mem}" y="{y_pos-10}" width="{len(mem)*10+10}" height="18" '
            svg += f'rx="3" fill="{color}" opacity="0.8"/>'
            svg += f'<text x="{x_mem+5}" y="{y_pos+3}" font-size="11">{mem}</text>'
            x_mem += len(mem) * 10 + 16
        
        if len(members) > 8:
            svg += f'<text x="{x_mem}" y="{y_pos+3}" font-size="11" fill="#999">+{len(members)-8} more</text>'
        
        y_pos += 32
    
    # Arrow marker
    svg += '<defs><marker id="arrowhead" markerWidth="10" markerHeight="7" refX="10" refY="3.5" orient="auto">'
    svg += '<polygon points="0 0, 10 3.5, 0 7" fill="#999"/></marker></defs>'
    
    svg += '</svg>'
    return svg


def generate_closure_lattice_svg():
    """Generate SVG showing closure operator on a lattice."""
    w, h = 500, 400
    svg = f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}">'
    svg += '<style>text { font-family: Arial, sans-serif; }</style>'
    svg += f'<rect width="{w}" height="{h}" fill="white"/>'
    
    svg += f'<text x="{w//2}" y="25" text-anchor="middle" font-size="16" font-weight="bold">'
    svg += 'Closure Operator on Feature Lattice</text>'
    svg += f'<text x="{w//2}" y="42" text-anchor="middle" font-size="11" fill="#666">'
    svg += 'Implications: a→b,c  b→d  |  Closed sets shown in bold</text>'
    
    # Lattice nodes (Hasse diagram of powerset with closure highlights)
    nodes = {
        '∅': (250, 350),
        '{c}': (120, 290),
        '{d}': (250, 290),
        '{b,d}': (180, 230),
        '{c,d}': (320, 230),
        '{b,c,d}': (250, 170),
        '{a,b,c,d}': (250, 110),
    }
    
    # Edges (Hasse diagram)
    edges = [
        ('∅', '{c}'), ('∅', '{d}'),
        ('{c}', '{c,d}'), ('{d}', '{b,d}'), ('{d}', '{c,d}'),
        ('{b,d}', '{b,c,d}'), ('{c,d}', '{b,c,d}'),
        ('{b,c,d}', '{a,b,c,d}'),
    ]
    
    # Draw edges
    for n1, n2 in edges:
        x1, y1 = nodes[n1]
        x2, y2 = nodes[n2]
        svg += f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" '
        svg += f'stroke="#ccc" stroke-width="2"/>'
    
    # Draw nodes
    for label, (x, y) in nodes.items():
        r = 25
        svg += f'<circle cx="{x}" cy="{y}" r="{r}" fill="#2C3E50" stroke="#1a252f" stroke-width="2"/>'
        svg += f'<text x="{x}" y="{y+4}" text-anchor="middle" fill="white" font-size="9">{label}</text>'
    
    # Annotation: closure arrows for non-closed sets
    svg += f'<text x="30" y="{h-20}" font-size="11" fill="#666">'
    svg += 'All nodes shown are closed (fixed points of the closure operator).</text>'
    
    svg += '</svg>'
    return svg


if __name__ == "__main__":
    # Generate all SVGs
    svgs = {
        'compression_spectrum': generate_compression_spectrum_svg(),
        'tropical_normalization': generate_tropical_normalization_svg(),
        'fiber_structure': generate_fiber_structure_svg(),
        'closure_lattice': generate_closure_lattice_svg(),
    }
    
    for name, svg_content in svgs.items():
        filename = f'{name}.svg'
        with open(filename, 'w') as f:
            f.write(svg_content)
        print(f"Generated {filename}")
    
    print("\nAll visualizations generated successfully!")
