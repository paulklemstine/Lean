from __future__ import annotations
from typing import Callable, FrozenSet
S = FrozenSet[int]
def iterate(worlds:S, phi:Callable[[S],S]) -> list[S]:
    history=[frozenset()]
    for _ in range(len(worlds)+1):
        nxt=phi(history[-1]); history.append(nxt)
        if nxt == history[-2]: return history
    raise ValueError("operator did not stabilize")
def main() -> None:
    worlds=frozenset({0,1,2}); edges=frozenset({(2,1),(1,0)})
    phi=lambda x: frozenset({0}) | frozenset(u for u,v in edges if v in x)
    print([sorted(x) for x in iterate(worlds,phi)])
    x=frozenset()
    print("negative iteration:", end=" ")
    for _ in range(5): print(sorted(x), end=" "); x=worlds-x
    print()
if __name__ == "__main__": main()
