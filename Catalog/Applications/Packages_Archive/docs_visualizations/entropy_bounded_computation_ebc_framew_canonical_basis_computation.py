(
    cl: ClosureOp,
    universe: set[Element],
) -> list[tuple[Element, FrozenSet[Element]]]:
    """
    Compute the canonical residual basis of a closure operator.

    Corresponds to `canonicalBasis` and `IsCanonicalBasis` in the Lean formalization.

    Returns a list of (target, support) pairs representing all minimal generators.
    """
    basis: list[tuple[Element, FrozenSet[Element]]] = []
    for x in sorted(universe):
        for support in find_minimal_supports(cl, x, universe):
            basis.append((x, support))
    return basis


