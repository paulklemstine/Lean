#!/usr/bin/env python3
"""
Bayesian Werewolf: Real-World Applications
==========================================

Demonstrates how the mathematical framework for social deduction games
applies to real-world problems:

1. Insider Threat Detection (cybersecurity)
2. Epidemiological Contact Tracing
3. Jury Selection and Deliberation Analysis
4. Network Intrusion Detection

Each application maps to the Werewolf game framework:
  - Players → agents/nodes
  - Werewolves → adversaries/infected
  - Evidence → behavioral signals
  - Elimination → quarantine/investigation
"""

from __future__ import annotations
import math
import random
from typing import Optional


# ─── Application 1: Insider Threat Detection ───────────────────────

class InsiderThreatDetector:
    """
    Map the Werewolf Bayesian framework to insider threat detection.

    Employees are "players", insiders are "werewolves".
    Behavioral signals (login patterns, data access) provide evidence
    for Bayesian updates on each employee's threat probability.

    The optimal strategy (vote for highest posterior) corresponds to
    investigating the employee with highest threat score.
    """

    def __init__(self, num_employees: int, estimated_insiders: int):
        self.n = num_employees
        self.k = estimated_insiders
        self.threat_scores = [estimated_insiders / num_employees] * num_employees
        self.investigated: set[int] = set()

    def observe_anomaly(self, employee: int, severity: float = 0.7) -> None:
        """
        Update threat score after observing anomalous behavior.

        Args:
            employee: Employee index
            severity: How anomalous (0=normal, 1=very suspicious)
        """
        if employee in self.investigated:
            return

        # Bayesian update: P(insider | anomaly) ∝ P(anomaly | insider) * P(insider)
        # P(anomaly | insider) = severity
        # P(anomaly | normal) = 1 - severity
        prior = self.threat_scores[employee]
        likelihood_insider = 0.3 + 0.7 * severity
        likelihood_normal = 0.3 + 0.7 * (1 - severity)

        posterior = (prior * likelihood_insider) / \
                    (prior * likelihood_insider + (1 - prior) * likelihood_normal)
        self.threat_scores[employee] = posterior

    def recommend_investigation(self) -> Optional[int]:
        """Return the employee most likely to be an insider threat."""
        candidates = [i for i in range(self.n) if i not in self.investigated]
        if not candidates:
            return None
        return max(candidates, key=lambda i: self.threat_scores[i])

    def complete_investigation(self, employee: int, was_insider: bool) -> None:
        """Record investigation results and update remaining scores."""
        self.investigated.add(employee)
        self.threat_scores[employee] = 1.0 if was_insider else 0.0

        # Redistribute among remaining
        remaining = [i for i in range(self.n) if i not in self.investigated]
        known_insiders = sum(1 for i in self.investigated
                            if self.threat_scores[i] == 1.0)
        remaining_insiders = self.k - known_insiders

        if remaining and remaining_insiders >= 0:
            for i in remaining:
                self.threat_scores[i] = remaining_insiders / len(remaining)


# ─── Application 2: Epidemiological Contact Tracing ────────────────

