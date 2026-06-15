"""
Numerical demonstrations for:

    "A Functorial Comparison of Neural Observation Pseudometrics and Proof Spectra"

This file is fully self-contained (standard library only). It realizes the
mathematics of the accompanying article/paper over the BOOLEAN SEMIRING

    B = {0, 1}   with   a + b = a OR b   and   a * b = a AND b,   0 = False, 1 = True

and over finite powers B^n with componentwise operations. We model an
*algebraic neural observation system* whose state space R = B^n and output space
K = B^m carry this semiring structure, and whose layers `step(., a)` and read-out
`observe` are SEMIRING HOMOMORPHISMS (they preserve 0, OR, AND componentwise).

Concretely, every such componentwise homomorphism B^n -> B^k is a "wiring": each
output coordinate is either a constant 0 or a copy of a single input coordinate.
(Any OR of two distinct input coordinates fails to preserve AND, so single-source
wirings are exactly the homomorphisms.) This gives a rich yet faithful playground.

We verify, numerically:
  * Proposition: the behavior map is a homomorphism in the state (additive,
    multiplicative, zero-preserving).
  * The behavior relation is a semiring congruence (compatible with OR and AND).
  * obsDist is a {0,1}-valued pseudometric (triangle inequality holds).
  * The comparison theorem: obsDist(x,y) = 0  <=>  behaviorRel(x,y).
  * The quotient metric quotObsDist satisfies SEPARATION (distinct classes are
    at distance 1), curing the pseudometric's defect.
  * Functoriality: an intertwining morphism preserves behavior and pushes the
    congruence forward.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, FrozenSet, List, Optional, Sequence, Tuple

# A Boolean vector / state is a tuple of 0/1 ints.
Vec = Tuple[int, ...]
# A "wiring" B^n -> B^k: for each output coordinate, either None (constant 0)
# or an int j meaning "copy input coordinate j". This is exactly a componentwise
# semiring homomorphism.
Wiring = Tuple[Optional[int], ...]


# --------------------------------------------------------------------------- #
# Semiring B^n: componentwise OR (+) and AND (*)                              #
# --------------------------------------------------------------------------- #
def vor(x: Vec, y: Vec) -> Vec:
    """Componentwise addition in B^n (logical OR)."""
    return tuple(a | b for a, b in zip(x, y))


def vand(x: Vec, y: Vec) -> Vec:
    """Componentwise multiplication in B^n (logical AND)."""
    return tuple(a & b for a, b in zip(x, y))


def vzero(n: int) -> Vec:
    """Additive identity 0 of B^n."""
    return tuple(0 for _ in range(n))


def apply_wiring(wiring: Wiring, x: Vec) -> Vec:
    """Apply a semiring homomorphism (wiring) to a state."""
    return tuple(0 if src is None else x[src] for src in wiring)


# --------------------------------------------------------------------------- #
# Algebraic neural observation system                                          #
# --------------------------------------------------------------------------- #
class AlgNeuralSystem:
    """An algebraic neural observation system over (B^n, B^m, alphabet).

    `steps[a]` is the wiring (homomorphism) for input symbol `a`.
    `observe` is the read-out wiring B^n -> B^m.
    """

    def __init__(
        self,
        n: int,
        m: int,
        steps: Dict[str, Wiring],
        observe: Wiring,
    ) -> None:
        self.n = n
        self.m = m
        self.steps = steps
        self.observe = observe
        self.alphabet: List[str] = sorted(steps.keys())

    def step(self, x: Vec, a: str) -> Vec:
        return apply_wiring(self.steps[a], x)

    def read(self, x: Vec) -> Vec:
        return apply_wiring(self.observe, x)

    def behavior(self, x: Vec, word: Sequence[str]) -> Vec:
        """behavior(x, w) = observe(foldl(step, x, w))."""
        state = x
        for a in word:
            state = self.step(state, a)
        return self.read(state)

    def all_states(self) -> List[Vec]:
        return [tuple(bits) for bits in product((0, 1), repeat=self.n)]

    def words_upto(self, k: int) -> List[Tuple[str, ...]]:
        """All input contexts (words) of length <= k."""
        out: List[Tuple[str, ...]] = [()]
        for length in range(1, k + 1):
            out.extend(product(self.alphabet, repeat=length))
        return out

    def equiv_upto(self, x: Vec, y: Vec, k: int) -> bool:
        """Depth-k behavioral equivalence (agree on all words of length <= k)."""
        return all(self.behavior(x, w) == self.behavior(y, w)
                   for w in self.words_upto(k))

    def behavior_rel(self, x: Vec, y: Vec) -> bool:
        """Full behavioral equivalence.

        By Myhill-Nerode (finite state set of size 2^n), depth n suffices:
        equivalence on words up to length 2^n is full behavioral equivalence.
        We use depth n + 2 as a safe, finite witness for these small systems.
        """
        return self.equiv_upto(x, y, self.n + 2)

    def obs_dist(self, x: Vec, y: Vec) -> int:
        """The observation pseudometric: 0 if behaviorally equal, else 1."""
        return 0 if self.behavior_rel(x, y) else 1

    def classes(self) -> List[FrozenSet[Vec]]:
        """The behavioral quotient: states modulo behavioral indistinguishability."""
        remaining = list(self.all_states())
        out: List[FrozenSet[Vec]] = []
        while remaining:
            rep = remaining[0]
            cls = [s for s in remaining if self.behavior_rel(rep, s)]
            out.append(frozenset(cls))
            remaining = [s for s in remaining if s not in cls]
        return out

    def quot_obs_dist(self, cx: FrozenSet[Vec], cy: FrozenSet[Vec]) -> int:
        """Descended distance on classes: pick representatives and measure."""
        return self.obs_dist(next(iter(cx)), next(iter(cy)))


# --------------------------------------------------------------------------- #
# Morphisms of algebraic neural systems                                        #
# --------------------------------------------------------------------------- #
class AlgNeuralHom:
    """A morphism f: N -> M intertwining the dynamics and read-out.

    Requires, for all states x and symbols a:
        f(step_N(x, a)) = step_M(f(x), a)   and   observe_N(x) = observe_M(f(x)).
    f need NOT be a semiring homomorphism -- only intertwine the dynamics.
    """

    def __init__(self, source: AlgNeuralSystem, target: AlgNeuralSystem,
                 fun: Callable[[Vec], Vec]) -> None:
        self.source = source
        self.target = target
        self.fun = fun

    def check_intertwines(self) -> bool:
        N, M = self.source, self.target
        for x in N.all_states():
            if N.read(x) != M.read(self.fun(x)):
                return False
            for a in N.alphabet:
                if self.fun(N.step(x, a)) != M.step(self.fun(x), a):
                    return False
        return True


# --------------------------------------------------------------------------- #
# Demonstrations                                                               #
# --------------------------------------------------------------------------- #
def demo_homomorphism(N: AlgNeuralSystem) -> None:
    print("=" * 70)
    print("1. Behavior is a homomorphism in the state (Proposition 2.4)")
    print("=" * 70)
    states = N.all_states()
    words = N.words_upto(N.n + 1)
    add_ok = mul_ok = zero_ok = True
    for w in words:
        if N.behavior(vzero(N.n), w) != vzero(N.m):
            zero_ok = False
        for x in states:
            for y in states:
                if N.behavior(vor(x, y), w) != vor(N.behavior(x, w), N.behavior(y, w)):
                    add_ok = False
                if N.behavior(vand(x, y), w) != vand(N.behavior(x, w), N.behavior(y, w)):
                    mul_ok = False
    print(f"  behavior(0, w) = 0            : {zero_ok}")
    print(f"  behavior(x OR y) = b(x) OR b(y): {add_ok}")
    print(f"  behavior(x AND y)= b(x) AND b(y): {mul_ok}")
    print()


def demo_congruence(N: AlgNeuralSystem) -> None:
    print("=" * 70)
    print("2. Behavioral equivalence is a semiring congruence (Theorem 3.2)")
    print("=" * 70)
    states = N.all_states()
    add_compat = mul_compat = True
    for a in states:
        for b in states:
            if not N.behavior_rel(a, b):
                continue
            for c in states:
                for d in states:
                    if not N.behavior_rel(c, d):
                        continue
                    if not N.behavior_rel(vor(a, c), vor(b, d)):
                        add_compat = False
                    if not N.behavior_rel(vand(a, c), vand(b, d)):
                        mul_compat = False
    print(f"  a~b, c~d => (a OR c) ~ (b OR d) : {add_compat}")
    print(f"  a~b, c~d => (a AND c)~ (b AND d): {mul_compat}")
    print()


def demo_pseudometric(N: AlgNeuralSystem) -> None:
    print("=" * 70)
    print("3. obsDist is a pseudometric (Theorem 5.2) and kernel = congruence")
    print("=" * 70)
    states = N.all_states()
    nonneg = self_zero = symm = triangle = kernel = True
    for x in states:
        if N.obs_dist(x, x) != 0:
            self_zero = False
        for y in states:
            d = N.obs_dist(x, y)
            if d < 0:
                nonneg = False
            if d != N.obs_dist(y, x):
                symm = False
            if (d == 0) != N.behavior_rel(x, y):
                kernel = False
            for z in states:
                if N.obs_dist(x, z) > N.obs_dist(x, y) + N.obs_dist(y, z):
                    triangle = False
    print(f"  non-negativity            : {nonneg}")
    print(f"  obsDist(x,x) = 0          : {self_zero}")
    print(f"  symmetry                  : {symm}")
    print(f"  triangle inequality       : {triangle}")
    print(f"  obsDist=0 <=> behaviorRel : {kernel}   (comparison theorem)")
    print()


def demo_quotient(N: AlgNeuralSystem) -> None:
    print("=" * 70)
    print("4. The behavioral quotient carries a genuine METRIC (Theorem 6.5)")
    print("=" * 70)
    classes = N.classes()
    print(f"  |states| = {len(N.all_states())}   ->   |behavior classes| = {len(classes)}")
    for i, cls in enumerate(classes):
        members = sorted("".join(map(str, s)) for s in cls)
        print(f"    class {i}: {{ {', '.join(members)} }}")
    # Separation: distinct classes are at distance 1, equal classes at 0.
    separation = True
    for cx in classes:
        for cy in classes:
            d = N.quot_obs_dist(cx, cy)
            same = cx == cy
            if (d == 0) != same:
                separation = False
    print(f"  separation: quotObsDist(X,Y)=0 <=> X=Y : {separation}")
    print()


def demo_functoriality() -> None:
    print("=" * 70)
    print("5. Functoriality: a morphism preserves behavior and pushes the")
    print("   congruence forward (Theorem 4.2, Corollary 4.3)")
    print("=" * 70)
    # Source N: 3-bit state, observe bit 0; step 'a' rotates bits left.
    N = AlgNeuralSystem(
        n=3, m=1,
        steps={"a": (1, 2, 0)},          # rotate: out_i = in_{i+1}
        observe=(0,),                     # read coordinate 0
    )
    # Target M: 3-bit state, same shape (an isomorphic relabeling by a fixed
    # permutation pi = (0 1 2) -> (2 0 1)). We intertwine via that permutation.
    pi = (2, 0, 1)  # f(x)_i = x_{pi^{-1}(i)}; build f directly below
    inv = [0, 0, 0]
    for i, p in enumerate(pi):
        inv[p] = i

    def f(x: Vec) -> Vec:
        return tuple(x[inv[i]] for i in range(3))

    # M must satisfy f(step_N(x,a)) = step_M(f(x),a) and observe_N = observe_M . f.
    # With f a coordinate permutation, the conjugated wiring/observe realize this.
    def conj_wiring(w: Wiring) -> Wiring:
        # step_M = f . step_N . f^{-1}
        out: List[Optional[int]] = [None] * 3
        for i in range(3):
            src = w[inv[i]]
            out[i] = None if src is None else pi[src]
        return tuple(out)

    M = AlgNeuralSystem(
        n=3, m=1,
        steps={"a": conj_wiring(N.steps["a"])},
        observe=tuple(N.observe[0] if N.observe[0] is None else inv.index(N.observe[0])
                      for _ in range(1)),
    )
    # Rebuild M.observe so that observe_N(x) = observe_M(f(x)); for a single read
    # coordinate j, M reads coordinate pi[j].
    M.observe = (pi[N.observe[0]],)

    hom = AlgNeuralHom(N, M, f)
    print(f"  f intertwines the dynamics and read-out : {hom.check_intertwines()}")

    # Behavior preservation: behavior_N(x,w) = behavior_M(f(x),w).
    words = N.words_upto(5)
    pres = all(N.behavior(x, w) == M.behavior(f(x), w)
               for x in N.all_states() for w in words)
    print(f"  behavior_N(x,w) = behavior_M(f(x),w)    : {pres}")

    # Congruence pushforward: x ~_N y  =>  f(x) ~_M f(y).
    push = True
    for x in N.all_states():
        for y in N.all_states():
            if N.behavior_rel(x, y) and not M.behavior_rel(f(x), f(y)):
                push = False
    print(f"  x ~_N y  =>  f(x) ~_M f(y)              : {push}")
    print()


def build_example() -> AlgNeuralSystem:
    """A 4-bit system with two input symbols, designed to have non-trivial
    behavioral collapse. Coordinates 2 and 3 are *unobservable*: no layer and no
    read-out ever copies from input index 2 or 3, so those bits can never affect
    any future observation. Hence states agreeing on bits 0,1 are behaviorally
    indistinguishable, collapsing 16 states down to 4 behavior classes."""
    return AlgNeuralSystem(
        n=4, m=1,
        steps={
            # 'a': out = (in1, in0, in0, in1)  -- only reads coordinates {0,1}
            "a": (1, 0, 0, 1),
            # 'b': out = (in0, in1, in1, in0)  -- only reads coordinates {0,1}
            "b": (0, 1, 1, 0),
        },
        observe=(0,),  # read coordinate 0; coordinates 2,3 never influence output
    )


def main() -> None:
    print()
    print("FUNCTORIAL COMPARISON OF NEURAL OBSERVATION PSEUDOMETRICS & PROOF SPECTRA")
    print("Boolean-semiring numerical demonstrations")
    print()
    N = build_example()
    demo_homomorphism(N)
    demo_congruence(N)
    demo_pseudometric(N)
    demo_quotient(N)
    demo_functoriality()
    print("All checks complete.")


if __name__ == "__main__":
    main()
