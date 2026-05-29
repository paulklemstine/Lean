#!/usr/bin/env python3
"""
Applications of Functorial Localization to Topological Data Analysis

This module demonstrates real-world applications:
1. Primewise denoising of persistence signals
2. Arithmetic spectral filtering for barcode refinement
3. Localization-based comparison of persistence modules
"""

import random
from collections import defaultdict
from typing import Dict, List, Set, Tuple, Optional


# ── Inline core classes ──────────────────────────────────────────

class FGAbGroup:
    def __init__(self, free_rank=0, torsion_parts=None):
        self.free_rank = free_rank
        self.torsion_parts = torsion_parts or {}

    def has_p_torsion(self, p):
        return p in self.torsion_parts and len(self.torsion_parts[p]) > 0

    def has_any_torsion(self):
        return any(len(e) > 0 for e in self.torsion_parts.values())

    def localize_at(self, p):
        t = {p: list(self.torsion_parts[p])} if p in self.torsion_parts else {}
        return FGAbGroup(free_rank=self.free_rank, torsion_parts=t)

    def __repr__(self):
        parts = []
        if self.free_rank > 0:
            parts.append(f"Z^{self.free_rank}")
        for p in sorted(self.torsion_parts):
            for e in self.torsion_parts[p]:
                parts.append(f"Z/{p}^{e}" if e > 1 else f"Z/{p}")
        return " + ".join(parts) if parts else "0"


class ZPersModule:
    def __init__(self, groups, support_range):
        self.groups = groups
        self.support_range = support_range

    def obj(self, i):
        return self.groups.get(i, FGAbGroup())

    def has_p_torsion_at(self, p, i):
        return self.obj(i).has_p_torsion(p)

    def has_torsion_at(self, i):
        return self.obj(i).has_any_torsion()

    def localize_at(self, p):
        ng = {}
        for idx, grp in self.groups.items():
            loc = grp.localize_at(p)
            if loc.free_rank > 0 or loc.has_any_torsion():
                ng[idx] = loc
        return ZPersModule(groups=ng, support_range=self.support_range)


def p_torsion_birth(F, p):
    lo, hi = F.support_range
    for i in range(lo, hi + 1):
        if F.has_p_torsion_at(p, i):
            if all(not F.has_p_torsion_at(p, j) for j in range(lo, i)):
                return i
    return None


def torsion_birth(F):
    lo, hi = F.support_range
    for i in range(lo, hi + 1):
        if F.has_torsion_at(i):
            if all(not F.has_torsion_at(j) for j in range(lo, i)):
                return i
    return None


# ── Application 1: Primewise Denoising ───────────────────────────

def primewise_denoise(F: ZPersModule, signal_prime: int,
                       noise_primes: List[int]) -> ZPersModule:
    """Remove torsion noise at specific primes.

    In topological data analysis, persistence modules computed over ℤ
    may contain torsion at multiple primes. Some of this torsion reflects
    genuine topological features (signal), while other torsion is computational
    noise.

    Localization at the signal prime removes all noise-prime torsion while
    preserving the signal exactly.

    Args:
        F: Input persistence module
        signal_prime: The prime whose torsion we want to keep
        noise_primes: Primes considered as noise

    Returns:
        Denoised persistence module (localization at signal_prime)
    """
    return F.localize_at(signal_prime)


def demo_denoising():
    print("=" * 60)
    print("APPLICATION 1: Primewise Denoising")
    print("=" * 60)

    # A persistence module with signal at p=2 and noise at p=3,5
    F = ZPersModule(
        groups={
            0: FGAbGroup(free_rank=1),
            1: FGAbGroup(free_rank=1, torsion_parts={3: [1]}),  # noise
            2: FGAbGroup(free_rank=1, torsion_parts={2: [1], 3: [1]}),  # signal + noise
            3: FGAbGroup(free_rank=1, torsion_parts={2: [1], 3: [1], 5: [1]}),  # more noise
        },
        support_range=(0, 3)
    )

    print("\nOriginal module (signal at p=2, noise at p=3,5):")
    for i in range(4):
        print(f"  F({i}) = {F.obj(i)}")
    print(f"  Global torsion birth: {torsion_birth(F)}")
    print(f"  2-torsion birth (signal): {p_torsion_birth(F, 2)}")

    denoised = primewise_denoise(F, signal_prime=2, noise_primes=[3, 5])
    print("\nDenoised (localized at p=2):")
    for i in range(4):
        print(f"  Loc_2(F)({i}) = {denoised.obj(i)}")
    print(f"  Torsion birth after denoising: {torsion_birth(denoised)}")
    print(f"  → Noise removed, signal preserved!")


# ── Application 2: Arithmetic Spectral Analysis ──────────────────

def spectral_decomposition(F: ZPersModule,
                            primes: List[int]) -> Dict[int, Optional[int]]:
    """Decompose torsion births into prime channels.

    This implements the arithmetic spectral analysis: each prime
    provides an independent "frequency channel" for torsion information.
    The global torsion birth is the minimum across all channels.

    Returns:
        Dict mapping each prime to its birth index (or None if no torsion)
    """
    spectrum = {}
    for p in primes:
        spectrum[p] = p_torsion_birth(F, p)
    return spectrum


