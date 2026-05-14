#!/usr/bin/env python3
"""
Algorithms for Berggren Orbit Computation

Implements the core algorithms from the research paper on using
Pythagorean triple orbits as a computational substrate.
"""

from typing import Tuple, List, Dict, Optional, Set
from dataclasses import dataclass
from math import gcd, log2, ceil
import numpy as np

Triple = Tuple[int, int, int]

# ============================================================
# Algorithm 1: Berggren Tree Traversal
# ============================================================

# Berggren matrices as 3x3 integer arrays
MAT_A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
MAT_B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]])
MAT_C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])

# Inverse matrices
INV_A = np.array([[1, 2, -2], [-2, -1, 2], [-2, -2, 3]])
INV_B = np.array([[1, 2, -2], [2, 1, -2], [-2, -2, 3]])
INV_C = np.array([[-1, -2, 2], [2, 1, -2], [-2, -2, 3]])

BERGGREN_MATS = {'A': MAT_A, 'B': MAT_B, 'C': MAT_C}
BERGGREN_INVS = {'A': INV_A, 'B': INV_B, 'C': INV_C}


def berggren_child(direction: str, triple: Triple) -> Triple:
    """
    Apply a Berggren generator to produce a child triple.
    
    Args:
        direction: 'A', 'B', or 'C'
        triple: A Pythagorean triple (a, b, c)
    
    Returns:
        The child triple in the given direction
    
    Time: O(1)
    Space: O(1)
    """
    v = np.array(triple)
    result = BERGGREN_MATS[direction] @ v
    return tuple(int(x) for x in result)


def berggren_parent(direction: str, triple: Triple) -> Triple:
    """
    Apply the inverse Berggren generator.
    
    Args:
        direction: 'A', 'B', or 'C'  
        triple: A Pythagorean triple
    
    Returns:
        The parent triple (inverse operation)
    """
    v = np.array(triple)
    result = BERGGREN_INVS[direction] @ v
    return tuple(int(x) for x in result)


def word_to_triple(word: str) -> Triple:
    """
    Convert a Berggren word to the corresponding triple.
    
    Args:
        word: String of 'A', 'B', 'C' characters
    
    Returns:
        The Pythagorean triple at that address
    
    Time: O(|word|)
    Space: O(1)
    
    >>> word_to_triple('')
    (3, 4, 5)
    >>> word_to_triple('A')
    (5, 12, 13)
    >>> word_to_triple('B')
    (21, 20, 29)
    """
    t = (3, 4, 5)
    for ch in word:
        t = berggren_child(ch, t)
    return t


def triple_to_word(triple: Triple) -> Optional[str]:
    """
    Find the Berggren word that generates a given primitive Pythagorean triple.
    Uses the descent algorithm: repeatedly apply inverse generators until
    reaching the root (3,4,5).
    
    Args:
        triple: A primitive Pythagorean triple (a, b, c) with a, b, c > 0
    
    Returns:
        The Berggren word, or None if the triple is not primitive/positive
    
    Time: O(log c) per step × O(log c) steps = O(log² c)
    Space: O(log c) for the word
    
    >>> triple_to_word((3, 4, 5))
    ''
    >>> triple_to_word((5, 12, 13))
    'A'
    """
    word_chars = []
    a, b, c = triple
    
    if a <= 0 or b <= 0 or c <= 0:
        return None
    if a*a + b*b != c*c:
        return None
    
    max_steps = 10 * int(log2(c + 1)) + 10
    
    for _ in range(max_steps):
        if (a, b, c) == (3, 4, 5):
            return ''.join(reversed(word_chars))
        
        # Determine which inverse to apply
        # The parent is found by checking which inverse gives positive entries
        for direction in ['A', 'B', 'C']:
            parent = berggren_parent(direction, (a, b, c))
            pa, pb, pc = parent
            if pa > 0 and pb > 0 and pc > 0 and pa*pa + pb*pb == pc*pc:
                word_chars.append(direction)
                a, b, c = pa, pb, pc
                break
        else:
            return None  # No valid parent found
    
    return None


# ============================================================
# Algorithm 2: Enumerate Triples by Depth
# ============================================================

