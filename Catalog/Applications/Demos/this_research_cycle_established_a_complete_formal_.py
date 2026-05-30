"""
Applications of Transfinite Game Values and Pythagorean Descent

Real-world applications demonstrating the mathematical results:
1. Game complexity classification for AI move ordering
2. Pythagorean network analysis
3. Tropical optimization for game scheduling
"""

import math
from typing import List, Dict, Tuple, Set


# =============================================================================
# Application 1: Game Complexity Classification for AI
# =============================================================================

class GameComplexityClassifier:
    """Classify game positions by complexity class for AI move ordering.
    
    In game-playing AI, positions of higher complexity require deeper
    search. By computing the game rank, we can allocate search budget
    proportional to complexity: simple positions get shallow search,
    complex positions get deep search.
    
    This is the practical application of the complexity hierarchy:
        GameComplexityClass(k) = { t : GameTree | t.gameRank ≤ k }
    """
    
    def __init__(self):
        self.classifications: Dict[str, int] = {}
    
    def classify_position(self, position_id: str, 
                          num_moves: int, 
                          move_complexities: List[int]) -> int:
        """Classify a game position by its approximate rank.
        
        Args:
            position_id: Unique identifier for the position
            num_moves: Number of available moves
            move_complexities: Estimated complexity of each successor
        
        Returns:
            Complexity class (0 = terminal, higher = more complex)
        """
        if num_moves == 0:
            rank = 0  # Terminal position
        else:
            rank = max(c + 1 for c in move_complexities)
        
        self.classifications[position_id] = rank
        return rank
    
    def recommended_search_depth(self, rank: int, 
                                  base_depth: int = 3) -> int:
        """Recommend search depth based on complexity class.
        
        Higher complexity → deeper search (more budget allocated)
        """
        return base_depth + min(rank, 10)  # Cap at 13 total
    
    def report(self):
        """Print classification report."""
        print("\nGame Complexity Classification Report")
        print("=" * 50)
        for pos_id, rank in sorted(self.classifications.items(), 
                                    key=lambda x: x[1]):
            depth = self.recommended_search_depth(rank)
            print(f"  Position {pos_id}: class={rank}, "
                  f"recommended_depth={depth}")


# =============================================================================
# Application 2: Pythagorean Network Analysis
# =============================================================================

class PythagoreanNetwork:
    """Analyze the network structure of Pythagorean descent.
    
    Nodes are positive integers, edges connect n to m when
    m is a Pythagorean descent of n. This network reveals
    the connectivity structure of Pythagorean triples.
    """
    
    def __init__(self, max_n: int = 100):
        self.max_n = max_n
        self.edges: List[Tuple[int, int]] = []
        self.adjacency: Dict[int, List[int]] = {}
        self._build_network()
    
    def _build_network(self):
        """Build the Pythagorean descent network."""
        for n in range(2, self.max_n + 1):
            n_sq = n * n
            neighbors = []
            for m in range(1, n):
                k_sq = n_sq - m * m
                if k_sq > 0:
                    k = int(math.isqrt(k_sq))
                    if k * k == k_sq:
                        self.edges.append((n, m))
                        neighbors.append(m)
            if neighbors:
                self.adjacency[n] = neighbors
    
    def hub_nodes(self, min_degree: int = 3) -> List[Tuple[int, int]]:
        """Find high-degree nodes (numbers appearing in many triples).
        
        These are the "hubs" of the Pythagorean network — numbers
        that participate in many Pythagorean relationships.
        """
        degrees = {}
        for n, m in self.edges:
            degrees[n] = degrees.get(n, 0) + 1
            degrees[m] = degrees.get(m, 0) + 1
        
        hubs = [(node, deg) for node, deg in degrees.items() 
                if deg >= min_degree]
        return sorted(hubs, key=lambda x: -x[1])
    
    def connected_components(self) -> List[Set[int]]:
        """Find connected components of the descent network.
        
        Uses union-find to identify clusters of Pythagorean-related numbers.
        """
        parent = {}
        
        def find(x):
            if x not in parent:
                parent[x] = x
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        
        def union(x, y):
            px, py = find(x), find(y)
            if px != py:
                parent[px] = py
        
        for n, m in self.edges:
            union(n, m)
        
        components: Dict[int, Set[int]] = {}
        all_nodes = set()
        for n, m in self.edges:
            all_nodes.add(n)
            all_nodes.add(m)
        
        for node in all_nodes:
            root = find(node)
            if root not in components:
                components[root] = set()
            components[root].add(node)
        
        return sorted(components.values(), key=lambda s: -len(s))
    
    def descent_depth(self, n: int, memo: Dict[int, int] = None) -> int:
        """Maximum descent depth from n (game-theoretic rank)."""
        if memo is None:
            memo = {}
        if n in memo:
            return memo[n]
        
        neighbors = self.adjacency.get(n, [])
        if not neighbors:
            memo[n] = 0
            return 0
        
        depth = max(self.descent_depth(m, memo) + 1 for m in neighbors)
        memo[n] = depth
        return depth
    
    def report(self):
        """Print network analysis report."""
        print("\nPythagorean Descent Network Analysis")
        print("=" * 50)
        print(f"  Nodes with edges: {len(self.adjacency)}")
        print(f"  Total edges: {len(self.edges)}")
        
        hubs = self.hub_nodes(min_degree=4)
        print(f"\n  Hub nodes (degree ≥ 4):")
        for node, deg in hubs[:10]:
            print(f"    n={node}: degree={deg}")
        
        components = self.connected_components()
        print(f"\n  Connected components: {len(components)}")
        if components:
            print(f"    Largest component: {len(components[0])} nodes")
            if len(components[0]) <= 20:
                print(f"    Members: {sorted(components[0])}")
        
        print(f"\n  Descent depths:")
        memo = {}
        max_depths = []
        for n in range(2, self.max_n + 1):
            if n in self.adjacency:
                d = self.descent_depth(n, memo)
                max_depths.append((n, d))
        
        max_depths.sort(key=lambda x: -x[1])
        for n, d in max_depths[:10]:
            print(f"    n={n}: max_descent_depth={d}")


