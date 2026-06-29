from typing import List

def mps_bond_phi_bound(bond_dimensions: List[int]) -> int:
    """Upper bound on Phi from MPS geometry alone (no SVD).

    Realizes the theorem phi_mps_le_bond: an MPS whose minimal bond across any
    cut has dimension D satisfies Phi <= D - 1. The cheapest cut is the bond
    with the smallest dimension.
    """
    if not bond_dimensions:
        raise ValueError("an MPS on >= 2 sites has at least one bond")
    return max(min(bond_dimensions) - 1, 0)

# Example: bonds (4, 2, 3) -> minimal bond 2 -> Phi <= 1.
print(mps_bond_phi_bound([4, 2, 3]))
