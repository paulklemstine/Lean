#!/usr/bin/env python3
"""
Self-Improving Mathematical Discovery Loop: Core Demo

Demonstrates the pi-agent ↔ Aristotle feedback loop architecture:
1. Prompt Selection (UCB-based explore/exploit)
2. Discovery Simulation (theorem proving with diminishing returns)
3. Catalog Integration (monotone knowledge growth)
4. Convergence Analysis (fixed-point detection)

Based on the formalized theory in MachineLearning/SelfImproving/LoopFoundations.lean
and MachineLearning/SelfImproving/ConvergenceTheory.lean.
"""

import numpy as np
import json
import os
from dataclasses import dataclass, field
from typing import List, Dict, Tuple, Optional
from collections import defaultdict

# ============================================================
# 1. Knowledge Catalog Model
# ============================================================

@dataclass
class Theorem:
    """A discovered mathematical theorem."""
    id: int
    name: str
    domain: str
    depth: float      # Mathematical depth (0-10)
    novelty: float    # Novelty score at time of discovery
    dependencies: List[int] = field(default_factory=list)
    step_discovered: int = 0

@dataclass
class KnowledgeCatalog:
    """
    Monotone growing catalog of verified theorems.
    Matches the Lean formalization: theorems(n) ⊆ theorems(n+1).
    """
    theorems: Dict[int, Theorem] = field(default_factory=dict)
    history: List[int] = field(default_factory=list)  # catalog size at each step
    domains: List[str] = field(default_factory=lambda: [
        "Algebra", "Geometry", "Topology", "Analysis",
        "NumberTheory", "Combinatorics", "Logic",
        "Physics", "Cryptography", "MachineLearning",
        "TropicalGeometry", "CategoryTheory", "Computation"
    ])

    def size(self) -> int:
        return len(self.theorems)

    def add_theorem(self, thm: Theorem):
        self.theorems[thm.id] = thm

    def snapshot(self):
        self.history.append(self.size())

    def domain_counts(self) -> Dict[str, int]:
        counts = defaultdict(int)
        for thm in self.theorems.values():
            counts[thm.domain] += 1
        return dict(counts)


# ============================================================
# 2. Prompt Strategy with UCB
# ============================================================

@dataclass
class PromptStrategy:
    """
    Upper Confidence Bound strategy for prompt selection.
    Matches the UCB formalization in ConvergenceTheory.lean.

    UCB(domain) = mean_reward(domain) + c * sqrt(log(total) / n_domain)
    """
    domain_rewards: Dict[str, List[float]] = field(default_factory=lambda: defaultdict(list))
    exploration_constant: float = 1.5
    total_pulls: int = 0

    def ucb_score(self, domain: str) -> float:
        rewards = self.domain_rewards[domain]
        if not rewards:
            return float('inf')  # Explore unvisited domains first
        mean = np.mean(rewards)
        n = len(rewards)
        exploration = self.exploration_constant * np.sqrt(
            np.log(max(1, self.total_pulls)) / n
        )
        return mean + exploration

    def select_domain(self, domains: List[str]) -> str:
        scores = {d: self.ucb_score(d) for d in domains}
        return max(scores, key=scores.get)

    def update(self, domain: str, reward: float):
        self.domain_rewards[domain].append(reward)
        self.total_pulls += 1


# ============================================================
# 3. Discovery Simulator
# ============================================================

class DiscoverySimulator:
    """
    Simulates the Aristotle theorem-proving process.
    Models diminishing returns as formalized in DiminishingReturns.
    """

    def __init__(self, base_rate: float = 5.0, decay: float = 0.02,
                 synergy_matrix: Optional[np.ndarray] = None):
        self.base_rate = base_rate
        self.decay = decay
        self.next_id = 0
        self.step = 0

        # Cross-domain synergy (matches DomainSynergy in ConvergenceTheory.lean)
        if synergy_matrix is not None:
            self.synergy = synergy_matrix
        else:
            n = 13
            self.synergy = np.eye(n) + 0.1 * np.random.rand(n, n)
            np.fill_diagonal(self.synergy, 1.0)

    def discover(self, domain: str, catalog: KnowledgeCatalog) -> List[Theorem]:
        """Simulate discovering theorems in a domain."""
        self.step += 1

        # Diminishing returns: reward(n) is antitone
        domain_count = sum(1 for t in catalog.theorems.values() if t.domain == domain)
        effective_rate = self.base_rate * np.exp(-self.decay * domain_count)

        # Cross-domain synergy boost
        domain_idx = catalog.domains.index(domain)
        synergy_boost = 0
        for j, d in enumerate(catalog.domains):
            if j < len(self.synergy) and domain_idx < len(self.synergy):
                d_count = sum(1 for t in catalog.theorems.values() if t.domain == d)
                synergy_boost += self.synergy[domain_idx][j] * (d_count > 0)

        effective_rate *= (1 + 0.1 * synergy_boost)

        # Generate theorems
        n_theorems = max(1, int(np.random.poisson(effective_rate)))
        new_theorems = []

        for _ in range(n_theorems):
            # Novelty decreases with catalog size
            novelty = max(0.1, 1.0 - catalog.size() / 1000)

            # Depth increases with existing knowledge
            depth = min(10, 1.0 + 0.5 * np.log1p(domain_count))

            # Dependencies from existing theorems
            existing_ids = [t.id for t in catalog.theorems.values()
                          if t.domain == domain]
            n_deps = min(len(existing_ids), np.random.randint(0, 4))
            deps = list(np.random.choice(existing_ids, n_deps, replace=False)) if existing_ids and n_deps > 0 else []

            thm = Theorem(
                id=self.next_id,
                name=f"{domain}_thm_{self.next_id}",
                domain=domain,
                depth=depth + np.random.normal(0, 0.3),
                novelty=novelty * np.random.uniform(0.5, 1.5),
                dependencies=deps,
                step_discovered=self.step
            )
            new_theorems.append(thm)
            self.next_id += 1

        return new_theorems


