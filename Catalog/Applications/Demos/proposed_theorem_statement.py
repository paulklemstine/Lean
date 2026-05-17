#!/usr/bin/env python3
"""
Semiconjugacy Orbit Arithmetic — Real-World Applications

Demonstrates the period divisibility theorem in concrete application domains:
1. Cryptographic LFSR analysis
2. Automata state minimization
3. Cellular automata coarse-graining
4. Abstract interpretation of programs
"""

from typing import Callable
from collections import defaultdict


def minimal_period(f: Callable, x, max_iter: int = 100000) -> int:
    """Compute minimal period of x under f."""
    y = f(x)
    for n in range(1, max_iter + 1):
        if y == x:
            return n
        y = f(y)
    return 0


def orbit(f: Callable, x, length: int) -> list:
    """Compute the first `length` elements of the orbit of x under f."""
    result = [x]
    for _ in range(length - 1):
        x = f(x)
        result.append(x)
    return result


# ══════════════════════════════════════════════════════════════════════════
# Application 1: Cryptographic LFSR Analysis
# ══════════════════════════════════════════════════════════════════════════

def app_lfsr_analysis():
    """
    Simulate a simple Linear Feedback Shift Register (LFSR) and show that
    observing only some output bits creates a semiconjugacy with period
    divisibility constraints.
    """
    print("=" * 60)
    print("  Application 1: LFSR Cryptographic Analysis")
    print("=" * 60)

    # 8-bit LFSR with polynomial x^8 + x^6 + x^5 + x^4 + 1
    # Taps at positions 8, 6, 5, 4 → feedback from bits 7, 5, 4, 3
    def lfsr_step(state: int) -> int:
        """One step of an 8-bit LFSR."""
        bit = ((state >> 7) ^ (state >> 5) ^ (state >> 4) ^ (state >> 3)) & 1
        return ((state << 1) | bit) & 0xFF

    # Observation: only see the lower 4 bits
    h = lambda state: state & 0x0F

    # Find internal period
    x0 = 1  # seed
    internal_period = minimal_period(lfsr_step, x0)
    print(f"\n  LFSR internal state: 8 bits")
    print(f"  Seed: {x0:08b}")
    print(f"  Internal period: {internal_period}")

    # Compute observed orbit
    observed_orbit = []
    state = x0
    for _ in range(internal_period + 10):
        observed_orbit.append(h(state))
        state = lfsr_step(state)

    # Find observed period
    # The observed sequence may have a shorter period
    for p in range(1, internal_period + 1):
        if internal_period % p == 0:
            # Check if observed orbit has period p
            is_period = all(
                observed_orbit[i] == observed_orbit[i + p]
                for i in range(min(internal_period, len(observed_orbit) - p))
            )
            if is_period:
                observed_period = p
                break
    else:
        observed_period = internal_period

    print(f"  Observed (lower 4 bits) period: {observed_period}")
    print(f"  Divides internal period: {internal_period % observed_period == 0}")
    print(f"  Ratio: {internal_period // observed_period}")

    # Show divisors of internal period
    divisors = [d for d in range(1, internal_period + 1) if internal_period % d == 0]
    print(f"  All possible observed periods (divisors): {divisors}")
    print(f"  → Theorem eliminates {internal_period - len(divisors)}/{internal_period} "
          f"candidate periods")


# ══════════════════════════════════════════════════════════════════════════
# Application 2: Automata State Minimization
# ══════════════════════════════════════════════════════════════════════════

