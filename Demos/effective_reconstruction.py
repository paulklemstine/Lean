"""
Effective reconstruction: numerical demonstrations.
===================================================

A *channel* is a map  obs : N -> N  from hidden states to observable records.
A *quantity*  f : N -> N  is fibre constant along obs when
    obs(x) == obs(y)  implies  f(x) == f(y).
A *decoder* is  dec : N -> N  with  dec(obs(x)) == f(x)  for all x.
A *selector* is  sel : N -> N  with  obs(sel(obs(x))) == obs(x)  for all x.

This script demonstrates, numerically and on finite windows:

  1. Fibre constancy is exactly decodability (set-theoretic level).
  2. Selection composes to decoding:  f o sel  decodes f.
  3. The canonical representative  r(n) = least m with obs(m) == obs(n)
     is total, computable, fibre constant, and every decoder for it is a
     selector -- it is *complete* for effective decoding.
  4. Effective selection == decidability of the emitted-record set.
  5. The stage-s approximate decoder converges with modulus s > x, so decoders
     are always limit-computable (one jump above computable).
  6. The diagonal trace channel: a channel whose records determine the quantity
     (determinism) yet whose decoder diagonalises away.  Simulated on a toy
     universal machine, with the least-preimage ("least halting trace")
     function exhibiting the irregular growth that blocks any computable bound.
  7. The finite patching principle and the effective Fano bound: a decoder wrong
     on finitely many records is repairable, so an unrepairable channel forces
     infinitely many errors.

Self-contained: standard library only.  Run with `python3 demo.py`.
"""

from __future__ import annotations

import math
from typing import Callable, Dict, List, Optional, Set, Tuple

Channel = Callable[[int], int]
Quantity = Callable[[int], int]
Decoder = Callable[[int], int]
Selector = Callable[[int], int]


# ----------------------------------------------------------------------------
# 0.  Pairing, and basic channel utilities
# ----------------------------------------------------------------------------

def pair(a: int, b: int) -> int:
    """Cantor pairing bijection N x N -> N."""
    s = a + b
    return s * (s + 1) // 2 + b


def unpair(n: int) -> Tuple[int, int]:
    """Inverse of `pair`."""
    s = (math.isqrt(8 * n + 1) - 1) // 2
    while s * (s + 1) // 2 > n:
        s -= 1
    while (s + 1) * (s + 2) // 2 <= n:
        s += 1
    b = n - s * (s + 1) // 2
    return s - b, b


def is_fibre_constant(obs: Channel, f: Quantity, window: int) -> bool:
    """Check fibre constancy of f along obs on the states 0..window-1."""
    seen: Dict[int, int] = {}
    for x in range(window):
        m = obs(x)
        if m in seen and seen[m] != f(x):
            return False
        seen[m] = f(x)
    return True


def decodes(obs: Channel, f: Quantity, dec: Decoder, window: int) -> bool:
    """Check dec(obs(x)) == f(x) on the states 0..window-1."""
    return all(dec(obs(x)) == f(x) for x in range(window))


def is_selector(obs: Channel, sel: Selector, window: int) -> bool:
    """Check obs(sel(obs(x))) == obs(x) on the states 0..window-1."""
    return all(obs(sel(obs(x))) == obs(x) for x in range(window))


# ----------------------------------------------------------------------------
# 1.  The canonical representative  r(n) = least m with obs(m) == obs(n)
# ----------------------------------------------------------------------------

def canonical_representative(obs: Channel, n: int) -> int:
    """Least m with obs(m) == obs(n).

    The search is unbounded in principle but *always* succeeds: m = n is a
    witness, so it terminates within n + 1 channel evaluations.  This is why the
    canonical representative is a total computable quantity on every computable
    channel, even one whose range is undecidable.
    """
    target = obs(n)
    m = 0
    while True:                     # guaranteed to stop at m <= n
        if obs(m) == target:
            return m
        m += 1


