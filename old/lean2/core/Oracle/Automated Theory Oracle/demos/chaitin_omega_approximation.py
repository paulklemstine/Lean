#!/usr/bin/env python3
"""
═══════════════════════════════════════════════════════════════════════════
CHAITIN'S Ω APPROXIMATION ENGINE
═══════════════════════════════════════════════════════════════════════════

Computes increasingly accurate lower bounds on Chaitin's halting probability Ω
by simulating simple programs (modeled as finite automata / register machines)
and tracking which ones halt.

Ω = Σ_{p halts} 2^{-|p|}

where the sum is over all self-delimiting programs p that halt, and |p| is
the length of program p in bits.

Key demonstrations:
  1. Ω is left-computably enumerable (we can approximate from below)
  2. Ω is NOT computable (we can never know we've found the exact value)
  3. Each new bit of Ω solves more and more halting problems
  4. The speed of convergence is related to the Busy Beaver function

Usage:
    python chaitin_omega_approximation.py
"""

import random
import math
from typing import List, Tuple, Dict, Optional
from dataclasses import dataclass, field
from collections import defaultdict


# ════════════════════════════════════════════════════════════════
# §1: SIMPLE PROGRAM MODEL
# ════════════════════════════════════════════════════════════════

@dataclass
class SimpleProgram:
    """
    A simple register machine program with:
    - One register (natural number)
    - Instructions: INC, DEC (with halt-if-zero), HALT, GOTO
    """
    instructions: List[Tuple[str, int]]  # (opcode, arg)
    length_bits: int  # length in bits

    def run(self, max_steps: int = 10000) -> Optional[int]:
        """Run the program. Returns number of steps if halts, None if doesn't."""
        register = 0
        pc = 0
        steps = 0

        while steps < max_steps and 0 <= pc < len(self.instructions):
            op, arg = self.instructions[pc]
            if op == "HALT":
                return steps
            elif op == "INC":
                register += 1
                pc += 1
            elif op == "DEC":
                if register > 0:
                    register -= 1
                    pc += 1
                else:
                    return steps  # halt on underflow
            elif op == "GOTO":
                pc = arg
            else:
                pc += 1
            steps += 1

        return None  # didn't halt within budget


def enumerate_programs(max_length: int) -> List[SimpleProgram]:
    """Enumerate all programs up to a given length."""
    programs = []
    opcodes = ["HALT", "INC", "DEC", "GOTO"]

    # Length 1: single instruction
    for op in opcodes:
        if op == "GOTO":
            for target in range(3):
                programs.append(SimpleProgram([(op, target)], 1))
        else:
            programs.append(SimpleProgram([(op, 0)], 1))

    # Length 2: two instructions
    for op1 in opcodes:
        args1 = [0] if op1 != "GOTO" else list(range(3))
        for a1 in args1:
            for op2 in opcodes:
                args2 = [0] if op2 != "GOTO" else list(range(3))
                for a2 in args2:
                    programs.append(SimpleProgram([(op1, a1), (op2, a2)], 2))

    # Length 3: three instructions
    if max_length >= 3:
        for op1 in opcodes:
            args1 = [0] if op1 != "GOTO" else list(range(4))
            for a1 in args1:
                for op2 in opcodes:
                    args2 = [0] if op2 != "GOTO" else list(range(4))
                    for a2 in args2:
                        for op3 in opcodes:
                            args3 = [0] if op3 != "GOTO" else list(range(4))
                            for a3 in args3:
                                programs.append(SimpleProgram(
                                    [(op1, a1), (op2, a2), (op3, a3)], 3))

    return programs


# ════════════════════════════════════════════════════════════════
# §2: Ω COMPUTATION
# ════════════════════════════════════════════════════════════════