# ============================================================
# 4. Self-Improving Loop
# ============================================================

class SelfImprovingLoop:
    """
    The complete pi-agent ↔ Aristotle feedback loop.

    Matches the SelfImprovingLoop structure in LoopFoundations.lean:
    - state: catalog valuation at each step
    - transition: one round of prompt → discover → archive → analyze
    - contractive: the discovery rate converges
    """

    def __init__(self, catalog: KnowledgeCatalog, strategy: PromptStrategy,
                 simulator: DiscoverySimulator):
        self.catalog = catalog
        self.strategy = strategy
        self.simulator = simulator
        self.step_rewards: List[float] = []
        self.step_domains: List[str] = []
        self.regret_history: List[float] = []

    def run_step(self) -> Tuple[str, int, float]:
        """Execute one iteration of the self-improving loop."""

        # 1. PROMPT: pi-agent selects optimal domain
        domain = self.strategy.select_domain(self.catalog.domains)

        # 2. DISCOVER: Aristotle proves theorems
        new_theorems = self.simulator.discover(domain, self.catalog)

        # 3. ARCHIVE: Integrate into catalog
        for thm in new_theorems:
            self.catalog.add_theorem(thm)
        self.catalog.snapshot()

        # 4. ANALYZE: Compute reward and update strategy
        reward = sum(t.novelty * t.depth for t in new_theorems)
        self.strategy.update(domain, reward)
        self.step_rewards.append(reward)
        self.step_domains.append(domain)

        return domain, len(new_theorems), reward

    def run(self, n_steps: int = 100, verbose: bool = True):
        """Run the full loop for n_steps iterations."""
        if verbose:
            print("=" * 70)
            print("SELF-IMPROVING MATHEMATICAL DISCOVERY LOOP")
            print("pi-agent ↔ Aristotle Feedback Architecture")
            print("=" * 70)
            print(f"\nDomains: {len(self.catalog.domains)}")
            print(f"UCB exploration constant: {self.strategy.exploration_constant}")
            print(f"Base discovery rate: {self.simulator.base_rate}")
            print(f"Diminishing returns decay: {self.simulator.decay}")
            print()

        for step in range(n_steps):
            domain, n_new, reward = self.run_step()

            if verbose and (step < 10 or step % 10 == 0 or step == n_steps - 1):
                print(f"Step {step+1:4d} | Domain: {domain:20s} | "
                      f"New: {n_new:3d} | Reward: {reward:7.2f} | "
                      f"Catalog: {self.catalog.size():5d}")

        if verbose:
            print("\n" + "=" * 70)
            print("FINAL STATISTICS")
            print("=" * 70)
            self.print_statistics()

    def print_statistics(self):
        print(f"\nTotal theorems discovered: {self.catalog.size()}")
        print(f"Total steps: {len(self.step_rewards)}")
        print(f"Mean reward per step: {np.mean(self.step_rewards):.2f}")
        print(f"Reward std: {np.std(self.step_rewards):.2f}")

        # Domain distribution
        print("\nDomain Distribution:")
        counts = self.catalog.domain_counts()
        for domain in sorted(counts.keys(), key=lambda d: counts[d], reverse=True):
            bar = "█" * (counts[domain] // 3)
            print(f"  {domain:20s}: {counts[domain]:4d} {bar}")

        # Convergence analysis
        if len(self.step_rewards) > 10:
            first_10 = np.mean(self.step_rewards[:10])
            last_10 = np.mean(self.step_rewards[-10:])
            print(f"\nConvergence Analysis:")
            print(f"  Mean reward (first 10 steps):  {first_10:.2f}")
            print(f"  Mean reward (last 10 steps):   {last_10:.2f}")
            print(f"  Ratio (diminishing returns):   {last_10/first_10:.3f}")

        # Knowledge graph density
        total_deps = sum(len(t.dependencies) for t in self.catalog.theorems.values())
        n = self.catalog.size()
        max_edges = n * (n - 1) / 2 if n > 1 else 1
        print(f"\nKnowledge Graph:")
        print(f"  Vertices (theorems): {n}")
        print(f"  Edges (dependencies): {total_deps}")
        print(f"  Density: {total_deps / max_edges:.6f}")


# ============================================================
# 5. Convergence Verification
# ============================================================

def verify_convergence(loop: SelfImprovingLoop):
    """
    Verify the mathematical properties formalized in Lean:
    1. Catalog monotonicity
    2. Diminishing returns
    3. Fixed point convergence
    """
    print("\n" + "=" * 70)
    print("CONVERGENCE VERIFICATION")
    print("(Matching Lean formalizations)")
    print("=" * 70)

    history = loop.catalog.history

    # 1. Monotonicity (KnowledgeCatalog.size_mono)
    is_monotone = all(history[i] <= history[i+1] for i in range(len(history)-1))
    print(f"\n1. Catalog monotonicity (size_mono): {'✓ VERIFIED' if is_monotone else '✗ FAILED'}")
    print(f"   Size sequence: {history[:5]} ... {history[-5:]}")

    # 2. Diminishing returns (DiminishingReturns)
    rewards = loop.step_rewards
    window = 10
    if len(rewards) >= 2 * window:
        moving_avg = [np.mean(rewards[i:i+window])
                      for i in range(0, len(rewards) - window + 1, window)]
        is_diminishing = all(moving_avg[i] >= moving_avg[i+1] * 0.8
                            for i in range(len(moving_avg)-1))
        print(f"\n2. Diminishing returns trend: {'✓ CONFIRMED' if is_diminishing else '~ WEAK'}")
        print(f"   Moving averages: {[f'{x:.1f}' for x in moving_avg[:6]]}")

    # 3. Fixed point convergence (loop_converges)
    if len(rewards) >= 20:
        diffs = [abs(rewards[i+1] - rewards[i]) for i in range(len(rewards)-1)]
        late_diffs = diffs[-20:]
        early_diffs = diffs[:20]
        convergence_ratio = np.mean(late_diffs) / max(np.mean(early_diffs), 1e-10)
        print(f"\n3. Fixed point convergence (loop_converges):")
        print(f"   Early volatility: {np.mean(early_diffs):.2f}")
        print(f"   Late volatility:  {np.mean(late_diffs):.2f}")
        print(f"   Convergence ratio: {convergence_ratio:.3f}")
        print(f"   Status: {'✓ CONVERGING' if convergence_ratio < 0.8 else '~ SLOW CONVERGENCE'}")

    # 4. Cross-pollination (cross_pollination_superadditive)
    counts = loop.catalog.domain_counts()
    n_active = sum(1 for c in counts.values() if c > 0)
    print(f"\n4. Cross-domain coverage:")
    print(f"   Active domains: {n_active}/{len(loop.catalog.domains)}")
    print(f"   Coverage: {n_active/len(loop.catalog.domains)*100:.0f}%")

    # 5. Bellman value computation
    gamma = 0.95
    bellman_value = sum(gamma**i * r for i, r in enumerate(rewards))
    theoretical_bound = max(rewards) / (1 - gamma) if rewards else 0
    print(f"\n5. Bellman value analysis:")
    print(f"   Discounted total value (γ={gamma}): {bellman_value:.1f}")
    print(f"   Theoretical upper bound: {theoretical_bound:.1f}")
    print(f"   Efficiency: {bellman_value/theoretical_bound*100:.1f}%")


# ============================================================
# 6. Main Execution
# ============================================================

def main():
    np.random.seed(42)

    # Initialize components
    catalog = KnowledgeCatalog()
    strategy = PromptStrategy(exploration_constant=1.5)
    simulator = DiscoverySimulator(base_rate=5.0, decay=0.015)

    # Seed the catalog with initial theorems (matching project's existing catalog)
    seed_domains = ["Algebra", "Geometry", "NumberTheory", "Logic", "Analysis"]
    for i, domain in enumerate(seed_domains):
        for j in range(3):
            catalog.add_theorem(Theorem(
                id=i*3+j, name=f"seed_{domain}_{j}",
                domain=domain, depth=2.0, novelty=1.0,
                step_discovered=0
            ))
    simulator.next_id = 15
    catalog.snapshot()

    # Run the self-improving loop
    loop = SelfImprovingLoop(catalog, strategy, simulator)
    loop.run(n_steps=100, verbose=True)

    # Verify convergence properties
    verify_convergence(loop)

    # Export results
    results = {
        "total_theorems": catalog.size(),
        "steps": len(loop.step_rewards),
        "domain_distribution": catalog.domain_counts(),
        "mean_reward": float(np.mean(loop.step_rewards)),
        "catalog_history": catalog.history,
        "rewards": [float(r) for r in loop.step_rewards],
    }

    output_path = os.path.join(os.path.dirname(__file__), "loop_results.json")
    with open(output_path, 'w') as f:
        json.dump(results, f, indent=2)
    print(f"\nResults exported to {output_path}")


if __name__ == "__main__":
    main()