def enumerate_triples(max_depth: int) -> Dict[int, List[Tuple[str, Triple]]]:
    """
    Enumerate all primitive Pythagorean triples up to a given tree depth.
    
    Args:
        max_depth: Maximum depth in the Berggren tree
    
    Returns:
        Dictionary mapping depth to list of (word, triple) pairs
    
    Time: O(3^max_depth)
    Space: O(3^max_depth)
    
    The number of triples at depth d is exactly 3^d.
    Total triples up to depth D: (3^(D+1) - 1) / 2.
    """
    result = {0: [('', (3, 4, 5))]}
    
    for d in range(1, max_depth + 1):
        result[d] = []
        for word, triple in result[d - 1]:
            for direction in 'ABC':
                child = berggren_child(direction, triple)
                result[d].append((word + direction, child))
    
    return result


# ============================================================
# Algorithm 3: Two-Counter Machine Simulator
# ============================================================

@dataclass
class TCInstruction:
    """A two-counter machine instruction."""
    opcode: str  # 'inc1', 'inc2', 'dec1', 'dec2', 'halt'
    target: int = 0  # jump target for dec instructions


@dataclass
class TCState:
    """State of a two-counter machine."""
    pc: int
    c1: int
    c2: int
    halted: bool = False
    
    def copy(self):
        return TCState(self.pc, self.c1, self.c2, self.halted)


class TwoCounterMachine:
    """
    A two-counter machine simulator.
    
    Two-counter machines are Turing-complete: any computable function
    can be computed by such a machine. This class simulates the machine
    and can encode its state into the Berggren orbit.
    
    Time per step: O(1)
    Space: O(1) (just pc, c1, c2)
    """
    
    def __init__(self, program: List[TCInstruction]):
        self.program = program
    
    def step(self, state: TCState) -> TCState:
        """Execute one step of the machine."""
        s = state.copy()
        if s.halted or s.pc >= len(self.program):
            s.halted = True
            return s
        
        instr = self.program[s.pc]
        if instr.opcode == 'inc1':
            s.c1 += 1
            s.pc += 1
        elif instr.opcode == 'inc2':
            s.c2 += 1
            s.pc += 1
        elif instr.opcode == 'dec1':
            if s.c1 > 0:
                s.c1 -= 1
                s.pc += 1
            else:
                s.pc = instr.target
        elif instr.opcode == 'dec2':
            if s.c2 > 0:
                s.c2 -= 1
                s.pc += 1
            else:
                s.pc = instr.target
        elif instr.opcode == 'halt':
            s.halted = True
        
        return s
    
    def run(self, c1: int = 0, c2: int = 0, max_steps: int = 10000) -> List[TCState]:
        """
        Run the machine and return the execution trace.
        
        Returns:
            List of states from initial to final
        """
        state = TCState(pc=0, c1=c1, c2=c2)
        trace = [state.copy()]
        
        for _ in range(max_steps):
            if state.halted:
                break
            state = self.step(state)
            trace.append(state.copy())
        
        return trace


def encode_tc_to_orbit(state: TCState) -> Dict[str, str]:
    """
    Encode a TC machine state into an orbit configuration.
    
    Maps:
        aRay(0) = ""     -> pc value
        aRay(1) = "A"    -> counter 1 value  
        aRay(2) = "AA"   -> counter 2 value
        All others       -> quiescent
    
    Returns:
        Dictionary mapping orbit addresses to cell states
    """
    return {
        '': f'pc({state.pc})',
        'A': f'c1({state.c1})',
        'AA': f'c2({state.c2})',
    }


# ============================================================
# Algorithm 4: Bit-Size Analysis
# ============================================================

def analyze_bitsize(max_depth: int = 20) -> Dict[str, List]:
    """
    Analyze the bit-size growth of triples along different branches.
    
    Returns:
        Dictionary with depth, bitsizes, and bounds for different branches
    
    Time: O(max_depth)
    Space: O(max_depth)
    """
    results = {}
    
    for branch_name, direction in [('A-ray', 'A'), ('B-ray', 'B'), ('C-ray', 'C')]:
        depths = []
        max_entries = []
        bitsizes = []
        bounds = []
        
        t = (3, 4, 5)
        for d in range(max_depth + 1):
            max_entry = max(abs(t[0]), abs(t[1]), abs(t[2]))
            bound = 7**d * 5
            
            depths.append(d)
            max_entries.append(max_entry)
            bitsizes.append(max_entry.bit_length())
            bounds.append(bound)
            
            t = berggren_child(direction, t)
        
        results[branch_name] = {
            'depths': depths,
            'max_entries': max_entries,
            'bitsizes': bitsizes,
            'bounds': bounds
        }
    
    return results


