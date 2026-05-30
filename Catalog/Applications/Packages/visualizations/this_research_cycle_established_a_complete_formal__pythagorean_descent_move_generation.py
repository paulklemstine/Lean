"""
Algorithms for Transfinite Game Values and Pythagorean Descent

Implements the core algorithms from the research paper with full
documentation, type hints, and complexity analysis.
"""

import math
from typing import Optional, Dict, List, Set, Tuple
from dataclasses import dataclass, field


# =============================================================================
# Algorithm 1: Game Tree with Rank Computation
# =============================================================================

@dataclass
class GameTree:
    """A finite well-founded game tree.
    
    Matches the Lean formalization:
    - leaf: terminal position (no children)
    - node: position with available moves (children)
    
    The game rank measures ordinal-like complexity:
        rank(leaf) = 0
        rank(node(children)) = max(rank(c) + 1 for c in children)
    
    Time complexity for rank: O(|T|) where |T| is tree size
    Space complexity: O(h) where h is height (recursion depth)
    """
    children: List['GameTree'] = field(default_factory=list)
    
    @property
    def is_leaf(self) -> bool:
        return len(self.children) == 0
    
    def game_rank(self) -> int:
        """Compute game-theoretic rank.
        
        Algorithm: ComputeGameRank
        Time: O(|T|) — visits each node exactly once
        Space: O(h) — recursion stack depth equals tree height
        """
        if self.is_leaf:
            return 0
        return max(c.game_rank() + 1 for c in self.children)
    
    def is_winning(self) -> bool:
        """Determine if current player wins under optimal play.
        
        Algorithm: ClassifyWinning
        Time: O(|T|) — visits each node once
        Space: O(h) — recursion depth
        
        A position is:
        - Losing if it's a leaf (no moves available)
        - Winning if any child is a losing position
        - Losing if all children are winning positions
        """
        if self.is_leaf:
            return False
        return any(not c.is_winning() for c in self.children)
    
    def height(self) -> int:
        """Compute tree height (longest root-to-leaf path).
        Time: O(|T|), Space: O(h)
        """
        if self.is_leaf:
            return 0
        return 1 + max(c.height() for c in self.children)
    
    def size(self) -> int:
        """Compute total number of nodes.
        Time: O(|T|), Space: O(h)
        """
        if self.is_leaf:
            return 1
        return 1 + sum(c.size() for c in self.children)
    
    @staticmethod
    def leaf() -> 'GameTree':
        """Create a leaf (terminal position)."""
        return GameTree()
    
    @staticmethod
    def of_rank(n: int) -> 'GameTree':
        """Construct a chain tree with exactly rank n.
        
        of_rank(0) = leaf
        of_rank(n+1) = node([of_rank(n)])
        
        Satisfies: of_rank(n).game_rank() == n for all n ≥ 0
        Time: O(n), Space: O(n)
        """
        if n == 0:
            return GameTree.leaf()
        return GameTree([GameTree.of_rank(n - 1)])
    
    @staticmethod
    def wide_tree(n: int) -> 'GameTree':
        """Create tree with n leaf children. Rank = 1 for n ≥ 1.
        Time: O(n), Space: O(n)
        """
        return GameTree([GameTree.leaf() for _ in range(n)])


# =============================================================================
# Algorithm 2: Pythagorean Descent Move Generation
# =============================================================================

def pythagorean_moves(n: int) -> List[int]:
    """Generate all valid Pythagorean descent moves from position n.
    
    Algorithm: PythagoreanMoves
    A move from n to m is valid if m < n and there exists k > 0
    such that m² + k² = n².
    
    Time: O(n) — iterates over all m < n
    Space: O(√n) — expected number of moves (heuristic)
    
    Args:
        n: Current position (positive integer)
    
    Returns:
        Sorted list of valid descent targets
    
    Examples:
        >>> pythagorean_moves(5)
        [3, 4]
        >>> pythagorean_moves(13)
        [5, 12]
        >>> pythagorean_moves(25)
        [7, 15, 20, 24]
    """
    moves = []
    n_sq = n * n
    for m in range(1, n):
        k_sq = n_sq - m * m
        if k_sq > 0:
            k = int(math.isqrt(k_sq))
            if k * k == k_sq:
                moves.append(m)
    return moves


def is_pythagorean_hypotenuse(n: int) -> bool:
    """Check if n appears as hypotenuse of a Pythagorean triple.
    Time: O(n)
    """
    return len(pythagorean_moves(n)) > 0


# =============================================================================
# Algorithm 3: Pythagorean Game Value Computation (with memoization)
# =============================================================================

