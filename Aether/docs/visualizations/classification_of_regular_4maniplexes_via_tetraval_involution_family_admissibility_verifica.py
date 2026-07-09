from typing import Dict, Hashable, List

Flag = Hashable
Involution = Dict[Flag, Flag]


def verify_involution_family(flags: List[Flag],
                             sigmas: List[Involution]) -> Dict[str, bool]:
    """Check the four involution-family axioms. O(n^2 * |flags|)."""
    involutive = all(s[s[x]] == x for s in sigmas for x in flags)
    fpf = all(s[x] != x for s in sigmas for x in flags)
    string = all(
        sigmas[i][sigmas[j][x]] == sigmas[j][sigmas[i][x]]
        for i in range(len(sigmas)) for j in range(len(sigmas))
        if abs(i - j) >= 2 for x in flags)
    sep = all(
        sigmas[i][v] != sigmas[j][v]
        for v in flags for i in range(len(sigmas))
        for j in range(len(sigmas)) if i != j)
    return {"involutive": involutive, "fixed_point_free": fpf,
            "string": string, "separation": sep,
            "is_valid_family": involutive and fpf and string and sep}
