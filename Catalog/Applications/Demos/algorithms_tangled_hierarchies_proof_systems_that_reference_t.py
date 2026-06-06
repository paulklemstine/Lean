#!/usr/bin/env python3
"""
Tangled Hierarchies: Core Algorithms

Type-hinted implementations of provability lattice operations
and consistency tower computations.
"""

from typing import Set, List, Callable, Tuple, Optional
from dataclasses import dataclass


@dataclass
class GLFrame:
    """A GL (Gödel-Löb) frame: finite set of worlds with transitive,
    irreflexive accessibility relation."""
    worlds: Set[int]
    accessible: Callable[[int, int], bool]  # R(w, v)
    
    def successors(self, w: int) -> Set[int]:
        return {v for v in self.worlds if self.accessible(w, v)}
    
    def box(self, S: Set[int]) -> Set[int]:
        """□S = {w : all successors of w are in S}"""
        return {w for w in self.worlds if self.successors(w) <= S}
    
    def diamond(self, S: Set[int]) -> Set[int]:
        """◇S = {w : some successor of w is in S}"""
        return {w for w in self.worlds if self.successors(w) & S}
    
    def box_iter(self, n: int, S: Set[int]) -> Set[int]:
        """□ⁿS: iterate box n times."""
        result = S
        for _ in range(n):
            result = self.box(result)
        return result
    
    def soundness_element(self, S: Set[int]) -> Set[int]:
        """snd(S) = (□S)ᶜ ∪ S"""
        return (self.worlds - self.box(S)) | S
    
    def snd_iter(self, n: int, S: Set[int]) -> Set[int]:
        """Iterate soundness n times."""
        result = S
        for _ in range(n):
            result = self.soundness_element(result)
        return result
    
    def consistency_tower(self, max_depth: int) -> List[Set[int]]:
        """Compute the first max_depth levels of the consistency tower.
        conTower(n) = (□^(n+1)⊥)ᶜ"""
        tower = []
        for n in range(max_depth):
            box_iter_bot = self.box_iter(n + 1, set())
            tower.append(self.worlds - box_iter_bot)
        return tower
    
    def provability_tower(self, max_depth: int) -> List[Set[int]]:
        """Compute the first max_depth levels of the provability tower.
        boxIter(n, ⊥)"""
        tower = [set()]
        for n in range(max_depth):
            tower.append(self.box(tower[-1]))
        return tower
    
    def tangling_rank(self, w: int) -> int:
        """Compute the well-founded rank of world w.
        The rank of a world is 1 + max rank of its successors."""
        succs = self.successors(w)
        if not succs:
            return 0
        return 1 + max(self.tangling_rank(v) for v in succs)
    
    def tangling_spectrum(self) -> dict:
        """Compute the tangling spectrum: {world: rank}"""
        return {w: self.tangling_rank(w) for w in self.worlds}
    
    def is_world_sound(self, w: int) -> bool:
        """Check if world w is sound: for all valuations and formulas,
        if w forces □φ then w forces φ.
        
        Equivalent to: w has no R-successors (in the semantic sense,
        a world is sound iff it cannot reach any world)."""
        return len(self.successors(w)) == 0
    
    def sound_worlds(self) -> Set[int]:
        """Return the set of all sound worlds."""
        return {w for w in self.worlds if self.is_world_sound(w)}


def linear_gl_frame(n: int) -> GLFrame:
    """Create a linear GL frame on n worlds: 0 < 1 < ... < n-1."""
    return GLFrame(
        worlds=set(range(n)),
        accessible=lambda w, v: w < v
    )


def tree_gl_frame(depth: int) -> GLFrame:
    """Create a binary tree GL frame of given depth.
    Worlds are labeled by binary strings (as integers).
    """
    worlds = set()
    next_id = [0]
    
    def build_tree(d: int) -> int:
        w = next_id[0]
        next_id[0] += 1
        worlds.add(w)
        if d > 0:
            left = build_tree(d - 1)
            right = build_tree(d - 1)
            children[w] = {left, right}
        else:
            children[w] = set()
        return w
    
    children: dict = {}
    root = build_tree(depth)
    
    # Compute transitive closure
    def descendants(w: int) -> Set[int]:
        result = set()
        for c in children.get(w, set()):
            result.add(c)
            result |= descendants(c)
        return result
    
    desc_cache = {w: descendants(w) for w in worlds}
    
    return GLFrame(
        worlds=worlds,
        accessible=lambda w, v: v in desc_cache.get(w, set())
    )


def verify_loeb_axiom(frame: GLFrame, valuation: Set[int]) -> bool:
    """Verify Löb's axiom □(□φ → φ) → □φ for a specific valuation.
    
    Args:
        frame: A GL frame
        valuation: Set of worlds where φ is true
    
    Returns:
        True if the Löb axiom holds for this valuation
    """
    box_phi = frame.box(valuation)
    # □φ → φ at world w means: w ∉ □φ or w ∈ φ
    imp_set = (frame.worlds - box_phi) | valuation
    box_imp = frame.box(imp_set)
    # □(□φ → φ) → □φ means: box_imp ⊆ box_phi
    return box_imp <= box_phi


def verify_second_incompleteness(frame: GLFrame) -> bool:
    """Verify the semantic second incompleteness theorem:
    no sound, consistent world proves its own consistency.
    
    Returns True if the theorem holds (no counterexample found).
    """
    box_bot = frame.box(set())
    # Sound for ⊥: worlds not in □⊥
    sound_worlds = frame.worlds - box_bot
    # Consistent: worlds not in ⊥ (all worlds)
    consistent = frame.worlds
    # Can prove own soundness: worlds in □(□⊥ → ⊥) = □(sound_for_bot)
    box_sound = frame.box(sound_worlds)
    
    for w in sound_worlds & consistent:
        if w in box_sound:
            return False  # Counterexample!
    return True


def compute_tangling_ceiling(frame: GLFrame, start: Set[int], 
                              max_iter: int = 100) -> Tuple[Set[int], int]:
    """Compute the tangling ceiling: iterate snd until stabilization.
    
    Returns (ceiling_set, num_iterations).
    """
    current = start
    for i in range(max_iter):
        next_set = frame.soundness_element(current)
        if next_set == current:
            return current, i
        current = next_set
    return current, max_iter


if __name__ == "__main__":
    # Demo: linear frame
    frame = linear_gl_frame(6)
    print("Linear GL Frame on 6 worlds")
    print(f"Tangling spectrum: {frame.tangling_spectrum()}")
    print(f"Provability tower: {[sorted(s) for s in frame.provability_tower(8)]}")
    print(f"Consistency tower: {[sorted(s) for s in frame.consistency_tower(8)]}")
    print(f"Löb axiom verified: {verify_loeb_axiom(frame, {3, 4, 5})}")
    print(f"Second incompleteness verified: {verify_second_incompleteness(frame)}")
    
    ceiling, iters = compute_tangling_ceiling(frame, {5})
    print(f"Tangling ceiling from {{5}}: {sorted(ceiling)} (after {iters} iterations)")
    
    # Demo: tree frame
    tree = tree_gl_frame(3)
    print(f"\nBinary tree GL frame (depth 3): {len(tree.worlds)} worlds")
    print(f"Second incompleteness verified: {verify_second_incompleteness(tree)}")
    print(f"Tangling spectrum: {tree.tangling_spectrum()}")
