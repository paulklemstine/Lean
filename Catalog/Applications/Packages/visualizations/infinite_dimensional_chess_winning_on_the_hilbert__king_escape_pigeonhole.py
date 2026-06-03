#!/usr/bin/env python3
"""
Algorithms for Infinite Chess on the Hilbert Board

Type-hinted implementations of the core algorithms from the formalization.
"""

from typing import Tuple, Set, List, Dict, Optional, FrozenSet
from dataclasses import dataclass
from enum import Enum, auto


# ============================================================
# Core Types
# ============================================================

Square = Tuple[int, int]


class PieceType(Enum):
    """Standard chess piece types."""
    KING = auto()
    QUEEN = auto()
    ROOK = auto()
    BISHOP = auto()
    KNIGHT = auto()
    PAWN = auto()


@dataclass(frozen=True)
class Piece:
    """A chess piece with type and position."""
    piece_type: PieceType
    position: Square


@dataclass
class ThreatConfiguration:
    """A finite configuration of threatening pieces with bounded threat radii."""
    pieces: List[Square]
    threat_sets: Dict[Square, Set[Square]]
    max_threat_radius: int
    max_threats_per_piece: int


# ============================================================
# Algorithm 1: Chebyshev Distance
# ============================================================

def chebyshev_distance(p: Square, q: Square) -> int:
    """
    Compute the Chebyshev (L∞) distance between two squares.
    
    This equals the minimum number of king moves from p to q.
    
    Time: O(1)
    Space: O(1)
    """
    return max(abs(p[0] - q[0]), abs(p[1] - q[1]))


# ============================================================
# Algorithm 2: King Escape (Pigeonhole)
# ============================================================

KING_OFFSETS = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]


def king_neighbors(p: Square) -> List[Square]:
    """Return the 8 king-adjacent squares."""
    return [(p[0] + dx, p[1] + dy) for dx, dy in KING_OFFSETS]


def find_safe_move(king_pos: Square, threats: Set[Square]) -> Optional[Square]:
    """
    Find a safe king move avoiding all threats.
    
    By the Pigeonhole Escape Theorem, this always succeeds when |threats| ≤ 7.
    
    Time: O(1) (always checks at most 8 neighbors)
    Space: O(1)
    """
    for neighbor in king_neighbors(king_pos):
        if neighbor not in threats:
            return neighbor
    return None  # Only possible if all 8 neighbors are threatened


# ============================================================
# Algorithm 3: Retreat Strategy
# ============================================================

def sign(x: int) -> int:
    """Sign function: returns -1, 0, or 1."""
    return (1 if x > 0 else (-1 if x < 0 else 0))


def retreat_square(king: Square, threat: Square) -> Square:
    """
    Compute the retreat square: the king move that maximizes
    distance from the threat.
    
    Guarantees: chebyshev_distance(result, threat) >= chebyshev_distance(king, threat) + 1
    
    Time: O(1)
    Space: O(1)
    """
    return (
        king[0] + sign(king[0] - threat[0]),
        king[1] + sign(king[1] - threat[1])
    )


def retreat_path(king: Square, threat: Square, steps: int) -> List[Square]:
    """
    Generate a retreat path of given length.
    Each step increases Chebyshev distance from the threat by exactly 1.
    
    Time: O(steps)
    Space: O(steps)
    """
    path = [king]
    current = king
    for _ in range(steps):
        current = retreat_square(current, threat)
        path.append(current)
    return path


# ============================================================
# Algorithm 4: Knight Attack Computation
# ============================================================

KNIGHT_OFFSETS = [(-2, -1), (-2, 1), (-1, -2), (-1, 2), (1, -2), (1, 2), (2, -1), (2, 1)]


def knight_attacks(pos: Square) -> List[Square]:
    """Return the 8 squares attacked by a knight at pos."""
    return [(pos[0] + dx, pos[1] + dy) for dx, dy in KNIGHT_OFFSETS]


def is_knight_safe(king: Square, knights: List[Square]) -> bool:
    """
    Check if the king is safe from all knights.
    
    By the Knight Safety theorem, safe iff chebyshev_distance(king, knight) > 3
    for all knights. More precisely, none of king's neighbors are knight-attacked.
    
    Time: O(|knights|)
    Space: O(|knights|)
    """
    king_nbrs = set(king_neighbors(king))
    for k in knights:
        if king_nbrs & set(knight_attacks(k)):
            return False
    return True


# ============================================================
# Algorithm 5: Threat Configuration Analysis
# ============================================================

def build_knight_threat_config(knight_positions: List[Square]) -> ThreatConfiguration:
    """Build a threat configuration from knight positions."""
    threat_sets = {}
    for pos in knight_positions:
        threat_sets[pos] = set(knight_attacks(pos))
    return ThreatConfiguration(
        pieces=knight_positions,
        threat_sets=threat_sets,
        max_threat_radius=2,
        max_threats_per_piece=8
    )


