#!/usr/bin/env python3
"""Numerical illustrations of finite discovery schedules and diagonalization."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Iterable, Sequence


Batch = set[int]
Schedule = Callable[[int], Batch]


def discovered_by(schedule: Schedule, deadline: int) -> Batch:
    """Return the union of batches from stage 0 through ``deadline``."""
    if deadline < 0:
        return set()
    archive: Batch = set()
    for stage in range(deadline + 1):
        archive.update(schedule(stage))
    return archive


def cumulative_batch_bound(schedule: Schedule, deadline: int) -> tuple[int, int]:
    """Return (distinct archive size, sum of batch sizes) through a deadline."""
    batches = [schedule(stage) for stage in range(deadline + 1)]
    return len(set().union(*batches) if batches else set()), sum(map(len, batches))


def explicit_missing_code(archive: Iterable[int]) -> int:
    """Construct m = sum(x + 1), a natural number absent from a finite archive."""
    finite_archive = set(archive)
    if any(x < 0 for x in finite_archive):
        raise ValueError("The archive must contain natural-number codes only.")
    witness = sum(x + 1 for x in finite_archive)
    assert witness not in finite_archive
    return witness


def enumeration_schedule(stage: int) -> Batch:
    """Discover exactly code n at stage n."""
    if stage < 0:
        raise ValueError("Stages are natural numbers.")
    return {stage}


def dyson_rate(stage: int) -> int:
    """Compute the illustrative double-exponential rate 2^(2^n)."""
    if stage < 0:
        raise ValueError("Stages are natural numbers.")
    return 2 ** (2**stage)


def finite_corpus_deadline(discovery_times: dict[int, int]) -> int:
    """Return the maximum discovery time for a finite corpus (0 if empty)."""
    if any(time < 0 for time in discovery_times.values()):
        raise ValueError("Discovery times must be natural numbers.")
    return max(discovery_times.values(), default=0)


def diagonal_bits(rows: Sequence[Sequence[bool]]) -> list[bool]:
    """Negate the diagonal of a finite Boolean table.

    The table must have at least as many columns in every row as it has rows.
    The output differs from row i at coordinate i.
    """
    size = len(rows)
    if any(len(row) < size for row in rows):
        raise ValueError("Every row must have at least len(rows) entries.")
    result = [not rows[i][i] for i in range(size)]
    assert all(result[i] != rows[i][i] for i in range(size))
    return result


@dataclass(frozen=True)
class GrowthRow:
    stage: int
    exponential: int
    double_exponential: int


def growth_table(max_stage: int) -> list[GrowthRow]:
    """Tabulate 2^n and 2^(2^n) through ``max_stage``."""
    if max_stage < 0:
        return []
    return [GrowthRow(n, 2**n, dyson_rate(n)) for n in range(max_stage + 1)]


def main() -> None:
    print("GROWTH PROFILES")
    print("stage | 2^n | 2^(2^n)")
    for row in growth_table(6):
        print(f"{row.stage:>5} | {row.exponential:>3} | {row.double_exponential}")

    deadline = 12
    archive = discovered_by(enumeration_schedule, deadline)
    distinct, batch_sum = cumulative_batch_bound(enumeration_schedule, deadline)
    missing = explicit_missing_code(archive)
    print("\nFINITE DEADLINE")
    print(f"By stage {deadline}: {sorted(archive)}")
    print(f"Distinct discoveries = {distinct}; sum of batch sizes = {batch_sum}")
    print(f"Explicit missing-code certificate = {missing}")
    print(f"Code 100 is nevertheless discovered later, at stage {100}.")

    corpus_times = {7: 4, 11: 9, 42: 6}
    common_deadline = finite_corpus_deadline(corpus_times)
    print("\nFINITE CORPUS")
    print(f"Discovery times: {corpus_times}")
    print(f"Common deadline: {common_deadline}")

    rows = [
        [False, False, True, True],
        [True, False, True, False],
        [True, True, True, False],
        [False, True, False, True],
    ]
    diagonal = diagonal_bits(rows)
    print("\nFINITE DIAGONALIZATION")
    print("Rows:", [[int(value) for value in row] for row in rows])
    print("Negated diagonal:", [int(value) for value in diagonal])
    for index, row in enumerate(rows):
        print(
            f"Output differs from row {index} at coordinate {index}: "
            f"{int(diagonal[index])} != {int(row[index])}"
        )


if __name__ == "__main__":
    main()
