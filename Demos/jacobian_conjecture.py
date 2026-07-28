#!/usr/bin/env python3
"""Exact demonstrations of the affine Jacobian--Weyl determinant identity."""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import Iterable, Sequence, TypeAlias

Q: TypeAlias = Fraction
Point: TypeAlias = tuple[Q, Q]
Polynomial: TypeAlias = list[Q]  # coefficients in ascending powers of t


def q(value: int) -> Q:
    """Create an exact rational number from an integer."""
    return Fraction(value, 1)


@dataclass(frozen=True)
class AffineMap2D:
    """The affine map (X,Y) -> (aX+bY+c, dX+eY+f)."""

    a: Q
    b: Q
    c: Q
    d: Q
    e: Q
    f: Q

    @property
    def determinant(self) -> Q:
        return self.a * self.e - self.b * self.d

    def apply(self, point: Point) -> Point:
        x, y = point
        return (
            self.a * x + self.b * y + self.c,
            self.d * x + self.e * y + self.f,
        )

    def inverse(self) -> "AffineMap2D":
        delta = self.determinant
        if delta == 0:
            raise ValueError("A singular affine map has no inverse.")
        # M^{-1}(u - translation)
        return AffineMap2D(
            self.e / delta,
            -self.b / delta,
            (self.b * self.f - self.e * self.c) / delta,
            -self.d / delta,
            self.a / delta,
            (self.d * self.c - self.a * self.f) / delta,
        )

    def commutator_scale(self) -> Q:
        """Coefficient multiplying [y,x] after affine substitution."""
        return self.a * self.e - self.b * self.d


def signed_double_area(p: Point, q_: Point, r: Point) -> Q:
    """Twice the signed area of triangle pqr."""
    qx, qy = q_[0] - p[0], q_[1] - p[1]
    rx, ry = r[0] - p[0], r[1] - p[1]
    return qx * ry - qy * rx


def trim(poly: Polynomial) -> Polynomial:
    """Remove irrelevant trailing zero coefficients."""
    result = list(poly)
    while len(result) > 1 and result[-1] == 0:
        result.pop()
    return result or [q(0)]


def poly_add(left: Sequence[Q], right: Sequence[Q]) -> Polynomial:
    size = max(len(left), len(right))
    return trim([
        (left[i] if i < len(left) else q(0))
        + (right[i] if i < len(right) else q(0))
        for i in range(size)
    ])


def poly_scale(scale: Q, poly: Sequence[Q]) -> Polynomial:
    return trim([scale * coefficient for coefficient in poly])


def multiply_by_t(poly: Sequence[Q]) -> Polynomial:
    """The operator x: p(t) -> t p(t)."""
    return [q(0), *poly]


def differentiate(poly: Sequence[Q]) -> Polynomial:
    """The operator y: p(t) -> p'(t)."""
    if len(poly) <= 1:
        return [q(0)]
    return trim([q(i) * poly[i] for i in range(1, len(poly))])


def affine_operator(
    x_coefficient: Q,
    y_coefficient: Q,
    constant: Q,
    poly: Sequence[Q],
) -> Polynomial:
    """Apply x_coefficient*x + y_coefficient*y + constant*1."""
    return poly_add(
        poly_add(
            poly_scale(x_coefficient, multiply_by_t(poly)),
            poly_scale(y_coefficient, differentiate(poly)),
        ),
        poly_scale(constant, poly),
    )


def transformed_commutator(fmap: AffineMap2D, poly: Sequence[Q]) -> Polynomial:
    """Apply [Y',X'] to a polynomial, where [u,v]=uv-vu."""
    x_prime = lambda p: affine_operator(fmap.a, fmap.b, fmap.c, p)
    y_prime = lambda p: affine_operator(fmap.d, fmap.e, fmap.f, p)
    return poly_add(y_prime(x_prime(poly)), poly_scale(q(-1), x_prime(y_prime(poly))))


def format_poly(poly: Sequence[Q]) -> str:
    """Format a coefficient list for compact terminal output."""
    terms: list[str] = []
    for power, coefficient in enumerate(trim(list(poly))):
        if coefficient == 0:
            continue
        variable = "" if power == 0 else ("t" if power == 1 else f"t^{power}")
        terms.append(f"{coefficient}{('*' + variable) if variable else ''}")
    return " + ".join(terms) if terms else "0"


def demonstrate_unit_determinant() -> None:
    fmap = AffineMap2D(q(2), q(1), q(5), q(3), q(2), q(-4))
    triangle = ((q(0), q(0)), (q(2), q(0)), (q(0), q(3)))
    transformed = tuple(fmap.apply(point) for point in triangle)
    before = signed_double_area(*triangle)
    after = signed_double_area(*transformed)
    point = (q(7), q(-2))
    recovered = fmap.inverse().apply(fmap.apply(point))

    print("Example 1: determinant-one affine map")
    print(f"  determinant = {fmap.determinant}")
    print(f"  signed double area: {before} -> {after}")
    print(f"  point round trip: {point} -> {recovered}")
    print(f"  commutator scale = {fmap.commutator_scale()}\n")


def demonstrate_operator_identity() -> None:
    fmap = AffineMap2D(q(2), q(1), q(5), q(3), q(2), q(-4))
    polynomials: Iterable[Polynomial] = (
        [q(1)],
        [q(2), q(-3), q(1)],
        [q(0), q(1), q(0), q(4)],
    )
    print("Example 2: Weyl relation on the polynomial operator model")
    for poly in polynomials:
        image = transformed_commutator(fmap, poly)
        expected = poly_scale(fmap.determinant, poly)
        assert image == expected
        print(f"  [Y',X']({format_poly(poly)}) = {format_poly(image)}")
    print()


def demonstrate_other_determinants() -> None:
    maps = (
        ("sixfold scaling", AffineMap2D(q(2), q(0), q(0), q(0), q(3), q(0))),
        ("singular collapse", AffineMap2D(q(1), q(2), q(0), q(2), q(4), q(0))),
    )
    sample = [q(1), q(2), q(3)]
    print("Example 3: nonunit and singular transformations")
    for name, fmap in maps:
        image = transformed_commutator(fmap, sample)
        expected = poly_scale(fmap.determinant, sample)
        assert image == expected
        print(
            f"  {name}: determinant {fmap.determinant}, "
            f"[Y',X']p = {format_poly(image)}"
        )
    print()


def main() -> None:
    demonstrate_unit_determinant()
    demonstrate_operator_identity()
    demonstrate_other_determinants()
    print("All exact rational checks passed.")


if __name__ == "__main__":
    main()
