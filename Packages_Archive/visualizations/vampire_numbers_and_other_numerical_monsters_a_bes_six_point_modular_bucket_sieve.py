from typing import List, Tuple

def residue_curve(modulus: int = 9) -> List[Tuple[int, int]]:
    return [(x, y) for x in range(modulus) for y in range(modulus)
            if ((x - 1) * (y - 1) - 1) % modulus == 0]

if __name__ == "__main__":
    points = residue_curve()
    print(points)
    print({(x * y) % 9 for x, y in points if (x, y) in {(2, 2), (5, 8), (8, 5)}})

# Use the returned points as bucket-pair keys before exact digit testing.
