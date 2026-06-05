#!/usr/bin/env python3
"""
Cryptographic Hash Function Algorithms

Type-hinted implementations of the Merkle-Damgård construction,
strengthened MD, prefix-free encoding, and collision-finding algorithms.
"""

from typing import List, Tuple, Optional, Callable, Dict, TypeVar, Generic
from dataclasses import dataclass
import struct

S = TypeVar('S')
B = TypeVar('B')


@dataclass
class CompressCollision:
    """A collision in a compression function: two distinct inputs yielding the same output."""
    s1: int
    b1: int
    s2: int
    b2: int
    output: int

    def __post_init__(self) -> None:
        assert (self.s1, self.b1) != (self.s2, self.b2), "Inputs must differ"


@dataclass
class MDCollision:
    """A collision in the full MD hash."""
    m1: List[int]
    m2: List[int]
    hash_value: int

    def __post_init__(self) -> None:
        assert self.m1 != self.m2, "Messages must differ"


def md_chain(
    compress: Callable[[int, int], int],
    iv: int,
    message: List[int]
) -> int:
    """
    Merkle-Damgård chain computation.

    Iteratively applies the compression function to process a list of
    message blocks, starting from the initialization vector.

    Algorithm:
        h₀ ← iv
        for i = 1 to n:
            hᵢ ← compress(hᵢ₋₁, mᵢ)
        return hₙ

    Args:
        compress: Compression function f: S × B → S
        iv: Initialization vector
        message: List of message blocks

    Returns:
        The hash value (final chain state)
    """
    state = iv
    for block in message:
        state = compress(state, block)
    return state


def md_chain_with_trace(
    compress: Callable[[int, int], int],
    iv: int,
    message: List[int]
) -> Tuple[int, List[int]]:
    """
    MD chain with full intermediate state trace.
    Returns (final_hash, [h₀, h₁, ..., hₙ]).
    """
    states = [iv]
    state = iv
    for block in message:
        state = compress(state, block)
        states.append(state)
    return state, states


def md_strengthened(
    compress: Callable[[int, int], int],
    iv: int,
    len_encode: Callable[[int], int],
    message: List[int]
) -> int:
    """
    Strengthened Merkle-Damgård: appends message length before hashing.

    Algorithm:
        padded ← message || [len_encode(|message|)]
        return md_chain(compress, iv, padded)

    This prevents length extension attacks (as used in SHA-256).
    """
    padded = message + [len_encode(len(message))]
    return md_chain(compress, iv, padded)


def md_finalized(
    compress: Callable[[int, int], int],
    finalize: Callable[[int], int],
    iv: int,
    message: List[int]
) -> int:
    """
    Finalized Merkle-Damgård: applies a finalization function to the output.

    Algorithm:
        h ← md_chain(compress, iv, message)
        return finalize(h)
    """
    return finalize(md_chain(compress, iv, message))


def collision_reduction(
    compress: Callable[[int, int], int],
    iv: int,
    m1: List[int],
    m2: List[int]
) -> Optional[CompressCollision]:
    """
    Merkle-Damgård collision reduction algorithm.

    Given two same-length messages that collide under the MD hash,
    finds a collision in the underlying compression function.

    Algorithm:
        Compute full state traces for both messages
        Walk backward from the end:
            If (sᵢ, bᵢ) ≠ (sᵢ', bᵢ') but compress(sᵢ, bᵢ) = compress(sᵢ', bᵢ'):
                return collision (sᵢ, bᵢ, sᵢ', bᵢ')
            If sᵢ ≠ sᵢ':
                continue backward (the divergence is earlier)

    Args:
        compress: Compression function
        iv: Initialization vector
        m1, m2: Two colliding same-length messages

    Returns:
        A CompressCollision, or None if messages don't actually collide
    """
    if len(m1) != len(m2):
        return None

    _, trace1 = md_chain_with_trace(compress, iv, m1)
    _, trace2 = md_chain_with_trace(compress, iv, m2)

    if trace1[-1] != trace2[-1]:
        return None  # Not actually a collision

    for i in range(len(m1) - 1, -1, -1):
        s1, b1 = trace1[i], m1[i]
        s2, b2 = trace2[i], m2[i]
        if (s1, b1) != (s2, b2):
            return CompressCollision(
                s1=s1, b1=b1, s2=s2, b2=b2,
                output=compress(s1, b1)
            )

    return None  # Messages are identical


def birthday_attack(
    hash_fn: Callable[[List[int]], int],
    block_range: int = 256,
    max_msg_len: int = 4,
    max_attempts: int = 1_000_000
) -> Optional[MDCollision]:
    """
    Birthday attack: find a collision by random sampling.

    Expected to succeed after O(√N) attempts where N is the hash output space.

    Algorithm:
        table ← empty dictionary
        repeat:
            m ← random message
            h ← hash(m)
            if h in table and table[h] ≠ m:
                return collision (m, table[h])
            table[h] ← m
    """
    import random
    seen: Dict[int, List[int]] = {}

    for _ in range(max_attempts):
        length = random.randint(1, max_msg_len)
        msg = [random.randint(0, block_range - 1) for _ in range(length)]
        h = hash_fn(msg)

        if h in seen and seen[h] != msg:
            return MDCollision(m1=msg, m2=seen[h], hash_value=h)
        seen[h] = msg

    return None


def prefix_free_encode(
    len_encode: Callable[[int], int],
    message: List[int]
) -> List[int]:
    """
    Prefix-free encoding by length prepending.

    Algorithm:
        return [len_encode(|message|)] || message

    If len_encode is injective, this encoding is prefix-free:
    no encoded message is a prefix of another.
    """
    return [len_encode(len(message))] + message


def verify_collision_reduction(
    compress: Callable[[int, int], int],
    iv: int,
    num_trials: int = 1000
) -> Tuple[int, int]:
    """
    Empirically verify the collision reduction theorem.

    Finds MD collisions via birthday attack and verifies that each
    one yields a valid compression collision via the reduction.

    Returns:
        (num_collisions_found, num_reductions_successful)
    """
    import random

    found = 0
    reduced = 0

    hash_fn = lambda msg: md_chain(compress, iv, msg)

    for _ in range(num_trials):
        collision = birthday_attack(hash_fn, block_range=16, max_msg_len=3, max_attempts=1000)
        if collision is not None:
            found += 1
            # Apply the reduction
            cc = collision_reduction(compress, iv, collision.m1, collision.m2)
            if cc is not None:
                # Verify the compression collision
                assert compress(cc.s1, cc.b1) == compress(cc.s2, cc.b2)
                assert (cc.s1, cc.b1) != (cc.s2, cc.b2)
                reduced += 1

    return found, reduced


if __name__ == "__main__":
    # Simple compression function for testing
    def test_compress(s: int, b: int) -> int:
        return (s * 31 + b) % (2**8)  # 8-bit output for easy collisions

    iv = 0

    print("Testing Merkle-Damgård algorithms")
    print("=" * 50)

    # Test basic chain
    msg = [1, 2, 3, 4]
    h = md_chain(test_compress, iv, msg)
    print(f"MD({msg}) = {h}")

    # Test strengthened MD
    h_str = md_strengthened(test_compress, iv, lambda n: n, msg)
    print(f"MD_strengthened({msg}) = {h_str}")

    # Test collision finding and reduction
    print("\nFinding collisions and verifying reductions...")
    found, reduced = verify_collision_reduction(test_compress, iv, num_trials=100)
    print(f"  Collisions found: {found}")
    print(f"  Successfully reduced: {reduced}")
    print(f"  Reduction success rate: {reduced/max(found,1)*100:.0f}%")
