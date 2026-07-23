from typing import Callable, Sequence

def lagrange_readout(
    phi: Callable[[float], float],
    inputs: Sequence[float],
    labels: Sequence[int],
) -> Callable[[float], float]:
    """Build N(x) = p(phi(x)) exactly realizing arbitrary labels on distinct inputs.

    Complexity: O(n) per evaluation node, O(n^2) to score the whole sample.
    """
    nodes = [phi(x) for x in inputs]
    assert len(set(nodes)) == len(nodes), "feature map not injective on sample"

    def net(x: float) -> float:
        t = phi(x)
        total = 0.0
        for i in range(len(nodes)):
            term = float(labels[i])
            for j in range(len(nodes)):
                if j != i:
                    term *= (t - nodes[j]) / (nodes[i] - nodes[j])
            total += term
        return total

    return net
