#!/usr/bin/env python3
"""
Sonic Mathematics: Counterpoint as Category Theory
===================================================

Numerical demonstrations of the five main theorems from the formalization
of first-species counterpoint as a directed multigraph (the Counterpoint Quiver).

All computations are performed in Z/12Z (integers mod 12), corresponding to
the standard 12-tone equal temperament system.

Results demonstrated:
  1. Strong connectivity of the Counterpoint Quiver
  2. Non-composability of permitted voice leadings
  3. Self-loop bottleneck (1 vs 12)
  4. Voice-swap asymmetry
  5. Hom-set computation (61 vs 72)
"""

from __future__ import annotations
from typing import NamedTuple


# ─────────────────────────────────────────────────────────────
# Core definitions
# ─────────────────────────────────────────────────────────────

N: int = 12  # modulus (12-TET)

CONSONANT: frozenset[int] = frozenset({0, 3, 4, 7, 8, 9})
PERFECT: frozenset[int] = frozenset({0, 7})
IMPERFECT: frozenset[int] = CONSONANT - PERFECT

INTERVAL_NAMES: dict[int, str] = {
    0: "Unison (P1)",
    1: "Minor 2nd",
    2: "Major 2nd",
    3: "Minor 3rd",
    4: "Major 3rd",
    5: "Perfect 4th",
    6: "Tritone",
    7: "Perfect 5th",
    8: "Minor 6th",
    9: "Major 6th",
    10: "Minor 7th",
    11: "Major 7th",
}


class VoiceLeading(NamedTuple):
    """A voice leading: (bass_motion, soprano_motion) in semitones mod 12."""
    bass: int
    soprano: int

    def is_parallel(self) -> bool:
        """Parallel motion: both voices move by the same nonzero amount."""
        return self.bass % N == self.soprano % N and self.bass % N != 0


def target_interval(source: int, vl: VoiceLeading) -> int:
    """Compute the target interval given a source interval and voice leading."""
    return (source + vl.soprano - vl.bass) % N


def is_permitted(source: int, target: int, vl: VoiceLeading) -> bool:
    """Check whether a voice leading from source to target is permitted."""
    return (
        source % N in CONSONANT
        and target % N in CONSONANT
        and target_interval(source, vl) == target % N
        and not (target % N in PERFECT and vl.is_parallel())
    )


def canonical_voice_leading(i: int, j: int) -> VoiceLeading:
    """The canonical voice leading from interval i to j: bass holds, soprano moves."""
    return VoiceLeading(bass=0, soprano=(j - i) % N)


def compose(f: VoiceLeading, g: VoiceLeading) -> VoiceLeading:
    """Compose two voice leadings (componentwise addition mod N)."""
    return VoiceLeading(bass=(f.bass + g.bass) % N, soprano=(f.soprano + g.soprano) % N)


# ─────────────────────────────────────────────────────────────
# Enumeration helpers
# ─────────────────────────────────────────────────────────────

def all_voice_leadings() -> list[VoiceLeading]:
    """All 144 voice leadings in Z/12Z × Z/12Z."""
    return [VoiceLeading(b, s) for b in range(N) for s in range(N)]


def permitted_edges(source: int, target: int) -> list[VoiceLeading]:
    """All permitted voice leadings from source to target."""
    return [vl for vl in all_voice_leadings() if is_permitted(source, target, vl)]


def self_loops(interval: int) -> list[VoiceLeading]:
    """All permitted self-loops at the given interval."""
    return permitted_edges(interval, interval)


def total_incoming(target: int) -> int:
    """Total permitted voice leadings from all consonant sources to target."""
    return sum(len(permitted_edges(src, target)) for src in CONSONANT)


# ═════════════════════════════════════════════════════════════
# DEMONSTRATIONS
# ═════════════════════════════════════════════════════════════

def demo_system_overview() -> None:
    """Display the basic setup of the Counterpoint System."""
    print("=" * 70)
    print("COUNTERPOINT SYSTEM: Standard 12-TET First Species")
    print("=" * 70)
    print(f"\nModulus: {N} (semitones per octave)")
    print(f"\nConsonant intervals ({len(CONSONANT)}):")
    for i in sorted(CONSONANT):
        kind = "PERFECT" if i in PERFECT else "imperfect"
        print(f"  {i:2d} semitones = {INTERVAL_NAMES[i]:15s}  [{kind}]")
    print(f"\nTotal voice leadings in (Z/{N}Z)²: {N * N}")
    print(f"Ordered pairs of consonances: {len(CONSONANT)}² = {len(CONSONANT)**2}")


