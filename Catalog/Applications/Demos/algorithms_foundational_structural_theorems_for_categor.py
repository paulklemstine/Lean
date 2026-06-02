"""
Graded Tower Theory: Core Algorithms

Implements the key computational primitives for analyzing graded towers:
defect sequences, anomaly detection, stability analysis, and tower products.
"""

from typing import TypeVar, Callable, Generic, List, Set, Tuple, Optional
from dataclasses import dataclass

T = TypeVar('T')


@dataclass
class GradedTower(Generic[T]):
    """A graded tower of finite sets with transition maps.

    Attributes:
        levels: List of sets, one per level (index 0 = bottom)
        transitions: List of dicts mapping elements of level[i] to level[i+1]
    """
    levels: List[Set[T]]
    transitions: List[dict]

    @property
    def height(self) -> int:
        """Number of transition maps (= number of levels - 1)."""
        return len(self.transitions)

    def validate(self) -> bool:
        """Check that transitions map between correct levels."""
        if len(self.transitions) != len(self.levels) - 1:
            return False
        for i, t in enumerate(self.transitions):
            if set(t.keys()) != self.levels[i]:
                return False
            if not all(v in self.levels[i + 1] for v in t.values()):
                return False
        return True


def compute_image(tower: GradedTower, level: int) -> Set:
    """Compute the image of transition map at given level.

    Args:
        tower: The graded tower
        level: Index of the transition map (0-indexed)

    Returns:
        Set of elements in the image of transition[level]
    """
    return set(tower.transitions[level].values())


def compute_anomaly_set(tower: GradedTower, level: int) -> Set:
    """Compute the anomaly set at a given level.

    The anomaly set consists of elements in level[i+1] that are NOT
    in the image of transition[i]. These are the "unexplained" elements.

    Args:
        tower: The graded tower
        level: Index of the transition map

    Returns:
        Set of anomalous elements at level+1
    """
    image = compute_image(tower, level)
    return tower.levels[level + 1] - image


def compute_shadow_set(tower: GradedTower, level: int) -> Set:
    """Compute the shadow set (= image) at a given level.

    The shadow set consists of elements in level[i+1] that ARE
    in the image of transition[i]. These are the "explained" elements.

    Args:
        tower: The graded tower
        level: Index of the transition map

    Returns:
        Set of shadow (explained) elements at level+1
    """
    return compute_image(tower, level)


def compute_defect_sequence(tower: GradedTower) -> List[int]:
    """Compute the defect sequence of the tower.

    defect[i] = |level[i+1]| - |image(transition[i])|

    The defect measures the failure of surjectivity at each level.
    defect[i] = 0 iff transition[i] is surjective.

    Args:
        tower: The graded tower

    Returns:
        List of defect values, one per transition
    """
    defects = []
    for i in range(tower.height):
        image = compute_image(tower, i)
        d = len(tower.levels[i + 1]) - len(image)
        defects.append(d)
    return defects


def is_injective(transition: dict) -> bool:
    """Check if a transition map is injective.

    Args:
        transition: Dict representing the map

    Returns:
        True if the map is injective (no two keys map to same value)
    """
    values = list(transition.values())
    return len(values) == len(set(values))


def is_surjective(tower: GradedTower, level: int) -> bool:
    """Check if transition[level] is surjective.

    Args:
        tower: The graded tower
        level: Index of the transition

    Returns:
        True if every element of level[level+1] is in the image
    """
    return len(compute_anomaly_set(tower, level)) == 0


def is_bijective(tower: GradedTower, level: int) -> bool:
    """Check if transition[level] is bijective."""
    return is_injective(tower.transitions[level]) and is_surjective(tower, level)


def find_stability_level(tower: GradedTower) -> Optional[int]:
    """Find the minimal stability level of the tower.

    The stability level k is the smallest index such that all
    transitions from k onward are bijective.

    Args:
        tower: The graded tower

    Returns:
        Minimal stability level, or None if the tower never stabilizes
    """
    n = tower.height
    # Check from the top down
    stability = n  # Start past the end
    for i in range(n - 1, -1, -1):
        if is_bijective(tower, i):
            stability = i
        else:
            break
    return stability if stability < n else None


def compute_fiber(transition: dict, target) -> Set:
    """Compute the fiber (preimage) of a single element.

    Args:
        transition: Dict representing the map
        target: Element to find the fiber of

    Returns:
        Set of elements mapping to target
    """
    return {k for k, v in transition.items() if v == target}


def verify_shadow_anomaly_partition(tower: GradedTower, level: int) -> bool:
    """Verify the Shadow-Anomaly Partition Theorem computationally.

    Checks that shadow ∪ anomaly = level[i+1] and shadow ∩ anomaly = ∅.

    Args:
        tower: The graded tower
        level: Index of the transition

    Returns:
        True if the partition property holds
    """
    shadow = compute_shadow_set(tower, level)
    anomaly = compute_anomaly_set(tower, level)
    union_ok = (shadow | anomaly) == tower.levels[level + 1]
    disjoint_ok = len(shadow & anomaly) == 0
    return union_ok and disjoint_ok


def tower_product(t1: GradedTower, t2: GradedTower) -> GradedTower:
    """Compute the product of two towers of the same height.

    The product tower has levels L1[i] × L2[i] and transitions
    τ1[i] × τ2[i].

    Args:
        t1: First tower
        t2: Second tower (must have same height)

    Returns:
        Product tower

    Raises:
        ValueError: If towers have different heights
    """
    if t1.height != t2.height:
        raise ValueError("Towers must have the same height")

    product_levels = []
    for i in range(len(t1.levels)):
        product_levels.append({(a, b) for a in t1.levels[i] for b in t2.levels[i]})

    product_transitions = []
    for i in range(t1.height):
        trans = {}
        for a in t1.levels[i]:
            for b in t2.levels[i]:
                trans[(a, b)] = (t1.transitions[i][a], t2.transitions[i][b])
        product_transitions.append(trans)

    return GradedTower(levels=product_levels, transitions=product_transitions)
