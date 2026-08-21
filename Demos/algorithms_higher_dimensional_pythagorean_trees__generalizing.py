"""Algorithm entries for PACKAGE.json (source of truth for the `algorithms` array)."""

CANONICAL_DESCENT_CODE = '''from math import gcd
from typing import List, Tuple

Quad = Tuple[int, int, int, int]


def content(q: Quad) -> int:
    """Greatest common divisor of the four entries."""
    g = 0
    for x in q:
        g = gcd(g, abs(x))
    return g


def is_pythagorean(q: Quad) -> bool:
    a, b, c, d = q
    return a * a + b * b + c * c == d * d


def canonical_parent(q: Quad) -> Quad:
    """One step of the canonical parent map: the all-plus Lorentz reflection
    (subtract k = a+b+c-d from every coordinate) followed by absolute values."""
    a, b, c, d = q
    k = a + b + c - d
    return (abs(a - k), abs(b - k), abs(c - k), d - k)


def descend_to_root(q: Quad) -> List[Quad]:
    """Full descent path of a primitive Pythagorean quadruple down to height one.

    Raises ValueError on input that is not a node (primitive, non-negative space
    coordinates, positive height).
    """
    a, b, c, d = q
    if not is_pythagorean(q) or d <= 0 or min(a, b, c) < 0 or content(q) != 1:
        raise ValueError(f"{q} is not a primitive Pythagorean quadruple in the positive cone")
    path = [q]
    while path[-1][3] > 1:
        nxt = canonical_parent(path[-1])
        if nxt[3] >= path[-1][3]:          # cannot happen for a node of height > 1
            raise RuntimeError("height failed to decrease")
        path.append(nxt)
    return path
'''

BFS_CODE = '''from collections import deque
from itertools import product
from math import gcd
from typing import Dict, List, Set, Tuple

Quad = Tuple[int, int, int, int]

ROOT: Quad = (1, 0, 0, 1)


def normalise(q: Quad) -> Quad:
    """Canonical representative: absolute values of the space coordinates, sorted."""
    a, b, c, d = q
    space = sorted(abs(x) for x in (a, b, c))
    return (space[0], space[1], space[2], d)


def children(q: Quad) -> List[Quad]:
    """The non-descending sign patterns applied to a node: its children.

    There are always six or seven of them: eight sign patterns minus the one or
    two descending ones.
    """
    a, b, c, d = q
    out: List[Quad] = []
    for e in product((1, -1), repeat=3):
        s = e[0] * a + e[1] * b + e[2] * c
        if s > d:                       # descending pattern: this is a parent
            continue
        v = (e[0] * a, e[1] * b, e[2] * c, d)
        k = v[0] + v[1] + v[2] - v[3]
        out.append(normalise((v[0] - k, v[1] - k, v[2] - k, v[3] - k)))
    return out


def generate(max_height: int) -> Dict[Quad, int]:
    """Breadth-first generation of all primitive Pythagorean quadruples of height
    at most `max_height`, returning each node with its distance from the root.

    A visited-set is mandatory: the quadruple graph is not a tree, so distinct
    words in the generators can reach the same node.
    """
    root = normalise(ROOT)
    seen: Dict[Quad, int] = {root: 0}
    queue: deque = deque([root])
    while queue:
        q = queue.popleft()
        for child in children(q):
            if child[3] > max_height or child in seen:
                continue
            seen[child] = seen[q] + 1
            queue.append(child)
    return seen
'''

