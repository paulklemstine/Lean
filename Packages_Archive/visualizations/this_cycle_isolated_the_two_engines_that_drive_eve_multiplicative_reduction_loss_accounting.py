from typing import Sequence


def composed_loss(losses: Sequence[float]) -> float:
    """
    End-to-end loss factor of a reduction pipeline.

    If stage j satisfies adv_{j} <= losses[j] * adv_{j-1} with each
    losses[j] >= 0, then adv_k <= (prod_j losses[j]) * adv_0. Losses multiply.
    """
    product = 1.0
    for l in losses:
        assert l >= 0.0, "non-negative losses preserve the inequality direction"
        product *= l
    return product
