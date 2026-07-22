(
    cl: ClosureOp,
    target: Element,
    universe: set[Element],
) -> list[FrozenSet[Element]]:
    """
    Find all minimal supports for a target element under a closure operator.

    Corresponds to `minimalSupports` and `IsMinimalSupport` in the Lean formalization.

    A set A is a minimal support for x if:
      1. x ∈ cl(A)
      2. For every proper subset B ⊊ A, x ∉ cl(B)
    """
    minimal: list[FrozenSet[Element]] = []
    elements = sorted(universe)

    # Check all subsets, smallest first, to find minimal supports
    for size in range(len(elements) + 1):
        for combo in combinations(elements, size):
            candidate = frozenset(combo)
            if target in cl(candidate):
                # Check minimality: no proper subset also generates target
                is_minimal = True
                for sub_size in range(size):
                    for sub_combo in combinations(list(candidate), sub_size):
                        if target in cl(frozenset(sub_combo)):
                            is_minimal = False
                            break
                    if not is_minimal:
                        break
                if is_minimal:
                    # Also check it's not a superset of an already-found minimal
                    if not any(m < candidate for m in minimal):
                        minimal.append(candidate)

    return minimal


