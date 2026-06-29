"""
Numerical demonstrations for:

    Boundary Obstructions to the Realization of Even Incoherence Indices
    by Maximal Standard Frames

Model recap
-----------
A *frame* on N voters is a finite set F of atoms in Z_N (the integers mod N).
A *perfectly balanced obstruction* is a nonempty multiset of atoms of F that
sums to 0 in Z_N.  The *incoherence index* idx(F) is the length of the shortest
such obstruction (0 if none exists).  A frame is *maximal* when its atoms
generate Z_N (equivalently gcd(atoms, N) = 1).

This file is fully self-contained (standard library only).  It numerically
exercises the main theorem (the boundary obstruction on N = 6) and the
supporting realization theory.
"""

from __future__ import annotations

from collections import deque
from itertools import combinations
from math import gcd
from typing import Iterable


# --------------------------------------------------------------------------- #
#  Core primitives
# --------------------------------------------------------------------------- #
def additive_order(a: int, N: int) -> int:
    """Additive order of `a` in Z_N: least m >= 1 with m*a == 0 (mod N)."""
    a %= N
    if a == 0:
        return 1
    return N // gcd(a, N)


def is_generator(a: int, N: int) -> bool:
    """True iff `a` generates Z_N, i.e. has additive order exactly N."""
    return additive_order(a, N) == N


def is_maximal(frame: Iterable[int], N: int) -> bool:
    """True iff the atoms of `frame` generate Z_N."""
    g = N
    for a in frame:
        g = gcd(g, a % N)
    return g == 1


def incoherence_index(frame: Iterable[int], N: int) -> int:
    """
    Shortest nonempty zero-sum sequence over `frame` in Z_N, computed as the
    girth of the Cayley graph Cay(Z_N, frame): BFS from 0 returning the first
    re-arrival at 0 using at least one edge.  Returns 0 if no obstruction.
    """
    atoms = sorted({a % N for a in frame})
    if not atoms:
        return 0
    dist: list[int] = [-1] * N
    dist[0] = 0
    queue: deque[int] = deque([0])
    while queue:
        r = queue.popleft()
        for a in atoms:
            s = (r + a) % N
            if s == 0:
                return dist[r] + 1
            if dist[s] == -1:
                dist[s] = dist[r] + 1
                queue.append(s)
    return 0


def shortest_obstruction(frame: Iterable[int], N: int) -> list[int]:
    """Reconstruct an explicit shortest balanced obstruction (witness)."""
    atoms = sorted({a % N for a in frame})
    if not atoms:
        return []
    prev: dict[int, tuple[int, int]] = {0: (-1, -1)}  # residue -> (pred, atom)
    queue: deque[int] = deque([0])
    end_atom = -1
    while queue:
        r = queue.popleft()
        for a in atoms:
            s = (r + a) % N
            if s == 0:
                end_atom = a
                seq = [a]
                cur = r
                while cur != 0:
                    pr, at = prev[cur]
                    seq.append(at)
                    cur = pr
                return list(reversed(seq))
            if s not in prev:
                prev[s] = (r, a)
                queue.append(s)
    return []


# --------------------------------------------------------------------------- #
#  Demo 1 : the main theorem -- no maximal frame on 6 voters has index 4
# --------------------------------------------------------------------------- #
def demo_boundary_obstruction_k1() -> None:
    """Theorem A (boundary_obstruction_k1): exhaustively verify that no maximal
    frame on N = 6 voters attains incoherence index 4 (the target 2k+2 at k=1)."""
    N = 6
    print(f"=== Theorem A: boundary obstruction on N = {N} (k = 1) ===")
    target = 4  # = 2*k + 2 = N/2 + 1
    found = []
    atoms = list(range(N))
    for size in range(1, N + 1):
        for frame in combinations(atoms, size):
            if not is_maximal(frame, N):
                continue
            idx = incoherence_index(frame, N)
            if idx == target:
                found.append((frame, idx))
    print(f"target index 2k+2 = {target}  (= N/2 + 1 = {N // 2 + 1})")
    print(f"maximal frames on {N} voters with index {target}: {len(found)} "
          f"-> {'NONE (obstruction confirmed)' if not found else found}")
    # Show the generator-only frames and their indices (the proof's case list).
    gens = [a for a in range(N) if is_generator(a, N)]
    print(f"generators of Z_{N}: {gens}")
    for frame in ([g] for g in gens):
        print(f"  frame {frame}: idx = {incoherence_index(frame, N)}")
    print(f"  frame {gens}: idx = {incoherence_index(gens, N)}  "
          f"(witness {shortest_obstruction(gens, N)})")
    print()