# =============================================================================
# Application 3: Tropical Game Scheduling
# =============================================================================

class TropicalScheduler:
    """Tropical optimization for game tournament scheduling.
    
    Uses the tropical semiring to optimize tournament structure:
    - tropMul (addition) = sequential composition of games
    - tropAdd (minimum) = parallel selection of games
    
    The tropical framework minimizes total tournament duration
    while respecting precedence constraints.
    """
    
    def __init__(self):
        self.games: Dict[str, int] = {}  # game -> duration
        self.precedence: List[Tuple[str, str]] = []  # (before, after)
    
    def add_game(self, name: str, duration: int):
        """Add a game with estimated duration."""
        self.games[name] = duration
    
    def add_precedence(self, before: str, after: str):
        """Specify that game `before` must complete before `after` starts."""
        self.precedence.append((before, after))
    
    def critical_path(self) -> Tuple[List[str], int]:
        """Find the critical path (longest sequential chain).
        
        In tropical algebra, this is the tropical "product" of
        durations along the longest path — computed via the
        tropical semiring where multiplication = addition.
        
        Time: O(V + E) using topological sort
        """
        # Build adjacency list
        successors: Dict[str, List[str]] = {g: [] for g in self.games}
        predecessors: Dict[str, List[str]] = {g: [] for g in self.games}
        for b, a in self.precedence:
            successors[b].append(a)
            predecessors[a].append(b)
        
        # Topological sort + longest path (tropical product)
        in_degree = {g: len(predecessors[g]) for g in self.games}
        dist = {g: 0 for g in self.games}
        prev = {g: None for g in self.games}
        
        # Initialize with games that have no predecessors
        queue = [g for g, d in in_degree.items() if d == 0]
        for g in queue:
            dist[g] = self.games[g]
        
        order = []
        while queue:
            g = queue.pop(0)
            order.append(g)
            for s in successors[g]:
                # Tropical multiplication: add durations
                new_dist = dist[g] + self.games[s]
                if new_dist > dist[s]:
                    dist[s] = new_dist
                    prev[s] = g
                in_degree[s] -= 1
                if in_degree[s] == 0:
                    queue.append(s)
        
        # Reconstruct critical path
        end_game = max(dist, key=dist.get)
        path = []
        current = end_game
        while current is not None:
            path.append(current)
            current = prev[current]
        path.reverse()
        
        return path, dist[end_game]
    
    def min_parallel_duration(self, group: List[str]) -> int:
        """Minimum duration when games can be played in parallel.
        
        In tropical algebra: tropical addition = minimum.
        The optimal parallel schedule picks the shortest game.
        """
        if not group:
            return 0
        return min(self.games[g] for g in group if g in self.games)
    
    def report(self):
        """Print scheduling analysis."""
        print("\nTropical Game Scheduling Analysis")
        print("=" * 50)
        print(f"  Games: {len(self.games)}")
        print(f"  Precedence constraints: {len(self.precedence)}")
        
        path, duration = self.critical_path()
        print(f"\n  Critical path (tropical product):")
        print(f"    Path: {' → '.join(path)}")
        print(f"    Total duration: {duration}")
        
        all_games = list(self.games.keys())
        min_dur = self.min_parallel_duration(all_games)
        print(f"\n  Minimum parallel duration (tropical sum):")
        print(f"    Shortest game: {min_dur}")


# =============================================================================
# Run Applications
# =============================================================================

