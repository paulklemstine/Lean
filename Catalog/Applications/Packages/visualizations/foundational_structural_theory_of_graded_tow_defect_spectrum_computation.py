def compute_achievable_defect_spectrum(group_order: int) -> List[int]:
    divs = [i for i in range(1, group_order+1) if group_order % i == 0]
    return sorted(group_order - d for d in divs)