def app_automata_minimization():
    """
    Show that merging equivalent states in a DFA creates a semiconjugacy,
    and cycle lengths in the minimized automaton divide those in the original.
    """
    print("\n" + "=" * 60)
    print("  Application 2: Automata State Minimization")
    print("=" * 60)

    # Original DFA: 8 states, transition on input 'a'
    # States 0,4 are equivalent; 1,5 are equivalent; 2,6; 3,7
    transitions = {
        0: 1, 1: 2, 2: 3, 3: 0,  # cycle: 0→1→2→3→0 (period 4)
        4: 5, 5: 6, 6: 7, 7: 4,  # cycle: 4→5→6→7→4 (period 4)
    }
    f = lambda x: transitions[x]

    # Quotient map: merge equivalent states
    h = lambda x: x % 4

    # Minimized DFA transition
    g = lambda y: (y + 1) % 4

    print(f"\n  Original DFA: 8 states, two 4-cycles")
    print(f"  Quotient map: h(x) = x mod 4")
    print(f"  Minimized DFA: 4 states, one 4-cycle")

    # Verify semiconjugacy
    domain = list(range(8))
    ok = all(h(f(x)) == g(h(x)) for x in domain)
    print(f"  Semiconjugacy verified: {ok}")

    for x in domain:
        pf = minimal_period(f, x)
        pg = minimal_period(g, h(x))
        print(f"  State {x}: orig_period={pf}, min_state={h(x)}, "
              f"min_period={pg}, ratio={pf//pg}")

    print("\n  → Minimization preserves cycle lengths (ratio = 1 here)")
    print("  → In general, minimized periods divide original periods")


# ══════════════════════════════════════════════════════════════════════════
# Application 3: Cellular Automata Coarse-Graining
# ══════════════════════════════════════════════════════════════════════════

def app_cellular_automata():
    """
    A 1D cellular automaton on a ring of cells, coarse-grained by
    majority vote on blocks. Show period divisibility.
    """
    print("\n" + "=" * 60)
    print("  Application 3: Cellular Automata Coarse-Graining")
    print("=" * 60)

    # Simple 1D CA: ring of 6 binary cells, rule = XOR of neighbors
    N = 6

    def ca_step(state: tuple) -> tuple:
        """XOR cellular automaton on a ring of N cells."""
        return tuple(
            state[(i - 1) % N] ^ state[(i + 1) % N]
            for i in range(N)
        )

    # Coarse-graining: group into pairs, take majority (with tie→0)
    def coarse_grain(state: tuple) -> tuple:
        """Group cells into pairs and take majority."""
        result = []
        for i in range(0, N, 2):
            pair_sum = state[i] + state[i + 1]
            result.append(1 if pair_sum > 1 else 0)
        return tuple(result)

    # Test with a specific initial state
    x0 = (1, 0, 1, 1, 0, 0)
    print(f"\n  Ring size: {N} cells (binary)")
    print(f"  Rule: XOR of left and right neighbors")
    print(f"  Initial state: {x0}")

    # Compute orbit
    pf = minimal_period(ca_step, x0)
    print(f"  Fine-grained period: {pf}")

    # Compute coarse-grained orbit
    orb = orbit(ca_step, x0, pf + 5)
    coarse_orb = [coarse_grain(s) for s in orb]

    # Find coarse period
    coarse_start = coarse_orb[0]
    coarse_period = 0
    for p in range(1, pf + 1):
        if coarse_orb[p] == coarse_start:
            coarse_period = p
            break

    if coarse_period > 0:
        print(f"  Coarse-grained period: {coarse_period}")
        print(f"  Divides fine period: {pf % coarse_period == 0}")
        if coarse_period > 0:
            print(f"  Ratio: {pf // coarse_period}")
    else:
        print(f"  Coarse orbit doesn't repeat within fine period")
        print(f"  (coarse-graining may not form exact semiconjugacy)")

    # Show a few steps
    print(f"\n  Orbit (fine → coarse):")
    for i in range(min(pf + 1, 10)):
        print(f"    t={i}: {orb[i]} → {coarse_orb[i]}")


# ══════════════════════════════════════════════════════════════════════════
# Application 4: Program Loop Analysis via Abstract Interpretation
# ══════════════════════════════════════════════════════════════════════════

