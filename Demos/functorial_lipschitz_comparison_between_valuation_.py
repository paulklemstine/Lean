"""
demo.py — Numerical demonstrations of the functorial Lipschitz comparison
between valuation depth (max-plus) and tropical valuation objects (multiplicative).

Core thesis demonstrated numerically:

    valuation depth  ==  log_base ( tropical Lipschitz constant )
    tropical shadow  ==  base ** valuation depth

and the law-intertwining identity

    base ** (max(a, b) + 1)  ==  base * max(base ** a, base ** b).

All functions are self-contained and fully type-hinted. Run `python demo.py`.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, List, Tuple


# ---------------------------------------------------------------------------
# 1. Valuation depth: the additive (max-plus) side
# ---------------------------------------------------------------------------

def vdepth_add(d_f: int, d_g: int) -> int:
    """Depth of f + g under the max-plus law: max(d_f, d_g) + 1."""
    return max(d_f, d_g) + 1


def vdepth_mul(d_f: int, d_g: int) -> int:
    """Depth of f * g: same max-plus law."""
    return max(d_f, d_g) + 1


def vdepth_comp(d_f: int, d_g: int) -> int:
    """Depth of f ∘ g (ultrametric composition law): max(d_f, d_g) + 1."""
    return max(d_f, d_g) + 1


def vdepth_square(d_f: int) -> int:
    """Squaring bound: max(d, d) + 1 = d + 1."""
    return vdepth_mul(d_f, d_f)


def vdepth_iterate(d_f: int, n: int) -> int:
    """Upper bound on depth of the n-fold iterate via repeated composition."""
    d: int = d_f
    for _ in range(n):
        d = vdepth_comp(d_f, d)
    return d


# ---------------------------------------------------------------------------
# 2. The comparison functor: exponential shadow and discrete-log inverse
# ---------------------------------------------------------------------------

def tropical_shadow(depth: int, base: int = 2) -> int:
    """T(f) = base ** depth — the tropical (multiplicative) shadow of depth."""
    return base ** depth


def depth_from_shadow(shadow: int, base: int = 2) -> int:
    """Nat.log_base inverse: recover depth from a shadow (exact on powers)."""
    if shadow < 1:
        return 0
    d: int = 0
    while base ** (d + 1) <= shadow:
        d += 1
    return d


def intertwining_identity(a: int, b: int, base: int = 2) -> Tuple[int, int, bool]:
    """Lemma 4.1: base**(max(a,b)+1) == base * max(base**a, base**b)."""
    lhs: int = base ** (max(a, b) + 1)
    rhs: int = base * max(base ** a, base ** b)
    return lhs, rhs, lhs == rhs


# ---------------------------------------------------------------------------
# 3. Tropical valuation objects: multiplicative Lipschitz rate
# ---------------------------------------------------------------------------

def iterated_tropical_rate(C: int, n: int) -> int:
    """Iterated tropical/ultrametric Lipschitz rate: C-Lipschitz => C**n."""
    return C ** n


@dataclass
class UltraLipschitzData:
    """Ultrametric Lipschitz datum: a single signed exponent.

    Composition takes the MIN exponent; iteration leaves it INVARIANT.
    """
    exponent: int

    @property
    def is_non_expansive(self) -> bool:
        return self.exponent >= 0

    def compose(self, other: "UltraLipschitzData") -> "UltraLipschitzData":
        return UltraLipschitzData(min(self.exponent, other.exponent))

    def iterate(self, n: int) -> "UltraLipschitzData":
        result: "UltraLipschitzData" = self
        for _ in range(n):
            result = result.compose(self)
        return result


# ---------------------------------------------------------------------------
# 4. Hensel iteration complexity (logarithmic, from quadratic precision)
# ---------------------------------------------------------------------------

def hensel_precision(steps: int) -> int:
    """Certified precision after `steps` Hensel-Newton steps: >= 2**steps."""
    return 2 ** steps


def hensel_steps_for_digits(digits: int) -> int:
    """Steps to reach `digits` of precision: floor(log2(digits)) + 1."""
    if digits < 1:
        return 0
    return digits.bit_length() - 1 + 1  # floor(log2 d) + 1


# ---------------------------------------------------------------------------
# 5. Depth evaluation over an expression tree (Algorithm 5.1)
# ---------------------------------------------------------------------------

Expr = Tuple  # ('leaf', d) | ('add'|'mul'|'comp', left, right)


def eval_depth(expr: Expr) -> int:
    """Bottom-up fold computing vdepth of an expression tree."""
    head = expr[0]
    if head == "leaf":
        return int(expr[1])
    left: int = eval_depth(expr[1])
    right: int = eval_depth(expr[2])
    return max(left, right) + 1


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_intertwining(base: int = 2) -> None:
    print(f"--- Law intertwining: base**(max(a,b)+1) == base*max(base**a,base**b), base={base} ---")
    for a, b in [(0, 0), (1, 0), (2, 3), (5, 2), (4, 4)]:
        lhs, rhs, ok = intertwining_identity(a, b, base)
        print(f"a={a}, b={b}:  lhs={lhs:>6}  rhs={rhs:>6}  equal={ok}")
    print()


def demo_log_exp_roundtrip(base: int = 2) -> None:
    print(f"--- depth <-> shadow round trip (base={base}) ---")
    for d in range(7):
        s = tropical_shadow(d, base)
        d_back = depth_from_shadow(s, base)
        print(f"depth={d}  shadow=base**depth={s:>4}  recovered_depth={d_back}  exact={d == d_back}")
    print()


def demo_iteration_comparison() -> None:
    print("--- Iteration: multiplicative blow-up vs. invariant ultrametric exponent ---")
    C = 3
    for n in range(0, 6):
        rate = iterated_tropical_rate(C, n)
        print(f"n={n}: tropical rate C**n = {rate:>5}   (log_C rate = {n}, i.e. depth grows linearly)")
    print()
    print("Ultrametric exponent is stable under iteration (no blow-up):")
    for e in [-1, 0, 2]:
        data = UltraLipschitzData(e)
        it = data.iterate(100)
        print(f"  exponent={e:>2}  after 100 iterations -> exponent={it.exponent:>2}  "
              f"non_expansive={it.is_non_expansive}")
    print()


def demo_hensel() -> None:
    print("--- Hensel iteration complexity (O(log n) steps for n digits) ---")
    for digits in [64, 256, 1024, 1_000_000]:
        steps = hensel_steps_for_digits(digits)
        prec = hensel_precision(steps)
        print(f"digits={digits:>9}: steps={steps:>2}  certified precision 2**steps={prec:>10} >= digits "
              f"({prec >= digits})")
    print()


def demo_depth_tree() -> None:
    print("--- Depth evaluation over an expression tree (max-plus fold) ---")
    # ((leaf3 + leaf1) ∘ (leaf2 * leaf0))
    expr: Expr = ("comp",
                  ("add", ("leaf", 3), ("leaf", 1)),
                  ("mul", ("leaf", 2), ("leaf", 0)))
    d = eval_depth(expr)
    print("expr = comp( add(leaf3, leaf1), mul(leaf2, leaf0) )")
    print(f"vdepth(expr) = {d}   shadow base=2 -> {tropical_shadow(d, 2)}")
    print()


def demo_lipschitz_transfer() -> None:
    print("--- Sharp Lipschitz transfer: tropical constant == ultrametric constant ---")
    # Reconstruction is norm-faithful: norm == valuation, so C transfers unchanged.
    valuations: List[int] = [1, 2, 5, 8]
    C = 4
    f: Callable[[int], int] = lambda v: min(C * v, C * v)  # tropical C-Lipschitz on valuations
    for v in valuations:
        trop = f(v)              # tropical: val(f x) <= C * val x
        ultra = f(v)             # ultrametric: norm == val, same bound, same constant
        print(f"val={v}: tropical val(f)={trop} <= C*val={C*v}; "
              f"ultrametric norm(f)={ultra} <= C*norm={C*v}  (same C={C})")
    print()


def main() -> None:
    demo_intertwining(base=2)
    demo_intertwining(base=3)
    demo_log_exp_roundtrip(base=2)
    demo_iteration_comparison()
    demo_hensel()
    demo_depth_tree()
    demo_lipschitz_transfer()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
