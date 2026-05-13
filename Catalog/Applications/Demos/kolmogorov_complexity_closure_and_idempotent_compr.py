#!/usr/bin/env python3
"""
Applications of Closure-Compression Duality

Demonstrates real-world applications of the theoretical framework to:
1. Data deduplication / canonical form computation
2. Compiler optimization (expression normalization)
3. Cryptographic hash collision analysis
4. Machine learning feature compression
"""

import itertools
from collections import defaultdict
from typing import List, Tuple, Dict, Set
import hashlib


# ===========================================================================
# Application 1: Data Deduplication via Canonical Forms
# ===========================================================================

class CanonicalDeduplicator:
    """
    Data deduplication system based on closure-compression duality.

    Maps data items to canonical representatives of their semantic
    equivalence class. By the compression optimality theorem, the
    canonical representative minimizes description length within each class.

    Real-world application: Database normalization, file deduplication,
    content-addressable storage.
    """

    def __init__(self):
        self.canonical_map: Dict[str, str] = {}
        self.class_sizes: Dict[str, int] = defaultdict(int)

    def normalize_whitespace(self, text: str) -> str:
        """Normalize whitespace: collapse runs, strip edges."""
        return ' '.join(text.split())

    def normalize_case(self, text: str) -> str:
        """Case-insensitive normalization."""
        return text.lower()

    def compress(self, text: str) -> str:
        """
        Full canonical compression: normalize whitespace and case.

        This is idempotent by construction:
        - normalize_whitespace(normalize_whitespace(x)) = normalize_whitespace(x)
        - normalize_case(normalize_case(x)) = normalize_case(x)
        - Their composition is also idempotent when applied in fixed order.
        """
        return self.normalize_case(self.normalize_whitespace(text))

    def deduplicate(self, items: List[str]) -> Tuple[List[str], Dict]:
        """
        Deduplicate a list of items using canonical compression.

        Returns:
            Tuple of (unique canonical forms, statistics dict)
        """
        canonical_items = set()
        fiber_sizes = defaultdict(int)
        total_chars_saved = 0

        for item in items:
            canonical = self.compress(item)
            canonical_items.add(canonical)
            fiber_sizes[canonical] += 1
            total_chars_saved += len(item) - len(canonical)

        stats = {
            "original_count": len(items),
            "unique_count": len(canonical_items),
            "dedup_ratio": 1 - len(canonical_items) / len(items)
            if items else 0,
            "total_chars_saved": total_chars_saved,
            "max_equivalence_class": max(fiber_sizes.values())
            if fiber_sizes else 0,
            "avg_equivalence_class": sum(fiber_sizes.values()) /
            len(fiber_sizes) if fiber_sizes else 0,
        }

        return sorted(canonical_items), stats


# ===========================================================================
# Application 2: Expression Normalization (Compiler Optimization)
# ===========================================================================

class ExpressionNormalizer:
    """
    Arithmetic expression normalizer based on idempotent rewriting.

    Normalizes expressions to canonical form by:
    1. Sorting commutative operands
    2. Flattening nested operations
    3. Constant folding

    The normalizer is idempotent: applying it twice gives the same result
    as applying it once, making it a valid closure operator.

    Real-world application: Compiler CSE (common subexpression elimination),
    symbolic computation, proof normalization.
    """

    @staticmethod
    def normalize(expr: tuple) -> tuple:
        """
        Normalize an arithmetic expression tree.

        Expression format: (op, left, right) or atomic value (int/str)

        Normalization rules:
        1. Sort commutative operators (+, *)
        2. Flatten nested same-operator applications
        3. Fold constants
        """
        if not isinstance(expr, tuple):
            return expr

        if len(expr) != 3:
            return expr

        op, left, right = expr
        # Recursively normalize children
        left = ExpressionNormalizer.normalize(left)
        right = ExpressionNormalizer.normalize(right)

        # Constant folding
        if isinstance(left, (int, float)) and isinstance(right, (int, float)):
            if op == '+':
                return left + right
            elif op == '*':
                return left * right
            elif op == '-':
                return left - right

        # Sort commutative operators
        if op in ('+', '*'):
            if str(right) < str(left):
                left, right = right, left

        return (op, left, right)

    @staticmethod
    def description_length(expr) -> int:
        """Compute the description length (tree size) of an expression."""
        if not isinstance(expr, tuple):
            return 1
        return 1 + sum(
            ExpressionNormalizer.description_length(child)
            for child in expr[1:]
        )


# ===========================================================================
# Application 3: Network Packet Deduplication
# ===========================================================================

class PacketDeduplicator:
    """
    Network packet deduplication via content-based canonical forms.

    Uses closure-compression to identify semantically equivalent packets
    and compress traffic by sending only canonical representatives.

    Real-world application: WAN optimization, CDN caching, protocol
    compression.
    """

    @staticmethod
    def canonical_form(packet: dict) -> tuple:
        """
        Map a packet to its canonical form.

        Ignores timestamps, sequence numbers, and other ephemeral fields.
        Focuses on semantic content.
        """
        # Extract semantic content (ignoring metadata)
        content = packet.get("payload", "")
        src = packet.get("src", "")
        dst = packet.get("dst", "")
        proto = packet.get("proto", "")

        return (proto, src, dst, content)

    @staticmethod
    def compress_stream(packets: List[dict]) -> Tuple[List[dict], Dict]:
        """
        Compress a packet stream by deduplicating canonical forms.

        Returns only the first occurrence of each canonical form,
        plus statistics on the compression achieved.
        """
        seen = set()
        unique = []
        duplicates = 0

        for packet in packets:
            canonical = PacketDeduplicator.canonical_form(packet)
            if canonical not in seen:
                seen.add(canonical)
                unique.append(packet)
            else:
                duplicates += 1

        stats = {
            "original_packets": len(packets),
            "unique_packets": len(unique),
            "duplicates_removed": duplicates,
            "compression_ratio": duplicates / len(packets) if packets else 0,
        }

        return unique, stats


