#!/usr/bin/env python3
"""
Algorithms for Aboriginal Kinship Systems

Type-hinted implementations of the key algorithms from the kinship
group theory formalization.
"""

from typing import TypeAlias

Section: TypeAlias = tuple[int, ...]


def z2_add(a: int, b: int) -> int:
    """Addition in Z/2Z."""
    return (a + b) % 2


def section_add(s: Section, t: Section) -> Section:
    """Addition in the section group (Z/2Z)^k."""
    return tuple(z2_add(a, b) for a, b in zip(s, t))


def marriage_partner(s: Section, marriage_element: Section) -> Section:
    """Compute the marriage partner of section s.

    Args:
        s: A section encoded as a tuple in (Z/2Z)^k
        marriage_element: The marriage generator of the kinship system

    Returns:
        The unique section that s can marry
    """
    return section_add(s, marriage_element)


def descent(s: Section, descent_element: Section) -> Section:
    """Compute the child's section given parent section s.

    Args:
        s: Parent's section
        descent_element: The descent generator

    Returns:
        The child's section
    """
    return section_add(s, descent_element)


def kinship_distance(s: Section, t: Section) -> int:
    """Compute the kinship distance between two sections.

    The kinship distance is the Hamming weight of s - t in (Z/2Z)^k,
    which equals the minimum number of elementary kinship operations
    (marriage or descent) needed to transform s into t.

    Args:
        s, t: Sections in (Z/2Z)^k

    Returns:
        Non-negative integer kinship distance
    """
    diff = section_add(s, t)  # In Z/2Z, subtraction = addition
    return sum(1 for x in diff if x != 0)


def enumerate_sections(k: int) -> list[Section]:
    """Enumerate all 2^k sections of a k-generator kinship system.

    Args:
        k: Number of generators (dimension of the section group)

    Returns:
        List of all sections as tuples in (Z/2Z)^k
    """
    if k == 0:
        return [()]
    smaller = enumerate_sections(k - 1)
    return [s + (0,) for s in smaller] + [s + (1,) for s in smaller]


def find_marriage_cosets(
    sections: list[Section],
    marriage_element: Section,
) -> list[list[Section]]:
    """Decompose sections into marriage-compatible cosets.

    Each coset contains sections that are marriage partners of each other.
    Within a coset, any member can marry any other member.

    Args:
        sections: All sections of the kinship system
        marriage_element: The marriage generator

    Returns:
        List of cosets (each a list of sections)
    """
    identity = tuple(0 for _ in marriage_element)
    subgroup = [identity, marriage_element]

    visited: set[tuple[Section, ...]] = set()
    cosets: list[list[Section]] = []

    for s in sections:
        coset = tuple(sorted(section_add(s, g) for g in subgroup))
        if coset not in visited:
            visited.add(coset)
            cosets.append(list(coset))

    return cosets


def find_moieties(k: int) -> list[list[Section]]:
    """Find all moieties (subgroups of index 2) in (Z/2Z)^k.

    A moiety is a subgroup containing exactly half the sections.
    In (Z/2Z)^k, there are exactly 2^k - 1 such subgroups,
    corresponding to the non-zero linear functionals on GF(2)^k.

    Args:
        k: Dimension of the section group

    Returns:
        List of moieties (each a list of sections in the subgroup)
    """
    sections = enumerate_sections(k)
    identity = tuple(0 for _ in range(k))
    moieties: list[list[Section]] = []

    # Each non-zero vector in GF(2)^k defines a hyperplane (kernel of
    # the associated linear functional), which is a subgroup of index 2
    for normal in sections:
        if normal == identity:
            continue
        # Kernel of the linear functional x -> <normal, x> mod 2
        kernel = [
            s for s in sections
            if sum(a * b for a, b in zip(normal, s)) % 2 == 0
        ]
        if len(kernel) == len(sections) // 2:
            kernel_sorted = sorted(kernel)
            if kernel_sorted not in moieties:
                moieties.append(kernel_sorted)

    return moieties


def kinship_group_table(k: int) -> dict[tuple[Section, Section], Section]:
    """Compute the full group (Cayley) table for (Z/2Z)^k.

    Args:
        k: Dimension

    Returns:
        Dictionary mapping (s, t) to s + t
    """
    sections = enumerate_sections(k)
    return {(s, t): section_add(s, t) for s in sections for t in sections}


def verify_kinship_axioms(k: int) -> dict[str, bool]:
    """Verify all group axioms for the kinship group (Z/2Z)^k.

    Args:
        k: Dimension

    Returns:
        Dictionary of axiom names to verification results
    """
    sections = enumerate_sections(k)
    identity = tuple(0 for _ in range(k))

    results = {}

    # Closure
    results["closure"] = all(
        section_add(a, b) in sections
        for a in sections for b in sections
    )

    # Identity
    results["identity"] = all(
        section_add(s, identity) == s for s in sections
    )

    # Self-inverse (exponent 2)
    results["self_inverse"] = all(
        section_add(s, s) == identity for s in sections
    )

    # Commutativity
    results["commutativity"] = all(
        section_add(a, b) == section_add(b, a)
        for a in sections for b in sections
    )

    # Associativity
    results["associativity"] = all(
        section_add(section_add(a, b), c) == section_add(a, section_add(b, c))
        for a in sections for b in sections for c in sections
    )

    # Cardinality is power of 2
    results["card_power_of_2"] = len(sections) == 2 ** k

    return results


def encode_kinship_as_code(
    marriage_element: Section,
    descent_element: Section,
) -> list[Section]:
    """Encode a kinship system as a binary linear code.

    The codewords are all elements of the group generated by
    marriage and descent.

    Args:
        marriage_element: Marriage generator
        descent_element: Descent generator

    Returns:
        List of codewords (group elements)
    """
    k = len(marriage_element)
    identity = tuple(0 for _ in range(k))

    # Generate all combinations
    generated: set[Section] = {identity}
    to_process = [marriage_element, descent_element]

    while to_process:
        new_elem = to_process.pop()
        if new_elem not in generated:
            generated.add(new_elem)
            for existing in list(generated):
                combined = section_add(existing, new_elem)
                if combined not in generated:
                    to_process.append(combined)

    return sorted(generated)


if __name__ == "__main__":
    # Kariera system
    print("Kariera axiom verification:")
    for name, ok in verify_kinship_axioms(2).items():
        print(f"  {name}: {ok}")

    print(f"\nKariera moieties: {len(find_moieties(2))}")
    for i, m in enumerate(find_moieties(2)):
        print(f"  Moiety {i+1}: {m}")

    print(f"\nAranda moieties: {len(find_moieties(3))}")

    # Coding bridge
    code = encode_kinship_as_code((1, 0), (0, 1))
    print(f"\nKariera as code: {code}")
    print(f"Code size: {len(code)} = 2^2")
