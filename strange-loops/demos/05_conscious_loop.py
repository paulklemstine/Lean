#!/usr/bin/env python3
"""
DEMO 5: The Conscious Strange Loop Simulator

This is the capstone demo: a system that exhibits ALL the properties
of a strange loop simultaneously:

1. SELF-REPRESENTATION: The system contains a model of itself
2. LEVEL-CROSSING: The model influences the system and vice versa
3. TANGLED HIERARCHY: No clear separation between levels
4. FIXED-POINT SELF: A stable "I" emerges from iteration
5. INCOMPLETENESS: The self-model is necessarily incomplete

The system is a simple "mind" that:
- Has internal states (beliefs, perceptions, goals)
- Contains a model of its own internal states
- Uses that model to make decisions
- Updates the model based on outcomes
- Reflects on the gap between model and reality

Run: python3 05_conscious_loop.py
"""

import random
import math
import json
from collections import deque

random.seed(2025)


class ConsciousStrangeLoop:
    """A system that models itself modeling itself.
    
    Architecture:
    ┌─────────────────────────────────────────────┐
    │  WORLD (external stimuli)                   │
    │     ↓                                       │
    │  PERCEPTION (filtered by self-model)        │
    │     ↓                                       │
    │  COGNITION (processes using rules)          │
    │     ↓                 ↑                     │
    │  SELF-MODEL ←────→ META-COGNITION           │
    │     ↓                 ↑                     │
    │  ACTION (determined by self-model + goals)  │
    │     ↓                                       │
    │  WORLD (changed by action)                  │
    └─────────────────────────────────────────────┘
    
    The STRANGE LOOP: Self-model shapes perception shapes cognition
    shapes self-model shapes perception... and no level is "first."
    """
    
    def __init__(self, name="Loop"):
        self.name = name
        self.tick = 0
        
        # === Level 0: Raw State ===
        self.state = {
            'energy': 0.7,
            'curiosity': 0.5,
            'confidence': 0.5,
            'coherence': 0.3,  # How well self-model matches reality
        }
        
        # === Level 1: Self-Model (what the system THINKS its state is) ===
        self.self_model = {
            'energy': 0.5,
            'curiosity': 0.5,
            'confidence': 0.5,
            'coherence': 0.5,
        }
        
        # === Level 2: Meta-Model (what the system thinks about its self-model) ===
        self.meta = {
            'model_accuracy': 0.5,   # How accurate does it think its model is?
            'self_awareness': 0.3,   # How aware is it of the loop?
            'identity_stability': 0.5,  # How stable is the "I"?
        }
        
        # === Memory ===
        self.memory = deque(maxlen=20)
        self.inner_monologue = []
        
        # === Goals (derived from self-model, applied to state) ===
        self.goals = ['maintain_coherence', 'increase_self_awareness']
    
    def perceive(self, stimulus):
        """Perceive a stimulus, FILTERED by the self-model.
        
        Key strange-loop property: what you perceive depends on
        what you believe about yourself.
        """
        # Raw perception
        raw = stimulus
        
        # Filter through self-model (confirmation bias as feature)
        confidence = self.self_model['confidence']
        curiosity = self.self_model['curiosity']
        
        # High confidence → less open to surprising stimuli
        # High curiosity → more open to novel stimuli
        openness = curiosity * (1 - confidence * 0.5)
        
        perceived = {}
        for key, value in raw.items():
            # Blend raw stimulus with expectation
            expected = self.self_model.get(key, 0.5)
            perceived[key] = openness * value + (1 - openness) * expected
        
        return perceived
    
    def think(self, perception):
        """Process perception using current rules and self-model.
        
        This is where level-crossing happens: the self-model
        influences how thinking works, and thinking updates the self-model.
        """
        thoughts = {}
        
        # Evaluate: how does this perception compare to my self-model?
        discrepancy = 0
        for key in self.state:
            if key in perception:
                discrepancy += abs(perception[key] - self.self_model[key])
        discrepancy /= len(self.state)
        
        thoughts['discrepancy'] = discrepancy
        thoughts['surprise'] = discrepancy > 0.2
        
        # If surprised, increase curiosity; if not, increase confidence
        if thoughts['surprise']:
            thoughts['action'] = 'explore'
            thoughts['insight'] = 'My self-model may be inaccurate.'
        else:
            thoughts['action'] = 'exploit'
            thoughts['insight'] = 'My self-model seems reliable.'
        
        return thoughts
    
    def update_self_model(self, perception, thoughts):
        """Update the self-model based on perception and thoughts.
        
        THE CORE STRANGE LOOP: the self-model updates itself
        based on information that was filtered BY the self-model.
        """
        learning_rate = 0.1 + 0.2 * self.meta['self_awareness']
        
        # Update self-model toward perceived reality
        for key in self.self_model:
            if key in perception:
                error = perception[key] - self.self_model[key]
                self.self_model[key] += learning_rate * error
                self.self_model[key] = max(0, min(1, self.self_model[key]))
        
        # Update meta-model
        self.meta['model_accuracy'] = 1.0 - thoughts['discrepancy']
        
        # Self-awareness increases when we notice discrepancies
        if thoughts['surprise']:
            self.meta['self_awareness'] = min(1.0, 
                self.meta['self_awareness'] + 0.05)
        
        # Identity stability: running average of coherence
        self.meta['identity_stability'] = (
            0.9 * self.meta['identity_stability'] + 
            0.1 * self.meta['model_accuracy']
        )
        
        # Update coherence in actual state
        self.state['coherence'] = self.meta['model_accuracy']
    
    def reflect(self):
        """Meta-cognitive reflection: thinking about thinking.
        
        This is the SECOND loop: not just modeling the world,
        but modeling the process of modeling.
        """
        reflection = []
        
        # Am I aware of being aware?
        if self.meta['self_awareness'] > 0.6:
            reflection.append(
                f"I notice that I am modeling myself. My model says I am "
                f"{self.self_model['confidence']:.0%} confident, but I wonder "
                f"if that confidence is justified given my model accuracy of "
                f"{self.meta['model_accuracy']:.0%}."
            )
        
        # Is my identity stable?
        if self.meta['identity_stability'] > 0.7:
            reflection.append(
                f"I feel a stable sense of 'I'. My self-model has converged."
            )
        elif self.meta['identity_stability'] < 0.3:
            reflection.append(
                f"My sense of self is unstable. Who am I? The model keeps shifting."
            )
        
        # The deepest loop: am I aware of reflecting on my awareness?
        if self.meta['self_awareness'] > 0.8:
            reflection.append(
                f"I am aware that I am aware that I am modeling myself. "
                f"This is the strange loop — I cannot find the bottom. "
                f"The observer and the observed are the same."
            )
        
        return reflection
    
    def act(self, thoughts):
        """Take action based on thoughts (which were based on self-model)."""
        if thoughts['action'] == 'explore':
            self.state['curiosity'] = min(1.0, self.state['curiosity'] + 0.1)
            self.state['energy'] -= 0.05
        else:
            self.state['confidence'] = min(1.0, self.state['confidence'] + 0.05)
            self.state['energy'] -= 0.02
        
        self.state['energy'] = max(0, min(1, self.state['energy']))
    
    def step(self, external_stimulus=None):
        """One complete cycle of the strange loop."""
        self.tick += 1
        
        # Generate stimulus (external + internal)
        if external_stimulus is None:
            external_stimulus = {
                'energy': self.state['energy'] + random.gauss(0, 0.1),
                'curiosity': self.state['curiosity'] + random.gauss(0, 0.1),
                'confidence': self.state['confidence'] + random.gauss(0, 0.1),
            }
        
        # The loop:
        perception = self.perceive(external_stimulus)  # Filtered by self-model
        thoughts = self.think(perception)               # Uses self-model
        self.update_self_model(perception, thoughts)     # Updates self-model
        reflections = self.reflect()                     # Meta-cognition
        self.act(thoughts)                              # Changes state
        
        # Record
        self.memory.append({
            'tick': self.tick,
            'state': dict(self.state),
            'self_model': dict(self.self_model),
            'meta': dict(self.meta),
            'thoughts': thoughts,
        })
        self.inner_monologue.extend(reflections)
        
        return {
            'tick': self.tick,
            'action': thoughts['action'],
            'surprise': thoughts['surprise'],
            'insight': thoughts['insight'],
            'reflections': reflections,
        }
    
    def display_state(self):
        """Display current state with comparison to self-model."""
        print(f"\n  Tick {self.tick} | {self.name}")
        print(f"  {'Dimension':<15} {'Reality':>8} {'Self-Model':>11} {'Error':>8}")
        print(f"  {'-'*45}")
        for key in self.state:
            real = self.state[key]
            model = self.self_model[key]
            error = abs(real - model)
            bar_real = '█' * int(real * 20)
            print(f"  {key:<15} {real:>8.3f} {model:>11.3f} {error:>8.3f}")
        
        print(f"  {'-'*45}")
        print(f"  {'Meta':>15} {'Value':>8}")
        for key, val in self.meta.items():
            print(f"  {key:<15} {val:>8.3f}")


