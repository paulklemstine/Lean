#!/usr/bin/env python3
"""
DEMO 3: Strange Loop Cellular Automaton

A cellular automaton where cells can observe and modify the RULES
that govern them — creating a genuine strange loop between the
object level (cell states) and the meta level (transition rules).

In a normal cellular automaton (like Conway's Game of Life), the rules
are fixed and external. Here, the rules are PART of the state, and the
state can CHANGE the rules. This creates a tangled hierarchy:

  Level 0: Cell states (the "world")
  Level 1: Transition rules (the "laws of physics")
  Level 0 ↔ Level 1: States encode rules, rules determine states

Run: python3 03_strange_loop_automaton.py
"""

import random
import time
import sys

# ============================================================
# PART 1: Self-Modifying Cellular Automaton
# ============================================================

class StrangeLoopAutomaton:
    """A 1D cellular automaton where cells can modify the rules.
    
    Each cell has:
    - A state (0 or 1)
    - A local rule (3-bit → 1-bit, like Wolfram's elementary CA)
    
    The twist: when certain patterns appear, cells can CHANGE
    their local rule based on their neighborhood's states.
    This creates a strange loop between rules and states.
    """
    
    def __init__(self, size=60, initial_rule=110):
        self.size = size
        self.cells = [0] * size
        self.cells[size // 2] = 1  # Start with a single active cell
        
        # Each cell has its own rule (initially all the same)
        self.rules = [initial_rule] * size
        
        # History for self-observation
        self.history = []
        self.generation = 0
    
    def get_rule_bit(self, rule_number, neighborhood):
        """Get the output bit for a given neighborhood pattern (0-7)."""
        return (rule_number >> neighborhood) & 1
    
    def step(self):
        """Advance one generation with strange-loop rule modification."""
        new_cells = [0] * self.size
        new_rules = list(self.rules)
        
        for i in range(self.size):
            # Get neighborhood
            left = self.cells[(i - 1) % self.size]
            center = self.cells[i]
            right = self.cells[(i + 1) % self.size]
            neighborhood = (left << 2) | (center << 1) | right
            
            # Apply local rule
            new_cells[i] = self.get_rule_bit(self.rules[i], neighborhood)
            
            # === THE STRANGE LOOP ===
            # If a cell sees a specific pattern, it modifies its own rule
            # The modification depends on the CURRENT state — so states change rules
            # and rules change states. Neither level is "primary."
            
            if neighborhood == 0b111:  # All three neighbors active
                # XOR the rule with a state-derived value
                new_rules[i] = (self.rules[i] ^ (self.generation * 7 + i)) % 256
            elif neighborhood == 0b000 and self.generation > 5:
                # Dead zone: adopt neighbor's rule (rule propagation)
                new_rules[i] = self.rules[(i + 1) % self.size]
            
            # Self-observation: if the cell's state matches a bit of its own rule...
            rule_self_bit = self.get_rule_bit(self.rules[i], 0b010)  # What does rule say about "just me"?
            if new_cells[i] == rule_self_bit:
                # Coherence! The cell's state agrees with what the rule "wants"
                # Reinforce: keep the rule stable
                pass
            else:
                # Dissonance! The cell's state conflicts with the rule's expectation
                # Occasionally flip a rule bit (self-modification through dissonance)
                if random.random() < 0.05:
                    bit_to_flip = random.randint(0, 7)
                    new_rules[i] ^= (1 << bit_to_flip)
                    new_rules[i] %= 256
        
        self.history.append(list(self.cells))
        self.cells = new_cells
        self.rules = new_rules
        self.generation += 1
    
    def display(self):
        """Display the current state with rule diversity information."""
        # Show cells
        row = ''.join('█' if c else '·' for c in self.cells)
        
        # Count unique rules (measure of rule diversity)
        unique_rules = len(set(self.rules))
        
        # Calculate "self-awareness" metric: how many cells' states
        # match what their own rule predicts for a lone cell
        coherence = sum(
            1 for i in range(self.size)
            if self.cells[i] == self.get_rule_bit(self.rules[i], 0b010)
        )
        coherence_pct = coherence / self.size * 100
        
        print(f"Gen {self.generation:3d} | {row} | Rules:{unique_rules:3d} Coher:{coherence_pct:5.1f}%")
    
    def measure_self_reference(self):
        """Measure the degree of self-reference in the system.
        
        Self-reference = correlation between a cell's state and
        information encoded in its own rule.
        """
        if len(self.history) < 2:
            return 0.0
        
        # Compare current state pattern with rule-encoded pattern
        state_pattern = sum(c << i for i, c in enumerate(self.cells[:8]))
        rule_pattern = self.rules[self.size // 2]  # Central cell's rule
        
        # XOR gives dissimilarity; we want similarity
        xor = state_pattern ^ rule_pattern
        similarity = 1.0 - bin(xor).count('1') / 8.0
        
        return similarity


# ============================================================
# PART 2: Run the Strange Loop
# ============================================================

def run_automaton():
    """Run the strange loop automaton and observe its behavior."""
    
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  STRANGE LOOP CELLULAR AUTOMATON                                   ║")
    print("║  Rules modify states. States modify rules. Neither is primary.     ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    print("Legend: █ = active cell, · = inactive cell")
    print("Rules = number of distinct rules in the population")
    print("Coher = % of cells whose state matches their rule's self-prediction")
    print()
    
    random.seed(42)  # Reproducible
    automaton = StrangeLoopAutomaton(size=50, initial_rule=110)
    
    # Run for several generations
    automaton.display()
    for _ in range(40):
        automaton.step()
        automaton.display()
    
    # Final analysis
    print()
    print("=" * 72)
    print("ANALYSIS: THE STRANGE LOOP")
    print("=" * 72)
    print(f"""
In a standard cellular automaton, rules are EXTERNAL and FIXED.
The cells obey the rules, but cannot change them. There is a clear
hierarchy: Rules (meta-level) → States (object-level).

In THIS automaton, the hierarchy is TANGLED:
  • Cell states determine which rules are modified (upward causation)
  • Rules determine which cell states change (downward causation)  
  • Neither level is "more fundamental" — they co-create each other

This is a genuine strange loop: you cannot separate the "laws"
from the "matter" because each is encoded in and modified by the other.

The 'Coherence' metric measures self-reference: how well does each
cell's state match what its own rule "expects"? When coherence is
high, the system has achieved a kind of self-consistency — the
states and rules agree about what the system IS.

This self-consistent state is a fixed point of the strange loop.
It is, in miniature, what Hofstadter calls an "I" — a stable
pattern of self-reference in a tangled hierarchy.
""")


# ============================================================
# PART 3: Autopoietic Loop — Self-Producing System
# ============================================================

def autopoietic_demo():
    """Demonstrate autopoiesis: a system that produces itself.
    
    Maturana & Varela's autopoiesis: a network of processes that
    produces the components which constitute the network itself.
    """
    
    print("=" * 72)
    print("AUTOPOIETIC STRANGE LOOP")
    print("=" * 72)
    
    # A simple autopoietic system: components that produce components
    # The system is a set of "molecules" that catalyze each other's creation
    
    class AutopoieticSystem:
        def __init__(self):
            self.components = {'A': 5, 'B': 5, 'C': 5}
            self.boundary = 15  # Total components = boundary integrity
            
        def step(self):
            # Each component type catalyzes production of the next
            # A → B, B → C, C → A (circular causation)
            new = dict(self.components)
            
            # Production (each type catalyzes the next)
            produced_B = min(self.components['A'], 3)
            produced_C = min(self.components['B'], 3)
            produced_A = min(self.components['C'], 3)
            
            # Decay (entropy)
            decay = 1
            
            new['A'] = max(0, self.components['A'] - decay + produced_A)
            new['B'] = max(0, self.components['B'] - decay + produced_B)
            new['C'] = max(0, self.components['C'] - decay + produced_C)
            
            self.components = new
            self.boundary = sum(new.values())
            
            return self.boundary > 0  # System is "alive" if boundary exists
        
        def display(self, gen):
            a_bar = '█' * self.components['A']
            b_bar = '█' * self.components['B']
            c_bar = '█' * self.components['C']
            alive = "ALIVE" if self.boundary > 0 else "DEAD"
            print(f"  Gen {gen:2d} | A:{a_bar:<12s} B:{b_bar:<12s} C:{c_bar:<12s} | {alive}")
    
    system = AutopoieticSystem()
    print("\nA produces B, B produces C, C produces A.")
    print("The system produces the components that constitute itself.\n")
    
    for gen in range(15):
        system.display(gen)
        if not system.step():
            print("  System has died — autopoiesis failed.")
            break
    
    print(f"""
The autopoietic loop: A→B→C→A→B→C→...
Each component exists BECAUSE of the others.
No component is "first" or "primary."
The system is its own cause and its own effect.
This circular causation is the biological analogue of a strange loop.
""")


if __name__ == "__main__":
    run_automaton()
    autopoietic_demo()