def demo_spectral_analysis():
    print("\n" + "=" * 60)
    print("APPLICATION 2: Arithmetic Spectral Analysis")
    print("=" * 60)

    # Module with different torsion appearing at different times
    F = ZPersModule(
        groups={
            0: FGAbGroup(free_rank=2),
            1: FGAbGroup(free_rank=2),
            2: FGAbGroup(free_rank=1, torsion_parts={7: [1]}),
            3: FGAbGroup(free_rank=1, torsion_parts={7: [1]}),
            4: FGAbGroup(free_rank=1, torsion_parts={2: [1], 7: [1]}),
            5: FGAbGroup(free_rank=1, torsion_parts={2: [1, 2], 3: [1], 7: [1]}),
            6: FGAbGroup(free_rank=1, torsion_parts={2: [1, 2], 3: [1], 5: [1], 7: [1]}),
        },
        support_range=(0, 6)
    )

    print("\nPersistence module with staggered torsion:")
    for i in range(7):
        g = F.obj(i)
        if g.free_rank > 0 or g.has_any_torsion():
            print(f"  F({i}) = {g}")

    primes = [2, 3, 5, 7, 11]
    spectrum = spectral_decomposition(F, primes)

    print("\nPrime spectrum (birth indices by channel):")
    for p, birth in sorted(spectrum.items()):
        status = f"birth at index {birth}" if birth is not None else "no torsion"
        bar = "█" * (birth if birth is not None else 0)
        print(f"  p={p:2d}: {status:20s}  |{bar}")

    global_birth = torsion_birth(F)
    active_births = [b for b in spectrum.values() if b is not None]
    print(f"\n  Global birth: {global_birth} = min({active_births})")
    print(f"  → Each prime reveals different topological features!")


# ── Application 3: Localization-Based Comparison ──────────────────

def localization_comparison(F: ZPersModule, G: ZPersModule,
                             primes: List[int]) -> Dict[int, Optional[int]]:
    """Compare two persistence modules via primewise localization.

    For each prime p, compute the distance between p-torsion births.
    This gives a finer comparison than the global torsion birth distance.

    Returns:
        Dict mapping primes to primewise distances (None if both empty)
    """
    distances = {}
    for p in primes:
        b1 = p_torsion_birth(F, p)
        b2 = p_torsion_birth(G, p)
        if b1 is not None and b2 is not None:
            distances[p] = abs(b1 - b2)
        elif b1 is None and b2 is None:
            distances[p] = 0
        else:
            distances[p] = None  # incomparable
    return distances


def demo_comparison():
    print("\n" + "=" * 60)
    print("APPLICATION 3: Localization-Based Comparison")
    print("=" * 60)

    F = ZPersModule(
        groups={
            1: FGAbGroup(torsion_parts={2: [1]}),
            3: FGAbGroup(torsion_parts={2: [1], 3: [1]}),
            5: FGAbGroup(torsion_parts={2: [1], 3: [1], 5: [1]}),
        },
        support_range=(0, 7)
    )

    G = ZPersModule(
        groups={
            2: FGAbGroup(torsion_parts={2: [1]}),
            3: FGAbGroup(torsion_parts={2: [1], 3: [1]}),
            6: FGAbGroup(torsion_parts={2: [1], 3: [1], 5: [1]}),
        },
        support_range=(0, 7)
    )

    print("\nModule F:")
    for i in range(8):
        g = F.obj(i)
        if g.has_any_torsion():
            print(f"  F({i}) = {g}")

    print("\nModule G:")
    for i in range(8):
        g = G.obj(i)
        if g.has_any_torsion():
            print(f"  G({i}) = {g}")

    primes = [2, 3, 5, 7]
    distances = localization_comparison(F, G, primes)

    global_d = abs((torsion_birth(F) or 0) - (torsion_birth(G) or 0))
    print(f"\n  Global torsion birth distance: {global_d}")
    print(f"\n  Primewise distances:")
    for p, d in sorted(distances.items()):
        print(f"    p={p}: distance = {d}")

    print(f"\n  → Primewise analysis reveals which features shifted most!")


# ── Main ──────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔═══════════════════════════════════════════════════════╗")
    print("║  Applications of Functorial Localization to TDA      ║")
    print("╚═══════════════════════════════════════════════════════╝")

    demo_denoising()
    demo_spectral_analysis()
    demo_comparison()

    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demo: Functorial Localization of Persistence Modules

This script demonstrates the core theorems of arithmetic persistence theory:
1. Birth set identification: p-torsion births = torsion births after localization
2. Interleaving preservation under localization
3. Primewise stability as a corollary of localization
4. Search for strict witness improvement candidates

