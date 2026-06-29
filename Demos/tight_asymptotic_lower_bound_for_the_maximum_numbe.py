"""
demo.py -- Numerical demonstration of the tight Theta(n^{2w}) lower bound for
strict alternating cycles in width-w posets, via the blown-up crown Crown(w, m).

Self-contained. No external dependencies (standard library only).

An element of Crown(w, m) is a triple (col, side, idx):
    col  in {0, ..., w-1}     -- which crown column
    side in {False, True}     -- False = lower vertex 'a', True = upper vertex 'b'
    idx  in {0, ..., m-1}     -- clone index inside the stack

Order  x <= y  holds iff:
    (chain rule) x.side == y.side and x.col == y.col and x.idx <= y.idx, OR
    (cross rule) x.side == False and y.side == True and y.col == (x.col + 1) % w.

We verify, for small parameters:
  * cardinality            : #Crown(w, m) == 2*w*m
  * width                  : max antichain size == w  (brute force)
  * strict-alt-cycle count : >= m^{2w}  (exactly m^{2w} from the cyc family)
  * asymptotic rate        : count == (n/(2w))^{2w} == (2w)^{-2w} * n^{2w}
"""

from __future__ import annotations

from itertools import product
from typing import Iterator, List, Tuple

# An element is (col, side, idx). side: False='a' (lower), True='b' (upper).
Elem = Tuple[int, bool, int]


def elements(w: int, m: int) -> List[Elem]:
    """All elements of Crown(w, m)."""
    return [(c, s, i) for c in range(w) for s in (False, True) for i in range(m)]


def leq(w: int, x: Elem, y: Elem) -> bool:
    """The partial order relation CrownLe on Crown(w, m)."""
    xc, xs, xi = x
    yc, ys, yi = y
    chain = (xs == ys) and (xc == yc) and (xi <= yi)
    cross = (xs is False) and (ys is True) and (yc == (xc + 1) % w)
    return chain or cross


def comparable(w: int, x: Elem, y: Elem) -> bool:
    return leq(w, x, y) or leq(w, y, x)


def card(w: int, m: int) -> int:
    """Cardinality of Crown(w, m) -- should equal 2*w*m (theorem Crown.card)."""
    return len(elements(w, m))


def is_partial_order(w: int, m: int) -> bool:
    """Brute-force check of reflexivity, antisymmetry, transitivity (crownPO)."""
    els = elements(w, m)
    for x in els:
        if not leq(w, x, x):
            return False
    for x in els:
        for y in els:
            if leq(w, x, y) and leq(w, y, x) and x != y:
                return False
    for x in els:
        for y in els:
            if not leq(w, x, y):
                continue
            for z in els:
                if leq(w, y, z) and not leq(w, x, z):
                    return False
    return True


def width_bruteforce(w: int, m: int) -> int:
    """Maximum antichain size by brute force -- should equal w (Crown.hasWidth)."""
    els = elements(w, m)
    n = len(els)
    best = 0
    # Enumerate all subsets is exponential; instead grow antichains greedily by
    # exhaustive search over reasonable sizes for small inputs.
    # For tractable demo sizes we test all subsets via a bitmask.
    for mask in range(1 << n):
        subset = [els[i] for i in range(n) if (mask >> i) & 1]
        if len(subset) <= best:
            continue
        ok = True
        for a in range(len(subset)):
            for b in range(a + 1, len(subset)):
                if comparable(w, subset[a], subset[b]):
                    ok = False
                    break
            if not ok:
                break
        if ok:
            best = len(subset)
    return best


def fold(w: int, x: Elem) -> int:
    """Column-folding map (Crown.fold): b(i) -> i, a(i) -> i+1 (mod w)."""
    xc, xs, _ = x
    return xc if xs else (xc + 1) % w


