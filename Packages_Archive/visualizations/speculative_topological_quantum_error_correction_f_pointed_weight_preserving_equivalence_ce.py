from __future__ import annotations
from typing import Hashable, Mapping

def is_weighted_isometry(
    source: Mapping[Hashable, int], target: Mapping[Hashable, int],
    source_zero: Hashable, target_zero: Hashable,
    mapping: Mapping[Hashable, Hashable],
) -> bool:
    return (set(mapping) == set(source)
            and set(mapping.values()) == set(target)
            and len(set(mapping.values())) == len(mapping)
            and mapping[source_zero] == target_zero
            and all(source[x] == target[mapping[x]] for x in source))

if __name__ == "__main__":
    logical = {"I": 0, "Lx": 7, "Lz": 5, "Lxz": 9}
    homology = {"0": 0, "a": 5, "b": 7, "a+b": 9}
    f = {"I": "0", "Lx": "b", "Lz": "a", "Lxz": "a+b"}
    print(is_weighted_isometry(logical, homology, "I", "0", f))