Run: python demo.py
"""

import random
import sys
from collections import defaultdict

# Inline all needed classes/functions for self-containedness

class FGAbGroup:
    """Finitely generated abelian group in primary decomposition form."""
    def __init__(self, free_rank=0, torsion_parts=None):
        self.free_rank = free_rank
        self.torsion_parts = torsion_parts or {}

    def has_p_torsion(self, p):
        return p in self.torsion_parts and len(self.torsion_parts[p]) > 0

    def has_any_torsion(self):
        return any(len(exps) > 0 for exps in self.torsion_parts.values())

    def localize_at(self, p):
        new_torsion = {}
        if p in self.torsion_parts:
            new_torsion[p] = list(self.torsion_parts[p])
        return FGAbGroup(free_rank=self.free_rank, torsion_parts=new_torsion)

    def __repr__(self):
        parts = []
        if self.free_rank > 0:
            parts.append(f"Z^{self.free_rank}")
        for p in sorted(self.torsion_parts.keys()):
            for e in self.torsion_parts[p]:
                parts.append(f"Z/{p}^{e}" if e > 1 else f"Z/{p}")
        return " + ".join(parts) if parts else "0"


class ZPersModule:
    """Finitely supported Z-indexed persistence module."""
    def __init__(self, groups, support_range):
        self.groups = groups
        self.support_range = support_range

    def obj(self, i):
        return self.groups.get(i, FGAbGroup())

    def has_p_torsion_at(self, p, i):
        return self.obj(i).has_p_torsion(p)

    def has_torsion_at(self, i):
        return self.obj(i).has_any_torsion()

    def localize_at(self, p):
        new_groups = {}
        for idx, grp in self.groups.items():
            loc = grp.localize_at(p)
            if loc.free_rank > 0 or loc.has_any_torsion():
                new_groups[idx] = loc
        return ZPersModule(groups=new_groups, support_range=self.support_range)


def p_torsion_birth_set(F, p):
    lo, hi = F.support_range
    for i in range(lo, hi + 1):
        if F.has_p_torsion_at(p, i):
            if all(not F.has_p_torsion_at(p, j) for j in range(lo, i)):
                return {i}
    return set()


def torsion_birth_set(F):
    lo, hi = F.support_range
    for i in range(lo, hi + 1):
        if F.has_torsion_at(i):
            if all(not F.has_torsion_at(j) for j in range(lo, i)):
                return {i}
    return set()


def hausdorff_distance(S, T):
    if not S or not T:
        return None
    d1 = max(min(abs(s - t) for t in T) for s in S)
    d2 = max(min(abs(s - t) for s in S) for t in T)
    return max(d1, d2)


def delta_close(S, T, delta):
    for s in S:
        if not any(abs(s - t) <= delta for t in T):
            return False
    for t in T:
        if not any(abs(s - t) <= delta for s in S):
            return False
    return True


def random_persistence_module(support_size=8, primes=None, birth_prob=0.3):
    if primes is None:
        primes = [2, 3, 5]
    groups = {}
    active_torsion = {}
    for i in range(support_size):
        free_rank = random.randint(0, 2)
        torsion = dict(active_torsion)
        for p in primes:
            if p not in active_torsion and random.random() < birth_prob:
                n = random.randint(1, 2)
                exps = sorted([random.randint(1, 2) for _ in range(n)])
                active_torsion[p] = exps
                torsion[p] = exps
        groups[i] = FGAbGroup(free_rank=free_rank, torsion_parts=torsion)
    return ZPersModule(groups=groups, support_range=(0, support_size - 1))


# ─────────────────────────────────────────────────────────────────
# Demo 1: Birth Set Identification Theorem
# ─────────────────────────────────────────────────────────────────

def demo_birth_set_identification():
    print("=" * 70)
    print("DEMO 1: Birth Set Identification Theorem")
    print("  PTorsionBirthSet(p, F) = TorsionBirthSet(LocalizedAtPrime(p, F))")
    print("=" * 70)

    # Concrete example
    F = ZPersModule(
        groups={
            0: FGAbGroup(free_rank=2),
            1: FGAbGroup(free_rank=2),
            2: FGAbGroup(free_rank=1, torsion_parts={2: [1]}),
            3: FGAbGroup(free_rank=1, torsion_parts={2: [1], 3: [1]}),
            4: FGAbGroup(free_rank=1, torsion_parts={2: [1, 2], 3: [1]}),
            5: FGAbGroup(free_rank=1, torsion_parts={2: [1, 2], 3: [1], 5: [1]}),
        },
        support_range=(0, 5)
    )

    print("\nPersistence module F:")
    for i in range(6):
        print(f"  F({i}) = {F.obj(i)}")

    primes = [2, 3, 5, 7]
    print("\nBirth set computations:")
    for p in primes:
        births = p_torsion_birth_set(F, p)
        loc_F = F.localize_at(p)
        loc_births = torsion_birth_set(loc_F)
        match = "✓" if births == loc_births else "✗"
        print(f"  p={p}: PTorsionBirthSet = {births}, "
              f"TorsionBirthSet(Loc_{p}(F)) = {loc_births}  [{match}]")

    # Random verification
    print("\nRandom verification (100 trials):")
    n_pass = 0
    for _ in range(100):
        F_rand = random_persistence_module()
        for p in [2, 3, 5]:
            if p_torsion_birth_set(F_rand, p) == torsion_birth_set(F_rand.localize_at(p)):
                n_pass += 1
    print(f"  {n_pass}/300 checks passed (expect 300/300)")


# ─────────────────────────────────────────────────────────────────
# Demo 2: Interleaving Preservation
# ─────────────────────────────────────────────────────────────────

def demo_interleaving_preservation():
    print("\n" + "=" * 70)
    print("DEMO 2: Interleaving Preservation under Localization")
    print("  If F,G are δ-interleaved, Loc_p(F), Loc_p(G) are also δ-interleaved")
    print("=" * 70)

    # Two modules that are "close" but not identical
    F = ZPersModule(
        groups={
            0: FGAbGroup(free_rank=1),
            1: FGAbGroup(free_rank=1),
            2: FGAbGroup(free_rank=1, torsion_parts={2: [1], 3: [1]}),
            3: FGAbGroup(free_rank=1, torsion_parts={2: [1], 3: [1]}),
        },
        support_range=(0, 3)
    )

    G = ZPersModule(
        groups={
            0: FGAbGroup(free_rank=1),
            1: FGAbGroup(free_rank=1),
            2: FGAbGroup(free_rank=1),
            3: FGAbGroup(free_rank=1, torsion_parts={2: [1], 3: [1]}),
        },
        support_range=(0, 3)
    )

    print("\nModule F (torsion birth at index 2):")
    for i in range(4):
        print(f"  F({i}) = {F.obj(i)}")
    print(f"  Global torsion birth: {torsion_birth_set(F)}")

    print("\nModule G (torsion birth at index 3):")
    for i in range(4):
        print(f"  G({i}) = {G.obj(i)}")
    print(f"  Global torsion birth: {torsion_birth_set(G)}")

    delta = 1
    print(f"\nWith δ = {delta}:")
    for p in [2, 3, 5]:
        births_F = p_torsion_birth_set(F, p)
        births_G = p_torsion_birth_set(G, p)
        loc_births_F = torsion_birth_set(F.localize_at(p))
        loc_births_G = torsion_birth_set(G.localize_at(p))
        close = delta_close(births_F, births_G, delta) if births_F and births_G else True
        loc_close = delta_close(loc_births_F, loc_births_G, delta) if loc_births_F and loc_births_G else True

        print(f"  p={p}: original δ-close={close}, localized δ-close={loc_close}")


# ─────────────────────────────────────────────────────────────────
# Demo 3: Primewise vs Global Stability
# ─────────────────────────────────────────────────────────────────

def demo_primewise_stability():
    print("\n" + "=" * 70)
    print("DEMO 3: Primewise Stability via Localization")
    print("  Localization provides a uniform mechanism for primewise stability")
    print("=" * 70)

    # Module with mixed torsion at different levels
    F = ZPersModule(
        groups={
            0: FGAbGroup(free_rank=1),
            3: FGAbGroup(free_rank=1, torsion_parts={2: [1]}),
            5: FGAbGroup(free_rank=1, torsion_parts={2: [1], 3: [1]}),
        },
        support_range=(0, 7)
    )

    G = ZPersModule(
        groups={
            0: FGAbGroup(free_rank=1),
            4: FGAbGroup(free_rank=1, torsion_parts={2: [1]}),
            6: FGAbGroup(free_rank=1, torsion_parts={2: [1], 3: [2]}),
        },
        support_range=(0, 7)
    )

    print("\nModule F:")
    for i in range(8):
        g = F.obj(i)
        if g.free_rank > 0 or g.has_any_torsion():
            print(f"  F({i}) = {g}")

    print("\nModule G:")
    for i in range(8):
        g = G.obj(i)
        if g.free_rank > 0 or g.has_any_torsion():
            print(f"  G({i}) = {g}")

    print("\nGlobal torsion birth distances:")
    gb_F = torsion_birth_set(F)
    gb_G = torsion_birth_set(G)
    gd = hausdorff_distance(gb_F, gb_G)
    print(f"  TorsionBirthSet(F) = {gb_F}")
    print(f"  TorsionBirthSet(G) = {gb_G}")
    print(f"  Hausdorff distance = {gd}")

    print("\nPrimewise birth distances (via localization):")
    for p in [2, 3, 5]:
        pb_F = p_torsion_birth_set(F, p)
        pb_G = p_torsion_birth_set(G, p)
        pd = hausdorff_distance(pb_F, pb_G)

        # Verify via localization
        loc_F = F.localize_at(p)
        loc_G = G.localize_at(p)
        lb_F = torsion_birth_set(loc_F)
        lb_G = torsion_birth_set(loc_G)
        ld = hausdorff_distance(lb_F, lb_G)

        print(f"  p={p}: primewise births F={pb_F}, G={pb_G}, "
              f"distance={pd}, localized distance={ld}")


# ─────────────────────────────────────────────────────────────────
# Demo 4: Search for Strict Improvement Candidates
# ─────────────────────────────────────────────────────────────────

def demo_strict_improvement_search():
    print("\n" + "=" * 70)
    print("DEMO 4: Search for Strict Witness Improvement")
    print("  Looking for cases where localization strictly reduces distance")
    print("=" * 70)

    random.seed(42)
    candidates = []
    n_trials = 500
    primes = [2, 3, 5, 7]

    for trial in range(n_trials):
        F = random_persistence_module(support_size=10, primes=primes, birth_prob=0.25)
        G = random_persistence_module(support_size=10, primes=primes, birth_prob=0.25)

        gb_F = torsion_birth_set(F)
        gb_G = torsion_birth_set(G)
        gd = hausdorff_distance(gb_F, gb_G)

        if gd is None or gd == 0:
            continue

        for p in primes:
            pb_F = p_torsion_birth_set(F, p)
            pb_G = p_torsion_birth_set(G, p)
            pd = hausdorff_distance(pb_F, pb_G)

            if pd is not None and pd < gd:
                candidates.append({
                    'trial': trial,
                    'prime': p,
                    'global_dist': gd,
                    'p_dist': pd,
                    'improvement': gd - pd,
                })

    print(f"\n  Searched {n_trials} random module pairs")
    print(f"  Found {len(candidates)} improvement candidates")

    if candidates:
        print("\n  Top candidates:")
        candidates.sort(key=lambda x: -x['improvement'])
        for c in candidates[:5]:
            print(f"    Trial {c['trial']}: p={c['prime']}, "
                  f"global_dist={c['global_dist']}, p_dist={c['p_dist']}, "
                  f"improvement={c['improvement']}")
    else:
        print("  No strict improvements found in this batch.")
        print("  (This doesn't disprove the conjecture — try larger search.)")


# ─────────────────────────────────────────────────────────────────
# Demo 5: Prime Channel Decomposition
# ─────────────────────────────────────────────────────────────────

def demo_prime_decomposition():
    print("\n" + "=" * 70)
    print("DEMO 5: Prime Channel Decomposition of Torsion")
    print("  Torsion information decomposes into independent prime channels")
    print("=" * 70)

    F = ZPersModule(
        groups={
            0: FGAbGroup(free_rank=1),
            1: FGAbGroup(free_rank=1, torsion_parts={2: [1]}),
            2: FGAbGroup(free_rank=1, torsion_parts={2: [1]}),
            3: FGAbGroup(free_rank=1, torsion_parts={2: [1], 3: [1]}),
            4: FGAbGroup(free_rank=1, torsion_parts={2: [1], 3: [1], 5: [1]}),
        },
        support_range=(0, 4)
    )

    print("\nModule F with staggered torsion births:")
    for i in range(5):
        print(f"  F({i}) = {F.obj(i)}")

    print("\nPrime channel analysis:")
    primes_used = sorted(prime_support_set(F))
    for p in primes_used:
        births = p_torsion_birth_set(F, p)
        loc = F.localize_at(p)
        print(f"  Channel p={p}:")
        print(f"    Birth index: {births}")
        print(f"    Localized module:")
        for i in range(5):
            g = loc.obj(i)
            if g.free_rank > 0 or g.has_any_torsion():
                print(f"      Loc_{p}(F)({i}) = {g}")

    print(f"\n  Global torsion birth: {torsion_birth_set(F)}")
    print(f"  This is the FIRST among all prime channel births: "
          f"{min(min(b) for p in primes_used for b in [p_torsion_birth_set(F, p)] if b)}")


def prime_support_set(F):
    primes = set()
    for grp in F.groups.values():
        primes.update(grp.torsion_parts.keys())
    return primes


# ─────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Functorial Localization of Persistence Modules — Interactive Demo  ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    demo_birth_set_identification()
    demo_interleaving_preservation()
    demo_primewise_stability()
    demo_strict_improvement_search()
    demo_prime_decomposition()

    print("\n" + "=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)


"""
Visualization: The Localization Functor in Action

