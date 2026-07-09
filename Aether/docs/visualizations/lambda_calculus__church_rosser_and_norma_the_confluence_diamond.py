"""
Visualization: the confluence diamond for parallel reduction.

Renders, as a Matplotlib figure, the reduction fork of a lambda term together
with the canonical common reduct given by Takahashi's complete development
cd(t). Demonstrates the diamond property:  t ==> u, t ==> v, and both
u ==> cd(t) and v ==> cd(t).
"""

from __future__ import annotations

from dataclasses import dataclass

import matplotlib.pyplot as plt


@dataclass(frozen=True)
class Term:
    pass


@dataclass(frozen=True)
class Var(Term):
    idx: int


@dataclass(frozen=True)
class Lam(Term):
    body: Term


@dataclass(frozen=True)
class App(Term):
    fn: Term
    arg: Term


def show(t: Term) -> str:
    if isinstance(t, Var):
        return str(t.idx)
    if isinstance(t, Lam):
        return f"(λ {show(t.body)})"
    return f"({show(t.fn)} {show(t.arg)})"


def lift(c: int, t: Term) -> Term:
    if isinstance(t, Var):
        return Var(t.idx + 1) if t.idx >= c else t
    if isinstance(t, Lam):
        return Lam(lift(c + 1, t.body))
    return App(lift(c, t.fn), lift(c, t.arg))


def subst(j: int, s: Term, t: Term) -> Term:
    if isinstance(t, Var):
        if t.idx == j:
            return s
        return Var(t.idx - 1) if t.idx > j else t
    if isinstance(t, Lam):
        return Lam(subst(j + 1, lift(0, s), t.body))
    return App(subst(j, s, t.fn), subst(j, s, t.arg))


def subst0(u: Term, t: Term) -> Term:
    return subst(0, u, t)


def one_step(t: Term) -> list[Term]:
    out: list[Term] = []
    if isinstance(t, App) and isinstance(t.fn, Lam):
        out.append(subst0(t.arg, t.fn.body))
    if isinstance(t, App):
        out += [App(r, t.arg) for r in one_step(t.fn)]
        out += [App(t.fn, r) for r in one_step(t.arg)]
    if isinstance(t, Lam):
        out += [Lam(r) for r in one_step(t.body)]
    return out


def cd(t: Term) -> Term:
    if isinstance(t, Var):
        return t
    if isinstance(t, Lam):
        return Lam(cd(t.body))
    if isinstance(t.fn, Lam):
        return subst0(cd(t.arg), cd(t.fn.body))
    return App(cd(t.fn), cd(t.arg))


def main() -> None:
    I = Lam(Var(0))
    t = App(App(I, App(I, Var(0))), App(I, Var(1)))
    reds = []
    seen = set()
    for r in one_step(t):
        if show(r) not in seen:
            seen.add(show(r))
            reds.append(r)
    u = reds[0]
    v = reds[-1]
    w = cd(t)

    fig, ax = plt.subplots(figsize=(8, 6))
    pts = {
        "t": (0.5, 1.0),
        "u": (0.15, 0.55),
        "v": (0.85, 0.55),
        "w": (0.5, 0.1),
    }
    labels = {"t": show(t), "u": show(u), "v": show(v), "w": f"cd(t) = {show(w)}"}
    for k, (x, y) in pts.items():
        ax.scatter([x], [y], s=40, color="#22264b", zorder=3)
        ax.annotate(labels[k], (x, y), textcoords="offset points",
                    xytext=(0, 10), ha="center", fontsize=11)

    def arrow(a: str, b: str) -> None:
        (x1, y1), (x2, y2) = pts[a], pts[b]
        ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                    arrowprops=dict(arrowstyle="-|>", color="#b3123a", lw=2))

    arrow("t", "u")
    arrow("t", "v")
    arrow("u", "w")
    arrow("v", "w")
    ax.set_title("Confluence diamond: every fork joins at cd(t)", fontsize=13)
    ax.axis("off")
    fig.tight_layout()
    fig.savefig("confluence_diamond.png", dpi=150)
    print("wrote confluence_diamond.png")


if __name__ == "__main__":
    main()
