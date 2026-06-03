def kernel_range_factorization(domain_card: int, kernel_card: int) -> int:
    assert domain_card % kernel_card == 0
    return domain_card // kernel_card