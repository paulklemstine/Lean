from __future__ import annotations


def in_H(n: int) -> bool:
    """H-membership predicate: n = 1 (mod 4)."""
    return n % 4 == 1


def closed_under_mult(limit: int) -> bool:
    """Verify exhaustively that H is closed under multiplication for all
    products of members below `limit`. Returns True iff closure holds.

    Correctness rests on the residue identity 1 * 1 = 1 (mod 4); this routine
    is an O(limit^2) empirical confirmation."""
    members = [n for n in range(1, limit) if in_H(n)]
    for a in members:
        for b in members:
            if not in_H(a * b):
                return False
    return True