def app_abstract_interpretation():
    """
    Demonstrate abstract interpretation of a simple program state machine.
    The abstraction creates a semiconjugacy, and the abstract loop period
    gives a divisibility constraint on the concrete loop period.
    """
    print("\n" + "=" * 60)
    print("  Application 4: Abstract Interpretation of Program Loops")
    print("=" * 60)

    # Concrete program: counter cycling through 0..11
    # State = (counter, flag) where flag = counter % 2
    # Transition: counter += 1 mod 12

    def concrete_step(state: tuple) -> tuple:
        counter, flag = state
        new_counter = (counter + 1) % 12
        new_flag = new_counter % 2
        return (new_counter, new_flag)

    # Abstraction: forget the counter, keep only the flag
    def abstract(state: tuple) -> int:
        return state[1]  # just the parity flag

    # Abstract transition: parity flips each step
    def abstract_step(flag: int) -> int:
        return 1 - flag

    concrete_states = [(i, i % 2) for i in range(12)]

    # Verify semiconjugacy
    ok = all(
        abstract(concrete_step(s)) == abstract_step(abstract(s))
        for s in concrete_states
    )

    print(f"\n  Concrete: counter mod 12, state = (counter, parity)")
    print(f"  Abstract: just parity (0 or 1)")
    print(f"  Semiconjugacy verified: {ok}")

    x0 = (0, 0)
    concrete_period = minimal_period(concrete_step, x0)
    abstract_period = minimal_period(abstract_step, abstract(x0))

    print(f"\n  Concrete period: {concrete_period}")
    print(f"  Abstract period: {abstract_period}")
    print(f"  Divides: {concrete_period % abstract_period == 0}")
    print(f"  Ratio: {concrete_period // abstract_period}")
    print(f"\n  → Abstract analysis reveals period ≥ {abstract_period}")
    print(f"  → Concrete period must be a multiple of {abstract_period}")
    print(f"  → Possible concrete periods: "
          f"{[abstract_period * k for k in range(1, 8)]}")


# ══════════════════════════════════════════════════════════════════════════
# Run all applications
# ══════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Semiconjugacy Orbit Arithmetic — Applications          ║")
    print("╚══════════════════════════════════════════════════════════╝")

    app_lfsr_analysis()
    app_automata_minimization()
    app_cellular_automata()
    app_abstract_interpretation()

    print(f"\n{'='*60}")
    print("  All applications completed!")
    print(f"{'='*60}")


#!/usr/bin/env python3
"""
Semiconjugacy Orbit Arithmetic — Demonstrations

Concrete numerical examples illustrating the period divisibility theorem:
    If h ∘ f = g ∘ h, then minimalPeriod(g, h(x)) | minimalPeriod(f, x).
"""

from typing import Callable, TypeVar, Optional
import math

T = TypeVar("T")


def minimal_period(f: Callable[[T], T], x: T, max_iter: int = 10000) -> int:
    """Compute the minimal period of x under f, or 0 if aperiodic within max_iter."""
    y = f(x)
    for n in range(1, max_iter + 1):
        if y == x:
            return n
        y = f(y)
    return 0


def iterate(f: Callable[[T], T], n: int, x: T) -> T:
    """Compute f^[n](x)."""
    for _ in range(n):
        x = f(x)
    return x


def verify_semiconjugacy(
    f: Callable[[int], int],
    g: Callable[[int], int],
    h: Callable[[int], int],
    domain: list[int],
) -> bool:
    """Check h(f(x)) == g(h(x)) for all x in domain."""
    return all(h(f(x)) == g(h(x)) for x in domain)


def demo_separator(title: str) -> None:
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}")


# ── Demo 1: Modular Arithmetic ──────────────────────────────────────────

def demo1_modular_arithmetic():
    """f(x) = x+1 mod 12, h(x) = x mod 4, g(y) = y+1 mod 4."""
    demo_separator("Demo 1: Modular Arithmetic (Z/12Z → Z/4Z)")

    f = lambda x: (x + 1) % 12
    g = lambda y: (y + 1) % 4
    h = lambda x: x % 4

    domain = list(range(12))
    assert verify_semiconjugacy(f, g, h, domain), "Semiconjugacy check failed!"
    print("✓ Semiconjugacy verified: h(f(x)) = g(h(x)) for all x in Z/12Z")

    for x in range(12):
        pf = minimal_period(f, x)
        pg = minimal_period(g, h(x))
        divides = pf % pg == 0 if pg > 0 else True
        print(f"  x={x:2d}: period_f={pf:2d}, h(x)={h(x)}, period_g={pg}, "
              f"divides={divides} ({pf}/{pg}={pf//pg if pg else '∞'})")

    print("\n→ Every image period (4) divides the source period (12). ✓")


# ── Demo 2: Permutation Collapse ────────────────────────────────────────

