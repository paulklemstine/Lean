#!/usr/bin/env python3
"""
Algorithms for Counterpoint Category Theory

Type-hinted implementations of the core algorithms used in the
formalization and analysis of first-species counterpoint as a category.
"""

from typing import NamedTuple, List, Set, Tuple, Dict
from enum import Enum, auto


class MotionType(Enum):
    CONTRARY = auto()
    OBLIQUE = auto()
    SIMILAR = auto()
    PARALLEL = auto()


class VoiceLeading(NamedTuple):
    source: int       # interval class (0-11)
    target: int       # interval class (0-11)
    bass_step: int    # integer step in semitones
    soprano_step: int # integer step in semitones


CONSONANT: Set[int] = {0, 3, 4, 7, 8, 9}
PERFECT: Set[int] = {0, 7}
IMPERFECT: Set[int] = {3, 4, 8, 9}


def interval_change(vl: VoiceLeading) -> int:
    """Compute the interval change mod 12."""
    return (vl.soprano_step - vl.bass_step) % 12


def is_coherent(vl: VoiceLeading) -> bool:
    """Check if a voice leading is coherent (transforms source to target)."""
    return (vl.source + interval_change(vl)) % 12 == vl.target


def classify_motion(vl: VoiceLeading) -> MotionType:
    """Classify the motion type of a voice leading.
    
    Algorithm:
    1. If both voices move by same amount → parallel
    2. If either voice is stationary → oblique
    3. If voices move in opposite directions → contrary
    4. Otherwise → similar
    """
    if vl.bass_step == vl.soprano_step:
        return MotionType.PARALLEL
    if vl.bass_step == 0 or vl.soprano_step == 0:
        return MotionType.OBLIQUE
    if (vl.bass_step > 0) != (vl.soprano_step > 0):
        return MotionType.CONTRARY
    return MotionType.SIMILAR


def is_valid_first_species(vl: VoiceLeading) -> bool:
    """Check if a voice leading satisfies first-species counterpoint rules.
    
    Algorithm:
    1. Check source and target are consonant
    2. Check coherence
    3. No non-trivial parallel motion to perfect consonances
    4. No similar motion to perfect consonances
    """
    if vl.source not in CONSONANT or vl.target not in CONSONANT:
        return False
    if not is_coherent(vl):
        return False
    motion = classify_motion(vl)
    if motion == MotionType.PARALLEL and vl.bass_step != 0:
        if vl.target in PERFECT:
            return False
    if motion == MotionType.SIMILAR:
        if vl.target in PERFECT:
            return False
    return True


def circle_distance(i: int) -> int:
    """Compute the circle distance of an interval class.
    
    min(i mod 12, 12 - (i mod 12))
    """
    v = i % 12
    return min(v, 12 - v)


def enumerate_valid_voice_leadings(max_step: int = 12) -> List[VoiceLeading]:
    """Enumerate all valid first-species voice leadings with bounded step size.
    
    Algorithm:
    For each (source, target) pair of consonant intervals,
    for each (bass_step, soprano_step) with |step| <= max_step,
    check validity.
    
    Returns sorted list of valid voice leadings.
    """
    results: List[VoiceLeading] = []
    for source in sorted(CONSONANT):
        for target in sorted(CONSONANT):
            for bass in range(-max_step, max_step + 1):
                for soprano in range(-max_step, max_step + 1):
                    vl = VoiceLeading(source, target, bass, soprano)
                    if is_valid_first_species(vl):
                        results.append(vl)
    return results


def count_morphisms_by_type(max_step: int = 12) -> Dict[MotionType, int]:
    """Count valid voice leadings by motion type.
    
    Returns a dictionary mapping each motion type to its count.
    """
    counts: Dict[MotionType, int] = {m: 0 for m in MotionType}
    for vl in enumerate_valid_voice_leadings(max_step):
        counts[classify_motion(vl)] += 1
    return counts


def find_contrary_witness(a: int, b: int) -> VoiceLeading:
    """Find a contrary-motion voice leading from interval a to interval b.
    
    Algorithm:
    Set bass_step = -1, soprano_step = (b - a - 1) mod 12.
    If soprano_step <= 0, add 12 to ensure positive.
    This gives contrary motion (bass down, soprano up).
    """
    diff = (b - a) % 12
    bass = -1
    soprano = diff + bass  # soprano - bass = diff
    if soprano <= 0:
        soprano += 12
    return VoiceLeading(a, b, bass, soprano)


def compose_voice_leadings(f: VoiceLeading, g: VoiceLeading) -> VoiceLeading:
    """Compose two voice leadings sequentially (f then g).
    
    Requires f.target == g.source for coherence.
    """
    assert f.target == g.source, "Voice leadings not composable"
    return VoiceLeading(
        source=f.source,
        target=g.target,
        bass_step=f.bass_step + g.bass_step,
        soprano_step=f.soprano_step + g.soprano_step
    )


def consonance_preorder_levels() -> Dict[int, List[int]]:
    """Compute the levels of the consonance preorder.
    
    Groups consonant intervals by their circle distance.
    """
    levels: Dict[int, List[int]] = {}
    for i in sorted(CONSONANT):
        d = circle_distance(i)
        levels.setdefault(d, []).append(i)
    return dict(sorted(levels.items()))


def compute_morphism_matrix() -> List[List[Tuple[int, int]]]:
    """Compute the morphism count matrix.
    
    Returns a 6x6 matrix where entry (i,j) is (n_abstract_motions, n_concrete_with_step_1).
    """
    consonant_list = sorted(CONSONANT)
    matrix = []
    for a in consonant_list:
        row = []
        for b in consonant_list:
            # Abstract motion count
            n_abstract = 4 if b not in PERFECT else 2
            # Concrete count with |step| <= 1
            n_concrete = sum(1 for bs in range(-1, 2) for ss in range(-1, 2)
                           if is_valid_first_species(VoiceLeading(a, b, bs, ss)))
            row.append((n_abstract, n_concrete))
        matrix.append(row)
    return matrix


if __name__ == "__main__":
    print("Morphisms by type (max_step=2):")
    counts = count_morphisms_by_type(max_step=2)
    for m, c in counts.items():
        print(f"  {m.name}: {c}")
    
    print("\nConsonance preorder levels:")
    for d, intervals in consonance_preorder_levels().items():
        names = {0: "P1", 3: "m3", 4: "M3", 7: "P5", 8: "m6", 9: "M6"}
        print(f"  Distance {d}: {[names.get(i, str(i)) for i in intervals]}")
    
    print("\nContrary motion witnesses:")
    for a in sorted(CONSONANT):
        for b in sorted(CONSONANT):
            vl = find_contrary_witness(a, b)
            assert is_valid_first_species(vl), f"Witness invalid for {a}→{b}"
    print("  All 36 witnesses verified ✓")
