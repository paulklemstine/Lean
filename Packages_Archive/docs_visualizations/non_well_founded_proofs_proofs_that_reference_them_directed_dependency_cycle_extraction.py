from __future__ import annotations
from typing import Dict, List, Mapping, Optional

def find_cycle(edges: Mapping[str, List[str]]) -> Optional[List[str]]:
    state: Dict[str, int] = {v: 0 for v in edges}
    stack: List[str] = []
    pos: Dict[str, int] = {}
    def visit(v: str) -> Optional[List[str]]:
        state[v] = 1; pos[v] = len(stack); stack.append(v)
        for w in edges[v]:
            if state[w] == 0:
                answer = visit(w)
                if answer is not None: return answer
            elif state[w] == 1:
                return stack[pos[w]:] + [w]
        stack.pop(); pos.pop(v); state[v] = 2
        return None
    for vertex in edges:
        if state[vertex] == 0:
            answer = visit(vertex)
            if answer is not None: return answer
    return None

if __name__ == "__main__":
    print(find_cycle({"a": ["b"], "b": ["c"], "c": ["a"]}))
