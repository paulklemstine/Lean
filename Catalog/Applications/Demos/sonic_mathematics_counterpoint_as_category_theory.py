#!/usr/bin/env python3
"""
Sonic Mathematics: Counterpoint as Category Theory — Numerical Demonstrations

This script demonstrates the five main theorems about first-species counterpoint
modeled as a directed graph (quiver) over consonant intervals in Z/12Z.

All computations use modular arithmetic over the integers mod 12.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Optional
from itertools import product


# ---------------------------------------------------------------------------
# Core Definitions
# ---------------------------------------------------------------------------

N = 12  # pitch classes in 12-TET

CONSONANT: set[int] = {0, 3, 4, 7, 8, 9}
PERFECT: set[int] = {0, 7}
IMPERFECT: set[int] = CONSONANT - PERFECT  # {3, 4, 8, 9}

INTERVAL_NAMES: dict[int, str] = {
    0: "Unison (P1/P8)",
    1: "minor 2nd",
    2: "Major 2nd",
    3: "minor 3rd",
    4: "Major 3rd",
    5: "Perfect 4th",
    6: "Tritone",
    7: "Perfect 5th",
    8: "minor 6th",
    9: "Major 6th",
    10: "minor 7th",
    11: "Major 7th",
}


@dataclass(frozen=True)
class VoiceLeading:
    """A voice leading: how much the bass and soprano each move (mod 12)."""
    bass: int
    soprano: int

    def __post_init__(self) -> None:
        object.__setattr__(self, "bass", self.bass % N)
        object.__setattr__(self, "soprano", self.soprano % N)

    @property
    def is_parallel(self) -> bool:
        """Parallel motion: both voices move by the same nonzero amount."""
        return self.bass == self.soprano and self.bass != 0

    def __repr__(self) -> str:
        return f"VL(bass={self.bass:+d}, sop={self.soprano:+d})"


def target_interval(source: int, vl: VoiceLeading) -> int:
    """Compute the target interval: source + soprano - bass (mod 12)."""
    return (source + vl.soprano - vl.bass) % N


def is_permitted(source: int, target: int, vl: VoiceLeading) -> bool:
    """Check if a voice leading is permitted under first-species rules."""
    return (
        source in CONSONANT
        and target in CONSONANT
        and target_interval(source, vl) == target
        and not (target in PERFECT and vl.is_parallel)
    )


def canonical_vl(source: int, target: int) -> VoiceLeading:
    """The canonical voice leading: bass stays, soprano moves by target - source."""
    return VoiceLeading(bass=0, soprano=(target - source) % N)


# ---------------------------------------------------------------------------
# Enumerate all permitted voice leadings
# ---------------------------------------------------------------------------

def all_voice_leadings() -> list[VoiceLeading]:
    """Return all 144 possible voice leadings over Z/12Z."""
    return [VoiceLeading(b, s) for b, s in product(range(N), repeat=2)]


def permitted_voice_leadings(source: int, target: int) -> list[VoiceLeading]:
    """Return all permitted voice leadings from source to target."""
    return [vl for vl in all_voice_leadings() if is_permitted(source, target, vl)]


# ---------------------------------------------------------------------------
# Theorem 1: Strong Connectivity
# ---------------------------------------------------------------------------

def demo_strong_connectivity() -> None:
    """Demonstrate that between any two consonant intervals, a permitted VL exists."""
    print("=" * 70)
    print("THEOREM 1: Strong Connectivity of the Counterpoint Quiver")
    print("=" * 70)
    print()
    print("For every pair (i, j) of consonant intervals, we exhibit a permitted")
    print("voice leading from i to j.")
    print()

    all_connected = True
    for i in sorted(CONSONANT):
        for j in sorted(CONSONANT):
            pvls = permitted_voice_leadings(i, j)
            status = f"✓ {len(pvls):2d} VLs" if pvls else "✗ NONE"
            if not pvls:
                all_connected = False
            cvl = canonical_vl(i, j)
            print(
                f"  {INTERVAL_NAMES[i]:16s} → {INTERVAL_NAMES[j]:16s}: "
                f"{status}  (canonical: {cvl})"
            )

    print()
    print(f"  Strong connectivity verified: {all_connected}")
    print()


# ---------------------------------------------------------------------------
# Theorem 2: Non-Composability
# ---------------------------------------------------------------------------

def compose(vl1: VoiceLeading, vl2: VoiceLeading) -> VoiceLeading:
    """Compose two voice leadings by adding motions."""
    return VoiceLeading((vl1.bass + vl2.bass) % N, (vl1.soprano + vl2.soprano) % N)


def demo_non_composability() -> None:
    """Find explicit witness: two permitted VLs whose composite is not permitted."""
    print("=" * 70)
    print("THEOREM 2: Non-Composability of Permitted Voice Leadings")
    print("=" * 70)
    print()
    print("We search for i→j→k where vl₁ (i→j) and vl₂ (j→k) are permitted")
    print("but their composite vl₁∘vl₂ is NOT permitted from i to k.")
    print()

    witnesses_found = 0
    for i in sorted(CONSONANT):
        for j in sorted(CONSONANT):
            for k in sorted(CONSONANT):
                for vl1 in permitted_voice_leadings(i, j):
                    for vl2 in permitted_voice_leadings(j, k):
                        comp = compose(vl1, vl2)
                        comp_target = target_interval(i, comp)
                        if comp_target == k and not is_permitted(i, k, comp):
                            witnesses_found += 1
                            if witnesses_found <= 5:
                                print(f"  WITNESS #{witnesses_found}:")
                                print(f"    {INTERVAL_NAMES[i]} →({vl1})→ "
                                      f"{INTERVAL_NAMES[j]} →({vl2})→ "
                                      f"{INTERVAL_NAMES[k]}")
                                print(f"    Composite: {comp}")
                                why = "parallel into perfect" if (
                                    k in PERFECT and comp.is_parallel
                                ) else "other rule"
                                print(f"    Forbidden because: {why}")
                                print()

    print(f"  Total non-composable witnesses found: {witnesses_found}")
    print(f"  Non-composability verified: {witnesses_found > 0}")
    print()


# ---------------------------------------------------------------------------
# Theorem 3: Perfect Consonance Bottleneck (Self-Loops)
# ---------------------------------------------------------------------------

def demo_self_loop_bottleneck() -> None:
    """Show that perfect consonances have 1 self-loop, imperfect have 12."""
    print("=" * 70)
    print("THEOREM 3: Perfect-Consonance Bottleneck (Self-Loops)")
    print("=" * 70)
    print()

    for j in sorted(CONSONANT):
        loops = permitted_voice_leadings(j, j)
        kind = "PERFECT" if j in PERFECT else "imperfect"
        print(f"  {INTERVAL_NAMES[j]:16s} ({kind:9s}): {len(loops):2d} self-loops")
        if j in PERFECT:
            print(f"    → Only the identity VL(bass=0, sop=0) is allowed")
            for vl in loops:
                print(f"       {vl}")

    print()
    print("  Perfect consonances: 1 self-loop (the identity)  — RIGID")
    print("  Imperfect consonances: 12 self-loops              — FLEXIBLE")
    print("  Ratio: 12:1 — maximum possible disparity")
    print()


# ---------------------------------------------------------------------------
# Theorem 4: Voice-Swap Asymmetry
# ---------------------------------------------------------------------------

def demo_voice_swap_asymmetry() -> None:
    """Show that i ↦ -i does not preserve consonance."""
    print("=" * 70)
    print("THEOREM 4: Voice-Swap Breaks Consonance")
    print("=" * 70)
    print()
    print("The involution ι(i) = -i mod 12 (swapping bass and soprano roles)")
    print("does NOT preserve the consonant set.")
    print()

    for i in sorted(CONSONANT):
        neg_i = (-i) % N
        preserved = neg_i in CONSONANT
        marker = "  ✓" if preserved else "  ✗ BROKEN"
        print(
            f"  ι({i:2d}) = {neg_i:2d}  "
            f"({INTERVAL_NAMES[i]:16s} → {INTERVAL_NAMES[neg_i]:16s})"
            f"{marker}"
        )

    print()
    print("  Key: ι(7) = 5.  Perfect fifth → Perfect fourth (DISSONANT)")
    print("  The bass voice has a privileged, asymmetric role.")
    print()


# ---------------------------------------------------------------------------
# Theorem 5: Hom-Set Cardinalities
# ---------------------------------------------------------------------------

def demo_hom_set_cardinalities() -> None:
    """Compute total incoming permitted VLs for perfect vs imperfect targets."""
    print("=" * 70)
    print("THEOREM 5: Hom-Set Cardinalities")
    print("=" * 70)
    print()
    print("Total permitted voice leadings arriving at each consonant interval")
    print("(from all 6 consonant sources):")
    print()

    for j in sorted(CONSONANT):
        total = sum(len(permitted_voice_leadings(i, j)) for i in sorted(CONSONANT))
        kind = "PERFECT" if j in PERFECT else "imperfect"
        print(f"  → {INTERVAL_NAMES[j]:16s} ({kind:9s}): {total:3d} incoming VLs")

    print()
    # Aggregate
    perfect_totals = []
    imperfect_totals = []
    for j in sorted(CONSONANT):
        total = sum(len(permitted_voice_leadings(i, j)) for i in sorted(CONSONANT))
        if j in PERFECT:
            perfect_totals.append(total)
        else:
            imperfect_totals.append(total)

    p_avg = sum(perfect_totals) / len(perfect_totals)
    i_avg = sum(imperfect_totals) / len(imperfect_totals)
    reduction = (1 - p_avg / i_avg) * 100

    print(f"  Average incoming to PERFECT consonances:   {p_avg:.1f}")
    print(f"  Average incoming to IMPERFECT consonances:  {i_avg:.1f}")
    print(f"  Reduction: {reduction:.1f}% fewer paths lead to perfect consonances")
    print()


# ---------------------------------------------------------------------------
# Bonus: Full Quiver Statistics
# ---------------------------------------------------------------------------

def demo_quiver_statistics() -> None:
    """Print summary statistics of the full counterpoint quiver."""
    print("=" * 70)
    print("BONUS: Full Counterpoint Quiver Statistics")
    print("=" * 70)
    print()

    total_edges = 0
    hom_matrix: dict[tuple[int, int], int] = {}
    for i in sorted(CONSONANT):
        for j in sorted(CONSONANT):
            count = len(permitted_voice_leadings(i, j))
            hom_matrix[(i, j)] = count
            total_edges += count

    print(f"  Vertices: {len(CONSONANT)} consonant intervals")
    print(f"  Total edges (permitted voice leadings): {total_edges}")
    print(f"  Edge density: {total_edges / (len(CONSONANT)**2 * N**2) * 100:.1f}% "
          f"of all possible VLs")
    print()

    # Hom-set matrix
    header = "  Hom |" + "".join(f" {j:3d}" for j in sorted(CONSONANT))
    print(header)
    print("  " + "-" * (len(header) - 2))
    for i in sorted(CONSONANT):
        row = f"   {i:2d} |" + "".join(
            f" {hom_matrix[(i, j)]:3d}" for j in sorted(CONSONANT)
        )
        print(row)

    print()
    print("  Row = source interval, Column = target interval")
    print("  Each entry = number of permitted voice leadings")
    print()


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     SONIC MATHEMATICS: Counterpoint as Category Theory             ║")
    print("║     Numerical Demonstrations of the Five Main Theorems             ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_strong_connectivity()
    demo_non_composability()
    demo_self_loop_bottleneck()
    demo_voice_swap_asymmetry()
    demo_hom_set_cardinalities()
    demo_quiver_statistics()

    print("All demonstrations complete.")
    print()


if __name__ == "__main__":
    main()