if __name__ == "__main__":
    # Application 1: Game Complexity Classification
    print("APPLICATION 1: Game Complexity Classification")
    print("=" * 60)
    classifier = GameComplexityClassifier()
    
    # Simulate classifying chess-like positions
    classifier.classify_position("endgame_KvK", 0, [])
    classifier.classify_position("endgame_KRvK", 3, [0, 0, 1])
    classifier.classify_position("middlegame_1", 5, [2, 1, 3, 2, 1])
    classifier.classify_position("opening_1", 8, [3, 4, 3, 2, 5, 3, 4, 2])
    classifier.classify_position("complex_tactic", 3, [5, 6, 4])
    classifier.report()
    
    # Application 2: Pythagorean Network
    print("\n\nAPPLICATION 2: Pythagorean Network")
    print("=" * 60)
    network = PythagoreanNetwork(max_n=100)
    network.report()
    
    # Application 3: Tropical Scheduling
    print("\n\nAPPLICATION 3: Tropical Game Scheduling")
    print("=" * 60)
    scheduler = TropicalScheduler()
    
    # Tournament with precedence constraints
    scheduler.add_game("Quarterfinal_1", 3)
    scheduler.add_game("Quarterfinal_2", 4)
    scheduler.add_game("Quarterfinal_3", 2)
    scheduler.add_game("Quarterfinal_4", 5)
    scheduler.add_game("Semifinal_1", 4)
    scheduler.add_game("Semifinal_2", 3)
    scheduler.add_game("Final", 6)
    
    scheduler.add_precedence("Quarterfinal_1", "Semifinal_1")
    scheduler.add_precedence("Quarterfinal_2", "Semifinal_1")
    scheduler.add_precedence("Quarterfinal_3", "Semifinal_2")
    scheduler.add_precedence("Quarterfinal_4", "Semifinal_2")
    scheduler.add_precedence("Semifinal_1", "Final")
    scheduler.add_precedence("Semifinal_2", "Final")
    
    scheduler.report()
    
    print("\n\nAll applications completed successfully!")


"""
Demo: Transfinite Game Values and Pythagorean Descent

Demonstrates the key mathematical concepts from the formalized theory:
1. Game tree construction and rank computation
2. Pythagorean descent game moves and winning analysis
3. Tropical game value algebra
4. Pythagorean hypotenuse counting and density analysis
"""

import math
from typing import Optional


# =============================================================================
# Part 1: Game Trees
# =============================================================================

class GameTree:
    """A finite well-founded game tree (matching the Lean formalization)."""
    
    def __init__(self, children: Optional[list] = None):
        """Create a game tree. None/empty = leaf (terminal position)."""
        self.children = children if children else []
        self.is_leaf = len(self.children) == 0
    
    def game_rank(self) -> int:
        """Compute the game-theoretic rank (ordinal-like complexity measure)."""
        if self.is_leaf:
            return 0
        return max(c.game_rank() + 1 for c in self.children)
    
    def is_winning(self) -> bool:
        """Is this a winning position for the current player?"""
        if self.is_leaf:
            return False  # No moves = losing
        return any(not c.is_winning() for c in self.children)
    
    def height(self) -> int:
        """Height (longest path to leaf)."""
        if self.is_leaf:
            return 0
        return 1 + max(c.height() for c in self.children)
    
    def size(self) -> int:
        """Total number of nodes."""
        if self.is_leaf:
            return 1
        return 1 + sum(c.size() for c in self.children)
    
    @staticmethod
    def leaf():
        return GameTree()
    
    @staticmethod
    def of_rank(n: int):
        """Construct a chain game tree with exactly rank n."""
        if n == 0:
            return GameTree.leaf()
        return GameTree([GameTree.of_rank(n - 1)])
    
    @staticmethod
    def wide_tree(n: int):
        """Construct a tree with n leaf children."""
        return GameTree([GameTree.leaf() for _ in range(n)])
    
    def __repr__(self):
        if self.is_leaf:
            return "●"
        return f"({', '.join(repr(c) for c in self.children)})"


print("=" * 60)
print("DEMO 1: Game Tree Rank and Winning Status")
print("=" * 60)

for n in range(8):
    t = GameTree.of_rank(n)
    print(f"  ofRank({n}): rank={t.game_rank()}, "
          f"height={t.height()}, size={t.size()}, "
          f"winning={t.is_winning()}, "
          f"parity={'odd' if n % 2 == 1 else 'even'}")

print("\nVerifying chain parity theorem:")
for n in range(20):
    t = GameTree.of_rank(n)
    assert t.is_winning() == (n % 2 == 1), f"Parity failed at n={n}"
print("  ✓ Chain parity verified for n = 0..19")