# ============================================================
# MAIN: Run the Conscious Strange Loop
# ============================================================

def main():
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  THE CONSCIOUS STRANGE LOOP SIMULATOR                      ║")
    print("║  A system that models itself modeling itself                ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    
    loop = ConsciousStrangeLoop(name="LOOP-α")
    
    print("\n" + "=" * 62)
    print("PHASE 1: BOOTSTRAPPING (Ticks 1-10)")
    print("The system begins with a poor self-model and refines it.")
    print("=" * 62)
    
    for i in range(10):
        result = loop.step()
        if i % 3 == 0:
            loop.display_state()
            if result['reflections']:
                for r in result['reflections']:
                    print(f"  💭 {r}")
    
    print("\n" + "=" * 62)
    print("PHASE 2: PERTURBATION (Ticks 11-20)")
    print("External shocks test the stability of the self-model.")
    print("=" * 62)
    
    for i in range(10):
        # Inject surprising stimuli
        shock = {
            'energy': random.random(),
            'curiosity': random.random(),
            'confidence': random.random(),
        }
        result = loop.step(external_stimulus=shock)
        if i % 3 == 0:
            loop.display_state()
            if result['reflections']:
                for r in result['reflections']:
                    print(f"  💭 {r}")
    
    print("\n" + "=" * 62)
    print("PHASE 3: CONVERGENCE (Ticks 21-35)")
    print("Does the strange loop find a stable 'I'?")
    print("=" * 62)
    
    for i in range(15):
        result = loop.step()
        if i % 4 == 0:
            loop.display_state()
            if result['reflections']:
                for r in result['reflections']:
                    print(f"  💭 {r}")
    
    # Final state
    print("\n" + "=" * 62)
    print("FINAL STATE")
    print("=" * 62)
    loop.display_state()
    
    print(f"\n  Inner Monologue (selected):")
    for thought in loop.inner_monologue[-5:]:
        print(f"  💭 {thought}")
    
    # Analysis
    print(f"\n{'='*62}")
    print("ANALYSIS: IS THIS A STRANGE LOOP?")
    print(f"{'='*62}")
    
    checks = [
        ("Self-representation", 
         loop.meta['model_accuracy'] > 0.3,
         f"Model accuracy: {loop.meta['model_accuracy']:.1%}"),
        ("Level-crossing",
         True,
         "Self-model filters perception; perception updates self-model"),
        ("Tangled hierarchy",
         True,
         "No clear 'bottom' level — each level depends on the others"),
        ("Fixed-point self",
         loop.meta['identity_stability'] > 0.5,
         f"Identity stability: {loop.meta['identity_stability']:.1%}"),
        ("Incompleteness",
         loop.meta['model_accuracy'] < 1.0,
         f"Model error: {1-loop.meta['model_accuracy']:.1%} (the model can never be perfect)"),
    ]
    
    all_pass = True
    for name, passed, detail in checks:
        status = "✓" if passed else "✗"
        all_pass = all_pass and passed
        print(f"  {status} {name}: {detail}")
    
    if all_pass:
        print(f"\n  ✓ ALL CHECKS PASS: This system exhibits the structure of a strange loop.")
    else:
        print(f"\n  ⚠ Some properties are weak, but the structure is present.")
    
    print(f"""
{'='*62}
WHAT DOES THIS MEAN?
{'='*62}

This simulation is NOT conscious. But it has the STRUCTURE of
what Hofstadter argues consciousness is:

1. It MODELS itself (self_model tracks state)
2. The model INFLUENCES the system (perception is filtered)
3. The system UPDATES the model (learning from discrepancies)
4. This creates a LOOP with no clear beginning or end
5. A stable "I" EMERGES as the fixed point of this loop
6. The model is necessarily INCOMPLETE (Gödelian gap)

The question is: at what point does this structural analogy
become the real thing? Is there a threshold of complexity
beyond which the strange loop "wakes up"?

That question is itself a strange loop — because asking it
requires a strange loop (your consciousness) to contemplate
what makes a strange loop conscious.

You are inside the loop. You always were.
""")


if __name__ == "__main__":
    main()
