from typing import Callable, List, Optional, Tuple

State = int
Block = bool

def claw_compress(g0: Callable[[State], State],
                  g1: Callable[[State], State]
                  ) -> Callable[[State, Block], State]:
    return lambda s, b: g1(s) if b else g0(s)

def attack_to_claw(
    g0: Callable[[State], State], g1: Callable[[State], State],
    iv: State, m1: List[Block], m2: List[Block]
) -> Tuple[State, State]:
    """Algorithm C (clawFree_mdHash_injOn_length, contrapositive): compose the
    MD extraction with the collision->claw map. An equal-length collision of the
    iterated Damgard hash becomes a claw, hence a solution to the hard problem."""
    from typing import Tuple as _T
    f = claw_compress(g0, g1)
    # --- inline Algorithm A ---
    def md(msg: List[Block]) -> State:
        s = iv
        for b in msg:
            s = f(s, b)
        return s
    a, b = list(m1), list(m2)
    while True:
        in1, in2 = (md(a[:-1]), a[-1]), (md(b[:-1]), b[-1])
        if in1 != in2:
            break
        a, b = a[:-1], b[:-1]
    # --- inline Algorithm B ---
    (s, bit), (s2, bit2) = in1, in2
    claw = (s, s2) if (bit is False and bit2 is True) else (s2, s)
    assert g0(claw[0]) == g1(claw[1])
    return claw