print("\nWide trees (all leaves as children):")
for n in range(1, 6):
    t = GameTree.wide_tree(n)
    print(f"  wideTree({n}): rank={t.game_rank()}, winning={t.is_winning()}")

# =============================================================================
# Part 2: Pythagorean Descent Game
# =============================================================================

def pythagorean_moves(n: int) -> list:
    """Find all valid Pythagorean descent moves from n."""
    moves = []
    for m in range(1, n):
        k_sq = n * n - m * m
        if k_sq > 0:
            k = int(math.isqrt(k_sq))
            if k * k == k_sq:
                moves.append(m)
    return moves


def is_pyth_hypotenuse(n: int) -> bool:
    """Check if n is a hypotenuse of some Pythagorean triple."""
    return len(pythagorean_moves(n)) > 0


print("\n" + "=" * 60)
print("DEMO 2: Pythagorean Descent Game")
print("=" * 60)

print("\nPythagorean descent moves:")
for n in range(2, 51):
    moves = pythagorean_moves(n)
    if moves:
        print(f"  From {n:3d}: can descend to {moves}")

print("\nVerifying formal results:")
print(f"  3 descends from 5: {3 in pythagorean_moves(5)}")  # True
print(f"  4 descends from 5: {4 in pythagorean_moves(5)}")  # True
print(f"  Moves from 0: {pythagorean_moves(0)}")  # []
print(f"  Moves from 1: {pythagorean_moves(1)}")  # []


# Compute game-theoretic values for Pythagorean descent
def pyth_game_value(n: int, memo: dict = None) -> int:
    """Compute game value (rank) of position n in Pythagorean descent."""
    if memo is None:
        memo = {}
    if n in memo:
        return memo[n]
    moves = pythagorean_moves(n)
    if not moves:
        memo[n] = 0
        return 0
    val = max(pyth_game_value(m, memo) + 1 for m in moves)
    memo[n] = val
    return val


def pyth_is_winning(n: int, memo: dict = None) -> bool:
    """Is position n winning in the Pythagorean descent game?"""
    if memo is None:
        memo = {}
    if n in memo:
        return memo[n]
    moves = pythagorean_moves(n)
    if not moves:
        memo[n] = False
        return False
    result = any(not pyth_is_winning(m, memo) for m in moves)
    memo[n] = result
    return result


print("\nPythagorean game values and winning status:")
memo_val = {}
memo_win = {}
for n in range(2, 51):
    if is_pyth_hypotenuse(n):
        val = pyth_game_value(n, memo_val)
        win = pyth_is_winning(n, memo_win)
        print(f"  n={n:3d}: game_value={val}, winning={win}")

# =============================================================================
# Part 3: Tropical Game Algebra
# =============================================================================

class TropicalGameValue:
    """Tropical game value (val, depth) with min-plus algebra."""
    
    def __init__(self, val: int, depth: int):
        self.val = val
        self.depth = depth
    
    def trop_add(self, other):
        """Tropical addition = minimum."""
        if self.val <= other.val:
            return self
        return other
    
    def trop_mul(self, other):
        """Tropical multiplication = ordinary addition."""
        return TropicalGameValue(
            self.val + other.val,
            self.depth + other.depth
        )
    
    @staticmethod
    def trop_one():
        return TropicalGameValue(0, 0)
    
    def __repr__(self):
        return f"T({self.val},{self.depth})"
    
    def __eq__(self, other):
        return self.val == other.val and self.depth == other.depth


print("\n" + "=" * 60)
print("DEMO 3: Tropical Game Algebra")
print("=" * 60)

a = TropicalGameValue(3, 1)
b = TropicalGameValue(5, 2)
c = TropicalGameValue(2, 3)

print(f"\n  a = {a}, b = {b}, c = {c}")
print(f"  a ⊕ b = min(a,b) = {a.trop_add(b)}")
print(f"  a ⊙ b = a+b = {a.trop_mul(b)}")
print(f"  a ⊙ 1 = {a.trop_mul(TropicalGameValue.trop_one())}")
print(f"  a ⊕ a = {a.trop_add(a)} (idempotent)")

print("\nVerifying tropical semiring laws:")
# Commutativity
assert a.trop_mul(b) == b.trop_mul(a), "Commutativity failed"
print("  ✓ Commutativity: a⊙b = b⊙a")

# Associativity
assert a.trop_mul(b).trop_mul(c) == a.trop_mul(b.trop_mul(c)), \
    "Associativity failed"
print("  ✓ Associativity: (a⊙b)⊙c = a⊙(b⊙c)")

# Identity
assert a.trop_mul(TropicalGameValue.trop_one()) == a, "Identity failed"
print("  ✓ Identity: a⊙1 = a")

# Idempotence
assert a.trop_add(a) == a, "Idempotence failed"
print("  ✓ Idempotence: a⊕a = a")

