from __future__ import annotations
import math

def nats_to_bits(nats: float) -> float:
    """Convert an information quantity from nats to bits (divide by log 2)."""
    return nats / math.log(2.0)

def landauer_bits(n: int) -> float:
    """tps_landauer_bits: unit-temperature cost of resolving the uniform prior
    over n outcomes, in bits. Equals log2(n) exactly. O(1)."""
    cost_nats = math.log(n)          # T=1, H(uniform)-H(point mass) = log n - 0
    return nats_to_bits(cost_nats)
