from typing import Optional, Dict, Set

class NestingForest:
    def __init__(self):
        self._parents: Dict[int, Optional[int]] = {}

    def add_oval(self, oval_id: int, parent_id: Optional[int] = None):
        self._parents[oval_id] = parent_id

    def depth(self, oval_id: int) -> int:
        d = 0
        current = oval_id
        while self._parents[current] is not None:
            current = self._parents[current]
            d += 1
        return d

    def is_outer(self, oval_id: int) -> bool:
        return self.depth(oval_id) % 2 == 0

    def max_depth(self) -> int:
        return max(self.depth(o) for o in self._parents) if self._parents else 0

# Example: quartic with nested pairs
forest = NestingForest()
forest.add_oval(1)  # root
forest.add_oval(2)  # root
forest.add_oval(3, 1)  # inside oval 1
forest.add_oval(4, 1)  # inside oval 1
for o in [1, 2, 3, 4]:
    print(f'Oval {o}: depth={forest.depth(o)}, outer={forest.is_outer(o)}')