# Val additivity
assert a.trop_mul(b).val == a.val + b.val, "Additivity failed"
print("  ✓ Val additivity: (a⊙b).val = a.val + b.val")

# Distributivity (when a.val ≤ b.val)
lhs = a.trop_add(b).trop_mul(c)
rhs = a.trop_mul(c).trop_add(b.trop_mul(c))
assert lhs == rhs, "Distributivity failed"
print("  ✓ Distributivity: (a⊕b)⊙c = (a⊙c)⊕(b⊙c) (when a.val ≤ b.val)")

# =============================================================================
# Part 4: Pythagorean Hypotenuse Density
# =============================================================================

print("\n" + "=" * 60)
print("DEMO 4: Pythagorean Hypotenuse Density")
print("=" * 60)

def count_hypotenuses(N: int) -> int:
    """Count Pythagorean hypotenuses up to N."""
    return sum(1 for n in range(1, N + 1) if is_pyth_hypotenuse(n))


print("\nPythagorean hypotenuse counts:")
for N in [10, 20, 50, 100, 200, 500]:
    count = count_hypotenuses(N)
    if N > 1:
        ratio = count / (N / math.sqrt(math.log(N)))
        print(f"  N={N:4d}: count={count:4d}, "
              f"N/√(log N) = {N/math.sqrt(math.log(N)):7.2f}, "
              f"ratio = {ratio:.4f}")
    else:
        print(f"  N={N:4d}: count={count:4d}")

hyps = [n for n in range(1, 101) if is_pyth_hypotenuse(n)]
print(f"\nPythagorean hypotenuses up to 100: {hyps}")
print(f"Count: {len(hyps)}")

print("\n5 is a hypotenuse:", is_pyth_hypotenuse(5))
print("Verified: 5 ∈ pythHypotenuses 5 ✓")

print("\n" + "=" * 60)
print("All demos completed successfully!")
print("=" * 60)