def total_threats(config: ThreatConfiguration) -> Set[Square]:
    """Compute the total threat set of a configuration."""
    result: Set[Square] = set()
    for threats in config.threat_sets.values():
        result |= threats
    return result


def find_safe_region(config: ThreatConfiguration) -> Square:
    """
    Find a square guaranteed safe from all threats.
    
    By the king_safe_far theorem, any square at Chebyshev distance 
    > maxThreatRadius + 1 from all pieces is safe.
    
    Time: O(|pieces|)
    Space: O(1)
    """
    if not config.pieces:
        return (0, 0)
    
    # Find the bounding box of all pieces
    max_coord = max(
        max(abs(p[0]), abs(p[1])) for p in config.pieces
    )
    
    # Go beyond max_coord + maxThreatRadius + 2 to guarantee safety
    safe_coord = max_coord + config.max_threat_radius + 2
    return (safe_coord, safe_coord)


# ============================================================
# Algorithm 6: Chain Game Value Computation
# ============================================================

def chain_game_value(n: int) -> List[int]:
    """
    Compute game values for all positions in the chain game of length n.
    
    Position k has value k (proved in chainGame_top_value).
    
    Time: O(n)
    Space: O(n)
    """
    return list(range(n + 1))


def verify_game_value_monotonicity(values: List[int]) -> bool:
    """
    Verify that game values are strictly decreasing along moves.
    In the chain game, position k+1 moves to position k,
    so value(k) < value(k+1) for all k.
    """
    return all(values[i] < values[i + 1] for i in range(len(values) - 1))


# ============================================================
# Algorithm 7: Escape Strategy Computation
# ============================================================

def compute_escape_strategy(
    king: Square,
    threats: List[Square],
    max_threat_radius: int,
    max_steps: int = 100
) -> List[Square]:
    """
    Compute an escape path for the king to reach safety.
    
    Strategy: retreat from the nearest threat at each step.
    By the Retreat Theorem and king_safe_far, the king eventually
    reaches a safe distance from all threats.
    
    Time: O(max_steps * |threats|)
    Space: O(max_steps)
    """
    path = [king]
    current = king
    
    for _ in range(max_steps):
        # Check if we're safe
        min_dist = min(
            (chebyshev_distance(current, t) for t in threats),
            default=float('inf')
        )
        if min_dist > max_threat_radius + 1:
            break  # Safe!
        
        # Find nearest threat
        nearest_threat = min(threats, key=lambda t: chebyshev_distance(current, t))
        
        # Retreat from nearest threat
        next_pos = retreat_square(current, nearest_threat)
        path.append(next_pos)
        current = next_pos
    
    return path


# ============================================================
# Main: Run all algorithms
# ============================================================

if __name__ == "__main__":
    print("Infinite Chess Algorithms — Test Suite")
    print("=" * 50)
    
    # Test Chebyshev distance
    assert chebyshev_distance((0, 0), (3, 5)) == 5
    assert chebyshev_distance((1, 2), (1, 2)) == 0
    assert chebyshev_distance((0, 0), (1, 1)) == 1
    print("✓ Chebyshev distance")
    
    # Test king escape
    assert find_safe_move((0, 0), set()) is not None
    assert find_safe_move((0, 0), {(-1,-1),(-1,0),(-1,1),(0,-1),(0,1),(1,-1),(1,0)}) is not None
    print("✓ King escape (pigeonhole)")
    
    # Test retreat
    r = retreat_square((0, 0), (3, 3))
    assert chebyshev_distance(r, (3, 3)) >= chebyshev_distance((0, 0), (3, 3)) + 1
    print("✓ Retreat theorem")
    
    # Test knight safety
    assert is_knight_safe((0, 0), [(5, 5)])  # Far knight
    assert not is_knight_safe((0, 0), [(1, 2)])  # Adjacent knight
    print("✓ Knight safety")
    
    # Test chain game
    values = chain_game_value(10)
    assert values[-1] == 10
    assert verify_game_value_monotonicity(values)
    print("✓ Chain game values")
    
    # Test escape strategy
    path = compute_escape_strategy((0, 0), [(3, 3), (-2, 5)], 2)
    final = path[-1]
    assert all(chebyshev_distance(final, t) > 3 for t in [(3, 3), (-2, 5)])
    print(f"✓ Escape strategy (escaped in {len(path)-1} steps)")
    
    # Test threat configuration
    config = build_knight_threat_config([(5, 5), (-3, 7)])
    safe = find_safe_region(config)
    assert all(chebyshev_distance(safe, p) > 3 for p in config.pieces)
    print("✓ Threat configuration analysis")
    
    print("\nAll tests passed!")