Shows how two persistence modules that are δ-interleaved remain
δ-interleaved after localization at a prime. The visualization
depicts the groups at each index, the interleaving maps, and
how localization simplifies the picture by removing extraneous torsion.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

# ── Configuration ─────────────────────────────────────────────────

fig, axes = plt.subplots(2, 2, figsize=(14, 9))

indices = list(range(8))
delta = 1

# Module F: torsion births
F_torsion = {
    0: {}, 1: {}, 2: {2: 1},
    3: {2: 1, 3: 1}, 4: {2: 1, 3: 1, 5: 1},
    5: {2: 1, 3: 1, 5: 1}, 6: {2: 1, 3: 1, 5: 1}, 7: {2: 1, 3: 1, 5: 1}
}
# Module G: shifted torsion births
G_torsion = {
    0: {}, 1: {}, 2: {}, 3: {2: 1},
    4: {2: 1, 3: 1}, 5: {2: 1, 3: 1, 5: 1},
    6: {2: 1, 3: 1, 5: 1}, 7: {2: 1, 3: 1, 5: 1}
}

prime_colors = {2: '#e74c3c', 3: '#3498db', 5: '#2ecc71'}

def torsion_label(tors):
    if not tors:
        return 'ℤ'
    parts = ['ℤ']
    for p in sorted(tors):
        parts.append(f'ℤ/{p}')
    return '⊕'.join(parts)

