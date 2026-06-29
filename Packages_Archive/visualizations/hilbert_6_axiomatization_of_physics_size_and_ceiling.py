from typing import Any

def size(e: Any) -> int:
    tag = e[0]
    if tag in ("zero", "one", "atom"):
        return 1
    if tag in ("add", "mul"):
        return size(e[1]) + size(e[2])
    if tag == "rev":
        return size(e[1])
    raise ValueError(tag)

def canonicalization_ceiling(e: Any) -> int:
    """The verified a-priori upper bound on the normal-form word count."""
    return 2 ** size(e)