"""
Visualization: Game Tree Rank Hierarchy

Visualizes the game-theoretic rank structure of game trees,
showing how rank increases with tree depth and branching.
Demonstrates the chain parity theorem (winning/losing alternation)
and the rank-height bound.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

# ---- Inline game tree implementation (self-contained) ----

class GameTree:
    def __init__(self, children=None):
        self.children = children if children else []
        self.is_leaf = len(self.children) == 0
    
    def game_rank(self):
        if self.is_leaf:
            return 0
        return max(c.game_rank() + 1 for c in self.children)
    
    def is_winning(self):
        if self.is_leaf:
            return False
        return any(not c.is_winning() for c in self.children)
    
    def height(self):
        if self.is_leaf:
            return 0
        return 1 + max(c.height() for c in self.children)
    
    @staticmethod
    def leaf():
        return GameTree()
    
    @staticmethod
    def of_rank(n):
        if n == 0:
            return GameTree.leaf()
        return GameTree([GameTree.of_rank(n - 1)])
    
    @staticmethod
    def wide_tree(n):
        return GameTree([GameTree.leaf() for _ in range(n)])

# ---- Build data ----

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Game Tree Rank Hierarchy and Pythagorean Descent', 
             fontsize=16, fontweight='bold')

# Plot 1: Chain parity theorem
ax1 = axes[0, 0]
ns = list(range(20))
ranks = [GameTree.of_rank(n).game_rank() for n in ns]
winning = [GameTree.of_rank(n).is_winning() for n in ns]
colors = ['#2ecc71' if w else '#e74c3c' for w in winning]

ax1.bar(ns, ranks, color=colors, edgecolor='black', linewidth=0.5)
ax1.set_xlabel('Chain Depth n', fontsize=11)
ax1.set_ylabel('Game Rank', fontsize=11)
ax1.set_title('Chain Parity: Rank = n, Win iff n is Odd', fontsize=12)

win_patch = mpatches.Patch(color='#2ecc71', label='Winning (odd)')
lose_patch = mpatches.Patch(color='#e74c3c', label='Losing (even)')
ax1.legend(handles=[win_patch, lose_patch], loc='upper left')

# Plot 2: Rank vs Height bound
ax2 = axes[0, 1]

# Generate various trees and compare rank vs height
tree_data = []
for n in range(1, 8):
    # Chain trees
    t = GameTree.of_rank(n)
    tree_data.append((t.height(), t.game_rank(), 'Chain'))
    
    # Wide trees
    t = GameTree.wide_tree(n)
    tree_data.append((t.height(), t.game_rank(), 'Wide'))
    
    # Mixed trees
    if n >= 2:
        t = GameTree([GameTree.of_rank(n-1), GameTree.leaf()])
        tree_data.append((t.height(), t.game_rank(), 'Mixed'))

heights_chain = [d[0] for d in tree_data if d[2] == 'Chain']
ranks_chain = [d[1] for d in tree_data if d[2] == 'Chain']
heights_wide = [d[0] for d in tree_data if d[2] == 'Wide']
ranks_wide = [d[1] for d in tree_data if d[2] == 'Wide']
heights_mixed = [d[0] for d in tree_data if d[2] == 'Mixed']
ranks_mixed = [d[1] for d in tree_data if d[2] == 'Mixed']

ax2.scatter(heights_chain, ranks_chain, c='#3498db', s=80, label='Chain', zorder=3)
ax2.scatter(heights_wide, ranks_wide, c='#e67e22', s=80, label='Wide', zorder=3)
ax2.scatter(heights_mixed, ranks_mixed, c='#9b59b6', s=80, label='Mixed', zorder=3)

max_h = max(d[0] for d in tree_data)
ax2.plot([0, max_h+1], [0, max_h+1], 'k--', alpha=0.5, label='rank = height')
ax2.set_xlabel('Height', fontsize=11)
ax2.set_ylabel('Game Rank', fontsize=11)
ax2.set_title('Rank ≤ Height (Verified Bound)', fontsize=12)
ax2.legend(fontsize=9)

# Plot 3: Pythagorean descent network
ax3 = axes[1, 0]

import math

def pythagorean_moves(n):
    moves = []
    n_sq = n * n
    for m in range(1, n):
        k_sq = n_sq - m * m
        if k_sq > 0:
            k = int(math.isqrt(k_sq))
            if k * k == k_sq:
                moves.append(m)
    return moves

# Draw the network for small numbers
max_n = 50
edges = []
for n in range(2, max_n + 1):
    for m in pythagorean_moves(n):
        edges.append((n, m))

# Position nodes on a circle
hypotenuses = set()
for n in range(2, max_n + 1):
    if pythagorean_moves(n):
        hypotenuses.add(n)

all_nodes = set()
for n, m in edges:
    all_nodes.add(n)
    all_nodes.add(m)

node_list = sorted(all_nodes)
n_nodes = len(node_list)
angles = {node: 2 * np.pi * i / n_nodes for i, node in enumerate(node_list)}
positions = {node: (np.cos(angles[node]), np.sin(angles[node])) 
             for node in node_list}

# Draw edges
for n, m in edges:
    x1, y1 = positions[n]
    x2, y2 = positions[m]
    ax3.plot([x1, x2], [y1, y2], 'b-', alpha=0.15, linewidth=0.5)

# Draw nodes
for node in node_list:
    x, y = positions[node]
    color = '#e74c3c' if node in hypotenuses else '#3498db'
    ax3.scatter(x, y, c=color, s=30, zorder=3, edgecolor='black', linewidth=0.3)

ax3.set_xlim(-1.3, 1.3)
ax3.set_ylim(-1.3, 1.3)
ax3.set_aspect('equal')
ax3.set_title(f'Pythagorean Descent Network (n ≤ {max_n})', fontsize=12)
ax3.axis('off')

hyp_patch = mpatches.Patch(color='#e74c3c', label='Hypotenuse')
leg_patch = mpatches.Patch(color='#3498db', label='Leg only')
ax3.legend(handles=[hyp_patch, leg_patch], loc='lower right', fontsize=9)

# Plot 4: Hypotenuse density
ax4 = axes[1, 1]

Ns = list(range(5, 501))
counts = []
cnt = 0
hyp_set = set()
for n in range(1, 501):
    if pythagorean_moves(n):
        hyp_set.add(n)
    if n >= 5:
        counts.append(len([h for h in hyp_set if h <= n]))

predicted = [N / math.sqrt(math.log(N)) for N in Ns]

# Scale predicted to match
scale = counts[-1] / predicted[-1] if predicted[-1] > 0 else 1

ax4.plot(Ns, counts, 'b-', linewidth=2, label='Actual count')
ax4.plot(Ns, [scale * p for p in predicted], 'r--', linewidth=1.5, 
         label=f'C·N/√(log N), C≈{scale:.3f}')
ax4.set_xlabel('N', fontsize=11)
ax4.set_ylabel('# Pythagorean Hypotenuses ≤ N', fontsize=11)
ax4.set_title('Hypotenuse Density (Landau–Ramanujan Conjecture)', fontsize=12)
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_game_tree.png', dpi=150, bbox_inches='tight')
print("Saved visualization to viz_game_tree.png")


"""
Visualization: Pythagorean Descent Game Analysis

Visualizes the game-theoretic structure of the Pythagorean descent game:
game values, winning/losing classification, and descent tree structure.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import math

# ---- Inline Pythagorean game functions (self-contained) ----

def pythagorean_moves(n):
    """Find all valid Pythagorean descent moves from n."""
    moves = []
    n_sq = n * n
    for m in range(1, n):
        k_sq = n_sq - m * m
        if k_sq > 0:
            k = int(math.isqrt(k_sq))
            if k * k == k_sq:
                moves.append(m)
    return moves

