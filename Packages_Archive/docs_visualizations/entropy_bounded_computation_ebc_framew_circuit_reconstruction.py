(
    cl: ClosureOp,
    universe: set[Element],
) -> dict[Element, MonotoneCircuit]:
    """
    Reconstruct a monotone DNF circuit from a closure operator.

    Corresponds to `reconstructClosureCircuit` in the Lean formalization.

    For each target x, builds: ⋁_{A ∈ minSupp(x)} ⋀_{a ∈ A} input(a)
    """
    circuits: dict[Element, MonotoneCircuit] = {}
    for x in sorted(universe):
        supports = find_minimal_supports(cl, x, universe)
        conjunctions = [conj_of_list(sorted(support)) for support in supports]
        circuits[x] = disj_of_list(conjunctions)
    return circuits


