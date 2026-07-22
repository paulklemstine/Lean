from __future__ import annotations

def certify(d: int, s: int, area: int, genus: int, alpha: int, beta: int) -> tuple[bool, int]:
    valid = d == s and s*s <= alpha*area and area <= beta*genus
    slack = alpha*beta*genus - d*d
    return valid and slack >= 0, slack

if __name__ == "__main__":
    print(certify(12, 12, 96, 24, 2, 4))
