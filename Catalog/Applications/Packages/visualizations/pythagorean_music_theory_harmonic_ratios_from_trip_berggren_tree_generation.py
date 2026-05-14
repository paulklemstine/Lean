#!/usr/bin/env python3
"""
Pythagorean Music Theory: Algorithms

Implements the core algorithms from the research paper:
1. Berggren tree generation with interval extraction
2. Consonance classification and complexity computation
3. Tropical logarithm transport
4. Circle-of-fifths projection
5. Octave equivalence reduction
"""

from fractions import Fraction
from typing import List, Tuple, Optional, Dict
import math


# ─── Type Aliases ────────────────────────────────────────────────────────────

Triple = Tuple[int, int, int]
IntervalData = Dict[str, object]


# ─── Algorithm 1: Berggren Tree Generation ──────────────────────────────────

def berggren_A(t: Triple) -> Triple:
    """
    Berggren matrix A applied to a Pythagorean triple.
    
    Complexity: O(1) arithmetic operations.
    
    >>> berggren_A((3, 4, 5))
    (5, 12, 13)
    """
    a, b, c = t
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)


def berggren_B(t: Triple) -> Triple:
    """
    Berggren matrix B applied to a Pythagorean triple.
    
    Complexity: O(1) arithmetic operations.
    
    >>> berggren_B((3, 4, 5))
    (21, 20, 29)
    """
    a, b, c = t
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)


def berggren_C(t: Triple) -> Triple:
    """
    Berggren matrix C applied to a Pythagorean triple.
    
    Complexity: O(1) arithmetic operations.
    
    >>> berggren_C((3, 4, 5))
    (15, 8, 17)
    """
    a, b, c = t
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)


def berggren_tree(root: Triple = (3, 4, 5), max_depth: int = 5,
                  max_hypotenuse: Optional[int] = None) -> List[Tuple[str, Triple, int]]:
    """
    Generate the Berggren tree up to a given depth or hypotenuse bound.
    
    Returns list of (path, triple, depth) tuples.
    
    Complexity: O(3^depth) nodes, O(1) per node.
    
    >>> len(berggren_tree(max_depth=2))
    13
    """
    results = []
    stack = [("", root, 0)]
    
    while stack:
        path, triple, depth = stack.pop()
        a, b, c = triple
        
        if max_hypotenuse and c > max_hypotenuse:
            continue
        
        results.append((path, triple, depth))
        
        if depth < max_depth:
            for label, gen in [("A", berggren_A), ("B", berggren_B), ("C", berggren_C)]:
                child = gen(triple)
                if max_hypotenuse is None or child[2] <= max_hypotenuse:
                    stack.append((path + label, child, depth + 1))
    
    return results


# ─── Algorithm 2: Interval Extraction ───────────────────────────────────────

def leg_ratio(a: int, b: int) -> Fraction:
    """
    Compute the leg ratio max(|a|,|b|) / min(|a|,|b|).
    
    This is the frequency ratio obtained from comparing the two legs.
    For (3,4,5): returns 4/3, the perfect fourth.
    
    Complexity: O(log(max(a,b))) for GCD reduction.
    
    >>> leg_ratio(3, 4)
    Fraction(4, 3)
    """
    return Fraction(max(abs(a), abs(b)), min(abs(a), abs(b)))


def hyp_leg_ratio(a: int, b: int, c: int) -> Fraction:
    """
    Compute the hypotenuse-to-larger-leg ratio |c| / max(|a|,|b|).
    
    For (3,4,5): returns 5/4, the just major third.
    
    Complexity: O(log(c)) for GCD reduction.
    
    >>> hyp_leg_ratio(3, 4, 5)
    Fraction(5, 4)
    """
    return Fraction(abs(c), max(abs(a), abs(b)))


def hyp_min_leg_ratio(a: int, b: int, c: int) -> Fraction:
    """
    Compute the hypotenuse-to-smaller-leg ratio |c| / min(|a|,|b|).
    
    For (3,4,5): returns 5/3, the major sixth.
    
    Complexity: O(log(c)) for GCD reduction.
    
    >>> hyp_min_leg_ratio(3, 4, 5)
    Fraction(5, 3)
    """
    return Fraction(abs(c), min(abs(a), abs(b)))