def guarded_selector(obs: Channel, in_range: Callable[[int], bool]) -> Selector:
    """Selector from a decision procedure for the emitted-record set.

    Off the range the search would diverge, so it is guarded: records that are
    never emitted are answered immediately with 0.
    """
    def sel(t: int) -> int:
        if not in_range(t):
            return 0
        n = 0
        while obs(n) != t:
            n += 1
        return n
    return sel


def bounded_selector(obs: Channel, bound: Callable[[int], int]) -> Selector:
    """Selector from a computable budget on the preimage search (Algorithm B)."""
    def sel(t: int) -> int:
        b = bound(t)
        for n in range(b + 1):
            if obs(n) == t:
                return n
        return b
    return sel


# ----------------------------------------------------------------------------
# 2.  The stage-s approximate decoder (limit computability, one jump)
# ----------------------------------------------------------------------------

def approx_decoder(obs: Channel, f: Quantity, m: int, s: int) -> int:
    """Scan states 0..s-1, keep f(k) for the last k with obs(k) == m, else 0.

    Correct at (obs(x), s) for every s > x: the modulus of convergence is
    "any preimage of the received record".
    """
    value = 0
    for k in range(s):
        if obs(k) == m:
            value = f(k)
    return value


def first_correct_stage(obs: Channel, f: Quantity, x: int, cap: int) -> Optional[int]:
    """Smallest s <= cap with approx_decoder(obs, f, obs(x), s) == f(x)."""
    for s in range(cap + 1):
        if approx_decoder(obs, f, obs(x), s) == f(x):
            return s
    return None


# ----------------------------------------------------------------------------
# 3.  Finite patching and repair (effective Fano bound)
# ----------------------------------------------------------------------------

def patch(dec: Decoder, corrections: Dict[int, int]) -> Decoder:
    """Overwrite a decoder at finitely many records; still computable."""
    table = dict(corrections)

    def patched(y: int) -> int:
        return table[y] if y in table else dec(y)
    return patched


def error_states(obs: Channel, f: Quantity, dec: Decoder, window: int) -> List[int]:
    """States below `window` that the decoder misreconstructs."""
    return [n for n in range(window) if dec(obs(n)) != f(n)]


def error_records(obs: Channel, f: Quantity, dec: Decoder, window: int) -> List[int]:
    """Distinct records below the window on which the decoder is wrong."""
    bad: Set[int] = set()
    for n in range(window):
        if dec(obs(n)) != f(n):
            bad.add(obs(n))
    return sorted(bad)


def repair(obs: Channel, f: Quantity, dec: Decoder, window: int) -> Decoder:
    """Repair a decoder whose errors on the window are finite (Repair Lemma).

    Fibre constancy makes the correct value on each bad record well defined.
    """
    corrections: Dict[int, int] = {}
    for n in range(window):
        if dec(obs(n)) != f(n):
            corrections[obs(n)] = f(n)
    return patch(dec, corrections)


# ----------------------------------------------------------------------------
# 4.  A toy universal machine, and the diagonal trace channel
# ----------------------------------------------------------------------------
#
# Programs are finite lists of instructions over two registers (a, b):
#     0 : a += 1
#     1 : a -= 1  (floor at 0)
#     2 : if a == 0 jump to instruction 0 else fall through
#     3 : b += a; halt
#     4 : loop forever
# A program is coded by a natural number in base 5 (little-endian digits).
# `step_run(code, inp, steps)` runs it for at most `steps` instructions.

HALT_OUTPUT_INSTR = 3
MAX_STEPS_GUARD = 4096


def decode_program(code: int) -> List[int]:
    """Base-5 digits of `code`, little-endian, as an instruction list."""
    if code == 0:
        return [0]
    instrs: List[int] = []
    while code > 0:
        instrs.append(code % 5)
        code //= 5
    return instrs


