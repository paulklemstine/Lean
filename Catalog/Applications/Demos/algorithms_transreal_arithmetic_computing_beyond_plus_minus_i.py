#!/usr/bin/env python3
"""
Transreal Arithmetic: Core Algorithms
=====================================
Type-hinted implementations of transreal number arithmetic.
"""

from __future__ import annotations
from enum import Enum, auto
from dataclasses import dataclass
from typing import Optional, Tuple, List


class Sign(Enum):
    """Sign classification for dispatch."""
    POSITIVE = auto()
    NEGATIVE = auto()
    ZERO = auto()


def classify_sign(x: float) -> Sign:
    """Classify the sign of a real number."""
    if x > 0:
        return Sign.POSITIVE
    elif x < 0:
        return Sign.NEGATIVE
    return Sign.ZERO


@dataclass(frozen=True)
class Transreal:
    """
    A transreal number.

    Representation: (tag, value) where
    - tag='real', value=float  → a real number
    - tag='pos_inf'            → +∞
    - tag='neg_inf'            → -∞
    - tag='nullity'            → Φ (0/0)
    """
    tag: str
    value: Optional[float] = None

    @staticmethod
    def real(x: float) -> Transreal:
        return Transreal(tag='real', value=x)

    @staticmethod
    def pos_inf() -> Transreal:
        return Transreal(tag='pos_inf')

    @staticmethod
    def neg_inf() -> Transreal:
        return Transreal(tag='neg_inf')

    @staticmethod
    def phi() -> Transreal:
        return Transreal(tag='nullity')

    def __str__(self) -> str:
        if self.tag == 'real':
            return str(self.value)
        return {'pos_inf': '+∞', 'neg_inf': '-∞', 'nullity': 'Φ'}[self.tag]

    def is_real(self) -> bool:
        return self.tag == 'real'

    def is_nullity(self) -> bool:
        return self.tag == 'nullity'

    def sign(self) -> Optional[Sign]:
        if not self.is_real():
            return None
        return classify_sign(self.value)


# ─── Addition ───

def transreal_add(a: Transreal, b: Transreal) -> Transreal:
    """
    Transreal addition.

    Algorithm:
    1. If either operand is Φ → Φ  (nullity absorption)
    2. If both real → real addition
    3. If both same infinity → that infinity
    4. If opposite infinities → Φ
    5. Infinity + real → that infinity
    """
    if a.is_nullity() or b.is_nullity():
        return Transreal.phi()

    if a.is_real() and b.is_real():
        return Transreal.real(a.value + b.value)

    if a.tag == 'pos_inf':
        if b.tag == 'pos_inf':
            return Transreal.pos_inf()
        if b.tag == 'neg_inf':
            return Transreal.phi()
        return Transreal.pos_inf()

    if a.tag == 'neg_inf':
        if b.tag == 'neg_inf':
            return Transreal.neg_inf()
        if b.tag == 'pos_inf':
            return Transreal.phi()
        return Transreal.neg_inf()

    # a is real, b is infinite
    return b  # real + inf = inf


# ─── Negation ───

def transreal_neg(a: Transreal) -> Transreal:
    """Transreal negation: negate reals, swap infinities, Φ → Φ."""
    if a.is_real():
        return Transreal.real(-a.value)
    if a.tag == 'pos_inf':
        return Transreal.neg_inf()
    if a.tag == 'neg_inf':
        return Transreal.pos_inf()
    return Transreal.phi()


# ─── Multiplication ───

def transreal_mul(a: Transreal, b: Transreal) -> Transreal:
    """
    Transreal multiplication.

    Algorithm:
    1. If either is Φ → Φ
    2. If both real → real multiplication
    3. If infinity × real: dispatch on sign of real
       - positive → same infinity
       - negative → opposite infinity
       - zero → Φ  (key departure from ring axioms!)
    4. infinity × infinity: same sign → +∞, different → -∞
    """
    if a.is_nullity() or b.is_nullity():
        return Transreal.phi()

    if a.is_real() and b.is_real():
        return Transreal.real(a.value * b.value)

    def inf_times_real(inf_positive: bool, r: float) -> Transreal:
        s = classify_sign(r)
        if s == Sign.ZERO:
            return Transreal.phi()
        if s == Sign.POSITIVE:
            return Transreal.pos_inf() if inf_positive else Transreal.neg_inf()
        return Transreal.neg_inf() if inf_positive else Transreal.pos_inf()

    if a.tag == 'pos_inf' and b.is_real():
        return inf_times_real(True, b.value)
    if a.tag == 'neg_inf' and b.is_real():
        return inf_times_real(False, b.value)
    if b.tag == 'pos_inf' and a.is_real():
        return inf_times_real(True, a.value)
    if b.tag == 'neg_inf' and a.is_real():
        return inf_times_real(False, a.value)

    # Both infinite
    if a.tag == b.tag:
        return Transreal.pos_inf()
    return Transreal.neg_inf()