class ContactTracer:
    """
    Map Werewolf framework to contact tracing.

    People are "players", infected individuals are "werewolves".
    Contact events and symptoms provide Bayesian evidence.
    Testing (elimination) reveals true status.

    Key insight: the werewolf fraction monotonicity theorem implies
    that as more people are tested negative, the infection probability
    among remaining untested individuals increases.
    """

    def __init__(self, population: int, estimated_infected: int):
        self.n = population
        self.k = estimated_infected
        self.infection_prob = [estimated_infected / population] * population
        self.tested: set[int] = set()

    def observe_contact(self, person: int, with_person: int) -> None:
        """Update infection probability after observing contact with high-risk person."""
        if person in self.tested:
            return

        risk = self.infection_prob[with_person]
        prior = self.infection_prob[person]
        # Contact with infected person increases risk
        transmission_prob = 0.3  # probability of transmission per contact
        p_contact_infected = transmission_prob * risk + (1 - transmission_prob)
        p_contact_healthy = 1.0  # healthy contact is neutral

        posterior = (prior * p_contact_infected) / \
                    (prior * p_contact_infected + (1 - prior) * p_contact_healthy)
        self.infection_prob[person] = min(posterior, 0.99)

    def observe_symptoms(self, person: int, symptom_severity: float) -> None:
        """Update after observing symptoms (0=none, 1=severe)."""
        if person in self.tested:
            return

        prior = self.infection_prob[person]
        p_symptoms_infected = 0.2 + 0.8 * symptom_severity
        p_symptoms_healthy = 0.05 + 0.15 * symptom_severity

        posterior = (prior * p_symptoms_infected) / \
                    (prior * p_symptoms_infected + (1 - prior) * p_symptoms_healthy)
        self.infection_prob[person] = min(posterior, 0.99)

    def prioritize_testing(self, num_tests: int = 1) -> list[int]:
        """Return the most likely infected individuals for testing."""
        candidates = [i for i in range(self.n) if i not in self.tested]
        candidates.sort(key=lambda i: self.infection_prob[i], reverse=True)
        return candidates[:num_tests]


# ─── Application 3: Network Intrusion Detection ───────────────────

def network_threat_assessment(num_nodes: int, num_compromised: int,
                              traffic_anomalies: list[tuple[int, float]]) -> list[tuple[int, float]]:
    """
    Assess network nodes for compromise using Bayesian Werewolf framework.

    Args:
        num_nodes: Total network nodes
        num_compromised: Estimated compromised nodes
        traffic_anomalies: List of (node_id, anomaly_score) observations

    Returns:
        Ranked list of (node_id, threat_probability) sorted by risk
    """
    priors = [num_compromised / num_nodes] * num_nodes

    for node, anomaly_score in traffic_anomalies:
        if 0 <= node < num_nodes:
            prior = priors[node]
            # Compromised nodes generate anomalies with higher probability
            p_anomaly_compromised = 0.2 + 0.8 * anomaly_score
            p_anomaly_normal = 0.05 + 0.2 * anomaly_score

            posterior = (prior * p_anomaly_compromised) / \
                        (prior * p_anomaly_compromised + (1 - prior) * p_anomaly_normal)
            priors[node] = posterior

    results = [(i, priors[i]) for i in range(num_nodes)]
    results.sort(key=lambda x: x[1], reverse=True)
    return results


# ─── Demonstrations ────────────────────────────────────────────────

def demo_insider_threat():
    """Demonstrate insider threat detection."""
    print("=" * 60)
    print("APPLICATION 1: Insider Threat Detection")
    print("=" * 60)

    detector = InsiderThreatDetector(20, 2)
    print(f"\nCompany with {detector.n} employees, ~{detector.k} suspected insiders")
    print(f"Initial threat score: {detector.threat_scores[0]:.4f}")

    # Simulate observations
    detector.observe_anomaly(5, 0.9)   # Employee 5: very suspicious
    detector.observe_anomaly(12, 0.6)  # Employee 12: moderately suspicious
    detector.observe_anomaly(3, 0.2)   # Employee 3: slightly unusual

    print("\nAfter behavioral observations:")
    top = sorted(range(20), key=lambda i: detector.threat_scores[i], reverse=True)[:5]
    for i in top:
        print(f"  Employee {i:2d}: threat = {detector.threat_scores[i]:.4f}")

    rec = detector.recommend_investigation()
    print(f"\nRecommend investigating: Employee {rec}")


