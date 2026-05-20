import math
from typing import List

class BoundedShrinkageVerifier:
    """Verifies bounded-shrinkage properties and produces certificates."""
    def certify(self, chain_cards: List[int], B: int) -> dict:
        k = len(chain_cards) - 1
        for i in range(k):
            if chain_cards[i] > B * chain_cards[i+1]:
                return {"valid": False, "reason": f"Step {i} violates bound"}
        
        mult_bound = B**k * chain_cards[-1]
        ratio = chain_cards[0] / chain_cards[-1] if chain_cards[-1] > 0 else float("inf")
        lb = math.log(chain_cards[0] // chain_cards[-1], B) if B > 1 and chain_cards[-1] > 0 else 0
        
        return {
            "valid": True,
            "k": k, "B": B,
            "multiplicative_bound": mult_bound,
            "lower_bound": lb,
            "bound_satisfied": k >= lb,
        }

# Example
v = BoundedShrinkageVerifier()
cert = v.certify([256, 128, 64, 32, 16, 8, 4, 2, 1], B=2)
print(f"Chain length: {cert['k']}")
print(f"Lower bound: {cert['lower_bound']:.1f}")
print(f"Bound satisfied: {cert['bound_satisfied']}")