def draw_module(ax, torsion_data, name, y_offset=0, color='black'):
    """Draw a persistence module as a sequence of nodes with labels."""
    for i in indices:
        tors = torsion_data.get(i, {})
        n_primes = len(tors)

        # Node
        circle_color = '#f0f0f0' if n_primes == 0 else '#fff3e0'
        ax.add_patch(plt.Circle((i, y_offset), 0.35, facecolor=circle_color,
                                edgecolor=color, linewidth=1.5, zorder=3))

        # Torsion indicators
        for j, (p, _) in enumerate(sorted(tors.items())):
            angle = 2 * np.pi * j / max(n_primes, 1) - np.pi/2
            dx, dy = 0.15 * np.cos(angle), 0.15 * np.sin(angle)
            ax.plot(i + dx, y_offset + dy, 'o', color=prime_colors.get(p, 'gray'),
                   markersize=6, zorder=4)

        # Arrows between nodes
        if i < max(indices):
            ax.annotate('', xy=(i + 0.6, y_offset), xytext=(i + 0.4, y_offset),
                       arrowprops=dict(arrowstyle='->', color=color, lw=1.2))

    ax.text(-0.8, y_offset, name, fontsize=13, fontweight='bold',
            ha='right', va='center', color=color)

def draw_interleaving(ax, y_top, y_bot, delta_val):
    """Draw interleaving arrows between two modules."""
    for i in indices:
        if i + delta_val <= max(indices):
            # Forward arrow (top to bottom)
            ax.annotate('', xy=(i + delta_val, y_bot + 0.4),
                       xytext=(i, y_top - 0.4),
                       arrowprops=dict(arrowstyle='->', color='#27ae60',
                                      lw=1, ls='--', alpha=0.5))
            # Backward arrow (bottom to top)
            ax.annotate('', xy=(i + delta_val, y_top - 0.4),
                       xytext=(i, y_bot + 0.4),
                       arrowprops=dict(arrowstyle='->', color='#e67e22',
                                      lw=1, ls='--', alpha=0.5))

# ── Panel 1: Original modules with interleaving ──────────────────

ax = axes[0, 0]
draw_module(ax, F_torsion, 'F', y_offset=1.5, color='#2c3e50')
draw_module(ax, G_torsion, 'G', y_offset=-1.5, color='#8e44ad')
draw_interleaving(ax, 1.5, -1.5, delta)

ax.set_xlim(-1.5, 8)
ax.set_ylim(-2.5, 2.5)
ax.set_xticks(indices)
ax.set_title(f'Original: F and G are δ={delta}-interleaved\n(colored dots = torsion at primes)',
             fontsize=11, fontweight='bold')
ax.set_xlabel('Filtration Index', fontsize=10)
ax.set_aspect('equal')
ax.grid(True, alpha=0.1)

# ── Panel 2: Localized at p=2 ─────────────────────────────────────

ax = axes[0, 1]
F_loc2 = {i: ({2: t[2]} if 2 in t else {}) for i, t in F_torsion.items()}
G_loc2 = {i: ({2: t[2]} if 2 in t else {}) for i, t in G_torsion.items()}

draw_module(ax, F_loc2, 'Loc₂(F)', y_offset=1.5, color='#c0392b')
draw_module(ax, G_loc2, 'Loc₂(G)', y_offset=-1.5, color='#8e44ad')
draw_interleaving(ax, 1.5, -1.5, delta)

ax.set_xlim(-1.5, 8)
ax.set_ylim(-2.5, 2.5)
ax.set_xticks(indices)
ax.set_title(f'Localized at p=2: Only 2-torsion survives\nδ={delta}-interleaving preserved!',
             fontsize=11, fontweight='bold')
ax.set_xlabel('Filtration Index', fontsize=10)
ax.set_aspect('equal')
ax.grid(True, alpha=0.1)

# ── Panel 3: Localized at p=3 ─────────────────────────────────────

ax = axes[1, 0]
F_loc3 = {i: ({3: t[3]} if 3 in t else {}) for i, t in F_torsion.items()}
G_loc3 = {i: ({3: t[3]} if 3 in t else {}) for i, t in G_torsion.items()}

draw_module(ax, F_loc3, 'Loc₃(F)', y_offset=1.5, color='#2980b9')
draw_module(ax, G_loc3, 'Loc₃(G)', y_offset=-1.5, color='#8e44ad')
draw_interleaving(ax, 1.5, -1.5, delta)