def step_run(code: int, inp: int, steps: int) -> Optional[int]:
    """Run program `code` on input `inp` for at most `steps` steps.

    Returns the output if it halts within the budget, else None.  This is a
    total computable function of (code, inp, steps) -- the step-bounded
    evaluation on which the diagonal trace channel is built.
    """
    prog = decode_program(code)
    a, b, pc = inp, 0, 0
    for _ in range(steps):
        if pc >= len(prog):
            return a                      # falling off the end halts
        instr = prog[pc]
        if instr == 0:
            a += 1
            pc += 1
        elif instr == 1:
            a = max(0, a - 1)
            pc += 1
        elif instr == 2:
            pc = 0 if a == 0 else pc + 1
        elif instr == HALT_OUTPUT_INSTR:
            return b + a
        else:
            pc = pc                       # loop forever
    return None


def obs_diag(n: int) -> int:
    """Diagonal trace channel: record a+1 if machine a self-halts in s steps, else 0."""
    a, s = unpair(n)
    return a + 1 if step_run(a, a, s) is not None else 0


def f_diag(n: int) -> int:
    """The quantity: the halting value, shifted so the blank record is unambiguous."""
    a, s = unpair(n)
    out = step_run(a, a, s)
    return 0 if out is None else out + 1


def least_halting_trace(a: int, cap: int = MAX_STEPS_GUARD) -> Optional[int]:
    """Least step budget s with machine a halting on input a within s steps."""
    for s in range(cap + 1):
        if step_run(a, a, s) is not None:
            return s
    return None


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def banner(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_1_fibre_constancy() -> None:
    banner("1.  Fibre constancy is exactly decodability")

    obs: Channel = lambda n: n % 6                 # record = residue mod 6
    good: Quantity = lambda n: (n % 6) ** 2        # fibre constant
    bad: Quantity = lambda n: n                    # not fibre constant

    print("channel obs(n) = n mod 6")
    print("  quantity g(n) = (n mod 6)^2   fibre constant:",
          is_fibre_constant(obs, good, 200))
    print("  quantity h(n) = n             fibre constant:",
          is_fibre_constant(obs, bad, 200))

    sel = bounded_selector(obs, lambda t: 5)
    print("  bounded selector sel(t) = least n <= 5 with n mod 6 == t is a selector:",
          is_selector(obs, sel, 200))
    dec: Decoder = lambda m: good(sel(m))
    print("  therefore g o sel decodes g:", decodes(obs, good, dec, 200))
    print("  and h, not being fibre constant, has no decoder at all:")
    print("    obs(1) == obs(7) but h(1)=1 != 7=h(7)")


def demo_2_canonical_representative() -> None:
    banner("2.  The canonical representative is complete for effective decoding")

    obs: Channel = lambda n: (n * n) % 10          # records = squares mod 10
    rep: Quantity = lambda n: canonical_representative(obs, n)

    print("channel obs(n) = n^2 mod 10")
    print("  n      :", [n for n in range(12)])
    print("  obs(n) :", [obs(n) for n in range(12)])
    print("  r(n)   :", [rep(n) for n in range(12)])
    print("  r is fibre constant:", is_fibre_constant(obs, rep, 300))
    print("  r lands in the same fibre for all n < 300:",
          all(obs(rep(n)) == obs(n) for n in range(300)))

    # Any decoder for r is a selector.
    records = sorted({obs(n) for n in range(300)})
    table = {m: rep(next(n for n in range(300) if obs(n) == m)) for m in records}
    dec: Decoder = lambda m: table.get(m, 0)
    print("  a decoder for r:", {m: table[m] for m in records})
    print("  it decodes r:", decodes(obs, rep, dec, 300))
    print("  and it IS a selector:", is_selector(obs, dec, 300))

    # Search cost is bounded by the input state itself.
    costs = [rep(n) for n in range(60)]
    print("  search for r(n) never looks past m = n; here max m reached =",
          max(costs), "over n < 60")


def demo_3_selection_is_range_decidability() -> None:
    banner("3.  Effective selection == decidability of the emitted-record set")

    # A channel whose range is the even numbers: decidable, so a selector exists.
    obs_even: Channel = lambda n: 2 * n
    sel = guarded_selector(obs_even, lambda t: t % 2 == 0)
    print("channel obs(n) = 2n, range = evens (decidable)")
    print("  guarded selector is a selector:", is_selector(obs_even, sel, 200))
    print("  a selector certifies the range:  t in range  <=>  obs(sel(t)) == t")
    checks = [(t, obs_even(sel(t)) == t, any(obs_even(n) == t for n in range(200)))
              for t in range(10)]
    for t, certified, truth in checks:
        print(f"    t={t}: certificate says {certified}, truth is {truth}")

    # A channel of finite rate: range finite, hence decidable, hence decodable.
    obs_fin: Channel = lambda n: min(n, 4)
    rng = sorted({obs_fin(n) for n in range(500)})
    sel_fin = guarded_selector(obs_fin, lambda t: t in set(rng))
    print(f"\nfinite-rate channel obs(n) = min(n,4), range = {rng}")
    print("  selector exists:", is_selector(obs_fin, sel_fin, 500))
    print("  so every computable fibre-constant quantity is effectively decodable.")


def demo_4_one_jump() -> None:
    banner("4.  Decoders are always limit-computable: modulus s > x")

    obs: Channel = lambda n: n % 7
    f: Quantity = lambda n: 3 * (n % 7) + 1
    print("channel obs(n) = n mod 7, quantity f(n) = 3(n mod 7) + 1")
    print("  fibre constant:", is_fibre_constant(obs, f, 300))
    print("\n   x   obs(x)   f(x)   stage at which the approximation first locks on")
    for x in range(10):
        s = first_correct_stage(obs, f, x, 60)
        print(f"  {x:2d}    {obs(x):4d}   {f(x):4d}          {s}")
    ok = all(approx_decoder(obs, f, obs(x), s) == f(x)
             for x in range(30) for s in range(x + 1, x + 12))
    print("\n  modulus verified: A(obs(x), s) == f(x) for all x < 30 and x < s < x+12:", ok)


def demo_5_diagonal_channel() -> None:
    banner("5.  The diagonal trace channel: determined but not computable")

    print("States are traces <a,s>: run machine a on input a for s steps.")
    print("Record  = a+1 if it halted, else 0.   Quantity = halting value + 1.")
    print("The record says WHICH machine self-halted, never WHAT it computed.\n")

    print("  state n   (a, s)     record   quantity")
    for n in range(14):
        a, s = unpair(n)
        print(f"  {n:6d}   ({a:2d},{s:2d})   {obs_diag(n):6d}   {f_diag(n):8d}")

    print("\n  fibre constancy holds by determinism of evaluation:",
          is_fibre_constant(obs_diag, f_diag, 400))

    print("\n  Least halting trace (least step budget s with machine a halting on a):")
    print("    a :", list(range(14)))
    print("    s :", [least_halting_trace(a, 256) for a in range(14)])
    print("  Machines with `None` did not halt within the simulation budget; on the")
    print("  true model this column is exactly the function no computable bound can")
    print("  dominate, which is the failure of uniform effective selection.")

    print("\n  The diagonal argument, spelled out:")
    print("    Suppose dec is a total computable decoder, and set g(a) = dec(a+1).")
    print("    Then g is total computable, so g has an index a0 and halts on a0.")
    print("    For a large enough step budget s, the trace n = <a0, s> has")
    print("      record   obs(n) = a0 + 1      quantity  f(n) = g(a0) + 1,")
    print("    so correctness forces  g(a0) = dec(a0+1) = g(a0) + 1.  Absurd.")
    print("    Hence no total computable decoder, hence no computable selector,")
    print("    hence the emitted-record set {0} u {a+1 : machine a self-halts} is")
    print("    undecidable -- a halting statement obtained from decoding alone.")


def demo_6_effective_fano() -> None:
    banner("6.  Finite patching and the effective Fano bound")

    obs: Channel = lambda n: n % 5
    f: Quantity = lambda n: (n % 5) * 11
    window = 200

    # A decoder that is wrong on exactly two records.
    sloppy: Decoder = lambda m: 0 if m in (2, 3) else (m % 5) * 11
    bad_states = error_states(obs, f, sloppy, window)
    bad_records = error_records(obs, f, sloppy, window)
    print("channel obs(n) = n mod 5, quantity f(n) = 11 (n mod 5)")
    print(f"  a sloppy decoder errs on records {bad_records}")
    print(f"  that is {len(bad_states)} of {window} states below the window")

    fixed = repair(obs, f, sloppy, window)
    print("  repaired decoder is perfect on the window:",
          decodes(obs, f, fixed, window))
    print("  Finite patching: hard-wiring finitely many constants preserves")
    print("  computability, so 'wrong on finitely many records' is always")
    print("  repairable.  Contrapositive: on a channel with NO computable decoder,")
    print("  every computable decoder is wrong on infinitely many records, and so")
    print("  misreconstructs infinitely many states.\n")

    # The unrepairable case, sampled: any fixed computable guess on the diagonal
    # channel already errs on many states inside a small window.
    guesses: Dict[str, Decoder] = {
        "dec(m) = 0": lambda m: 0,
        "dec(m) = 1": lambda m: 1,
        "dec(m) = m": lambda m: m,
    }
    print("  diagonal trace channel, errors inside the first 400 states:")
    for name, g in guesses.items():
        errs = error_states(obs_diag, f_diag, g, 400)
        print(f"    {name:12s} -> {len(errs):3d} misreconstructed states"
              f"  (first few: {errs[:6]})")
    print("  Theory: for EVERY computable decoder this count diverges as the")
    print("  window grows; the finite lower bound |S| - rate of the finite theory")
    print("  becomes an infinite lower bound, uniformly over all algorithms.")


def demo_7_four_way_equivalence() -> None:
    banner("7.  The four-way equivalence, checked on sample channels")

    def summarise(name: str, obs: Channel, in_range: Optional[Callable[[int], bool]],
                  window: int = 200) -> None:
        rep: Quantity = lambda n: canonical_representative(obs, n)
        decidable = in_range is not None
        if decidable:
            sel = guarded_selector(obs, in_range)             # type: ignore[arg-type]
            has_sel = is_selector(obs, sel, window)
            dec: Decoder = lambda m: rep(sel(m))
            decodes_rep = decodes(obs, rep, dec, window)
            sel_from_dec = is_selector(obs, dec, window)
        else:
            has_sel = decodes_rep = sel_from_dec = False
        print(f"  {name}")
        print(f"     (1) range decidable                 : {decidable}")
        print(f"     (2) computable selector             : {has_sel}")
        print(f"     (3)/(4) canonical representative decoded : {decodes_rep}")
        print(f"     any decoder for r is a selector     : {sel_from_dec}")

    summarise("obs(n) = n mod 9            ", lambda n: n % 9, lambda t: 0 <= t < 9)
    summarise("obs(n) = 3n + 1             ", lambda n: 3 * n + 1,
              lambda t: t % 3 == 1 and t >= 1)
    summarise("obs(n) = min(n, 6)          ", lambda n: min(n, 6), lambda t: 0 <= t <= 6)
    print("  diagonal trace channel        ")
    print("     (1) range decidable                 : False  (halting problem)")
    print("     (2) computable selector             : False")
    print("     (3)/(4) canonical representative decoded : False")
    print("     -- all four fail together, exactly as the equivalence predicts.")


def main() -> None:
    print(__doc__)
    demo_1_fibre_constancy()
    demo_2_canonical_representative()
    demo_3_selection_is_range_decidability()
    demo_4_one_jump()
    demo_5_diagonal_channel()
    demo_6_effective_fano()
    demo_7_four_way_equivalence()
    print("\nAll demonstrations complete.\n")


if __name__ == "__main__":
    main()