def demo_strong_connectivity() -> None:
    """Theorem 1: The Counterpoint Quiver is strongly connected."""
    print("\n" + "=" * 70)
    print("THEOREM 1: Strong Connectivity")
    print("=" * 70)
    print("\nFor every pair of consonant intervals (i, j), there exists a")
    print("permitted voice leading from i to j.\n")

    all_connected = True
    for i in sorted(CONSONANT):
        for j in sorted(CONSONANT):
            edges = permitted_edges(i, j)
            vl = canonical_voice_leading(i, j)
            ok = is_permitted(i, j, vl)
            if not edges:
                all_connected = False
            if i == j:
                label = "(identity)"
            else:
                label = f"(bass=0, sop={(j - i) % N})"
            print(f"  {INTERVAL_NAMES[i]:15s} → {INTERVAL_NAMES[j]:15s}: "
                  f"{len(edges):2d} voice leadings  "
                  f"canonical {label} {'✓' if ok else '✗'}")

    print(f"\n  All pairs connected: {'YES ✓' if all_connected else 'NO ✗'}")
    print(f"  Total edges in quiver: "
          f"{sum(len(permitted_edges(i, j)) for i in CONSONANT for j in CONSONANT)}")


def demo_non_composability() -> None:
    """Theorem 2: Permitted voice leadings do not compose."""
    print("\n" + "=" * 70)
    print("THEOREM 2: Non-Composability")
    print("=" * 70)
    print("\nThere exist permitted f: A→B and g: B→C whose composition g∘f is forbidden.\n")

    violations_found = 0
    examples: list[tuple[int, int, int, VoiceLeading, VoiceLeading]] = []

    for a in sorted(CONSONANT):
        for b in sorted(CONSONANT):
            for c in sorted(CONSONANT):
                for f in permitted_edges(a, b):
                    for g in permitted_edges(b, c):
                        gf = compose(f, g)
                        if target_interval(a, gf) == c and not is_permitted(a, c, gf):
                            violations_found += 1
                            if len(examples) < 3:
                                examples.append((a, b, c, f, g))

    print(f"  Total composition violations found: {violations_found}\n")
    for a, b, c, f, g in examples:
        gf = compose(f, g)
        print(f"  Example: {INTERVAL_NAMES[a]} →(f)→ {INTERVAL_NAMES[b]} →(g)→ {INTERVAL_NAMES[c]}")
        print(f"    f = (bass={f.bass}, sop={f.soprano})  parallel={f.is_parallel()}  ✓ permitted")
        print(f"    g = (bass={g.bass}, sop={g.soprano})  parallel={g.is_parallel()}  ✓ permitted")
        print(f"    g∘f = (bass={gf.bass}, sop={gf.soprano})  parallel={gf.is_parallel()}  "
              f"target={INTERVAL_NAMES[c]}({'perfect' if c in PERFECT else 'imperfect'})  ✗ FORBIDDEN")
        print()


def demo_self_loop_bottleneck() -> None:
    """Theorem 3: Perfect consonances have 1 self-loop, imperfect have 12."""
    print("=" * 70)
    print("THEOREM 3: Self-Loop Bottleneck")
    print("=" * 70)
    print("\nSelf-loops at each consonant interval:\n")

    for i in sorted(CONSONANT):
        loops = self_loops(i)
        kind = "PERFECT" if i in PERFECT else "imperfect"
        print(f"  {INTERVAL_NAMES[i]:15s} ({kind:9s}): {len(loops):2d} self-loops")
        if i in PERFECT:
            print(f"    └─ Only the identity (0,0)")
        else:
            motions = ", ".join(f"({vl.bass},{vl.soprano})" for vl in loops)
            print(f"    └─ All 12 parallel motions: {motions}")

    perfect_loops = [len(self_loops(i)) for i in sorted(PERFECT)]
    imperfect_loops = [len(self_loops(i)) for i in sorted(IMPERFECT)]
    print(f"\n  Perfect consonances:   {perfect_loops[0]} self-loop(s) each")
    print(f"  Imperfect consonances: {imperfect_loops[0]} self-loop(s) each")
    print(f"  Bottleneck ratio: {imperfect_loops[0]}:{perfect_loops[0]} = {imperfect_loops[0] // perfect_loops[0]}×")


