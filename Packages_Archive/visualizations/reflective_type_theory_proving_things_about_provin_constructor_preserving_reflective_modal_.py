from __future__ import annotations
from typing import Any, Mapping
Tree = tuple[Any, ...]
def translate(t: Tree, names: Mapping[str,str]) -> Tree:
    tag, *xs = t
    if tag in {"atom","bound","var"}: return (names[tag], xs[0])
    return (names[tag], *(translate(x, names) for x in xs))
def main() -> None:
    forward={"atom":"atom","bound":"var","proof":"box","fix":"mu"}
    backward={v:k for k,v in forward.items()}
    r=("fix",("proof",("bound",0)))
    m=translate(r,forward)
    print(r, "->", m, "->", translate(m,backward))
if __name__ == "__main__": main()