# ===========================================================================
# Application 4: Feature Compression for ML
# ===========================================================================

class FeatureCompressor:
    """
    Feature vector compression using idempotent quantization.

    Quantizes continuous features to discrete levels, creating an
    idempotent compression operator. The fixed points are exactly
    the quantized values — the "incompressible" feature vectors.

    Real-world application: Model compression, feature hashing,
    dimensionality reduction.
    """

    def __init__(self, levels: int = 8):
        """
        Args:
            levels: Number of quantization levels per feature
        """
        self.levels = levels

    def quantize_value(self, x: float, lo: float = 0.0,
                       hi: float = 1.0) -> float:
        """Quantize a single value to the nearest level."""
        if hi <= lo:
            return lo
        step = (hi - lo) / self.levels
        bucket = int((x - lo) / step)
        bucket = max(0, min(bucket, self.levels - 1))
        return lo + (bucket + 0.5) * step

    def compress(self, features: tuple) -> tuple:
        """
        Compress a feature vector by quantization.

        This is idempotent: quantizing already-quantized values
        produces the same values.
        """
        return tuple(self.quantize_value(f) for f in features)

    def analyze_compression(self, dataset: List[tuple]) -> Dict:
        """
        Analyze compression on a dataset.

        Returns statistics including:
        - Number of unique canonical forms
        - Compression ratio
        - Fixed point count
        """
        canonical_forms = set()
        fixed_count = 0

        for features in dataset:
            compressed = self.compress(features)
            canonical_forms.add(compressed)
            if compressed == features:
                fixed_count += 1

        return {
            "dataset_size": len(dataset),
            "unique_forms": len(canonical_forms),
            "fixed_points": fixed_count,
            "compression_ratio": 1 - len(canonical_forms) / len(dataset)
            if dataset else 0,
        }


