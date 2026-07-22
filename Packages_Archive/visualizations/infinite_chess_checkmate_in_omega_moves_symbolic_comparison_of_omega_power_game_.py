from dataclasses import dataclass

@dataclass(frozen=True)
class OmegaPower:
    exponent: int | None

def compare(a: OmegaPower, b: OmegaPower) -> int:
    if a.exponent is None:
        return 0 if b.exponent is None else 1
    if b.exponent is None:
        return -1
    return (a.exponent > b.exponent) - (a.exponent < b.exponent)

if __name__ == "__main__":
    print(compare(OmegaPower(3), OmegaPower(None)))