class PythagoreanGame:
    """The Pythagorean Descent Game with memoized game analysis.
    
    From position n, a player can move to any m where m is a leg
    of a Pythagorean triple with hypotenuse n. The game is
    well-founded because each move strictly decreases the position.
    
    The game value (rank) of position n is:
        0 if no moves exist (terminal/losing position)
        max(game_value(m) + 1 for m in moves(n)) otherwise
    """
    
    def __init__(self):
        self._rank_memo: Dict[int, int] = {}
        self._winning_memo: Dict[int, bool] = {}
        self._moves_memo: Dict[int, List[int]] = {}
    
    def moves(self, n: int) -> List[int]:
        """Get cached moves from position n."""
        if n not in self._moves_memo:
            self._moves_memo[n] = pythagorean_moves(n)
        return self._moves_memo[n]
    
    def game_rank(self, n: int) -> int:
        """Compute game-theoretic rank of position n.
        
        Algorithm: ComputePythGameRank
        Time: O(n² log n) amortized for all positions up to n
        Space: O(n) for memoization
        """
        if n in self._rank_memo:
            return self._rank_memo[n]
        
        m_list = self.moves(n)
        if not m_list:
            self._rank_memo[n] = 0
            return 0
        
        rank = max(self.game_rank(m) + 1 for m in m_list)
        self._rank_memo[n] = rank
        return rank
    
    def is_winning(self, n: int) -> bool:
        """Classify position n as winning or losing.
        
        Algorithm: ClassifyPythPosition
        Time: O(n²) amortized for all positions up to n
        Space: O(n) for memoization
        """
        if n in self._winning_memo:
            return self._winning_memo[n]
        
        m_list = self.moves(n)
        if not m_list:
            self._winning_memo[n] = False
            return False
        
        result = any(not self.is_winning(m) for m in m_list)
        self._winning_memo[n] = result
        return result
    
    def game_tree(self, n: int, max_depth: int = 10) -> GameTree:
        """Build the explicit game tree for position n.
        
        Args:
            n: Starting position
            max_depth: Maximum recursion depth (prevents huge trees)
        
        Returns:
            GameTree representing all plays from position n
        """
        if max_depth <= 0:
            return GameTree.leaf()
        
        m_list = self.moves(n)
        if not m_list:
            return GameTree.leaf()
        
        children = [self.game_tree(m, max_depth - 1) for m in m_list]
        return GameTree(children)


# =============================================================================
# Algorithm 4: Tropical Game Value Algebra
# =============================================================================

@dataclass
class TropicalGameValue:
    """Tropical (min-plus) game value.
    
    Algebraic structure:
    - tropAdd(a, b) = min(a, b)     [tropical addition]
    - tropMul(a, b) = a + b         [tropical multiplication]  
    - tropOne = (0, 0)              [multiplicative identity]
    
    Satisfies:
    - Commutativity: a ⊙ b = b ⊙ a
    - Associativity: (a ⊙ b) ⊙ c = a ⊙ (b ⊙ c)
    - Identity: a ⊙ 1 = a
    - Idempotence: a ⊕ a = a
    - Distributivity: (a ⊕ b) ⊙ c = (a ⊙ c) ⊕ (b ⊙ c)
      (when a.val ≤ b.val)
    """
    val: int
    depth: int
    
    def trop_add(self, other: 'TropicalGameValue') -> 'TropicalGameValue':
        """Tropical addition: minimum."""
        if self.val <= other.val:
            return self
        return other
    
    def trop_mul(self, other: 'TropicalGameValue') -> 'TropicalGameValue':
        """Tropical multiplication: ordinary addition."""
        return TropicalGameValue(
            self.val + other.val,
            self.depth + other.depth
        )
    
    @staticmethod
    def trop_one() -> 'TropicalGameValue':
        """Multiplicative identity."""
        return TropicalGameValue(0, 0)
    
    def __eq__(self, other):
        if not isinstance(other, TropicalGameValue):
            return False
        return self.val == other.val and self.depth == other.depth


# =============================================================================
# Algorithm 5: Pythagorean Hypotenuse Counter
# =============================================================================

def count_pythagorean_hypotenuses(N: int) -> int:
    """Count integers n ≤ N that are Pythagorean hypotenuses.
    
    Conjectured asymptotic: Θ(N / √(log N))
    (Landau-Ramanujan theorem for sums of two squares)
    
    Time: O(N²)
    Space: O(1)
    """
    count = 0
    for n in range(1, N + 1):
        if is_pythagorean_hypotenuse(n):
            count += 1
    return count


def list_pythagorean_hypotenuses(N: int) -> List[int]:
    """List all Pythagorean hypotenuses up to N."""
    return [n for n in range(1, N + 1) if is_pythagorean_hypotenuse(n)]


# =============================================================================
# Example usage
# =============================================================================

if __name__ == "__main__":
    # Game tree examples
    print("=== Game Tree Examples ===")
    t = GameTree.of_rank(5)
    print(f"Chain of rank 5: rank={t.game_rank()}, winning={t.is_winning()}")
    
    t2 = GameTree.wide_tree(3)
    print(f"Wide tree (3 leaves): rank={t2.game_rank()}, winning={t2.is_winning()}")
    
    # Pythagorean game
    print("\n=== Pythagorean Game ===")
    game = PythagoreanGame()
    for n in [5, 10, 13, 25, 50]:
        moves = game.moves(n)
        if moves:
            print(f"Position {n}: moves={moves}, "
                  f"rank={game.game_rank(n)}, "
                  f"winning={game.is_winning(n)}")
    
    # Tropical algebra
    print("\n=== Tropical Algebra ===")
    a = TropicalGameValue(3, 1)
    b = TropicalGameValue(5, 2)
    print(f"a={a}, b={b}")
    print(f"a⊕b = {a.trop_add(b)}")
    print(f"a⊙b = {a.trop_mul(b)}")
    
    # Hypotenuse counting
    print("\n=== Hypotenuse Density ===")
    for N in [50, 100, 200, 500]:
        c = count_pythagorean_hypotenuses(N)
        ratio = c / (N / math.sqrt(math.log(N))) if N > 1 else 0
        print(f"N={N}: count={c}, predicted≈{N/math.sqrt(math.log(N)):.1f}, ratio={ratio:.3f}")
