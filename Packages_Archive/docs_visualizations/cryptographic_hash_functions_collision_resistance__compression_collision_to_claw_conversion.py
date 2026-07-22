from typing import Tuple

State = int
Block = bool

def collision_to_claw(
    collision: Tuple[Tuple[State, Block], Tuple[State, Block]]
) -> Tuple[State, State]:
    """Algorithm B (clawCompress_collision_to_claw): a compression collision of
    clawCompress is turned into a claw using the differing block bits. For
    injective g0, g1 the same-bit cases cannot occur."""
    (s, b), (s2, b2) = collision
    if b == b2:
        raise ValueError("same-bit collision => a permutation is non-injective")
    return (s, s2) if (b is False and b2 is True) else (s2, s)
