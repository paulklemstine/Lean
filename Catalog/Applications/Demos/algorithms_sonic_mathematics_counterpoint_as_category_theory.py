"""
Algorithms for Counterpoint Category Theory

Type-hinted implementations of the core algorithms for analyzing
first-species counterpoint as a categorical structure.
"""

from typing import Set, Dict, List, Tuple, Optional
from dataclasses import dataclass


@dataclass(frozen=True)
class VoiceLeading:
    """A voice leading in mod-n pitch space."""
    bass_step: int
    treble_step: int
    n: int = 12

    @property
    def interval_change(self) -> int:
        return (self.treble_step - self.bass_step) % self.n

    @property
    def is_parallel(self) -> bool:
        return self.bass_step == self.treble_step and self.bass_step % self.n != 0

    def compose(self, other: 'VoiceLeading') -> 'VoiceLeading':
        """Sequential composition of voice leadings."""
        return VoiceLeading(
            bass_step=(self.bass_step + other.bass_step) % self.n,
            treble_step=(self.treble_step + other.treble_step) % self.n,
            n=self.n
        )


def consonant_intervals(n: int = 12) -> Set[int]:
    """Return the set of consonant intervals in n-TET.

    For standard 12-TET: {0, 3, 4, 7, 8, 9}
    For other n, uses a complexity-based consonance criterion.
    """
    if n == 12:
        return {0, 3, 4, 7, 8, 9}
    # General case: intervals whose simplest frequency ratio has
    # numerator + denominator ≤ 12
    result = {0}
    for i in range(1, n):
        # Approximate frequency ratio
        ratio = 2 ** (i / n)
        # Find best rational approximation
        best_p, best_q = 1, 1
        best_err = abs(ratio - 1)
        for q in range(1, 13):
            p = round(ratio * q)
            if p > 0:
                err = abs(ratio - p / q)
                if err < best_err:
                    best_err = err
                    best_p, best_q = p, q
        if best_p + best_q <= 12:
            result.add(i)
    return result


def perfect_consonances(n: int = 12) -> Set[int]:
    """Return perfect consonances (unison and fifth) in n-TET."""
    if n == 12:
        return {0, 7}
    # General: unison and the interval closest to 3:2 ratio
    fifth = round(n * 0.58496)  # log2(3/2) ≈ 0.585
    return {0, fifth % n}


def enumerate_valid_voice_leadings(
    consonant: Set[int],
    perfect: Set[int],
    n: int = 12
) -> Dict[Tuple[int, int], List[VoiceLeading]]:
    """Enumerate all valid voice leadings between consonant intervals.

    Algorithm:
    1. For each (source, target) pair of consonant intervals
    2. For each possible bass step b ∈ {0, ..., n-1}
    3. Compute treble step t = b + (target - source) mod n
    4. Check: if target is perfect, reject parallel motion (b = t ≠ 0)
    5. Collect all valid voice leadings

    Returns: Dict mapping (source, target) to list of valid VoiceLeadings

    Complexity: O(|C|² · n) where |C| = number of consonant intervals
    """
    result: Dict[Tuple[int, int], List[VoiceLeading]] = {}

    for s in sorted(consonant):
        for t in sorted(consonant):
            valid = []
            for b in range(n):
                treble = (b + (t - s)) % n
                vl = VoiceLeading(bass_step=b, treble_step=treble, n=n)

                # Check parallel-perfects rule
                if t in perfect and vl.is_parallel:
                    continue
                valid.append(vl)
            result[(s, t)] = valid

    return result


def compute_transition_matrix(
    consonant: Set[int],
    perfect: Set[int],
    n: int = 12
) -> Dict[Tuple[int, int], int]:
    """Compute the transition count matrix.

    Returns: Dict mapping (source, target) to number of valid voice leadings.
    """
    vls = enumerate_valid_voice_leadings(consonant, perfect, n)
    return {k: len(v) for k, v in vls.items()}


def find_composition_failures(
    consonant: Set[int],
    perfect: Set[int],
    n: int = 12
) -> List[Tuple[int, int, int, VoiceLeading, VoiceLeading]]:
    """Find all composition failures: pairs of valid VLs whose composition is invalid.

    Returns list of (source, middle, target, vl1, vl2) tuples where
    vl1 and vl2 are individually valid but vl1.compose(vl2) is invalid.
    """
    vls = enumerate_valid_voice_leadings(consonant, perfect, n)
    failures = []

    for (s, m), vl1_list in vls.items():
        for (m2, t), vl2_list in vls.items():
            if m2 != m:
                continue
            for vl1 in vl1_list:
                for vl2 in vl2_list:
                    comp = vl1.compose(vl2)
                    # Check if composition is valid
                    if comp.interval_change != (t - s) % n:
                        continue  # shouldn't happen
                    if t in perfect and comp.is_parallel:
                        failures.append((s, m, t, vl1, vl2))

    return failures


def analyze_n_tet(n: int) -> Dict:
    """Analyze counterpoint structure for n-TET tuning system.

    Returns analysis dict with counts and structural properties.
    """
    consonant = consonant_intervals(n)
    perfect = perfect_consonances(n)
    imperfect = consonant - perfect

    matrix = compute_transition_matrix(consonant, perfect, n)
    total_valid = sum(matrix.values())
    total_unrestricted = len(consonant) ** 2 * n

    failures = find_composition_failures(consonant, perfect, n)

    # Check inversion closure
    inv_closed = all(((n - i) % n) in consonant for i in consonant)

    return {
        "n": n,
        "consonant": sorted(consonant),
        "perfect": sorted(perfect),
        "imperfect": sorted(imperfect),
        "num_consonant": len(consonant),
        "total_valid": total_valid,
        "total_unrestricted": total_unrestricted,
        "deficit": total_unrestricted - total_valid,
        "num_composition_failures": len(failures),
        "is_category": len(failures) == 0,
        "inversion_closed": inv_closed,
        "transition_matrix": matrix,
    }


if __name__ == "__main__":
    # Demonstrate for standard 12-TET
    result = analyze_n_tet(12)
    print(f"12-TET Analysis:")
    print(f"  Consonant intervals: {result['consonant']}")
    print(f"  Perfect: {result['perfect']}, Imperfect: {result['imperfect']}")
    print(f"  Total valid VLs: {result['total_valid']}")
    print(f"  Deficit: {result['deficit']}")
    print(f"  Is a category: {result['is_category']}")
    print(f"  Composition failures: {result['num_composition_failures']}")
    print(f"  Inversion closed: {result['inversion_closed']}")

    # Compare different tuning systems
    print("\n--- Comparison across tuning systems ---")
    for n in [5, 7, 12, 19, 24, 31]:
        r = analyze_n_tet(n)
        cat = "✓" if r["is_category"] else "✗"
        print(f"  {n:2d}-TET: {r['num_consonant']} consonances, "
              f"{r['total_valid']}/{r['total_unrestricted']} valid VLs, "
              f"category={cat}")