def width_via_fold_upper_bound() -> int:
    """The fold lands in {0,...,w-1}, certifying width <= w (returns symbolic w)."""
    # Conceptual: |antichain| <= |image of fold| <= w.  See Lemma 4.2.
    raise NotImplementedError("symbolic; see width_bruteforce for the numeric check")


def cyc(w: int, u: Tuple[int, ...], v: Tuple[int, ...]) -> List[Tuple[Elem, Elem]]:
    """The witnessing cycle family cyc(u, v): column t -> (a(t,u_t), b(t,v_t))."""
    return [((t, False, u[t]), (t, True, v[t])) for t in range(w)]


def is_strict_alt_cycle(w: int, p: List[Tuple[Elem, Elem]]) -> bool:
    """Check IsStrictAltCycle: (SAC1) x_i <= y_j iff j=i+1; (SAC2) y_i not<= x_i."""
    # SAC1
    for i in range(w):
        for j in range(w):
            lhs = leq(w, p[i][0], p[j][1])
            rhs = (j == (i + 1) % w)
            if lhs != rhs:
                return False
    # SAC2
    for i in range(w):
        if leq(w, p[i][1], p[i][0]):
            return False
    return True


def all_clone_functions(w: int, m: int) -> Iterator[Tuple[int, ...]]:
    """All functions {0,...,w-1} -> {0,...,m-1}; there are m^w of them."""
    return product(range(m), repeat=w)


def count_cyc_strict_alt_cycles(w: int, m: int) -> int:
    """Count strict alternating cycles produced by the cyc family (cyc_strict,
    cyc_injective give exactly m^{2w} distinct ones)."""
    seen = set()
    count = 0
    for u in all_clone_functions(w, m):
        for v in all_clone_functions(w, m):
            p = cyc(w, u, v)
            assert is_strict_alt_cycle(w, p), "cyc(u,v) failed to be strict alt cycle!"
            key = tuple(p)  # injectivity: distinct (u,v) -> distinct families
            assert key not in seen, "cyc not injective!"
            seen.add(key)
            count += 1
    return count


def main() -> None:
    print("=" * 70)
    print("Blown-up crown Crown(w, m): tight Theta(n^{2w}) alternating cycles")
    print("=" * 70)

    for (w, m) in [(2, 1), (2, 2), (2, 3), (3, 1), (3, 2)]:
        n = card(w, m)
        po = is_partial_order(w, m)
        cyc_count = count_cyc_strict_alt_cycles(w, m)
        expected = m ** (2 * w)
        const = (2 * w) ** (-(2 * w))
        rate = const * n ** (2 * w)

        print(f"\nw = {w}, m = {m}")
        print(f"  #elements              = {n}        (expected 2*w*m = {2*w*m})")
        print(f"  is partial order       = {po}")
        if w * m <= 4:  # keep brute-force width tractable (2^(2wm) subsets)
            width = width_bruteforce(w, m)
            print(f"  width (brute force)    = {width}        (expected w = {w})")
        else:
            print(f"  width (brute force)    = skipped (too large), claimed {w}")
        print(f"  strict alt cycles      = {cyc_count}")
        print(f"  m^(2w)                 = {expected}   (match: {cyc_count == expected})")
        print(f"  (2w)^(-2w) * n^(2w)    = {rate:.4f}   (count == this: "
              f"{abs(cyc_count - rate) < 1e-9})")

    print("\n" + "=" * 70)
    print("Asymptotic growth of the cycle count as n -> infinity (w = 2):")
    print("=" * 70)
    w = 2
    print(f"{'m':>4} {'n=2wm':>8} {'cycles=m^{2w}':>14} {'cycles/n^{2w}':>16}")
    for m in [1, 2, 4, 8, 16, 32]:
        n = 2 * w * m
        cycles = m ** (2 * w)
        ratio = cycles / n ** (2 * w)
        print(f"{m:>4} {n:>8} {cycles:>14} {ratio:>16.8f}")
    print(f"\nRatio converges to (2w)^(-2w) = {(2*w)**(-(2*w)):.8f}, "
          f"confirming count = c_w * n^(2w).")