def demo_contact_tracing():
    """Demonstrate contact tracing."""
    print("\n" + "=" * 60)
    print("APPLICATION 2: Epidemiological Contact Tracing")
    print("=" * 60)

    tracer = ContactTracer(50, 5)
    print(f"\nPopulation: {tracer.n}, estimated infected: {tracer.k}")

    # Simulate contact network
    tracer.observe_symptoms(10, 0.8)  # Person 10 has symptoms
    tracer.observe_contact(11, 10)     # Person 11 had contact with 10
    tracer.observe_contact(12, 10)     # Person 12 had contact with 10
    tracer.observe_symptoms(11, 0.3)   # Person 11 has mild symptoms

    print("\nAfter observations:")
    priority = tracer.prioritize_testing(5)
    for p in priority:
        print(f"  Person {p:2d}: infection prob = {tracer.infection_prob[p]:.4f}")

    print(f"\nPriority test order: {priority}")


def demo_network_security():
    """Demonstrate network intrusion detection."""
    print("\n" + "=" * 60)
    print("APPLICATION 3: Network Intrusion Detection")
    print("=" * 60)

    anomalies = [(3, 0.95), (7, 0.8), (15, 0.6), (3, 0.85), (7, 0.3)]
    results = network_threat_assessment(20, 2, anomalies)

    print(f"\nNetwork: 20 nodes, ~2 compromised")
    print(f"Anomalies observed: {anomalies}")
    print("\nThreat assessment (top 5):")
    for node, prob in results[:5]:
        print(f"  Node {node:2d}: threat = {prob:.4f}")