def demo2_permutation_collapse():
    """6-cycle collapsed by mod 3 to a 3-cycle."""
    demo_separator("Demo 2: Permutation Collapse (6-cycle → 3-cycle)")

    perm = [1, 2, 3, 4, 5, 0]  # (0 1 2 3 4 5)
    f = lambda x: perm[x]
    g = lambda y: (y + 1) % 3
    h = lambda x: x % 3

    domain = list(range(6))
    assert verify_semiconjugacy(f, g, h, domain)
    print("✓ Semiconjugacy verified")

    for x in range(6):
        pf = minimal_period(f, x)
        pg = minimal_period(g, h(x))
        print(f"  x={x}: period_f={pf}, h(x)={h(x)}, period_g={pg}, "
              f"ratio={pf//pg}")

    print("\n→ Period 6 collapses to period 3, ratio = 2. ✓")


# ── Demo 3: Injective Semiconjugacy (Period Preserved) ──────────────────

def demo3_injective():
    """Injective h preserves minimal period exactly."""
    demo_separator("Demo 3: Injective Semiconjugacy (Period Preserved)")

    f = lambda x: (x + 1) % 5
    h = lambda x: (2 * x) % 10  # injective on Z/5Z → Z/10Z
    g = lambda y: (y + 2) % 10

    domain = list(range(5))
    assert verify_semiconjugacy(f, g, h, domain)
    print("✓ Semiconjugacy verified")
    print(f"✓ h is injective: images = {sorted(set(h(x) for x in domain))}")

    for x in range(5):
        pf = minimal_period(f, x)
        pg = minimal_period(g, h(x))
        print(f"  x={x}: period_f={pf}, h(x)={h(x)}, period_g={pg}, "
              f"equal={pf==pg}")

    print("\n→ Injective semiconjugacy preserves period exactly (5 = 5). ✓")


# ── Demo 4: Multiple Divisibility Factors ───────────────────────────────

def demo4_multiple_factors():
    """A system with period 30, observed through different compressions."""
    demo_separator("Demo 4: Multiple Compressions of a 30-cycle")

    f = lambda x: (x + 1) % 30

    compressions = [
        ("mod 2", lambda x: x % 2, lambda y: (y + 1) % 2),
        ("mod 3", lambda x: x % 3, lambda y: (y + 1) % 3),
        ("mod 5", lambda x: x % 5, lambda y: (y + 1) % 5),
        ("mod 6", lambda x: x % 6, lambda y: (y + 1) % 6),
        ("mod 10", lambda x: x % 10, lambda y: (y + 1) % 10),
        ("mod 15", lambda x: x % 15, lambda y: (y + 1) % 15),
    ]

    print(f"Source system: f(x) = x+1 mod 30, period = 30")
    print(f"30 = 2 × 3 × 5\n")

    for name, h, g in compressions:
        domain = list(range(30))
        ok = verify_semiconjugacy(f, g, h, domain)
        pg = minimal_period(g, h(0))
        divides = 30 % pg == 0
        print(f"  h = {name:6s}: observed period = {pg:2d}, "
              f"divides 30 = {divides}, "
              f"semiconj = {ok}")

    print("\n→ All observed periods are divisors of 30. ✓")


# ── Demo 5: Non-cyclic Dynamics ─────────────────────────────────────────