HARMONIC_CODE = '''from fractions import Fraction
from typing import List, Tuple

Quad = Tuple[int, int, int, int]


def harmonic_report(q: Quad) -> dict:
    """Classify a Pythagorean quadruple by the harmonic branching law.

    For each coordinate x with the other two space coordinates y, z the law reads

        second parent  <=>  x (y + z) < y z   <=>   1/y + 1/z < 1/x,
        neutral move   <=>  x (y + z) = y z   <=>   1/y + 1/z = 1/x.

    At most one coordinate can satisfy the strict inequality, so the number of
    parents is 1 or 2 and the number of children is 7 or 6.
    """
    a, b, c, d = q
    coords = (a, b, c)
    harmonic_index = None
    neutral_index = None
    detail: List[Tuple[int, Fraction, Fraction, str]] = []
    for i in range(3):
        x, y, z = coords[i], coords[(i + 1) % 3], coords[(i + 2) % 3]
        if min(x, y, z) <= 0:
            detail.append((i, Fraction(0), Fraction(0), "degenerate"))
            continue
        lhs, rhs = Fraction(1, y) + Fraction(1, z), Fraction(1, x)
        if x * (y + z) < y * z:
            harmonic_index, tag = i, "harmonic (second parent)"
        elif x * (y + z) == y * z:
            neutral_index, tag = i, "neutral (height preserved)"
        else:
            tag = "plain"
        detail.append((i, lhs, rhs, tag))
    parents = 2 if harmonic_index is not None else 1
    return {
        "quadruple": q,
        "parents": parents,
        "children": 8 - parents,
        "harmonic_index": harmonic_index,
        "neutral_index": neutral_index,
        "detail": detail,
    }
'''

