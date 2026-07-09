"""Render the smallest forbidden minor G_{2,1} and a daisy cube as text/SVG.

Standalone: writes an SVG of the daisy cube dc({{0,1},{1,2}}) inside Q3,
drawn as a Hasse-style diagram by subset size (rank).
"""
from itertools import combinations
from typing import FrozenSet, List, Set

Vertex = FrozenSet[int]


def down_closure(gens: List[Vertex]) -> Set[Vertex]:
    out: Set[Vertex] = set()
    stack = list(gens)
    while stack:
        a = stack.pop()
        if a in out:
            continue
        out.add(a)
        for x in a:
            stack.append(a - {x})
    return out


def render_svg(path: str = "daisy_cube.svg") -> None:
    fam = sorted(down_closure([frozenset({0, 1}), frozenset({1, 2})]), key=lambda s: (len(s), sorted(s)))
    ranks: dict[int, List[Vertex]] = {}
    for v in fam:
        ranks.setdefault(len(v), []).append(v)
    W, H, R = 520, 360, 16
    pos = {}
    for r, vs in ranks.items():
        y = 40 + r * 110
        for i, v in enumerate(vs):
            x = (W * (i + 1)) // (len(vs) + 1)
            pos[v] = (x, y)
    lines = ['<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d">' % (W, H),
             '<rect width="100%%" height="100%%" fill="#0b1020"/>']
    for a in fam:
        for b in fam:
            if len(a ^ b) == 1 and len(a) < len(b):
                (x1, y1), (x2, y2) = pos[a], pos[b]
                lines.append('<line x1="%d" y1="%d" x2="%d" y2="%d" stroke="#5b8def" stroke-width="2"/>' % (x1, y1, x2, y2))
    for v, (x, y) in pos.items():
        label = "{" + ",".join(map(str, sorted(v))) + "}" if v else "∅"
        lines.append('<circle cx="%d" cy="%d" r="%d" fill="#ffd166"/>' % (x, y, R))
        lines.append('<text x="%d" y="%d" font-size="11" text-anchor="middle" fill="#0b1020">%s</text>' % (x, y + 4, label))
    lines.append('</svg>')
    with open(path, "w") as f:
        f.write("\n".join(lines))
    print("wrote", path)


if __name__ == "__main__":
    render_svg()