# ============================================================
# Algorithm 5: Orbit Distance Computation
# ============================================================

def common_prefix_length(w1: str, w2: str) -> int:
    """Compute the common prefix length of two orbit addresses."""
    length = 0
    for c1, c2 in zip(w1, w2):
        if c1 == c2:
            length += 1
        else:
            break
    return length


def tree_distance(w1: str, w2: str) -> int:
    """
    Compute the tree distance between two orbit addresses.
    
    This is the number of edges in the unique path between w1 and w2
    in the Berggren tree.
    
    Time: O(min(|w1|, |w2|))
    Space: O(1)
    """
    cpl = common_prefix_length(w1, w2)
    return len(w1) + len(w2) - 2 * cpl


# ============================================================
# Main: Run all algorithms with examples
# ============================================================

if __name__ == '__main__':
    print("Berggren Orbit Computation - Algorithm Demonstrations")
    print("=" * 60)
    
    # Algorithm 1: Word operations
    print("\n--- Algorithm 1: Word-Triple Conversion ---")
    test_words = ['', 'A', 'B', 'C', 'AA', 'AB', 'BA', 'ABC']
    for w in test_words:
        t = word_to_triple(w)
        w_back = triple_to_word(t)
        print(f"  word='{w}' -> triple={t} -> word_back='{w_back}'")
    
    # Algorithm 2: Enumeration
    print("\n--- Algorithm 2: Enumeration ---")
    tree = enumerate_triples(3)
    for d, triples in tree.items():
        print(f"  Depth {d}: {len(triples)} triples")
        if d <= 1:
            for w, t in triples:
                print(f"    '{w}' -> {t}")
    
    # Algorithm 3: Counter machine
    print("\n--- Algorithm 3: Two-Counter Machine ---")
    # Program: compute 3 + 2 = 5 by transferring c2 to c1
    prog = [
        TCInstruction('dec2', 2),  # 0: if c2>0, dec c2, go 1; else go 2
        TCInstruction('inc1'),     # 1: inc c1, go 0... 
    ]
    # Simpler: just count to 5
    prog = [
        TCInstruction('inc1'),  # 0
        TCInstruction('inc1'),  # 1
        TCInstruction('inc1'),  # 2
        TCInstruction('inc1'),  # 3
        TCInstruction('inc1'),  # 4
        TCInstruction('halt'),  # 5
    ]
    
    machine = TwoCounterMachine(prog)
    trace = machine.run()
    
    print(f"  Program: 5x inc1, halt")
    print(f"  Final state: c1={trace[-1].c1}, c2={trace[-1].c2}")
    print(f"  Steps taken: {len(trace)-1}")
    print(f"  Orbit encoding of final state:")
    for addr, val in encode_tc_to_orbit(trace[-1]).items():
        t = word_to_triple(addr)
        print(f"    addr='{addr}' (triple {t}) -> {val}")
    
    # Algorithm 4: Bit-size analysis
    print("\n--- Algorithm 4: Bit-Size Analysis ---")
    analysis = analyze_bitsize(15)
    for branch, data in analysis.items():
        print(f"  {branch}:")
        print(f"    Depth 0: {data['bitsizes'][0]} bits")
        print(f"    Depth 5: {data['bitsizes'][5]} bits")
        print(f"    Depth 10: {data['bitsizes'][10]} bits")
        print(f"    Depth 15: {data['bitsizes'][15]} bits")
        growth_rate = data['bitsizes'][15] / 15
        print(f"    Avg bits/depth: {growth_rate:.2f}")
    
    # Algorithm 5: Tree distance
    print("\n--- Algorithm 5: Tree Distance ---")
    pairs = [('', 'A'), ('A', 'B'), ('AA', 'AB'), ('ABC', 'ACB'), ('', 'AAA')]
    for w1, w2 in pairs:
        d = tree_distance(w1, w2)
        print(f"  d('{w1}', '{w2}') = {d}")
