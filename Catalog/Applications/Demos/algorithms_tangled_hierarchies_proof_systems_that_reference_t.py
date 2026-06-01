"""
Algorithms for Tangled Hierarchies: Proof Systems That Reference Their Own Soundness

Type-hinted implementations of core algorithms from the formalization.
"""

from typing import List, Tuple, Dict, Set, Optional, Callable
from dataclasses import dataclass


# ============================================================
# Algorithm 1: GL Formula Construction and Modal Depth
# ============================================================

@dataclass
class GLFormula:
    """Modal formula for provability logic GL."""
    pass

@dataclass
class Var(GLFormula):
    index: int

@dataclass
class Bot(GLFormula):
    pass

@dataclass
class Imp(GLFormula):
    left: GLFormula
    right: GLFormula

@dataclass
class Box(GLFormula):
    inner: GLFormula


def neg(phi: GLFormula) -> GLFormula:
    """Negation: ¬φ := φ → ⊥"""
    return Imp(phi, Bot())

def modal_depth(phi: GLFormula) -> int:
    """Compute the modal depth of a GL formula."""
    if isinstance(phi, Var) or isinstance(phi, Bot):
        return 0
    elif isinstance(phi, Imp):
        return max(modal_depth(phi.left), modal_depth(phi.right))
    elif isinstance(phi, Box):
        return modal_depth(phi.inner) + 1
    raise TypeError(f"Unknown formula type: {type(phi)}")


def soundness_op(phi: GLFormula) -> GLFormula:
    """The soundness operator: □φ → φ"""
    return Imp(Box(phi), phi)


def iterated_soundness(n: int, phi: GLFormula) -> GLFormula:
    """Apply the soundness operator n times."""
    result = phi
    for _ in range(n):
        result = soundness_op(result)
    return result


def con_formula(n: int) -> GLFormula:
    """The n-th consistency formula.
    Con_0 = ¬⊥, Con_{n+1} = ¬□¬Con_n
    """
    if n == 0:
        return neg(Bot())
    return neg(Box(neg(con_formula(n - 1))))


def entanglement_depth(phi: GLFormula) -> int:
    """Compute the entanglement depth: counts nested □φ → φ patterns."""
    if isinstance(phi, Var) or isinstance(phi, Bot):
        return 0
    elif isinstance(phi, Box):
        return entanglement_depth(phi.inner)
    elif isinstance(phi, Imp):
        if isinstance(phi.left, Box) and phi.left.inner == phi.right:
            return entanglement_depth(phi.right) + 1
        return max(entanglement_depth(phi.left), entanglement_depth(phi.right))
    raise TypeError(f"Unknown formula type: {type(phi)}")


# ============================================================
# Algorithm 2: Kripke Frame Evaluation
# ============================================================

@dataclass
class GLFrame:
    """A GL-frame: finite, transitive, irreflexive accessibility."""
    num_worlds: int
    R: List[List[bool]]  # R[i][j] = True iff world i sees world j

    def is_valid(self) -> bool:
        """Check that R is transitive and irreflexive."""
        n = self.num_worlds
        # Irreflexivity
        for i in range(n):
            if self.R[i][i]:
                return False
        # Transitivity
        for i in range(n):
            for j in range(n):
                for k in range(n):
                    if self.R[i][j] and self.R[j][k] and not self.R[i][k]:
                        return False
        return True


def linear_chain_frame(n: int) -> GLFrame:
    """Construct a linear chain frame with n worlds."""
    R = [[i < j for j in range(n)] for i in range(n)]
    return GLFrame(num_worlds=n, R=R)


def forces(frame: GLFrame, valuation: Dict[int, List[bool]],
           world: int, phi: GLFormula) -> bool:
    """Evaluate whether world forces phi under valuation."""
    if isinstance(phi, Var):
        return valuation.get(phi.index, [False] * frame.num_worlds)[world]
    elif isinstance(phi, Bot):
        return False
    elif isinstance(phi, Imp):
        return (not forces(frame, valuation, world, phi.left) or
                forces(frame, valuation, world, phi.right))
    elif isinstance(phi, Box):
        return all(
            not frame.R[world][w2] or forces(frame, valuation, w2, phi.inner)
            for w2 in range(frame.num_worlds)
        )
    raise TypeError(f"Unknown formula type: {type(phi)}")