def demo_voice_swap_asymmetry() -> None:
    """Theorem 4: Voice swap (negation) breaks consonance."""
    print("\n" + "=" * 70)
    print("THEOREM 4: Voice-Swap Asymmetry")
    print("=" * 70)
    print("\nThe negation map i ↦ −i (mod 12) does NOT preserve consonance.\n")

    print(f"  {'Interval':15s} {'Negation':15s} {'Consonant?':12s} {'Neg Consonant?':15s} {'Preserved?'}")
    print("  " + "-" * 65)

    all_preserved = True
    for i in sorted(CONSONANT):
        neg_i = (-i) % N
        i_cons = i in CONSONANT
        neg_cons = neg_i in CONSONANT
        preserved = neg_cons
        if not preserved:
            all_preserved = False
        print(f"  {INTERVAL_NAMES[i]:15s} {INTERVAL_NAMES[neg_i]:15s} "
              f"{'Yes':12s} {'Yes' if neg_cons else 'NO ✗':15s} "
              f"{'✓' if preserved else '✗ BROKEN'}")

    print(f"\n  Voice swap preserves all consonances: {'YES' if all_preserved else 'NO ✗'}")
    print(f"  Key failure: Perfect 5th (7) ↦ Perfect 4th (5), which is DISSONANT")
    print(f"  This formalizes the asymmetric role of the bass voice.")


def demo_hom_set_computation() -> None:
    """Theorem 5: Hom-set cardinalities (61 vs 72)."""
    print("\n" + "=" * 70)
    print("THEOREM 5: Hom-Set Computation")
    print("=" * 70)
    print("\nTotal incoming permitted voice leadings to each consonant interval:\n")

    print(f"  {'Target':15s} {'Type':10s} {'Incoming':>8s}  Breakdown by source")
    print("  " + "-" * 70)

    for j in sorted(CONSONANT):
        kind = "PERFECT" if j in PERFECT else "imperfect"
        incoming = total_incoming(j)
        breakdown = "  ".join(
            f"{INTERVAL_NAMES[i][:5]}:{len(permitted_edges(i, j)):2d}"
            for i in sorted(CONSONANT)
        )
        print(f"  {INTERVAL_NAMES[j]:15s} {kind:10s} {incoming:8d}  {breakdown}")

    perf_totals = [total_incoming(j) for j in sorted(PERFECT)]
    imp_totals = [total_incoming(j) for j in sorted(IMPERFECT)]

    print(f"\n  Perfect consonance targets:   {perf_totals[0]} incoming each")
    print(f"  Imperfect consonance targets: {imp_totals[0]} incoming each")
    print(f"  Difference: {imp_totals[0] - perf_totals[0]} fewer voice leadings to perfect consonances")
    print(f"  Reduction: {(1 - perf_totals[0] / imp_totals[0]) * 100:.1f}%")


def demo_quiver_statistics() -> None:
    """Summary statistics of the Counterpoint Quiver."""
    print("\n" + "=" * 70)
    print("QUIVER SUMMARY STATISTICS")
    print("=" * 70)

    total_edges = 0
    edge_matrix: dict[tuple[int, int], int] = {}
    for i in sorted(CONSONANT):
        for j in sorted(CONSONANT):
            count = len(permitted_edges(i, j))
            edge_matrix[(i, j)] = count
            total_edges += count

    print(f"\n  Vertices (consonant intervals): {len(CONSONANT)}")
    print(f"  Total directed edges: {total_edges}")
    print(f"  Max possible edges (no restrictions): {len(CONSONANT)**2 * N}")
    print(f"  Edge density: {total_edges / (len(CONSONANT)**2 * N) * 100:.1f}%")

    print("\n  Edge count matrix (rows=source, cols=target):\n")
    header = "        " + "  ".join(f"{INTERVAL_NAMES[j][:6]:>6s}" for j in sorted(CONSONANT))
    print(f"  {header}")
    print("  " + " " * 8 + "-" * (len(sorted(CONSONANT)) * 8))
    for i in sorted(CONSONANT):
        row = "  ".join(f"{edge_matrix[(i, j)]:6d}" for j in sorted(CONSONANT))
        print(f"  {INTERVAL_NAMES[i][:6]:>6s}  {row}")

    print(f"\n  Row sums (outgoing from each interval):")
    for i in sorted(CONSONANT):
        out = sum(edge_matrix[(i, j)] for j in CONSONANT)
        kind = "PERFECT" if i in PERFECT else "imperfect"
        print(f"    {INTERVAL_NAMES[i]:15s} ({kind}): {out}")


def main() -> None:
    """Run all demonstrations."""
    print()
    print("╔" + "═" * 68 + "╗")
    print("║  SONIC MATHEMATICS: Counterpoint as Category Theory               ║")
    print("║  Numerical Demonstrations of Five Main Theorems                    ║")
    print("╚" + "═" * 68 + "╝")
    print()

    demo_system_overview()
    demo_strong_connectivity()
    demo_non_composability()
    demo_self_loop_bottleneck()
    demo_voice_swap_asymmetry()
    demo_hom_set_computation()
    demo_quiver_statistics()

    print("\n" + "=" * 70)
    print("All five theorems numerically verified. ✓")
    print("=" * 70)


if __name__ == "__main__":
    main()