ax.set_xlim(-1.5, 8)
ax.set_ylim(-2.5, 2.5)
ax.set_xticks(indices)
ax.set_title(f'Localized at p=3: Only 3-torsion survives\nδ={delta}-interleaving preserved!',
             fontsize=11, fontweight='bold')
ax.set_xlabel('Filtration Index', fontsize=10)
ax.set_aspect('equal')
ax.grid(True, alpha=0.1)

# ── Panel 4: Birth set comparison ─────────────────────────────────

ax = axes[1, 1]

labels = ['Global F', 'Global G', 'p=2 F', 'p=2 G', 'p=3 F', 'p=3 G', 'p=5 F', 'p=5 G']
births = [2, 3, 2, 3, 3, 4, 4, 5]
colors_list = ['#2c3e50', '#8e44ad', '#e74c3c', '#e74c3c', '#3498db', '#3498db', '#2ecc71', '#2ecc71']
alphas = [0.9, 0.9, 0.8, 0.5, 0.8, 0.5, 0.8, 0.5]

y_pos = list(range(len(labels)))
bars = ax.barh(y_pos, [0.6]*len(labels), left=[b-0.3 for b in births],
               color=colors_list, alpha=alphas, height=0.6, edgecolor='white')

for i, (birth, label) in enumerate(zip(births, labels)):
    ax.text(birth, i, str(birth), ha='center', va='center',
            color='white', fontweight='bold', fontsize=9)

# Draw distance brackets
for pair_start in [0, 2, 4, 6]:
    b1, b2 = births[pair_start], births[pair_start + 1]
    dist = abs(b1 - b2)
    mid_y = pair_start + 0.5
    ax.annotate(f'Δ={dist}', xy=(max(b1, b2) + 0.5, mid_y),
               fontsize=9, color='#e67e22', fontweight='bold')

ax.set_xlim(-0.5, 8)
ax.set_yticks(y_pos)
ax.set_yticklabels(labels, fontsize=9)
ax.set_xlabel('Filtration Index', fontsize=10)
ax.set_title('Birth Indices: Global vs. Primewise\n'
             '(Theorem 2: p-births = localized births)',
             fontsize=11, fontweight='bold')
ax.grid(True, alpha=0.1, axis='x')
ax.invert_yaxis()

# Legend
legend_patches = [mpatches.Patch(color=prime_colors[p], label=f'p={p} torsion')
                  for p in [2, 3, 5]]
fig.legend(handles=legend_patches, loc='lower center', ncol=3,
           fontsize=10, frameon=True, fancybox=True)

plt.tight_layout(rect=[0, 0.05, 1, 1])
plt.savefig('viz_localization_functor.png', dpi=150, bbox_inches='tight')
print("Saved viz_localization_functor.png")


"""
Visualization: Prime Spectrum of a Persistence Module

Shows how torsion information decomposes into independent prime channels,
each revealing different topological features at different scales.
Each row represents a prime channel; colored cells indicate where
torsion at that prime is present. The leftmost colored cell in each
row is the "birth" for that channel.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

# ── Define example persistence modules ──────────────────────────

# Persistence module with staggered torsion births
# F(i) groups: torsion appears at different primes at different indices
torsion_data = {
    # index: {prime: [exponents]}
    0: {},
    1: {},
    2: {7: [1]},
    3: {7: [1]},
    4: {2: [1], 7: [1]},
    5: {2: [1, 2], 3: [1], 7: [1]},
    6: {2: [1, 2], 3: [1], 5: [1], 7: [1]},
    7: {2: [1, 2], 3: [1, 1], 5: [1], 7: [1]},
    8: {2: [1, 2], 3: [1, 1], 5: [1], 7: [1], 11: [1]},
    9: {2: [1, 2], 3: [1, 1], 5: [1], 7: [1], 11: [1]},
}

primes = [2, 3, 5, 7, 11]
indices = list(range(10))
prime_colors = {
    2: '#e74c3c',   # red
    3: '#3498db',   # blue
    5: '#2ecc71',   # green
    7: '#f39c12',   # orange
    11: '#9b59b6',  # purple
}

# ── Create figure ─────────────────────────────────────────────────

fig, axes = plt.subplots(3, 1, figsize=(12, 10), gridspec_kw={'height_ratios': [4, 2, 2]})

# Panel 1: Prime spectrum heatmap
ax1 = axes[0]
for pi, p in enumerate(primes):
    for idx in indices:
        torsion = torsion_data.get(idx, {})
        has_torsion = p in torsion and len(torsion[p]) > 0
        if has_torsion:
            rank = len(torsion[p])
            alpha = min(0.3 + 0.2 * rank, 1.0)
            ax1.add_patch(plt.Rectangle((idx - 0.4, pi - 0.35), 0.8, 0.7,
                                         facecolor=prime_colors[p], alpha=alpha,
                                         edgecolor='white', linewidth=1.5))
            # Mark birth (first appearance)
            is_birth = all(p not in torsion_data.get(j, {}) or
                          len(torsion_data.get(j, {}).get(p, [])) == 0
                          for j in range(idx))
            if is_birth:
                ax1.plot(idx, pi, 'w*', markersize=14, markeredgecolor='black',
                        markeredgewidth=0.8)

ax1.set_xlim(-0.5, 9.5)
ax1.set_ylim(-0.5, len(primes) - 0.5)
ax1.set_xticks(indices)
ax1.set_yticks(range(len(primes)))
ax1.set_yticklabels([f'p = {p}' for p in primes], fontsize=12)
ax1.set_xlabel('Filtration Index', fontsize=12)
ax1.set_title('Prime Spectrum of a Persistence Module\n'
              '(★ = birth index, intensity = torsion rank)',
              fontsize=14, fontweight='bold')
ax1.grid(True, alpha=0.15)
ax1.invert_yaxis()

# Panel 2: Localization effect
ax2 = axes[1]
loc_prime = 3  # Localize at p=3

for idx in indices:
    torsion = torsion_data.get(idx, {})
    # Before localization: all torsion
    total_torsion = sum(len(torsion.get(p, [])) for p in primes)
    if total_torsion > 0:
        ax2.bar(idx - 0.2, total_torsion, width=0.35, color='gray', alpha=0.5,
               label='Before' if idx == 4 else '')

    # After localization at p=3: only 3-torsion
    p3_torsion = len(torsion.get(loc_prime, []))
    if p3_torsion > 0:
        ax2.bar(idx + 0.2, p3_torsion, width=0.35, color=prime_colors[loc_prime],
               alpha=0.8, label=f'After Loc₃' if idx == 5 else '')

ax2.set_xlim(-0.5, 9.5)
ax2.set_xticks(indices)
ax2.set_ylabel('Torsion Rank', fontsize=11)
ax2.set_title(f'Effect of Localization at p = {loc_prime}: '
              f'Isolating the {loc_prime}-primary Channel', fontsize=12)
ax2.legend(loc='upper left', fontsize=10)
ax2.grid(True, alpha=0.15)

# Panel 3: Birth set comparison
ax3 = axes[2]
y_positions = {'Global': 0}
for i, p in enumerate(primes):
    y_positions[f'p={p}'] = i + 1

# Global torsion birth
global_birth = min(idx for idx in indices if torsion_data.get(idx, {}))
ax3.barh(0, 0.6, left=global_birth - 0.3, color='black', alpha=0.7, height=0.5)
ax3.text(global_birth, 0, f'{global_birth}', ha='center', va='center',
         color='white', fontweight='bold', fontsize=10)

# Primewise births
for i, p in enumerate(primes):
    birth = None
    for idx in indices:
        if p in torsion_data.get(idx, {}) and len(torsion_data.get(idx, {}).get(p, [])) > 0:
            birth = idx
            break
    if birth is not None:
        ax3.barh(i + 1, 0.6, left=birth - 0.3, color=prime_colors[p],
                alpha=0.8, height=0.5)
        ax3.text(birth, i + 1, f'{birth}', ha='center', va='center',
                color='white', fontweight='bold', fontsize=10)

ax3.set_xlim(-0.5, 9.5)
ax3.set_xticks(indices)
ax3.set_yticks(list(y_positions.values()))
ax3.set_yticklabels(list(y_positions.keys()), fontsize=11)
ax3.set_xlabel('Filtration Index', fontsize=12)
ax3.set_title('Birth Set Decomposition: Global vs. Primewise',
              fontsize=12)
ax3.grid(True, alpha=0.15, axis='x')
ax3.invert_yaxis()

plt.tight_layout()
plt.savefig('viz_prime_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved viz_prime_spectrum.png")


"""
Visualization: Stability Comparison — Global vs Primewise

