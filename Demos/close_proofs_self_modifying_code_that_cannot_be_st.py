#!/usr/bin/env python3
"""Finite demonstrations of self-modifying simulation and algebraic forgetting.

These examples illustrate bounded behavior only. In particular, failure to observe
termination within a chosen budget is not evidence of nontermination.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, Iterable, List, Optional, Sequence, Tuple

Program = Tuple[int, ...]
Configuration = Tuple[Program, int]
Transition = Callable[[Program, int], Optional[Configuration]]


def run_self_modifying(
    step: Transition, initial: Configuration, steps: int
) -> List[Configuration]:
    """Return the finite trace, stopping when the transition returns None."""
    trace = [initial]
    current = initial
    for _ in range(steps):
        nxt = step(*current)
        if nxt is None:
            break
        trace.append(nxt)
        current = nxt
    return trace


def run_fixed_interpreter(
    step: Transition, encoded_state: Configuration, steps: int
) -> List[Configuration]:
    """Run a fixed interpreter whose ordinary state stores program and data."""
    trace = [encoded_state]
    current = encoded_state
    for _ in range(steps):
        nxt = step(current[0], current[1])
        if nxt is None:
            break
        trace.append(nxt)
        current = nxt
    return trace


def rewriting_step(program: Program, state: int) -> Optional[Configuration]:
    """Toy transition: consume an instruction and append a state-dependent rewrite."""
    if not program or state >= 8:
        return None
    head, *tail = program
    new_state = state + head
    rewritten = tuple(tail) + ((new_state % 3) + 1,)
    return rewritten, new_state


def bounded_monitor(
    evaluator: Callable[[int], Optional[int]], maximum_budget: int
) -> Optional[Tuple[int, int]]:
    """Return the first budget and output observed, or None within the finite bound."""
    for budget in range(maximum_budget + 1):
        value = evaluator(budget)
        if value is not None:
            return budget, value
    return None


def halts_after(required_steps: int, output: int) -> Callable[[int], Optional[int]]:
    """Create a toy bounded evaluator that succeeds from a specified stage onward."""
    return lambda budget: output if budget >= required_steps else None


def targeted_forgetting(word: str, retained: Iterable[str]) -> str:
    """Delete symbols not belonging to the retained alphabet."""
    keep = set(retained)
    return "".join(symbol for symbol in word if symbol in keep)


def words_up_to(alphabet: Sequence[str], length: int) -> List[str]:
    """Enumerate all words over an alphabet up to the requested length."""
    return [""] + [
        "".join(chars)
        for size in range(1, length + 1)
        for chars in product(alphabet, repeat=size)
    ]


def quotient_classes(
    alphabet: Sequence[str], retained: Iterable[str], length: int
) -> Dict[str, List[str]]:
    """Group bounded words by their image under targeted forgetting."""
    classes: Dict[str, List[str]] = {}
    for word in words_up_to(alphabet, length):
        image = targeted_forgetting(word, retained)
        classes.setdefault(image, []).append(word)
    return classes


def finite_memory_value(word: str, modulus: int) -> int:
    """A compositional finite memory: word length modulo a positive modulus."""
    if modulus <= 0:
        raise ValueError("modulus must be positive")
    return len(word) % modulus


def first_memory_collision(alphabet: Sequence[str], modulus: int) -> Tuple[str, str, int]:
    """Find a collision among words of length at most the memory size."""
    seen: Dict[int, str] = {}
    for word in words_up_to(alphabet, modulus):
        value = finite_memory_value(word, modulus)
        if value in seen and seen[value] != word:
            return seen[value], word, value
        seen[value] = word
    raise RuntimeError("no collision found; the alphabet may be empty")


def demo_simulation() -> None:
    """Display matching traces for direct rewriting and fixed interpretation."""
    initial: Configuration = ((1, 2, 1), 0)
    direct = run_self_modifying(rewriting_step, initial, 8)
    encoded = run_fixed_interpreter(rewriting_step, initial, 8)
    print("\n1. STEP-FOR-STEP SIMULATION")
    for index, (left, right) in enumerate(zip(direct, encoded)):
        print(f"step {index:2d}: direct={left}  encoded={right}")
    print("traces equal:", direct == encoded)


def demo_monitor() -> None:
    """Show positive and inconclusive outcomes of bounded monitoring."""
    print("\n2. BOUNDED TERMINATION MONITOR")
    examples = [("quick", 3, 99), ("late", 12, 7)]
    for name, stage, output in examples:
        result = bounded_monitor(halts_after(stage, output), maximum_budget=8)
        print(f"{name:5s}: {result}")
    print("The 'late' result is only inconclusive at budget 8; it succeeds at budget 12.")


def demo_forgetting() -> None:
    """Display finite-memory collision and targeted-forgetting quotient classes."""
    print("\n3. FINITE MEMORY AND TARGETED FORGETTING")
    left, right, value = first_memory_collision(["a", "b"], modulus=3)
    print(f"length-mod-3 collision: {left!r} and {right!r} both map to {value}")
    classes = quotient_classes(["a", "b"], retained=["a"], length=3)
    for image, members in sorted(classes.items(), key=lambda item: (len(item[0]), item[0])):
        print(f"observable {image!r:5s} <- {members}")
    erased = classes.get("", [])
    closed_examples = [(u, v, u + v) for u in erased for v in erased if len(u + v) <= 3]
    print("sample erased concatenations:", closed_examples[:6])


def main() -> None:
    """Run all demonstrations."""
    demo_simulation()
    demo_monitor()
    demo_forgetting()


if __name__ == "__main__":
    main()