def is_valid_in_frame(frame: GLFrame, phi: GLFormula) -> bool:
    """Check if phi is valid in the frame (for small frames, brute-force)."""
    # Only practical for very small frames and formulas with few variables
    var_indices = collect_variables(phi)
    if not var_indices:
        return all(forces(frame, {}, w, phi)
                   for w in range(frame.num_worlds))
    # Enumerate all valuations
    n = frame.num_worlds
    for bits in range(2 ** (len(var_indices) * n)):
        val: Dict[int, List[bool]] = {}
        for idx_i, var_idx in enumerate(var_indices):
            val[var_idx] = []
            for w in range(n):
                bit_pos = idx_i * n + w
                val[var_idx].append(bool((bits >> bit_pos) & 1))
        if not all(forces(frame, val, w, phi)
                   for w in range(n)):
            return False
    return True


def collect_variables(phi: GLFormula) -> List[int]:
    """Collect all variable indices appearing in a formula."""
    if isinstance(phi, Var):
        return [phi.index]
    elif isinstance(phi, Bot):
        return []
    elif isinstance(phi, Imp):
        left_vars = collect_variables(phi.left)
        right_vars = collect_variables(phi.right)
        return list(set(left_vars + right_vars))
    elif isinstance(phi, Box):
        return collect_variables(phi.inner)
    return []


# ============================================================
# Algorithm 3: Tangling Level Computation
# ============================================================

def compute_tangling_levels(frame: GLFrame,
                            valuation: Dict[int, List[bool]],
                            max_depth: int) -> Dict[int, List[int]]:
    """For each depth k, find worlds that witness tangling at depth k.

    A world witnesses tangling at depth k if it forces Con_k but not Con_{k+1}.
    """
    levels: Dict[int, List[int]] = {}
    for k in range(max_depth):
        witnesses = []
        con_k = con_formula(k)
        con_k1 = con_formula(k + 1)
        for w in range(frame.num_worlds):
            if (forces(frame, valuation, w, con_k) and
                    not forces(frame, valuation, w, con_k1)):
                witnesses.append(w)
        if witnesses:
            levels[k] = witnesses
    return levels


def box_orbit(box_fn: Callable[[int], int], x: int,
              carrier_size: int) -> Tuple[int, int]:
    """Find cycle in box orbit using Floyd's algorithm.

    Returns (mu, lam) where mu is the index of the first repeated element
    and lam is the cycle length.
    """
    # Phase 1: Find meeting point
    tortoise = box_fn(x)
    hare = box_fn(box_fn(x))
    steps = 0
    while tortoise != hare and steps < carrier_size + 1:
        tortoise = box_fn(tortoise)
        hare = box_fn(box_fn(hare))
        steps += 1

    # Phase 2: Find start of cycle
    mu = 0
    tortoise = x
    while tortoise != hare and mu < carrier_size + 1:
        tortoise = box_fn(tortoise)
        hare = box_fn(hare)
        mu += 1

    # Phase 3: Find cycle length
    lam = 1
    hare = box_fn(tortoise)
    while tortoise != hare:
        hare = box_fn(hare)
        lam += 1

    return mu, lam


# ============================================================
# Algorithm 4: Optimal Tangling Bound Verification
# ============================================================

def enumerate_gl_frames(n: int) -> List[GLFrame]:
    """Enumerate all transitive, irreflexive relations on n elements.
    Warning: exponential in n — only for small n.
    """
    frames: List[GLFrame] = []
    # There are n*(n-1)/2 possible directed edges (excluding self-loops)
    edges = [(i, j) for i in range(n) for j in range(n) if i != j]
    num_edges = len(edges)

    for bits in range(2 ** num_edges):
        R = [[False] * n for _ in range(n)]
        for idx, (i, j) in enumerate(edges):
            if (bits >> idx) & 1:
                R[i][j] = True

        frame = GLFrame(num_worlds=n, R=R)
        if frame.is_valid():
            frames.append(frame)

    return frames


def verify_tangling_bound(n: int, max_depth: int = 10) -> bool:
    """Verify the optimal tangling bound conjecture for frames of size n.

    Returns True if for all GL-frames of size n and all valuations,
    the number of tangling levels is at most n.
    """
    frames = enumerate_gl_frames(n)
    for frame in frames:
        # Test with the trivial valuation
        val: Dict[int, List[bool]] = {}
        levels = compute_tangling_levels(frame, val, max_depth)
        if len(levels) > n:
            return False
    return True