def compute_omega_approximation(max_length: int = 3, max_steps: int = 10000):
    """
    Compute a lower bound on Ω by running all programs up to max_length
    with a step budget of max_steps.
    """
    programs = enumerate_programs(max_length)

    halting = []
    non_halting = []
    unknown = []

    for p in programs:
        result = p.run(max_steps)
        if result is not None:
            halting.append((p, result))
        else:
            unknown.append(p)  # might halt later — we just don't know

    # Compute Ω lower bound
    # Using prefix-free encoding: contribution = 2^{-length_bits}
    # But we need to normalize by program count at each length
    omega_lower = 0.0
    by_length = defaultdict(lambda: {"total": 0, "halting": 0})

    for p in programs:
        by_length[p.length_bits]["total"] += 1
    for p, _ in halting:
        by_length[p.length_bits]["halting"] += 1

    # Simple model: at length L, each program has probability 2^{-L} in prefix-free coding
    # Actual Ω contribution from length-L programs that halt:
    for length, counts in sorted(by_length.items()):
        frac = counts["halting"] / counts["total"]
        omega_lower += frac * (2 ** (-length))

    return omega_lower, halting, unknown, by_length


# ════════════════════════════════════════════════════════════════
# §3: CONVERGENCE DEMONSTRATION
# ════════════════════════════════════════════════════════════════

def demonstrate_convergence():
    """Show how Ω approximation improves with more computation."""
    print("\n" + "═" * 70)
    print("  CHAITIN'S Ω: Convergence from Below")
    print("═" * 70)

    print("\n  Ω = probability that a random program halts")
    print("  We can only approximate from below (left-c.e.)")
    print("  More computation → better lower bound, but NEVER exact.\n")

    step_budgets = [10, 50, 100, 500, 1000, 5000, 10000]

    print(f"  {'Steps':>8} | {'Ω lower bound':>15} | {'Halting':>8} | {'Unknown':>8} | Bar")
    print(f"  {'-'*8}-+-{'-'*15}-+-{'-'*8}-+-{'-'*8}-+-{'-'*30}")

    prev_omega = 0
    for budget in step_budgets:
        omega, halting, unknown, _ = compute_omega_approximation(2, budget)
        bar_len = int(omega * 60)
        bar = "█" * bar_len + "░" * max(0, 30 - bar_len)
        arrow = "↑" if omega > prev_omega else "="
        print(f"  {budget:>8} | {omega:>15.12f} | {len(halting):>8} | {len(unknown):>8} | {bar} {arrow}")
        prev_omega = omega

    print(f"\n  Note: Ω increases monotonically. Each new halting program")
    print(f"  adds to the sum. But we can never know when we're 'done'.")


# ════════════════════════════════════════════════════════════════
# §4: BITS OF Ω SOLVE HALTING PROBLEMS
# ════════════════════════════════════════════════════════════════

def omega_bits_power():
    """Demonstrate how knowing bits of Ω helps solve halting problems."""
    print("\n" + "═" * 70)
    print("  BITS OF Ω: Each Bit Solves More Problems")
    print("═" * 70)

    print("\n  Knowing the first n bits of Ω lets you solve the halting problem")
    print("  for all programs of length ≤ n (approximately).")
    print("  This is Chaitin's incompleteness: a finite formal system")
    print("  can determine only finitely many bits of Ω.\n")

    omega_full, halting, _, by_length = compute_omega_approximation(3, 10000)

    print(f"  Full Ω approximation: {omega_full:.15f}\n")

    # Show bits
    omega_binary = []
    val = omega_full
    for i in range(20):
        val *= 2
        if val >= 1:
            omega_binary.append('1')
            val -= 1
        else:
            omega_binary.append('0')

    print(f"  Binary: 0.{''.join(omega_binary)}...")
    print()

    # Show what each bit "knows"
    print(f"  {'Bits known':>12} | {'Programs decided':>18} | {'Halting insight'}")
    print(f"  {'-'*12}-+-{'-'*18}-+-{'-'*30}")

    for n_bits in range(1, min(11, len(omega_binary)+1)):
        known = omega_binary[:n_bits]
        # Knowing n bits of Ω lets us decide halting for all n-bit programs
        decided = sum(by_length[l]["total"] for l in by_length if l <= n_bits)
        print(f"  {n_bits:>12} | {decided:>18} | 0.{''.join(known)}...")


# ════════════════════════════════════════════════════════════════
# §5: THE INCOMPRESSIBILITY BARRIER
# ════════════════════════════════════════════════════════════════