if __name__ == "__main__":
    demo_insider_threat()
    demo_contact_tracing()
    demo_network_security()
    print("\n" + "=" * 60)
    print("All applications demonstrated.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Bayesian Werewolf: Optimal Strategy for Social Deduction Games
==============================================================

Demonstrates the core theorems formalized in Lean 4:
1. Game state transitions and win conditions
2. Random elimination probability analysis
3. Villager win probability via Markov chain recursion
4. Bayesian posterior belief updates
5. Shannon entropy of belief states

Usage:
    python demo.py
"""

from fractions import Fraction
from functools import lru_cache
import math


# ─── Game State ─────────────────────────────────────────────────────
class WerewolfState:
    """Tracks remaining werewolves and villagers."""
    def __init__(self, wolves: int, villagers: int):
        self.wolves = wolves
        self.villagers = villagers

    @property
    def total_players(self) -> int:
        return self.wolves + self.villagers

    @property
    def game_over(self) -> bool:
        return self.wolves == 0 or self.wolves >= self.villagers

    @property
    def villagers_win(self) -> bool:
        return self.wolves == 0 and self.villagers > 0

    @property
    def werewolves_win(self) -> bool:
        return self.wolves >= self.villagers and self.wolves > 0

    @property
    def valid(self) -> bool:
        return self.wolves > 0 and self.wolves < self.villagers

    def random_elim_prob(self) -> Fraction:
        """Probability of randomly eliminating a werewolf."""
        if self.total_players == 0:
            return Fraction(0)
        return Fraction(self.wolves, self.total_players)

    def __repr__(self):
        return f"WerewolfState(wolves={self.wolves}, villagers={self.villagers})"


# ─── Villager Win Probability (Markov Chain) ────────────────────────
@lru_cache(maxsize=None)
def villager_win_prob(w: int, v: int) -> float:
    """
    Compute the villager win probability under random elimination.

    This is the absorption probability of the Markov chain on (w, v).
    Matches the Lean definition `villagerWinProb`.
    """
    if w == 0:
        return 1.0 if v > 0 else 0.0
    if w >= v:
        return 0.0
    if v <= 1:
        return 0.0
    tot = w + v
    p_correct = w / tot
    p_incorrect = v / tot
    return (p_correct * villager_win_prob(w - 1, v - 1) +
            p_incorrect * villager_win_prob(w, v - 2))


# ─── Binary Entropy ────────────────────────────────────────────────
def binary_entropy(p: float) -> float:
    """H(p) = -p log p - (1-p) log(1-p), with natural log."""
    if p <= 0 or p >= 1:
        return 0.0
    return -(p * math.log(p) + (1 - p) * math.log(1 - p))


# ─── Bayesian Belief ───────────────────────────────────────────────
def uniform_prior(n: int, k: int) -> list[float]:
    """Uniform prior: each player has probability k/n of being a werewolf."""
    return [k / n] * n


def expected_wolves(belief: list[float]) -> float:
    """Sum of all posterior probabilities."""
    return sum(belief)


def belief_entropy(belief: list[float]) -> float:
    """Total Shannon entropy of a belief state."""
    return sum(binary_entropy(p) for p in belief)


# ─── Demonstrations ────────────────────────────────────────────────
def demo_game_states():
    """Demonstrate basic game state properties."""
    print("=" * 60)
    print("DEMO 1: Game State Properties")
    print("=" * 60)

    s = WerewolfState(2, 5)
    print(f"\nInitial state: {s}")
    print(f"  Total players: {s.total_players}")
    print(f"  Game over? {s.game_over}")
    print(f"  Valid? {s.valid}")
    print(f"  Random elimination prob: {s.random_elim_prob()} = {float(s.random_elim_prob()):.4f}")

    # Theorem: win conditions are exclusive
    print(f"\n  Villagers win? {s.villagers_win}")
    print(f"  Werewolves win? {s.werewolves_win}")
    print(f"  Both win? {s.villagers_win and s.werewolves_win}  (Theorem: always False)")

    # Perfect play
    print(f"\n  With perfect play (2 wolves, 5 villagers, n=7):")
    print(f"  After 2 rounds: state (0, 5-2) = (0, 3)")
    final = WerewolfState(0, 3)
    print(f"  Final state: {final}")
    print(f"  Villagers win? {final.villagers_win}  (Theorem: True when 2k < n)")


def demo_win_probabilities():
    """Demonstrate villager win probability calculations."""
    print("\n" + "=" * 60)
    print("DEMO 2: Villager Win Probabilities (Random Elimination)")
    print("=" * 60)

    print(f"\n{'n':>4} {'k':>4} {'v':>4} {'P(villagers win)':>18} {'Bound 1-k/v':>12}")
    print("-" * 50)

    for n in range(5, 16):
        for k in range(1, n // 2):
            v = n - k
            p = villager_win_prob(k, v)
            bound = 1 - k / v
            print(f"{n:4d} {k:4d} {v:4d} {p:18.6f} {bound:12.4f}")


def demo_one_wolf_recurrence():
    """Demonstrate the one-wolf recurrence (proved in Lean)."""
    print("\n" + "=" * 60)
    print("DEMO 3: One-Wolf Recurrence Relation")
    print("=" * 60)

    print("\nTheorem: villagerWinProb(1, v) = 1/(1+v) · P(0, v-1) + v/(1+v) · P(1, v-2)")
    print(f"\n{'v':>4} {'P(1,v)':>12} {'RHS':>12} {'Match?':>8}")
    print("-" * 40)

    for v in range(3, 12):
        lhs = villager_win_prob(1, v)
        rhs = (1 / (1 + v)) * villager_win_prob(0, v - 1) + \
              (v / (1 + v)) * villager_win_prob(1, v - 2)
        match = abs(lhs - rhs) < 1e-12
        print(f"{v:4d} {lhs:12.6f} {rhs:12.6f} {'✓' if match else '✗':>8}")


def demo_bayesian_beliefs():
    """Demonstrate Bayesian belief framework."""
    print("\n" + "=" * 60)
    print("DEMO 4: Bayesian Beliefs and Shannon Entropy")
    print("=" * 60)

    n, k = 7, 2
    prior = uniform_prior(n, k)
    print(f"\nUniform prior for n={n}, k={k}:")
    print(f"  Probabilities: {[f'{p:.4f}' for p in prior]}")
    print(f"  Expected wolves: {expected_wolves(prior):.4f}  (Theorem: equals k={k})")
    print(f"  Entropy: {belief_entropy(prior):.4f}")
    print(f"  Max entropy: {n * math.log(2):.4f}  (Theorem: entropy ≤ n·log(2))")

    # After observing a suspicious vote pattern (hypothetical update)
    print("\n  After hypothetical Bayesian update (player 3 is suspicious):")
    updated = prior.copy()
    updated[3] = 0.5  # more suspicious
    # Renormalize to keep expected = k
    total = sum(updated)
    updated = [p * k / total for p in updated]
    print(f"  Updated: {[f'{p:.4f}' for p in updated]}")
    print(f"  Expected wolves: {expected_wolves(updated):.4f}")
    print(f"  Entropy: {belief_entropy(updated):.4f}  (lower = more information)")


def demo_fraction_monotonicity():
    """Demonstrate werewolf fraction monotonicity theorems."""
    print("\n" + "=" * 60)
    print("DEMO 5: Werewolf Fraction Monotonicity")
    print("=" * 60)

    w = 2
    print(f"\nWith w={w} wolves:")
    print(f"  {'v':>4} {'w/(w+v)':>12} {'w/(w+v-1)':>12}  Increasing?")
    print("  " + "-" * 44)
    for v in range(3, 10):
        frac1 = Fraction(w, w + v)
        frac2 = Fraction(w, w + v - 1)
        print(f"  {v:4d} {float(frac1):12.6f} {float(frac2):12.6f}  {'✓' if frac1 <= frac2 else '✗'}")

    print(f"\n  Theorem: w/(w+v) ≤ w/(w+v-1) when v > 1 (proved in Lean)")


def demo_conjecture_test():
    """Test the falsifiable conjecture about villager win probability scaling."""
    print("\n" + "=" * 60)
    print("DEMO 6: Conjecture Test — Win Probability Upper Bound")
    print("=" * 60)

    print("\nConjecture: villagerWinProb(k, v) ≤ 1 - k/v")
    print(f"\n{'k':>4} {'v':>4} {'P_win':>12} {'1-k/v':>12} {'Holds?':>8}")
    print("-" * 44)

    all_hold = True
    for n in range(5, 21):
        for k in range(1, n // 2):
            v = n - k
            p = villager_win_prob(k, v)
            bound = 1 - k / v
            holds = p <= bound + 1e-12
            if not holds:
                all_hold = False
            print(f"{k:4d} {v:4d} {p:12.6f} {bound:12.6f} {'✓' if holds else '✗':>8}")

    print(f"\nConjecture {'CONFIRMED' if all_hold else 'REFUTED'} for all tested cases")


if __name__ == "__main__":
    demo_game_states()
    demo_win_probabilities()
    demo_one_wolf_recurrence()
    demo_bayesian_beliefs()
    demo_fraction_monotonicity()
    demo_conjecture_test()
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization 2: Shannon Entropy Evolution During Werewolf Games

Shows how the Shannon entropy of the Bayesian belief state evolves
over the course of a game. Entropy decreases as information is gained
through eliminations and observations. This connects game theory
to information theory — the key cross-domain bridge in our research.
"""

import numpy as np
import matplotlib.pyplot as plt
import math
import random


def binary_entropy(p: float) -> float:
    """Binary entropy H(p) = -p log p - (1-p) log(1-p)."""
    if p <= 0 or p >= 1:
        return 0.0
    return -(p * math.log(p) + (1 - p) * math.log(1 - p))


def simulate_game_entropy(n: int, k: int, seed: int = 42) -> tuple[list[int], list[float], list[float]]:
    """
    Simulate a game tracking entropy evolution.

    Returns:
        rounds: List of round numbers
        entropies: Shannon entropy at each round
        max_beliefs: Maximum belief (suspicion) at each round
    """
    random.seed(seed)
    wolves = set(random.sample(range(n), k))
    alive = list(range(n))
    beliefs = [k / n] * n

    rounds = [0]
    entropies = [sum(binary_entropy(p) for p in beliefs)]
    max_beliefs_list = [max(beliefs)]

    round_num = 0
    while True:
        alive_wolves = [p for p in alive if p in wolves]
        alive_villagers = [p for p in alive if p not in wolves]

        if len(alive_wolves) == 0 or len(alive_wolves) >= len(alive_villagers):
            break

        # Day: eliminate random player
        target = random.choice(alive)
        is_wolf = target in wolves
        alive.remove(target)

        # Update beliefs after elimination reveal
        beliefs[target] = 1.0 if is_wolf else 0.0
        remaining = [i for i in alive if beliefs[i] not in (0.0, 1.0)]
        known_wolf_count = sum(1 for i in range(n) if beliefs[i] == 1.0)
        remaining_wolves_est = k - known_wolf_count

        if remaining and remaining_wolves_est >= 0:
            for i in remaining:
                beliefs[i] = max(0, min(1, remaining_wolves_est / len(remaining)))

        round_num += 1
        rounds.append(round_num)
        entropies.append(sum(binary_entropy(beliefs[i]) for i in alive))
        max_beliefs_list.append(max(beliefs[i] for i in alive) if alive else 0)

        # Check win
        alive_wolves = [p for p in alive if p in wolves]
        alive_villagers = [p for p in alive if p not in wolves]
        if len(alive_wolves) == 0 or len(alive_wolves) >= len(alive_villagers):
            break

        # Night: wolves kill a villager
        if alive_villagers:
            victim = random.choice(alive_villagers)
            alive.remove(victim)
            beliefs[victim] = 0.0

            remaining = [i for i in alive if beliefs[i] not in (0.0, 1.0)]
            if remaining and remaining_wolves_est >= 0:
                for i in remaining:
                    beliefs[i] = max(0, min(1, remaining_wolves_est / len(remaining)))

            round_num += 1
            rounds.append(round_num)
            entropies.append(sum(binary_entropy(beliefs[i]) for i in alive))
            max_beliefs_list.append(max(beliefs[i] for i in alive) if alive else 0)

    return rounds, entropies, max_beliefs_list


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot multiple game simulations
ax1 = axes[0]
colors = plt.cm.viridis(np.linspace(0, 0.9, 5))
configs = [(7, 2), (9, 3), (11, 3), (13, 4), (15, 5)]

for i, (n, k) in enumerate(configs):
    rounds, entropies, _ = simulate_game_entropy(n, k, seed=42 + i)
    max_entropy = n * math.log(2)
    normalized = [e / max_entropy for e in entropies]
    ax1.plot(rounds, normalized, 'o-', color=colors[i],
             label=f'n={n}, k={k}', linewidth=2, markersize=5)

ax1.set_xlabel('Round', fontsize=13)
ax1.set_ylabel('Normalized Entropy (H / n·ln2)', fontsize=13)
ax1.set_title('Entropy Decrease During Games\n(Information Gain)', fontsize=14, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(-0.05, 1.05)

# Plot entropy bound verification
ax2 = axes[1]
ns = list(range(5, 21))
for k in [1, 2, 3]:
    initial_entropies = []
    bounds = []
    for n in ns:
        if k < n // 2:
            prior = k / n
            h = n * binary_entropy(prior)
            bound = n * math.log(2)
            initial_entropies.append(h)
            bounds.append(bound)
        else:
            initial_entropies.append(None)
            bounds.append(None)

    valid = [(n, e, b) for n, e, b in zip(ns, initial_entropies, bounds)
             if e is not None]
    if valid:
        vn, ve, vb = zip(*valid)
        ax2.plot(vn, ve, 'o-', label=f'H(prior), k={k}', linewidth=2)

ax2.plot(ns, [n * math.log(2) for n in ns], 'k--',
         label='n·ln(2) (upper bound)', linewidth=2)

ax2.set_xlabel('Number of Players (n)', fontsize=13)
ax2.set_ylabel('Shannon Entropy', fontsize=13)
ax2.set_title('Entropy Bound Verification\n(Theorem: H ≤ n·ln(2))', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_entropy_evolution.png', dpi=150, bbox_inches='tight')
print("Saved viz_entropy_evolution.png")


#!/usr/bin/env python3
"""
Visualization 3: Werewolf Fraction Monotonicity

Visualizes the two key monotonicity theorems proved in Lean:
1. Werewolf fraction increases when a villager is removed
2. Werewolf fraction decreases when a werewolf is removed

These theorems explain WHY the game gets progressively harder
for villagers: each mistake (eliminating a villager) makes future
mistakes more likely, creating a positive feedback loop.
"""

import numpy as np
import matplotlib.pyplot as plt


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Fraction increases as villagers are removed (fixed w)
ax1 = axes[0]
for w in [1, 2, 3, 4]:
    vs = list(range(w + 2, 20))
    fracs = [w / (w + v) for v in vs]
    ax1.plot(vs, fracs, 'o-', label=f'w={w}', linewidth=2, markersize=4)

ax1.set_xlabel('Villagers (v)', fontsize=12)
ax1.set_ylabel('Werewolf Fraction w/(w+v)', fontsize=12)
ax1.set_title('Wolf Fraction vs Villagers\n(Decreasing: removing villagers\nincreases wolf fraction)',
              fontsize=11, fontweight='bold')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)
ax1.invert_xaxis()  # Show effect of removing villagers

# Panel 2: Game trajectory showing fraction evolution
ax2 = axes[1]
scenarios = [
    ("Perfect play", [(2, 5), (1, 4), (0, 3)], 'green'),
    ("All mistakes", [(2, 5), (2, 3), (2, 1)], 'red'),
    ("Mixed (1 correct, 1 wrong)", [(2, 5), (1, 4), (1, 2)], 'orange'),
]

for label, trajectory, color in scenarios:
    fracs = [w / (w + v) if w + v > 0 else 1.0 for w, v in trajectory]
    rounds = list(range(len(trajectory)))
    ax2.plot(rounds, fracs, 'o-', color=color, label=label,
             linewidth=2.5, markersize=8)
    for r, (w, v) in enumerate(trajectory):
        ax2.annotate(f'({w},{v})', (r, fracs[r]),
                    textcoords="offset points", xytext=(5, 10),
                    fontsize=8, color=color)

ax2.axhline(y=0.5, color='black', linestyle=':', linewidth=1.5,
            label='w=v (wolf win)')
ax2.set_xlabel('Round', fontsize=12)
ax2.set_ylabel('Werewolf Fraction', fontsize=12)
ax2.set_title('Game Trajectories (n=7, k=2)\n(States shown as (w,v))',
              fontsize=11, fontweight='bold')
ax2.legend(fontsize=8, loc='upper left')
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0, 1.05)

# Panel 3: The "vicious cycle" effect
ax3 = axes[2]
# Show how probability of correct elimination changes along paths
w_start, v_start = 2, 8
rounds_correct = []
rounds_incorrect = []
w, v = w_start, v_start

# Correct path
ws, vs = [w], [v]
while w > 0 and w < v and v > 1:
    w -= 1; v -= 1  # correct elimination + night kill
    ws.append(w); vs.append(v)
probs_correct = [wi / (wi + vi) if wi + vi > 0 else 0 for wi, vi in zip(ws, vs)]

# Incorrect path
w, v = w_start, v_start
ws2, vs2 = [w], [v]
while w > 0 and w < v and v > 2:
    v -= 2  # incorrect elimination + night kill (lose 2 villagers)
    ws2.append(w); vs2.append(v)
probs_incorrect = [wi / (wi + vi) if wi + vi > 0 else 0 for wi, vi in zip(ws2, vs2)]

ax3.plot(range(len(probs_correct)), probs_correct, 's-', color='green',
         label='Correct eliminations', linewidth=2.5, markersize=8)
ax3.plot(range(len(probs_incorrect)), probs_incorrect, 'D-', color='red',
         label='Incorrect eliminations', linewidth=2.5, markersize=8)

ax3.axhline(y=0.5, color='black', linestyle=':', linewidth=1.5)
ax3.fill_between(range(max(len(probs_correct), len(probs_incorrect))),
                 0.5, 1.0, alpha=0.1, color='red', label='Wolf win zone')

ax3.set_xlabel('Round', fontsize=12)
ax3.set_ylabel('P(correct next elimination)', fontsize=12)
ax3.set_title('The Vicious Cycle Effect\n(n=10, k=2)',
              fontsize=11, fontweight='bold')
ax3.legend(fontsize=8)
ax3.grid(True, alpha=0.3)
ax3.set_ylim(0, 1.05)

plt.suptitle('Werewolf Fraction Monotonicity — Formally Verified',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_fraction_monotonicity.png', dpi=150, bbox_inches='tight')
print("Saved viz_fraction_monotonicity.png")


#!/usr/bin/env python3
"""
Visualization 1: Villager Win Probability Heatmap

Visualizes the exact villager win probability under random elimination
as a heatmap over the (wolves, villagers) state space. The absorbing
states (wolves = 0 or wolves ≥ villagers) form the boundary conditions.
This directly corresponds to the Lean-verified `villagerWinProb` function.
"""

import numpy as np
import matplotlib.pyplot as plt
from functools import lru_cache


@lru_cache(maxsize=None)
def villager_win_prob(w: int, v: int) -> float:
    """Exact villager win probability under random elimination."""
    if w == 0:
        return 1.0 if v > 0 else 0.0
    if w >= v:
        return 0.0
    if v <= 1:
        return 0.0
    tot = w + v
    return (w / tot) * villager_win_prob(w - 1, v - 1) + \
           (v / tot) * villager_win_prob(w, v - 2)


max_w = 10
max_v = 20

# Build heatmap data
data = np.full((max_w + 1, max_v + 1), np.nan)
for w in range(max_w + 1):
    for v in range(max_v + 1):
        data[w, v] = villager_win_prob(w, v)

fig, ax = plt.subplots(figsize=(12, 7))
im = ax.imshow(data, origin='lower', aspect='auto',
               cmap='RdYlGn', vmin=0, vmax=1,
               extent=[-0.5, max_v + 0.5, -0.5, max_w + 0.5])

# Add diagonal line for w = v (werewolf win boundary)
ax.plot([0, max_w], [0, max_w], 'k--', linewidth=2, label='w = v (wolf win boundary)')

# Annotate key states
for w in range(max_w + 1):
    for v in range(max_v + 1):
        if w + v <= 12 and not np.isnan(data[w, v]):
            val = data[w, v]
            color = 'white' if val < 0.3 or val > 0.7 else 'black'
            ax.text(v, w, f'{val:.2f}', ha='center', va='center',
                    fontsize=6, color=color, fontweight='bold')

ax.set_xlabel('Villagers (v)', fontsize=14)
ax.set_ylabel('Werewolves (w)', fontsize=14)
ax.set_title('Villager Win Probability Under Random Elimination\n'
             '(Markov Chain Absorption Probability)',
             fontsize=16, fontweight='bold')

cbar = plt.colorbar(im, ax=ax, shrink=0.8)
cbar.set_label('P(Villagers Win)', fontsize=12)

ax.legend(loc='upper right', fontsize=11)
plt.tight_layout()
plt.savefig('viz_win_probability.png', dpi=150, bbox_inches='tight')
print("Saved viz_win_probability.png")
