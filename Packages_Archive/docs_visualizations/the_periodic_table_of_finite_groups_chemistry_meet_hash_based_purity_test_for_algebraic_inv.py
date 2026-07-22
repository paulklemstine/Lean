from dataclasses import dataclass
from typing import Hashable, Iterable

@dataclass(frozen=True)
class Record:
    name: str
    fingerprint: tuple[Hashable, ...]
    label: bool

def impure_buckets(records: Iterable[Record]) -> dict[tuple[Hashable, ...], set[bool]]:
    buckets: dict[tuple[Hashable, ...], set[bool]] = {}
    for record in records:
        buckets.setdefault(record.fingerprint, set()).add(record.label)
    return {key: values for key, values in buckets.items() if len(values) > 1}

if __name__ == "__main__":
    data = [Record("C6", (6, 6), True), Record("D6", (6, 6), False)]
    print(impure_buckets(data))