def incompressibility_demo():
    """Show the connection between Ω and incompressibility."""
    print("\n" + "═" * 70)
    print("  THE INCOMPRESSIBILITY BARRIER")
    print("═" * 70)

    print("""
  Chaitin's theorem: A formal system of complexity c cannot prove
  "K(s) ≥ n" for any n > c + O(1).

  This means:
  - ZFC (complexity ~10⁴) can prove incompressibility for strings
    up to ~10⁴ bits, but not beyond.
  - To prove a 1-million-bit string is incompressible, you'd need
    a formal system of at least ~1 million bits of complexity.

  The Oracle Real Ω is the MAXIMALLY incompressible object:
  every finite subsequence of its bits is incompressible.
""")

    # Demonstrate with random strings
    print("  Simulated incompressibility distribution:")
    print(f"  {'Length n':>10} | {'Compressible (K<n)':>20} | {'Incompressible (K≥n)':>22} | Ratio")
    print(f"  {'-'*10}-+-{'-'*20}-+-{'-'*22}-+-{'-'*10}")

    for n in [4, 8, 12, 16, 20]:
        total = 2 ** n
        # At most 2^(n-1) strings have K < n (by counting argument)
        compressible_bound = 2 ** (n - 1)
        incompressible = total - compressible_bound
        print(f"  {n:>10} | {compressible_bound:>20} | {incompressible:>22} | "
              f"{incompressible/total:.4f}")

    print(f"\n  → Most strings of length n are incompressible.")
    print(f"  → Most mathematical truths are 'hard' (long proofs).")
    print(f"  → The ATO spends most of its time on trivial truths.")


# ════════════════════════════════════════════════════════════════
# §6: BUSY BEAVER CONNECTION
# ════════════════════════════════════════════════════════════════

def busy_beaver_connection():
    """Show the connection between Ω convergence and Busy Beaver."""
    print("\n" + "═" * 70)
    print("  THE BUSY BEAVER CONNECTION")
    print("═" * 70)

    print("""
  The Busy Beaver function BB(n) = max steps before halting among
  all n-state Turing machines that halt.

  Connection to Ω:
  - To compute the first n bits of Ω, you need to run all n-bit
    programs for at least BB(n) steps.
  - BB grows faster than ANY computable function.
  - Known values: BB(1)=1, BB(2)=6, BB(3)=21, BB(4)=107,
    BB(5)=47,176,870 (recently determined!), BB(6) > 10^36534

  This means Ω convergence is UNIMAGINABLY slow:
""")

    bb_values = {1: 1, 2: 6, 3: 21, 4: 107, 5: 47176870}

    print(f"  {'n':>4} | {'BB(n)':>15} | {'log₁₀(BB(n))':>14} | Steps needed for n bits of Ω")
    print(f"  {'-'*4}-+-{'-'*15}-+-{'-'*14}-+-{'-'*35}")

    for n, bb in bb_values.items():
        log_bb = math.log10(bb) if bb > 0 else 0
        print(f"  {n:>4} | {bb:>15,} | {log_bb:>14.2f} | ≥ {bb:,} steps")

    print(f"  {6:>4} | {'> 10^36534':>15} | {'> 36534':>14} | Astronomically many steps")
    print(f"\n  Bottom line: computing even 6 bits of Ω requires more steps")
    print(f"  than there are atoms in the observable universe (≈10^80).")


# ════════════════════════════════════════════════════════════════
# MAIN
# ════════════════════════════════════════════════════════════════

def main():
    print("╔" + "═" * 68 + "╗")
    print("║  CHAITIN'S Ω APPROXIMATION ENGINE                                ║")
    print("║  The Number That Knows Everything (But Can Never Be Known)       ║")
    print("╚" + "═" * 68 + "╝")

    demonstrate_convergence()
    omega_bits_power()
    incompressibility_demo()
    busy_beaver_connection()

    print("\n" + "═" * 70)
    print("  FINAL INSIGHT: Ω is a single real number that, if known exactly,")
    print("  would solve ALL halting problems and thus ALL mathematical questions")
    print("  expressible in arithmetic. But its very definition ensures it")
    print("  can never be fully computed. It is the ultimate oracle —")
    print("  all-knowing, forever beyond reach.")
    print("═" * 70)


if __name__ == "__main__":
    main()