def compute_game_values(max_n):
    """Compute game values for all positions up to max_n."""
    values = {}
    winning = {}
    
    for n in range(0, max_n + 1):
        moves = pythagorean_moves(n)
        if not moves:
            values[n] = 0
            winning[n] = False
        else:
            values[n] = max(values.get(m, 0) + 1 for m in moves)
            winning[n] = any(not winning.get(m, False) for m in moves)
    
    return values, winning

# ---- Compute data ----
max_n = 100
values, winning = compute_game_values(max_n)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Pythagorean Descent Game: Structure and Strategy', 
             fontsize=16, fontweight='bold')

# Plot 1: Game values as bar chart
ax1 = axes[0, 0]
hypotenuses = [n for n in range(2, max_n + 1) if pythagorean_moves(n)]
game_vals = [values[n] for n in hypotenuses]
colors = ['#2ecc71' if winning[n] else '#e74c3c' for n in hypotenuses]

ax1.bar(hypotenuses, game_vals, color=colors, width=0.8, edgecolor='none')
ax1.set_xlabel('Position n (Pythagorean hypotenuses)', fontsize=11)
ax1.set_ylabel('Game Value (Rank)', fontsize=11)
ax1.set_title('Game Values of Pythagorean Positions', fontsize=12)

win_patch = mpatches.Patch(color='#2ecc71', label='Winning')
lose_patch = mpatches.Patch(color='#e74c3c', label='Losing')
ax1.legend(handles=[win_patch, lose_patch], fontsize=10)
ax1.grid(True, alpha=0.3, axis='y')

# Plot 2: Game value distribution
ax2 = axes[0, 1]
val_counts = {}
for n in hypotenuses:
    v = values[n]
    val_counts[v] = val_counts.get(v, 0) + 1

sorted_vals = sorted(val_counts.keys())
counts = [val_counts[v] for v in sorted_vals]

ax2.bar(sorted_vals, counts, color='#3498db', edgecolor='black', linewidth=0.5)
ax2.set_xlabel('Game Value', fontsize=11)
ax2.set_ylabel('Number of Positions', fontsize=11)
ax2.set_title('Distribution of Game Values (n ≤ 100)', fontsize=12)
ax2.grid(True, alpha=0.3, axis='y')

# Plot 3: Descent tree from 65
ax3 = axes[1, 0]

def draw_tree(ax, n, x, y, dx, depth=0, max_depth=4):
    """Draw the descent tree from position n."""
    if depth > max_depth:
        return
    
    moves = pythagorean_moves(n)
    is_win = winning.get(n, False)
    
    color = '#2ecc71' if is_win else '#e74c3c'
    ax.scatter(x, y, s=200, c=color, zorder=5, edgecolor='black', linewidth=1)
    ax.text(x, y, str(n), ha='center', va='center', fontsize=7, fontweight='bold')
    
    if not moves or depth >= max_depth:
        return
    
    n_moves = len(moves)
    if n_moves == 1:
        offsets = [0]
    else:
        offsets = np.linspace(-dx, dx, n_moves)
    
    for i, m in enumerate(moves):
        child_x = x + offsets[i]
        child_y = y - 1
        ax.plot([x, child_x], [y, child_y], 'k-', linewidth=1, alpha=0.5)
        draw_tree(ax, m, child_x, child_y, dx * 0.4, depth + 1, max_depth)

draw_tree(ax3, 65, 0, 0, 4, max_depth=3)
ax3.set_title('Descent Tree from n=65', fontsize=12)
ax3.set_xlim(-6, 6)
ax3.set_ylim(-4.5, 0.8)
ax3.axis('off')

# Plot 4: Winning vs losing positions heatmap
ax4 = axes[1, 1]

# Create a grid showing which positions are winning/losing/non-game
grid_size = 10
grid = np.zeros((grid_size, grid_size))
labels_grid = np.empty((grid_size, grid_size), dtype=object)

for i in range(grid_size):
    for j in range(grid_size):
        n = i * grid_size + j + 1
        if n > max_n:
            grid[i, j] = 0.5  # neutral
            labels_grid[i, j] = ''
        elif not pythagorean_moves(n):
            grid[i, j] = 0  # not a hypotenuse
            labels_grid[i, j] = str(n)
        elif winning.get(n, False):
            grid[i, j] = 1  # winning
            labels_grid[i, j] = str(n)
        else:
            grid[i, j] = -1  # losing
            labels_grid[i, j] = str(n)

cmap = plt.cm.RdYlGn
im = ax4.imshow(grid, cmap=cmap, vmin=-1, vmax=1, aspect='equal')