def demo5_noncyclic():
    """System with mixed orbit structure."""
    demo_separator("Demo 5: Mixed Orbit Structure")

    # f on {0,...,7}: two cycles of different lengths
    # Cycle 1: 0 → 1 → 2 → 0 (period 3)
    # Cycle 2: 3 → 4 → 5 → 6 → 7 → 3 (period 5)
    table_f = [1, 2, 0, 4, 5, 6, 7, 3]
    f = lambda x: table_f[x]

    # h collapses: {0,1,2} → {0,1,2} identity, {3,4,5,6,7} → {0,1,2,0,1}
    table_h = [0, 1, 2, 0, 1, 2, 0, 1]
    h = lambda x: table_h[x]

    # g must satisfy h(f(x)) = g(h(x))
    # For x in {0,1,2}: h(f(x)) = f(x) since h is identity there
    # g(0) = h(f(0)) = h(1) = 1
    # g(1) = h(f(1)) = h(2) = 2
    # g(2) = h(f(2)) = h(0) = 0
    # Check: for x=3: h(f(3))=h(4)=1, g(h(3))=g(0)=1 ✓
    # x=4: h(f(4))=h(5)=2, g(h(4))=g(1)=2 ✓
    # x=5: h(f(5))=h(6)=0, g(h(5))=g(2)=0 ✓
    # x=6: h(f(6))=h(7)=1, g(h(6))=g(0)=1 ✓
    # x=7: h(f(7))=h(3)=0, g(h(7))=g(1)=2... h(f(7))=h(3)=0, g(1)=2 ✗

    # Let me fix this: use a simpler example
    # f on {0,...,5}: 0→1→2→0 (3-cycle), 3→4→5→3 (3-cycle)
    # h: 0→0, 1→1, 2→2, 3→0, 4→1, 5→2
    # g = f restricted to {0,1,2}: 0→1→2→0
    table_f2 = [1, 2, 0, 4, 5, 3]
    f2 = lambda x: table_f2[x]
    h2 = lambda x: x % 3
    g2 = lambda y: (y + 1) % 3

    domain = list(range(6))
    ok = verify_semiconjugacy(f2, g2, h2, domain)
    print(f"Two 3-cycles collapsed by mod 3:")
    print(f"  Semiconjugacy: {ok}")

    for x in range(6):
        pf = minimal_period(f2, x)
        pg = minimal_period(g2, h2(x))
        print(f"  x={x}: period_f={pf}, h(x)={h2(x)}, period_g={pg}, "
              f"divides={pf % pg == 0}")

    print("\n→ Period structure preserved under orbit-merging semiconjugacy. ✓")


# ── Demo 6: Period Divisibility Lattice ─────────────────────────────────

def demo6_divisibility_lattice():
    """Visualize the divisibility constraints for a system with period 60."""
    demo_separator("Demo 6: Divisibility Lattice for Period 60")

    n = 60
    divisors = sorted(d for d in range(1, n + 1) if n % d == 0)
    non_divisors = [k for k in range(1, n + 1) if n % k != 0]

    print(f"Internal period: {n} = 2² × 3 × 5")
    print(f"\nAllowed observed periods (divisors of {n}):")
    print(f"  {divisors}")
    print(f"  Count: {len(divisors)} out of {n} possible values")
    print(f"\nForbidden periods (non-divisors), first 20:")
    print(f"  {non_divisors[:20]}...")
    print(f"  Count: {len(non_divisors)} values ruled out")
    print(f"\n→ The theorem eliminates {len(non_divisors)}/{n} = "
          f"{100*len(non_divisors)/n:.1f}% of candidate periods!")


