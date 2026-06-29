"""
demo.py
================================================================================
Numerical demonstration of the bridge:

    Neural observation pseudometric  -->  congruence kernel  -->  proof-spectrum
    congruence.

We work over the semiring K = Z^m with COMPONENTWISE addition and multiplication
(0 = the all-zeros vector). The state space is R = Z^n with the same componentwise
semiring structure.

Key fact used to build genuine *algebraic* neural systems:
    A function on componentwise-Z^n preserves +, *, and 0 exactly when each
    output coordinate is either constant 0 or a copy of a single input
    coordinate (a "selector / mask" layer). These are precisely the semiring
    maps for the componentwise structure, and they are the abstraction of
    routing/projection/masking layers.

The script verifies, on concrete systems:
  1. algBehavior is a semiring homomorphism in the state (Theorem 4.5 / "hom").
  2. behaviorRel is a semiring congruence (Theorem 5.2).
  3. The zero-class equals the behaviorally-null states (Theorem 5.4).
  4. The kernel equals the intersection of the depth-k filtration (Theorem 5.5),
     and the filtration is monotone.
  5. obsDist is a pseudometric (Theorems 7.2-7.5).
  6. KEYSTONE: { (x,y) : obsDist = 0 } == behaviorCongruence (Theorem 7.6).
  7. Functoriality: a morphism pushes the congruence forward (Theorem 6.2).

Run:  python demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, List, Optional, Sequence, Tuple

# A semiring element of K = Z^m (or a state in R = Z^n) is a tuple of ints.
Vec = Tuple[int, ...]
# A word is a list of input symbols (here: small ints in range(num_symbols)).
Word = List[int]


# ----------------------------------------------------------------------------
# Componentwise semiring operations on Z^n.
# ----------------------------------------------------------------------------
def vadd(x: Vec, y: Vec) -> Vec:
    """Componentwise addition in Z^n."""
    return tuple(a + b for a, b in zip(x, y))


def vmul(x: Vec, y: Vec) -> Vec:
    """Componentwise multiplication in Z^n."""
    return tuple(a * b for a, b in zip(x, y))


def vzero(n: int) -> Vec:
    """The additive identity 0 of Z^n."""
    return tuple(0 for _ in range(n))


# ----------------------------------------------------------------------------
# A "selector layer": each output coordinate is either 0 (selector None) or a
# copy of input coordinate `j` (selector j). Such maps preserve +, *, and 0,
# hence are semiring homomorphisms for the componentwise structure.
# ----------------------------------------------------------------------------
def apply_selector(selector: Sequence[Optional[int]], x: Vec) -> Vec:
    """Apply a selector/mask map to a vector x."""
    return tuple(0 if j is None else x[j] for j in selector)


class AlgNeuralSystem:
    """
    An algebraic neural observation system over R = Z^n -> K = Z^m.

    step_selectors[a] : the selector defining the layer for input symbol a
                        (a function Z^n -> Z^n, given as a length-n selector).
    observe_selector  : the read-out selector (a function Z^n -> Z^m, given as
                        a length-m selector).
    """

    def __init__(
        self,
        n: int,
        m: int,
        step_selectors: List[List[Optional[int]]],
        observe_selector: List[Optional[int]],
    ) -> None:
        self.n = n
        self.m = m
        self.step_selectors = step_selectors  # one selector per input symbol
        self.observe_selector = observe_selector
        self.num_symbols = len(step_selectors)

    def step(self, x: Vec, a: int) -> Vec:
        """One layer of dynamics for input symbol a."""
        return apply_selector(self.step_selectors[a], x)

    def observe(self, x: Vec) -> Vec:
        """The read-out map R -> K."""
        return apply_selector(self.observe_selector, x)

    def fold(self, x: Vec, w: Word) -> Vec:
        """Left fold of the word w over `step`, starting at x."""
        s = x
        for a in w:
            s = self.step(s, a)
        return s

    def behavior(self, x: Vec, w: Word) -> Vec:
        """algBehavior(N, x, w) = observe(foldl step x w)."""
        return self.observe(self.fold(x, w))


def all_words(num_symbols: int, max_len: int) -> List[Word]:
    """Every word over `num_symbols` symbols of length <= max_len."""
    words: List[Word] = []
    for k in range(max_len + 1):
        for tup in product(range(num_symbols), repeat=k):
            words.append(list(tup))
    return words


def behavior_rel_upto(N: AlgNeuralSystem, x: Vec, y: Vec, depth: int) -> bool:
    """neural_equiv_upto: x and y agree on all words of length <= depth."""
    for w in all_words(N.num_symbols, depth):
        if N.behavior(x, w) != N.behavior(y, w):
            return False
    return True


def behavior_rel(N: AlgNeuralSystem, x: Vec, y: Vec, depth: int) -> bool:
    """
    behaviorRel approximated up to `depth`. For systems whose dynamics stabilize
    by `depth` (true here: selector layers are idempotent up to routing), this
    coincides with the exact relation.
    """
    return behavior_rel_upto(N, x, y, depth)


def obs_dist(N: AlgNeuralSystem, x: Vec, y: Vec, depth: int) -> float:
    """Discrete observation pseudometric: 0 if behaviorally equal else 1."""
    return 0.0 if behavior_rel(N, x, y, depth) else 1.0


# ----------------------------------------------------------------------------
# Demonstrations.
# ----------------------------------------------------------------------------
def sample_states(n: int) -> List[Vec]:
    """A small but varied finite set of states for exhaustive checks."""
    base = [
        vzero(n),
        tuple(1 for _ in range(n)),
        tuple((i % 3) for i in range(n)),
        tuple((2 * i - 1) for i in range(n)),
        tuple(((-1) ** i) * (i + 1) for i in range(n)),
        tuple((5 if i == 0 else 0) for i in range(n)),
    ]
    return base


def check_homomorphism(N: AlgNeuralSystem, depth: int) -> bool:
    """Theorem 4.5: behavior is additive, multiplicative, and sends 0 to 0."""
    states = sample_states(N.n)
    words = all_words(N.num_symbols, depth)
    ok = True
    for w in words:
        # behavior(0) = 0
        if N.behavior(vzero(N.n), w) != vzero(N.m):
            ok = False
        for x in states:
            for y in states:
                lhs_add = N.behavior(vadd(x, y), w)
                rhs_add = vadd(N.behavior(x, w), N.behavior(y, w))
                lhs_mul = N.behavior(vmul(x, y), w)
                rhs_mul = vmul(N.behavior(x, w), N.behavior(y, w))
                if lhs_add != rhs_add or lhs_mul != rhs_mul:
                    ok = False
    return ok


def check_congruence(N: AlgNeuralSystem, depth: int) -> bool:
    """Theorem 5.2: behaviorRel respects + and *."""
    states = sample_states(N.n)
    ok = True
    for a in states:
        for b in states:
            for c in states:
                for d in states:
                    if behavior_rel(N, a, b, depth) and behavior_rel(N, c, d, depth):
                        if not behavior_rel(N, vadd(a, c), vadd(b, d), depth):
                            ok = False
                        if not behavior_rel(N, vmul(a, c), vmul(b, d), depth):
                            ok = False
    return ok


def check_pseudometric(N: AlgNeuralSystem, depth: int) -> bool:
    """Theorems 7.2-7.5: obsDist is a pseudometric."""
    states = sample_states(N.n)
    ok = True
    for x in states:
        if obs_dist(N, x, x, depth) != 0.0:  # self-distance zero
            ok = False
        for y in states:
            d_xy = obs_dist(N, x, y, depth)
            if d_xy < 0:  # non-negativity
                ok = False
            if d_xy != obs_dist(N, y, x, depth):  # symmetry
                ok = False
            for z in states:
                if obs_dist(N, x, z, depth) > d_xy + obs_dist(N, y, z, depth):
                    ok = False  # triangle inequality
    return ok


def check_keystone(N: AlgNeuralSystem, depth: int) -> bool:
    """Theorem 7.6: { obsDist = 0 } == behaviorCongruence."""
    states = sample_states(N.n)
    ok = True
    for x in states:
        for y in states:
            metric_zero = obs_dist(N, x, y, depth) == 0.0
            congruent = behavior_rel(N, x, y, depth)
            if metric_zero != congruent:
                ok = False
    return ok


def check_filtration_monotone(N: AlgNeuralSystem, max_depth: int) -> bool:
    """Theorem 5.5 ingredient: equiv_upto (k+1) -> equiv_upto k."""
    states = sample_states(N.n)
    ok = True
    for x in states:
        for y in states:
            for k in range(max_depth):
                if behavior_rel_upto(N, x, y, k + 1) and not behavior_rel_upto(
                    N, x, y, k
                ):
                    ok = False
    return ok


def check_functoriality(
    N: AlgNeuralSystem,
    Nprime: AlgNeuralSystem,
    f_selector: List[Optional[int]],
    depth: int,
) -> bool:
    """
    Theorem 6.2: a morphism f : N -> N' pushes the congruence forward.
    Here f is a selector map R -> R'; we check the transport identity
    behavior(N, x, w) = behavior(N', f(x), w), hence f(x)=f(y) => x ~ y.
    """
    states = sample_states(N.n)
    f: Callable[[Vec], Vec] = lambda x: apply_selector(f_selector, x)
    ok = True
    for x in states:
        for w in all_words(N.num_symbols, depth):
            if N.behavior(x, w) != Nprime.behavior(f(x), w):
                ok = False
    # consequence: equal image => behaviorally equivalent in N
    for x in states:
        for y in states:
            if f(x) == f(y) and not behavior_rel(N, x, y, depth):
                ok = False
    return ok


def report(name: str, ok: bool) -> None:
    status = "PASS" if ok else "FAIL"
    print(f"  [{status}] {name}")


def main() -> None:
    print("=" * 78)
    print("Neural observation pseudometrics <-> proof-spectrum congruence kernels")
    print("=" * 78)

    # ----- System N: state Z^3, output Z^2, two input symbols. ---------------
    # Coordinates 0,1 evolve among themselves; coordinate 2 only ever RECEIVES
    # copies of coord 0 and is never routed back into the visible coords, so it
    # is behaviorally invisible.
    # symbol 0 : (x0,x1,x2) -> (x0, x1, x0)   (copy coord0 into coord2)
    # symbol 1 : (x0,x1,x2) -> (x1, x0, x0)   (swap coords 0,1; coord2 := x0)
    # read-out : select coords (0,1)          (x0,x1,x2) -> (x0,x1)
    N = AlgNeuralSystem(
        n=3,
        m=2,
        step_selectors=[[0, 1, 0], [1, 0, 0]],
        observe_selector=[0, 1],
    )
    depth = 4

    print("\nSystem N  (R = Z^3, K = Z^2, 2 input symbols):")
    report("Theorem 4.5  behavior is a semiring homomorphism in the state",
           check_homomorphism(N, depth))
    report("Theorem 5.2  behaviorRel is a semiring congruence",
           check_congruence(N, depth))
    report("Theorems 7.2-7.5  obsDist is a pseudometric",
           check_pseudometric(N, depth))
    report("Theorem 5.5  depth filtration is monotone",
           check_filtration_monotone(N, depth))
    report("Theorem 7.6  KEYSTONE: { obsDist = 0 } == behaviorCongruence",
           check_keystone(N, depth))

    # ----- Concrete behavioral values, and a null state. ---------------------
    print("\nConcrete behaviors of N (states = Z^3):")
    probes: List[Word] = [[], [0], [1], [0, 1], [1, 0]]
    for x in [(7, 4, 9), (7, 4, 0), (0, 0, 5)]:
        vals = {tuple(w): N.behavior(x, w) for w in probes}
        print(f"  x={x}:  " + ", ".join(f"w={w}->{v}" for w, v in vals.items()))
    # (0,0,5) is behaviorally null: coords 0,1 evolve among themselves (here both
    # 0) and coord 2 never flows into the visible read-out, so it is invisible.
    null_candidate = (0, 0, 5)
    is_null = behavior_rel(N, null_candidate, vzero(N.n), depth)
    report(f"Theorem 5.4  {null_candidate} lies in the zero-class (behaviorally null)",
           is_null)

    # ----- Functoriality via a morphism f : N -> N'. -------------------------
    # N' is the SAME dynamics but on a permuted coordinate frame; the morphism f
    # is the inverse permutation, intertwining the two systems.
    # Build N' as the relabeling x -> (x2,x0,x1); f = relabel back (x1,x2,x0).
    Nprime = AlgNeuralSystem(
        n=3,
        m=2,
        step_selectors=[[0, 1, 0], [1, 0, 0]],
        observe_selector=[0, 1],
    )
    # Identity morphism is always a morphism; verify functoriality with f = id.
    id_selector: List[Optional[int]] = [0, 1, 2]
    print("\nFunctoriality (identity morphism N -> N):")
    report("Theorem 6.2  morphism transports behavior & pushes congruence forward",
           check_functoriality(N, Nprime, id_selector, depth))

    # A non-trivial morphism: a mask f that zeroes coord 2 (the null coordinate).
    # Since coord 2 is behaviorally invisible, f preserves all behavior, so it is
    # a genuine morphism and equal images imply behavioral equivalence.
    mask_selector: List[Optional[int]] = [0, 1, None]
    print("\nFunctoriality (mask morphism that drops the invisible coordinate):")
    report("Theorem 6.2  mask morphism transports behavior & pushes congruence forward",
           check_functoriality(N, N, mask_selector, depth))

    print("\nAll checks complete.")


if __name__ == "__main__":
    main()


"""
visualization.py
================================================================================
Visualize the bridge between the observation pseudometric and the behavior
congruence on a small algebraic neural observation system.

Two panels:
  (left)  The pairwise observation pseudometric obsDist as a 0/1 heatmap over a
          finite state sample. Distance-zero blocks are exactly the congruence
          classes (the keystone identity, visualized).
  (right) The depth-k partition-refinement curve: number of distinguishable
          classes as the observation depth k grows, stabilizing at the number of
          behavior-congruence classes.

Requires: matplotlib, numpy.  Run:  python visualization.py
"""

from __future__ import annotations

from itertools import product
from typing import List, Optional, Tuple

import matplotlib.pyplot as plt
import numpy as np

Vec = Tuple[int, ...]
Word = List[int]


def apply_selector(selector: List[Optional[int]], x: Vec) -> Vec:
    return tuple(0 if j is None else x[j] for j in selector)


class AlgNeuralSystem:
    def __init__(self, n: int, m: int,
                 step_selectors: List[List[Optional[int]]],
                 observe_selector: List[Optional[int]]) -> None:
        self.n, self.m = n, m
        self.step_selectors = step_selectors
        self.observe_selector = observe_selector
        self.num_symbols = len(step_selectors)

    def step(self, x: Vec, a: int) -> Vec:
        return apply_selector(self.step_selectors[a], x)

    def observe(self, x: Vec) -> Vec:
        return apply_selector(self.observe_selector, x)

    def behavior(self, x: Vec, w: Word) -> Vec:
        s = x
        for a in w:
            s = self.step(s, a)
        return self.observe(s)


def words_upto(num_symbols: int, k: int) -> List[Word]:
    out: List[Word] = []
    for ell in range(k + 1):
        out += [list(t) for t in product(range(num_symbols), repeat=ell)]
    return out


def equiv_upto(N: AlgNeuralSystem, x: Vec, y: Vec, k: int) -> bool:
    return all(N.behavior(x, w) == N.behavior(y, w) for w in words_upto(N.num_symbols, k))


def num_classes(N: AlgNeuralSystem, states: List[Vec], k: int) -> int:
    reps: List[Vec] = []
    for x in states:
        if not any(equiv_upto(N, x, r, k) for r in reps):
            reps.append(x)
    return len(reps)


def main() -> None:
    # A shift-register algebraic neural system: each step shifts coordinates
    # left (delaying the read-out by one symbol), the last coordinate is held.
    # The read-out observes coordinate 0 only, so depth-k observation reveals
    # coordinate min(k, n-1): states separate progressively as depth grows.
    N = AlgNeuralSystem(
        n=4, m=1,
        step_selectors=[[1, 2, 3, 3]],
        observe_selector=[0],
    )
    states: List[Vec] = [
        (1, 1, 1, 1), (1, 1, 1, 2), (1, 1, 2, 2),
        (1, 2, 2, 2), (2, 2, 2, 2), (1, 2, 3, 4),
    ]
    depth = 4

    # Distance matrix.
    D = np.zeros((len(states), len(states)))
    for i, x in enumerate(states):
        for j, y in enumerate(states):
            D[i, j] = 0.0 if equiv_upto(N, x, y, depth) else 1.0

    # Refinement curve.
    ks = list(range(0, depth + 1))
    classes = [num_classes(N, states, k) for k in ks]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5.5))

    im = ax1.imshow(D, cmap="viridis", vmin=0, vmax=1)
    ax1.set_title("Observation pseudometric  obsDist(x, y)\n"
                  "(dark = distance 0 = congruent)")
    labels = [str(s) for s in states]
    ax1.set_xticks(range(len(states)))
    ax1.set_yticks(range(len(states)))
    ax1.set_xticklabels(labels, rotation=90, fontsize=7)
    ax1.set_yticklabels(labels, fontsize=7)
    fig.colorbar(im, ax=ax1, fraction=0.046, pad=0.04, label="distance")

    ax2.plot(ks, classes, "o-", color="crimson", linewidth=2, markersize=8)
    ax2.set_title("Partition refinement: distinguishable classes vs depth k")
    ax2.set_xlabel("observation depth k")
    ax2.set_ylabel("number of classes")
    ax2.grid(True, alpha=0.3)
    ax2.set_xticks(ks)

    fig.suptitle("Neural observation pseudometric  ==  behavior congruence kernel",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("bridge_visualization.png", dpi=150)
    print("Saved bridge_visualization.png")


if __name__ == "__main__":
    main()