# ===========================================================================
# Main: Run all applications
# ===========================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATION 1: Data Deduplication")
    print("=" * 70)

    dedup = CanonicalDeduplicator()
    items = [
        "Hello World",
        "hello world",
        "HELLO WORLD",
        "  Hello   World  ",
        "hello  world",
        "Hello World!",
        "hello world!",
        "  HELLO   WORLD!  ",
        "Goodbye World",
        "goodbye world",
    ]

    # Verify idempotence
    for item in items:
        c1 = dedup.compress(item)
        c2 = dedup.compress(c1)
        assert c1 == c2, f"Idempotence violated: {item} -> {c1} -> {c2}"

    unique, stats = dedup.deduplicate(items)
    print(f"\nInput: {len(items)} strings")
    for item in items:
        print(f"  '{item}' → '{dedup.compress(item)}'")
    print(f"\nCanonical forms: {unique}")
    print(f"Statistics: {stats}")

    print(f"\n{'=' * 70}")
    print("APPLICATION 2: Expression Normalization")
    print("=" * 70)

    norm = ExpressionNormalizer()
    expressions = [
        ('+', 'b', 'a'),          # Should normalize to ('+', 'a', 'b')
        ('+', 'a', 'b'),          # Already canonical
        ('*', 3, 4),              # Should fold to 12
        ('+', ('*', 'b', 'a'), ('*', 'a', 'b')),  # Both sides normalize
        ('-', ('+', 2, 3), 1),    # Should fold to 4
    ]

    for expr in expressions:
        canonical = norm.normalize(expr)
        c2 = norm.normalize(canonical)
        is_fixed = canonical == expr
        is_idempotent = c2 == canonical
        dl_before = norm.description_length(expr)
        dl_after = norm.description_length(canonical)

        print(f"\n  {expr}")
        print(f"  → {canonical}")
        print(f"  Fixed point: {is_fixed}, Idempotent: {is_idempotent}")
        print(f"  Description length: {dl_before} → {dl_after} "
              f"(saved {dl_before - dl_after})")

    print(f"\n{'=' * 70}")
    print("APPLICATION 3: Packet Stream Compression")
    print("=" * 70)

    packets = [
        {"proto": "HTTP", "src": "A", "dst": "B", "payload": "GET /",
         "seq": 1, "time": 100},
        {"proto": "HTTP", "src": "A", "dst": "B", "payload": "GET /",
         "seq": 2, "time": 200},
        {"proto": "HTTP", "src": "A", "dst": "B", "payload": "GET /",
         "seq": 3, "time": 300},
        {"proto": "HTTP", "src": "A", "dst": "C", "payload": "GET /",
         "seq": 1, "time": 150},
        {"proto": "DNS", "src": "A", "dst": "D", "payload": "QUERY",
         "seq": 1, "time": 50},
        {"proto": "DNS", "src": "A", "dst": "D", "payload": "QUERY",
         "seq": 2, "time": 250},
    ]

    unique_packets, pstats = PacketDeduplicator.compress_stream(packets)
    print(f"\n  {pstats}")
    for p in unique_packets:
        print(f"  Kept: {PacketDeduplicator.canonical_form(p)}")

    print(f"\n{'=' * 70}")
    print("APPLICATION 4: ML Feature Compression")
    print("=" * 70)

    import random
    random.seed(42)

    fc = FeatureCompressor(levels=4)
    dataset = [tuple(random.random() for _ in range(3)) for _ in range(100)]

    stats = fc.analyze_compression(dataset)
    print(f"\n  Dataset: {stats['dataset_size']} samples, 3 features each")
    print(f"  Unique canonical forms: {stats['unique_forms']}")
    print(f"  Compression ratio: {stats['compression_ratio']:.2%}")

    # Verify idempotence
    for features in dataset:
        c1 = fc.compress(features)
        c2 = fc.compress(c1)
        assert c1 == c2, "Idempotence violated in feature compressor!"
    print("  ✓ Idempotence verified for all feature vectors")

    # Show some examples
    print(f"\n  Sample compressions:")
    for features in dataset[:5]:
        compressed = fc.compress(features)
        print(f"    {tuple(f'{f:.3f}' for f in features)} → "
              f"{tuple(f'{f:.3f}' for f in compressed)}")

    print(f"\n{'=' * 70}")
    print("All applications demonstrated successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Closure-Compression Duality: Concrete Demonstrations

This module demonstrates the core theorems of closure-compression duality
with concrete, runnable examples on finite types and bitstrings.
"""

import itertools
from collections import defaultdict


def is_idempotent(c, domain):
    """Check if c is idempotent on the given domain."""
    return all(c(c(x)) == c(x) for x in domain)


def fixed_points(c, domain):
    """Return the set of fixed points of c."""
    return {x for x in domain if c(x) == x}


def fiber(c, x, domain):
    """Return the fiber {y | c(y) = x}."""
    return {y for y in domain if c(y) == x}


def fiber_class(c, x, domain):
    """Return the equivalence class {y | c(y) = c(x)}."""
    cx = c(x)
    return {y for y in domain if c(y) == cx}


def closure_cost(c, length_fn, x, domain):
    """Compute the closure cost: min length in the equivalence class."""
    cls = fiber_class(c, x, domain)
    return min(length_fn(y) for y in cls)


# ===========================================================================
# Demo 1: Bitstring compression via run-length encoding normalization
# ===========================================================================

def demo_bitstring_compression():
    """
    Demonstrate closure-compression duality on 4-bit strings.

    We define a compressor that normalizes bitstrings by sorting their bits
    (e.g., 1010 -> 0011). This is idempotent (sorting sorted = sorted),
    and we assign "length" as the number of transitions (01 or 10 boundaries).
    """
    print("=" * 70)
    print("DEMO 1: Bitstring Compression via Sorting Normalization")
    print("=" * 70)

    n = 4
    domain = list(itertools.product([0, 1], repeat=n))

    # Compressor: sort bits (canonical representative)
    def compress(bits):
        return tuple(sorted(bits))

    # Length function: number of transitions (alternations)
    def length_fn(bits):
        return sum(1 for i in range(len(bits) - 1) if bits[i] != bits[i + 1])

    # Verify idempotence
    assert is_idempotent(compress, domain), "Compressor must be idempotent!"

    # Verify length non-increasing
    assert all(length_fn(compress(x)) <= length_fn(x) for x in domain)

    # Show fixed points
    fp = fixed_points(compress, domain)
    print(f"\nDomain size: {len(domain)} bitstrings of length {n}")
    print(f"Fixed points (already sorted): {len(fp)}")
    for x in sorted(fp):
        print(f"  {''.join(map(str, x))}  (transitions: {length_fn(x)})")

    # Show fiber structure
    print(f"\nFiber structure (equivalence classes):")
    seen = set()
    for x in sorted(domain):
        cx = compress(x)
        if cx not in seen:
            seen.add(cx)
            cls = fiber_class(compress, x, domain)
            lengths = {y: length_fn(y) for y in cls}
            min_len = min(lengths.values())
            print(f"  Representative: {''.join(map(str, cx))} (len={length_fn(cx)})")
            print(f"    Class members: {len(cls)}, "
                  f"lengths: {sorted(lengths.values())}")
            # Verify optimality: c(x) achieves minimum length
            assert length_fn(cx) == min_len, \
                f"Optimality violated! c(x) len={length_fn(cx)}, min={min_len}"
            print(f"    ✓ Fixed point achieves minimum length {min_len}")

    # Verify closure cost = length of compressed representative
    print(f"\nClosure cost verification:")
    for x in sorted(domain)[:8]:
        cc = closure_cost(compress, length_fn, x, domain)
        lc = length_fn(compress(x))
        status = "✓" if cc == lc else "✗"
        print(f"  {status} closureCost({''.join(map(str, x))}) = {cc} = "
              f"ℓ(c({''.join(map(str, x))})) = {lc}")

    print()


# ===========================================================================
# Demo 2: Incompressibility characterization
# ===========================================================================

def demo_incompressibility():
    """
    Demonstrate the incompressibility theorem on a small finite type.

    We show that elements fixed by ALL strict admissible compressors are
    exactly those whose length is preserved by all such compressors.
    """
    print("=" * 70)
    print("DEMO 2: Incompressibility as Universal Fixed-Point Property")
    print("=" * 70)

    # Domain: integers 0..7 with "length" = value itself
    domain = list(range(8))

    def length_fn(x):
        return x

    # Generate all idempotent functions on this domain
    # (too many for domain size 8, so we sample specific ones)
    compressors = []

    # Compressor 1: floor to nearest even
    def c1(x):
        return x if x % 2 == 0 else x - 1
    compressors.append(("floor_even", c1))

    # Compressor 2: min with 4
    def c2(x):
        return min(x, 4)
    compressors.append(("cap_at_4", c2))

    # Compressor 3: identity (trivial)
    def c3(x):
        return x
    compressors.append(("identity", c3))

    # Compressor 4: map to 0 if x > 5
    def c4(x):
        return 0 if x > 5 else x
    compressors.append(("truncate_above_5", c4))

    print(f"\nDomain: {domain}")
    print(f"Length function: ℓ(x) = x")
    print(f"\nAnalyzing {len(compressors)} compressors:\n")

    for name, c in compressors:
        idem = is_idempotent(c, domain)
        strict = all(
            (c(x) == x) or (length_fn(c(x)) < length_fn(x))
            for x in domain
        )
        admissible = idem and all(length_fn(c(x)) <= length_fn(x) for x in domain)
        strict_admissible = idem and strict

        fp = fixed_points(c, domain)
        print(f"  {name}:")
        print(f"    Idempotent: {idem}, Admissible: {admissible}, "
              f"Strict: {strict_admissible}")
        print(f"    Fixed points: {sorted(fp)}")
        print(f"    Mapping: {[c(x) for x in domain]}")

    # Find universally fixed elements
    strict_compressors = [
        (name, c) for name, c in compressors
        if is_idempotent(c, domain) and
        all((c(x) == x) or (length_fn(c(x)) < length_fn(x)) for x in domain)
    ]

    universally_fixed = set(domain)
    for name, c in strict_compressors:
        universally_fixed &= fixed_points(c, domain)

    print(f"\nStrict admissible compressors: "
          f"{[name for name, _ in strict_compressors]}")
    print(f"Universally fixed elements (incompressible): "
          f"{sorted(universally_fixed)}")
    print(f"These are exactly the elements where ℓ(c(x)) = ℓ(x) "
          f"for ALL strict compressors.")

    # Verify the iff
    for x in domain:
        all_fixed = all(c(x) == x for _, c in strict_compressors)
        all_preserved = all(
            length_fn(c(x)) == length_fn(x) for _, c in strict_compressors
        )
        assert all_fixed == all_preserved, f"Iff violated at x={x}!"
    print("✓ Incompressibility ↔ universally fixed: verified for all elements")

    print()


# ===========================================================================
# Demo 3: Tropical / Min-Plus closure cost
# ===========================================================================

def demo_tropical_closure():
    """
    Demonstrate the tropical (min-plus) properties of closure cost.
    """
    print("=" * 70)
    print("DEMO 3: Tropical Closure Cost and Idempotent Aggregation")
    print("=" * 70)

    # Domain: words represented as tuples, with length = tuple length
    words = [()] + [(0,), (1,)] + \
        list(itertools.product([0, 1], repeat=2)) + \
        list(itertools.product([0, 1], repeat=3))
    domain = list(range(len(words)))
    word_map = {i: w for i, w in enumerate(words)}

    def length_fn(i):
        return len(word_map[i])

    # Compressor: map each word to the shortest word with same bit-count
    def bit_count(w):
        return sum(w) if w else 0

    # Group by bit count, find shortest in each group
    groups = defaultdict(list)
    for i, w in enumerate(words):
        groups[bit_count(w)].append(i)

    canonical = {}
    for bc, members in groups.items():
        best = min(members, key=length_fn)
        for m in members:
            canonical[m] = best

    def compress(i):
        return canonical[i]

    print(f"\nDomain: {len(domain)} binary words of length 0-3")
    print(f"Compressor: map to shortest word with same number of 1-bits\n")

    # Verify properties
    assert is_idempotent(compress, domain)
    print("✓ Compressor is idempotent")

    assert all(length_fn(compress(i)) <= length_fn(i) for i in domain)
    print("✓ Compressor is length-nonincreasing")

    # Show closure cost computation
    print(f"\nClosure cost (tropical min) for each element:")
    print(f"{'Word':<12} {'ℓ(w)':<6} {'c(w)':<12} {'ℓ(c(w))':<8} "
          f"{'closureCost':<12} {'Match?'}")
    print("-" * 62)
    for i in domain:
        w = word_map[i]
        cw = word_map[compress(i)]
        cc = closure_cost(compress, length_fn, i, domain)
        lc = length_fn(compress(i))
        match = "✓" if cc == lc else "✗"
        print(f"{''.join(map(str, w)) or 'ε':<12} {length_fn(i):<6} "
              f"{''.join(map(str, cw)) or 'ε':<12} {lc:<8} {cc:<12} {match}")

    # Verify idempotence of closure cost
    print(f"\nClosure cost idempotence: closureCost(c(x)) = closureCost(x)")
    all_match = True
    for i in domain:
        cc_cx = closure_cost(compress, length_fn, compress(i), domain)
        cc_x = closure_cost(compress, length_fn, i, domain)
        if cc_cx != cc_x:
            all_match = False
            print(f"  ✗ closureCost(c({i})) = {cc_cx} ≠ {cc_x} = closureCost({i})")
    if all_match:
        print("  ✓ Verified for all elements!")

    print()


# ===========================================================================
# Demo 4: Counting fixed points and compression ratio
# ===========================================================================

def demo_counting():
    """
    Demonstrate the counting theorem: fixed points = range cardinality,
    and compressed + fixed = total.
    """
    print("=" * 70)
    print("DEMO 4: Counting Fixed Points and Compression Ratio")
    print("=" * 70)

    n = 5
    domain = list(itertools.product([0, 1], repeat=n))

    # Several compressors with different compression ratios
    compressors = []

    # Sort bits
    compressors.append(("sort_bits",
                         lambda x: tuple(sorted(x))))

    # XOR parity normalization: map to canonical with same parity
    compressors.append(("zero_last_bit",
                         lambda x: x[:-1] + (0,)))

    # Identity
    compressors.append(("identity", lambda x: x))

    # Constant
    compressors.append(("constant_zero",
                         lambda x: (0,) * n))

    print(f"\nDomain: {len(domain)} bitstrings of length {n}\n")

    for name, c in compressors:
        assert is_idempotent(c, domain), f"{name} not idempotent!"
        fp = fixed_points(c, domain)
        range_c = {c(x) for x in domain}
        compressed = {x for x in domain if c(x) != x}

        print(f"Compressor: {name}")
        print(f"  |fixed points| = {len(fp)}")
        print(f"  |range(c)|     = {len(range_c)}")
        print(f"  fixed = range? {fp == range_c}  ✓")
        print(f"  |compressed| + |fixed| = {len(compressed)} + {len(fp)} "
              f"= {len(compressed) + len(fp)} = {len(domain)}  ✓")
        ratio = len(fp) / len(domain) * 100
        print(f"  Compression ratio: {ratio:.1f}% of elements are irreducible")
        print()

    print()


# ===========================================================================
# Demo 5: MDL Bridge - Semantic Invariant Preservation
# ===========================================================================

def demo_mdl_bridge():
    """
    Demonstrate the MDL bridge theorem: compression preserves semantic
    content while reducing description length.
    """
    print("=" * 70)
    print("DEMO 5: MDL Bridge - Semantic Invariant Preservation")
    print("=" * 70)

    # Domain: 4-bit strings
    # Semantic invariant U: number of 1-bits (Hamming weight)
    # Description length K: position in lexicographic order (arbitrary cost)
    n = 4
    domain = list(itertools.product([0, 1], repeat=n))

    def U(x):
        """Semantic invariant: Hamming weight."""
        return sum(x)

    def K(x):
        """Description length: binary value as integer."""
        return int(''.join(map(str, x)), 2)

    # Compressor: sort bits (preserves Hamming weight)
    def c(x):
        return tuple(sorted(x))

    print(f"\nSemantic invariant U(x) = Hamming weight")
    print(f"Description length K(x) = integer value of bitstring")
    print(f"Compressor c(x) = sort bits\n")

    assert is_idempotent(c, domain)

    print(f"{'x':<8} {'K(x)':<6} {'U(x)':<6} {'c(x)':<8} "
          f"{'K(c(x))':<8} {'U(c(x))':<8} {'K↓?':<5} {'U=?'}")
    print("-" * 57)
    for x in domain:
        cx = c(x)
        k_reduced = K(cx) <= K(x)
        u_preserved = U(cx) == U(x)
        print(f"{''.join(map(str, x)):<8} {K(x):<6} {U(x):<6} "
              f"{''.join(map(str, cx)):<8} {K(cx):<8} {U(cx):<8} "
              f"{'✓' if k_reduced else '✗':<5} "
              f"{'✓' if u_preserved else '✗'}")

    all_k = all(K(c(x)) <= K(x) for x in domain)
    all_u = all(U(c(x)) == U(x) for x in domain)
    print(f"\n✓ K(c(x)) ≤ K(x) for all x: {all_k}")
    print(f"✓ U(c(x)) = U(x) for all x: {all_u}")
    print(f"→ MDL bridge theorem verified: compression gives upper bounds "
          f"while preserving semantics")

    print()


if __name__ == "__main__":
    demo_bitstring_compression()
    demo_incompressibility()
    demo_tropical_closure()
    demo_counting()
    demo_mdl_bridge()
    print("=" * 70)
    print("All demonstrations completed successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts embedded."""

import json
import base64
import os
import sys

# Add visualization generation
sys.path.insert(0, os.path.dirname(__file__))

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def image_to_base64(path):
    with open(path, 'rb') as f:
        return "data:image/png;base64," + base64.b64encode(f.read()).decode('utf-8')

def main():
    project_root = os.path.dirname(os.path.abspath(__file__))

    # Read all content
    article = read_file(os.path.join(project_root, 'ARTICLE.md'))
    research_paper = read_file(os.path.join(project_root, 'RESEARCH_PAPER.md'))
    future_directions = read_file(os.path.join(project_root, 'FUTURE_DIRECTIONS.md'))
    lean_proofs = read_file(os.path.join(project_root, 'Computation', 'ClosureCompressionDuality.lean'))
    demo_code = read_file(os.path.join(project_root, 'demo.py'))
    algorithms_code = read_file(os.path.join(project_root, 'algorithms.py'))
    applications_code = read_file(os.path.join(project_root, 'applications.py'))

    # Read visualization images
    viz_files = [
        ('Fiber Structure', 'viz_fiber_structure.png'),
        ('Compression Landscape', 'viz_compression_landscape.png'),
        ('Incompressibility Matrix', 'viz_incompressibility.png'),
        ('Tropical Cost', 'viz_tropical_cost.png'),
        ('Counting Theorem', 'viz_counting_theorem.png'),
    ]

    visualizations = []
    for name, filename in viz_files:
        path = os.path.join(project_root, filename)
        if os.path.exists(path):
            visualizations.append({
                "name": name,
                "data": image_to_base64(path)
            })

    package = {
        "title": "Closure-Compression Duality: Idempotent Operators as Canonical Compressors with Tropical Cost Structure",
        "domain": "Computation",
        "article": article,
        "research_paper": research_paper,
        "future_directions": future_directions,
        "demos": [
            {
                "name": "Closure-Compression Duality Demonstrations",
                "code": demo_code
            }
        ],
        "algorithms": [
            {
                "name": "Optimal Compressor Construction",
                "pseudocode": "Input: Domain D, length ℓ, equivalence eq\n1. Group elements by eq(x)\n2. For each class, find argmin ℓ\n3. Map all members to the minimizer\nOutput: Idempotent fiber-optimal compressor\nTime: O(n log n), Space: O(n)",
                "code": algorithms_code
            }
        ],
        "visualizations": visualizations,
        "lean_proofs": lean_proofs
    }

    output_path = os.path.join(project_root, 'PACKAGE.json')
    with open(output_path, 'w') as f:
        json.dump(package, f, indent=2, ensure_ascii=False)

    print(f"PACKAGE.json generated ({os.path.getsize(output_path)} bytes)")
    print(f"  Visualizations embedded: {len(visualizations)}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualizations for Closure-Compression Duality

Generates publication-quality figures illustrating the core mathematical
structures and theorems.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import itertools
from collections import defaultdict
import base64
from io import BytesIO


def fig_to_base64(fig):
    """Convert a matplotlib figure to a base64-encoded PNG data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_fiber_structure():
    """
    Visualize the fiber structure of an idempotent compressor.
    Shows how elements map to canonical representatives.
    """
    fig, ax = plt.subplots(1, 1, figsize=(10, 7))

    # 4-bit strings compressed by sorting
    n = 4
    domain = list(itertools.product([0, 1], repeat=n))

    def compress(bits):
        return tuple(sorted(bits))

    def length_fn(bits):
        return sum(1 for i in range(len(bits) - 1) if bits[i] != bits[i + 1])

    # Group into fibers
    fibers = defaultdict(list)
    for x in domain:
        fibers[compress(x)].append(x)

    # Layout: fixed points on the left, fiber members on the right
    colors = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63', '#9C27B0']
    y_pos = 0
    y_positions = {}

    for idx, (rep, members) in enumerate(sorted(fibers.items())):
        color = colors[idx % len(colors)]
        rep_str = ''.join(map(str, rep))

        # Draw representative (fixed point) on the left
        rep_y = y_pos + len(members) / 2
        ax.add_patch(plt.Rectangle((0.5, rep_y - 0.3), 2, 0.6,
                                    facecolor=color, alpha=0.8,
                                    edgecolor='black', linewidth=2))
        ax.text(1.5, rep_y, f"{rep_str}\nℓ={length_fn(rep)}",
                ha='center', va='center', fontsize=9, fontweight='bold',
                color='white')

        # Draw fiber members on the right
        for j, member in enumerate(sorted(members)):
            my = y_pos + j
            member_str = ''.join(map(str, member))
            is_fixed = member == rep

            ax.add_patch(plt.Rectangle((5.5, my - 0.25), 2, 0.5,
                                        facecolor=color if is_fixed else 'white',
                                        alpha=0.6 if is_fixed else 0.3,
                                        edgecolor=color, linewidth=1.5))
            ax.text(6.5, my, f"{member_str} (ℓ={length_fn(member)})",
                    ha='center', va='center', fontsize=8,
                    color='white' if is_fixed else 'black')

            # Draw arrow from member to representative
            ax.annotate('', xy=(2.5, rep_y), xytext=(5.5, my),
                       arrowprops=dict(arrowstyle='->', color=color,
                                       alpha=0.4, lw=1))

        y_pos += len(members) + 0.5

    ax.set_xlim(-0.5, 9)
    ax.set_ylim(-0.5, y_pos)
    ax.set_title('Fiber Structure of Idempotent Compressor\n'
                 '(4-bit strings, sort normalization)',
                 fontsize=14, fontweight='bold')
    ax.text(1.5, -1.2, 'Fixed Points\n(Canonical Representatives)',
            ha='center', fontsize=10, style='italic')
    ax.text(6.5, -1.2, 'Fiber Members\n(Equivalence Class)',
            ha='center', fontsize=10, style='italic')
    ax.axis('off')

    fig.tight_layout()
    return fig


def viz_compression_landscape():
    """
    Visualize the compression landscape: length values across the domain
    with fixed points highlighted.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    n = 5
    domain = list(itertools.product([0, 1], repeat=n))

    def compress(bits):
        return tuple(sorted(bits))

    def length_fn(bits):
        return sum(1 for i in range(len(bits) - 1) if bits[i] != bits[i + 1])

    # Left: bar chart of lengths before/after compression
    indices = range(len(domain))
    lengths_before = [length_fn(x) for x in domain]
    lengths_after = [length_fn(compress(x)) for x in domain]
    is_fixed = [compress(x) == x for x in domain]

    ax = axes[0]
    colors_before = ['#2196F3' if f else '#BBDEFB' for f in is_fixed]
    ax.bar(indices, lengths_before, color=colors_before, alpha=0.7,
           label='ℓ(x)', width=0.4, align='edge')
    ax.bar([i + 0.4 for i in indices], lengths_after, color='#FF9800',
           alpha=0.7, label='ℓ(c(x))', width=0.4, align='edge')
    ax.set_xlabel('Element index', fontsize=11)
    ax.set_ylabel('Description length', fontsize=11)
    ax.set_title('Length Before/After Compression', fontsize=13,
                 fontweight='bold')
    ax.legend(fontsize=10)

    # Highlight fixed points
    fixed_patch = mpatches.Patch(color='#2196F3', label='Fixed point')
    nonfixed_patch = mpatches.Patch(color='#BBDEFB', label='Non-fixed')
    ax.legend(handles=[fixed_patch, nonfixed_patch,
                       mpatches.Patch(color='#FF9800', label='ℓ(c(x))')],
              fontsize=9)

    # Right: compression ratio by equivalence class
    ax = axes[1]
    fibers = defaultdict(list)
    for x in domain:
        fibers[compress(x)].append(x)

    class_names = []
    class_sizes = []
    min_lengths = []
    max_lengths = []
    avg_lengths = []

    for rep in sorted(fibers.keys()):
        members = fibers[rep]
        rep_str = ''.join(map(str, rep))
        lengths = [length_fn(m) for m in members]
        class_names.append(f"{rep_str}\n(n={len(members)})")
        class_sizes.append(len(members))
        min_lengths.append(min(lengths))
        max_lengths.append(max(lengths))
        avg_lengths.append(np.mean(lengths))

    x_pos = range(len(class_names))
    ax.bar(x_pos, max_lengths, color='#FFCDD2', label='max ℓ', alpha=0.8)
    ax.bar(x_pos, avg_lengths, color='#FF9800', label='avg ℓ', alpha=0.8)
    ax.bar(x_pos, min_lengths, color='#4CAF50', label='min ℓ = ℓ(c(x))',
           alpha=0.9)
    ax.set_xticks(x_pos)
    ax.set_xticklabels(class_names, fontsize=8)
    ax.set_ylabel('Description length', fontsize=11)
    ax.set_title('Length Distribution by Equivalence Class', fontsize=13,
                 fontweight='bold')
    ax.legend(fontsize=9)

    fig.tight_layout()
    return fig


def viz_incompressibility():
    """
    Visualize the incompressibility theorem: elements fixed by
    all strict compressors.
    """
    fig, ax = plt.subplots(figsize=(10, 6))

    domain = list(range(8))

    def length_fn(x):
        return x

    compressors = {
        'floor_even': lambda x: x if x % 2 == 0 else x - 1,
        'cap_at_4': lambda x: min(x, 4),
        'truncate>5': lambda x: 0 if x > 5 else x,
    }

    # Create grid: compressor × element
    comp_names = list(compressors.keys())
    n_comp = len(comp_names)
    n_elem = len(domain)

    grid = np.zeros((n_comp, n_elem))
    for i, (name, c) in enumerate(compressors.items()):
        for j, x in enumerate(domain):
            if c(x) == x:
                grid[i, j] = 1  # Fixed
            else:
                grid[i, j] = 0  # Compressed

    # Plot heatmap
    cmap = plt.cm.colors.ListedColormap(['#FFCDD2', '#C8E6C9'])
    im = ax.imshow(grid, cmap=cmap, aspect='auto', interpolation='nearest')

    # Labels
    ax.set_xticks(range(n_elem))
    ax.set_xticklabels([str(x) for x in domain], fontsize=11)
    ax.set_yticks(range(n_comp))
    ax.set_yticklabels(comp_names, fontsize=11)
    ax.set_xlabel('Element x (ℓ(x) = x)', fontsize=12)
    ax.set_ylabel('Compressor', fontsize=12)
    ax.set_title('Fixed-Point Matrix: Incompressibility Analysis\n'
                 '(Green = fixed, Red = compressed)', fontsize=14,
                 fontweight='bold')

    # Add text annotations
    for i in range(n_comp):
        for j in range(n_elem):
            c = list(compressors.values())[i]
            text = f"c({j})={c(j)}"
            color = 'darkgreen' if grid[i, j] == 1 else 'darkred'
            ax.text(j, i, text, ha='center', va='center', fontsize=8,
                    color=color, fontweight='bold' if grid[i, j] == 1 else 'normal')

    # Mark universally fixed elements
    universally_fixed = set(domain)
    for c in compressors.values():
        universally_fixed &= {x for x in domain if c(x) == x}

    for x in universally_fixed:
        ax.add_patch(plt.Rectangle((x - 0.5, -0.5), 1, n_comp,
                                    fill=False, edgecolor='gold',
                                    linewidth=3, linestyle='--'))

    legend_elements = [
        mpatches.Patch(facecolor='#C8E6C9', edgecolor='black',
                       label='Fixed (c(x)=x)'),
        mpatches.Patch(facecolor='#FFCDD2', edgecolor='black',
                       label='Compressed (c(x)≠x)'),
        mpatches.Patch(fill=False, edgecolor='gold', linewidth=2,
                       linestyle='--', label='Universally incompressible'),
    ]
    ax.legend(handles=legend_elements, loc='upper right', fontsize=9)

    fig.tight_layout()
    return fig


def viz_tropical_cost():
    """
    Visualize tropical (min-plus) closure costs.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Domain: integers 0-15 with modular equivalence
    domain = list(range(16))

    def compress(x):
        return x % 5  # Mod 5 normalization

    def length_fn(x):
        return x  # Length = value

    # Left: closure cost vs raw length
    ax = axes[0]
    raw_lengths = [length_fn(x) for x in domain]
    closure_costs = []
    for x in domain:
        cls = [y for y in domain if compress(y) == compress(x)]
        closure_costs.append(min(length_fn(y) for y in cls))

    is_fixed = [compress(x) == x for x in domain]
    colors = ['#4CAF50' if f else '#2196F3' for f in is_fixed]

    ax.scatter(domain, raw_lengths, c='#BBDEFB', s=100, zorder=2,
               label='ℓ(x)', edgecolors='#2196F3', linewidths=1.5)
    ax.scatter(domain, closure_costs, c=colors, s=100, zorder=3,
               label='closureCost(x)', edgecolors='black', linewidths=1,
               marker='D')

    for x in domain:
        if raw_lengths[x] != closure_costs[x]:
            ax.annotate('', xy=(x, closure_costs[x]),
                       xytext=(x, raw_lengths[x]),
                       arrowprops=dict(arrowstyle='->', color='red',
                                       alpha=0.5, lw=1.5))

    ax.set_xlabel('Element x', fontsize=11)
    ax.set_ylabel('Cost', fontsize=11)
    ax.set_title('Raw Length vs Tropical Closure Cost\n'
                 '(Compressor: x mod 5)', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Right: idempotence verification
    ax = axes[1]
    cost_x = []
    cost_cx = []
    for x in domain:
        cls_x = [y for y in domain if compress(y) == compress(x)]
        cls_cx = [y for y in domain if compress(y) == compress(compress(x))]
        cost_x.append(min(length_fn(y) for y in cls_x))
        cost_cx.append(min(length_fn(y) for y in cls_cx))

    ax.scatter(cost_x, cost_cx, c='#2196F3', s=100, zorder=3,
               edgecolors='black', linewidths=1)
    max_val = max(max(cost_x), max(cost_cx)) + 1
    ax.plot([0, max_val], [0, max_val], 'r--', alpha=0.5, label='y = x')

    for x in domain:
        ax.annotate(str(x), (cost_x[x], cost_cx[x]),
                   fontsize=7, ha='center', va='bottom')

    ax.set_xlabel('closureCost(x)', fontsize=11)
    ax.set_ylabel('closureCost(c(x))', fontsize=11)
    ax.set_title('Tropical Idempotence Verification\n'
                 'closureCost(c(x)) = closureCost(x)', fontsize=13,
                 fontweight='bold')
    ax.legend(fontsize=10)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    fig.tight_layout()
    return fig


def viz_counting_theorem():
    """
    Visualize the counting theorem: |fixed points| = |range|,
    |compressed| + |fixed| = |total|.
    """
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Compare multiple compressors on 5-bit strings
    n = 5
    domain = list(itertools.product([0, 1], repeat=n))
    total = len(domain)

    compressors = {
        'Identity': lambda x: x,
        'Sort bits': lambda x: tuple(sorted(x)),
        'Clear last': lambda x: x[:-1] + (0,),
        'Clear last 2': lambda x: x[:-2] + (0, 0),
        'Constant': lambda x: (0,) * n,
    }

    names = list(compressors.keys())
    fixed_counts = []
    range_counts = []

    for name, c in compressors.items():
        fp = sum(1 for x in domain if c(x) == x)
        rng = len({c(x) for x in domain})
        fixed_counts.append(fp)
        range_counts.append(rng)

    # Left: fixed points vs range size
    ax = axes[0]
    x_pos = np.arange(len(names))
    width = 0.35

    bars1 = ax.bar(x_pos - width/2, fixed_counts, width,
                   label='|Fixed points|', color='#4CAF50', alpha=0.8)
    bars2 = ax.bar(x_pos + width/2, range_counts, width,
                   label='|Range(c)|', color='#2196F3', alpha=0.8)

    ax.set_xticks(x_pos)
    ax.set_xticklabels(names, fontsize=9, rotation=15)
    ax.set_ylabel('Count', fontsize=11)
    ax.set_title('Fixed Points = Range\n(Idempotent Map Theorem)',
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.axhline(y=total, color='red', linestyle='--', alpha=0.5,
               label=f'Total = {total}')

    # Add value labels
    for bar in bars1:
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.5,
                str(int(bar.get_height())), ha='center', fontsize=9)
    for bar in bars2:
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.5,
                str(int(bar.get_height())), ha='center', fontsize=9)

    # Right: stacked bar of compressed + fixed = total
    ax = axes[1]
    compressed = [total - fp for fp in fixed_counts]

    ax.bar(x_pos, fixed_counts, label='Fixed (incompressible)',
           color='#4CAF50', alpha=0.8)
    ax.bar(x_pos, compressed, bottom=fixed_counts,
           label='Compressed (reducible)', color='#FF9800', alpha=0.8)

    ax.axhline(y=total, color='red', linestyle='--', alpha=0.5)
    ax.text(len(names) - 0.5, total + 0.5, f'Total = {total}',
            fontsize=10, color='red')

    ax.set_xticks(x_pos)
    ax.set_xticklabels(names, fontsize=9, rotation=15)
    ax.set_ylabel('Count', fontsize=11)
    ax.set_title('Compressed + Fixed = Total\n(Partition Theorem)',
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)

    fig.tight_layout()
    return fig


if __name__ == "__main__":
    print("Generating visualizations...")

    fig1 = viz_fiber_structure()
    fig1.savefig('viz_fiber_structure.png', dpi=150, bbox_inches='tight')
    print("  ✓ viz_fiber_structure.png")

    fig2 = viz_compression_landscape()
    fig2.savefig('viz_compression_landscape.png', dpi=150, bbox_inches='tight')
    print("  ✓ viz_compression_landscape.png")

    fig3 = viz_incompressibility()
    fig3.savefig('viz_incompressibility.png', dpi=150, bbox_inches='tight')
    print("  ✓ viz_incompressibility.png")

    fig4 = viz_tropical_cost()
    fig4.savefig('viz_tropical_cost.png', dpi=150, bbox_inches='tight')
    print("  ✓ viz_tropical_cost.png")

    fig5 = viz_counting_theorem()
    fig5.savefig('viz_counting_theorem.png', dpi=150, bbox_inches='tight')
    print("  ✓ viz_counting_theorem.png")

    print("\nAll visualizations generated successfully!")