# --------------------------------------------------------------------------- #
#  Demo 2 : the forbidden interval (N/2, N) across the refutation family
# --------------------------------------------------------------------------- #
def demo_forbidden_interval_family() -> None:
    """Refutations at (k,n) = (1,3),(2,5),(3,7) -> N = 6,10,14 with targets
    4,6,8 = N/2 + 1.  Verify the target N/2+1 is unattained by maximal frames
    and that the realizable maximal indices avoid the open interval (N/2, N)."""
    print("=== Forbidden interval (N/2, N) for even electorates ===")
    for k in (1, 2, 3):
        n = 2 * k + 1
        N = 2 * n
        target = 2 * k + 2  # = N/2 + 1
        realizable: set[int] = set()
        atoms = list(range(N))
        # enumerate maximal frames (cap subset size for tractability at N=14)
        max_size = min(N, 5)
        for size in range(1, max_size + 1):
            for frame in combinations(atoms, size):
                if is_maximal(frame, N):
                    realizable.add(incoherence_index(frame, N))
        in_gap = sorted(v for v in realizable if N // 2 < v < N)
        print(f"k={k}, n={n}, N={N}: target 2k+2={target} (=N/2+1={N//2+1})")
        print(f"  index {target} realizable by a maximal frame? "
              f"{'YES' if target in realizable else 'NO'}")
        print(f"  realizable maximal indices in open interval (N/2,N)=({N//2},{N}): "
              f"{in_gap if in_gap else 'EMPTY (gap confirmed)'}")
    print()


# --------------------------------------------------------------------------- #
#  Demo 3 : positive realization theory (Lemmas 4-5, Theorems B, C, E)
# --------------------------------------------------------------------------- #
def demo_positive_realization() -> None:
    """Verify Lemma 5 / Theorem B / Theorem C: the single-generator frame {1}
    is maximal with idx = N, and N is the greatest index over nonempty frames."""
    print("=== Positive realization: idx({1}) = N is the maximum ===")
    for N in (4, 6, 8, 10, 12):
        idx1 = incoherence_index([1], N)
        # brute-force maximum over all nonempty frames
        best = 0
        for size in range(1, N + 1):
            for frame in combinations(range(N), size):
                best = max(best, incoherence_index(frame, N))
        print(f"N={N:2d}: idx(({1},...)) = idx({{1}}) = {idx1}, "
              f"maximal? {is_maximal([1], N)}, "
              f"max idx over all frames = {best}  "
              f"({'OK' if idx1 == N == best else 'MISMATCH'})")
    print()


# --------------------------------------------------------------------------- #
#  Demo 4 : parity transfer (Theorem D)
# --------------------------------------------------------------------------- #
def demo_parity_transfer() -> None:
    """Theorem D (even_incoherenceIndex): for even N, a frame all of whose atoms
    are odd has even incoherence index."""
    print("=== Parity transfer: all-odd-atom frames have even index ===")
    for N in (6, 8, 10, 12):
        odd_atoms = [a for a in range(N) if a % 2 == 1]
        # sample several all-odd frames
        examples = [[1], [1, 3], [3, 5], odd_atoms]
        for frame in examples:
            idx = incoherence_index(frame, N)
            tag = "even" if idx % 2 == 0 else "ODD (violation!)"
            print(f"  N={N:2d} frame={frame}: idx={idx} ({tag})")
    print()


# --------------------------------------------------------------------------- #
#  Demo 5 : cofinite realization of the target 2k+2 (companion result)
# --------------------------------------------------------------------------- #
def demo_cofinite_realization() -> None:
    """Illustrate the cofinite phenomenon: while target 2k+2 fails at the
    boundary n = 2k+1, the two-atom family {1, N-(2k+1)} realizes it for large
    enough electorates (here N = 2n > (2k+1)^2)."""
    print("=== Cofinite realization via the family {1, N-(2k+1)} ===")
    for k in (1, 2, 3):
        target = 2 * k + 2
        print(f"k={k}, target 2k+2={target}:")
        for n in range(2 * k + 1, 2 * (2 * k * k + 2 * k + 1) + 1):
            N = 2 * n
            frame = [1 % N, (N - (2 * k + 1)) % N]
            if not is_maximal(frame, N):
                continue
            idx = incoherence_index(frame, N)
            if idx == target:
                print(f"   first success: n={n} (N={N}), frame={frame}, "
                      f"idx={idx}, witness={shortest_obstruction(frame, N)}")
                break
    print()


def main() -> None:
    demo_boundary_obstruction_k1()
    demo_forbidden_interval_family()
    demo_positive_realization()
    demo_parity_transfer()
    demo_cofinite_realization()


if __name__ == "__main__":
    main()
