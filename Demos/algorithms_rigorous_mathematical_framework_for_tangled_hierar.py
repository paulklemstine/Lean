"""
Algorithms for Tangled Hierarchy Spectral Theory
================================================

Type-hinted implementations of the core algorithms from the formalization.
"""

from typing import List, Tuple, Dict, Set, Optional
from dataclasses import dataclass


@dataclass
class GLFormula:
    """Modal formula for provability logic GL."""
    kind: str  # 'var', 'bot', 'imp', 'box'
    children: Tuple  # varies by kind

    @staticmethod
    def var(n: int) -> 'GLFormula':
        return GLFormula('var', (n,))

    @staticmethod
    def bot() -> 'GLFormula':
        return GLFormula('bot', ())

    @staticmethod
    def imp(phi: 'GLFormula', psi: 'GLFormula') -> 'GLFormula':
        return GLFormula('imp', (phi, psi))

    @staticmethod
    def box(phi: 'GLFormula') -> 'GLFormula':
        return GLFormula('box', (phi,))

    @staticmethod
    def neg(phi: 'GLFormula') -> 'GLFormula':
        return GLFormula.imp(phi, GLFormula.bot())

    def __repr__(self) -> str:
        if self.kind == 'var':
            return f'p{self.children[0]}'
        elif self.kind == 'bot':
            return '⊥'
        elif self.kind == 'imp':
            return f'({self.children[0]} → {self.children[1]})'
        elif self.kind == 'box':
            return f'□{self.children[0]}'
        return '?'


def modal_depth(phi: GLFormula) -> int:
    """Compute the modal depth of a formula."""
    if phi.kind == 'var' or phi.kind == 'bot':
        return 0
    elif phi.kind == 'imp':
        return max(modal_depth(phi.children[0]), modal_depth(phi.children[1]))
    elif phi.kind == 'box':
        return modal_depth(phi.children[0]) + 1
    return 0


def entanglement_depth(phi: GLFormula) -> int:
    """Compute the entanglement depth (count of nested □φ→φ patterns)."""
    if phi.kind == 'var' or phi.kind == 'bot':
        return 0
    elif phi.kind == 'box':
        return entanglement_depth(phi.children[0])
    elif phi.kind == 'imp':
        lhs, rhs = phi.children
        if lhs.kind == 'box' and lhs.children[0] == rhs:
            return entanglement_depth(rhs) + 1
        else:
            return max(entanglement_depth(lhs), entanglement_depth(rhs))
    return 0


def soundness_op(phi: GLFormula) -> GLFormula:
    """The soundness operator: □φ → φ."""
    return GLFormula.imp(GLFormula.box(phi), phi)


def iterated_soundness(n: int, phi: GLFormula) -> GLFormula:
    """Apply the soundness operator n times."""
    result = phi
    for _ in range(n):
        result = soundness_op(result)
    return result


def con_formula(n: int) -> GLFormula:
    """The n-th consistency formula: Con_0=⊤, Con_{n+1}=¬□¬Con_n."""
    if n == 0:
        return GLFormula.neg(GLFormula.bot())
    return GLFormula.neg(GLFormula.box(GLFormula.neg(con_formula(n - 1))))


def tangling_level(n: int, w: int) -> int:
    """Tangling level of world w in a linear chain of n worlds."""
    return n - 1 - w


def con_forces_linear_chain(n: int, w: int, k: int) -> bool:
    """Check if Con_k is forced at world w in a linear chain of n worlds.

    Implements the Consistency Stratification Theorem:
    Con_k forced at w ⟺ w + k < n
    """
    return w + k < n


@dataclass
class GLFrame:
    """A GL-frame (finite, transitive, irreflexive)."""
    num_worlds: int
    relation: List[List[bool]]  # adjacency matrix

    def is_accessible(self, w1: int, w2: int) -> bool:
        return self.relation[w1][w2]


def linear_chain_frame(n: int) -> GLFrame:
    """Create a linear chain frame with n worlds."""
    rel = [[i < j for j in range(n)] for i in range(n)]
    return GLFrame(n, rel)


def forces_in_frame(frame: GLFrame, valuation: Dict[int, Set[int]],
                    w: int, phi: GLFormula) -> bool:
    """Check if formula phi is forced at world w in frame under valuation."""
    if phi.kind == 'var':
        return w in valuation.get(phi.children[0], set())
    elif phi.kind == 'bot':
        return False
    elif phi.kind == 'imp':
        if forces_in_frame(frame, valuation, w, phi.children[0]):
            return forces_in_frame(frame, valuation, w, phi.children[1])
        return True
    elif phi.kind == 'box':
        for wp in range(frame.num_worlds):
            if frame.is_accessible(w, wp):
                if not forces_in_frame(frame, valuation, wp, phi.children[0]):
                    return False
        return True
    return False


def compute_tangling_spectrum(frame: GLFrame, max_k: int = 20) -> Dict[int, int]:
    """Compute the tangling spectrum: for each world, find its tangling level.

    Returns dict mapping world -> max k such that Con_k is forced.
    """
    spectrum: Dict[int, int] = {}
    valuation: Dict[int, Set[int]] = {}  # empty valuation (Con_k has no vars)

    for w in range(frame.num_worlds):
        max_level = -1
        for k in range(max_k):
            if forces_in_frame(frame, valuation, w, con_formula(k)):
                max_level = k
            else:
                break
        spectrum[w] = max_level
    return spectrum


def verify_stratification(n: int) -> bool:
    """Verify the Consistency Stratification Theorem for a chain of n worlds.

    Checks: Con_k forced at w ⟺ w + k < n, for all w, k.
    """
    frame = linear_chain_frame(n)
    valuation: Dict[int, Set[int]] = {}

    for w in range(n):
        for k in range(n + 2):
            expected = (w + k < n)
            actual = forces_in_frame(frame, valuation, w, con_formula(k))
            if actual != expected:
                return False
    return True


def verify_optimal_tangling(n: int) -> Tuple[bool, int]:
    """Verify the Optimal Frame Tangling Conjecture for frames with n worlds.

    Enumerates all transitive irreflexive relations on {0,...,n-1} and
    checks that no frame has more than n distinct tangling levels.

    Returns (all_pass, max_levels_found).
    """
    from itertools import product

    max_levels = 0

    # Enumerate all possible relations
    pairs = [(i, j) for i in range(n) for j in range(n) if i != j]

    for bits in product([False, True], repeat=len(pairs)):
        rel = [[False] * n for _ in range(n)]
        for (i, j), b in zip(pairs, bits):
            rel[i][j] = b

        # Check irreflexivity
        if any(rel[i][i] for i in range(n)):
            continue

        # Check transitivity
        ok = True
        for i in range(n):
            for j in range(n):
                for k_idx in range(n):
                    if rel[i][j] and rel[j][k_idx] and not rel[i][k_idx]:
                        ok = False
                        break
                if not ok:
                    break
            if not ok:
                break
        if not ok:
            continue

        frame = GLFrame(n, rel)
        spectrum = compute_tangling_spectrum(frame, max_k=n + 2)
        levels = set(spectrum.values())
        max_levels = max(max_levels, len(levels))

    return (max_levels <= n, max_levels)