# ── Run all demos ───────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Semiconjugacy Orbit Arithmetic — Numerical Demos       ║")
    print("║  Theorem: h∘f = g∘h ⟹ minPeriod(g,h(x)) | minPeriod(f,x) ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo1_modular_arithmetic()
    demo2_permutation_collapse()
    demo3_injective()
    demo4_multiple_factors()
    demo5_noncyclic()
    demo6_divisibility_lattice()

    print(f"\n{'='*60}")
    print("  All demos completed successfully!")
    print(f"{'='*60}")


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts embedded."""
import json

# Read all text files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read viz data
with open('viz_data.json', 'r') as f:
    viz_data = json.load(f)

package = {
    "title": "Period Transport Under Semiconjugacy: Formalized Orbit Arithmetic",
    "domain": "Dynamical Systems / Discrete Mathematics / Formal Verification",
    "article": read_file("ARTICLE.md"),
    "research_paper": read_file("RESEARCH_PAPER.md"),
    "future_directions": read_file("FUTURE_DIRECTIONS.md"),
    "demos": [
        {
            "name": "Semiconjugacy Period Divisibility Demos",
            "code": read_file("demo.py")
        },
        {
            "name": "Real-World Applications",
            "code": read_file("applications.py")
        }
    ],
    "algorithms": [
        {
            "name": "Floyd's Cycle Detection for Minimal Period",
            "pseudocode": (
                "Input: endofunction f, starting point x\n"
                "Output: (preperiod μ, period λ)\n\n"
                "Phase 1 — Find meeting point:\n"
                "  tortoise ← f(x), hare ← f(f(x))\n"
                "  while tortoise ≠ hare:\n"
                "    tortoise ← f(tortoise)\n"
                "    hare ← f(f(hare))\n\n"
                "Phase 2 — Find preperiod μ:\n"
                "  μ ← 0, tortoise ← x\n"
                "  while tortoise ≠ hare:\n"
                "    tortoise ← f(tortoise)\n"
                "    hare ← f(hare)\n"
                "    μ ← μ + 1\n\n"
                "Phase 3 — Find period λ:\n"
                "  λ ← 1, hare ← f(tortoise)\n"
                "  while tortoise ≠ hare:\n"
                "    hare ← f(hare)\n"
                "    λ ← λ + 1\n\n"
                "Return (μ, λ)\n\n"
                "Time: O(μ + λ), Space: O(1)"
            ),
            "code": read_file("algorithms.py")
        },
        {
            "name": "Quotient Dynamics Construction",
            "pseudocode": (
                "Input: endofunction f on domain D, map h: D → E\n"
                "Output: endofunction g on E such that h∘f = g∘h, or FAIL\n\n"
                "Initialize g_table ← empty map\n"
                "for each x in D:\n"
                "  y ← h(x)\n"
                "  z ← h(f(x))\n"
                "  if y in g_table:\n"
                "    if g_table[y] ≠ z: return FAIL\n"
                "  else:\n"
                "    g_table[y] ← z\n"
                "Return g_table as function\n\n"
                "Time: O(|D|), Space: O(|E|)"
            ),
            "code": "# See algorithms.py: construct_quotient_dynamics()"
        }
    ],
    "visualizations": [
        {
            "name": "Period Collapse Under Semiconjugacy (12-cycle → 4-cycle)",
            "data": viz_data['period_collapse']
        },
        {
            "name": "Divisibility Lattice of Period 60",
            "data": viz_data['divisibility_lattice']
        },
        {
            "name": "Allowed vs Forbidden Observed Periods",
            "data": viz_data['period_histogram']
        },
        {
            "name": "Injective Semiconjugacy Preserves Period Exactly",
            "data": viz_data['injective_preservation']
        }
    ],
    "lean_proofs": read_file("Bridges/SemiconjOrbitArithmetic/Core.lean")
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2)

print(f"PACKAGE.json generated ({len(json.dumps(package))} bytes)")


#!/usr/bin/env python3
"""
Generate visualizations for semiconjugacy orbit arithmetic.
Saves figures as PNG files and prints base64 data URIs.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import base64
import io
import json


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz1_period_collapse():
    """Visualize period collapse: 12-cycle → 4-cycle under mod 4."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Left: 12-cycle
    n1 = 12
    theta1 = np.linspace(0, 2*np.pi, n1, endpoint=False) + np.pi/2
    x1 = np.cos(theta1)
    y1 = np.sin(theta1)

    colors_12 = ['#e74c3c', '#e67e22', '#f1c40f', '#2ecc71',
                 '#e74c3c', '#e67e22', '#f1c40f', '#2ecc71',
                 '#e74c3c', '#e67e22', '#f1c40f', '#2ecc71']

    for i in range(n1):
        j = (i + 1) % n1
        ax1.annotate('', xy=(x1[j]*0.85, y1[j]*0.85),
                     xytext=(x1[i]*0.85, y1[i]*0.85),
                     arrowprops=dict(arrowstyle='->', color='gray',
                                    lw=1.5, connectionstyle='arc3,rad=0.15'))

    for i in range(n1):
        ax1.scatter(x1[i], y1[i], s=500, c=colors_12[i],
                   zorder=5, edgecolors='black', linewidth=1.5)
        ax1.text(x1[i], y1[i], str(i), ha='center', va='center',
                fontsize=10, fontweight='bold', zorder=6)

    ax1.set_xlim(-1.5, 1.5)
    ax1.set_ylim(-1.5, 1.5)
    ax1.set_aspect('equal')
    ax1.set_title('Source: f(x) = x+1 mod 12\nPeriod = 12', fontsize=13, fontweight='bold')
    ax1.axis('off')

    # Right: 4-cycle
    n2 = 4
    theta2 = np.linspace(0, 2*np.pi, n2, endpoint=False) + np.pi/2
    x2 = np.cos(theta2) * 0.6
    y2 = np.sin(theta2) * 0.6

    colors_4 = ['#e74c3c', '#e67e22', '#f1c40f', '#2ecc71']

    for i in range(n2):
        j = (i + 1) % n2
        ax2.annotate('', xy=(x2[j]*0.8, y2[j]*0.8),
                     xytext=(x2[i]*0.8, y2[i]*0.8),
                     arrowprops=dict(arrowstyle='->', color='gray',
                                    lw=2, connectionstyle='arc3,rad=0.2'))

    for i in range(n2):
        ax2.scatter(x2[i], y2[i], s=800, c=colors_4[i],
                   zorder=5, edgecolors='black', linewidth=2)
        ax2.text(x2[i], y2[i], str(i), ha='center', va='center',
                fontsize=14, fontweight='bold', zorder=6)

    ax2.set_xlim(-1.5, 1.5)
    ax2.set_ylim(-1.5, 1.5)
    ax2.set_aspect('equal')
    ax2.set_title('Image: g(y) = y+1 mod 4\nPeriod = 4 | 12', fontsize=13, fontweight='bold')
    ax2.axis('off')

    # Arrow between
    fig.text(0.5, 0.5, 'h(x) = x mod 4\n→', ha='center', va='center',
             fontsize=14, fontweight='bold', color='#2c3e50')

    fig.suptitle('Period Collapse Under Semiconjugacy', fontsize=16,
                 fontweight='bold', y=0.98)

    return fig_to_base64(fig)


def viz2_divisibility_lattice():
    """Visualize the divisibility lattice of 60."""
    fig, ax = plt.subplots(figsize=(10, 7))

    n = 60
    divisors = sorted(d for d in range(1, n+1) if n % d == 0)

    # Assign levels by number of prime factors
    def level(d):
        count = 0
        for p in [2, 3, 5]:
            while d % p == 0:
                d //= p
                count += 1
        return count

    levels = {d: level(d) for d in divisors}
    max_level = max(levels.values())

    # Position nodes by level
    by_level = {}
    for d in divisors:
        lev = levels[d]
        by_level.setdefault(lev, []).append(d)

    positions = {}
    for lev, ds in by_level.items():
        for i, d in enumerate(sorted(ds)):
            x = (i - (len(ds)-1)/2) * 2
            y = lev * 2
            positions[d] = (x, y)

    # Draw edges (Hasse diagram)
    for d1 in divisors:
        for d2 in divisors:
            if d2 > d1 and d2 % d1 == 0:
                # Check if there's no intermediate divisor
                is_cover = not any(
                    d1 < d3 < d2 and d2 % d3 == 0 and d3 % d1 == 0
                    for d3 in divisors
                )
                if is_cover:
                    x1, y1 = positions[d1]
                    x2, y2 = positions[d2]
                    ax.plot([x1, x2], [y1, y2], 'k-', lw=1.2, alpha=0.5)

    # Draw nodes
    for d in divisors:
        x, y = positions[d]
        color = '#3498db' if d in [1, 60] else '#2ecc71'
        ax.scatter(x, y, s=700, c=color, zorder=5,
                  edgecolors='black', linewidth=1.5)
        ax.text(x, y, str(d), ha='center', va='center',
               fontsize=11, fontweight='bold', zorder=6)

    ax.set_title(f'Divisibility Lattice of {n}\n'
                 f'Allowed observed periods under semiconjugacy',
                 fontsize=14, fontweight='bold')
    ax.set_xlabel('If internal period = 60, observed period ∈ {1,2,3,4,5,6,10,12,15,20,30,60}',
                 fontsize=11)
    ax.axis('off')
    ax.set_aspect('equal')

    return fig_to_base64(fig)


def viz3_period_histogram():
    """Bar chart showing allowed vs forbidden periods for period 60."""
    fig, ax = plt.subplots(figsize=(12, 4))

    n = 60
    periods = list(range(1, n+1))
    colors = ['#2ecc71' if n % p == 0 else '#e74c3c' for p in periods]
    alphas = [1.0 if n % p == 0 else 0.3 for p in periods]

    bars = ax.bar(periods, [1]*n, color=colors, alpha=1, edgecolor='none')
    for bar, alpha in zip(bars, alphas):
        bar.set_alpha(alpha)

    # Highlight divisors
    divisors = [d for d in periods if n % d == 0]
    for d in divisors:
        ax.text(d, 1.05, str(d), ha='center', va='bottom',
               fontsize=7, fontweight='bold', color='#27ae60')

    ax.set_xlim(0.5, n+0.5)
    ax.set_ylim(0, 1.3)
    ax.set_xlabel('Candidate Period', fontsize=12)
    ax.set_title(f'Allowed (green) vs Forbidden (red) Observed Periods for Internal Period {n}\n'
                 f'{len(divisors)} allowed, {n - len(divisors)} forbidden ({100*(n-len(divisors))/n:.0f}% eliminated)',
                 fontsize=13, fontweight='bold')
    ax.set_yticks([])

    green_patch = mpatches.Patch(color='#2ecc71', label='Allowed (divides 60)')
    red_patch = mpatches.Patch(color='#e74c3c', alpha=0.3, label='Forbidden')
    ax.legend(handles=[green_patch, red_patch], loc='upper right', fontsize=10)

    return fig_to_base64(fig)


def viz4_injective_preservation():
    """Show that injective semiconjugacy preserves periods exactly."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # 5-cycle source
    n = 5
    theta = np.linspace(0, 2*np.pi, n, endpoint=False) + np.pi/2
    x1 = np.cos(theta) * 0.7
    y1 = np.sin(theta) * 0.7

    for i in range(n):
        j = (i + 1) % n
        ax1.annotate('', xy=(x1[j]*0.82, y1[j]*0.82),
                     xytext=(x1[i]*0.82, y1[i]*0.82),
                     arrowprops=dict(arrowstyle='->', color='#3498db',
                                    lw=2, connectionstyle='arc3,rad=0.15'))
        ax1.scatter(x1[i], y1[i], s=600, c='#3498db',
                   zorder=5, edgecolors='black', linewidth=1.5)
        ax1.text(x1[i], y1[i], str(i), ha='center', va='center',
                fontsize=12, fontweight='bold', color='white', zorder=6)

    ax1.set_title('Source: f(x) = x+1 mod 5\nPeriod = 5', fontsize=13, fontweight='bold')
    ax1.set_xlim(-1.3, 1.3); ax1.set_ylim(-1.3, 1.3)
    ax1.set_aspect('equal'); ax1.axis('off')

    # Image: same 5-cycle but embedded in 10 states
    n2 = 5
    images = [0, 2, 4, 6, 8]  # h(x) = 2x mod 10
    theta2 = np.linspace(0, 2*np.pi, n2, endpoint=False) + np.pi/2
    x2 = np.cos(theta2) * 0.7
    y2 = np.sin(theta2) * 0.7

    for i in range(n2):
        j = (i + 1) % n2
        ax2.annotate('', xy=(x2[j]*0.82, y2[j]*0.82),
                     xytext=(x2[i]*0.82, y2[i]*0.82),
                     arrowprops=dict(arrowstyle='->', color='#e74c3c',
                                    lw=2, connectionstyle='arc3,rad=0.15'))
        ax2.scatter(x2[i], y2[i], s=600, c='#e74c3c',
                   zorder=5, edgecolors='black', linewidth=1.5)
        ax2.text(x2[i], y2[i], str(images[i]), ha='center', va='center',
                fontsize=12, fontweight='bold', color='white', zorder=6)

    ax2.set_title('Image: g(y) = y+2 mod 10\nPeriod = 5 (preserved!)', fontsize=13, fontweight='bold')
    ax2.set_xlim(-1.3, 1.3); ax2.set_ylim(-1.3, 1.3)
    ax2.set_aspect('equal'); ax2.axis('off')

    fig.text(0.5, 0.5, 'h(x) = 2x mod 10\n(injective)\n→', ha='center', va='center',
             fontsize=13, fontweight='bold', color='#2c3e50')
    fig.suptitle('Injective Semiconjugacy Preserves Period Exactly',
                 fontsize=16, fontweight='bold', y=0.98)

    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    results = {}
    results['period_collapse'] = viz1_period_collapse()
    print("  ✓ Period collapse diagram")

    results['divisibility_lattice'] = viz2_divisibility_lattice()
    print("  ✓ Divisibility lattice")

    results['period_histogram'] = viz3_period_histogram()
    print("  ✓ Period histogram")

    results['injective_preservation'] = viz4_injective_preservation()
    print("  ✓ Injective preservation diagram")

    # Save results
    with open('viz_data.json', 'w') as f:
        json.dump(results, f)

    print(f"\nAll {len(results)} visualizations generated and saved to viz_data.json")