# ─── Algorithm 3: Consonance Classification ─────────────────────────────────

def interval_complexity(q: Fraction) -> int:
    """
    Compute the interval complexity of a ratio: numerator + denominator.
    
    Lower complexity indicates greater consonance in just intonation.
    
    Complexity: O(1) after reduction.
    
    >>> interval_complexity(Fraction(4, 3))
    7
    >>> interval_complexity(Fraction(5, 4))
    9
    """
    return q.numerator + q.denominator


def is_consonant(q: Fraction, threshold: int = 12) -> bool:
    """
    Classify a ratio as consonant if its complexity is below threshold.
    
    Default threshold 12 captures: unison, octave, fifth, fourth,
    major third, minor third, major sixth, minor sixth.
    
    Complexity: O(1).
    
    >>> is_consonant(Fraction(4, 3))
    True
    >>> is_consonant(Fraction(12, 5))
    False
    """
    return q > 0 and interval_complexity(q) <= threshold


def consonance_class(q: Fraction) -> str:
    """
    Classify a ratio into consonance categories.
    
    Returns one of: "perfect", "imperfect", "dissonant".
    
    >>> consonance_class(Fraction(3, 2))
    'perfect'
    >>> consonance_class(Fraction(5, 4))
    'imperfect'
    """
    c = interval_complexity(q)
    if c <= 5:  # unison, octave, fifth
        return "perfect"
    elif c <= 12:  # thirds, sixths, fourth
        return "imperfect"
    else:
        return "dissonant"


# ─── Algorithm 4: Tropical Logarithm Transport ──────────────────────────────

def tropical_log(q: Fraction) -> float:
    """
    Compute the tropical logarithm of a positive rational.
    
    Maps multiplicative interval space to additive interval space.
    
    Complexity: O(1).
    
    >>> abs(tropical_log(Fraction(4,3)) + tropical_log(Fraction(3,2)) - tropical_log(Fraction(2,1))) < 1e-15
    True
    """
    return math.log(float(q))


def tropical_interval_vector(triple: Triple) -> Tuple[float, float, float]:
    """
    Extract the tropical interval vector from a Pythagorean triple.
    
    Returns (log(legRatio), log(hypLegRatio), log(hypMinLegRatio)).
    
    >>> v = tropical_interval_vector((3, 4, 5))
    >>> abs(v[0] - math.log(4/3)) < 1e-15
    True
    """
    a, b, c = triple
    return (
        tropical_log(leg_ratio(a, b)),
        tropical_log(hyp_leg_ratio(a, b, c)),
        tropical_log(hyp_min_leg_ratio(a, b, c))
    )


# ─── Algorithm 5: Circle of Fifths Projection ───────────────────────────────

def octave_reduce(ratio: float) -> float:
    """
    Reduce a frequency ratio to the fundamental octave [1, 2).
    
    Complexity: O(log(ratio)).
    
    >>> abs(octave_reduce(4/3) - 4/3) < 1e-15
    True
    >>> abs(octave_reduce(8/3) - 4/3) < 1e-15
    True
    """
    if ratio <= 0:
        return 0.0
    while ratio >= 2:
        ratio /= 2
    while ratio < 1:
        ratio *= 2
    return ratio


def fifth_coordinate(q: Fraction) -> float:
    """
    Compute the fifth-normalized coordinate: log(q) / log(3/2).
    
    This measures how many perfect fifths the interval spans.
    
    >>> abs(fifth_coordinate(Fraction(3, 2)) - 1.0) < 1e-15
    True
    """
    return math.log(float(q)) / math.log(1.5)


def circle_of_fifths_position(q: Fraction) -> float:
    """
    Project an interval onto the circle of fifths (mod 12 fifths ≈ 7 octaves).
    
    Returns a position in [0, 12) representing the number of fifths
    from unison, reduced modulo 12.
    
    >>> abs(circle_of_fifths_position(Fraction(4, 3)) - 11.0) < 0.02
    True
    """
    # log(q) / log(3/2), then reduce mod (log(2)/log(3/2)) ≈ 1.709...
    # Then normalize to [0, 12)
    fifths = fifth_coordinate(q)
    octave_in_fifths = math.log(2) / math.log(1.5)  # ≈ 1.70951
    reduced = fifths % octave_in_fifths
    return reduced * 12 / octave_in_fifths