for i in range(grid_size):
    for j in range(grid_size):
        n = i * grid_size + j + 1
        if n <= max_n:
            fontsize = 6 if n >= 10 else 7
            ax4.text(j, i, labels_grid[i, j], ha='center', va='center', 
                    fontsize=fontsize)

ax4.set_title('Positions 1-100: Win/Lose/Non-game', fontsize=12)
ax4.set_xticks([])
ax4.set_yticks([])

non_patch = mpatches.Patch(color=cmap(0.5), label='Non-hypotenuse')
win2_patch = mpatches.Patch(color=cmap(1.0), label='Winning')
lose2_patch = mpatches.Patch(color=cmap(0.0), label='Losing')
ax4.legend(handles=[win2_patch, lose2_patch, non_patch], 
           fontsize=8, loc='upper right')

plt.tight_layout()
plt.savefig('viz_pythagorean_game.png', dpi=150, bbox_inches='tight')
print("Saved visualization to viz_pythagorean_game.png")


"""
Visualization: Tropical Game Algebra

Visualizes the tropical (min-plus) semiring structure on game values,
showing how game composition (tropical multiplication = addition)
and game choice (tropical addition = minimum) interact.
"""

import matplotlib.pyplot as plt
import numpy as np

fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle('Tropical Game Algebra: The Min-Plus Semiring', 
             fontsize=15, fontweight='bold')

# Plot 1: Tropical multiplication table (val component)
ax1 = axes[0]
n = 8
vals = np.arange(n)
mul_table = np.zeros((n, n), dtype=int)
for i in range(n):
    for j in range(n):
        mul_table[i, j] = i + j  # tropical mul = ordinary add

im1 = ax1.imshow(mul_table, cmap='YlOrRd', aspect='equal')
ax1.set_xlabel('b.val', fontsize=11)
ax1.set_ylabel('a.val', fontsize=11)
ax1.set_title('Tropical Multiplication\n(a ⊙ b).val = a.val + b.val', fontsize=12)
ax1.set_xticks(range(n))
ax1.set_yticks(range(n))

for i in range(n):
    for j in range(n):
        ax1.text(j, i, str(mul_table[i, j]), ha='center', va='center', 
                fontsize=8, color='black' if mul_table[i,j] < 10 else 'white')

plt.colorbar(im1, ax=ax1, shrink=0.8)

# Plot 2: Tropical addition table (val component)
ax2 = axes[1]
add_table = np.zeros((n, n), dtype=int)
for i in range(n):
    for j in range(n):
        add_table[i, j] = min(i, j)  # tropical add = min

im2 = ax2.imshow(add_table, cmap='YlGnBu', aspect='equal')
ax2.set_xlabel('b.val', fontsize=11)
ax2.set_ylabel('a.val', fontsize=11)
ax2.set_title('Tropical Addition\n(a ⊕ b).val = min(a.val, b.val)', fontsize=12)
ax2.set_xticks(range(n))
ax2.set_yticks(range(n))

for i in range(n):
    for j in range(n):
        ax2.text(j, i, str(add_table[i, j]), ha='center', va='center', 
                fontsize=8)

plt.colorbar(im2, ax=ax2, shrink=0.8)

# Plot 3: Distributivity visualization
ax3 = axes[2]

# Show that (a⊕b)⊙c = (a⊙c)⊕(b⊙c) when a.val ≤ b.val
a_vals = range(0, 6)
b_vals = range(0, 6)
c_val = 2  # fixed c

lhs_data = []
rhs_data = []
labels = []

for a in a_vals:
    for b in b_vals:
        if a <= b:  # condition for distributivity
            # LHS: (a⊕b)⊙c = min(a,b) + c = a + c
            lhs = min(a, b) + c_val
            # RHS: min(a+c, b+c) = a + c (since a ≤ b)
            rhs = min(a + c_val, b + c_val)
            lhs_data.append(lhs)
            rhs_data.append(rhs)
            labels.append(f'({a},{b})')

x = range(len(lhs_data))
ax3.bar([i - 0.15 for i in x], lhs_data, width=0.3, color='#3498db', 
        label='(a⊕b)⊙c', alpha=0.8)
ax3.bar([i + 0.15 for i in x], rhs_data, width=0.3, color='#e74c3c', 
        label='(a⊙c)⊕(b⊙c)', alpha=0.8)

ax3.set_xlabel('(a.val, b.val) pairs', fontsize=10)
ax3.set_ylabel('Result value', fontsize=11)
ax3.set_title(f'Distributivity Verification (c.val={c_val})\n'
              f'a.val ≤ b.val guaranteed', fontsize=12)
ax3.set_xticks(x)
ax3.set_xticklabels(labels, rotation=45, fontsize=7)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('viz_tropical.png', dpi=150, bbox_inches='tight')
print("Saved visualization to viz_tropical.png")
