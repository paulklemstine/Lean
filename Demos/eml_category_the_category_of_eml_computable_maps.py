#!/usr/bin/env python3
"""Numerical and structural demonstrations for finite EML expression trees.

The script uses only the Python standard library.  Run it directly with
``python3 demo.py``.  It demonstrates substitution semantics, associative
program composition, tuple pairing, leaf-size invariance, and the explicit
exponential-tower witness that defeats each proposed finite template.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import exp, log
from typing import Sequence, TypeAlias


@dataclass(frozen=True)
class Const:
    value: float


@dataclass(frozen=True)
class Var:
    index: int


@dataclass(frozen=True)
class Add:
    left: "Expr"
    right: "Expr"


@dataclass(frozen=True)
class Mul:
    left: "Expr"
    right: "Expr"


@dataclass(frozen=True)
class Exp:
    child: "Expr"


@dataclass(frozen=True)
class Log:
    child: "Expr"


Expr: TypeAlias = Const | Var | Add | Mul | Exp | Log
Program: TypeAlias = tuple[Expr, ...]


def total_log(value: float) -> float:
    """A real-valued totalization: log(abs(x)) off zero and 0 at zero."""
    return 0.0 if value == 0.0 else log(abs(value))


def evaluate(expression: Expr, inputs: Sequence[float]) -> float:
    """Evaluate an EML expression at a real input vector."""
    if isinstance(expression, Const):
        return expression.value
    if isinstance(expression, Var):
        return inputs[expression.index]
    if isinstance(expression, Add):
        return evaluate(expression.left, inputs) + evaluate(expression.right, inputs)
    if isinstance(expression, Mul):
        return evaluate(expression.left, inputs) * evaluate(expression.right, inputs)
    if isinstance(expression, Exp):
        return exp(evaluate(expression.child, inputs))
    return total_log(evaluate(expression.child, inputs))


def size(expression: Expr) -> int:
    """Count all leaves and operation nodes in an expression tree."""
    if isinstance(expression, (Const, Var)):
        return 1
    if isinstance(expression, (Add, Mul)):
        return 1 + size(expression.left) + size(expression.right)
    return 1 + size(expression.child)


def substitute(expression: Expr, replacements: Sequence[Expr]) -> Expr:
    """Simultaneously replace each variable by its indexed expression."""
    if isinstance(expression, Const):
        return expression
    if isinstance(expression, Var):
        return replacements[expression.index]
    if isinstance(expression, Add):
        return Add(substitute(expression.left, replacements),
                   substitute(expression.right, replacements))
    if isinstance(expression, Mul):
        return Mul(substitute(expression.left, replacements),
                   substitute(expression.right, replacements))
    if isinstance(expression, Exp):
        return Exp(substitute(expression.child, replacements))
    return Log(substitute(expression.child, replacements))


def identity(arity: int) -> Program:
    """Return the coordinate-variable identity program."""
    return tuple(Var(index) for index in range(arity))


def compose(outer: Program, inner: Program) -> Program:
    """Compose two programs by substitution into every outer coordinate."""
    return tuple(substitute(output, inner) for output in outer)


def pair(first: Program, second: Program) -> Program:
    """Pair programs with a common input by concatenating their outputs."""
    return first + second


def evaluate_program(program: Program, inputs: Sequence[float]) -> tuple[float, ...]:
    """Evaluate every output coordinate of a program."""
    return tuple(evaluate(output, inputs) for output in program)


def exponential_tower(depth: int) -> Expr:
    """Build depth nested exponential nodes above the constant zero."""
    if depth < 0:
        raise ValueError("depth must be nonnegative")
    result: Expr = Const(0.0)
    for _ in range(depth):
        result = Exp(result)
    return result


def close_tuple(left: Sequence[float], right: Sequence[float], tolerance: float = 1e-12) -> bool:
    """Compare two numerical vectors within an absolute tolerance."""
    return len(left) == len(right) and all(
        abs(a - b) <= tolerance for a, b in zip(left, right)
    )


def demonstrate_substitution_semantics() -> None:
    """Check symbolic substitution against numerical functional composition."""
    outer: Expr = Add(Mul(Var(0), Var(1)), Exp(Var(0)))
    replacements = (Add(Var(0), Const(2.0)), Mul(Var(0), Const(0.5)))
    x = (1.25,)
    symbolic = evaluate(substitute(outer, replacements), x)
    intermediate = tuple(evaluate(item, x) for item in replacements)
    semantic = evaluate(outer, intermediate)
    print("1. Substitution semantics")
    print(f"   symbolic result = {symbolic:.12f}")
    print(f"   composed result = {semantic:.12f}")
    print(f"   agreement       = {abs(symbolic - semantic) < 1e-12}\n")


def demonstrate_category_and_pairing() -> None:
    """Check identity, associativity, and pairing-precomposition numerically."""
    f: Program = (Add(Var(0), Const(1.0)), Mul(Var(0), Var(0)))
    g: Program = (Add(Var(0), Var(1)), Exp(Mul(Const(0.1), Var(1))))
    h: Program = (Mul(Var(0), Var(1)),)
    x = (0.4,)

    left_assoc = compose(compose(h, g), f)
    right_assoc = compose(h, compose(g, f))
    identity_ok = compose(f, identity(1)) == f and compose(identity(2), f) == f
    associative_ok = left_assoc == right_assoc

    first: Program = (Add(Var(0), Const(3.0)),)
    second: Program = (Mul(Var(0), Var(0)), Exp(Var(0)))
    preprocessing: Program = (Mul(Const(2.0), Var(0)),)
    paired_then_composed = compose(pair(first, second), preprocessing)
    composed_then_paired = pair(compose(first, preprocessing),
                                compose(second, preprocessing))
    pairing_ok = paired_then_composed == composed_then_paired

    print("2. Category laws and tuple pairing")
    print(f"   identity laws                 = {identity_ok}")
    print(f"   associativity                 = {associative_ok}")
    print(f"   common numerical output       = {evaluate_program(left_assoc, x)}")
    print(f"   pairing commutes with compose = {pairing_ok}")
    print(f"   paired output at x={x[0]}      = "
          f"{evaluate_program(paired_then_composed, x)}\n")


def demonstrate_obstruction() -> None:
    """Construct the one-node-larger tower witness for several templates."""
    templates: tuple[Expr, ...] = (
        Var(0),
        Add(Var(0), Const(1.0)),
        Exp(Mul(Var(0), Add(Var(1), Const(2.0)))),
    )
    leaf_replacement = (Const(7.0), Const(-2.0))

    print("3. Finite-template obstruction")
    for number, template in enumerate(templates, start=1):
        replacements = leaf_replacement[:2] if number == 3 else leaf_replacement[:1]
        specialized = substitute(template, replacements)
        template_size = size(template)
        witness = exponential_tower(template_size)
        print(
            f"   template {number}: size={template_size}, "
            f"leaf-specialized size={size(specialized)}, "
            f"escaping tower size={size(witness)}"
        )
        assert size(specialized) == template_size
        assert size(witness) == template_size + 1
    print("   Every displayed witness is structurally unreachable by leaf substitution.\n")


def main() -> None:
    """Run all demonstrations."""
    print("Finite EML Programs: numerical and structural demonstrations\n")
    demonstrate_substitution_semantics()
    demonstrate_category_and_pairing()
    demonstrate_obstruction()


if __name__ == "__main__":
    main()
