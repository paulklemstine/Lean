#!/usr/bin/env python3
"""Exact numerical demonstrations for the three-halves steering word."""

from __future__ import annotations

from collections import defaultdict
from typing import DefaultDict, Dict, List, Sequence, Tuple


def nearest_three_halves(n: int) -> int:
    """Return the nearest integer to (3/2)^n, using half-up ties exactly."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    if n == 0:
        return 1
    numerator = 3**n
    denominator = 2**n
    return (numerator + denominator // 2) // denominator


def rounded_orbit(last_index: int) -> List[int]:
    """Return m_0 through m_last_index using exact integer arithmetic."""
    if last_index < 0:
        return []
    return [nearest_three_halves(n) for n in range(last_index + 1)]


def steering_word(length: int) -> Tuple[List[int], List[int]]:
    """Return length steering symbols and the length+1 rounded states."""
    if length < 0:
        raise ValueError("length must be nonnegative")
    states = rounded_orbit(length)
    symbols = [2 * states[n + 1] - 3 * states[n] for n in range(length)]
    return states, symbols


def block_weight(symbols: Sequence[int], start: int, length: int) -> int:
    """Evaluate the weighted contribution of a steering block in O(length)."""
    if start < 0 or length < 0 or start + length > len(symbols):
        raise ValueError("requested block lies outside the symbol sequence")
    weight = 0
    power_of_two = 1
    for j in range(length):
        weight = 3 * weight + power_of_two * symbols[start + j]
        power_of_two *= 2
    return weight


def verify_endpoint(states: Sequence[int], symbols: Sequence[int],
                    start: int, length: int) -> bool:
    """Check 2^k m_(n+k) = 3^k m_n + W(n,k)."""
    left = 2**length * states[start + length]
    right = 3**length * states[start] + block_weight(symbols, start, length)
    return left == right


def factors(symbols: Sequence[int], length: int) -> Dict[Tuple[int, ...], List[int]]:
    """Map each distinct length-k factor to all starting positions in the prefix."""
    if length < 0 or length > len(symbols):
        raise ValueError("factor length must lie between zero and prefix length")
    occurrences: DefaultDict[Tuple[int, ...], List[int]] = defaultdict(list)
    for start in range(len(symbols) - length + 1):
        occurrences[tuple(symbols[start:start + length])].append(start)
    return dict(occurrences)


def repeated_block_identity(states: Sequence[int], a: int, b: int,
                            length: int) -> Tuple[int, int]:
    """Return both sides of the repeated-block rigidity identity."""
    left = 2**length * (states[a + length] - states[b + length])
    right = 3**length * (states[a] - states[b])
    return left, right


def zero_runs(symbols: Sequence[int]) -> List[Tuple[int, int]]:
    """List maximal zero runs as (starting position, length)."""
    runs: List[Tuple[int, int]] = []
    start = 0
    while start < len(symbols):
        if symbols[start] != 0:
            start += 1
            continue
        end = start
        while end < len(symbols) and symbols[end] == 0:
            end += 1
        runs.append((start, end - start))
        start = end
    return runs


def main() -> None:
    """Generate a prefix and demonstrate all finite-block theorems numerically."""
    prefix_length = 80
    states, symbols = steering_word(prefix_length)

    print("THREE-HALVES STEERING WORD: EXACT DEMONSTRATION")
    print("Rounded states m_0,...,m_12:", states[:13])
    print("Steering symbols t_0,...,t_11:", symbols[:12])
    print("Observed alphabet:", sorted(set(symbols)))
    assert set(symbols) <= {-2, -1, 0, 1, 2}

    print("\nEndpoint reconstruction checks:")
    for start, length in [(0, 3), (2, 8), (11, 17), (40, 20)]:
        weight = block_weight(symbols, start, length)
        valid = verify_endpoint(states, symbols, start, length)
        print(f"  start={start:2d}, length={length:2d}, weight={weight:>12d}, valid={valid}")
        assert valid

    print("\nFinite-prefix factor complexities (and five-letter ceilings):")
    for length in range(1, 11):
        complexity = len(factors(symbols, length))
        print(f"  k={length:2d}: observed={complexity:3d}, ceiling=5^k={5**length}")
        assert complexity <= 5**length

    print("\nRepeated-block rigidity examples:")
    shown = 0
    for length in range(1, 7):
        for block, positions in factors(symbols, length).items():
            if len(positions) >= 2:
                a, b = positions[0], positions[1]
                left, right = repeated_block_identity(states, a, b, length)
                print(f"  block={block}, positions=({a},{b}), sides=({left},{right})")
                assert left == right
                shown += 1
                break
        if shown >= 4:
            break

    print("\nZero-run divisibility checks:")
    for start, length in zero_runs(symbols):
        divisor = 2**length
        valid = states[start] % divisor == 0
        print(f"  start={start:2d}, length={length}, m_start={states[start]}, "
              f"divisible by {divisor}: {valid}")
        assert valid


if __name__ == "__main__":
    main()