# ─── Inversion ───

def transreal_inv(a: Transreal) -> Transreal:
    """Transreal multiplicative inverse: 1/0 = +∞, 1/±∞ = 0, 1/Φ = Φ."""
    if a.is_nullity():
        return Transreal.phi()
    if a.tag in ('pos_inf', 'neg_inf'):
        return Transreal.real(0.0)
    if a.value == 0:
        return Transreal.pos_inf()
    return Transreal.real(1.0 / a.value)


def transreal_div(a: Transreal, b: Transreal) -> Transreal:
    """Transreal division: a / b = a × b⁻¹."""
    return transreal_mul(a, transreal_inv(b))


# ─── Property Checkers ───

def is_additively_idempotent(x: Transreal) -> bool:
    """Check if x + x = x."""
    return transreal_add(x, x) == x


def is_negation_fixed_point(x: Transreal) -> bool:
    """Check if -x = x."""
    return transreal_neg(x) == x


def check_distributivity(a: Transreal, b: Transreal, c: Transreal) -> bool:
    """Check if a * (b + c) = a*b + a*c."""
    lhs = transreal_mul(a, transreal_add(b, c))
    rhs = transreal_add(transreal_mul(a, b), transreal_mul(a, c))
    return lhs == rhs


# ─── Transreal Evaluation Engine ───

def evaluate_expression(expr: str, env: dict[str, Transreal]) -> Transreal:
    """
    Simple expression evaluator for transreal arithmetic.
    Supports +, -, *, / with standard precedence.
    Variables looked up in env.
    """
    # Tokenize
    tokens: List[str] = []
    i = 0
    while i < len(expr):
        if expr[i].isspace():
            i += 1
        elif expr[i] in '+-*/()':
            tokens.append(expr[i])
            i += 1
        else:
            j = i
            while j < len(expr) and (expr[j].isalnum() or expr[j] in '._'):
                j += 1
            tokens.append(expr[i:j])
            i = j

    pos = 0

    def peek() -> Optional[str]:
        nonlocal pos
        return tokens[pos] if pos < len(tokens) else None

    def consume() -> str:
        nonlocal pos
        t = tokens[pos]
        pos += 1
        return t

    def parse_atom() -> Transreal:
        t = peek()
        if t == '(':
            consume()
            result = parse_expr()
            consume()  # ')'
            return result
        t = consume()
        if t in env:
            return env[t]
        try:
            return Transreal.real(float(t))
        except ValueError:
            raise ValueError(f"Unknown symbol: {t}")

    def parse_factor() -> Transreal:
        if peek() == '-':
            consume()
            return transreal_neg(parse_atom())
        return parse_atom()

    def parse_term() -> Transreal:
        left = parse_factor()
        while peek() in ('*', '/'):
            op = consume()
            right = parse_factor()
            if op == '*':
                left = transreal_mul(left, right)
            else:
                left = transreal_div(left, right)
        return left

    def parse_expr() -> Transreal:
        left = parse_term()
        while peek() in ('+', '-'):
            op = consume()
            right = parse_term()
            if op == '+':
                left = transreal_add(left, right)
            else:
                left = transreal_add(left, transreal_neg(right))
        return left

    return parse_expr()


if __name__ == "__main__":
    # Quick test
    env = {
        'inf': Transreal.pos_inf(),
        'ninf': Transreal.neg_inf(),
        'phi': Transreal.phi(),
    }
    tests = [
        "0 / 0",
        "1 / 0",
        "inf + ninf",
        "0 * inf",
        "inf * (0 + 1)",
        "inf * 0 + inf * 1",
    ]
    for expr in tests:
        result = evaluate_expression(expr, env)
        print(f"{expr:30s} = {result}")