ALGORITHMS = [
    {
        "name": "Canonical Lorentz Descent to the Root Quadruple",
        "description": (
            "Given a primitive Pythagorean quadruple (a,b,c,d) with non-negative space "
            "coordinates and positive height, this algorithm computes its canonical descent "
            "path to the root (1,0,0,1). One step applies the all-ones Lorentz reflection, "
            "which subtracts k = a+b+c-d from every coordinate, and then takes absolute values "
            "of the space coordinates. Correctness rests on three facts. (i) The reflection is "
            "an integral automorphism of the Lorentz form of signature (3,1), so the "
            "Pythagorean relation is preserved, and the greatest common divisor of the four "
            "entries is preserved as well, so primitivity survives. (ii) For a primitive node "
            "of height d > 1 one has k > 0, because a+b+c <= d would force all pairwise "
            "products ab, bc, ca to vanish and hence, by primitivity, d = 1. (iii) The new "
            "height 2d-(a+b+c) is positive, since (a+b+c)^2 <= 3(a^2+b^2+c^2) = 3d^2 < 4d^2. "
            "Thus the height strictly decreases at every step and the iteration terminates. "
            "Each step costs O(1) integer operations; the height contracts by a factor lying in "
            "[2-sqrt(3), 2+sqrt(3)], and empirically the path length is O(log d), bounded above "
            "trivially by d. The edges traversed form the canonical spanning tree of the "
            "quadruple graph."
        ),
        "pseudocode": (
            "INPUT   a primitive Pythagorean quadruple q = (a,b,c,d), a,b,c >= 0, d > 0\n"
            "OUTPUT  the sequence q = q_0, q_1, ..., q_t with height(q_t) = 1\n"
            "\n"
            "1  assert a^2 + b^2 + c^2 = d^2 and gcd(a,b,c,d) = 1\n"
            "2  path <- [q]\n"
            "3  while height(last(path)) > 1 do\n"
            "4        (a,b,c,d) <- last(path)\n"
            "5        k <- a + b + c - d                    # the reflection shift, k > 0\n"
            "6        q' <- (|a-k|, |b-k|, |c-k|, d-k)      # reflect, then fold into the cone\n"
            "7        assert height(q') < height(last(path))\n"
            "8        append q' to path\n"
            "9  return path                                  # last entry is a permutation of (1,0,0,1)"
        ),
        "code": CANONICAL_DESCENT_CODE,
    },
    {
        "name": "Breadth-First Generation of the Pythagorean Quadruple Graph",
        "description": (
            "Enumerates every primitive Pythagorean quadruple of height at most X by growing "
            "outward from the root (1,0,0,1). At a node, each of the eight sign patterns "
            "eps in {+1,-1}^3 is applied to the space coordinates and then followed by the "
            "all-ones reflection; the patterns that strictly decrease the height are the node's "
            "parents and are skipped, and the remaining six or seven are its children. "
            "Completeness follows from the descent theorem: every primitive quadruple in the "
            "positive cone reaches the root under repeated canonical descent, hence is produced "
            "by the reverse process. Unlike the classical two-dimensional situation, the graph "
            "is not a tree - a node may have two parents, and infinitely many do - so a "
            "visited-set is mandatory to avoid duplicates and infinite regeneration; this is "
            "the operational fingerprint of the failure of the tree property. With a hash set "
            "the cost is O(N) hash operations for N nodes, and N grows empirically like X^2 "
            "(against X for Pythagorean triples)."
        ),
        "pseudocode": (
            "INPUT   height bound X\n"
            "OUTPUT  a dictionary mapping each primitive quadruple of height <= X to its\n"
            "        distance from the root\n"
            "\n"
            "1  root <- normalise((1,0,0,1)) = (0,0,1,1)\n"
            "2  seen <- { root : 0 };  queue <- [ root ]\n"
            "3  while queue is non-empty do\n"
            "4        q = (a,b,c,d) <- pop_front(queue)\n"
            "5        for each eps in {+1,-1}^3 do\n"
            "6              S <- eps_1*a + eps_2*b + eps_3*c\n"
            "7              if S > d then continue            # descending: a parent, not a child\n"
            "8              v <- (eps_1*a, eps_2*b, eps_3*c, d)\n"
            "9              k <- v_1 + v_2 + v_3 - v_4\n"
            "10             q' <- normalise( v - (k,k,k,k) )  # absolute values, sorted\n"
            "11             if height(q') <= X and q' not in seen then\n"
            "12                   seen[q'] <- seen[q] + 1;  push_back(queue, q')\n"
            "13 return seen"
        ),
        "code": BFS_CODE,
    },
    {
        "name": "Harmonic Branching Classifier (Egyptian-Fraction Test)",
        "description": (
            "Decides, in O(1) integer operations, how many parents a Pythagorean quadruple has "
            "and whether it carries a height-preserving move. The mathematical content is the "
            "harmonic branching law: the reflection with a minus sign on the coordinate x "
            "strictly lowers the height if and only if x(y+z) < yz, equivalently "
            "1/y + 1/z < 1/x, where y, z are the other two space coordinates; equality "
            "x(y+z) = yz makes the move neutral, leaving the height unchanged. Adding the two "
            "inequalities for different coordinates yields 2xy < 0, so the strict inequality "
            "can hold for at most one coordinate; combined with the fact that the all-plus "
            "pattern always descends and that any pattern with two or more minus signs cannot, "
            "the parent count is exactly 1 or 2 and the branching number is 7 or 6. Because the "
            "criterion is homogeneous of degree two in (x,y,z), it is scale-invariant and hence "
            "defines a region on the unit sphere: the classifier is literally reading off which "
            "spherical region the normalised node lies in."
        ),
        "pseudocode": (
            "INPUT   a Pythagorean quadruple q = (a,b,c,d) with positive entries\n"
            "OUTPUT  parent count, harmonic index (if any), neutral index (if any)\n"
            "\n"
            "1  harmonic <- none;  neutral <- none\n"
            "2  for i in {0,1,2} do\n"
            "3        x <- coordinate i;  y, z <- the other two space coordinates\n"
            "4        if x*(y+z) <  y*z then harmonic <- i     # 1/y + 1/z < 1/x\n"
            "5        if x*(y+z) =  y*z then neutral  <- i     # 1/y + 1/z = 1/x\n"
            "6  parents <- 2 if harmonic is set else 1         # the all-plus pattern always descends\n"
            "7  return (parents, 8 - parents, harmonic, neutral)"
        ),
        "code": HARMONIC_CODE,
    },
]