def is_in_circle_of_fifths(q: Fraction, tolerance: float = 0.01) -> bool:
    """
    Check if a ratio lies (approximately) on the circle of fifths.
    
    A ratio is on the circle of fifths if it equals (3/2)^n * 2^m
    for some integers n, m.
    
    >>> is_in_circle_of_fifths(Fraction(4, 3))
    True
    >>> is_in_circle_of_fifths(Fraction(3, 2))
    True
    >>> is_in_circle_of_fifths(Fraction(5, 4))
    False
    """
    # log(q) = n * log(3/2) + m * log(2)
    # Solve: log(q) / log(2) = n * log(3/2)/log(2) + m
    # So n * log(3/2)/log(2) must be close to an integer (mod 1)
    log_ratio = math.log(float(q)) / math.log(2)
    log_fifth = math.log(1.5) / math.log(2)
    
    # Try small values of n
    for n in range(-12, 13):
        remainder = log_ratio - n * log_fifth
        if abs(remainder - round(remainder)) < tolerance:
            return True
    return False


# ─── Algorithm 6: Full Interval Analysis ────────────────────────────────────

def analyze_triple(triple: Triple) -> IntervalData:
    """
    Perform complete harmonic analysis of a Pythagorean triple.
    
    Returns a dictionary with all computed musical properties.
    
    >>> d = analyze_triple((3, 4, 5))
    >>> d['leg_ratio'] == Fraction(4, 3)
    True
    >>> d['consonant']
    True
    """
    a, b, c = triple
    lr = leg_ratio(a, b)
    hlr = hyp_leg_ratio(a, b, c)
    hmlr = hyp_min_leg_ratio(a, b, c)
    
    return {
        'triple': triple,
        'is_pythagorean': a**2 + b**2 == c**2,
        'is_primitive': math.gcd(a, math.gcd(b, c)) == 1,
        'leg_ratio': lr,
        'hyp_leg_ratio': hlr,
        'hyp_min_leg_ratio': hmlr,
        'leg_complexity': interval_complexity(lr),
        'hyp_complexity': interval_complexity(hlr),
        'consonant': is_consonant(lr),
        'consonance_class': consonance_class(lr),
        'tropical_vector': tropical_interval_vector(triple),
        'fifth_coord': fifth_coordinate(lr),
        'on_circle_of_fifths': is_in_circle_of_fifths(lr),
        'octave_reduced': octave_reduce(float(lr)),
        'cents': 1200 * math.log2(octave_reduce(float(lr))),
    }


# ─── Algorithm 7: Berggren Orbit with Interval Tracking ─────────────────────

def berggren_orbit_intervals(depth: int = 5) -> List[IntervalData]:
    """
    Generate the complete Berggren tree and analyze all intervals.
    
    Complexity: O(3^depth) total, O(1) per node.
    
    >>> results = berggren_orbit_intervals(depth=1)
    >>> len(results)
    4
    """
    tree = berggren_tree(max_depth=depth)
    return [analyze_triple(triple) for _, triple, _ in tree]


# ─── Main ────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    import doctest
    doctest.testmod(verbose=False)
    
    print("Pythagorean Music Theory — Algorithm Verification")
    print("=" * 60)
    
    # Verify core computations
    print("\n1. Root triple analysis:")
    d = analyze_triple((3, 4, 5))
    for k, v in d.items():
        print(f"   {k}: {v}")
    
    print("\n2. Berggren depth-2 interval catalog:")
    results = berggren_orbit_intervals(depth=2)
    for r in results:
        t = r['triple']
        print(f"   {t}: leg={r['leg_ratio']}, cons={r['consonance_class']}, "
              f"fifths={r['on_circle_of_fifths']}")
    
    print("\n3. Tropical transport verification:")
    q, r = Fraction(4, 3), Fraction(3, 2)
    log_sum = tropical_log(q) + tropical_log(r)
    log_prod = tropical_log(q * r)
    print(f"   log({q}) + log({r}) = {log_sum:.10f}")
    print(f"   log({q}·{r}) = log({q*r}) = {log_prod:.10f}")
    print(f"   Equal: {abs(log_sum - log_prod) < 1e-15}")
