from typing import Sequence

def evaluate_with_witness(message: Sequence[float], key: Sequence[float]) -> tuple[float, int]:
    if not message or len(message) != len(key):
        raise ValueError("nonempty equal-length vectors required")
    witness = min(range(len(message)), key=lambda i: message[i] + key[i])
    return message[witness] + key[witness], witness