if __name__ == "__main__":
    main()


"""
visualize.py -- Visualizations for the blown-up crown Crown(w, m).

Produces two figures:
  1. A Hasse-style diagram of Crown(w, m) showing the 2w stacks of m clones and
     the cross relations a(i) -> b(i+1).
  2. A log-log plot of the strict-alternating-cycle count m^{2w} against the
     poset size n = 2wm, exhibiting the slope-2w power law (Theta(n^{2w})).

Requires: matplotlib, numpy.  Run:  python3 visualize.py
"""

from __future__ import annotations

from typing import List, Tuple

import matplotlib.pyplot as plt
import numpy as np


def hasse_diagram(w: int = 3, m: int = 2) -> None:
    """Draw the cover relations of Crown(w, m)."""
    fig, ax = plt.subplots(figsize=(2.2 * w, 5))
    # Position: each column i has an 'a' stack (lower, y in [0,1]) and a 'b' stack
    # (upper, y in [2,3]).  x-coordinate separates columns; a/b offset slightly.
    pos = {}
    for i in range(w):
        for j in range(m):
            pos[(i, False, j)] = (3 * i, 0.0 + 0.7 * j)          # a stack
            pos[(i, True, j)] = (3 * i + 1.0, 2.6 + 0.7 * j)     # b stack

    # chain covers within stacks
    for i in range(w):
        for s in (False, True):
            for j in range(m - 1):
                x0, y0 = pos[(i, s, j)]
                x1, y1 = pos[(i, s, j + 1)]
                ax.plot([x0, x1], [y0, y1], color="0.6", lw=1)
    # cross covers a(i) -> b(i+1): draw min-to-max representative to avoid clutter
    for i in range(w):
        x0, y0 = pos[(i, False, m - 1)]
        x1, y1 = pos[((i + 1) % w, True, 0)]
        ax.annotate("", xy=(x1, y1), xytext=(x0, y0),
                    arrowprops=dict(arrowstyle="->", color="crimson", lw=1.5,
                                    connectionstyle="arc3,rad=0.2"))

    for (i, s, j), (x, y) in pos.items():
        color = "#1f77b4" if not s else "#ff7f0e"
        ax.scatter([x], [y], s=140, color=color, zorder=3, edgecolor="k")
        label = f"{'b' if s else 'a'}{i},{j}"
        ax.text(x, y, label, ha="center", va="center", fontsize=6, color="white",
                zorder=4)

    ax.set_title(f"Blown-up crown Crown(w={w}, m={m})  ({2*w*m} elements, width {w})")
    ax.axis("off")
    fig.tight_layout()
    fig.savefig("crown_hasse.png", dpi=150)
    print("wrote crown_hasse.png")


def power_law_plot(w_values: List[int] = [2, 3, 4]) -> None:
    """Log-log plot of cycle count m^{2w} vs n = 2wm for several widths."""
    fig, ax = plt.subplots(figsize=(7, 5))
    ms = np.arange(1, 40)
    for w in w_values:
        n = 2 * w * ms
        cycles = ms.astype(float) ** (2 * w)
        ax.loglog(n, cycles, marker="o", ms=3, label=f"w = {w}  (slope {2*w})")
    ax.set_xlabel("poset size  n = 2wm")
    ax.set_ylabel("strict alternating cycles  = $m^{2w}$")
    ax.set_title("Cycle count grows as $\\Theta(n^{2w})$ (log-log: slope $2w$)")
    ax.legend()
    ax.grid(True, which="both", ls=":", alpha=0.5)
    fig.tight_layout()
    fig.savefig("crown_power_law.png", dpi=150)
    print("wrote crown_power_law.png")


if __name__ == "__main__":
    hasse_diagram(w=3, m=2)
    power_law_plot([2, 3, 4])