Shows how the interleaving distance decomposes across prime channels,
demonstrating that primewise stability can be strictly better than
global stability. This is the computational evidence for the witness
improvement conjecture.
"""
import matplotlib.pyplot as plt
import numpy as np
import random

# ── Self-contained classes ────────────────────────────────────────

class FGAbGroup:
    def __init__(self, free_rank=0, torsion_parts=None):
        self.free_rank = free_rank
        self.torsion_parts = torsion_parts or {}
    def has_p_torsion(self, p):
        return p in self.torsion_parts and len(self.torsion_parts[p]) > 0
    def has_any_torsion(self):
        return any(len(e) > 0 for e in self.torsion_parts.values())
    def localize_at(self, p):
        t = {p: list(self.torsion_parts[p])} if p in self.torsion_parts else {}
        return FGAbGroup(free_rank=self.free_rank, torsion_parts=t)

class ZPersModule:
    def __init__(self, groups, support_range):
        self.groups = groups
        self.support_range = support_range
    def obj(self, i):
        return self.groups.get(i, FGAbGroup())
    def has_p_torsion_at(self, p, i):
        return self.obj(i).has_p_torsion(p)
    def has_torsion_at(self, i):
        return self.obj(i).has_any_torsion()
    def localize_at(self, p):
        ng = {i: g.localize_at(p) for i, g in self.groups.items()
              if g.localize_at(p).has_any_torsion() or g.localize_at(p).free_rank > 0}
        return ZPersModule(groups=ng, support_range=self.support_range)

def torsion_birth(F):
    lo, hi = F.support_range
    for i in range(lo, hi + 1):
        if F.has_torsion_at(i):
            if all(not F.has_torsion_at(j) for j in range(lo, i)):
                return i
    return None

def p_torsion_birth(F, p):
    lo, hi = F.support_range
    for i in range(lo, hi + 1):
        if F.has_p_torsion_at(p, i):
            if all(not F.has_p_torsion_at(p, j) for j in range(lo, i)):
                return i
    return None

def random_module(n=10, primes=None, prob=0.25):
    if primes is None:
        primes = [2, 3, 5, 7]
    groups = {}
    active = {}
    for i in range(n):
        torsion = dict(active)
        for p in primes:
            if p not in active and random.random() < prob:
                active[p] = [random.randint(1, 2)]
                torsion[p] = active[p]
        if torsion:
            groups[i] = FGAbGroup(free_rank=1, torsion_parts=torsion)
        else:
            groups[i] = FGAbGroup(free_rank=1)
    return ZPersModule(groups=groups, support_range=(0, n - 1))

# ── Experiment: collect primewise vs global distances ─────────────

random.seed(123)
n_trials = 300
primes = [2, 3, 5, 7]

global_dists = []
primewise_dists = {p: [] for p in primes}
improvements = []

for _ in range(n_trials):
    F = random_module(12, primes, 0.3)
    G = random_module(12, primes, 0.3)

    gb_F = torsion_birth(F)
    gb_G = torsion_birth(G)
    if gb_F is not None and gb_G is not None:
        gd = abs(gb_F - gb_G)
        global_dists.append(gd)

        min_pd = float('inf')
        for p in primes:
            pb_F = p_torsion_birth(F, p)
            pb_G = p_torsion_birth(G, p)
            if pb_F is not None and pb_G is not None:
                pd = abs(pb_F - pb_G)
                primewise_dists[p].append(pd)
                min_pd = min(min_pd, pd)

        if min_pd < float('inf'):
            improvements.append(gd - min_pd)

# ── Create figure ─────────────────────────────────────────────────

fig, axes = plt.subplots(2, 2, figsize=(13, 10))

# Panel 1: Distribution of global vs min-primewise distance
ax = axes[0, 0]
bins = np.arange(-0.5, max(max(global_dists, default=0), 8) + 1.5, 1)
ax.hist(global_dists, bins=bins, alpha=0.6, color='#2c3e50', label='Global', edgecolor='white')
min_pw = [min(primewise_dists[p][i] for p in primes if i < len(primewise_dists[p]))
          for i in range(min(len(primewise_dists[p]) for p in primes)) if
          any(i < len(primewise_dists[p]) for p in primes)]
if min_pw:
    ax.hist(min_pw, bins=bins, alpha=0.6, color='#e74c3c', label='Min primewise', edgecolor='white')
ax.set_xlabel('Birth Set Distance', fontsize=11)
ax.set_ylabel('Count', fontsize=11)
ax.set_title('Global vs Best Primewise Distance\n(300 random module pairs)', fontsize=12, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.15)

# Panel 2: Improvement histogram
ax = axes[0, 1]
if improvements:
    bins_imp = np.arange(min(improvements) - 0.5, max(improvements) + 1.5, 1)
    colors_imp = ['#2ecc71' if v > 0 else '#95a5a6' if v == 0 else '#e74c3c' for v in sorted(set(improvements))]
    ax.hist(improvements, bins=bins_imp, alpha=0.7, color='#3498db', edgecolor='white')
    pos = sum(1 for x in improvements if x > 0)
    zero = sum(1 for x in improvements if x == 0)
    neg = sum(1 for x in improvements if x < 0)
    ax.axvline(0, color='black', linestyle='--', alpha=0.5)
    ax.text(0.95, 0.95, f'Improved: {pos}\nEqual: {zero}\nWorse: {neg}',
            transform=ax.transAxes, ha='right', va='top', fontsize=10,
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
ax.set_xlabel('Improvement (global − best primewise)', fontsize=11)
ax.set_ylabel('Count', fontsize=11)
ax.set_title('Witness Improvement via Localization\n(positive = localization helps)',
             fontsize=12, fontweight='bold')
ax.grid(True, alpha=0.15)

# Panel 3: Per-prime distance distributions
ax = axes[1, 0]
prime_color_map = {2: '#e74c3c', 3: '#3498db', 5: '#2ecc71', 7: '#f39c12'}
positions = []
data = []
labels_p = []
for i, p in enumerate(primes):
    if primewise_dists[p]:
        data.append(primewise_dists[p])
        positions.append(i)
        labels_p.append(f'p={p}')

if data:
    bp = ax.boxplot(data, positions=positions, patch_artist=True, widths=0.6)
    for i, (patch, p) in enumerate(zip(bp['boxes'], primes)):
        patch.set_facecolor(prime_color_map[p])
        patch.set_alpha(0.6)
    if global_dists:
        ax.boxplot([global_dists], positions=[len(primes)], patch_artist=True,
                   widths=0.6, boxprops=dict(facecolor='#2c3e50', alpha=0.6))
        labels_p.append('Global')
    ax.set_xticks(list(range(len(labels_p))))
    ax.set_xticklabels(labels_p, fontsize=11)

ax.set_ylabel('Birth Set Distance', fontsize=11)
ax.set_title('Distance Distribution by Prime Channel\nvs Global Distance',
             fontsize=12, fontweight='bold')
ax.grid(True, alpha=0.15, axis='y')

# Panel 4: Concrete example
ax = axes[1, 1]

# Specific example showing improvement
F_ex = ZPersModule(
    groups={
        0: FGAbGroup(free_rank=1),
        1: FGAbGroup(free_rank=1, torsion_parts={3: [1]}),
        3: FGAbGroup(free_rank=1, torsion_parts={2: [1], 3: [1]}),
    },
    support_range=(0, 6)
)
G_ex = ZPersModule(
    groups={
        0: FGAbGroup(free_rank=1),
        2: FGAbGroup(free_rank=1, torsion_parts={3: [1]}),
        3: FGAbGroup(free_rank=1, torsion_parts={2: [1], 3: [1]}),
    },
    support_range=(0, 6)
)

categories = ['Global', 'p=2', 'p=3']
F_births = [torsion_birth(F_ex), p_torsion_birth(F_ex, 2), p_torsion_birth(F_ex, 3)]
G_births = [torsion_birth(G_ex), p_torsion_birth(G_ex, 2), p_torsion_birth(G_ex, 3)]
distances_ex = []
for fb, gb in zip(F_births, G_births):
    if fb is not None and gb is not None:
        distances_ex.append(abs(fb - gb))
    else:
        distances_ex.append(0)

x_pos = np.arange(len(categories))
colors_ex = ['#2c3e50', '#e74c3c', '#3498db']

bars = ax.bar(x_pos, distances_ex, color=colors_ex, alpha=0.7, edgecolor='white', width=0.5)
for bar, d, fb, gb in zip(bars, distances_ex, F_births, G_births):
    label = f'd={d}'
    if fb is not None and gb is not None:
        label += f'\n({fb}↔{gb})'
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.05,
            label, ha='center', va='bottom', fontsize=9)

ax.set_xticks(x_pos)
ax.set_xticklabels(categories, fontsize=11)
ax.set_ylabel('Birth Distance', fontsize=11)
ax.set_title('Concrete Example: Primewise Can Beat Global\n'
             'F: 3-torsion at 1, 2-torsion at 3\n'
             'G: 3-torsion at 2, 2-torsion at 3',
             fontsize=11, fontweight='bold')
ax.grid(True, alpha=0.15, axis='y')

plt.tight_layout()
plt.savefig('viz_stability_comparison.png', dpi=150, bbox_inches='tight')
print("Saved viz_stability_comparison.png")
